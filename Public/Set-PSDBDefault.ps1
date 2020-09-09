function Set-PSDBDefault {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Low")]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ArgumentCompleter([SubscriptionCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $Subscription,

        [Parameter(Position = 1, ValueFromPipeline = $true)]
        [ArgumentCompleter([ResourceGroupCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $ResourceGroupName,

        [ArgumentCompleter([SqlServerCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName,

        [ArgumentCompleter([DatabaseCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $DatabaseName,

        [ValidateNotNullOrEmpty()]
        [ValidateSet("Processs", "User", "Machine")]
        [string] $Level = "Process"
    )
    
    process {
        try {
            # setting the default subscription in current context.
            # It is expected that user should have logged into Azure already.

            # clearing the defaults. It returns old values if session is not restarted.
            _clearDefaults
            
            Write-Verbose "Setting default subscription"
            [System.Environment]::SetEnvironmentVariable("PSDB_SUBSCRIPTION", $Subscription, $Level)
            [PSDBResources]::Subscription = $env:PSDB_SUBSCRIPTION
            Set-AzContext -Subscription $Subscription > $null

            # setting default parameters helps to pick the mandatory parameters from current running process.
            if ($ResourceGroupName) {
                [System.Environment]::SetEnvironmentVariable("PSDB_RESOURCEGROUPNAME", $ResourceGroupName, $Level)
                $Global:PSDefaultParameterValues["*-PSDB*:ResourceGroupName"] = $ResourceGroupName
                [PSDBResources]::ResourceGroupName = $env:PSDB_RESOURCEGROUPNAME
            }

            if ($ServerName) {
                [System.Environment]::SetEnvironmentVariable("PSDB_SERVERNAME", $ServerName, $Level)
                $Global:PSDefaultParameterValues["*-PSDB*:ServerName"] = $ServerName
                [PSDBResources]::ServerName = $env:PSDB_SERVERNAME
            }

            if ($DatabaseName) {
                [System.Environment]::SetEnvironmentVariable("PSDB_DATABASENAME", $DatabaseName, $Level)
                $Global:PSDefaultParameterValues["*-PSDB*:DatabaseName"] = $DatabaseName
                [PSDBResources]::DatabaseName = $env:PSDB_DATABASENAME
            }
        }
        catch {
            throw "An error occurred: $($_.Exception.Message)"
        }        
    }
}