using namespace System.Management.Automation;

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