function New-PSDBConnectionString {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding(DefaultParameterSetName = "AADIntegrated")]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Standard")]
        [Parameter(Mandatory = $true, ParameterSetName = "MARSEnabled")]
        [Parameter(Mandatory = $true, ParameterSetName = "AADIntegrated")]
        [Parameter(Mandatory = $true, ParameterSetName = "AAD")]
        [ArgumentCompleter([SqlServerCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $SqlServerName,

        [Parameter(Mandatory = $true, ParameterSetName = "Standard")]
        [Parameter(Mandatory = $true, ParameterSetName = "MARSEnabled")]
        [Parameter(Mandatory = $true, ParameterSetName = "AADIntegrated")]
        [Parameter(Mandatory = $true, ParameterSetName = "AAD")]
        [ArgumentCompleter([DatabaseCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $DatabaseName,

        [Parameter(Mandatory = $true, ParameterSetName = "Standard")]
        [Parameter(Mandatory = $true, ParameterSetName = "MARSEnabled")]
        [Parameter(Mandatory = $true, ParameterSetName = "AAD", HelpMessage = "Provide the username of database")]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [Parameter(Mandatory = $true, ParameterSetName = "AAD", HelpMessage = "Provide the domain name")]
        [ValidateNotNullOrEmpty()]
        [string] $Domain,

        [Parameter(Mandatory = $true, ParameterSetName = "Standard")]
        [Parameter(Mandatory = $true, ParameterSetName = "MARSEnabled")]
        [Parameter(Mandatory = $true, ParameterSetName = "AAD", HelpMessage = "Provide the database secure password")]
        [ValidateNotNullOrEmpty()]
        [securestring] $Password,
        
        [Parameter(Mandatory = $true, ParameterSetName = "MARSEnabled")]
        [switch] $MultipleActiveResultSets,

        [Parameter(Mandatory = $true, ParameterSetName = "AADIntegrated")]
        [Parameter(Mandatory = $true, ParameterSetName = "AAD")]
        [ValidateSet("Active Directory Integrated", "Active Directory Password")]
        [ValidateNotNullOrEmpty()]
        [string] $Authentication,

        [Parameter(Mandatory = $true, ParameterSetName = "Encrypted")]
        [ArgumentCompleter([SqlServerCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $DataSource,

        [Parameter(Mandatory = $true, ParameterSetName = "Encrypted")]
        [ValidateNotNullOrEmpty()]
        [string] $InitialCatalog,

        [Parameter(ParameterSetName = "Encrypted")]
        [ValidateNotNullOrEmpty()]
        [switch] $IntegratedSecurity,

        [Parameter(Mandatory = $false, ParameterSetName = "Encrypted")]
        [ValidateNotNullOrEmpty()]
        [string] $ColumnEncryptionSetting = "enabled"
    )
    
    process {
        try {
            [PSDBConnectionString] $ConnectionString = [PSDBConnectionString]::new()
            $CS = $null

            if ($PSCmdlet.ParameterSetName -eq "Standard") {             
                $pswd = _convertToPlainText -Password $Password
                $CS = $ConnectionString.BuildConnectionString($SqlServerName, $DatabaseName, $UserName, $pswd)
            }

            elseif ($PSCmdlet.ParameterSetName -eq "MARSEnabled") {
                $pswd = _convertToPlainText -Password $Password
                $CS = $ConnectionString.BuildConnectionString($SqlServerName, $DatabaseName, $UserName, $pswd, $MultipleActiveResultSets.IsPresent)
            }

            elseif ($PSCmdlet.ParameterSetName -eq "AADIntegrated") {
                $CS = $ConnectionString.BuildConnectionString($SqlServerName, $DatabaseName, $Authentication)
            }

            elseif ($PSCmdlet.ParameterSetName -eq "AAD") {
                $pswd = _convertToPlainText -Password $Password
                $CS = $ConnectionString.BuildConnectionString($SqlServerName, $DatabaseName, $Authentication, $UserName, $pswd, $Domain)
            }

            elseif ($PSCmdlet.ParameterSetName -eq "Encrypted") {
                $CS = $ConnectionString.BuildConnectionString($DataSource, $InitialCatalog, $IntegratedSecurity, $ColumnEncryptionSetting)
            }

            return $CS
        }
        catch {
            throw "An error occurred: $($_.Exception.Message)"
        }        
    }
}