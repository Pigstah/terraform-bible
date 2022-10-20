# Sharing Module Data

Sometimes we need the data from one module within another - we can use a data block but that can cause a "chicken and egg" scenario, where the resource needs to exist to query it (we could go down the rabbit hole of adding in ```depends_on``` flags but that can become messy if you're needing to do it for a lot of resources). 

So one option you have is parsing the module into the module block for that module to use.

- [Sharing Module Data](#sharing-module-data)
    - [Parsing a Module into another](#parsing-a-module-into-another)

### Parsing a Module into another

So below we have a two module blocks, one for a resource group and one for a vnet. We would like to use the resource group module within the vnet module, to ensure they're part of the same resource group or create a new resource group all together.

```bash
module "create_resource_group" {
  source = "./modules/resource-group"

  # variables
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "create_vnet" {
  source = "./modules/vnet"

  # variables
  resource_group_name = var.resource_group_name
  location            = var.location
}
```

We can achieve this by replace the variable for ```resource_group_name``` with a reference to the module that creates it. An example is below:

```bash
resource_group_name = module.create_resource_group.resource_group_name 
```

Lets break the above down so we understand it:

- module - this lets Terraform know that you're calling a module
- create_resource_group - this is the name of the module
- resource_group_name - this is the output within that module, that will give return the resource groups name

Finally if you put this together, it will look like this:

```bash
module "create_resource_group" {
  source = "./modules/resource-group"

  # variables
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "create_vnet" {
  source = "./modules/vnet"

  # variables
  resource_group_name = module.create_resource_group.resource_group_name 
  location            = var.location
}
```

When ```terraform apply``` is run the vnet will be created and added to the vnet that is created in the ```create_resource_group``` module.