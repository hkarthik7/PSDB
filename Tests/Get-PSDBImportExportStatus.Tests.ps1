Set-StrictMode -Version Latest

Describe "PSDB" {
    BeforeAll {
        Import-Module .\PSDB\PSDB.psm1 -Force
    }
    Context "Get-PSDBImportExportStatus" {
        BeforeAll {
            $result = "https://status-link-to-export-and-import-status"
        }

        It "Should be exactly same as result" {
            Mock Get-PSDBImportExportStatus { retun "Succeeded" } -ParameterFilter {
                $StatusLink -eq $result
            }
        }
    }
}