# reference: https://thomasthornton.cloud/2020/10/06/query-azure-sql-database-using-service-principal-with-powershell/

# pre-requisites (not included below)
# 1: az ad sp create-for-rbac --skip-assignment --name <spn-name>
#    a) Creating a new application registration in the azure ad tenant.
#    b) Generate the client secret for the application registration.
# 2: Assign the API permission, azure sql database (application permission)
# 3: Assign this SPN access to the azure sql database. Create user [] from external provider, Assign a database role.


# declare and assign values to variables
$tenantName       = '<azure-ad-tenant-name>.onmicrosoft.com'
$tenantId         = 'xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' # tenant id of the azure ad
$clientId         = 'xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' # app registration id aka client id
$clientSecret     = 'blah-blah-blah'                      # client password
$sqlServerUrl     = "azure-sql-server-name.database.windows.net"
$database         = "database-name"
$query            = "select * from table"
$connectionString = "Server=tcp:$sqlServerUrl,1433;Initial Catalog=$database;Connect Timeout=30"

# get the access token
$accessTokenJson = curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "client_id=$clientId&scope=https%3A%2F%2Fdatabase.windows.net%2F.default&client_secret=$clientSecret&grant_type=client_credentials" "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" | convertfrom-json
$accessToken = $accessTokenJson.access_token

# declare the sqlclient connection objects
$sqlConnection                  = New-Object System.Data.SqlClient.SqlConnection                
$sqlCmd                         = New-Object System.Data.SqlClient.SqlCommand
$sqlAdapter                     = New-Object System.Data.SqlClient.SqlDataAdapter

$sqlConnection.ConnectionString = $connectionString
$sqlConnection.AccessToken      = $accessToken
$sqlConnection.Open()
$sqlCmd.Connection              = $sqlConnection 
$sqlCmd.CommandText             = $query

$sqlAdapter.SelectCommand       = $sqlCmd
$dataSet                        = New-Object System.Data.DataSet
$sqlAdapter.Fill($dataSet)
$dataSet.Tables[0].Rows
        
# finally
$sqlAdapter.Dispose()
$sqlCmd.Dispose()
$sqlConnection.Dispose()
	
