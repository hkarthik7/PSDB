Set-StrictMode -Version Latest

Describe "PSDB" {
    BeforeAll {
        Import-Module .\PSDB\PSDB.psm1 -Force
    }
    Context "New-PSDBConnectionString" {
        BeforeAll {
            $SqlServerName = "sql-01"
            $DatabaseName = "sql-db-01"
            $Creds = New-Object System.Management.Automation.PSCredential("domain\username", ("myPassword" | ConvertTo-SecureString -AsPlainText -Force))
            $cs = Get-PSDBConnectionString
        }

        It "Should return 'Standard' connection string" {
            Mock New-PSDBConnectionString { return $cs["Standard"] } -ParameterFilter {
                $SqlServerName -eq $SqlServerName
                $DatabaseName -eq  $DatabaseName
                $Credential -eq $Creds
            }
        }

        It "Should return 'MARS Enabled' connection string" {
            Mock New-PSDBConnectionString { return $cs["MARS Enabled"] } -ParameterFilter {
                $SqlServerName -eq $SqlServerName
                $DatabaseName -eq  $DatabaseName
                $Credential -eq $Creds
                $MultipleActiveResultSets -eq $true
            }
        }

        It "Should return 'AAD With Username and Password' connection string" {
            Mock New-PSDBConnectionString { return $cs["AAD With Username and Password"] } -ParameterFilter {
                $SqlServerName -eq $SqlServerName
                $DatabaseName -eq  $DatabaseName
                $Credential -eq $Creds
                $Authentication -eq 'Active Directory Password'
            }
        }

        It "Should return 'Integrated Windows Authentication with AAD' connection string" {
            Mock New-PSDBConnectionString { return $cs["Integrated Windows Authentication with AAD"] } -ParameterFilter {
                $SqlServerName -eq $SqlServerName
                $DatabaseName -eq  $DatabaseName
                $Authentication -eq 'Active Directory Integrated'
            }
        }

        It "Should return 'Always Encrypted' connection string" {
            Mock New-PSDBConnectionString { return $cs["Always Encrypted"] } -ParameterFilter {
                $DataSource -eq $SqlServerName
                $InitialCatalog -eq  $DatabaseName
                $IntegratedSecurity -eq $true
            }
        }

        It "Should be exactly same as `$connectionString" {
            # Assert for connection string.
            $connectionString = "Data Source=sql-01;Initial Catalog=sql-db-01;Integrated Security=True;Column Encryption Setting=enabled;"
            Assert ( (New-PSDBConnectionString -DataSource $SqlServerName -InitialCatalog $DatabaseName -IntegratedSecurity) -eq $connectionString ) `
            "result should be same as $connectionString"
        }
    }
}