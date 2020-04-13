if($args.Length -le 1) {
   Write-Host "Invalid args"
   return;
}
   
[string]$user=$args[0]
[string]$password=$args[1]

Copy-Item parameters.json parameters1.json
$content = Get-Content parameters1.json

$content = $content -replace "@@user", $user
$content = $content -replace "@@pass", $password

$content | Out-File parameters1.json

az login
az group create --name UbuntuRG --location westus
az deployment group create --name MyMachineDeployment --resource-group UbuntuRG --template-file template.json --parameters parameters1.json

Remove-Item parameters1.json

#az group delete --name UbuntuRG
#az group delete --name NetworkWatcherRG