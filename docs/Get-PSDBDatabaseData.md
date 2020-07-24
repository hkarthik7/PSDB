---
external help file: PSDB-help.xml
Module Name: PSDB
online version:
schema: 2.0.0
---

# Get-PSDBDatabaseData

## SYNOPSIS

Get-PSDBDatabaseData retrieves database tabale data.

## SYNTAX

```
Get-PSDBDatabaseData [-ConnectionString] <String> [-Query] <String> [<CommonParameters>]
```

## DESCRIPTION

Get-PSDBDatabaseData retrieves database tabale data. As the name implies it is suggested to run only SELECT query when you call this function.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-PSDBDatabaseData `
            -ConnectionString "Data Source=SqlServer01.database.windows.net; Authentication=Active Directory Integrated; Initial Catalog=Database01;" `
            -Query "select * from sys.sysusers"
```

This outputs the list of users in system table.

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

Provide the query to run.

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