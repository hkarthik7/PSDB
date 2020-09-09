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