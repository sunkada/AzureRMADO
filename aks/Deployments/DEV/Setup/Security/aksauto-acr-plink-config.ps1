param([Parameter(Mandatory=$true)]   [string] $resourceGroup,
        [Parameter(Mandatory=$true)] [string] $vnetResourceGroup,
        [Parameter(Mandatory=$true)] [string] $location,
        [Parameter(Mandatory=$true)] [string] $vnetName,
        [Parameter(Mandatory=$true)] [string] $pepName,
        [Parameter(Mandatory=$true)] [string] $pepResourceName, 
        [Parameter(Mandatory=$true)]  [string] $vnetLinkName)

$privateDnsZone = "privateLink.azurecr.io"

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
if ($ipConfigurationsCount -lt 2)
{

   Write-Host "IpConfigurations' count should be atleast 2"
   return;

}

$acrPrivateIP = $pep.NetworkInterfaces[0].IpConfigurations[1].PrivateIpAddress
Write-Host $acrPrivateIP

$acrDataPrivateIP = $pep.NetworkInterfaces[0].IpConfigurations[0].PrivateIpAddress
Write-Host $acrDataPrivateIP

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

$acrRecord = New-AzPrivateDnsRecordConfig -Ipv4Address $acrPrivateIP
$dnsRecord = Get-AzPrivateDnsRecordSet -ResourceGroupName $resourceGroup `
-ZoneName $privateDnsZone -Name $pepResourceName -RecordType "A"

$recordExists = $dnsRecord.Records.Contains($acrRecord)
if (!$dnsRecord)
{
   New-AzPrivateDnsRecordSet -ResourceGroupName $resourceGroup `
   -Name $pepResourceName -ZoneName $privateDnsZone `
   -RecordType "A" -Ttl 10 -PrivateDnsRecord $acrRecord

}
elseif ($recordExists -eq $false)
{

   $dnsRecord.Records.Add($acrRecord)
   Set-AzPrivateDnsRecordSet -RecordSet $dnsRecord

}

$pepDataResourceName = $pepResourceName + "." + $location + ".data"
$acrDataRecord = New-AzPrivateDnsRecordConfig -Ipv4Address $acrDataPrivateIP
$dnsDataRecord = Get-AzPrivateDnsRecordSet -ResourceGroupName $resourceGroup `
-ZoneName $privateDnsZone -Name $pepDataResourceName -RecordType "A"

$recordExists = $dnsRecord.Records.Contains($acrDataRecord)
if (!$dnsDataRecord)
{
   New-AzPrivateDnsRecordSet -ResourceGroupName $resourceGroup `
   -Name $pepDataResourceName -ZoneName $privateDnsZone `
   -RecordType "A" -Ttl 10 -PrivateDnsRecord $acrDataRecord
 
}
elseif ($recordExists -eq $false)
{

   $dnsDataRecord.Records.Add($acrDataRecord)
   Set-AzPrivateDnsRecordSet -RecordSet $dnsDataRecord
   
}
