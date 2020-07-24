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
                    
                    Set-PSDBDefaults -Subscription $Subscription

                    $storageKey = _getStorageAccountKey -StorageAccountName $StorageAccountName
                    $storageUri = _getStorageUri -StorageAccountName $StorageAccountName -StorageContainerName $StorageContainerName

                    # Placing this check here because when I'm retrieving the information for different subscription it has to
                    # fetch the correct latest bacpac file. If this is out of this check then the context will be different and
                    # I'm receiving error.
                    if (-not $BacpacName) {
                        $BacpacName = _getLatestBacPacFile -StorageAccountName $StorageAccountName -StorageContainerName $StorageContainerName
                    }

                    Set-PSDBDefaults -Subscription $context

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
                $ImportDatabaseAs = $BacpacName
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
            
            Write-Output "Sql Import is : $($sqlImport.Status)"
        }
        catch {
            throw "Error at line $($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)."
        }
    }
}

