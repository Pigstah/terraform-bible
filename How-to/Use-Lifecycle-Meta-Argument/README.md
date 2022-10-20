# Lifecycle Meta Arguments

- [Lifecycle Meta Arguments](#lifecycle-meta-arguments)
  - [Using the Lifecyle Argument](#using-the-lifecyle-argument)
    - [Syntaxt and Arguments](#syntaxt-and-arguments)
      - [Create Before Destroy](#create-before-destroy)
      - [Prevent Destroy](#prevent-destroy)
      - [Ignore Changes](#ignore-changes)

Lifecycle Meta Arguments have many use cases and can be used for various different reasons. This nested block can be used to manage the configuration of a resource within a project. What that means if you can tell Terraform not ```create_before_destroy``` - ```ignore_changes``` etc (these will be explained later on) and this will affect how the infrastructure if viewed by Terraform. One example would be using ```prevent_destroy``` which would prevent the destruction of a resource containing this nested block. You would use this on infrastructure you don't want to accidentally destroy, such a SQL servers etc.

## Using the Lifecyle Argument

Below is an example of a nested lifecycle block in use, which will tell Terraform to create the resource before destroy the current:

```bash
resource "azurerm_resource_group" "example" {
  # ...

  lifecycle {
    create_before_destroy = true
  }
}
```

I have taken the explanations for each lifecycle argument directly for the documentation [here](https://www.terraform.io/docs/language/meta-arguments/lifecycle.html)

### Syntaxt and Arguments

The following arguments can be used within a lifecycle block:

#### Create Before Destroy

```create_before_destroy``` (bool) - By default, when Terraform must change a resource argument that cannot be updated in-place due to remote API limitations, Terraform will instead destroy the existing object and then create a new replacement object with the new configured arguments.

The create_before_destroy meta-argument changes this behavior so that the new replacement object is created first, and the prior object is destroyed after the replacement is created.

This is an opt-in behavior because many remote object types have unique name requirements or other constraints that must be accommodated for both a new and an old object to exist concurrently. Some resource types offer special options to append a random suffix onto each object name to avoid collisions, for example. Terraform CLI cannot automatically activate such features, so you must understand the constraints for each resource type before using ```create_before_destroy``` with it.

#### Prevent Destroy

```prevent_destroy``` (bool) - This meta-argument, when set to true, will cause Terraform to reject with an error any plan that would destroy the infrastructure object associated with the resource, as long as the argument remains present in the configuration.

This can be used as a measure of safety against the accidental replacement of objects that may be costly to reproduce, such as database instances. However, it will make certain configuration changes impossible to apply, and will prevent the use of the terraform destroy command once such objects are created, and so this option should be used sparingly.

Since this argument must be present in configuration for the protection to apply, note that this setting does not prevent the remote object from being destroyed if the resource block were removed from configuration entirely: in that case, the ```prevent_destroy``` setting is removed along with it, and so Terraform will allow the destroy operation to succeed.

#### Ignore Changes

```ignore_changes``` (list of attribute names) - By default, Terraform detects any difference in the current settings of a real infrastructure object and plans to update the remote object to match configuration.

The ```ignore_changes``` feature is intended to be used when a resource is created with references to data that may change in the future, but should not affect said resource after its creation. In some rare cases, settings of a remote object are modified by processes outside of Terraform, which Terraform would then attempt to "fix" on the next run. In order to make Terraform share management responsibilities of a single object with a separate process, the ignore_changes meta-argument specifies resource attributes that Terraform should ignore when planning updates to the associated remote object.

The arguments corresponding to the given attribute names are considered when planning a create operation, but are ignored when planning an update. The arguments are the relative address of the attributes in the resource. Map and list elements can be referenced using index notation, like tags["Name"] and list[0] respectively.

```bash
resource "aws_instance" "example" {
  # ...

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}
```

Instead of a list, the special keyword all may be used to instruct Terraform to ignore all attributes, which means that Terraform can create and destroy the remote object but will never propose updates to it.

Only attributes defined by the resource type can be ignored. ignore_changes cannot be applied to itself or to any other meta-arguments.