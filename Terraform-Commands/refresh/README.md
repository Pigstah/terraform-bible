# Terraform refresh

```
Usage: terraform [global options] refresh [options]

  Update the state file of your infrastructure with metadata that matches
  the physical resources they are tracking.

  This will not modify your infrastructure, but it can modify your
  state file to update metadata. This metadata might cause new changes
  to occur when you generate a plan or call apply next.

Options:

  -compact-warnings   If Terraform produces any warnings that are not
                      accompanied by errors, show them in a more compact form
                      that includes only the summary messages.

  -input=true         Ask for input for variables if not directly set.

  -lock=false         Don't hold a state lock during the operation. This is
                      dangerous if others might concurrently run commands
                      against the same workspace.

  -lock-timeout=0s    Duration to retry a state lock.

  -no-color           If specified, output won't contain any color.

  -target=resource    Resource to target. Operation will be limited to this
                      resource and its dependencies. This flag can be used
                      multiple times.

  -var 'foo=bar'      Set a variable in the Terraform configuration. This
                      flag can be set multiple times.

  -var-file=foo       Set variables in the Terraform configuration from
                      a file. If "terraform.tfvars" or any ".auto.tfvars"
                      files are present, they will be automatically loaded.

  -state, state-out, and -backup are legacy options supported for the local
  backend only. For more information, see the local backend's documentation.
```