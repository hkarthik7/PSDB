# This function helps to retrieve the secrets from key vault and returns as secure string.
# This then can be used with sql import and export operation.
function Get-PSDBKVSecret {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [KeyVaultValidateAttribute()]
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

            $kvSecret = Get-AzKeyVaultSecret -VaultName $VaultName -Name $SecretName -IncludeVersions -ErrorAction stop

            if ($null -eq $kvSecret) {
                $Message = "Cannot validate argument on parameter 'SecretName'. '$($SecretName)' is not a valid SecretName. Pass the valid secret name and try again."
                $ErrorId = "InvalidArgument,PSDBKVSecret\Get-PSDBKVSecret" 
                Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
            }

            else {
                if ($PSBoundParameters["Version"]) {
                    $secret = $kvSecret | Where-Object { $_.Version -eq $Version }

                    if ($null -eq $secret) {
                        $Message = "Cannot validate argument on parameter 'Version'. '$($Version)' is not a valid Version number. Pass the valid version number and try again."
                        $ErrorId = "InvalidArgument,PSDBKVSecret\Get-PSDBKVSecret" 
                        Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
                    }

                    else {
                        if ($AsPlainText.IsPresent) {
                            if ($secret.Enabled) {
                                $kv = Get-AzKeyVaultSecret -VaultName $secret.VaultName -Name $secret.Name -Version $secret.Version
                                $PSCmdlet.WriteObject((_convertToPlainText ($kv.SecretValue -as [securestring])))
                            } else {
                                $Message = "Cannot validate argument on parameter 'SecretName'. '$($SecretName)' is not enabled. Pass the valid secret name and try again."
                                $ErrorId = "InvalidArgument,PSDBKVSecret\Get-PSDBKVSecret" 
                                Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
                            }
                        } else {
                            $kv = Get-AzKeyVaultSecret -VaultName $secret.VaultName -Name $secret.Name -Version $secret.Version
                            $PSCmdlet.WriteObject($kv.SecretValue)
                        }
                    }
                }

                else {
                    if ($AsPlainText.IsPresent) {
                        $kvSecret | ForEach-Object {
                            if ($_.Enabled) {
                                $kv = Get-AzKeyVaultSecret -VaultName $_.VaultName -Name $_.Name -Version $_.Version
                                $PSCmdlet.WriteObject((_convertToPlainText ($kv.SecretValue -as [securestring])))
                            }
                        }
                    } else {
                        $kvSecret | ForEach-Object {
                            if ($_.Enabled) {
                                $kv = Get-AzKeyVaultSecret -VaultName $_.VaultName -Name $_.Name -Version $_.Version
                                $PSCmdlet.WriteObject($kv.SecretValue)
                            }
                        }
                    }
                }                
            }
        }
        catch {
            $content = $_.Exception.Response.Content
            $content = if ($content) { $content | ConvertFrom-Json }
            if ($content.error.innererror.code -eq "SecretDisabled") {
                $Message = "Cannot validate argument on parameter 'SecretName'. There is no active current version of '$($SecretName)'. Pass the valid secret name and try again."
                $ErrorId = "InvalidArgument,PSDBKVSecret\Get-PSDBKVSecret" 
                Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
            }
        }
    }
}