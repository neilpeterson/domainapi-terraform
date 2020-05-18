# pro-template scaffolding infa

## Quickstart

Ensure both the Azure CLI and Terraform are installed on your development system and authenticated with Azure.

Clone both this repository and the pro-template scaffolding application to your development system.

Run the following commands from the Terraform configurations directory.

```
terraform init
terrafom apply
```

Once the infrastructure deployment has completed, following the Terraform output to run the application. Note, the third command needs to be run from the root of the pro-scaffolding application.

```
_1_Run_this_command_to_login_to_the_Azure_Contianer_Registry = az acr login --name acrnepeters011
_2_Run_this_command_to_login_connect_with_kubernetes_cluster = az aks get-credentials --name aks-nepeters011 --resource-group rg-nepeters011
_3_Run_this_command_to_build_and_stage_container_image = az acr build --registry acrnepeters011 -f src/Services/DomainAPI/Dockerfile --image domainapi:v1 .
_4_Run_this_command_to_run_helm_chart = helm install ./domain-api --set SqlServer=sqlnepeters011.database.windows.net --set SqlUser=twtadmin --set SqlPassword=Password2020! --set Image=acrnepeters011.azurecr.io/domainapi:v1 --generate-name
```