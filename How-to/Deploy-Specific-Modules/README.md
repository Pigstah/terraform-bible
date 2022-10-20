# Deploying Specific Modules

- [Deploying Specific Modules](#deploying-specific-modules)
  - [Use Cases](#use-cases)
    - [Targeting modules to test](#targeting-modules-to-test)
    - [Targeting certain modules for destruction](#targeting-certain-modules-for-destruction)

*WARNING - the following guide should only be used in development environments as it can cause Terraform crashes and state file corruptions.*

When deploying infrastructure using Terraform it is designed to have an all or nothing approach. What that means is you have to deploy all the resources specified in your ```main.tf``` file. This can prove time consuming especially when you're dealing with standing Kubernetes clusters or SQL servers. 

A good way to test specific modules when developing your Terraform code is to use the ```-target``` flag. Before we start there is a disclaimer Terraform advises against using the ```-target``` flag, especially in Production as it can cause unwanted errors or state file discrepancies. Please see the message below from the CLI:

```bash
│ Warning: Resource targeting is in effect
│ 
│ You are creating a plan with the -target option, which means that the result of this plan may not represent all of the changes requested by the current configuration.
│ 
│ The -target option is not for routine use, and is provided only for exceptional situations such as recovering from errors or mistakes, or when Terraform specifically suggests to use it as part of an error message.
```

- [Deploying Specific Modules](#deploying-specific-modules)
  - [Use Cases](#use-cases)
    - [Targeting modules to test](#targeting-modules-to-test)
    - [Targeting certain modules for destruction](#targeting-certain-modules-for-destruction)

Now this sounds ominous but I can assure you that if used properly and not carelessly will help with testing out your individual modules and save time when testing the deployments.

## Use Cases

There are certain use cases for the ```-target``` flag and I will cover some of them here.

### Targeting modules to test

Sometimes you may want to test your new code that you've added but don't want to wait a full 20-30 mins (on large deployments) to just see it error at the end. A good way to handle this would be to target the module you want to deploy and any modules it depends on. 

You would do this using the below command:

```bash
terraform apply -target=module.name_of_module -target=module.name_of_module_dependency
```

This would deploy only the modules you specify, thus lowering thew time for the deployment and making sure it all works.

### Targeting certain modules for destruction

In some cases you may encounter a resource that is not functioning as expected or is stuck in an state that can't be manually repaired (AKS Cluster stuck in a failed state and start/stop is not fixing it). When this happens you can use the ```-target``` flag with the ```destroy``` command to destroy that resource and then re-apply afterwards. 

This just saves time in having to run the whole deployment again.

```bash
terraform destroy -target=module.name_of_module -target=module.name_of_module_dependency
```