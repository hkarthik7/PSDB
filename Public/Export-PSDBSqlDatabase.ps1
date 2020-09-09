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