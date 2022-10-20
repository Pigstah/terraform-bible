# Workspace Variable

- [Workspace Variable](#workspace-variable)
  - [Using the workspace variable](#using-the-workspace-variable)

Terraform offers a feature where you can create separate workspaces within a single state file. This means that you can have multiple environments under one state and manage each deployment. The other good thing that comes with using workspaces is that use of the workspace variable. The workspace variable can be used throughout the project and will input the workspace name. This is handy for naming conventions when deploying multiple environments.

## Using the workspace variable

Using the workspace variable is very simple, please see the example below:

```bash
resource "azurerm_resource_group" "rg" {
  name     = "test-rg-${terraform.workspace}"
  location = "uksouth"
}
```

As you can see it's as simple as using ```terraform.workspace``` - whne this resource gets created it will look like "test-rg-(name of workspace)"
