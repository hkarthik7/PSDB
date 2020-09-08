# Install dependencies
$RequiredModules = @("psake", "Pester", "BuildHelpers", "PSScriptAnalyzer")
$RequiredModules | ForEach-Object {
    if (-not (Get-Module -ListAvailable $_)) {
        Install-Module -Name $_ -SkipPublisherCheck -Scope CurrentUser -Force -Repository PSGallery
    }
}

Invoke-psake .\build.ps1 Clean, Build, Analyze, Test