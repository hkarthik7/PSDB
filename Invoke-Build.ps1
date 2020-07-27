function Invoke-Build {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $ModuleName,

        [string]
        $ModuleVersion = "0.1.13",

        [switch]
        $UpdateManifest,

        [switch]
        $NewMarkdown,

        [switch]
        $UpdateMarkdown,

        [switch]
        $GenerateHelp
    )
    
    process {

         # module refresh
         if (Get-Module -Name $ModuleName) {
            Remove-Module -Name $ModuleName -Force
        }

        $root = Split-Path $PSCommandPath
        $contents = @()
        $folders = @("Classes", "Private", "Public")

        # move all the functions to module file and export only public functions.
        foreach ($folder in $folders) {
            if ($folder -eq "Classes") {
                $class = Get-Content (Get-ChildItem -Path "$root\$folder" -Filter "*.ps1").FullName
                $class | Set-Content "$root\$ModuleName\$ModuleName.classes.ps1"
            } else {
                $contents += Get-Content (Get-ChildItem -Path "$root\$folder" -Filter "*.ps1").FullName
            }
        }

        $contents | Set-Content "$root\$ModuleName\$ModuleName.functions.ps1"

        if ($UpdateManifest.IsPresent) {
            # import and copy only public functions to manifest file.
            Import-Module "$root\$ModuleName\$ModuleName.psm1" -Force

            $functions = (Get-Command -Module $ModuleName).Name | Where-Object {$_ -like "*-*"}

            $manifest = @{
                Path = "$root\$ModuleName\$ModuleName.psd1"
                Guid = (New-Guid)
                CompanyName = ""
                Author = "Harish Karthic"
                RootModule = "$ModuleName.psm1"
                ModuleVersion = $ModuleVersion
                Description = "PSDB is a PowerShell module which wrapps the operation of Azure Sql import and export and provides additional functionality to drive the import and export operation as you do in Azure portal."
                FunctionsToExport = @($functions)
                LicenseUri = 'https://github.com/hkarthik7/PSDB/blob/master/LICENSE'
                ProjectUri = 'https://github.com/hkarthik7/PSDB'
                ReleaseNotes = 'https://github.com/hkarthik7/PSDB/blob/master/CHANGELOG.md'
                Tags = @("PSDB", "AzureSqlImport", "AzureSqlExport", "PowerShellAzureSql", "SqlExport", "SqlAutomation", "DatabaseAutomation")
            }

            New-ModuleManifest @manifest
        }

        # forcing the import of final module
        Import-Module "$root\$ModuleName" -Force

        if ($NewMarkdown.IsPresent) {
            # generate markdown files.
            New-MarkdownHelp -Module $ModuleName -OutputFolder "$root\docs" -ErrorAction SilentlyContinue
        }

        if ($UpdateMarkdown.IsPresent) {
            Update-MarkdownHelp -Path "$root\docs"
        }

        if ($GenerateHelp.IsPresent) {
            # generate help files.
            New-ExternalHelp -Path "$root\docs" -OutputPath "$root\$ModuleName\en-US" -Force
        }
    }
}

Invoke-Build -ModuleName "PSDB"