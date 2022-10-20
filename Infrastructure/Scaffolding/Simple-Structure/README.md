# Single File Deployment

A simple structure is suitable for small and testing projects, with a few resources of varying types and variables. It has a few configuration files, usually one per resource type (or more helper ones together with a main), and no custom modules, because most of the resources are unique and there aren’t enough to be generalized and reused.

- [Single File Deployment](#single-file-deployment)
  - [File Structure Explained](#file-structure-explained)
  - [Resource Documentation](#resource-documentation)
      - [Azure Provider Documentation](#azure-provider-documentation)
      - [AWS Provider Documentation](#aws-provider-documentation)
      - [GCP Provider Documentation](#gcp-provider-documentation)
  - [Preparing the project](#preparing-the-project)
    - [Creating and initialising a backend](#creating-and-initialising-a-backend)
    - [Setting a provider](#setting-a-provider)
    - [Initialising the project](#initialising-the-project)
  - [Writing the resource code](#writing-the-resource-code)
    - [Resource creation](#resource-creation)
    - [Adding variables](#adding-variables)
    - [Adding outputs](#adding-outputs)
  - [Deployment](#deployment)
    - [Validate](#validate)
    - [Plan](#plan)
    - [Apply](#apply)
  - [Destroying your resources](#destroying-your-resources)
    - [Destroy](#destroy)

## File Structure Explained

```
.
├── README.md
├── backend.tf
├── main.tf
├── output.tf
├── provider.tf
└── variable.tf
```

- Main
  - The file that stores all your code to deploy resources to your cloud environment
- Backend
  - Used to store the Terraform state file
- Provider
  - Used to define the cloud provider and version that is being used
- Variable
  - Used to store the variables you will use throughout the project. Note not as important for a simple structure deployment but handy if you don't want to keep repeating values.
- Output 
  - Used to output resource data - for example if you've created a public IP you can add this to the output file and it will be shown at the end of a successful deployment

## Resource Documentation

Below is the documentation for all the cloud providers for resource creation. You can find examples of resource code, as well as detailed explanations for each of the arguments that can be used when creating a resource.

#### Azure Provider Documentation

- [Link to docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

#### AWS Provider Documentation

- [Link to docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

#### GCP Provider Documentation

- [Link to docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

## Preparing the project

There are several steps to make before you can start deploying infrastructure to your cloud provider. Please follow along below:

Please note that this guide assumes you understand the basics of Terraform (state files, resource blocks etc) and won't go into much detail explaining what each part does. If you want to understand more please refer to <insert directory here>.

### Creating and initialising a backend

In order to save the state of your project, you need to create a place to store it. This can be done locally (not advised) or by storing it in a with a storage container (Blob, S3 Bucket).

In the example below I'll be using Azure.

Firstly you'll need to create a storage account and a container to store the state file.

Use the below script to create the storage account via the CLI - please note you need to be logged into AZ-Cli - it also advised to replace the default names for the variables.

```bash
#!/bin/bash

RESOURCE_GROUP_NAME=tfstate
STORAGE_ACCOUNT_NAME=tfstate$RANDOM
CONTAINER_NAME=tfstate
LOCATION=uksouth

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME
```

Once this has completed, you will need the following details from the storage account

- storage_account_name: The name of the Azure Storage account.
- container_name: The name of the blob container.
- key: The name of the state store file to be created.
- access_key: The storage access key.
- resource_group: The name of the resource group

This next step isn't always necessary but if you receive an error stating you cannot access the storage account due to the ARM_ACCESS_KEY, then use the below env variable:

```bash
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)
export ARM_ACCESS_KEY=$ACCOUNT_KEY
```

Next we will need to add the details of the storage account to the ```backend.tf```in order for Terraform to store the state file.

Below is the details you need for the backend:

```bash
backend "azurerm" {
  resource_group_name  = "<resource_group_name>"
  storage_account_name = "<storage_account_name>"
  container_name       = "<container_name"
  key                  = "tfstate"
}
```

Please follow the next step to then initialise the project and backend

### Setting a provider

Terraform uses providers to query cloud providers APIs in order to deploy infrastructure. These providers can be declared in a file, or as part of the resource creation itself but for this project we will be using a ```provider.tf```file.

This example is using Azure and you will need to use the following and add it to the ```proivder.tf``` file:

```hcl
terraform {
required_providers {
    azurerm = {
        source  = "hashicorp/azurerm"
        version = "<version_number>"
        }
    }
}

provider "azurerm" {
  features {}
}
```

You will need to add a version number, I recommend using the latest, unless deploying legacy code.

### Initialising the project

The final step in preparing the project for actual deployments requires you to run the following:

```bash
terraform init
```

This will do two things:

- Initialise the projects providers
- Store the state of the project in the storage container we created earlier

The project is now ready to start deploying infrastructure code.

## Writing the resource code

This is a single layer Terraform deployment (no modules in use) and is fairly straight forward to add resource code and get deployed quickly.

### Resource creation

Open the ```main.tf``` and add the following resource block

```bash
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}
```

You should notice we are specifying two variables for the ```name``` and ```location```. In normal circumstances when deploying a single resource, you wouldn't use variables but with this example I want to show you the full approach.

### Adding variables

So we have our resource block, which will create a resource group but we don't have the variables declared. Let's add the variables so the resource creating will not error once we apply it.

Within the root directory there is a file called ```variable.tf``` - open this file and add the following variable blocks.

```bash
variable "resource_group_name" {
  description = "Name of the Resource Group"
  default     = "test-rgp"
}

variable "location" {
  description = "Location of the deployed resources"
  default     = "uksouth"
}
```

### Adding outputs

So next we want to be able to see the name of the resource group and it's location outputted to the CLI after it's been deployed. We can do this by adding output blocks to the ```output.tf``` file.

Open the ```output.tf``` file and add the following:

```bash
output "resource_group_name_output" {
  value       = azurerm_resource_group.example.name
  description = "Name of the resource group"
}

output "location_output" {
  value       = azurerm_resource_group.example.location
  description = "Location of the resource group"
}
```

Outputs can be handy to show information needed once the deployment has completed or to pass data to other modules within the deployment.

## Deployment

Finally time has come to deploy your Terraform code - you will need to run one command and Terraform will take care of the rest. Before that we can do some checks to make sure all the code is configured properly.

### Validate

Run the validate command below to do exactly what it says on the tin - validate the code is correct:

```bash
terraform validate
```

### Plan
Next we can run a plan, which is essentially a dry run without the actual code execution:

```bash
terraform plan
```

Providing all of the above worked correctly and outputted no errors then you can now run the below (note that there will be a prompt, you will want to say yes):

### Apply

```bash
terraform apply
```

Allow Terraform to do its thing and once you get the green complete message with your outputs then you're done!

## Destroying your resources

Destroying is a lot easier than actually deploying - all you need to do in order to destroy the last deployment is run the following (note that there will be a prompt, you will want to say yes):

### Destroy

```bash
terraform destroy
```
