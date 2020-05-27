param(
  [string] [Parameter(Mandatory=$true)] $sqlServer,
  [string] [Parameter(Mandatory=$true)] $sqlAdmin,
  [string] [Parameter(Mandatory=$true)] $sqlPassword,
  [string] [Parameter(Mandatory=$true)] $aksCluster,
  [string] [Parameter(Mandatory=$true)] $aksResourceGroup,
  [string] [Parameter(Mandatory=$true)] $subscriptionId,
  [string] [Parameter(Mandatory=$true)] $agwName,
  [string] [Parameter(Mandatory=$true)] $identityResourceID,
  [string] [Parameter(Mandatory=$true)] $identityClientID
)

# Install SQL Tools
bash -c "apt-get update && apt-get install -y gnupg2"
bash -c "curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -"
bash -c "curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list | tee /etc/apt/sources.list.d/msprod.list"
bash -c "apt-get update"
bash -c "export ACCEPT_EULA=Y && apt-get install msodbcsql17 -y"
bash -c "export ACCEPT_EULA=Y && apt-get install mssql-tools unixodbc-dev -y"

# Create domaindb Table
$file = $(New-Item -ItemType File -Name domaindata.sql)
Set-Content -Path $file.Name -Value "CREATE TABLE [domaindb].[dbo].[domaindata] ([Id] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY, [Name] NVARCHAR(MAX) NULL);`nGO"
bash -c "/opt/mssql-tools/bin/sqlcmd -S tcp:$sqlServer -d domaindb -U $sqlAdmin -P $sqlPassword -i /mnt/azscripts/azscriptinput/domaindata.sql"

# Connect to AKS Cluster
bash -c "curl -sL https://aka.ms/InstallAzureCLIDeb | bash"
bash -c "az login --identity"
bash -c "az aks install-cli"
bash -c "az aks get-credentials --name $aksCluster --resource-group $aksResourceGroup"

# Configure POD Identity
bash -c "kubectl apply -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment-rbac.yaml"
bash -c "kubectl apply -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/mic-exception.yaml"

# Install Helm
bash -c "curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3"
bash -c "chmod 700 get_helm.sh"
bash -c "./get_helm.sh"

# Configure APP Gateway Ingress Controller
bash -c "helm repo add application-gateway-kubernetes-ingress https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/"
bash -c "helm repo update"
bash -c "curl https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/docs/examples/sample-helm-config.yaml > helm-config.yaml"
$a = get-content -path helm-config.yaml
$a = $a -replace '<subscriptionId>', $subscriptionId
$a = $a -replace '<agwName>', $agwName
$a = $a -replace '<identityResourceID>', $identityResourceID
$a = $a -replace '<identityClientID>', $identityClientID
$a = $a -replace 'enabled: false', 'enabled: true'
New-Item helm-config-updated.yaml
Set-Content helm-config-update.yaml $a

bash -c "helm install ingress-azure -f helm-config-updated.yaml application-gateway-kubernetes-ingress/ingress-azure --version 1.0.0"

# Need to work through this, can I add the pod identity identityResourceId and identityClientId as Helm Values
# https://azure.github.io/application-gateway-kubernetes-ingress/examples/sample-helm-config.yaml