if($args.Length -le 1) {
   Write-Host "Invalid args"
   return;
}
   
[string]$user=$args[0]
[string]$password=$args[1]
[string]$ubuntu=$args[2]

Copy-Item parameters.json parameters1.json
$path = Join-Path "ubuntu$ubuntu"
$parameter1 = Join-Path $path parameters1.json
$content = Get-Content $parameter1 -Encoding UTF8

$content = $content -replace "@@user", $user
$content = $content -replace "@@pass", $password

$content | Out-File $parameter1

az login
az group create --name UbuntuRG --location westus
az deployment group create --name MyMachineDeployment --resource-group UbuntuRG --template-file template.json --parameters $parameter1
az network nsg rule create --name PortFTP21 --nsg-name UbuntuVM-nsg --resource-group UbuntuRG --access Allow --direction Inbound --protocol '*' --priority 310 --destination-port-ranges '20-21'
az network nsg rule create --name PortFTP45 --nsg-name UbuntuVM-nsg --resource-group UbuntuRG --access Allow --direction Inbound --protocol '*' --priority 311 --destination-port-ranges '40000-50000'

Remove-Item $parameter1

#az group delete --name UbuntuRG
#az group delete --name NetworkWatcherRG