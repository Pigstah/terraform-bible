# Using for_each Expressions

- [Using for_each Expressions](#using-for_each-expressions)
  - [Example of for_each in action](#example-of-for_each-in-action)

For expressions in Terraform are very useful and can really save a lot of time when using needing to create multiple of the same resource. They enable you to iterate over a map or set of strings and creates an instance of all those values. You can then use that instance to add them to a resource as string values. Learning this method can mean less code churn and less code in general!

An description taken from the Terraform documentation is below:

>By default, a resource block configures one real infrastructure object (and similarly, a module block includes a child module's contents into the configuration one time). However, sometimes you want to manage several similar objects (like a fixed pool of compute instances) without writing a separate block for each one. Terraform has two ways to do this: count and for_each.

*See documentation [here](https://www.terraform.io/docs/language/meta-arguments/for_each.html)*

## Example of for_each in action

The below example shows how you can use the ```for_each``` expression to add multiple tables to a storage account using only one block of resource code:

```bash
locals {
  table_names = {
    table_1 = "AllHashes"
    table_2 = "ChangeFeedLanding"
    table_3 = "Reports"
  }
}

resource "azurerm_storage_table" "ti_tables_1" {
  for_each             = { for names in local.table_names : names => names }

  name                 = each.value
  storage_account_name = azurerm_storage_account.storage_account_1.name
}
```

The expression will create an instance ```names``` and use the map of strings within the local block to populate that instance. Then for the name value in the resource block you use ```each.value``` which takes the values of that instance and then adds them to the value.

Something to note from Terraform docs is the below:

>The for_each meta-argument accepts a map or a set of strings, and creates an instance for each item in that map or set. Each instance has a distinct infrastructure object associated with it, and each is separately created, updated, or destroyed when the configuration is applied.

*See documentation [here](https://www.terraform.io/docs/language/meta-arguments/for_each.html)*
