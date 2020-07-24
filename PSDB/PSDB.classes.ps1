# This class helps for tab completing the resource group name. Note that I am not specifying "using namespace"
# as this is intentional because when I build the module it gets accumulated to a single file and I get error
# when running it. This is because the module is built with different completers name and namespaces are scattered
# in resultant file.
class KeyVaultCompleter : System.Management.Automation.IArgumentCompleter {
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $WordToComplete,
        [System.Management.Automation.Language.CommandAst] $CommandAst,
        [System.Collections.IDictionary] $FakeBoundParameters
    ) {
        $results = [System.Collections.Generic.List[System.Management.Automation.CompletionResult]]::new()

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
# This class helps for tab completing the resource group name. Note that I am not specifying "using namespace"
# as this is intentional.
class ResourceGroupCompleter : System.Management.Automation.IArgumentCompleter {
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $WordToComplete,
        [System.Management.Automation.Language.CommandAst] $CommandAst,
        [System.Collections.IDictionary] $FakeBoundParameters
    ) {
        $results = [System.Collections.Generic.List[System.Management.Automation.CompletionResult]]::new()

        foreach ($value in (_getResources -ResourceGroups)) {
            if ($value -like "*$WordToComplete*") {
                $results.Add($value)
            }
        }

        return $results
    }
}
# This class helps for tab completing the resource group name. Note that I am not specifying "using namespace"
# as this is intentional.
class SqlServerCompleter : System.Management.Automation.IArgumentCompleter {
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $WordToComplete,
        [System.Management.Automation.Language.CommandAst] $CommandAst,
        [System.Collections.IDictionary] $FakeBoundParameters
    ) {
        $results = [System.Collections.Generic.List[System.Management.Automation.CompletionResult]]::new()

        foreach ($value in (_getResources -SqlServers)) {
            if ($value -like "*$WordToComplete*") {
                $results.Add($value)
            }
        }

        return $results
    }
}
# This class allows the tab completion and it is expected that user should have
# logged into Azure.
class StorageAccountCompleter : System.Management.Automation.IArgumentCompleter {
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $WordToComplete,
        [System.Management.Automation.Language.CommandAst] $CommandAst,
        [System.Collections.IDictionary] $FakeBoundParameters
    ) {
        $results = [System.Collections.Generic.List[System.Management.Automation.CompletionResult]]::new()

        foreach ($value in (_getResources -StorageAccounts)) {
            if ($value -like "*$WordToComplete*") {
                $results.Add($value)
            }
        }
        
        return $results
    }
}
# This class allows the tab completion and it is expected that user should have
# logged into Azure.
class SubscriptionCompleter : System.Management.Automation.IArgumentCompleter {
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $WordToComplete,
        [System.Management.Automation.Language.CommandAst] $CommandAst,
        [System.Collections.IDictionary] $FakeBoundParameters
    ) {
        $results = [System.Collections.Generic.List[System.Management.Automation.CompletionResult]]::new()

        foreach ($value in _getDefaultSubscriptions) {
            if ($value -like "*$WordToComplete*") {
                $results.Add($value)
            }
        }
        
        return $results
    }
}
