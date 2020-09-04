---
external help file: PSDB-help.xml
Module Name: PSDB
online version: https://www.connectionstrings.com/sql-server/
schema: 2.0.0
---

# Get-PSDBImportExportStatus

## SYNOPSIS

Get-PSDBImportExportStatus is a wrapper for cmdlet Get-AzSqlDatabaseImportExportStatus which checks the status of import or export operation for given status link.

## SYNTAX

```
Get-PSDBImportExportStatus [-StatusLink] <String> [-Interval <Int32>] [-TimeOut <Int32>] [-Wait]
 [<CommonParameters>]
```

## DESCRIPTION

Get-PSDBImportExportStatus is a wrapper for cmdlet Get-AzSqlDatabaseImportExportStatus which checks the status of import or export operation for given status link.
Get-PSDBImportExportStatus is mainly built for end to end automation of sql database import and export. This function continuously checks for the status of operation for given status link and waits till the operation completes.

If switch -Wait is enabled by default it checks for the status till the operation completes and if time exceeds than 300 seconds i.e., 5 minutes the script stops automatically. This waiting period can by controlled by passing the interval to check the status continuously and time out after particular time period. Note that all the values have to be passed in seconds.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-PSDBImportExportStatus -StatusLink "<Link here>" -Wait
```

Import and Export operation returns status link which can be passed to this function to check the status.

## PARAMETERS

### -Interval

Provide the time interval in seconds to wait for certain period and check the status of import and export status. Default is 5 seconds.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StatusLink

Url where the export or import operation status can be checked.

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

### -TimeOut

Set the time out in seconds to terminate the status check operation. Default is 300 seconds.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Wait

If this is enabled the script will wait for passed in time period and check the status.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Get-PSDBImportExportStatus](https://github.com/hkarthik7/PSDB/blob/master/docs/Get-PSDBImportExportStatus.md)