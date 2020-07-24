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