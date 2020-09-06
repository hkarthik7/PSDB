function Set-PSDBDefault {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Low")]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [SubscriptionValidateAttribute()]
        [ArgumentCompleter([SubscriptionCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $Subscription,

        [Parameter(Position = 1, ValueFromPipeline = $true)]
        [ArgumentCompleter([ResourceGroupCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $ResourceGroupName,

        [SqlServerValidateAttribute()]
        [ArgumentCompleter([SqlServerCompleter])]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName,

        [ValidateNotNullOrEmpty()]
        [string] $DatabaseName
    )

    DynamicParam {
        $dp = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        $ParameterName = 'Level'

        # Create the collection of attributes
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

        # Create and set the parameters' attributes
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $false
        $ParameterAttribute.HelpMessage = "Set the default parameters to work with the module on ease."

        $arrSet = "Process", "User", "Machine"
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

        # Add the ValidateSet to the attributes collection
        $AttributeCollection.Add($ValidateSetAttribute)

        # Add the attributes to the attributes collection
        $AttributeCollection.Add($ParameterAttribute)
        
        # Create and return the dynamic parameter
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $dp.Add($ParameterName, $RuntimeParameter)

        return $dp
    }

    begin {
        $Level = $PSBoundParameters[$ParameterName]
    }
    
    process {
        # setting the default subscription user gives and retrieving all the subscriptions in
        # current context. This will be then used for tab completions.
        # It is expected that user should have logged into Azure already.
        if (-not $Level) {
            $Level = "Process"
        }

        if ($PSCmdlet.ShouldProcess($Subscription, "Set-PSDBDefault")) {

            # clearing the defaults. It returns old values if session is not restarted.
            _clearDefaults

            if ($null -eq $env:PSDB_SUBSCRIPTIONS) {
                $Subscriptions = (Get-AzContext -ListAvailable -WarningAction SilentlyContinue).Subscription.Name -join ","
            } else {
                $Subscriptions = $env:PSDB_SUBSCRIPTIONS
            }

            if (-not $Subscriptions) {
                throw [System.Exception]::new("Please login to Azure using 'Connect-AzAccount' cmdlet to continue..")
            } 
        
            else {
                [System.Environment]::SetEnvironmentVariable("PSDB_SUBSCRIPTION", $Subscription, $Level)
                [System.Environment]::SetEnvironmentVariable("PSDB_SUBSCRIPTIONS", $Subscriptions, $Level)

                [PSDBResources]::Subscription = $env:PSDB_SUBSCRIPTION
                [PSDBResources]::Subscriptions = $env:PSDB_SUBSCRIPTIONS

                if ((Get-AzContext).Subscription.Name -ne $Subscription) {
                    Write-Verbose "Setting given subscription as default.."
                    Set-AzContext -Subscription $Subscription > $null
                }                
            }
        }

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
}