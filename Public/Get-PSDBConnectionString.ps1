function Get-PSDBConnectionString {
    process {
        $AzSqlConnectionStrings = @{
            "Standard" = "Server=tcp:myserver.database.windows.net,1433;Database=myDataBase;User ID=mylogin@myserver;Password=myPassword;Trusted_Connection=False;Encrypt=True;"
            "MARS Enabled" = "Server=tcp:myserver.database.windows.net,1433;Database=myDataBase;User ID=mylogin@myserver;Password=myPassword;Trusted_Connection=False;Encrypt=True;MultipleActiveResultSets=True;"
            "Integrated Windows Authentication with AAD" = "Server=tcp:myserver.database.windows.net,1433;Authentication=Active Directory Integrated;Database=mydatabase;"
            "AAD With Username and Password" = "Server=tcp:myserver.database.windows.net,1433;Authentication=Active Directory Password;Database=myDataBase;UID=myUser@myDomain;PWD=myPassword;"
            "Always Encrypted" = "Data Source=myServer;Initial Catalog=myDB;Integrated Security=true;Column Encryption Setting=enabled;"
        }

        return $AzSqlConnectionStrings
    }    
}