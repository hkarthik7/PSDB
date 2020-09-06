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
        [Parameter(Mandatory = $true, ParameterSetName = "AAD", HelpMessage = "Provide the username with domain name")]
        [ValidateNotNullOrEmpty()]
        [pscredential] $Credential,
        
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
                $UserId = $Credential.GetNetworkCredential().UserName                
                $Password = $Credential.GetNetworkCredential().Password

                $CS = $ConnectionString.BuildConnectionString($SqlServerName, $DatabaseName, $UserId, $Password)
            }

            elseif ($PSCmdlet.ParameterSetName -eq "MARSEnabled") {
                $UserId = $Credential.GetNetworkCredential().UserName                
                $Password = $Credential.GetNetworkCredential().Password

                $CS = $ConnectionString.BuildConnectionString($SqlServerName, $DatabaseName, $UserId, $Password, $MultipleActiveResultSets.IsPresent)
            }

            elseif ($PSCmdlet.ParameterSetName -eq "AADIntegrated") {
                $CS = $ConnectionString.BuildConnectionString($SqlServerName, $DatabaseName, $Authentication)
            }

            elseif ($PSCmdlet.ParameterSetName -eq "AAD") {

                if ([string]::IsNullOrWhiteSpace($Credential.GetNetworkCredential().Domain)) {

                    $Message = "Provide the domain name with username in format 'domain\username' to form the connection string."
                    $ErrorId = "ObjectNotSpecified,PSDBConnectionString\New-PSDBConnectionString" 
                    Write-Error -Exception ArgumentException -Message $Message -Category NotSpecified -ErrorId $ErrorId

                } else {
                    $UserId = $Credential.GetNetworkCredential().UserName
                    $Domain = $Credential.GetNetworkCredential().Domain
                    $Password = $Credential.GetNetworkCredential().Password

                    $CS = $ConnectionString.BuildConnectionString($SqlServerName, $DatabaseName, $Authentication, $UserId, $Password, $Domain)
                }
            }

            elseif ($PSCmdlet.ParameterSetName -eq "Encrypted") {
                $CS = $ConnectionString.BuildConnectionString($DataSource, $InitialCatalog, $IntegratedSecurity, $ColumnEncryptionSetting)
            }

            return $CS
        }
        catch {
            throw "Error at line $($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)."
        }        
    }
}