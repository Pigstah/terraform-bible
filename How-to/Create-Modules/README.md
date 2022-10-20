# Create Modules

Modules in Terraform are a great way to keep your code tidy and also create modules that can be used throughout the project. We will go over the basics of modules, what they need in order to deploy correctly and how to reuse them.

- [Create Modules](#create-modules)
  - [Modules Overview](#modules-overview)
  - [Creating a module](#creating-a-module)
    - [File Structure](#file-structure)
  - [Calling Modules](#calling-modules)
    - [Adding module block](#adding-module-block)
    - [Adding outputs of the module](#adding-outputs-of-the-module)
    - [Adding the variables](#adding-the-variables)

## Modules Overview

To give a basic overview I have taken this short paragraph from the Terraform website:

>A module is a container for multiple resources that are used together. Modules can be used to create lightweight abstractions, so that you can describe your infrastructure in terms of its architecture, rather than directly in terms of physical objects.
>
>The .tf files in your working directory when you run ```terraform plan``` or ```terraform apply``` together form the root module. That module may call other modules and connect them together by passing output values from one to input values of another.

*[Reference to documentation](https://www.terraform.io/docs/language/modules/develop/index.html)*

## Creating a module

This guide will cover creating a module within a Terraform project.

### File Structure

A module will live in its own folder, normally called ```modules``` but this is not a strict naming convention. The general file structure of a module is as follows:

```bash
modules
├── module-code
│   ├── README.md
│   ├── main.tf
│   ├── output.tf
│   └── variable.tf
```

At a basic level you could have all of the contents of these files within the ```main.tf``` but its good practice to split out the outputs and variables into their own files.

- Modules
  - Where all the resource code will live, they are broken down into modules to keep code clean and also make it re-usable elsewhere within the project.
  - Variable
    - Used to store the variables you will use throughout the project
  - Output 
    - Used to output module resource data - this will outputs within the specified module - for example if you've created a public IP you can add this to the output file and it will be shown at the end of a successful deployment
  - Main
    - This is the file where all the resource code lives

## Calling Modules

The next sections will cover how you call the modules once they have been created.

### Adding module block

Below is an example of a module block. The module block will tell Terraform where to look for the module you have specified. The name of the module block does not matter but its always good to give it a descriptive name.

We also specify any variables that we are parsing into this module. Some variables will live solely in the module itself but sometimes you want to have the ability to change those variables on the fly. Thats when using tfvars and parsing them in at the root level comes in handy.

```bash
module "create_resource_group" {
  source = "./modules/resource-group"

  # variables
  resource_group_name = var.resource_group_name
  location            = var.location
}
```

### Adding outputs of the module

When creating modules an important piece is outputs. Outputs can be used to get data from one module to another or just to output an important string to the CLI / Pipeline.

Outputs always live in the ```output.tf``` file in the root and the module directory. To make sure Terraform knows about these outputs, you should add the below to the ```output.tf``` file in the root directory:

```bash
output "resource_group_outputs" {
  value = module.create_resource_group
}
```

### Adding the variables 

Variables can be managed from the root, tfvars or within the module itself. If using the root / tfvars approach you would need to make sure the variables are defined in the module block (see [Adding module block](#adding-module-block)) and within the root ```variable.tf``` file.

Below is an example of the variable blocks:

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

At this point you're ready to hit apply and watch your new module deploy.