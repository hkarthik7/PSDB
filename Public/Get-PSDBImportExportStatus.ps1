function Get-PSDBImportExportStatus {
    [Alias("Status")]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $StatusLink,

        [int] $Interval = 5,

        [int] $TimeOut = 300,

        [switch] $Wait
    )

    process {
        try {
            $Status = Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $StatusLink

            if ($Wait.IsPresent) {

                $timeSpan = New-TimeSpan -Seconds $TimeOut
                $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

                while (($Status.Status -eq "InProgress") -and ($stopWatch.Elapsed.Seconds -lt $timeSpan.TotalSeconds)) {

                    Start-Sleep -Seconds $Interval
                    $Status = Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $StatusLink
                    
                    if (($Status.Status -ne "InProgress") -or ($stopWatch.Elapsed.Seconds -lt $timeSpan.TotalSeconds)) {
                        if ($Status.Status -ne "InProgress") {
                            Write-Output "Status has changed to: $($Status.Status)"
                        }
                    }
                    else { Start-Sleep -Seconds $Interval; continue; }
                }

                $stopWatch.Stop()
            }

            else {
                return $Status.Status
            }
        }
        catch {
            throw "Error at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
        }
        finally {
            if ($stopWatch.IsRunning) {
                $stopWatch.Stop()
            }
        }
    }
}