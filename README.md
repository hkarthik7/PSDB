# PSDB

[![Build Status](https://dev.azure.com/solteccode/PSDB/_apis/build/status/PSDB-CI-Github?branchName=master)](https://dev.azure.com/solteccode/PSDB/_build/latest?definitionId=30&branchName=master)

**PSDB** module allows you to ease the automation of Azure Sql import and export. Also, it allows you to connect to the database and run queries.

It comes with tab completion of resource groups, sql servers, storage accounts and key vaults to select the resources easily. Functions `Get-PSDBDatabaseData` and `Invoke-PSDBDatabaseQuery` allows you to open database connection and perfom database operations. 

View the introduction and module usage [here](https://hkarthik7.github.io/powershell/2020/08/02/PSDB.html).

## Getting Started

You can directly install the module from [PowerShell gallery](https://www.powershellgallery.com/packages/PSDB/0.1.14).

## Release Notes

- [Change Log](CHANGELOG.md)

## Dependencies

- Az.Accounts
- Az.Sql
- Az.Resources
- Az.Storage
- Az.KeyVault

## Functions

- [Export-PSDBSqlDatabase](https://github.com/hkarthik7/PSDB/blob/master/docs/Export-PSDBSqlDatabase.md)
- [Get-PSDBConnectionString](https://github.com/hkarthik7/PSDB/blob/master/docs/Get-PSDBConnectionString.md)
- [Get-PSDBDatabaseData](https://github.com/hkarthik7/PSDB/blob/master/docs/Get-PSDBDatabaseData.md)
- [Get-PSDBImportExportStatus](https://github.com/hkarthik7/PSDB/blob/master/docs/Get-PSDBImportExportStatus.md)
- [Get-PSDBKVSecret](https://github.com/hkarthik7/PSDB/blob/master/docs/Get-PSDBKVSecret.md)
- [Import-PSDBSqlDatabase](https://github.com/hkarthik7/PSDB/blob/master/docs/Import-PSDBSqlDatabase.md)
- [Invoke-PSDBDatabaseQuery](https://github.com/hkarthik7/PSDB/blob/master/docs/Invoke-PSDBDatabaseQuery.md)
- [New-PSDBConnectionString](https://github.com/hkarthik7/PSDB/blob/master/docs/New-PSDBConnectionString.md)
- [Set-PSDBDefault](https://github.com/hkarthik7/PSDB/blob/master/docs/Set-PSDBDefault.md)

## Test Results

[![Test Results](/Tests/img/test-results.PNG)](/Tests/img/test-results.PNG)

## Build Locally

Clone the repo and run .\psake.ps1 which installs the dependencies and runs the default task. This indeed updates the
functions and classes in .\PSDB folder.

## License

This project is licensed under [MIT](LICENSE)

## Contributions

Contributions are welcome, the goal is to make this module more robust and common to use on ease in all possible scenario.