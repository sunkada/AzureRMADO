param([Parameter(Mandatory=$true)]   [string] $resourceGroup,
        [Parameter(Mandatory=$true)] [string] $vnetResourceGroup,
        [Parameter(Mandatory=$true)] [string] $vnetName,
        [Parameter(Mandatory=$true)] [string] $subnetName,
        [Parameter(Mandatory=$true)] [string] $pepName,
        [Parameter(Mandatory=$true)] [string] $pepConnectionName,
        [Parameter(Mandatory=$true)] [string] $pepResourceName,
        [Parameter(Mandatory=$true)] [string] $pepResourceType,
        [Parameter(Mandatory=$true)] [string] $pepSubResourceId,
        [Parameter(Mandatory=$true)] [string] $pepTemplateFileName,
        [Parameter(Mandatory=$true)] [string] $baseFolderPath)

$templatesFolderPath = $baseFolderPath + "\Templates\DEV"

$vnet = Get-AzVirtualNetwork -ResourceGroupName $vnetResourceGroup `
-Name $vnetName

$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet `
-Name $subnetName
$subnet.PrivateEndpointNetworkPolicies = "Disabled"
$subnet.PrivateLinkServiceNetworkPolicies = "Enabled"

$vnet = Set-AzVirtualNetworkSubnetConfig -Name $subnetName `
-VirtualNetwork $vnet -AddressPrefix $subnet.AddressPrefix[0]

Set-AzVirtualNetwork -VirtualNetwork $vnet

$pepNames = "-privateEndpointName $pepName -privateEndpointConnectionName $pepConnectionName -pepResourceType $pepResourceType -pepResourceName $pepResourceName -subResourceId $pepSubResourceId"
$pepDeployCommand = "/Network/$pepTemplateFileName.ps1 -rg $resourceGroup -vnetRG $vnetResourceGroup -fpath $templatesFolderPath -deployFileName $pepTemplateFileName -vnetName $vnetName -subnetName $subnetName $pepNames"

$pepDeployPath = $templatesFolderPath + $pepDeployCommand
Invoke-Expression -Command $pepDeployPath




