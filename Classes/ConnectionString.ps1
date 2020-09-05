using namespace System.Text;

# This class attribute helps to create connection string for connection Azure Sql database.
# More information on how to form or create a connection string can be found at
# https://www.connectionstrings.com/
class PSDBConnectionString
{
    static [int] $PortNumber = 1433
    static [bool] $TrustedConnection = $false
    static [bool] $Encrypt = $true
    static [bool] $MultipleActiveResultSets = $true
    static [bool] $IntegratedSecurity = $true
    static [string] $ColumnEncryptionSetting = "enabled"

    PSDBConnectionString() {}

    # constructs the standard connection string for Azure Sql
    [string] BuildConnectionString ([string] $Server, [string] $Database, [string] $UserID, [string] $Pswd)
    {
        [StringBuilder] $StringBuilder = [StringBuilder]::new()
        $StringBuilder.Append("Server=tcp:$($Server),$([PSDBConnectionString]::PortNumber);") > $null
        $StringBuilder.Append("Database=$($Database);") > $null
        $StringBuilder.Append("User ID=$($UserID)@$($Server);") > $null
        $StringBuilder.Append("Password=$($Pswd);") > $null
        $StringBuilder.Append("Trusted_Connection=$([PSDBConnectionString]::TrustedConnection);") > $null
        $StringBuilder.Append("Encrypt=$([PSDBConnectionString]::Encrypt);") > $null

        return $StringBuilder.ToString()
    }

    # with MARS Enabled
    [string] BuildConnectionString ([string] $Server, [string] $Database, [string] $UserID, [string] $Pswd, [bool] $MultipleActiveResultSets = $true)
    {
        [StringBuilder] $StringBuilder = [StringBuilder]::new()
        $StringBuilder.Append("Server=tcp:$($Server),$([PSDBConnectionString]::PortNumber);") > $null
        $StringBuilder.Append("Database=$($Database);") > $null
        $StringBuilder.Append("User ID=$($UserID)@$($Server);") > $null
        $StringBuilder.Append("Password=$($Pswd);") > $null
        $StringBuilder.Append("Trusted_Connection=$([PSDBConnectionString]::TrustedConnection);") > $null
        $StringBuilder.Append("Encrypt=$([PSDBConnectionString]::Encrypt);") > $null
        $StringBuilder.Append("MultipleActiveResultSets=$($MultipleActiveResultSets);") > $null

        return $StringBuilder.ToString()
    }

    # Integrated with Azure AD
    [string] BuildConnectionString ([string] $Server, [string] $Database, [string] $Authentication)
    {
        [StringBuilder] $StringBuilder = [StringBuilder]::new()
        $StringBuilder.Append("Server=tcp:$($Server),$([PSDBConnectionString]::PortNumber);") > $null
        $StringBuilder.Append("Authentication=$($Authentication);") > $null
        $StringBuilder.Append("Database=$($Database);") > $null

        return $StringBuilder.ToString()
    }

    # Integrated with Azure AD; with username and password
    [string] BuildConnectionString ([string] $Server, [string] $Database, [string] $Authentication, [string] $UserID, [string] $Pswd, [string] $Domain)
    {
        [StringBuilder] $StringBuilder = [StringBuilder]::new()
        $StringBuilder.Append("Server=tcp:$($Server),$([PSDBConnectionString]::PortNumber);") > $null
        $StringBuilder.Append("Authentication=$($Authentication);") > $null
        $StringBuilder.Append("Database=$($Database);") > $null
        $StringBuilder.Append("UID=$($UserID)@$($Domain);") > $null
        $StringBuilder.Append("Password=$($Pswd);") > $null

        return $StringBuilder.ToString()
    }

    # with always encrypted
    [string] BuildConnectionString ([string] $DataSource, [string] $InitialCatalog, [bool] $IntegratedSecurity = $true, [string] $ColumnEncryptionSetting = "enabled")
    {
        [StringBuilder] $StringBuilder = [StringBuilder]::new()
        $StringBuilder.Append("Data Source=$($DataSource);") > $null
        $StringBuilder.Append("Initial Catalog=$($InitialCatalog);") > $null
        $StringBuilder.Append("Integrated Security=$($IntegratedSecurity);") > $null
        $StringBuilder.Append("Column Encryption Setting=$($ColumnEncryptionSetting);") > $null

        return $StringBuilder.ToString()
    }
}