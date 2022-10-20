# Terraform Automated

Within this guide we will learn how to create the backend for the state file within the terraform code.

- [Terraform Automated](#terraform-automated)
  - [Creating Backend for Azure](#creating-backend-for-azure)
    - [Terraform Configuration](#terraform-configuration)

## Creating Backend for Azure

In order to create a backend for Terraform we need the following resources:

- Resource Group
- Storage Account
- Storage Container

This deployment will be separated from the core Terraform code - so best practice would be to save it in its own directory like ```terraform-state```.

### Terraform Configuration

Firstly we need to define a few variables to parse into the resource creation:

```bash
# company
variable "project" {
  type        = string
  description = "This variable defines the name of the company"
  default     = "project-a"
}

# environment
variable "environment" {
  type        = string
  description = "This variable defines the environment to be built"
  default     = "non-prod"
}

# azure region
variable "location" {
  type        = string
  description = "Azure region where the resource group will be created"
  default     = "uksouth"
}
```

Next we'll create the ```main.tf``` file that will contain the resource code:

```bash
# Generate a random storage name
resource "random_string" "tf-name" {
  length  = 8
  upper   = false
  number  = true
  lower   = true
  special = false
}

# Create a Resource Group for the Terraform State File
resource "azurerm_resource_group" "state-rgp" {
  name     = "rgp-${lower(var.project)}-tfstate-${var.environment}"
  location = var.location  lifecycle {
    prevent_destroy = true
  }  
  tags = {
    environment = var.environment
  }
}

# Create a Storage Account for the Terraform State File
resource "azurerm_storage_account" "state-sta" {
  depends_on = [azurerm_resource_group.state-rg]
 
  name = "${lower(var.project)}tf${random_string.tf-name.result}"
  resource_group_name = azurerm_resource_group.state-rg.name
  location = azurerm_resource_group.state-rg.location
  account_kind = "StorageV2"
  account_tier = "Standard"
  access_tier = "Hot"
  account_replication_type = "ZRS"
  enable_https_traffic_only = true
   
  lifecycle {
    prevent_destroy = true
  }  
  
  tags = {
    environment = var.environment
  }
}

# Create a Storage Container for the Core State File
resource "azurerm_storage_container" "tfstate-container" {
  depends_on = [azurerm_storage_account.state-sta]
  
  name                 = "tfstate"
  storage_account_name = azurerm_storage_account.state-sta.name
}
```

Finally we need to output the details to add to the backend block to connect to it:

```bash
output "terraform_state_resource_group_name" {
  value = azurerm_resource_group.state-rgp.name
}
output "terraform_state_storage_account" {
  value = azurerm_storage_account.state-sta.name
}
output "terraform_state_storage_container_core" {
  value = azurerm_storage_container.tfstate-container.name
}
```

Last but not least you will need to run the following command:

```bash
terraform apply
```

Once the deployment has finished, you will see the outputs in the CLI - copy these to fill out the backend block below:

```bash
terraform {
  backend "azurerm" {
    resource_group_name  = ""
    storage_account_name = ""
    container_name       = ""
    key                  = "tfstate"
  }
}
```

You will then use the backend above in your core Terraform directory to store the state.