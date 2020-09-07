# dot sourcing all the files.
. "$PSScriptRoot\PSDB.classes.ps1"
. "$PSScriptRoot\PSDB.functions.ps1"

#Supress the warning message for Key vault
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"