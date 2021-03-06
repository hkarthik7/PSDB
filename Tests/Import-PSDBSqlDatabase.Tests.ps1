Set-StrictMode -Version Latest

Describe "PSDB" {
    BeforeAll {
        Import-Module .\PSDB\PSDB.psm1 -Force
    }
    Context "Import-PSDBSqlDatabase" {
        BeforeAll {
            $result = "https://status-link-to-export-and-import-status"
        }

        It "Should return the status link after triggering the import operation" {
            Mock Import-PSDBSqlDatabase { return $result } -ParameterFilter {
                $ResourceGroupName -eq "sql"
                $ServerName -eq "sql-01"
                $StorageAccountName -eq "storageaccount"
                $StorageContainerName -eq  "test"
                $AdministratorLogin -eq "sqladmin"
                $AdministratorLoginPassword -eq "sqlPassword"
            }
        }
    }
}