
$displayName   = "jp-demo-to-delete"
$identifierUri = "api://$displayName"
$appRegistration = az ad app create --display-name $displayName
write-output "New application creation is completed. Pausing the process for 20s to allow the application creation to be completed."
sleep 20

$app   = $appRegistration | ConvertFrom-Json
$appId = $app.appId
				
write-output "Updating the identifier-uri of the application."
az ad app update --id $appId --identifier-uris $identifierUri
sleep 10

$appJson = (az ad app show --id="$identifierUri") | ConvertFrom-Json

# -------------------------------------------------------------------------------------------- #
# List all applications list via graph api - GET https://graph.microsoft.com/v1.0/applications #
# -------------------------------------------------------------------------------------------- #
$uri = "https://graph.microsoft.com/v1.0/applications"

$allApplications = az rest `
   --method GET `
   --uri $uri `
   --headers 'Content-Type=application/json' | convertfrom-json

$allApplications.value |% {"{0}-{1}" -f $_.appid, $_.displayname}

# ------------------------------------------------------------------------------------------------- #
# Get an application details via graph api - GET https://graph.microsoft.com/v1.0/applications/{id} #
# ------------------------------------------------------------------------------------------------- #
$uri = "https://graph.microsoft.com/v1.0/applications/{id}"
$uri = $uri -replace "{id}", $appJson.objectId

$application = az rest `
   --method GET `
   --uri $uri `
   --headers 'Content-Type=application/json' | convertfrom-json
   
# ------------------------------------------------------------------------------- #
# Delete an application DELETE https://graph.microsoft.com/v1.0/applications/{id} #
# ------------------------------------------------------------------------------- #
# windows powershell equivalent: Remove-AzureADApplication
$uri = "https://graph.microsoft.com/v1.0/applications/{id}"
$uri = $uri -replace "{id}", $appJson.objectId

az rest `
   --method DELETE `
   --uri $uri `
   --headers 'Content-Type=application/json'

# ------------------------------------------------------------------------------------------------------------------------ #
# List all the deleted application GET https://graph.microsoft.com/v1.0/directory/deletedItems/microsoft.graph.application #
# ------------------------------------------------------------------------------------------------------------------------ #
# windows powershell equivalent : Get-AzureADDeletedApplication
$uri = "https://graph.microsoft.com/v1.0/directory/deletedItems/microsoft.graph.application"

$allApplicationsDeleted = az rest `
   --method GET `
   --uri $uri `
   --headers 'Content-Type=application/json' | convertfrom-json
$allApplicationsDeleted.value.displayName

# ----------------------------------------------------------------------------------------------------------------- #
# Delete applications which are deleted, DELETE https://graph.microsoft.com/v1.0/directory/deletedItems/{object-id} #
# ----------------------------------------------------------------------------------------------------------------- #
# windows powershell equivalent : Remove-AzureADDeletedApplication
$objectIdToPermanentlyDelete = $allApplicationsDeleted.value[0].id
$uri = "https://graph.microsoft.com/v1.0/directory/deletedItems/{object-id}"
$uri = $uri -replace "{object-id}", $objectIdToPermanentlyDelete

az rest `
   --method DELETE `
   --uri $uri `
   --headers 'Content-Type=application/json'
