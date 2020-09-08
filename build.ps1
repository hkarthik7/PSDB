# Clean, build, analyze, test and publish test results. (CI)
# Publish module (CD)

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false, Position = 0)]
    [string] $ModuleName = (Get-ProjectName),

    [Parameter(Mandatory = $false, Position = 1)]
    [ValidateSet("Major", "Minor", "Patch", "Build")]
    [string] $Version = "Patch"
)

$root = Split-Path $PSCommandPath

Task Clean {
    #region module refresh
    if (Get-Module $ModuleName) {
        Remove-Module $ModuleName
    }
    #endregion module refresh
}

Task Build {
    # import the merge function
    . .\Merge-Files.ps1

    # move all the functions to module file.
    Merge-Files -InputDirectory .\Classes -OutputDirectory .\PSDB\PSDB.classes.ps1 -Classes
    Merge-Files -InputDirectory .\Private\, .\Public\ -OutputDirectory .\PSDB\PSDB.functions.ps1 -Functions
}

Task UpdateManifest {
    # import and copy only public functions to manifest file.
    Import-Module "$root\$ModuleName\$ModuleName.psm1" -Force
    $functions = (Get-Command -Module $ModuleName).Name | Where-Object {$_ -like "*-*"}

    # Bump the version of the module
    Step-ModuleVersion -Path (Get-PSModuleManifest) -By $Version
    Set-ModuleFunction -Name (Get-PSModuleManifest) -FunctionsToExport $functions
}

Task Analyze {
    # run PSScriptAnalyzer
    Write-Output "Running Static code analyzer"
    Invoke-ScriptAnalyzer -Path .\PSDB -Recurse -ReportSummary
}

Task Test {
    Write-Output "Running Pester tests"
    Invoke-Pester .\Tests -OutputFormat NUnitXml -OutputFile ".\Tests\results\test-results.xml" -Show All -WarningAction SilentlyContinue
}

Task createMarkdownHelp {
    Write-Output "Generating Markdown help files"
    # generate markdown files.
    # module has to be loaded into the session before creating help files.
    Import-Module .\PSDB -Force
    New-MarkdownHelp -Module $ModuleName -OutputFolder "$root\docs" -ErrorAction SilentlyContinue | Out-Null
}

Task updateMarkdownHelp {
    Write-Output "Updating Markdown help files"
    Import-Module .\PSDB -Force
    Update-MarkdownHelp -Path "$root\docs" | Out-Null
}

Task createExternalHelp {
    Write-Output "Generating External help files"
    # generate help files.
    Import-Module .\PSDB -Force
    New-ExternalHelp -Path "$root\docs" -OutputPath "$root\$ModuleName\en-US" -Force | Out-Null
}
