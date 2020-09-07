---
external help file: PSDB-help.xml
Module Name: PSDB
online version:
schema: 2.0.0
---

# Set-PSDBDefault

## SYNOPSIS

Set-PSDBDefault sets the default parameters in current session or process.

## SYNTAX

```
Set-PSDBDefault [-Subscription] <String> [[-ResourceGroupName] <String>] [-ServerName <String>]
 [-DatabaseName <String>] [-WhatIf] [-Confirm] [-Level <String>] [<CommonParameters>]
```

## DESCRIPTION

Set-PSDBDefault helps to set the default parameters used in PSDB module in current session. This helps to tab complete certain parameters
such as ResourceGroupName and working with Subscriptions.

## EXAMPLES

### Example 1

```powershell
PS C:\> Set-PSDBDefault -Subscription "subscription name"
```

This sets the default subscription in current session and selects the subscription. Once this is set it allows to tab complete the subscriptions consequently.

### Example 2

```powershell
PS C:\> Set-PSDBDefault -ResourceGroupName "resource group name" -ServerName "Sql server name" -DatabaseName "Sql database name"
```

Once these values are set in current session it is not required to pass these values to export and import functions. It automatically picks up the default values.

## PARAMETERS

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DatabaseName

Provide the Sql database name to set as default value.

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

### -Level

Select the level to set the defaults.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Process, User, Machine

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceGroupName

Provide the resource group that you want to default. Then for any other parameter where resource group name is mandatory it is not required to specify this.
Also it allows tab completion.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ServerName

Provide the Sql server name.

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

Provide the default subscription name to set.

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

### -WhatIf
Shows what would happen if the cmdlet runs. The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

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

[Set-PSDBDefault](https://github.com/hkarthik7/PSDB/blob/master/docs/Set-PSDBDefault.md)