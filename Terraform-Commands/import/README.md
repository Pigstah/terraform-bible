# Terraform import 

```
Usage: terraform [global options] import [options] ADDR ID

  Import existing infrastructure into your Terraform state.

  This will find and import the specified resource into your Terraform
  state, allowing existing infrastructure to come under Terraform
  management without having to be initially created by Terraform.

  The ADDR specified is the address to import the resource to. Please
  see the documentation online for resource addresses. The ID is a
  resource-specific ID to identify that resource being imported. Please
  reference the documentation for the resource type you're importing to
  determine the ID syntax to use. It typically matches directly to the ID
  that the provider uses.

  The current implementation of Terraform import can only import resources
  into the state. It does not generate configuration. A future version of
  Terraform will also generate configuration.

  Because of this, prior to running terraform import it is necessary to write
  a resource configuration block for the resource manually, to which the
  imported object will be attached.

  This command will not modify your infrastructure, but it will make
  network requests to inspect parts of your infrastructure relevant to
  the resource being imported.

Options:

  -config=path            Path to a directory of Terraform configuration files
                          to use to configure the provider. Defaults to pwd.
                          If no config files are present, they must be provided
                          via the input prompts or env vars.

  -allow-missing-config   Allow import when no resource configuration block exists.

  -input=false            Disable interactive input prompts.

  -lock=false             Don't hold a state lock during the operation. This is
                          dangerous if others might concurrently run commands
                          against the same workspace.

  -lock-timeout=0s        Duration to retry a state lock.

  -no-color               If specified, output won't contain any color.

  -var 'foo=bar'          Set a variable in the Terraform configuration. This
                          flag can be set multiple times. This is only useful
                          with the "-config" flag.

  -var-file=foo           Set variables in the Terraform configuration from
                          a file. If "terraform.tfvars" or any ".auto.tfvars"
                          files are present, they will be automatically loaded.

  -ignore-remote-version  A rare option used for the remote backend only. See
                          the remote backend documentation for more information.

  -state, state-out, and -backup are legacy options supported for the local
  backend only. For more information, see the local backend's documentation.
```