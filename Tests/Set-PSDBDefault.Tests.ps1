Set-StrictMode -Version Latest

Describe "PSDB" {
    BeforeAll {
        Import-Module .\PSDB\PSDB.psm1 -Force
    }
    Context "Set-PSDBDefault" {
        BeforeAll {
            $subscription = (Get-AzSubscription -WarningAction SilentlyContinue).Name[0]
        }

        It "Should set the subscription in current context" {
            Set-PSDBDefault -Subscription $subscription
            $currentContext = (Get-AzContext).Subscription.Name
            ($currentContext -eq $subscription) | Should -Be $true
        }

        It "Should create environment variable" {
            $env:PSDB_SUBSCRIPTION | Should -Not -Be $null
        }

        It "Environment variable should contain current context value" {
            Assert ( ($env:PSDB_SUBSCRIPTION) -eq $subscription ) "$env:PSDB_SUBSCRIPTION should not be null after setting the value in current context"
        }
    }
}