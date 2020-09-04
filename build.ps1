[CmdletBinding()]
param (
    [Parameter(Mandatory = $false, Position = 0)]
    [string] $ModuleName = (Get-ProjectName),

    [Parameter(Mandatory = $false, Position = 1)]
    [ValidateSet("Major", "Minor", "Patch", "Build")]
    [string] $Version = "Patch"
)

# declaring constants
$root = Split-Path $PSCommandPath
$contents = @()
$folders = @("Classes", "Private", "Public")


Task init {
    # module refresh
    if (Get-Module -Name $ModuleName) {
        Remove-Module -Name $ModuleName -Force
    }
}

Task build {  

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
}

Task updateManifest {
    # import and copy only public functions to manifest file.
    Import-Module "$root\$ModuleName\$ModuleName.psm1" -Force

    $functions = (Get-Command -Module $ModuleName).Name | Where-Object {$_ -like "*-*"}

    Step-ModuleVersion -Path (Get-PSModuleManifest) -By $Version

    Set-ModuleFunction -Name (Get-PSModuleManifest) -FunctionsToExport $functions
}

Task createMarkdownHelp {
    # generate markdown files.
    New-MarkdownHelp -Module $ModuleName -OutputFolder "$root\docs" -ErrorAction SilentlyContinue
}

Task updateMarkdownHelp {
    Update-MarkdownHelp -Path "$root\docs"
}

Task createExternalHelp {
    # generate help files.
    New-ExternalHelp -Path "$root\docs" -OutputPath "$root\$ModuleName\en-US" -Force
}

Task default -depends init,build