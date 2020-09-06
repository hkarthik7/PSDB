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