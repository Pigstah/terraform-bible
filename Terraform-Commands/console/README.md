# Terraform Console

```
Usage: terraform [global options] console [options]

  Starts an interactive console for experimenting with Terraform
  interpolations.

  This will open an interactive console that you can use to type
  interpolations into and inspect their values. This command loads the
  current state. This lets you explore and test interpolations before
  using them in future configurations.

  This command will never modify your state.

Options:

  -state=path       Legacy option for the local backend only. See the local
                    backend's documentation for more information.

  -var 'foo=bar'    Set a variable in the Terraform configuration. This
                    flag can be set multiple times.

  -var-file=foo     Set variables in the Terraform configuration from
                    a file. If "terraform.tfvars" or any ".auto.tfvars"
                    files are present, they will be automatically loaded.
```