# Terraform General Policies & Processes

The goal of this document is to give people a base understanding of the processes that we want to put in place to make sure people are deploying safe, well written and trackable code.

It goes without saying that Terraform code should be treated exactly the same as any other code project with the the organisation as it is just as crucial.

## Github / DevOps repo Management

### PR Peer reviews

All projects containing Terraform code that are going to be deployed should have a peer review in place. Either by policy or by asking someone to review in policy not in place. 

### Clear and easily readable README

A clear and concise README should be constructed for all Terraform projects, detailing what is being deployed and if there are any steps prior to actually running ```Terraform apply```. You can use tools such as [Terraform-docs](../../Tools/terraform-docs/README.md) to aid in documentation as well, as this will document all your variables and outputs within the project.

### Gitignore

When setting up a repository make sure you add a .gitignore file, either at creation of the repository or from this public [repo](https://github.com/github/gitignore)

### Branch Names

When creating branches please try to prefix it with your initials, for example ```MP/new-branch-name``` makes it a lot easier to track. Also branch names should either be linked to a PBI (PBI ID) or descriptive enough to get the gist of what that branches changes contain.

### PR Checks

Where possible try to use PR checks to make sure the code outputs a valid plan and also take advantage of using ```terraform fmt``` to auto format any code.

## Testing changes

### Applying to all Environments

When working on new changes and preparing them for Prod, we need to make sure all changes are followed through each environment to ensure they are production ready.

Flow should be:

```
Dev > QA > Stage > Production
```

This gives us the best chance of catching any bugs or errors before hitting production.