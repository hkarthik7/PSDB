# 0.1.16

- Update for `Get-PSDBKVSecret` with error handling and code refactor. Removed `SecretValueText` attribute fetcher from
the function and replaced with helper function to convert the secure string to plain text. `SecretValueText` will be
deprecated in future module release.
- Added argument validators for `ResourceGroupName`, `StorageAccount`, `SqlServer`, `Subscription` and `Database.`
- Function name change for `Set-PSDBDefault` and added argument completer for `Database`.
- Added warning message suppression for KeyVault cmdlet.

# 0.1.15

- Added helper functions `Get-PSDBConnectionString` and `New-PSDBConnectionString` to get a list of available connection
strings and to create a connection string. More details on available connection strings 
can be availed [here](https://www.connectionstrings.com/).

# 0.1.14

- Bug fix for `Import-PSDBSqlDatabase`. Database name is being imported with .bacpac extension, this bug is removed in this version.

# 0.1.13

- Added new function `Get-PSDBImportExportStatus` to check the status of import or export operation.

# 0.1.12

- Now Export and Import functions return the operational status link which helps to monitor the status continuously.

# 0.1.11

- Minor update in manifest file. Bug fix for Invoke-Build file as all the classes are accumulated in .functions.ps1 file.

# 0.1.10

- Initial module release.