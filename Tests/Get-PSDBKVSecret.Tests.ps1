Set-StrictMode -Version Latest

Describe "PSDB" {
    BeforeAll {
        Import-Module .\PSDB\PSDB.psm1 -Force
    }
    Context "Get-PSDBKVSecret" {
        # Act and assert on defined dummy variables.

        BeforeEach {
            $VaultName = "test-psdb-kv-01"
            $SecretName = "sqlpassword"
            $result = "Test@123"
        }

        It "Should return password as plain text" {
            Mock Get-PSDBKVSecret { return $result } -ParameterFilter {
                $VaultName -eq $VaultName
                $SecretName -eq  $SecretName
                $AsPlainText -eq $true
            }
        }

        It "Should return password as secure string" {
            Get-PSDBKVSecret -VaultName $VaultName -SecretName $SecretName | Should -BeOfType System.Security.SecureString
        }
    }
}