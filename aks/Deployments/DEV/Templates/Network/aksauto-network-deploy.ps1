param([Parameter(Mandatory=$true)] [string] $rg,
        [Parameter(Mandatory=$true)] [string] $fpath,
        [Parameter(Mandatory=$true)] [string] $deployFileName,
        [Parameter(Mandatory=$true)] [string] $aksVNetName,
        [Parameter(Mandatory=$true)] [string] $aksVNetPrefix,
        [Parameter(Mandatory=$true)] [string] $aksSubnetName,
        [Parameter(Mandatory=$true)] [string] $aksSubNetPrefix,
        [Parameter(Mandatory=$true)] [string] $appgwSubnetName,
        [Parameter(Mandatory=$true)] [string] $appgwSubnetPrefix,
        [Parameter(Mandatory=$true)] [string] $vrnSubnetName,
        [Parameter(Mandatory=$true)] [string] $vrnSubnetPrefix)

Test-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath\Network\$deployFileName.json" `
-aksVNetName $aksVNetName -aksVNetPrefix $aksVNetPrefix `
-aksSubnetName $aksSubnetName -aksSubNetPrefix $aksSubNetPrefix `
-appgwSubnetName $appgwSubnetName -appgwSubnetPrefix $appgwSubnetPrefix `
-vrnSubnetName $vrnSubnetName -vrnSubnetPrefix $vrnSubnetPrefix

New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath\Network\$deployFileName.json" `
-aksVNetName $aksVNetName -aksVNetPrefix $aksVNetPrefix `
-aksSubnetName $aksSubnetName -aksSubNetPrefix $aksSubNetPrefix `
-appgwSubnetName $appgwSubnetName -appgwSubnetPrefix $appgwSubnetPrefix `
-vrnSubnetName $vrnSubnetName -vrnSubnetPrefix $vrnSubnetPrefix