param([Parameter(Mandatory=$false)] [string] $resourceGroup = "fanguru-rg",
        [Parameter(Mandatory=$false)] [string] $location = "centralindia",
        [Parameter(Mandatory=$false)] [string] $fanguruVNetName= "fanguruvnet",
        [Parameter(Mandatory=$false)] [string] $fanguruVNetPrefix ="173.0.0.0/16",
        [Parameter(Mandatory=$false)] [string] $appgwSubnetName = "appgwsubnet",
        [Parameter(Mandatory=$false)] [string] $appgwSubnetPrefix= "173.0.4.0/27",
        [Parameter(Mandatory=$false)] [string] $apimSubnetName = "apimsubnet",
        [Parameter(Mandatory=$false)] [string] $apimSubnetPrefix = "173.0.5.0/27",
        [Parameter(Mandatory=$false)] [string] $networkTemplateFileName = "fanguru-network-deploy",
        [Parameter(Mandatory=$false)] [string] $subscriptionId = "67aa1a6a-7473-46e2-aec6-d27892dfa9ba",
        [Parameter(Mandatory=$false)] [string] $baseFolderPath = "C:\Users\ban\Documents\fanguru\Deployments",
        [Parameter(Mandatory=$false)] [string] $storageaccname1 = "fangurustrgac1",
        [Parameter(Mandatory=$false)] [string] $storageaccname2 = "fangurustrgac2",
        [Parameter(Mandatory=$false)] [string] $storageaccname3 = "fangurustrgac3",
        [Parameter(Mandatory=$false)] [string] $StorageSkuName = "Standard_LRS",
        [Parameter(Mandatory=$false)] [string] $Storagekind = "StorageV2",
        [Parameter(Mandatory=$false)] [string] $storageAccessTier  = "Hot",
        [Parameter(Mandatory=$false)] [string] $appinsightsname1 = "fanguruappinsight1",
        [Parameter(Mandatory=$false)] [string] $appinsightskind = "web",
        [Parameter(Mandatory=$false)] [string] $WorkspaceName = "fanguruwk",
        [Parameter(Mandatory=$false)] [string] $LASku = "pergb2018",
        [Parameter(Mandatory=$false)] [string] $functionAppName1  = "functionappstg",
        [Parameter(Mandatory=$false)] [string] $functionAppName2   = "functionappdevkjkjkjnk",
        [Parameter(Mandatory=$false)] [string] $functionAppName3   = "functionappuatjjkljj",
        [Parameter(Mandatory=$false)] [string] $appServicePlanName1 = "fanguruappplan1",
        [Parameter(Mandatory=$false)] [string] $appServicePlanName2 = "fanguruappplan2",
        [Parameter(Mandatory=$false)] [string] $appServicePlanName3 = "fanguruappplan3",
        [Parameter(Mandatory=$false)] [string] $appinsightsname  = "fanguruappinsight1",
        [Parameter(Mandatory=$false)] [string] $OSType = "Windows",
        [Parameter(Mandatory=$false)] [string] $SKU1 = "S2",
        [Parameter(Mandatory=$false)] [string] $SKU2 = "Y1",
        [Parameter(Mandatory=$false)] [string] $runtime = "Dotnet",
        [Parameter(Mandatory=$false)] [string] $funappruntimeverison = "3",
        [Parameter(Mandatory=$false)] [string] $dotnetruntimeverison = "3",
        [Parameter(Mandatory=$false)] [string] $adminSqlLogin = "SqlAdmin",
        [Parameter(Mandatory=$false)] [SecureString] $password = "P@ssw0rd@123",
        [Parameter(Mandatory=$false)] [string] $serverName="fanguru-sql-svr" ,
        [Parameter(Mandatory=$false)] [string] $databaseName = "mydatdbase",
        [Parameter(Mandatory=$false)] [string] $CatalogCollation = "SQL_Latin1_General_CP1_CI_AS",
        [Parameter(Mandatory=$false)] [string] $SQlMaxSizeBytes = 32GB)            

$templatesFolderPath = $baseFolderPath + "/Templates"

# Assuming Logged In


$networkNames = "-fanguruVNetName $fanguruVNetName -fanguruVNetPrefix $fanguruVNetPrefix -appgwSubnetName $appgwSubnetName -appgwSubnetPrefix $appgwSubnetPrefix -apimSubnetName $apimSubnetName -apimSubnetPrefix $apimSubnetPrefix"
$networkDeployCommand = "/Network/$networkTemplateFileName.ps1 -rg $resourceGroup -fpath $templatesFolderPath -deployFileName $networkTemplateFileName $networkNames"

# PS Select Subscriotion 
Select-AzSubscription -SubscriptionId $subscriptionId

$rgRef = Get-AzResourceGroup -Name $resourceGroup -Location $location
if (!$rgRef)
{

   $rgRef = New-AzResourceGroup -Name $resourceGroup -Location $location
   if (!$rgRef)
   {
        Write-Host "Error creating Resource Group"
        return;
   }

}

$networkDeployPath = $templatesFolderPath + $networkDeployCommand
Invoke-Expression -Command $networkDeployPath

##Storage acc create
$storageAcc1 = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageaccname1

if (!$storageAcc1)
{

   $storageAcc1 = New-AzStorageAccount -ResourceGroupName $resourceGroup -AccountName $storageaccname1 -Location $location -SkuName $StorageSkuName -Kind $Storagekind -AccessTier $storageAccessTier

   if (!$storageAcc1)
   {
        Write-Host "Error creating Storage acc1"
        return;
   }

}
$storageAcc1

$storageAcc2 = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageaccname2

if (!$storageAcc2)
{

   $storageAcc2 = New-AzStorageAccount -ResourceGroupName $resourceGroup -AccountName $storageaccname2 -Location $location -SkuName $StorageSkuName -Kind $Storagekind -AccessTier $storageAccessTier


   if (!$storageAcc2)
   {
        Write-Host "Error creating Storage acc2"
        return;
   }

}
$storageAcc2

$storageAcc3 = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageaccname3

if (!$storageAcc3)
{

   $storageAcc3 = New-AzStorageAccount -ResourceGroupName $resourceGroup -AccountName $storageaccname3 -Location $location -SkuName $StorageSkuName -Kind $Storagekind -AccessTier $storageAccessTier


   if (!$storageAcc3)
   {
        Write-Host "Error creating Storage acc3"
        return;
   }

}
$storageAcc3

## App insights create 

$appinsights1 = Get-AzApplicationInsights -Name $appinsightsname1 -ResourceGroupName $resourceGroup

if (!$appinsights1)
{

   $appinsights1 = New-AzApplicationInsights -Name $appinsightsname1 -ResourceGroupName $resourceGroup -Kind $appinsightskind -Location $location



   if (!$appinsights1)
   {
        Write-Host "Error creating appinsights1"
        return;
   }

}
$appinsights1

# # Create the workspace if needed
try {
        Get-AzOperationalInsightsWorkspace -Name $WorkspaceName -ErrorAction Stop
    } catch {
       $LA = New-AzOperationalInsightsWorkspace -Location $location -Name $WorkspaceName -Sku $LASku -ResourceGroupName $resourceGroup
    }
    
    $LA

## create an Appservice Plan

    $appsvrplan = Get-AzResource -ResourceGroupName $resourceGroup -Name $appServicePlanName1

    if(-not $appsvrplan) {
    New-AzResource -ResourceGroupName $resourceGroup  -Location $location -ResourceType microsoft.web/serverfarms -ResourceName $appServicePlanName1 -Sku @{name="S2";tier="Standard"; size="S2"; family="S"; capacity="2"}
    }
    else {
    Write-Host "Errorcreating an App service plan"
    }

    ## First function app create
    $azFuncapp = Get-AzFunctionApp -ResourceGroupName $resourceGroup -Name $functionAppName1

    if(-not $azFuncapp) {
    
    New-AzFunctionApp -Name $functionAppName1 -PlanName $appServicePlanName1 -StorageAccountName $storageaccname1 -OSType $OSType -Runtime $runtime -RuntimeVersion $dotnetruntimeverison  -ResourceGroupName $resourceGroup -ApplicationInsightsName $appinsightsname -FunctionsVersion $funappruntimeverison
    ## Second app service plan & function app create
    }
    else {
    Write-Host "Errorcreating a Function app1"
    }
    
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
        #$plan.PSObject.Properties   
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
        
       # New-AzFunctionApp -Name $functionAppName2 -PlanName $appServicePlanName2 -StorageAccountName $storageaccname1 -OSType $OSType -Runtime $runtime -ResourceGroupName $resourceGroup -ApplicationInsightsName $appinsightsname -FunctionsVersion $funappruntimeverison  

        New-AzResource -ResourceType 'Microsoft.Web/Sites' -ResourceName $functionAppName2 -kind 'functionapp' -Location $location -resourceGroup $resourceGroup -Properties $props  -force
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

    Set-AzWebApp -Name $functionAppName2 -resourceGroup $resourceGroup -AppSettings $AppSettings
    
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

    ## AZ Sql server & daabase create
   # Create a server with a system wide unique server name
$server = New-AzSqlServer -ResourceGroupName $resourceGroupName `
-ServerName $serverName `
-Location $location `
-SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminSqlLogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force))

# Create a blank database with an S0 performance level
$database = New-AzSqlDatabase  -ResourceGroupName $resourceGroupName  -ServerName $serverName -DatabaseName $databaseName -CatalogCollation $CatalogCollation -MaxSizeBytes $SQlMaxSizeBytes
    
Write-Host "Infra-steup Successfully Done!"