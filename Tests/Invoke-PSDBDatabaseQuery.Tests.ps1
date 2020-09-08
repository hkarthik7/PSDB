Set-StrictMode -Version Latest

Describe "PSDB" {
    BeforeAll {
        Import-Module .\PSDB\PSDB.psm1 -Force
    }
    Context "Invoke-PSDBDatabaseQuery" {
        BeforeAll {
            $username = Get-PSDBKVSecret -VaultName (_getResources -KeyVaults)[0] -SecretName "SQLUSERNAME" -AsPlainText
            $password = Get-PSDBKVSecret -VaultName (_getResources -KeyVaults)[0] -SecretName "SQLPASSWORD"
            $creds = New-Object System.Management.Automation.PSCredential($username, $password)
            $cs = New-PSDBConnectionString `
                    -SqlServerName "$((_getResources -SqlServers)).database.windows.net" `
                    -DatabaseName (_getResources -SqlDatabases) `
                    -Credential $creds
            $q = "SELECT * FROM sys.sysusers"
            $invokeQuery = "CREATE user [test] with password='Welcome@1234'"
            $dropQuery = "DROP user [test]"
        }

        It "Should create [test] user" {
            # invoke the query to create user in database
            $cs | Invoke-PSDBDatabaseQuery -Query $invokeQuery | Should -Be $null
        }

        It "Should return corresponding value" {
            # Act and assert for the value test2
            # fetch the results and validate if user is created or not
            $results = $cs | Get-PSDBDatabaseData -Query $q
            Assert ( ($results.name | Where-Object { $_ -eq "test" } ) -eq "test" ) `
            "Should be test2"
        }

        It "Should drop [test] user" {
            # invoke the query to create user in database
            $cs | Invoke-PSDBDatabaseQuery -Query $dropQuery | Should -Be $null
        }

        It "Should not exists" {
            $results = $cs | Get-PSDBDatabaseData -Query $q
            $results.name | Where-Object { $_ -eq "test" } | Should -Be $null
        }
    }
}