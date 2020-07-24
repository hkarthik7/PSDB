function Invoke-PSDBDatabaseQuery {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true, 
            Position = 0, 
            ValueFromPipeline = $true, 
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Provide the database connection string.")]
        [string] $ConnectionString,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
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

            # execute query
            $command.ExecuteNonQuery() > $null
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