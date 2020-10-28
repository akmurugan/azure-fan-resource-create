param([Parameter(Mandatory=$false)] [string]    $resourceGroup = "fanguru-rg",
        [Parameter(Mandatory=$false)] [string]  $appplanname1 = "fanguruappplan1",
        [Parameter(Mandatory=$false)] [string]  $appplanname2 = "fanguruappplan2",
        [Parameter(Mandatory=$false)] [string]  $appplanname3 = "fanguruappplan3",
        [Parameter(Mandatory=$false)] [string]  $funappname1 = "fanguruapp1",
        [Parameter(Mandatory=$false)] [string]  $funappname2 = "fanguruapp2",
        [Parameter(Mandatory=$false)] [string]  $funappname3 = "fanguruapp3",
        [Parameter(Mandatory=$false)] [string]  $OSType = "Windows",
        [Parameter(Mandatory=$false)] [string]  $SKU1 = "S2",
        [Parameter(Mandatory=$false)] [string]  $SKU2 = "Y1",
        [Parameter(Mandatory=$false)] [string]  $runtime = "dotnet",
        [Parameter(Mandatory=$false)] [string]  $storageaccname1 = "fangurustrgac1",
        [Parameter(Mandatory=$false)] [string]  $appinsightsname1 = "fanguruappinsight1",
        [Parameter(Mandatory=$false)] [string]  $funappruntimeverison = "3",
        [Parameter(Mandatory=$false)] [string]  $subscriptionId = "67aa1a6a-7473-46e2-aec6-d27892dfa9ba" )

## Create an app service plan. 
 az appservice plan create `
 --resource-group $resourceGroup `
 --name $appplanname1 `
 --location $location `
 --sku S2 `
 --number-of-workers 2
 

## Crean an Azure function app
az functionapp create --name $funappname1 --resource-group $resourceGroup `
--storage-account $storageaccname1 --app-insights $appinsightsname1  `
--consumption-plan-location $  $appplanname1 --disable-app-insights false `
--functions-version $funappruntimeverison --os-type $OSType  `
--runtime $runtime --subscription $subscriptionId 

az functionapp create --name $funappname2 --resource-group $resourceGroup `
--storage-account $storageaccname1 --app-insights $appinsightsname1  `
--plan $appplanname2 --disable-app-insights false `
--functions-version $funappruntimeverison --os-type $OSType  `
--runtime $runtime --subscription $subscriptionId 

az functionapp create --name $funappname3 --resource-group $resourceGroup `
--storage-account $storageaccname1 --app-insights $appinsightsname1  `
--plan $appplanname3 --disable-app-insights false `
--functions-version $funappruntimeverison --os-type $OSType  `
--runtime $runtime --subscription $subscriptionId 

az resource create `
    --resource-group $resourceGroup `
    --name myconsumptionplan `
    --resource-type Microsoft.web/serverfarms `
    --is-full-object `
    --properties "{\"location\":\"northeurope\",\"sku\":{\"name\":\"Y1\",\"tier\":\"Dynamic\"}}"