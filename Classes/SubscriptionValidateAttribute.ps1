using namespace System.Management.Automation;

class SubscriptionValidateAttribute : ValidateArgumentsAttribute {
    [void] Validate(
      [object] $arguments,
      [EngineIntrinsics] $EngineIntrinsics) {

      # Do not fail on null or empty, leave that to other validation conditions
      if ([string]::IsNullOrEmpty($arguments)) { 
        return 
      }

      if ([string]::IsNullOrEmpty([PSDBResources]::Subscriptions)) {
        $subscriptions = (Get-AzSubscription -WarningAction SilentlyContinue).Name
      } else {
        $subscriptions = ([PSDBResources]::ResourceGroups).Split(",")
      }

      $SubscriptionsIds = (Get-AzSubscription -WarningAction SilentlyContinue).Id
      $Names = $subscriptions

      if (($arguments -notin $Names) -and ($arguments -notin $SubscriptionsIds)) {
        throw [ValidationMetadataException]::new(
            "'$arguments' is not a valid subscription name or id. Valid subscriptions are: '" +
            ($subscriptions -join "', '") + "'")
      }
    }
}