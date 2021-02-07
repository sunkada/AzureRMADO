param([Parameter(Mandatory=$false)]   [string] $resourceGroup = "aks-workshop-rg",        
        [Parameter(Mandatory=$false)] [string] $projectName = "snr-aks-workshop",
        [Parameter(Mandatory=$false)] [string] $nameSpaceName = "aks-workshop-dev",
        [Parameter(Mandatory=$false)] [string] $location = "eastus",
        [Parameter(Mandatory=$false)] [string] $clusterName = "snr-aks-cluster",        
        [Parameter(Mandatory=$false)] [string] $acrName = "snraksacr",
        [Parameter(Mandatory=$false)] [string] $keyVaultName = "snrkv",
        [Parameter(Mandatory=$false)] [string] $appgwName = "snraksappgw",
        [Parameter(Mandatory=$false)] [string] $aksVNetName = "snraksvnet",
        [Parameter(Mandatory=$false)] [string] $aksSubnetName = "snrakssubnet",
        [Parameter(Mandatory=$false)] [string] $appgwSubnetName = "snraksappgwsubnet",        
        [Parameter(Mandatory=$false)] [string] $appgwTemplateFileName = "aksauto-appgw-deploy",        
        [Parameter(Mandatory=$false)] [string] $ingControllerIPAddress = "173.0.0.200",
        [Parameter(Mandatory=$false)] [string] $ingHostName = "ingress-dev.wkshpdev.com",
        [Parameter(Mandatory=$false)] [string] $baseFolderPath = "D:\Microsoft\Workshops\AKSWorkshop\AKSAutomate\Deployments\DEV")

$templatesFolderPath = $baseFolderPath + "\Templates"
$yamlFilePath = "$baseFolderPath\YAMLs"
$ingControllerName = $projectName + "-ing"
$ingControllerNSName = $ingControllerName + "-ns"
$ingControllerFileName = "internal-ingress"

# Switch Cluster context
$kbctlContextCommand = "az aks get-credentials --resource-group $resourceGroup --name $clusterName --overwrite-existing --admin"
Invoke-Expression -Command $kbctlContextCommand

Write-Host $yamlFilePath

# Configure ILB file
# $ipReplaceCommand = "sed -e 's|<ILB_IP>|$ingControllerIPAddress|' $yamlFilePath\Common\$ingControllerFileName.yaml > $yamlFilePath\Common\tmp.$ingControllerFileName.yaml"
# Invoke-Expression -Command $ipReplaceCommand
# # Remove temp ILB file
# $removeTempFileCommand = "mv $yamlFilePath\Common\tmp.$ingControllerFileName.yaml $yamlFilePath\Common\$ingControllerFileName.yaml"
# Invoke-Expression -Command $removeTempFileCommand

# Create Namespace
$nginxNSCommand = "kubectl create namespace $nameSpaceName"
Invoke-Expression -Command $nginxNSCommand
# nginx NS
$nginxNSCommand = "kubectl create namespace $ingControllerNSName"
Invoke-Expression -Command $nginxNSCommand

# Install nginx as ILB using Helm
$nginxRepoAddCommand = "helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx"
Invoke-Expression -Command $nginxRepoAddCommand

$nginxRepoUpdateCommand = "helm repo update"
Invoke-Expression -Command $nginxRepoUpdateCommand

# $nginxILBCommand = "helm install $ingControllerName bitnami/nginx-ingress-controller --namespace $ingControllerNSName -f $yamlFilePath/Common/$ingControllerFileName.yaml --set controller.replicaCount=2 --set nodeSelector.'beta.kubernetes.io/os'=linux --set defaultBackend.nodeSelector.'beta\.kubernetes\.io/os'=linux"
$nginxILBCommand = "helm install $ingControllerName ingress-nginx/ingress-nginx --namespace $ingControllerNSName -f $yamlFilePath\Common\$ingControllerFileName.yaml"
Invoke-Expression -Command $nginxILBCommand

# Install AppGW
$networkNames = "-appgwName $appgwName -vnetName $aksVNetName -subnetName $appgwSubnetName"
$appgwDeployCommand = "\AppGW\$appgwTemplateFileName.ps1 -rg $resourceGroup -fpath $templatesFolderPath -deployFileName $appgwTemplateFileName -backendIPAddress $ingControllerIPAddress -hostName $ingHostName $networkNames"
$appgwDeployPath = $templatesFolderPath + $appgwDeployCommand
Invoke-Expression -Command $appgwDeployPath

Write-Host "-----------Post-Config------------"
