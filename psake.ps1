# Install dependencies
# Az cmdlets wouldn't work in pipeline which fails the tests.
# This has also be dealt by checking for the module.
$RequiredModules = @("psake", "Pester", "BuildHelpers", "PSScriptAnalyzer", "platyPS", "Az.Accounts", "Az.Sql", "Az.Resources", "Az.Storage", "Az.KeyVault")
$RequiredModules | ForEach-Object {
    if (-not (Get-Module -ListAvailable $_)) {
        Write-Output "Installing module $($_)"
        Install-Module -Name $_ -SkipPublisherCheck -Scope CurrentUser -Force -Repository PSGallery -AllowClobber
    }
}

Invoke-psake .\build.ps1 Clean, Build, Analyze, Test