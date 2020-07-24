---
external help file: PSDB-help.xml
Module Name: PSDB
online version:
schema: 2.0.0
---

# Export-PSDBSqlDatabase

## SYNOPSIS

Export-PSDBSqlDatabase is a wrapper for New-AzSqlDatabaseExport cmdlet with tab completion for mandatory parameters.

## SYNTAX

```
Export-PSDBSqlDatabase -ResourceGroupName <String> [-DatabaseName] <String> -ServerName <String>
 [-StorageKeyType <String>] -StorageAccountName <String> -StorageContainerName <String> [-BlobName <String>]
 -AdministratorLogin <String> -AdministratorLoginPassword <SecureString> [-Subscription <String>]
 [<CommonParameters>]
```

## DESCRIPTION

Export-PSDBSqlDatabase is a wrapper for New-AzSqlDatabaseExport cmdlet with tab completion for mandatory parameters. It helps you export the database as you would do in Azure portal.

You can save the exported .bacpac file in different subscription by providing values to storage account name, container name and the subscription.

## EXAMPLES

### Example 1

```powershell
PS C:\> Export-PSDBSqlDatabase `
            -StorageAccountName "storage account name" ` # tab completion is available for this.
            -StorageContainerName "backups" `
            -AdministratorLogin "admin" `
            -AdministratorLoginPassword ('sqlstringpassword' | ConvertTo-SecureString -AsPlainText -Force)
```

Run Set-PSDBDefaults to set the resource group name, sql server name and database name as default values. Once this is set it is not required to provide these values at the time of export operation.

## PARAMETERS

### -AdministratorLogin

Provide the sql instance admin login user name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AdministratorLoginPassword

Provide the sql instance admin login password.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -BlobName

Provide the name of blob that you want to save as. If not provided it will save the .bacpac file as it would do in Azure Portal like DatabaseName-YY-MM-DD-HH-MM.bacpac format.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DatabaseName

Provide the database name that you want to export.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ResourceGroupName

Provide the resource group name. If this is set as default then it is not required to provide when running this cmdlet.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ServerName

Provide the sql server name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -StorageAccountName

Provide the storage account name where you want to save the .bacpac file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -StorageContainerName

Provide Container Name to save the exported database .bacpac file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -StorageKeyType

By default it is set to StorageAccessKey.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Subscription

Provide the subscription name if exported .bacpac file have to be saved in different subscription.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
