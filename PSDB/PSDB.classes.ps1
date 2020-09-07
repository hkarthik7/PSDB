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
class DatabaseCompleter : IArgumentCompleter {
    [IEnumerable[CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $WordToComplete,
        [Language.CommandAst] $CommandAst,
        [IDictionary] $FakeBoundParameters
    ) {
        $results = [List[CompletionResult]]::new()
        foreach ($value in (_getResources -SqlDatabases)) {
            if ($value -like "*$WordToComplete*") {
                $results.Add($value)
            }
        }
        return $results
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
class KeyVaultValidateAttribute : ValidateArgumentsAttribute {
    [void] Validate(
      [object] $arguments,
      [EngineIntrinsics] $EngineIntrinsics) {
      # Do not fail on null or empty, leave that to other validation conditions
      if ([string]::IsNullOrEmpty($arguments)) {
        return
      }
      if ([string]::IsNullOrEmpty([PSDBResources]::KeyVaults)) {
        $KeyVaults = _getResources -KeyVaults
      } else {
        $KeyVaults = ([PSDBResources]::KeyVaults).Split(",")
      }
      if ($arguments -notin $KeyVaults) {
        throw [ValidationMetadataException]::new(
            "'$arguments' is not a valid key vault. Pass the valid key vault name and try again.")
      }
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
class ResourceGroupValidateAttribute : ValidateArgumentsAttribute {
    [void] Validate(
      [object] $arguments,
      [EngineIntrinsics] $EngineIntrinsics) {
      # Do not fail on null or empty, leave that to other validation conditions
      if ([string]::IsNullOrEmpty($arguments)) {
        return
      }
      if ([string]::IsNullOrEmpty([PSDBResources]::ResourceGroups)) {
        $ResourceGroups = _getResources -ResourceGroups
      } else {
        $ResourceGroups = ([PSDBResources]::ResourceGroups).Split(",")
      }
      if ($arguments -notin $ResourceGroups) {
        throw [ValidationMetadataException]::new(
            "'$arguments' is not a valid resource group. Pass the valid resource group and try again.")
      }
    }
}
class SqlDatabaseValidateAttribute : ValidateArgumentsAttribute {
    [void] Validate(
      [object] $arguments,
      [EngineIntrinsics] $EngineIntrinsics) {
      # Do not fail on null or empty, leave that to other validation conditions
      if ([string]::IsNullOrEmpty($arguments)) {
        return
      }
      if ([string]::IsNullOrEmpty([PSDBResources]::SqlDatabases)) {
        $SqlDatabases = _getResources -SqlDatabases
      } else {
        $SqlDatabases = ([PSDBResources]::SqlDatabases).Split(",")
      }
      if ($arguments -notin $SqlDatabases) {
        throw [ValidationMetadataException]::new(
            "'$arguments' is not a valid Sql database. Pass the valid Sql database name and try again.")
      }
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
class SqlServerValidateAttribute : ValidateArgumentsAttribute {
    [void] Validate(
      [object] $arguments,
      [EngineIntrinsics] $EngineIntrinsics) {
      # Do not fail on null or empty, leave that to other validation conditions
      if ([string]::IsNullOrEmpty($arguments)) {
        return
      }
      if ([string]::IsNullOrEmpty([PSDBResources]::SqlServers)) {
        $SqlServers = _getResources -SqlServers
      } else {
        $SqlServers = ([PSDBResources]::SqlServers).Split(",")
      }
      if ($arguments -notin $SqlServers) {
        throw [ValidationMetadataException]::new(
            "'$arguments' is not a valid Sql server. Pass the valid Sql server name and try again.")
      }
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
class StorageAcountValidateAttribute : ValidateArgumentsAttribute {
    [void] Validate(
      [object] $arguments,
      [EngineIntrinsics] $EngineIntrinsics) {
      # Do not fail on null or empty, leave that to other validation conditions
      if ([string]::IsNullOrEmpty($arguments)) {
        return
      }
      if ([string]::IsNullOrEmpty([PSDBResources]::StorageAccounts)) {
        $StorageAccounts = _getResources -StorageAccounts
      } else {
        $StorageAccounts = ([PSDBResources]::StorageAccounts).Split(",")
      }
      if ($arguments -notin $StorageAccounts) {
        throw [ValidationMetadataException]::new(
            "'$arguments' is not a valid storage account. Pass the valid storage account name and try again.")
      }
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
class SubscriptionValidateAttribute : ValidateArgumentsAttribute {
    [void] Validate(
      [object] $arguments,
      [EngineIntrinsics] $EngineIntrinsics) {
      # Do not fail on null or empty, leave that to other validation conditions
      if ([string]::IsNullOrEmpty($arguments)) {
        return
      }
      if ([string]::IsNullOrEmpty([PSDBResources]::Subscriptions)) {
        $subscriptions = (Get-AzSubscription -WarningAction SilentlyContinue).Name
      } else {
        $subscriptions = ([PSDBResources]::ResourceGroups).Split(",")
      }
      $SubscriptionsIds = (Get-AzSubscription -WarningAction SilentlyContinue).Id
      $Names = $subscriptions
      if (($arguments -notin $Names) -and ($arguments -notin $SubscriptionsIds)) {
        throw [ValidationMetadataException]::new(
            "'$arguments' is not a valid subscription name or id. Valid subscriptions are: '" +
            ($subscriptions -join "', '") + "'")
      }
    }
}

