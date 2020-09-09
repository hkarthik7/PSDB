# dot sourcing all the files.
. "$PSScriptRoot\PSDB.classes.ps1"
. "$PSScriptRoot\PSDB.functions.ps1"

# Supress the warning message for KeyVault
if (-not ($env:SuppressAzurePowerShellBreakingChangeWarnings)) {
    $env:SuppressAzurePowerShellBreakingChangeWarnings = $true
}

# Set default subscriptions in the session
if ([string]::IsNullOrWhiteSpace($env:PSDB_SUBSCRIPTIONS)) {
    $Subscriptions = (Get-AzContext -ListAvailable -WarningAction SilentlyContinue).Subscription.Name -join ","
    [System.Environment]::SetEnvironmentVariable("PSDB_SUBSCRIPTIONS", $Subscriptions, "Process")
    [PSDBResources]::Subscriptions = $env:PSDB_SUBSCRIPTIONS
}