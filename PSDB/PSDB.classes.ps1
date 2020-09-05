using namespace System.Text;
using namespace System.Collections;
using namespace System.Management.Automation;
using namespace System.Collections.Generic;
 # This class attribute helps to create connection string for connection Azure Sql database.
# More information on how to form or create a connection string can be found at
# https://www.connectionstrings.com/
class PSDBConnectionString
{
    static [int] $PortNumber = 1433
    static [bool] $TrustedConnection = $false
    static [bool] $Encrypt = $true
    static [bool] $MultipleActiveResultSets = $true
    static [bool] $IntegratedSecurity = $true
    static [string] $ColumnEncryptionSetting = "enabled"
    PSDBConnectionString() {}
    # constructs the standard connection string for Azure Sql
    [string] BuildConnectionString ([string] $Server, [string] $Database, [string] $UserID, [string] $Pswd)
    {
        [StringBuilder] $StringBuilder = [StringBuilder]::new()
        $StringBuilder.Append("Server=tcp:$($Server),$([PSDBConnectionString]::PortNumber);") > $null
        $StringBuilder.Append("Database=$($Database);") > $null
        $StringBuilder.Append("User ID=$($UserID)@$($Server);") > $null
        $StringBuilder.Append("Password=$($Pswd);") > $null
        $StringBuilder.Append("Trusted_Connection=$([PSDBConnectionString]::TrustedConnection);") > $null
        $StringBuilder.Append("Encrypt=$([PSDBConnectionString]::Encrypt);") > $null
        return $StringBuilder.ToString()
    }
    # with MARS Enabled
    [string] BuildConnectionString ([string] $Server, [string] $Database, [string] $UserID, [string] $Pswd, [bool] $MultipleActiveResultSets = $true)
    {
        [StringBuilder] $StringBuilder = [StringBuilder]::new()
        $StringBuilder.Append("Server=tcp:$($Server),$([PSDBConnectionString]::PortNumber);") > $null
        $StringBuilder.Append("Database=$($Database);") > $null
        $StringBuilder.Append("User ID=$($UserID)@$($Server);") > $null
        $StringBuilder.Append("Password=$($Pswd);") > $null
        $StringBuilder.Append("Trusted_Connection=$([PSDBConnectionString]::TrustedConnection);") > $null
        $StringBuilder.Append("Encrypt=$([PSDBConnectionString]::Encrypt);") > $null
        $StringBuilder.Append("MultipleActiveResultSets=$($MultipleActiveResultSets);") > $null
        return $StringBuilder.ToString()
    }
    # Integrated with Azure AD
    [string] BuildConnectionString ([string] $Server, [string] $Database, [string] $Authentication)
    {
        [StringBuilder] $StringBuilder = [StringBuilder]::new()
        $StringBuilder.Append("Server=tcp:$($Server),$([PSDBConnectionString]::PortNumber);") > $null
        $StringBuilder.Append("Authentication=$($Authentication);") > $null
        $StringBuilder.Append("Database=$($Database);") > $null
        return $StringBuilder.ToString()
    }
    # Integrated with Azure AD; with username and password
    [string] BuildConnectionString ([string] $Server, [string] $Database, [string] $Authentication, [string] $UserID, [string] $Pswd, [string] $Domain)
    {
        [StringBuilder] $StringBuilder = [StringBuilder]::new()
        $StringBuilder.Append("Server=tcp:$($Server),$([PSDBConnectionString]::PortNumber);") > $null
        $StringBuilder.Append("Authentication=$($Authentication);") > $null
        $StringBuilder.Append("Database=$($Database);") > $null
        $StringBuilder.Append("UID=$($UserID)@$($Domain);") > $null
        $StringBuilder.Append("Password=$($Pswd);") > $null
        return $StringBuilder.ToString()
    }
    # with always encrypted
    [string] BuildConnectionString ([string] $DataSource, [string] $InitialCatalog, [bool] $IntegratedSecurity = $true, [string] $ColumnEncryptionSetting = "enabled")
    {
        [StringBuilder] $StringBuilder = [StringBuilder]::new()
        $StringBuilder.Append("Data Source=$($DataSource);") > $null
        $StringBuilder.Append("Initial Catalog=$($InitialCatalog);") > $null
        $StringBuilder.Append("Integrated Security=$($IntegratedSecurity);") > $null
        $StringBuilder.Append("Column Encryption Setting=$($ColumnEncryptionSetting);") > $null
        return $StringBuilder.ToString()
    }
}
class KeyVaultCompleter : IArgumentCompleter {
    [IEnumerable[CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $WordToComplete,
        [Language.CommandAst] $CommandAst,
        [IDictionary] $FakeBoundParameters
    ) {
        $results = [List[CompletionResult]]::new()
        foreach ($value in (_getResources -KeyVaults)) {
            if ($value -like "*$WordToComplete*") {
                $results.Add($value)
            }
        }
        return $results
    }
}
class PSDBResources {
    static [string] $Subscription           = $null
    static [object] $Subscriptions          = $null
    static [object] $ResourceGroups         = $null
    static [object] $ResourceGroupName      = $null
    static [object] $SqlServers             = $null
    static [object] $ServerName             = $null
    static [object] $SqlDatabases           = $null
    static [object] $DatabaseName           = $null
    static [object] $StorageAccounts        = $null
    static [object] $KeyVaults              = $null
}
class PSDBValidator
{
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
class ResourceGroupCompleter : IArgumentCompleter {
    [IEnumerable[CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $WordToComplete,
        [Language.CommandAst] $CommandAst,
        [IDictionary] $FakeBoundParameters
    ) {
        $results = [List[CompletionResult]]::new()
        foreach ($value in (_getResources -ResourceGroups)) {
            if ($value -like "*$WordToComplete*") {
                $results.Add($value)
            }
        }
        return $results
    }
}
class SqlServerCompleter : IArgumentCompleter {
    [IEnumerable[CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $WordToComplete,
        [Language.CommandAst] $CommandAst,
        [IDictionary] $FakeBoundParameters
    ) {
        $results = [List[CompletionResult]]::new()
        foreach ($value in (_getResources -SqlServers)) {
            if ($value -like "*$WordToComplete*") {
                $results.Add($value)
            }
        }
        return $results
    }
}
class StorageAccountCompleter : IArgumentCompleter {
    [IEnumerable[CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $WordToComplete,
        [Language.CommandAst] $CommandAst,
        [IDictionary] $FakeBoundParameters
    ) {
        $results = [List[CompletionResult]]::new()
        foreach ($value in (_getResources -StorageAccounts)) {
            if ($value -like "*$WordToComplete*") {
                $results.Add($value)
            }
        }
        return $results
    }
}
class SubscriptionCompleter : IArgumentCompleter {
    [IEnumerable[CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $WordToComplete,
        [Language.CommandAst] $CommandAst,
        [IDictionary] $FakeBoundParameters
    ) {
        $results = [List[CompletionResult]]::new()
        foreach ($value in _getDefaultSubscriptions) {
            if ($value -like "*$WordToComplete*") {
                $results.Add($value)
            }
        }
        return $results
    }
}

