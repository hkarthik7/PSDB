Set-StrictMode -Version Latest

Describe "PSDB" {
    BeforeAll {
        Import-Module .\PSDB\PSDB.psm1 -Force
    }
    Context "Get-PSDBDatabaseData" {
        BeforeEach {
            $username = Get-PSDBKVSecret -VaultName (_getResources -KeyVaults)[0] -SecretName "SQLUSERNAME" -AsPlainText
            $password = Get-PSDBKVSecret -VaultName (_getResources -KeyVaults)[0] -SecretName "SQLPASSWORD"
            $creds = New-Object System.Management.Automation.PSCredential($username, $password)
            $cs = New-PSDBConnectionString `
                    -SqlServerName "$((_getResources -SqlServers)).database.windows.net" `
                    -DatabaseName (_getResources -SqlDatabases) `
                    -UserName $username `
                    -Password $password
            $q = "SELECT * FROM sys.sysusers"
            $result = @{
                uid         = 16393
                status      = 0
                name        = "db_denydatawriter"
                sid         = '{1, 5, 0, 0...}'
                roles       = ''
                createdate  = '08/04/2003 09:10:42'
                updatedate  = '13/04/2009 12:59:14'
                altuid      = 1
                password    = ''
                gid         = 16393
                environ     = ''
                hasdbaccess = 0
                islogin     = 0
                isntname    = 0
                isntgroup   = 0
                isntuser    = 0
                issqluser   = 0
                isaliased   = 0
                issqlrole   = 1
                isapprole   = 0
            }
        }

        It "Should be exactly same as result" {
            Mock Get-PSDBDatabaseData { retun $result } -ParameterFilter {
                $ConnectionString -eq $cs
                $Query -eq $q
            }
        }

        It "Should be of type DataTable" {
            Get-PSDBDatabaseData -ConnectionString $cs -Query $q | Should -BeOfType [System.Data.DataTable]
        }

        It "Should return corresponding value" {
            # Act and assert on corresponding name field
            $name = "db_denydatawriter"
            Assert ( ((Get-PSDBDatabaseData -ConnectionString $cs -Query $q).name | Where-Object { $_ -eq $name } ) -eq $name ) `
            "Should be $name"
        }
    }
}