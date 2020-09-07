using namespace System.Management.Automation;

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