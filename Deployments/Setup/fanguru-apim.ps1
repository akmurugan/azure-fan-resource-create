param([Parameter(Mandatory=$false)] [string]$resourceGroup ="fanguru-rg1",
      [Parameter(Mandatory=$false)] [string]$cartisVNetName ="fanguruvnet",
      [Parameter(Mandatory=$false)] [string]$apimname = "fanguruapim",
      [Parameter(Mandatory=$false)] [string]$location ="centralindia",
      [Parameter(Mandatory=$false)] [string]$apimsku = "Developer",  
      [Parameter(Mandatory=$false)] [string]$apimOrganization = "fanguru",
      [Parameter(Mandatory=$false)] [string]$apimAdminEmail = "shreyas.pd@sysfore.com",
      [Parameter(Mandatory=$false)] [string]$SubscriptionId = "67aa1a6a-7473-46e2-aec6-d27892dfa9ba" )
     
 
$selectsubscription = Select-AzSubscription -SubscriptionId $SubscriptionId


$vn = (Get-AzVirtualNetwork -Name $fanguruVNetName -ResourceGroupName $resourceGroup)

 $apimVirtualNetwork =   $vn.Subnets[1]

 $apimVirtualNetwork.Id

#create api management instance with required parameters

$apimVirtualNetwork1 = New-AzApiManagementVirtualNetwork -SubnetResourceId  $apimVirtualNetwork.Id

$apimService = New-AzApiManagement -ResourceGroupName $resourceGroup -Location $location -Name $apimname -Organization $apimOrganization -AdminEmail $apimAdminEmail -Sku "$apimsku" -VirtualNetwork $apimVirtualNetwork1 -VpnType Interna