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
    return $env:PSDB_SUBSCRIPTIONS.Split(",")
}

# Using this function only for tab completers.
function _getResources {
    param (
        [switch] $ResourceGroups,
        [switch] $SqlServers,
        [switch] $StorageAccounts,
        [switch] $KeyVaults
    )

    if ($ResourceGroups) {
        $rsgs = $env:PSDB_RESOURCEGROUPS -split ","
        if (-not $rsgs) {
            $resources = Get-AzResource
            $resourceGroupNames = $resources.ResourceGroupName | Select-Object -Unique

            _setDefaultResource -ResourceName "ResourceGroups" -Resources $resourceGroupNames
            [PSDBResources]::ResourceGroups = $env:PSDB_RESOURCEGROUPS.Split(",")

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
            [PSDBResources]::SqlServers = $env:PSDB_SQLSERVERS.Split(",")

            return [PSDBResources]::SqlServers
        } else {
            return $sql
        }
    }

    if ($StorageAccounts) {
        $storage = $env:PSDB_STORAGEACCOUNTS -split ","
        if (-not $storage) {
            $resources = Get-AzResource
            $accounts = $resources | Where-Object {$_.ResourceId -like "*Microsoft.Storage*"} | Select-Object Name

            _setDefaultResource -ResourceName "StorageAccounts" -Resources $accounts.Name
            [PSDBResources]::StorageAccounts = $env:PSDB_STORAGEACCOUNTS.Split(",")

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
            [PSDBResources]::KeyVaults = $env:PSDB_KEYVAULTS.Split(",")

            return [PSDBResources]::KeyVaults
        } else {
            return $kvs
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
    $env:PSDB_STORAGEACCOUNTS = $null
    $env:PSDB_KEYVAULTS = $null
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
function Export-PSDBSqlDatabase {
    [CmdletBinding()]
    [Alias("Export")]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ArgumentCompleter([ResourceGroupCompleter])]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceGroupName,

        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DatabaseName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ArgumentCompleter([SqlServerCompleter])]
        [ValidateNotNullOrEmpty()]
        [string]$ServerName,

        [string]$StorageKeyType = "StorageAccessKey",

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ArgumentCompleter([StorageAccountCompleter])]
        [ValidateNotNullOrEmpty()]
        [string]$StorageAccountName,

        [Parameter(Mandatory = $true, HelpMessage = "Provide Container Name to save the exported database .bacpac file.", ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$StorageContainerName,

        [Parameter(HelpMessage = "Provide the name of blob that you want to save as.")]
        [string] $BlobName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $AdministratorLogin,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [securestring] $AdministratorLoginPassword,

        [Parameter(Mandatory = $false, HelpMessage = "Provide the subscription name if exported .bacpac file have to be saved in different subscription.")]
        [ArgumentCompleter([SubscriptionCompleter])]
        [string] $Subscription
    )

    process {

        try {

            #region start DB export

            if ($PSBoundParameters["Subscription"]) {
                $context = (Get-AzContext).Subscription.Name

                if ($context -ne $Subscription) {
                    
                    Set-PSDBDefault -Subscription $Subscription

                    $storageKey = _getStorageAccountKey -StorageAccountName $StorageAccountName
                    $storageUri = _getStorageUri -StorageAccountName $StorageAccountName -StorageContainerName $StorageContainerName

                    Set-PSDBDefault -Subscription $context
                } else {
                    $storageKey = _getStorageAccountKey -StorageAccountName $StorageAccountName
                    $storageUri = _getStorageUri -StorageAccountName $StorageAccountName -StorageContainerName $StorageContainerName
                }

            } else {
                $storageKey = _getStorageAccountKey -StorageAccountName $StorageAccountName
                $storageUri = _getStorageUri -StorageAccountName $StorageAccountName -StorageContainerName $StorageContainerName
            }

            if (-not $BlobName) {
                $BlobName = _getBacpacName -DatabaseName $DatabaseName
            }

            $splat = @{
                DatabaseName = $DatabaseName
                ServerName = $ServerName
                StorageKeyType = $StorageKeyType
                StorageKey = $storageKey
                StorageUri = "$storageUri/$BlobName"
                ResourceGroupName = $ResourceGroupName
                AdministratorLogin = $AdministratorLogin
                AdministratorLoginPassword = $AdministratorLoginPassword
            }

            $sqlExport = New-AzSqlDatabaseExport @splat

            return $sqlExport.OperationStatusLink

            #end region start DB export
        }
        catch {
            throw "Error at line $($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)."
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
        [string] $ConnectionString,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
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
            throw "Error at line $($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)."
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
        [string] $StatusLink,

        [int] $Interval = 5,

        [int] $TimeOut = 300,

        [switch] $Wait
    )

    process {
        try {
            $Status = Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $StatusLink

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
            throw "Error at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
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

            if ($PSBoundParameters["Version"]) {

                $kvSecret = Get-AzKeyVaultSecret -VaultName $VaultName -Name $SecretName -Version $Version

                if ($AsPlainText.IsPresent) {
                    if ($kvSecret.Enabled) {
                        return $kvSecret.SecretValueText
                    } else {
                        Write-Error "Given secret $($SecretName) is not enabled.."
                    }
                } else {
                    return $kvSecret.SecretValue
                }

            } 
            
            else {
                $kvSecrets = Get-AzKeyVaultSecret -VaultName $VaultName -Name $SecretName -IncludeVersions
                $secrets = @()

                if ($AsPlainText.IsPresent) {
                    $kvSecrets | ForEach-Object {
                        if ($PSItem.Enabled) {
                            $secrets += Get-AzKeyVaultSecret -VaultName $VaultName -Name $SecretName -Version $PSItem.Version
                        }
                    }

                    return $secrets.SecretValueText

                } else {
                    $kvSecrets | ForEach-Object {
                        if ($PSItem.Enabled) {
                            $secrets += Get-AzKeyVaultSecret -VaultName $VaultName -Name $SecretName -Version $PSItem.Version
                        }
                    }

                    return $secrets.SecretValue
                }
            }
        }
        catch {
            throw "Error at line $($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)."
        }
    }
}
function Import-PSDBSqlDatabase {
    [CmdletBinding()]
    [Alias("Import")]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ArgumentCompleter([ResourceGroupCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $ResourceGroupName,

        [Parameter(HelpMessage = "Provide the name of database to import as. If not provided by default it will take the name of .bacpac file.")]
        [ValidateNotNullOrEmpty()]
        [string] $ImportDatabaseAs,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ArgumentCompleter([SqlServerCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName,

        [string] $StorageKeyType = "StorageAccessKey",

        [string] $Edition,

        [string] $ServiceObjectiveName,

        [string] $DatabaseMaxSizeBytes,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ArgumentCompleter([StorageAccountCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $StorageAccountName,

        [Parameter(Mandatory = $true, HelpMessage = "Provide Container Name to import database .bacpac file from.", ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $StorageContainerName,

        [Parameter(HelpMessage = "Provide the name of .bacpac file. If not provided it tries to retrieve latest '.bacpac' file from provided container.")]
        [string] $BacpacName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $AdministratorLogin,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [securestring] $AdministratorLoginPassword,

        [Parameter(Mandatory = $false, HelpMessage = "Provide the subscription name to import .bacpac file from.")]
        [ArgumentCompleter([SubscriptionCompleter])]
        [string] $Subscription
    )
    
    process {
        try {

            #region start DB import

            if ($PSBoundParameters["Subscription"]) {
                $context = (Get-AzContext).Subscription.Name

                if ($context -ne $Subscription) {
                    
                    Set-PSDBDefault -Subscription $Subscription

                    $storageKey = _getStorageAccountKey -StorageAccountName $StorageAccountName
                    $storageUri = _getStorageUri -StorageAccountName $StorageAccountName -StorageContainerName $StorageContainerName

                    # Placing this check here because when I'm retrieving the information for different subscription it has to
                    # fetch the correct latest bacpac file. If this is out of this check then the context will be different and
                    # I'm receiving error.
                    if (-not $BacpacName) {
                        $BacpacName = _getLatestBacPacFile -StorageAccountName $StorageAccountName -StorageContainerName $StorageContainerName
                    }

                    Set-PSDBDefault -Subscription $context

                } else {
                    $storageKey = _getStorageAccountKey -StorageAccountName $StorageAccountName
                    $storageUri = _getStorageUri -StorageAccountName $StorageAccountName -StorageContainerName $StorageContainerName

                    if (-not $BacpacName) {
                        $BacpacName = _getLatestBacPacFile -StorageAccountName $StorageAccountName -StorageContainerName $StorageContainerName
                    }
                }

            } else {
                $storageKey = _getStorageAccountKey -StorageAccountName $StorageAccountName
                $storageUri = _getStorageUri -StorageAccountName $StorageAccountName -StorageContainerName $StorageContainerName

                if (-not $BacpacName) {
                    $BacpacName = _getLatestBacPacFile -StorageAccountName $StorageAccountName -StorageContainerName $StorageContainerName
                }
            }

            if (-not $Edition) {
                $Edition = "Standard"
            }

            if (-not $DatabaseMaxSizeBytes) {
                $DatabaseMaxSizeBytes = "5000000"
            }

            if (-not $ServiceObjectiveName) {
                $ServiceObjectiveName = "S0"
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
            }

            $sqlImport = New-AzSqlDatabaseImport @splat

            return $sqlImport.OperationStatusLink
        }
        catch {
            throw "Error at line $($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)."
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
        [string] $ConnectionString,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
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
            throw "Error at line $($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)."
        }
        finally {
            # cleaning up
            $connection.Close()
        }
    }
}
function New-PSDBConnectionString {
    [CmdletBinding()]
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
        [ValidateNotNullOrEmpty()]
        [string] $DatabaseName,

        [Parameter(Mandatory = $true, ParameterSetName = "Standard")]
        [Parameter(Mandatory = $true, ParameterSetName = "MARSEnabled")]
        [Parameter(Mandatory = $true, ParameterSetName = "AAD", HelpMessage = "Provide the username with domain name")]
        [ValidateNotNullOrEmpty()]
        [pscredential] $Credential,
        
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
                $UserId = $Credential.GetNetworkCredential().UserName                
                $Password = $Credential.GetNetworkCredential().Password

                $CS = $ConnectionString.BuildConnectionString($SqlServerName, $DatabaseName, $UserId, $Password)
            }

            elseif ($PSCmdlet.ParameterSetName -eq "MARSEnabled") {
                $UserId = $Credential.GetNetworkCredential().UserName                
                $Password = $Credential.GetNetworkCredential().Password

                $CS = $ConnectionString.BuildConnectionString($SqlServerName, $DatabaseName, $UserId, $Password, $MultipleActiveResultSets.IsPresent)
            }

            elseif ($PSCmdlet.ParameterSetName -eq "AADIntegrated") {
                $CS = $ConnectionString.BuildConnectionString($SqlServerName, $DatabaseName, $Authentication)
            }

            elseif ($PSCmdlet.ParameterSetName -eq "AAD") {

                if ([string]::IsNullOrWhiteSpace($Credential.GetNetworkCredential().Domain)) {

                    $Message = "Provide the domain name with username in format 'domain\username' to form the connection string."
                    $ErrorId = "ObjectNotSpecified,PSDBConnectionString\New-PSDBConnectionString" 
                    Write-Error -Exception ArgumentException -Message $Message -Category NotSpecified -ErrorId $ErrorId

                } else {
                    $UserId = $Credential.UserName
                    $Password = $Credential.GetNetworkCredential().Password

                    $CS = $ConnectionString.BuildConnectionString($SqlServerName, $DatabaseName, $Authentication, $UserId, $Password)
                }
            }

            elseif ($PSCmdlet.ParameterSetName -eq "Encrypted") {
                $CS = $ConnectionString.BuildConnectionString($DataSource, $InitialCatalog, $IntegratedSecurity, $ColumnEncryptionSetting)
            }

            return $CS
        }
        catch {
            throw "Error at line $($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)."
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

        [ValidateNotNullOrEmpty()]
        [string] $DatabaseName
    )

    DynamicParam {
        $dp = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        $ParameterName = 'Level'

        # Create the collection of attributes
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

        # Create and set the parameters' attributes
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $false
        $ParameterAttribute.HelpMessage = "Set the default parameters to work with the module on ease."

        $arrSet = "Process", "User", "Machine"
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

        # Add the ValidateSet to the attributes collection
        $AttributeCollection.Add($ValidateSetAttribute)

        # Add the attributes to the attributes collection
        $AttributeCollection.Add($ParameterAttribute)
        
        # Create and return the dynamic parameter
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $dp.Add($ParameterName, $RuntimeParameter)

        return $dp
    }

    begin {
        $Level = $PSBoundParameters[$ParameterName]
    }
    
    process {
        # setting the default subscription user gives and retrieving all the subscriptions in
        # current context. This will be then used for tab completions.
        # It is expected that user should have logged into Azure already.
        if (-not $Level) {
            $Level = "Process"
        }

        if ($PSCmdlet.ShouldProcess($Subscription, "Set-PSDBDefault")) {

            # clearing the defaults. It returns old values if session is not restarted.
            _clearDefaults

            if ($null -eq $env:PSDB_SUBSCRIPTIONS) {
                $Subscriptions = (Get-AzContext -ListAvailable -WarningAction SilentlyContinue).Subscription.Name -join ","
            } else {
                $Subscriptions = $env:PSDB_SUBSCRIPTIONS
            }

            if (-not $Subscriptions) {
                throw [System.Exception]::new("Please login to Azure using 'Connect-AzAccount' cmdlet to continue..")
            } 
        
            else {
                [System.Environment]::SetEnvironmentVariable("PSDB_SUBSCRIPTION", $Subscription, $Level)
                [System.Environment]::SetEnvironmentVariable("PSDB_SUBSCRIPTIONS", $Subscriptions, $Level)

                [PSDBResources]::Subscription = $env:PSDB_SUBSCRIPTION
                [PSDBResources]::Subscriptions = $env:PSDB_SUBSCRIPTIONS

                if ((Get-AzContext).Subscription.Name -ne $Subscription) {
                    Write-Verbose "Setting given subscription as default.."
                    Set-AzContext -Subscription $Subscription > $null
                }                
            }
        }

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
}
