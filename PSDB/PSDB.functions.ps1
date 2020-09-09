function _setDefaultResource {
    param (
        [string] $ResourceName,
        [object[]] $Resources
    )
    if ($Resources.Count -gt 1) {
        $Resources = $Resources -join ","
    }
    [System.Environment]::SetEnvironmentVariable("PSDB_$($ResourceName.ToUpper())", $Resources, "Process")
}
function _getDefaultSubscription {
    return $env:PSDB_SUBSCRIPTION
}
function _getDefaultSubscriptions {
    return ($env:PSDB_SUBSCRIPTIONS -split ",")
}
# Using this function only for tab completers.
function _getResources {
    param (
        [switch] $ResourceGroups,
        [switch] $SqlServers,
        [switch] $StorageAccounts,
        [switch] $KeyVaults,
        [switch] $SqlDatabases
    )
    if ($ResourceGroups) {
        $rsgs = $env:PSDB_RESOURCEGROUPS -split ","
        if (-not $rsgs) {
            $resources = Get-AzResource
            $resourceGroupNames = $resources.ResourceGroupName | Select-Object -Unique
            _setDefaultResource -ResourceName "ResourceGroups" -Resources $resourceGroupNames
            [PSDBResources]::ResourceGroups = $env:PSDB_RESOURCEGROUPS  -split ","
            return [PSDBResources]::ResourceGroups
        } else {
            return $rsgs
        }
    }
    if ($SqlServers) {
        $sql = $env:PSDB_SQLSERVERS -split ","
        if (-not $sql) {
            $resources = Get-AzResource
            $servers = $resources | Where-Object {$_.ResourceId -like "*Microsoft.Sql*" -and $_.Name -notlike "*/*"} | Select-Object Name
            _setDefaultResource -ResourceName "SqlServers" -Resources $servers.Name
            [PSDBResources]::SqlServers = $env:PSDB_SQLSERVERS -split ","
            return [PSDBResources]::SqlServers
        } else {
            return $sql
        }
    }
    if ($StorageAccounts) {
        $storage = $env:PSDB_STORAGEACCOUNTS -split ","
        if (-not $storage) {
            $resources = @()
            $currentContext = (Get-AzContext).Subscription.Name
            $subscriptions = if ([string]::IsNullOrEmpty($env:PSDB_SUBSCRIPTIONS)) { (Get-AzContext -ListAvailable).Subscription.Name } else { _getDefaultSubscriptions }
            $subscriptions | ForEach-Object { Set-AzContext -Subscription $_ > $null; $resources += Get-AzResource }
            Set-AzContext -Subscription $currentContext
            # $resources = Get-AzResource
            $accounts = $resources | Where-Object {$_.ResourceId -like "*Microsoft.Storage*"} | Select-Object Name
            _setDefaultResource -ResourceName "StorageAccounts" -Resources $accounts.Name
            [PSDBResources]::StorageAccounts = $env:PSDB_STORAGEACCOUNTS -split ","
            return [PSDBResources]::StorageAccounts
        } else {
            return $storage
        }
    }
    if ($KeyVaults) {
        $kvs = $env:PSDB_KEYVAULTS -split ","
        if (-not $kvs) {
            $resources = Get-AzResource
            $kVaults = $resources | Where-Object {$_.ResourceId -like "*Microsoft.KeyVault*"} | Select-Object Name
            _setDefaultResource -ResourceName "KeyVaults" -Resources $kVaults.Name
            [PSDBResources]::KeyVaults = $env:PSDB_KEYVAULTS -split ","
            return [PSDBResources]::KeyVaults
        } else {
            return $kvs
        }
    }
    if ($SqlDatabases) {
        $dbs = $env:PSDB_DATABASES -split ","
        if (-not $dbs) {
            $resources = Get-AzResource
            $databases = $resources | Where-Object {$_.ResourceType -eq "Microsoft.Sql/servers/databases"} | Select-Object Name
            $databases = $databases | Where-Object { $_.Name -notlike "*master*" }
            _setDefaultResource -ResourceName "DATABASES" -Resources $databases.Name.Split("/")[1]
            [PSDBResources]::SqlDatabases = $env:PSDB_DATABASES -split ","
            return [PSDBResources]::SqlDatabases
        } else {
            return $dbs
        }
    }
    return Get-AzResource
}
function _getStorageAccountKey {
    param (
        [string] $StorageAccountName
    )
    $storageAccounts = Get-AzStorageAccount
    $storage = $storageAccounts | Where-Object {$_.StorageAccountName -eq $StorageAccountName} | Select-Object ResourceGroupName
    $keys = Get-AzStorageAccountKey -ResourceGroupName $storage.ResourceGroupName -Name $StorageAccountName
    return $keys.Value[1]
}
function _getStorageUri {
    param (
        [string] $StorageAccountName,
        [string] $StorageContainerName
    )
    $key = _getStorageAccountKey -StorageAccountName $StorageAccountName
    $context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $key
    $container = Get-AzStorageContainer -Name $StorageContainerName -Context $context
    return $container.CloudBlobContainer.Uri.AbsoluteUri
}
function _getBacpacName {
    param(
        [string] $DatabaseName
    )
    if ([string]::IsNullOrEmpty($DatabaseName)) {
        return "-$(Get-Date -UFormat %Y-%m-%d-%H-%M).bacpac"
    } else {
        return "$DatabaseName-$(Get-Date -UFormat %Y-%m-%d-%H-%M).bacpac"
    }
}
function _clearDefaults {
    $env:PSDB_RESOURCEGROUPNAME = $null
    $env:PSDB_RESOURCEGROUPS = $null
    $env:PSDB_SQLSERVERS = $null
    # $env:PSDB_STORAGEACCOUNTS = $null
    $env:PSDB_DATABASES = $null
    $env:PSDB_SUBSCRIPTION = $null
    # $env:PSDB_SUBSCRIPTIONS = $null
}
function _getLatestBacPacFile {
    param (
        [string] $StorageAccountName,
        [string] $StorageContainerName
    )
    $key = _getStorageAccountKey -StorageAccountName $StorageAccountName
    $context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $key
    $blob = Get-AzStorageBlob -Blob "*.bacpac" -Container $StorageContainerName -Context $context
    return ($blob | Sort-Object -Descending | Select-Object -First 1).Name
}
function _convertToPlainText {
    param (
        [securestring] $Password
    )
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
}
function _containerValidation {
    param (
        [string] $StorageAccountName,
        [string] $StorageContainerName
    )
    $validated = $false
    #Container validation
    try {
        $Context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey (_getStorageAccountKey $StorageAccountName)
        $container = Get-AzStorageContainer -Name $StorageContainerName -Context $Context -ErrorAction SilentlyContinue
        if (-not ([string]::IsNullOrEmpty($container))) { $validated = $true } else { $validated = $false }
    }
    catch {
        $validated = $false
    }
    return $validated
}
function Export-PSDBSqlDatabase {
    [CmdletBinding()]
    [Alias("Export")]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ResourceGroupValidateAttribute()]
        [ArgumentCompleter([ResourceGroupCompleter])]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceGroupName,
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [SqlDatabaseValidateAttribute()]
        [ArgumentCompleter([DatabaseCompleter])]
        [ValidateNotNullOrEmpty()]
        [string]$DatabaseName,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [SqlServerValidateAttribute()]
        [ArgumentCompleter([SqlServerCompleter])]
        [ValidateNotNullOrEmpty()]
        [string]$ServerName,
        [string]$StorageKeyType = "StorageAccessKey",
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [StorageAcountValidateAttribute()]
        [ArgumentCompleter([StorageAccountCompleter])]
        [ValidateNotNullOrEmpty()]
        [string]$StorageAccountName,
        [Parameter(Mandatory = $true, HelpMessage = "Provide Container Name to save the exported database .bacpac file.", ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$StorageContainerName,
        [Parameter(HelpMessage = "Provide the name of blob that you want to save as.")]
        [ValidateNotNullOrEmpty()]
        [string] $BlobName,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $AdministratorLogin,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [securestring] $AdministratorLoginPassword,
        [Parameter(Mandatory = $false, HelpMessage = "Provide the subscription name if exported .bacpac file have to be saved in different subscription.")]
        [SubscriptionValidateAttribute()]
        [ArgumentCompleter([SubscriptionCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $Subscription
    )
    process {
        try {
            #region start DB export
            if (-not $BlobName) {
                $BlobName = _getBacpacName -DatabaseName $DatabaseName
            }
            if ($PSBoundParameters["Subscription"]) {
                $context = (Get-AzContext).Subscription.Name
                Set-PSDBDefault -Subscription $Subscription
                if (_containerValidation -StorageAccountName $StorageAccountName -StorageContainerName $StorageContainerName) {
                    $storageKey = _getStorageAccountKey -StorageAccountName $StorageAccountName
                    $storageUri = _getStorageUri -StorageAccountName $StorageAccountName -StorageContainerName $StorageContainerName
                    Set-PSDBDefault -Subscription $context
                    $splat = @{
                        DatabaseName = $DatabaseName
                        ServerName = $ServerName
                        StorageKeyType = $StorageKeyType
                        StorageKey = $storageKey
                        StorageUri = "$storageUri/$BlobName"
                        ResourceGroupName = $ResourceGroupName
                        AdministratorLogin = $AdministratorLogin
                        AdministratorLoginPassword = $AdministratorLoginPassword
                        ErrorAction = "Stop"
                    }
                    try {
                        $sqlExport = New-AzSqlDatabaseExport @splat
                        return $sqlExport.OperationStatusLink
                    }
                    catch {
                        if ($_.Exception.Message -match "Login failed") {
                            $Message = "Cannot validate argument on parameter 'AdministratorLogin' and 'AdministratorLoginPassword'. Pass the valid username and password and try again."
                            $ErrorId = "InvalidArgument,PSDBSqlDatabase\Export-PSDBSqlDatabase"
                            Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
                        }
                        else {
                            throw "An error occurred: $($_.Exception.Message)"
                        }
                    }
                }
                else {
                    $Message = "Cannot validate argument on parameter 'StorageContainerName'. '$($StorageContainerName)' is not a valid storage container name. Pass the valid storage container name and try again."
                    $ErrorId = "InvalidArgument,PSDBSqlDatabase\Export-PSDBSqlDatabase"
                    Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
                }
            }
            else {
                if (_containerValidation -StorageAccountName $StorageAccountName -StorageContainerName $StorageContainerName) {
                    $storageKey = _getStorageAccountKey -StorageAccountName $StorageAccountName
                    $storageUri = _getStorageUri -StorageAccountName $StorageAccountName -StorageContainerName $StorageContainerName
                    $splat = @{
                        DatabaseName = $DatabaseName
                        ServerName = $ServerName
                        StorageKeyType = $StorageKeyType
                        StorageKey = $storageKey
                        StorageUri = "$storageUri/$BlobName"
                        ResourceGroupName = $ResourceGroupName
                        AdministratorLogin = $AdministratorLogin
                        AdministratorLoginPassword = $AdministratorLoginPassword
                        ErrorAction = "Stop"
                    }
                    try {
                        $sqlExport = New-AzSqlDatabaseExport @splat
                        return $sqlExport.OperationStatusLink
                    }
                    catch {
                        if ($_.Exception.Message -match "Login failed") {
                            $Message = "Cannot validate argument on parameter 'AdministratorLogin' and 'AdministratorLoginPassword'. Pass the valid username and password and try again."
                            $ErrorId = "InvalidArgument,PSDBSqlDatabase\Export-PSDBSqlDatabase"
                            Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
                        }
                        else {
                            throw "An error occurred: $($_.Exception.Message)"
                        }
                    }
                }
                else {
                    $Message = "Cannot validate argument on parameter 'StorageContainerName'. '$($StorageContainerName)' is not a valid storage container name. Pass the valid storage container name and try again."
                    $ErrorId = "InvalidArgument,PSDBSqlDatabase\Export-PSDBSqlDatabase"
                    Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
                }
            }
            #end region start DB export
        }
        catch {
            throw "An error occurred: $($_.Exception.Message)"
        }
    }
}
#EOF
function Get-PSDBConnectionString {
    process {
        $AzSqlConnectionStrings = @{
            "Standard" = "Server=tcp:myserver.database.windows.net,1433;Database=myDataBase;User ID=mylogin@myserver;Password=myPassword;Trusted_Connection=False;Encrypt=True;"
            "MARS Enabled" = "Server=tcp:myserver.database.windows.net,1433;Database=myDataBase;User ID=mylogin@myserver;Password=myPassword;Trusted_Connection=False;Encrypt=True;MultipleActiveResultSets=True;"
            "Integrated Windows Authentication with AAD" = "Server=tcp:myserver.database.windows.net,1433;Authentication=Active Directory Integrated;Database=mydatabase;"
            "AAD With Username and Password" = "Server=tcp:myserver.database.windows.net,1433;Authentication=Active Directory Password;Database=myDataBase;UID=myUser@myDomain;PWD=myPassword;"
            "Always Encrypted" = "Data Source=myServer;Initial Catalog=myDB;Integrated Security=true;Column Encryption Setting=enabled;"
        }
        return $AzSqlConnectionStrings
    }
}
function Get-PSDBDatabaseData {
    [CmdletBinding()]
    [OutputType([PSCustomobject])]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Provide the database connection string.")]
        [ValidateNotNullOrEmpty()]
        [string] $ConnectionString,
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Query
    )
    process {
        try {
            #region open DB connection
            $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
            $connection.ConnectionString = $ConnectionString
            $command = $connection.CreateCommand()
            $command.CommandText = $Query
            $connection.Open()
            #endregion open DB connection
            # execute the passed query and retrieve data
            $adapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter $command
            $dataset = New-Object -TypeName System.Data.Dataset
            $adapter.Fill($dataset) | Out-Null
            $result = $dataset.Tables
            return $result
        }
        catch {
            throw "An error occurred: $($_.Exception.Message)"
        }
        finally {
            # cleaning up
            $connection.Close()
        }
    }
}
function Get-PSDBImportExportStatus {
    [Alias("Status")]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $StatusLink,
        [int] $Interval = 5,
        [int] $TimeOut = 300,
        [switch] $Wait
    )
    process {
        try {
            $Status = Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $StatusLink -ErrorAction Stop
            if ($Wait.IsPresent) {
                $timeSpan = New-TimeSpan -Seconds $TimeOut
                $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()
                while (($Status.Status -eq "InProgress") -and ($stopWatch.Elapsed.Seconds -lt $timeSpan.TotalSeconds)) {
                    Start-Sleep -Seconds $Interval
                    $Status = Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $StatusLink
                    if (($Status.Status -ne "InProgress") -or ($stopWatch.Elapsed.Seconds -lt $timeSpan.TotalSeconds)) {
                        if ($Status.Status -ne "InProgress") {
                            Write-Output "Status has changed to: $($Status.Status)"
                        }
                    }
                    else { Start-Sleep -Seconds $Interval; continue; }
                }
                $stopWatch.Stop()
            }
            else {
                return $Status.Status
            }
        }
        catch {
            if ($_.Exception.Message -match "Invalid URI") {
                $Message = "Cannot validate argument '$($StatusLink)' on parameter StatusLink. Invalid URI. Pass the correct URI and try again."
                $ErrorId = "InvalidArgument,PSDBImportExportStatus\Export-PSDBImportExportStatus"
                Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
            }
            elseif ($_.Exception.Message -match "An error occurred while sending the request") {
                $Message = "Cannot validate argument '$($StatusLink)' on parameter StatusLink. Invalid URI. Pass the correct URI and try again."
                $ErrorId = "InvalidArgument,PSDBImportExportStatus\Export-PSDBImportExportStatus"
                Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
            }
            else {
                $Message = "$($_.Exception.Message)."
                $ErrorId = "InvalidArgument,PSDBImportExportStatus\Export-PSDBImportExportStatus"
                Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
            }
        }
        finally {
            if ($stopWatch.IsRunning) {
                $stopWatch.Stop()
            }
        }
    }
}
# This function helps to retrieve the secrets from key vault and returns as secure string.
# This then can be used with sql import and export operation.
function Get-PSDBKVSecret {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [KeyVaultValidateAttribute()]
        [ArgumentCompleter([KeyVaultCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $VaultName,
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $SecretName,
        [switch] $AsPlainText,
        [ValidateNotNullOrEmpty()]
        [string] $Version
    )
    process {
        try {
            $kvSecret = Get-AzKeyVaultSecret -VaultName $VaultName -Name $SecretName -IncludeVersions -ErrorAction stop
            if ($null -eq $kvSecret) {
                $Message = "Cannot validate argument on parameter 'SecretName'. '$($SecretName)' is not a valid SecretName. Pass the valid secret name and try again."
                $ErrorId = "InvalidArgument,PSDBKVSecret\Get-PSDBKVSecret"
                Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
            }
            else {
                if ($PSBoundParameters["Version"]) {
                    $secret = $kvSecret | Where-Object { $_.Version -eq $Version }
                    if ($null -eq $secret) {
                        $Message = "Cannot validate argument on parameter 'Version'. '$($Version)' is not a valid Version number. Pass the valid version number and try again."
                        $ErrorId = "InvalidArgument,PSDBKVSecret\Get-PSDBKVSecret"
                        Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
                    }
                    else {
                        if ($AsPlainText.IsPresent) {
                            if ($secret.Enabled) {
                                $kv = Get-AzKeyVaultSecret -VaultName $secret.VaultName -Name $secret.Name -Version $secret.Version
                                $PSCmdlet.WriteObject((_convertToPlainText ($kv.SecretValue -as [securestring])))
                            } else {
                                $Message = "Cannot validate argument on parameter 'SecretName'. '$($SecretName)' is not enabled. Pass the valid secret name and try again."
                                $ErrorId = "InvalidArgument,PSDBKVSecret\Get-PSDBKVSecret"
                                Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
                            }
                        } else {
                            $kv = Get-AzKeyVaultSecret -VaultName $secret.VaultName -Name $secret.Name -Version $secret.Version
                            $PSCmdlet.WriteObject($kv.SecretValue)
                        }
                    }
                }
                else {
                    if ($AsPlainText.IsPresent) {
                        $kvSecret | ForEach-Object {
                            if ($_.Enabled) {
                                $kv = Get-AzKeyVaultSecret -VaultName $_.VaultName -Name $_.Name -Version $_.Version
                                $PSCmdlet.WriteObject((_convertToPlainText ($kv.SecretValue -as [securestring])))
                            }
                        }
                    } else {
                        $kvSecret | ForEach-Object {
                            if ($_.Enabled) {
                                $kv = Get-AzKeyVaultSecret -VaultName $_.VaultName -Name $_.Name -Version $_.Version
                                $PSCmdlet.WriteObject($kv.SecretValue)
                            }
                        }
                    }
                }
            }
        }
        catch {
            $content = $_.Exception.Response.Content
            $content = if ($content) { $content | ConvertFrom-Json }
            if ($content.error.innererror.code -eq "SecretDisabled") {
                $Message = "Cannot validate argument on parameter 'SecretName'. There is no active current version of '$($SecretName)'. Pass the valid secret name and try again."
                $ErrorId = "InvalidArgument,PSDBKVSecret\Get-PSDBKVSecret"
                Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
            }
        }
    }
}
function Import-PSDBSqlDatabase {
    [CmdletBinding()]
    [Alias("Import")]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ResourceGroupValidateAttribute()]
        [ArgumentCompleter([ResourceGroupCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $ResourceGroupName,
        [Parameter(HelpMessage = "Provide the name of database to import as. If not provided by default it will take the name of .bacpac file.")]
        [ValidateNotNullOrEmpty()]
        [string] $ImportDatabaseAs,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [SqlServerValidateAttribute()]
        [ArgumentCompleter([SqlServerCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName,
        [string] $StorageKeyType = "StorageAccessKey",
        [string] $Edition,
        [string] $ServiceObjectiveName,
        [string] $DatabaseMaxSizeBytes,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [StorageAcountValidateAttribute()]
        [ArgumentCompleter([StorageAccountCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $StorageAccountName,
        [Parameter(Mandatory = $true, HelpMessage = "Provide Container Name to import database .bacpac file from.", ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $StorageContainerName,
        [Parameter(HelpMessage = "Provide the name of .bacpac file. If not provided it tries to retrieve latest '.bacpac' file from provided container.")]
        [ValidateNotNullOrEmpty()]
        [string] $BacpacName,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $AdministratorLogin,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [securestring] $AdministratorLoginPassword,
        [Parameter(Mandatory = $false, HelpMessage = "Provide the subscription name to import .bacpac file from.")]
        [SubscriptionValidateAttribute()]
        [ArgumentCompleter([SubscriptionCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $Subscription
    )
    process {
        try {
            if (-not $Edition) {
                $Edition = "Standard"
            }
            if (-not $DatabaseMaxSizeBytes) {
                $DatabaseMaxSizeBytes = "5000000"
            }
            if (-not $ServiceObjectiveName) {
                $ServiceObjectiveName = "S0"
            }
            #region start DB import
            if ($PSBoundParameters["Subscription"]) {
                $context = (Get-AzContext).Subscription.Name
                Set-PSDBDefault -Subscription $Subscription
                if (_containerValidation -StorageAccountName $StorageAccountName -StorageContainerName $StorageContainerName) {
                    $storageKey = _getStorageAccountKey -StorageAccountName $StorageAccountName
                    $storageUri = _getStorageUri -StorageAccountName $StorageAccountName -StorageContainerName $StorageContainerName
                    # Placing this check here because when I'm retrieving the information for different subscription it has to
                    # fetch the correct latest bacpac file. If this is out of this check then the context will be different and
                    # I'm receiving error.
                    if (-not $BacpacName) {
                        $BacpacName = _getLatestBacPacFile -StorageAccountName $StorageAccountName -StorageContainerName $StorageContainerName
                    }
                    if (-not $ImportDatabaseAs) {
                        $ImportDatabaseAs = $BacpacName.Replace(".bacpac", "")
                    }
                    Set-PSDBDefault -Subscription $context
                    $splat = @{
                        DatabaseName = $ImportDatabaseAs
                        ResourceGroupName = $ResourceGroupName
                        ServerName = $ServerName
                        StorageKeyType = "StorageAccessKey"
                        StorageKey = $storageKey
                        StorageUri = "$storageUri/$BacpacName"
                        Edition = $Edition
                        ServiceObjectiveName = $ServiceObjectiveName
                        DatabaseMaxSizeBytes = $DatabaseMaxSizeBytes
                        AdministratorLogin = $AdministratorLogin
                        AdministratorLoginPassword = $AdministratorLoginPassword
                        ErrorAction = "Stop"
                    }
                    try {
                        $sqlImport = New-AzSqlDatabaseImport @splat
                        return $sqlImport.OperationStatusLink
                    }
                    catch {
                        if ($_.Exception.Message -match "Login failed") {
                            $Message = "Cannot validate argument on parameter 'AdministratorLogin' and 'AdministratorLoginPassword'. Pass the valid username and password and try again."
                            $ErrorId = "InvalidArgument,PSDBSqlDatabase\Export-PSDBSqlDatabase"
                            Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
                        }
                        else {
                            throw "An error occurred: $($_.Exception.Message)"
                        }
                    }
                }
                else {
                    $Message = "Cannot validate argument on parameter 'StorageContainerName'. '$($StorageContainerName)' is not a valid storage container name. Pass the valid storage container name and try again."
                    $ErrorId = "InvalidArgument,PSDBSqlDatabase\Export-PSDBSqlDatabase"
                    Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
                }
            }
            else {
                if (_containerValidation -StorageAccountName $StorageAccountName -StorageContainerName $StorageContainerName) {
                    $storageKey = _getStorageAccountKey -StorageAccountName $StorageAccountName
                    $storageUri = _getStorageUri -StorageAccountName $StorageAccountName -StorageContainerName $StorageContainerName
                    if (-not $BacpacName) {
                        $BacpacName = _getLatestBacPacFile -StorageAccountName $StorageAccountName -StorageContainerName $StorageContainerName
                    }
                    if (-not $ImportDatabaseAs) {
                        $ImportDatabaseAs = $BacpacName.Replace(".bacpac", "")
                    }
                    $splat = @{
                        DatabaseName = $ImportDatabaseAs
                        ResourceGroupName = $ResourceGroupName
                        ServerName = $ServerName
                        StorageKeyType = "StorageAccessKey"
                        StorageKey = $storageKey
                        StorageUri = "$storageUri/$BacpacName"
                        Edition = $Edition
                        ServiceObjectiveName = $ServiceObjectiveName
                        DatabaseMaxSizeBytes = $DatabaseMaxSizeBytes
                        AdministratorLogin = $AdministratorLogin
                        AdministratorLoginPassword = $AdministratorLoginPassword
                        ErrorAction = "Stop"
                    }
                    try {
                        $sqlImport = New-AzSqlDatabaseImport @splat
                        return $sqlImport.OperationStatusLink
                    }
                    catch {
                        if ($_.Exception.Message -match "Login failed") {
                            $Message = "Cannot validate argument on parameter 'AdministratorLogin' and 'AdministratorLoginPassword'. Pass the valid username and password and try again."
                            $ErrorId = "InvalidArgument,PSDBSqlDatabase\Export-PSDBSqlDatabase"
                            Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
                        }
                        else {
                            throw "An error occurred: $($_.Exception.Message)"
                        }
                    }
                }
                else {
                    $Message = "Cannot validate argument on parameter 'StorageContainerName'. '$($StorageContainerName)' is not a valid storage container name. Pass the valid storage container name and try again."
                    $ErrorId = "InvalidArgument,PSDBSqlDatabase\Export-PSDBSqlDatabase"
                    Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
                }
            }
            #endregion start DB import
        }
        catch {
            if ($_.Exception.Message -match "The variable cannot be validated") {
                $Message = "Cannot validate argument on parameter 'StorageContainerName'. '$($StorageContainerName)' is not found in storage account '$($StorageAccountName)'. Pass the valid storage container name and try again."
                $ErrorId = "InvalidArgument,PSDBSqlDatabase\Export-PSDBSqlDatabase"
                Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
            }
            elseif ($_.Exception.Message -match "Target database is not empty") {
                $Message = "Database with name '$($ImportDatabaseAs)' already exists in '$($ServerName)'. Pass different name and try again."
                $ErrorId = "InvalidArgument,PSDBSqlDatabase\Export-PSDBSqlDatabase"
                Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
            }
            else {
                throw "An error occurred: $($_.Exception.Message)"
            }
        }
    }
}
function Invoke-PSDBDatabaseQuery {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Provide the database connection string.")]
        [ValidateNotNullOrEmpty()]
        [string] $ConnectionString,
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Query
    )
    process {
        try {
            #region open DB connection
            $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
            $connection.ConnectionString = $ConnectionString
            $command = $connection.CreateCommand()
            $command.CommandText = $Query
            $connection.Open()
            #endregion open DB connection
            # execute query
            $command.ExecuteNonQuery() > $null
        }
        catch {
            throw "An error occurred: $($_.Exception.Message)"
        }
        finally {
            # cleaning up
            $connection.Close()
        }
    }
}
function New-PSDBConnectionString {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding(DefaultParameterSetName = "AADIntegrated")]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Standard")]
        [Parameter(Mandatory = $true, ParameterSetName = "MARSEnabled")]
        [Parameter(Mandatory = $true, ParameterSetName = "AADIntegrated")]
        [Parameter(Mandatory = $true, ParameterSetName = "AAD")]
        [ArgumentCompleter([SqlServerCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $SqlServerName,
        [Parameter(Mandatory = $true, ParameterSetName = "Standard")]
        [Parameter(Mandatory = $true, ParameterSetName = "MARSEnabled")]
        [Parameter(Mandatory = $true, ParameterSetName = "AADIntegrated")]
        [Parameter(Mandatory = $true, ParameterSetName = "AAD")]
        [ArgumentCompleter([DatabaseCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $DatabaseName,
        [Parameter(Mandatory = $true, ParameterSetName = "Standard")]
        [Parameter(Mandatory = $true, ParameterSetName = "MARSEnabled")]
        [Parameter(Mandatory = $true, ParameterSetName = "AAD", HelpMessage = "Provide the username of database")]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,
        [Parameter(Mandatory = $true, ParameterSetName = "AAD", HelpMessage = "Provide the domain name")]
        [ValidateNotNullOrEmpty()]
        [string] $Domain,
        [Parameter(Mandatory = $true, ParameterSetName = "Standard")]
        [Parameter(Mandatory = $true, ParameterSetName = "MARSEnabled")]
        [Parameter(Mandatory = $true, ParameterSetName = "AAD", HelpMessage = "Provide the database secure password")]
        [ValidateNotNullOrEmpty()]
        [securestring] $Password,
        [Parameter(Mandatory = $true, ParameterSetName = "MARSEnabled")]
        [switch] $MultipleActiveResultSets,
        [Parameter(Mandatory = $true, ParameterSetName = "AADIntegrated")]
        [Parameter(Mandatory = $true, ParameterSetName = "AAD")]
        [ValidateSet("Active Directory Integrated", "Active Directory Password")]
        [ValidateNotNullOrEmpty()]
        [string] $Authentication,
        [Parameter(Mandatory = $true, ParameterSetName = "Encrypted")]
        [ArgumentCompleter([SqlServerCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $DataSource,
        [Parameter(Mandatory = $true, ParameterSetName = "Encrypted")]
        [ValidateNotNullOrEmpty()]
        [string] $InitialCatalog,
        [Parameter(ParameterSetName = "Encrypted")]
        [ValidateNotNullOrEmpty()]
        [switch] $IntegratedSecurity,
        [Parameter(Mandatory = $false, ParameterSetName = "Encrypted")]
        [ValidateNotNullOrEmpty()]
        [string] $ColumnEncryptionSetting = "enabled"
    )
    process {
        try {
            [PSDBConnectionString] $ConnectionString = [PSDBConnectionString]::new()
            $CS = $null
            if ($PSCmdlet.ParameterSetName -eq "Standard") {
                $pswd = _convertToPlainText -Password $Password
                $CS = $ConnectionString.BuildConnectionString($SqlServerName, $DatabaseName, $UserName, $pswd)
            }
            elseif ($PSCmdlet.ParameterSetName -eq "MARSEnabled") {
                $pswd = _convertToPlainText -Password $Password
                $CS = $ConnectionString.BuildConnectionString($SqlServerName, $DatabaseName, $UserName, $pswd, $MultipleActiveResultSets.IsPresent)
            }
            elseif ($PSCmdlet.ParameterSetName -eq "AADIntegrated") {
                $CS = $ConnectionString.BuildConnectionString($SqlServerName, $DatabaseName, $Authentication)
            }
            elseif ($PSCmdlet.ParameterSetName -eq "AAD") {
                $pswd = _convertToPlainText -Password $Password
                $CS = $ConnectionString.BuildConnectionString($SqlServerName, $DatabaseName, $Authentication, $UserName, $pswd, $Domain)
            }
            elseif ($PSCmdlet.ParameterSetName -eq "Encrypted") {
                $CS = $ConnectionString.BuildConnectionString($DataSource, $InitialCatalog, $IntegratedSecurity, $ColumnEncryptionSetting)
            }
            return $CS
        }
        catch {
            throw "An error occurred: $($_.Exception.Message)"
        }
    }
}
function Set-PSDBDefault {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Low")]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ArgumentCompleter([SubscriptionCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $Subscription,
        [Parameter(Position = 1, ValueFromPipeline = $true)]
        [ArgumentCompleter([ResourceGroupCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $ResourceGroupName,
        [ArgumentCompleter([SqlServerCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName,
        [ArgumentCompleter([DatabaseCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $DatabaseName,
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Processs", "User", "Machine")]
        [string] $Level = "Process"
    )
    process {
        try {
            # setting the default subscription in current context.
            # It is expected that user should have logged into Azure already.
            # clearing the defaults. It returns old values if session is not restarted.
            _clearDefaults
            Write-Verbose "Setting default subscription"
            [System.Environment]::SetEnvironmentVariable("PSDB_SUBSCRIPTION", $Subscription, $Level)
            [PSDBResources]::Subscription = $env:PSDB_SUBSCRIPTION
            Set-AzContext -Subscription $Subscription > $null
            # setting default parameters helps to pick the mandatory parameters from current running process.
            if ($ResourceGroupName) {
                [System.Environment]::SetEnvironmentVariable("PSDB_RESOURCEGROUPNAME", $ResourceGroupName, $Level)
                $Global:PSDefaultParameterValues["*-PSDB*:ResourceGroupName"] = $ResourceGroupName
                [PSDBResources]::ResourceGroupName = $env:PSDB_RESOURCEGROUPNAME
            }
            if ($ServerName) {
                [System.Environment]::SetEnvironmentVariable("PSDB_SERVERNAME", $ServerName, $Level)
                $Global:PSDefaultParameterValues["*-PSDB*:ServerName"] = $ServerName
                [PSDBResources]::ServerName = $env:PSDB_SERVERNAME
            }
            if ($DatabaseName) {
                [System.Environment]::SetEnvironmentVariable("PSDB_DATABASENAME", $DatabaseName, $Level)
                $Global:PSDefaultParameterValues["*-PSDB*:DatabaseName"] = $DatabaseName
                [PSDBResources]::DatabaseName = $env:PSDB_DATABASENAME
            }
        }
        catch {
            throw "An error occurred: $($_.Exception.Message)"
        }
    }
}

