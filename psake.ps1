# Install dependencies
$RequiredModules = @("psake", "Pester", "BuildHelpers", "PSScriptAnalyzer", "platyPS")
$RequiredModules | ForEach-Object {
    if (-not (Get-Module -ListAvailable $_)) {
        Write-Output "Installing module $($_)"
        Install-Module -Name $_ -SkipPublisherCheck -Scope CurrentUser -Force -Repository PSGallery
    }
}

Invoke-psake .\build.ps1 Clean, Build, Analyze, Test