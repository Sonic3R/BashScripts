﻿az login
#az group create --name UbuntuRG --location westus
az deployment group create --name MyMachineDeployment --resource-group UbuntuRG --template-file template.json --parameters parameters.json


#az group delete --name UbuntuRG
#az group delete --name NetworkWatcherRG