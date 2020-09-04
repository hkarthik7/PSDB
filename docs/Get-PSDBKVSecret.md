---
external help file: PSDB-help.xml
Module Name: PSDB
online version:
schema: 2.0.0
---

# Get-PSDBKVSecret

## SYNOPSIS

Get-PSDBKVSecret is a wrapper for Get-AzKeyVaultSecret modified accordingly to work with PSDB module on ease.

## SYNTAX

```
Get-PSDBKVSecret [-VaultName] <String> [-SecretName] <String> [-AsPlainText] [-Version <String>]
 [<CommonParameters>]
```

## DESCRIPTION

Get-PSDBKVSecret is a wrapper for Get-AzKeyVaultSecret modified accordingly to work with PSDB module on ease. It has tab completion for key vault name and option to select the version. If no version is provided it returns all secrets by default. The value that it returns can be controlled by -AsPlainText switch.

## EXAMPLES

### Example 1

```powershell
PS C:\> $userName = Get-PSDBKVSecret -VaultName "kv-01" -SecretName "DatabaseUsername" -AsPlainText
PS C:\> $password = Get-PSDBKVSecret -VaultName "kv-01" -SecretName "DatabasePassword"
```

Now this can be passed to other functions to export and import database.

## PARAMETERS

### -AsPlainText

If provided retrieves the secret value as plain text.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SecretName

Provide the key vault secret name.

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

### -VaultName

Provide the key vault name.

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

### -Version

Provide the secret version to be retrieved.

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

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Get-PSDBKVSecret](https://github.com/hkarthik7/PSDB/blob/master/docs/Get-PSDBKVSecret.md)