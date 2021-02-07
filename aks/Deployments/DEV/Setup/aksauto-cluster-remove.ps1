param([Parameter(Mandatory=$false)]   [string] $resourceGroup = "aks-workshop-rg",        
        [Parameter(Mandatory=$false)] [string] $clusterName = "aks-workshop-cluster",       
        [Parameter(Mandatory=$false)] [string] $subscriptionId = "<subscriptionId>")

$subscriptionCommand = "az account set -s $subscriptionId"

# PS Select Subscriotion 
Select-AzSubscription -SubscriptionId $subscriptionId

# CLI Select Subscriotion 
Invoke-Expression -Command $subscriptionCommand

az aks delete --name $clusterName --resource-group $resourceGroup --yes

Write-Host "-----------Remove------------"