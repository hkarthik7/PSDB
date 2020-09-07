using namespace System.Management.Automation;

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