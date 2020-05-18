param(
  [string] [Parameter(Mandatory=$true)] $sqlServer,
  [string] [Parameter(Mandatory=$true)] $sqlAdmin,
  [string] [Parameter(Mandatory=$true)] $sqlPassword,
  [string] [Parameter(Mandatory=$true)] $aksCluster,
  [string] [Parameter(Mandatory=$true)] $aksResourceGroup
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
bash -c "kubectl apply -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment-rbac.yaml"
bash -c "kubectl apply -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/mic-exception.yaml"