function Get-PSDBDatabaseData {
    [CmdletBinding()]
    [OutputType([PSCustomobject])]
    param (
        [Parameter(
            Mandatory = $true, 
            Position = 0, 
            ValueFromPipeline = $true, 
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Provide the database connection string.")]
        [ValidateNotNullOrEmpty()]        
        [string] $ConnectionString,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Query
    )
    
    process {
        try {
            #region open DB connection

            $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
            $connection.ConnectionString = $ConnectionString
            $command = $connection.CreateCommand()
            $command.CommandText = $Query
            $connection.Open()

            #endregion open DB connection

            # execute the passed query and retrieve data
            $adapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter $command
            $dataset = New-Object -TypeName System.Data.Dataset

            $adapter.Fill($dataset) | Out-Null
            $result = $dataset.Tables

            return $result
        }
        catch {
            throw "Error at line $($_.InvocationInfo.ScriptLineNumber) : $($_.Exception.Message)."
        }
        finally {
            # cleaning up
            $connection.Close()
        }
    }
}