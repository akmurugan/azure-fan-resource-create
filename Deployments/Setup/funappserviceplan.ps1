
param(
    [Parameter(Mandatory=$false)] [string]  $resourceGroup     ="fanguru-rg",
    [Parameter(Mandatory=$false)] [string]  $storageaccname1  = "fangurustrgac1",
    [Parameter(Mandatory=$false)] [string]  $functionAppName1  = "functionappstg",
    [Parameter(Mandatory=$false)] [string]  $functionAppName2   = "functionappdev",
    [Parameter(Mandatory=$false)] [string]  $functionAppName3   = "functionappuat",
    [Parameter(Mandatory=$false)] [string]  $appServicePlanName1 = "fanguruappplan1",
    [Parameter(Mandatory=$false)] [string]  $appServicePlanName2 = "fanguruappplan2",
    [Parameter(Mandatory=$false)] [string]  $appServicePlanName3 = "fanguruappplan3",
    [Parameter(Mandatory=$false)] [string]  $location            = "centralindia",
    [Parameter(Mandatory=$false)] [string]  $appinsightsname  = "fanguruappinsight1",
    [Parameter(Mandatory=$false)] [string]  $OSType = "Windows",
    [Parameter(Mandatory=$false)] [string]  $SKU1 = "S2",
    [Parameter(Mandatory=$false)] [string]  $SKU2 = "Y1",
    [Parameter(Mandatory=$false)] [string]  $runtime = "Dotnet",
    [Parameter(Mandatory=$false)] [string]  $funappruntimeverison = "3",
    [Parameter(Mandatory=$false)] [string]  $dotnetruntimeverison = "3"
    )

    ## create an Appservice Plan

    New-AzResource -ResourceGroupName $resourceGroup  -Location $location -ResourceType microsoft.web/serverfarms -ResourceName $appServicePlanName1 -Sku @{name="S2";tier="Standard"; size="S2"; family="S"; capacity="2"}
    
    ## First function app create
    New-AzFunctionApp -Name $functionAppName1 -PlanName $appServicePlanName1 -StorageAccountName $storageaccname1 -OSType $OSType -Runtime $runtime -RuntimeVersion $dotnetruntimeverison  -ResourceGroupName $resourceGroup -ApplicationInsightsName $appinsightsname -FunctionsVersion $funappruntimeverison
    ## Second app service plan & function app create

    $SkuName = "Y1"
    $SkuTier = "Dynamic"
    $WebAppApiVersion = "2015-08-01"

    $fullObject = @{
        location = $location
        sku = @{
            name = $SkuName
            tier = $SkuTier 
        }
    }
    Write-Host "Ensuring the $appServicePlanName2 app service plan exists"

    $plan = Get-AzAppServicePlan -Name $appServicePlanName2 -resourceGroup $resourceGroup -ErrorAction SilentlyContinue
    if(-not $plan) {
        Write-Host "Creating $appServicePlanName2 app service plan"
        New-AzResource -resourceGroup $resourceGroup -ResourceType Microsoft.Web/serverfarms -Name $appServicePlanName2 -IsFullObject -PropertyObject $fullObject -ApiVersion $WebAppApiVersion -Force
    }
    else {
        Write-Host "$appServicePlanName2 app service plan already exists"   
    }

$plan

    [String]$planId = ''

    $plan = Get-AzAppServicePlan -Name $appServicePlanName2 -resourceGroup $resourceGroup -ErrorAction SilentlyContinue
    if(-not $plan) {
        throw [System.ArgumentOutOfRangeException] "Missing App Service Plan.  (resourceGroup='$resourceGroup', AppServicePlan.Name = '$appServicePlanName2')"
    }
    else {
        Write-Host "START AzAppServicePlan Properties"   
        $plan.PSObject.Properties   
        Write-Host "END AzAppServicePlan Properties"   

        #get the planId, so that can be used as the backing-app-service-plan for this AppService
        [String]$planId = $plan.Id
    }

    #wire up the necessary properties for this AppService
    $props = @{
        ServerFarmId = $planId
        }


    $functionAppResource = Get-AzResource | Where-Object { $_.ResourceName -eq $functionAppName2 -And $_.ResourceType -eq 'Microsoft.Web/Sites' }

    if ($functionAppResource -eq $null)
    {
        
        New-AzFunctionApp -Name $functionAppName1 -PlanName $appServicePlanName2 -StorageAccountName $storageaccname1 -OSType $OSType -Runtime $runtime -ResourceGroupName $resourceGroup -ApplicationInsightsName $appinsightsname -FunctionsVersion $funappruntimeverison  

        #New-AzResource -ResourceType 'Microsoft.Web/Sites' -ResourceName $functionAppName2 -kind 'functionapp' -Location $location -resourceGroup $resourceGroup -Properties $props -force
    }    


    $azStorageAccountGetCheck = Get-AzStorageAccount -resourceGroup $resourceGroup -AccountName $storageaccname1 -ErrorAction SilentlyContinue

    if(-not $azStorageAccountGetCheck) 
    {
        New-AzStorageAccount -resourceGroup $resourceGroup -AccountName $storageaccname1 -Location $location -SkuName 'Standard_LRS'
    }
    else 
    {
        Write-Host "$storageaccname1 storage account already exists"
    }    
  
    $keys = Get-AzStorageAccountKey -resourceGroup $resourceGroup -AccountName $storageaccname1

    $accountKey = $keys | Where-Object { $_.KeyName -eq "Key1" } | Select Value

    $storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=' + $storageaccname1 + ';AccountKey=' + $accountKey.Value

    $appinsignts = Get-AzResource -Name $appinsightsname -ResourceType "Microsoft.Insights/components"

    $appinsightsresource =  Get-AzResource -ResourceId $appinsignts.ResourceId

    $appInsightsKey = $appinsightsresource.Properties.InstrumentationKey
    
    $appInsightsconnectionstring = $appInsightsKey = $appinsightsresource.Properties.ConnectionString 

    $AppSettings = @{}

    $AppSettings = @{
        
    'AzureWebJobsDashboard' = $storageAccountConnectionString;

    'AzureWebJobsStorage' = $storageAccountConnectionString;

    'FUNCTIONS_EXTENSION_VERSION' = '~3';

    'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING' = $storageAccountConnectionString;

    'WEBSITE_CONTENTSHARE' = $storageaccname1;

    'APPINSIGHTS_INSTRUMENTATIONKEY' = $appInsightsKey

    'APPLICATIONINSIGHTS_CONNECTION_STRING' = $appInsightsconnectionstring

}

    Set-AzWebApp -Name $functionAppName -resourceGroup $resourceGroup -AppSettings $AppSettings
    
    Update-AzFunctionApp -Name $functionAppName2 -ResourceGroupName $resourceGroup -ApplicationInsightsName $appinsightsname

    ## Third app service plan & function app create
    $SkuName = "Y1"
    $SkuTier = "Dynamic"
    $WebAppApiVersion = "2015-08-01"

    $fullObject = @{
        location = $location
        sku = @{
            name = $SkuName
            tier = $SkuTier 
        }
    }
    Write-Host "Ensuring the $appServicePlanName3 app service plan exists"

    $plan = Get-AzAppServicePlan -Name $appServicePlanName3 -resourceGroup $resourceGroup -ErrorAction SilentlyContinue
    if(-not $plan) {
        Write-Host "Creating $appServicePlanName3 app service plan"
        New-AzResource -resourceGroup $resourceGroup -ResourceType Microsoft.Web/serverfarms -Name $appServicePlanName3 -IsFullObject -PropertyObject $fullObject -ApiVersion $WebAppApiVersion -Force
    }
    else {
        Write-Host "$appServicePlanName3 app service plan already exists"   
    }

$plan

    [String]$planId = ''

    $plan = Get-AzAppServicePlan -Name $appServicePlanName3 -resourceGroup $resourceGroup -ErrorAction SilentlyContinue
    if(-not $plan) {
        throw [System.ArgumentOutOfRangeException] "Missing App Service Plan.  (resourceGroup='$resourceGroup', AppServicePlan.Name = '$appServicePlanName3')"
    }
    else {
        Write-Host "START AzAppServicePlan Properties"   
        $plan.PSObject.Properties   
        Write-Host "END AzAppServicePlan Properties"   

        #get the planId, so that can be used as the backing-app-service-plan for this AppService
        [String]$planId = $plan.Id
    }

    #wire up the necessary properties for this AppService
    $props = @{
        ServerFarmId = $planId
        }


    $functionAppResource = Get-AzResource | Where-Object { $_.ResourceName -eq $functionAppName3 -And $_.ResourceType -eq 'Microsoft.Web/Sites' }

    if ($functionAppResource -eq $null)
    {
        New-AzResource -ResourceType 'Microsoft.Web/Sites' -ResourceName $functionAppName3 -kind 'functionapp' -Location $location -resourceGroup $resourceGroup -Properties $props -force
    }    


    $azStorageAccountGetCheck = Get-AzStorageAccount -resourceGroup $resourceGroup -AccountName $storageaccname1 -ErrorAction SilentlyContinue

    if(-not $azStorageAccountGetCheck) 
    {
        New-AzStorageAccount -resourceGroup $resourceGroup -AccountName $storageaccname1 -Location $location -SkuName 'Standard_LRS'
    }
    else 
    {
        Write-Host "$storageaccname1 storage account already exists"
    }    
  
    $keys = Get-AzStorageAccountKey -resourceGroup $resourceGroup -AccountName $storageaccname1

    $accountKey = $keys | Where-Object { $_.KeyName -eq "Key1" } | Select Value

    $storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=' + $storageaccname1 + ';AccountKey=' + $accountKey.Value

    $appinsignts = Get-AzResource -Name $appinsightsname -ResourceType "Microsoft.Insights/components"

    $appinsightsresource =  Get-AzResource -ResourceId $appinsignts.ResourceId

    $appInsightsKey = $appinsightsresource.Properties.InstrumentationKey
    $appInsightsconnectionstring = $appInsightsKey = $appinsightsresource.Properties.ConnectionString 

    $AppSettings = @{}

    $AppSettings = @{
        
    'AzureWebJobsDashboard' = $storageAccountConnectionString;

    'AzureWebJobsStorage' = $storageAccountConnectionString;

    'FUNCTIONS_EXTENSION_VERSION' = '~3';

    'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING' = $storageAccountConnectionString;

    'WEBSITE_CONTENTSHARE' = $storageaccname1;

    'APPINSIGHTS_INSTRUMENTATIONKEY' = $appInsightsKey

    'APPLICATIONINSIGHTS_CONNECTION_STRING' = $appInsightsconnectionstring

}

    Set-AzWebApp -Name $functionAppName3 -resourceGroup $resourceGroup -AppSettings $AppSettings
    
    Update-AzFunctionApp -Name $functionAppName3 -ResourceGroupName $resourceGroup -ApplicationInsightsName $appinsightsname