# Coding Standards and Conventions

- [Coding Standards and Conventions](#coding-standards-and-conventions)
  - [Variable usage](#variable-usage)
      - [Naming Variables](#naming-variables)
      - [Variable Descriptions](#variable-descriptions)
  - [Naming Conventions](#naming-conventions)
      - [Infrastructure Naming](#infrastructure-naming)
      - [Resource Naming](#resource-naming)
  - [File Structure](#file-structure)
  - [Tfvars](#tfvars)
  - [Code Formatting](#code-formatting)
      - [Aligning within the code blocks](#aligning-within-the-code-blocks)
      - [Organising Code & Commenting](#organising-code--commenting)
  - [Tagging Resources](#tagging-resources)

## Variable usage

Variables are a key part of Terraform and can be very powerful. Covered below are some of the basics in managing those variables.

#### Naming Variables

Try to keep the names of variables short and clear:

```bash
# Good Example
var.rgp_name

# Bad Example
var.resource_group_name
```

Both are clear but one is shorter and easier to type. 


#### Variable Descriptions

Descriptions can be used within the variable block, and must be used with every variable. It doesn't need to be a details description, just a short line telling us what it is.

```bash
variable "rgp_env" {
  description = "This is the name of the resource group"
  type        = string
  default     = "rgp-test"
}
```

## Naming Conventions

Its important to keep naming of resource uniformed - it makes it easy to spot the infrastructure and also easy to find various different environments as well.

#### Infrastructure Naming

Generally we try to use the following formula, whilst still trying to keep the names short and snappy.

- Resource - short name of the resource eg akv (azure-key-vault), aks (azure-kubernetes-service)
- Region/Location - short name of the region/location 
- Project - name of the project - be it a short name etc
- Workspace - this would just use the ```terraform.workspace``` variable and take the workspace that is set 


```bash
# Example
<resource>-<region/location>-<project>-<env/workspace>

# This will look something like this
rgp-usc-timw-shared-qa
```

When it comes to naming tables, topics, queues and basically anything that is within a resource these naming conventions don't need to follow the same structure. See an example below:

- Resource Group = rgp-usc-timw-shared-qa
- Storage = sausctimwsharedqa
- Table   = "name_of_table"

*NOTE - you may have noticed the storage account has no hyphens, this is because Azure will only accept lowercase a-z or numbers within certain resource names - so please bear this in mind.*

#### Resource Naming

When you create resource code you will have to make sure each resource has a unique name - keeping these names consistent is key to making sure the code is readable and resources are easily found.

See the resource block below and the naming convention:

```bash
resource "azurerm_resource_group" "uks-rg" {
  name     = "test-rgp"
  location = "uksouth
}
```

The names do not need to be long or overly descriptive but give an idea of what its doing. In the example above I've added ```uks-rg``` which is basically saying "UK South Resource Group". The general formula is as follows:

```bash
<region>-<resource>
```

There can be more added if necessary but try to keep them as clear and simple as possible. Also adding numbers at the end to differentiate between multiple of the same resource in the same region is good as well.

## File Structure

The file structure doesn't matter too much on small dev deployments, as long as it gives you the resources you need it doesn't matter how you got there. When dealing with writing Terraform code for larger projects that will ultimately be used a lot, then there are some rules to follow in order to keep the files neat and readable from the a high level.

Below is an example of a modulated Terraform project and how the file structure looks: 

```bash
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

With larger projects this is the structured approach you'd want to take. It makes it easy to find resource code as each resource lives within the modules directory and has it's own module. Each file is labeled correctly and keeping this default naming convention means you always know what file does what.

## Tfvars

Tfvars are there to manage variables throughout the project that may or may not need to be changed on an environment basis. It's good to get in the habit of using Tfvars for your variables so that you only have to look in one place to change things such as ```node_vm_size_ = "Standard_D4s_v3"```. 

When using Tfvars make sure they live in a ```environments``` directory and are labeled clearly for each environment eg ```terraform.tfvars.prod```.

Within the files itself you don't need to follow any strict structure but a good way to keep it readable is to make sure all the ```=``` are in line, see example below:

```bash
resource_group_name_1               = ""
location_1                          = ""
cluster_name_1                      = ""
storage_account_1                   = ""
nodepool_vm_size_1                  = ""
servicebus_namespace_1              = ""
```

Finally if you're using tfvars for multiple resource deployment, for example two clusters that are exact replicas of each other, make sure you group each of those variables together, another example below:

```bash
resource_group_name_1               = ""
location_1                          = ""
cluster_name_1                      = ""
storage_account_1                   = ""
nodepool_vm_size_1                  = ""
servicebus_namespace_1              = ""

resource_group_name_2               = ""
location_2                          = ""
cluster_name_2                      = ""
storage_account_2                   = ""
nodepool_vm_size_2                  = ""
servicebus_namespace_2              = ""
```

This just makes it easier to read in general and know exactly where to find specific variables.

## Code Formatting

The only code formatting that will help a lot with the readability is aligning the ```=``` within the all of the code blocks. This will make it easier to read and make changes.

#### Aligning within the code blocks

See example below:

```bash
resource "azurerm_servicebus_namespace" "service_bus_namespace1" {
  name                = "${var.servicebus_namespace_1}-${terraform.workspace}"
  location            = var.location_1
  resource_group_name = var.resource_group_name_1
  sku                 = "Premium"
  capacity            = "1"
  zone_redundant      = true

  tags = {
      sb_namespace = "${var.servicebus_namespace_1}.${terraform.workspace}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
```

You will notice that the nested tags and lifecycle blocks are not aligned with the resource block. This is intentional as they are separate blocks within the resource block.

#### Organising Code & Commenting

Another process to consider is organising your code via resource to make it easy to find a particular resource. 

The best way to do this is to add a comment denoting what the resource after the comment. Example:

```bash
## QUEUES ##

resource "azurerm_servicebus_queue" "example" {
  name                = "example1"
  resource_group_name = var.resource_group_name_1
  namespace_name      = azurerm_servicebus_namespace.service_bus_namespace1.name

  enable_partitioning = false
  max_size_in_megabytes = 81920
}

## TOPICS ##

resource "azurerm_servicebus_topic" "example2" {
  name                  = "example2"
  resource_group_name   = var.resource_group_name_1
  namespace_name        = azurerm_servicebus_namespace.service_bus_namespace1.name

  enable_partitioning   = false
  default_message_ttl   = "P14D"
  max_size_in_megabytes = 81920
}
```

This will make things a lot easier to find resources.

You can also comment on any code that may need explaining, so any for_each, for and count expressions.

## Tagging Resources

Resource tagging is very important, not only to identify who has deployed the resource but it also ties into the costings through Bytes. 

Tag blocks are nested within resource blocks, not all resource blocks can handle tags, so please refer to the documentation for that particular resource. The tags can be representative of anything you want but generally we try to use the following:

- Project/Product
- Environment
- CreatedDate

In order to create reusable tags and not have to add them to each resource is to add a locals block to the top of the resource main.tf file.

```bash
locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    CreatedDate = timestamp()
  }
}
```

Once this has been added, you then need to add the following to the tag block:

```bash
resource "azurerm_resource_group" "Demo" {
  name     = var.ResourceGroupName
  location = var.ResourceGroupLocation

  tags = merge(local.common_tags)

  lifecycle {
    ignore_changes = [
      tags["CreatedDate"]
    ]
  }
}
```

The lifecycle block with ```ignore_changes``` will not update the ```CreatedDate``` tag after the initial deployment. This is so you know when it was deployed and it doesn't change every time you update the code.
