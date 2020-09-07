# PSDB

## about_PSDB

# SHORT DESCRIPTION

PSDB helps to ease the automation of Azure Sql export and import functions.

# LONG DESCRIPTION

PSDB is a PowerShell module which wrapps the operation of Azure Sql import and export and provides additional functionality to drive the import and export operation as you do in Azure.

It comes with tab completion of resource groups, sql servers, storage accounts and key vaults to select the resources easily. Also there are two helper functions `Get-PSDBDatabaseData` and `Invoke-PSDBDatabaseQuery` which allows you to open database connection and perfom database operations. This module is created to automate end to end sql import, export and database operations.

Additionaly you can create a `Connection String` with the function `New-PSDBConnectionString` with diffferent versions and parameters.

# EXAMPLES

```powershell
PS C:\> Set-PSDBDefault -Subscription "mySubscription"
```

```powershell
PS C:\> Set-PSDBDefault -Subscription "mySubscription" -ResourceGroupName "RSG" -ServerName "SqlServer01" -DatabaseName "Database01"
```

Calling Set-PSDBDefault function with above mentioned parameters allows you to set the passed parameters in the current context. This way you don't have to specify ResourceGroupname, ServerName and DatabaseName in Export, Import and other functions that require these parameters. You can simply call the function with other mandatory parameters and execute.

## Export

- Perform export operation. Let's take an example that you want to export database from development subscription and place the exported .bacpac file in test subscription's sstorage account you can do the following. If you are exporting and saving the bacpac in same subscription then it is not mandatory to pass value to -Subscription parameter.

```powershell
# Set the default values. Since you have to export the database from development lets set the context as development.
PS C:\> Set-PSDBDefault -Subscription "development" -ResourceGroupName "RSG" -ServerName "SqlServer01" -DatabaseName "Database01"

# Now that context is set; retrieve username and password for database from keyvault. You can also pass the username and password as is, refer cmdlet releated help by running help Export-PSDBSqlDatabase -Full to know more.
PS C:\> $userName = Get-PSDBKVSecret -VaultName "myKeyVault" -SecretName "SQLUSERNAME" -AsPlainText
PS C:\> $password = Get-PSDBKVSecret -VaultName "myKeyVault" -SecretName "SQLPASSWORD"

# Now we have everything that we want to perform export operation. Pass the test subscription name and storage account details to export .bacpac file and save in the storage account.
PS C:\> Export-PSDBSqlDatabase `
            -StorageAccountName "storageaccount01" `
            -StorageContainerName sqlbackups `
            -AdministratorLogin $userName `
            -AdministratorLoginPassword $password `
            -Subscription "test"
```

# NOTE

By default the bacpac will be saved in the format of DatabaseName-YY-MM-DD--HH-MM as it would in Azure portal. You can change this by passing BlobName parameter in export function and BacPacName while importing it.

# TROUBLESHOOTING NOTE

Make sure to set the correct subscription in current context before calling any function.

# SEE ALSO

[Set-PSDBDefault](https://github.com/hkarthik7/PSDB/blob/master/docs/Set-PSDBDefault.md)
[Get-PSDBDatabaseData](https://github.com/hkarthik7/PSDB/blob/master/docs/Get-PSDBDatabaseData.md)
[Invoke-PSDBDatabaseQuery](https://github.com/hkarthik7/PSDB/blob/master/docs/Invoke-PSDBDatabaseQuery.md)

# KEYWORDS

[Set-PSDBDefault](https://github.com/hkarthik7/PSDB/blob/master/docs/Set-PSDBDefault.md)
