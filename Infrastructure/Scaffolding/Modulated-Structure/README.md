# Modulated Deployment

A modulated structure is best to use when you have a large deployment of different infrastructure parts. Modules allow you to share that code with other modules, makes it easier to manage the code and allows for a lot more logic to be used when creating the deployment.

- [Modulated Deployment](#modulated-deployment)
  - [File Structure Explained](#file-structure-explained)
  - [Resource Documentation](#resource-documentation)
    - [Azure Provider Documentation](#azure-provider-documentation)
    - [AWS Provider Documentation](#aws-provider-documentation)
    - [GCP Provider Documentation](#gcp-provider-documentation)
  - [Preparing the project](#preparing-the-project)
    - [Creating and initialising a backend](#creating-and-initialising-a-backend)
    - [Setting a provider](#setting-a-provider)
    - [Initialising the project](#initialising-the-project)
  - [Writing the module code](#writing-the-module-code)
    - [Resource creation](#resource-creation)
    - [Adding variables](#adding-variables)
    - [Adding outputs](#adding-outputs)
  - [Calling the module](#calling-the-module)
    - [Adding module block](#adding-module-block)
    - [Adding outputs of the module](#adding-outputs-of-the-module)
    - [Adding the variables](#adding-the-variables)
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
├── environments
│   └── terraform.tfvars
├── main.tf
├── modules
│   ├── aks-cluster
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variable.tf
│   ├── resource-group
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variable.tf
│   └── vnet
│       ├── main.tf
│       ├── output.tf
│       └── variable.tf
├── output.tf
├── provider.tf
└── variables.tf
```

- Main
  - The file that will direct Terraform to each of your modules containing the resource code
- Modules
  - Where all the resource code will live, they are broken down into modules to keep code clean and also make it re-usable elsewhere within the project.
- Backend
  - Used to store the Terraform state file
- Environments
  - This is used to store the different tfvars for various deployments. It doesn't explicitly need to be this location, in fact they can be in the root dir but keeps things organised. A useful tip is to append the env after each of the vars - ```terraform.tfvars.dev```
- Provider
  - Used to define the cloud provider and version that is being used
- Variable
  - Used to store the variables you will use throughout the project
- Output 
  - Used to output module resource data - this will outputs within the specified module - for example if you've created a public IP you can add this to the output file and it will be shown at the end of a successful deployment

## Resource Documentation

Below is the documentation for all the cloud providers for resource creation. You can find examples of resource code, as well as detailed explanations for each of the arguments that can be used when creating a resource.

### Azure Provider Documentation

- [Link to docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

### AWS Provider Documentation

- [Link to docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### GCP Provider Documentation

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

## Writing the module code

This step we will just do a basic deployment of a resource group, so you can see the process needed to add new resources to this modulated approach. We will create a resource block within the ```modules/resource-group``` directory and the block will need to be within the ```main.tf``` file.

### Resource creation

Once inside the directory, open the ```main.tf``` and add the following resource block

```bash
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}
```

You should notice we are specifying two variables for the ```name``` and ```location```. In normal circumstances when deploying a single resource, you wouldn't use variables but with this example I want to show you the full approach.

### Adding variables

So we have our resource block, which will create a resource group but we don't have the variables declared. Let's add the variables so the resource creating will not error once we apply it.

Within the current directory there is a file called ```variable.tf``` - open this file and add the following variable blocks.

```bash
variable "resource_group_name" {
  description = "Name of the Resource Group"
  default     = ""
}

variable "location" {
  description = "Location of the deployed resources"
  default     = ""
}
```

If you're hawk eyed you should notice the ```default``` fields are empty. There's a good reason for this and it will be covered later when we cover the use of ```tfvars```.

### Adding outputs

So next we want to be able to see the name of the resource group and it's location outputted to the CLI after it's been deployed. We can do this by adding output blocks to the ```output.tf``` file within the same directory.

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

## Calling the module

So we have the module created for our resource group creation but Terraform doesn't know where to pick this code up. So we need to go back to the root of the directory and update the main configuration files.

### Adding module block

Firstly we need to add the source of the module to the ```main.tf``` within the root directory.

Open the ```main.tf``` file and add the following:

```bash
module "create_resource_group" {
  source = "./modules/resource-group"

  # variables
  resource_group_name = var.resource_group_name
  location            = var.location
}
```

You should notice we declared our variables again within this module block - thats because we will be loading these variables from a ```tfvars``` file. This will be covered later on in this section.

### Adding outputs of the module

So we next need to let Terraform know there are outputs we've set. So for this you need to open the ```output.tf``` file and add the following:

```bash
output "resource_group_outputs" {
  value = module.create_resource_group
}
```

### Adding the variables 

We now need to add the variables into the root ```variable.tf```file and also update the the ```terraform.tfvars```.

Firstly open the ```variable.tf``` file and add the following:

```bash
variable "resource_group_name" {
  description = "Name of the Resource Group"
  default     = ""
}

variable "location" {
  description = "Location of the deployed resources"
  default     = ""
}
```

Next go to the ```environments/``` directory and open ```terraform.tfvars``` and add the following:

```bash
resource_group_name = "test-rgp"
location            = "uksouth"
```

The ```tfvars``` file will get parsed in when you run ```terraform apply``` and will thus populate the variables throughout the project.

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
terraform apply -var-file=environments/terraform.tfvars
```

Allow Terraform to do its thing and once you get the green complete message with your outputs then you're done!

## Destroying your resources

Destroying is a lot easier than actually deploying - all you need to do in order to destroy the last deployment is run the following (note that there will be a prompt, you will want to say yes):

### Destroy

```bash
terraform destroy -var-file=environments/terraform.tfvars
```




