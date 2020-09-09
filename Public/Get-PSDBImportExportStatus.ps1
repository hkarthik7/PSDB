function Get-PSDBImportExportStatus {
    [Alias("Status")]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $StatusLink,

        [int] $Interval = 5,

        [int] $TimeOut = 300,

        [switch] $Wait
    )

    process {
        try {
            $Status = Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $StatusLink -ErrorAction Stop

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
            if ($_.Exception.Message -match "Invalid URI") {
                $Message = "Cannot validate argument '$($StatusLink)' on parameter StatusLink. Invalid URI. Pass the correct URI and try again."
                $ErrorId = "InvalidArgument,PSDBImportExportStatus\Export-PSDBImportExportStatus"
                Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
            }
            elseif ($_.Exception.Message -match "An error occurred while sending the request") {
                $Message = "Cannot validate argument '$($StatusLink)' on parameter StatusLink. Invalid URI. Pass the correct URI and try again."
                $ErrorId = "InvalidArgument,PSDBImportExportStatus\Export-PSDBImportExportStatus"
                Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
            }
            else {
                $Message = "$($_.Exception.Message)."
                $ErrorId = "InvalidArgument,PSDBImportExportStatus\Export-PSDBImportExportStatus"
                Write-Error -Exception ArgumentException -Message $Message -Category InvalidArgument -ErrorId $ErrorId
            }
        }
        finally {
            if ($stopWatch.IsRunning) {
                $stopWatch.Stop()
            }
        }
    }
}