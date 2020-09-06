class PSDBValidator
{
    PSDBValidator() { }
    
    [bool] SubscriptionValidator([string] $Subscription)
    {
        [bool] $isPresent = $false

        $SubscriptionIds = (Get-AzSubscription -WarningAction SilentlyContinue).Id

        if (((_getDefaultSubscriptions) -contains $Subscription) -or ($SubscriptionIds -contains $Subscription)) {
            $isPresent = $true
        }

        return $isPresent
    }

    [bool] ResourceGroupValidator([string] $ResourceGroupName)
    {
        [bool] $isPresent = $false

        $ResourceGroups = _getResources -ResourceGroups

        if ($ResourceGroups -contains $ResourceGroupName) {
            $isPresent = $true
        }

        return $isPresent
    }

    [bool] StorageAccountValidator([string] $StorageAccountName)
    {
        [bool] $isPresent = $false

        $StorageAccounts = _getResources -StorageAccounts

        if ($StorageAccounts -contains $StorageAccountName) {
            $isPresent = $true
        }

        return $isPresent
    }

    [bool] StorageContainerValidator([string] $StorageAccountName, [string] $StorageAccountContainer)
    {
        [bool] $isPresent = $false

        $Context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey (_getStorageAccountKey $StorageAccountName)
        $Container = Get-AzStorageContainer -Name $StorageAccountContainer -Context $Context

        if (![string]::IsNullOrWhiteSpace($Container.Name)) {
            $isPresent = $true
        }

        return $isPresent
    }

    [bool] SqlServerValidator([string] $SqlServerName)
    {
        [bool] $isPresent = $false

        $SqlServers = _getResources -SqlServers

        if ($SqlServers -contains $SqlServerName) {
            $isPresent = $true
        }

        return $isPresent
    }

    [bool] DatabaseValidator([string] $DatabaseName, [string] $SqlServerName, [string] $ResourceGroupName)
    {
        [bool] $isPresent = $false

        $DB = Get-AzSqlDatabase -ResourceGroupName $ResourceGroupName -DatabaseName $DatabaseName -ServerName $SqlServerName

        if (![string]::IsNullOrWhiteSpace($DB.DatabaseName)) {
            $isPresent = $true
        }

        return $isPresent
    }

    [bool] KeyVaultValidator([string] $VaultName)
    {
        [bool] $isPresent = $false

        $Vaults = _getResources -KeyVaults

        if ($Vaults -contains $VaultName) {
            $isPresent = $true
        }

        return $isPresent
    }

    [bool] KeyVaultSecretValidator([string] $VaultName, [string] $SecretName)
    {
        [bool] $isPresent = $false

        $Secret = Get-AzKeyVaultSecret -VaultName $VaultName -Name $SecretName -

        if (![string]::IsNullOrWhiteSpace($Secret.Name)) {
            $isPresent = $true
        }

        return $isPresent
    }
}

