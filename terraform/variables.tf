variable "identifier" {
  default = "fullnep08"
}

variable "resourceGroupName" {
  default     = "hello-world"
}

variable "location" {
  default     = "eastus"
}

variable "continerRegistryName" {
  default     = "acr"
}

variable "keyvaultName" {
  default     = "keyvault"
}

variable "sqlServerName" {
  default     = "sql"
}

variable "sqlServerAdminName" {
  default     = "twtadmin"
}

variable "sqlServerAdminPassword" {
  default     = "Password2020!"
}

variable "aksName" {
  default     = "aks"
}
variable "aksClisntId" {}

variable "aksClientSecret" {}