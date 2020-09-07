using namespace System.Management.Automation;

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