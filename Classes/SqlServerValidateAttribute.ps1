using namespace System.Management.Automation;

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

      $servers = $SqlServers

      if ($arguments -notin $servers) {
        throw [ValidationMetadataException]::new(
            "'$arguments' is not a valid Sql server. Pass the valid Sql server name and try again.")
      }
    }
}