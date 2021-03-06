using namespace System.Collections;
using namespace System.Management.Automation;
using namespace System.Collections.Generic;

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