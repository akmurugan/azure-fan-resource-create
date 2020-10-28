param(
     [Parameter(Mandatory=$false)] [string]$resourceGroup ="fanguru-rg",
     [Parameter(Mandatory=$false)] [string]$storageAccount = "stgacc1",
     [Parameter(Mandatory=$false)] [string]$subscriptionId  = "67aa1a6a-7473-46e2-aec6-d27892dfa9ba",
     [Parameter(Mandatory=$false)] [string]$functionAppName = "functionapp1",
     [Parameter(Mandatory=$false)] [string]$appInsightsName = "cartis-stg-appinsights",
     [Parameter(Mandatory=$false)] [string]$appServicePlanName = "functionappplan1",
     [Parameter(Mandatory=$false)] [string]$tier = "consumption",
     [Parameter(Mandatory=$false)] [string]$location = "centralindia"
     )
 

 

#selecting default azure subscription by name
Select-AzSubscription -SubscriptionId "$subscriptionId"

 

#========Creating App Service Plan============

 

New-AzAppServicePlan -ResourceGroupName $resourceGroup -Name $appServicePlanName -Location $location -Tier $tier

 

#========Creating Azure Storage Account========

 

 $checkexstingstgacc = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageaccname
 if (!$checkexstingstgacc)
{
  New-AzStorageAccount -ResourceGroupName $resourceGroup -AccountName $storageAccount -Location $location -SkuName "Standard_LRS"
 
 if (!$checkexstingstgacc)
   {
        Write-Host "Error creating Storage account"
        return;
   }

 

}

 

$functionAppSettings = @{
    ServerFarmId="/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.Web/serverfarms/$appServicePlanName";
    alwaysOn=$True;
}

 

#========Creating Azure Function========

 

$functionAppResource = Get-AzResource | Where-Object { $_.ResourceName -eq $functionAppName -And $_.ResourceType -eq "Microsoft.Web/Sites" }
if ($functionAppResource -eq $null)
{
  New-AzResource -ResourceType 'Microsoft.Web/Sites' -ResourceName $functionAppName -kind 'functionapp' -Location $location -ResourceGroupName $resourceGroup -Properties $functionAppSettings -force
}

 

#========Creating AppInsight Resource========

 

New-AzApplicationInsights -ResourceGroupName $resourceGroup -Name $appInsightsName -Location $location
$resource = Get-AzResource -Name $appInsightsName -ResourceType "Microsoft.Insights/components"
$details = Get-AzResource -ResourceId $resource.ResourceId
$appInsightsKey = $details.Properties.InstrumentationKey