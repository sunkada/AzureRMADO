param([Parameter(Mandatory=$true)]    [string]  $userName,
        [Parameter(Mandatory=$true)]  [string]  $password,
        [Parameter(Mandatory=$true)]  [string]  $resourceGroup,
        [Parameter(Mandatory=$true)]  [string]  $clusterName,
        [Parameter(Mandatory=$true)]  [string]  $tenantId)


$securedPassword = ConvertTo-SecureString $password -AsPlainText -Force
$spCreds = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $userName,$securedPassword

Connect-AzAccount -Credential $spCreds -TenantId $tenantId -ServicePrincipal

$loginCommand = "az login --service-principal -u $userName -p $password --tenant $tenantId"
Invoke-Expression $loginCommand

$kbctlContextCommand = "az aks get-credentials --resource-group $resourceGroup --name $clusterName --overwrite-existing --admin"
Invoke-Expression -Command $kbctlContextCommand
