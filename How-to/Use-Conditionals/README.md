# Conditional Expressions

- [Conditional Expressions](#conditional-expressions)
  - [Simple Expression Example](#simple-expression-example)
  - [Advanced example using Count](#advanced-example-using-count)

Conditional Expressions can be used throughout a Terraform project to enable or disable certain resources for various different reasons. To explain in a bit more detail see the below taken from Terraforms documentation:

A conditional expression uses the value of a bool expression to select one of two values.

The syntax of a conditional expression is as follows:
```bash
condition ? true_val : false_val
```
If condition is true then the result is true_val. If condition is false then the result is false_val.

A common use of conditional expressions is to define defaults to replace invalid values:
```bash
var.a != "" ? var.a : "default-a"
```
If var.a is an empty string then the result is "default-a", but otherwise it is the actual value of var.a.

*[Link to docs](https://www.terraform.io/docs/language/expressions/conditionals.html)*

## Simple Expression Example

Using variables and tfvars for deployments is handy but sometimes you want to stand something up without having to give set all the variables.

A unique way of doing this would be to use a conditional part of your locals block (if you're unfamiliar with a locals block, see documentation [here](https://www.terraform.io/docs/language/values/locals.html))

See local value example below:

```bash
locals {
    name  = (var.name != ? var.name : random_id.id.hex)
    owner = var.team
    common_tags = {
        Owner = local.owner
        Name  = local.name
    } 
}
```

The above local block has an expression which will look to see if var.name is not empty, then assign var.name to the value, else it will assign a random hex value to the tag. 

Visual representation below:

| Condition	| ?	| true value | : | false value |
|-----------|---|------------|---|-------------|
|If the name variable is NOT empty|	then | Assign the var.name value to the tag |	else | Assign random_id.id.hex value to the tag |

Using this approach means that you could in theory deploy a stack very quickly with minimal configuration if needed. As all he values that aren't hard coded would be assigned random values.

## Advanced example using Count

You can also use conditionals with the count function (again if you're not familiar with the count function please see docs [here](https://www.terraform.io/docs/language/meta-arguments/count.html))

A good example is using the count with an expression to deploy one of a particular resource or two if the condition is met.

```bash
resource "azurerm_resource_group" "example_1" {
  name     = var.resource_group_name_1
  location = var.location_1
}

resource "azurerm_resource_group" "example_2" {
  count    = var.is_production ? 1 : 0

  name     = var.resource_group_name_2
  location = var.location_2
}
```

The above example looks for ```var.is_production``` and if it is set to ```True``` then the secondary resource group is deployed as well, else it will ignore the resource block.

This gives you the flexibility to design a single block of code that can change per environment.