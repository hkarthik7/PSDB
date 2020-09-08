# Install dependencies
# Get-AzResource wouldn't work in pipeline which fails the tests.
# This has also be dealt by checking for the module.

$AzModules = (Import-PowerShellDataFile -Path .\PSDB\PSDB.psd1)["RequiredModules"]
$RequiredModules = @("psake", "Pester", "BuildHelpers", "PSScriptAnalyzer", "platyPS", $AzModules)
$RequiredModules | ForEach-Object {
    if (-not (Get-Module -ListAvailable $_)) {
        Write-Output "Installing module $($_)"
        Install-Module -Name $_ -SkipPublisherCheck -Scope CurrentUser -Force -Repository PSGallery
    }
}

Invoke-psake .\build.ps1 Clean, Build, Analyze, Test