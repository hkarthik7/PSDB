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