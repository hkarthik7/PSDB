# PSDB

**PSDB** is a PowerShell module which wrapps the operation of Azure Sql import and export and provides additional functionality to drive the import and export operation as you do in Azure.

It comes with tab completion of resource groups, sql servers, storage accounts and key vaults to select the resources easily. Also there are two helper functions `Get-PSDBDatabaseData` and `Invoke-PSDBDatabaseQuery` which allows you to open database connection and perfom database operations. This module is created to automate end to end sql import, export and database operations.

## Getting Started

```powershell
PS C:\> Install-Module PSDB
```

## EXAMPLES

```powershell
PS C:\> Set-PSDBDefaults -Subscription "mySubscription" -ResourceGroupName "RSG" -ServerName "SqlServer01" -DatabaseName "Database01"
```

Calling `Set-PSDBDefaults` function with above mentioned parameters allows you to set the passed parameters in the current context. This way you don't have to specify ResourceGroupname, ServerName and DatabaseName in Export, Import and other functions that require these parameters. You can simply call the function with other mandatory parameters and execute.

- Perform export operation. Let's take an example that you want to export database from development subscription and place the exported .bacpac file in test subscription's sstorage account you can do the following. If you are exporting and saving the bacpac in same subscription then it is not mandatory to pass value to -Subscription parameter.

```powershell
# Set the default values. Since you have to export the database from development lets set the context as development.
PS C:\> Set-PSDBDefaults -Subscription "development" -ResourceGroupName "RSG" -ServerName "SqlServer01" -DatabaseName "Database01"

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

## Contributions

Contributions are welcome, the goal is to make this module more robust and common to use on ease in all possible scenario.