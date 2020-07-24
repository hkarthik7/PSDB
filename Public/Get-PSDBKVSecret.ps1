# This function helps to retrieve the secrets from key vault and returns as secure string.
# This then can be used with sql import and export operation.
function Get-PSDBKVSecret {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ArgumentCompleter([KeyVaultCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $VaultName,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $SecretName,

        [switch] $AsPlainText,

        [ValidateNotNullOrEmpty()]
        [string] $Version
    )
    
    process {
        try {

            if ($PSBoundParameters["Version"]) {

                $kvSecret = Get-AzKeyVaultSecret -VaultName $VaultName -Name $SecretName -Version $Version

                if ($AsPlainText.IsPresent) {
                    if ($kvSecret.Enabled) {
                        return $kvSecret.SecretValueText
                    } else {
                        Write-Error "Given secret $($SecretName) is not enabled.."
                    }
                } else {
                    return $kvSecret.SecretValue
                }

            } 
            
            else {
                $kvSecrets = Get-AzKeyVaultSecret -VaultName $VaultName -Name $SecretName -IncludeVersions
                $secrets = @()

                if ($AsPlainText.IsPresent) {
                    $kvSecrets | ForEach-Object {
                        if ($PSItem.Enabled) {
                            $secrets += Get-AzKeyVaultSecret -VaultName $VaultName -Name $SecretName -Version $PSItem.Version
                        }
                    }

                    return $secrets.SecretValueText

                } else {
                    $kvSecrets | ForEach-Object {
                        if ($PSItem.Enabled) {
                            $secrets += Get-AzKeyVaultSecret -VaultName $VaultName -Name $SecretName -Version $PSItem.Version
                        }
                    }

                    return $secrets.SecretValue
                }
            }
        }
        catch {
            throw "Error at line $($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)."
        }
    }
}