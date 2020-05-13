# Domain Data API

```
# Run from the terraform directory

terraform init
terraform plan --out plan.out
terraform apply plan.out
```

Once complete, Terraform outputs the following commands which can be used to connect to Azure service and start the application. 

**Note**: the third command needs to be run from the root of the domain API project.

```Outputs:

_1_Run_this_command_to_login_to_the_Azure_Contianer_Registry = az acr login --name acrfullnep08
_2_Run_this_command_to_login_connect_with_kubernetes_cluster = az aks get-credentials --name aksfullnep08 --resource-group hello-world-fullnep08
_3_Run_this_command_to_build_and_stage_container_image = az acr build --registry acrfullnep08 -f src/Services/DomainAPI/Dockerfile --image domainapi:v1 .
_4_Run_this_command_to_run_helm_chart = helm install ./domain-api --set SqlServer=sqlfullnep08.database.windows.net --set SqlUser=twtadmin --set SqlPassword=Password2020! --set Image=acrfullnep08azurecr.io/domainapi:v1 --generate-name
```

## Pod identity (these are notes as I work through this process)

Enable AAD Pod Identity in Kubernetes cluster

```
kubectl apply -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment-rbac.yaml
```

Create Azure Identity and Azure Identity Binding objects in the cluster.

```
kubectl apply -f pod-identity.yaml
```