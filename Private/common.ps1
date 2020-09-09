function _setDefaultResource {
    param (
        [string] $ResourceName,
        [object[]] $Resources
    )

    if ($Resources.Count -gt 1) {
        $Resources = $Resources -join ","
    }

    [System.Environment]::SetEnvironmentVariable("PSDB_$($ResourceName.ToUpper())", $Resources, "Process")
}

function _getDefaultSubscription {
    return $env:PSDB_SUBSCRIPTION
}

function _getDefaultSubscriptions {
    return ($env:PSDB_SUBSCRIPTIONS -split ",")
}

# Using this function only for tab completers.
function _getResources {
    param (
        [switch] $ResourceGroups,
        [switch] $SqlServers,
        [switch] $StorageAccounts,
        [switch] $KeyVaults,
        [switch] $SqlDatabases
    )

    if ($ResourceGroups) {
        $rsgs = $env:PSDB_RESOURCEGROUPS -split ","
        if (-not $rsgs) {
            $resources = Get-AzResource
            $resourceGroupNames = $resources.ResourceGroupName | Select-Object -Unique

            _setDefaultResource -ResourceName "ResourceGroups" -Resources $resourceGroupNames
            [PSDBResources]::ResourceGroups = $env:PSDB_RESOURCEGROUPS  -split ","

            return [PSDBResources]::ResourceGroups
        } else {
            return $rsgs
        }
    }

    if ($SqlServers) {
        $sql = $env:PSDB_SQLSERVERS -split ","
        if (-not $sql) {
            $resources = Get-AzResource
            $servers = $resources | Where-Object {$_.ResourceId -like "*Microsoft.Sql*" -and $_.Name -notlike "*/*"} | Select-Object Name

            _setDefaultResource -ResourceName "SqlServers" -Resources $servers.Name
            [PSDBResources]::SqlServers = $env:PSDB_SQLSERVERS -split ","

            return [PSDBResources]::SqlServers
        } else {
            return $sql
        }
    }

    if ($StorageAccounts) {
        $storage = $env:PSDB_STORAGEACCOUNTS -split ","
        if (-not $storage) {
            $resources = @()
            $currentContext = (Get-AzContext).Subscription.Name
            $subscriptions = if ([string]::IsNullOrEmpty($env:PSDB_SUBSCRIPTIONS)) { (Get-AzContext -ListAvailable).Subscription.Name } else { _getDefaultSubscriptions }
            $subscriptions | ForEach-Object { Set-AzContext -Subscription $_ > $null; $resources += Get-AzResource }
            Set-AzContext -Subscription $currentContext
            # $resources = Get-AzResource
            $accounts = $resources | Where-Object {$_.ResourceId -like "*Microsoft.Storage*"} | Select-Object Name

            _setDefaultResource -ResourceName "StorageAccounts" -Resources $accounts.Name
            [PSDBResources]::StorageAccounts = $env:PSDB_STORAGEACCOUNTS -split ","

            return [PSDBResources]::StorageAccounts
        } else {
            return $storage
        }
    }

    if ($KeyVaults) {
        $kvs = $env:PSDB_KEYVAULTS -split ","
        if (-not $kvs) {
            $resources = Get-AzResource
            $kVaults = $resources | Where-Object {$_.ResourceId -like "*Microsoft.KeyVault*"} | Select-Object Name

            _setDefaultResource -ResourceName "KeyVaults" -Resources $kVaults.Name
            [PSDBResources]::KeyVaults = $env:PSDB_KEYVAULTS -split ","

            return [PSDBResources]::KeyVaults
        } else {
            return $kvs
        }
    }

    if ($SqlDatabases) {
        $dbs = $env:PSDB_DATABASES -split ","
        if (-not $dbs) {
            $resources = Get-AzResource
            $databases = $resources | Where-Object {$_.ResourceType -eq "Microsoft.Sql/servers/databases"} | Select-Object Name
            $databases = $databases | Where-Object { $_.Name -notlike "*master*" }

            _setDefaultResource -ResourceName "DATABASES" -Resources $databases.Name.Split("/")[1]
            [PSDBResources]::SqlDatabases = $env:PSDB_DATABASES -split ","

            return [PSDBResources]::SqlDatabases
        } else {
            return $dbs
        }
    }

    return Get-AzResource
}

function _getStorageAccountKey {
    param (
        [string] $StorageAccountName
    )
    
    $storageAccounts = Get-AzStorageAccount
    $storage = $storageAccounts | Where-Object {$_.StorageAccountName -eq $StorageAccountName} | Select-Object ResourceGroupName
    $keys = Get-AzStorageAccountKey -ResourceGroupName $storage.ResourceGroupName -Name $StorageAccountName

    return $keys.Value[1]

}

function _getStorageUri {
    param (
        [string] $StorageAccountName,
        [string] $StorageContainerName
    )

    $key = _getStorageAccountKey -StorageAccountName $StorageAccountName
    $context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $key
    $container = Get-AzStorageContainer -Name $StorageContainerName -Context $context

    return $container.CloudBlobContainer.Uri.AbsoluteUri
}

function _getBacpacName {
    param(
        [string] $DatabaseName
    )

    if ([string]::IsNullOrEmpty($DatabaseName)) {
        return "-$(Get-Date -UFormat %Y-%m-%d-%H-%M).bacpac"
    } else {
        return "$DatabaseName-$(Get-Date -UFormat %Y-%m-%d-%H-%M).bacpac"
    }
}

function _clearDefaults {
    $env:PSDB_RESOURCEGROUPNAME = $null
    $env:PSDB_RESOURCEGROUPS = $null
    $env:PSDB_SQLSERVERS = $null
    # $env:PSDB_STORAGEACCOUNTS = $null
    $env:PSDB_DATABASES = $null
    $env:PSDB_SUBSCRIPTION = $null
    # $env:PSDB_SUBSCRIPTIONS = $null
}

function _getLatestBacPacFile {
    param (
        [string] $StorageAccountName,
        [string] $StorageContainerName
    )

    $key = _getStorageAccountKey -StorageAccountName $StorageAccountName
    $context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $key
    $blob = Get-AzStorageBlob -Blob "*.bacpac" -Container $StorageContainerName -Context $context

    return ($blob | Sort-Object -Descending | Select-Object -First 1).Name
}

function _convertToPlainText {
    param (
        [securestring] $Password
    )

    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
}

function _containerValidation {
    param (
        [string] $StorageAccountName,
        [string] $StorageContainerName
    )

    $validated = $false
    
    #Container validation
    try {
        $Context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey (_getStorageAccountKey $StorageAccountName)
        $container = Get-AzStorageContainer -Name $StorageContainerName -Context $Context -ErrorAction SilentlyContinue
        if (-not ([string]::IsNullOrEmpty($container))) { $validated = $true } else { $validated = $false }
    }
    catch {
        $validated = $false
    }

    return $validated   
}