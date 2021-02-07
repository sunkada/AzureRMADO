param([Parameter(Mandatory=$true)]   [string] $resourceGroup,
        [Parameter(Mandatory=$true)] [string] $vnetResourceGroup,
        [Parameter(Mandatory=$true)] [string] $location,
        [Parameter(Mandatory=$true)] [string] $vnetName,
        [Parameter(Mandatory=$true)] [string] $pepName,
        [Parameter(Mandatory=$true)] [string] $pepResourceName, 
        [Parameter(Mandatory=$true)]  [string] $vnetLinkName)

$privateDnsZone = "privatelink.vaultcore.azure.net"

$vnet = Get-AzVirtualNetwork -ResourceGroupName $vnetResourceGroup `
-Name $vnetName

$pep = Get-AzPrivateEndpoint -Name $pepName `
-ResourceGroupName $resourceGroup -ExpandResource NetworkInterfaces

$interfacesCount = $pep.NetworkInterfaces.Count
if ($interfacesCount -lt 1)
{

   Write-Host "NetworkInterfaces' count should be atleast 1"
   return;

}

$ipConfigurationsCount = $pep.NetworkInterfaces[0].IpConfigurations.Count
if ($ipConfigurationsCount -lt 1)
{

   Write-Host "IpConfigurations' count should be atleast 1"
   return;

}

$kvPrivateIP = $pep.NetworkInterfaces[0].IpConfigurations[0].PrivateIpAddress
Write-Host $kvPrivateIP

$zone = Get-AzPrivateDnsZone -ResourceGroupName $resourceGroup `
-Name $privateDnsZone
if (!$zone)
{
   $zone = New-AzPrivateDnsZone -ResourceGroupName $resourceGroup `
   -Name $privateDnsZone
   Write-Host $zone.ResourceId
}

$vnetLink = Get-AzPrivateDnsVirtualNetworkLink -ResourceGroupName $resourceGroup `
-Name $vnetLinkName -ZoneName $privateDnsZone
if (!$vnetLink)
{
   $vnetLink = New-AzPrivateDnsVirtualNetworkLink -ResourceGroupName $resourceGroup `
   -ZoneName $privateDnsZone -Name $vnetLinkName -VirtualNetwork $vnet
   Write-Host $vnetLink.ResourceId
}

$kvRecord = New-AzPrivateDnsRecordConfig -Ipv4Address $kvPrivateIP
$dnsRecord = Get-AzPrivateDnsRecordSet -ResourceGroupName $resourceGroup `
-ZoneName $privateDnsZone -Name $pepResourceName -RecordType "A"

$recordExists = $dnsRecord.Records.Contains($kvRecord)
if (!$dnsRecord)
{
   New-AzPrivateDnsRecordSet -ResourceGroupName $resourceGroup `
   -Name $pepResourceName -ZoneName $privateDnsZone `
   -RecordType "A" -Ttl 10 -PrivateDnsRecord $kvRecord

}
elseif ($recordExists -eq $false)
{

   $dnsRecord.Records.Add($kvRecord)
   Set-AzPrivateDnsRecordSet -RecordSet $dnsRecord

}
