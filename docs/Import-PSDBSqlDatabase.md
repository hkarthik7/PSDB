---
external help file: PSDB-help.xml
Module Name: PSDB
online version:
schema: 2.0.0
---

# Import-PSDBSqlDatabase

## SYNOPSIS

Import-PSDBSqlDatabase is a wrapper for New-AzSqlDatabaseImport which provides tab completion for resourcegroups, sql servers, storageacount and subscription.

## SYNTAX

```
Import-PSDBSqlDatabase [-ResourceGroupName] <String> [[-ImportDatabaseAs] <String>] [-ServerName] <String>
 [[-StorageKeyType] <String>] [[-Edition] <String>] [[-ServiceObjectiveName] <String>]
 [[-DatabaseMaxSizeBytes] <String>] [-StorageAccountName] <String> [-StorageContainerName] <String>
 [[-BacpacName] <String>] [-AdministratorLogin] <String> [-AdministratorLoginPassword] <SecureString>
 [[-Subscription] <String>] [<CommonParameters>]
```

## DESCRIPTION

Import-PSDBSqlDatabase is a wrapper for New-AzSqlDatabaseImport which helps you to import the database on ease without considering the complexity. Import datase with New-AzSqlDatabaseImport as you would do in Azure portal by supplying ResourceGroupName, SqlServerName, Database Name to import .bacpac file as, storage account and container name.

It also allows you to tab complete mandatory parameters and select .bapac file in storage account of different subscripion. If you specify the storage account name which is different from yur current set context then you have to specify Subscription parameter.

For instance you have selected development subscription in the current context and the bacpac file that you want to import is in test subscription, then you have to specify the test subscription storage account name and test subscription name for -Subscription parameter.

## EXAMPLES

### Example 1

```powershell
PS C:\> $impUsr = Get-PSDBKVSecret -VaultName kv-01 -SecretName "SQLUSERNAME" -AsPlainText
PS C:\> $impPswd = Get-PSDBKVSecret -VaultName kv-01 -SecretName "SQLPASSWORD"
PS C:\> Import-PSDBSqlDatabase `
            -StorageAccountName "storage account name" `
            -StorageContainerName "container name" `
            -AdministratorLogin $impUsr `
            -AdministratorLoginPassword $impPswd
```

Run Set-PSDBDefaults to set the subscription to which you want to import the database or .bacpac file and set resource groupname, server name as defaults. This way you don't have specify these parameter when you call import function.

## PARAMETERS

### -AdministratorLogin

Provide the sql admin user name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 10
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AdministratorLoginPassword

Provide the sql admin password.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: True
Position: 11
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -BacpacName

Provide the name of .bacpac file. If not provided it tries to retrieve latest '.bacpac' file from provided container.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DatabaseMaxSizeBytes

Default is 500000.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Edition

Default is Standard. Provide the SQL database edition here.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ImportDatabaseAs

Provide the name of database to import as. If not provided by default it will take the name of .bacpac file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceGroupName

Provide the resource group name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ServerName

Provide the name of Sql server.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ServiceObjectiveName

Default to S0.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StorageAccountName

Provide the storage account name where .bacpac file is placed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 7
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -StorageContainerName

Provide Container Name to import database .bacpac file from.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 8
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -StorageKeyType

Default to StorageAccessKey.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Subscription

Provide the subscription name to import .bacpac file from.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.Security.SecureString

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
