# PSDB

[![Build Status](https://dev.azure.com/solteccode/PSDB/_apis/build/status/PSDB-CI-Github?branchName=master)](https://dev.azure.com/solteccode/PSDB/_build/latest?definitionId=30&branchName=master)

**PSDB** is a PowerShell module which wrapps the operation of Azure Sql import and export and provides additional functionality to drive the import and export operation as you do in Azure portal.

It comes with tab completion of resource groups, sql servers, storage accounts and key vaults to select the resources easily. Also there are two helper functions `Get-PSDBDatabaseData` and `Invoke-PSDBDatabaseQuery` which allows you to open database connection and perfom database operations. This module is created to automate end to end sql import, export and database operations.

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

|Name|
---
|[Export-PSDBSqlDatabase](https://github.com/hkarthik7/PSDB/blob/master/docs/Export-PSDBSqlDatabase.md)|
|[Get-PSDBConnectionString](https://github.com/hkarthik7/PSDB/blob/master/docs/Get-PSDBConnectionString.md)|
|[Get-PSDBDatabaseData](https://github.com/hkarthik7/PSDB/blob/master/docs/Get-PSDBDatabaseData.md)|
|[Get-PSDBImportExportStatus](https://github.com/hkarthik7/PSDB/blob/master/docs/Get-PSDBImportExportStatus.md)|
|[Get-PSDBKVSecret](https://github.com/hkarthik7/PSDB/blob/master/docs/Get-PSDBKVSecret.md)|
|[Import-PSDBSqlDatabase](https://github.com/hkarthik7/PSDB/blob/master/docs/Import-PSDBSqlDatabase.md)|
|[Invoke-PSDBDatabaseQuery](https://github.com/hkarthik7/PSDB/blob/master/docs/Invoke-PSDBDatabaseQuery.md)|
|[New-PSDBConnectionString](https://github.com/hkarthik7/PSDB/blob/master/docs/New-PSDBConnectionString.md)|
|[Set-PSDBDefault](https://github.com/hkarthik7/PSDB/blob/master/docs/Set-PSDBDefault.md)|

## Build Locally

Clone the repo and run .\psake.ps1 which install the dependencies and runs the default task. This indeed updated the
functions and classes in .\PSDB folder.

## License

This project is licensed under [MIT](LICENSE)

## Contributions

Contributions are welcome, the goal is to make this module more robust and common to use on ease in all possible scenario.