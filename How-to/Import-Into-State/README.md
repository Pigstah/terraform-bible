# Importing Resources into State

- [Importing Resources into State](#importing-resources-into-state)
  - [Using the Import command](#using-the-import-command)
    - [Including Vars file with Import](#including-vars-file-with-import)

With Terraform you're able to import existing infrastructure for Terraform to manage. This is particularly good for the development cycle, as developers can stand up infrastructure as they please and this can be imported and managed.

You may also come across the need to import when you're implementing changes that already exist. Example being a topic within a service bus namespace has been created manually, tested and then requested to be added to the infrastructure. At the point of the apply, Terraform will notice this is already present and ask for it to be imported.

## Using the Import command

Using the import command is very simple, it has three parts to it (sometimes four, if needing to specify tfvars) and runs quickly.

PLEASE NOTE:  
*```name_of_provider_module``` would represent a module like ```azurerm_storage_account```and the ```name_of_local_module``` would be the unique identifying name you assign it*

See below for an example:

```bash
# If using a module approach
terraform import <module>.<Name_of_Provider_Module>.<Name_of_Local_Module>.<Name_of_Resource> <Azure Resource ID>

# If using a simple single file approach
terraform import <Name_of_Provider_Module>.<Name_of_Local_Module>.<Name_of_Resource> <Azure Resource ID>
```

Terraform will then go fetch the resource and add it into the current state.

### Including Vars file with Import

Finally if you're using variables locally, such as tfvars, then you would need to specify them also within the above commands. See example below:

```bash
# If using a module approach
terraform import -var-file=<Path_to_tfvars/var file> <module>.<Name_of_Provider_Module>.<Name_of_Local_Module>.<Name_of_Resource> <Azure Resource ID>

# If using a simple single file approach
terraform import -var-file=<Path_to_tfvars/var file> <Name_of_Provider_Module>.<Name_of_Local_Module>.<Name_of_Resource> <Azure Resource ID>
```