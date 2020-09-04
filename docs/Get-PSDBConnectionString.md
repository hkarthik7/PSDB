---
external help file: PSDB-help.xml
Module Name: PSDB
online version:
schema: 2.0.0
---

# Get-PSDBConnectionString

## SYNOPSIS
This function displays the Azure Sql connection strings.

## SYNTAX

```
Get-PSDBConnectionString [<CommonParameters>]
```

## DESCRIPTION
This function helps to identify the right connection string for Azure Sql database. You can choose which connection is possibl to use in your scenario and run
`New-PSDBConnectionString` function to form the connection string. Then it can be passed to helper functions `Get-PSDBDatabaseData` and `Invoke-PSDBDatabaseQuery`
to connect and work with Sql database.

These connection strings are available in [Connection Strings Website](https://www.connectionstrings.com/sql-server/).

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-PSDBConnectionString

Name                           Value
----                           -----
AAD With Username and Password Server=tcp:myserver.database.windows.net,1433;Authentication=Active Directory Password;Database=myDataBase;UID=myUser@myDomain;PWD=myPassword;
Standard                       Server=tcp:myserver.database.windows.net,1433;Database=myDataBase;User ID=mylogin@myserver;Password=myPassword;Trusted_Connection=False;Encrypt=True;
Always Encrypted               Data Source=myServer;Initial Catalog=myDB;Integrated Security=true;Column Encryption Setting=enabled;
MARS Enabled                   Server=tcp:myserver.database.windows.net,1433;Database=myDataBase;User ID=mylogin@myserver;Password=myPassword;Trusted_Connection=False;Encrypt=True;MultipleActi...
Integrated Windows Authenti... Server=tcp:myserver.database.windows.net,1433;Authentication=Active Directory Integrated;Database=mydatabase;
```

This is a helper function to identify and form the connection string to use it to query the database.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

[Get-PSDBConnectionString](https://github.com/hkarthik7/PSDB/blob/master/docs/Get-PSDBConnectionString.md)