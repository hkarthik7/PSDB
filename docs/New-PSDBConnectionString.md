---
external help file: PSDB-help.xml
Module Name: PSDB
online version: https://www.connectionstrings.com/sql-server/
schema: 2.0.0
---

# New-PSDBConnectionString

## SYNOPSIS
`New-PSDBConnectionString` helps you to create a connection string for Azure Sql database.

## SYNTAX

### AADIntegrated (Default)
```
New-PSDBConnectionString -SqlServerName <String> -DatabaseName <String> -Authentication <String>
 [<CommonParameters>]
```

### AAD
```
New-PSDBConnectionString -SqlServerName <String> -DatabaseName <String> -UserName <String> -Domain <String>
 -Password <PSCredential> -Authentication <String> [<CommonParameters>]
```

### MARSEnabled
```
New-PSDBConnectionString -SqlServerName <String> -DatabaseName <String> -UserName <String>
 -Password <PSCredential> [-MultipleActiveResultSets] [<CommonParameters>]
```

### Standard
```
New-PSDBConnectionString -SqlServerName <String> -DatabaseName <String> -UserName <String>
 -Password <PSCredential> [<CommonParameters>]
```

### Encrypted
```
New-PSDBConnectionString -DataSource <String> -InitialCatalog <String> [-IntegratedSecurity]
 [-ColumnEncryptionSetting <String>] [<CommonParameters>]
```

## DESCRIPTION
`New-PSDBConnectionString` helps you to create five different types of connection string which can be used to connect database.
These connection strings are available in [Connection Strings Website](https://www.connectionstrings.com/sql-server/) and the examples
which are pertaining to Azure Sql can be created with this function.

To view the list of available connection strings and what parameters to pass run `Get-PSDBConnectionString` function.

## EXAMPLES

### Example 1
```powershell
# Create standard connection string
PS C:\> New-PSDBConnectionString `
            -SqlServerName "sql-01" `
            -DatabaseName "sql-db-01" 
            -UserName "sqladmin" `
            -Password ("SqlPassword" | ConvertTo-SecureString -AsPlainText -Force)

This returns below connection string; 
"Server=tcp:sql-01,1433;Database=sql-db-01;User ID=sqladmin@sql-01;Password=SqlPassword;Trusted_Connection=False;Encrypt=True;"
```

### Example 2
```powershell
# Create Azure Active Directory integrated with username and password connection string
PS C:\> $Cred = New-Object System.Management.Automation.PSCredential("domain\sqladmin", ("SqlPassword" | ConvertTo-SecureString -AsPlainText -Force))
PS C:\> New-PSDBConnectionString `
            -SqlServerName "sql-01" `
            -DatabaseName "sql-db-01" `
            -Authentication 'Active Directory Password' 
            -UserName "sqladmin" `
            -Domain "domain"
            -Password ("SqlPassword" | ConvertTo-SecureString -AsPlainText -Force)

This returns below connection string; 
"Server=tcp:sql-01,1433;Authentication=Active Directory Password;Database=sql-db-01;UID=sqladmin@domain;Password=SqlPassword;"
```

Tab completion is available for SqlServerName. Run `Get-PSDBConnectionString` to know the list of Connection string that can be formed with this
function.

## PARAMETERS

### -Authentication
Provide the authentication type.

```yaml
Type: String
Parameter Sets: AADIntegrated, AAD
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
Parameter Sets: AADIntegrated, AAD, MARSEnabled, Standard
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
Parameter Sets: AADIntegrated, AAD, MARSEnabled, Standard
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Domain
Provide the domain name

```yaml
Type: String
Parameter Sets: AAD
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Password
Provide the database secure password

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

### -UserName
Provide the username of database

```yaml
Type: String
Parameter Sets: AAD, MARSEnabled, Standard
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