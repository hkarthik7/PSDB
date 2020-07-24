---
external help file: PSDB-help.xml
Module Name: PSDB
online version:
schema: 2.0.0
---

# Invoke-PSDBDatabaseQuery

## SYNOPSIS

Invoke-PSDBDatabaseQuery executes the query for the connect string.

## SYNTAX

```
Invoke-PSDBDatabaseQuery [-ConnectionString] <String> [-Query] <String> [<CommonParameters>]
```

## DESCRIPTION

Call this function to run UPDATE, DELETE and other invoke sql queries. Based on the connection string database connection is established and query is executed.

Care must be taken while running this function as it doesn't return any values once the query is exeucted. Running UPDATE or DELETE query can cause database inconsistency and care should be taken before calling this function.

## EXAMPLES

### Example 1

```powershell
PS C:\> Invoke-PSDBDatabaseQuery `
            -ConnectionString "Data Source=SqlServer01.database.windows.net; Authentication=Active Directory Integrated; InitialCatalog=Database01" `
            -Query "DROP user [username]"
```

This drops the user from database.

## PARAMETERS

### -ConnectionString

Provide the database connection string.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Query

Provide the Sql query to execute.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Connection Strings](https://www.connectionstrings.com/sql-server/)