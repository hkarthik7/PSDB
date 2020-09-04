---
external help file: PSDB-help.xml
Module Name: PSDB
online version: https://www.connectionstrings.com/sql-server/
schema: 2.0.0
---

# New-PSDBConnectionString

## SYNOPSIS
New-PSDBConnectionString helps you to create a connection string for Azure Sql database.

## SYNTAX

### AAD
```
New-PSDBConnectionString -SqlServerName <String> -DatabaseName <String> -Credential <PSCredential>
 -Authentication <String> [<CommonParameters>]
```

### AADIntegrated
```
New-PSDBConnectionString -SqlServerName <String> -DatabaseName <String> -Authentication <String>
 [<CommonParameters>]
```

### MARSEnabled
```
New-PSDBConnectionString -SqlServerName <String> -DatabaseName <String> -Credential <PSCredential>
 [-MultipleActiveResultSets] [<CommonParameters>]
```

### Standard
```
New-PSDBConnectionString -SqlServerName <String> -DatabaseName <String> -Credential <PSCredential>
 [<CommonParameters>]
```

### Encrypted
```
New-PSDBConnectionString -DataSource <String> -InitialCatalog <String> [-IntegratedSecurity]
 [-ColumnEncryptionSetting <String>] [<CommonParameters>]
```

## DESCRIPTION
New-PSDBConnectionString helps you to create five different types of connection string which can be used to connect database.
These connection strings are available in [Connection Strings Website](https://www.connectionstrings.com/sql-server/) and the examples
which are pertaining to Azure Sql can be created with this function.

To view the list of available connection strings and what parameters to pass run `Get-PSDBConnectionString` function.

## EXAMPLES

### Example 1
```powershell
# Create standard connection string
PS C:\> $Cred = Get-Credential
PS C:\> New-PSDBConnectionString `
            -SqlServerName "sql-01" `
            -DatabaseName "sql-db-01" `
            -Credential $Cred

This returns below connection string; 
"Server=tcp:sql-01,1433;Database=sql-db-01;User ID=sqladmin@sql-01;Password=SqlPassword;Trusted_Connection=False;Encrypt=True;"
```

Tab completion is available for SqlServerName. Run `Get-PSDBConnectionString` to know the list of Connection string that can be formed with this
function.

## PARAMETERS

### -Authentication
Provide the authentication type.

```yaml
Type: String
Parameter Sets: AAD, AADIntegrated
Aliases:
Accepted values: Active Directory Integrated, Active Directory Password

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ColumnEncryptionSetting
Default to Enabled.

```yaml
Type: String
Parameter Sets: Encrypted
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Provide the username and Password. For Azure Active Directory with password connection string you need to pass the domain name with username like
domain\username and the password.

```yaml
Type: PSCredential
Parameter Sets: AAD, MARSEnabled, Standard
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DataSource
Provide the SqlServerName without FQDN; Tab completion is available.

```yaml
Type: String
Parameter Sets: Encrypted
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DatabaseName
Provide the DatabaseName.

```yaml
Type: String
Parameter Sets: AAD, AADIntegrated, MARSEnabled, Standard
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InitialCatalog
Provide the database name.

```yaml
Type: String
Parameter Sets: Encrypted
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IntegratedSecurity
True if provided.

```yaml
Type: SwitchParameter
Parameter Sets: Encrypted
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MultipleActiveResultSets
True if provided.

```yaml
Type: SwitchParameter
Parameter Sets: MARSEnabled
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SqlServerName
Provide the SqlServerName.

```yaml
Type: String
Parameter Sets: AAD, AADIntegrated, MARSEnabled, Standard
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

[New-PSDBConnectionString](https://github.com/hkarthik7/PSDB/blob/master/docs/New-PSDBConnectionString.md)