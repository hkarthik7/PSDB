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