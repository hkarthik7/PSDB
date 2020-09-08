Set-StrictMode -Version Latest

Describe "PSDB" {
    BeforeAll {
        Import-Module .\PSDB\PSDB.psm1 -Force
    }
    Context "Get-PSDBConnectionString" {
        BeforeAll {
            $result = @{
                "Standard" = "Server=tcp:myserver.database.windows.net,1433;Database=myDataBase;User ID=mylogin@myserver;Password=myPassword;Trusted_Connection=False;Encrypt=True;"
                "MARS Enabled"  = "Server=tcp:myserver.database.windows.net,1433;Database=myDataBase;User ID=mylogin@myserver;Password=myPassword;Trusted_Connection=False;Encrypt=True;MultipleActiveResultSets=True;"
            }
        }

        It "Should be exactly same as result" {
            Mock Get-PSDBConnectionString { retun $result }
        }

        It "Should return Az Sql Connection strings" {
            Get-PSDBConnectionString | Should -BeOfType Hashtable
        }

        It "Should return corresponding value" {
            $cs = "Server=tcp:myserver.database.windows.net,1433;Database=myDataBase;User ID=mylogin@myserver;Password=myPassword;Trusted_Connection=False;Encrypt=True;MultipleActiveResultSets=True;"
            (Get-PSDBConnectionString)["MARS Enabled"] | Should -BeLikeExactly $cs
        }
    }
}