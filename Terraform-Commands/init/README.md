# Terraform init

```
Usage: terraform [global options] init [options]

  Initialize a new or existing Terraform working directory by creating
  initial files, loading any remote state, downloading modules, etc.

  This is the first command that should be run for any new or existing
  Terraform configuration per machine. This sets up all the local data
  necessary to run Terraform that is typically not committed to version
  control.

  This command is always safe to run multiple times. Though subsequent runs
  may give errors, this command will never delete your configuration or
  state. Even so, if you have important information, please back it up prior
  to running this command, just in case.

Options:

  -backend=true           Configure the backend for this configuration.

  -backend-config=path    This can be either a path to an HCL file with key/value
                          assignments (same format as terraform.tfvars) or a
                          'key=value' format. This is merged with what is in the
                          configuration file. This can be specified multiple
                          times. The backend type must be in the configuration
                          itself.

  -force-copy             Suppress prompts about copying state data. This is
                          equivalent to providing a "yes" to all confirmation
                          prompts.

  -from-module=SOURCE     Copy the contents of the given module into the target
                          directory before initialization.

  -get=true               Download any modules for this configuration.

  -input=true             Ask for input if necessary. If false, will error if
                          input was required.

  -no-color               If specified, output won't contain any color.

  -plugin-dir             Directory containing plugin binaries. This overrides all
                          default search paths for plugins, and prevents the
                          automatic installation of plugins. This flag can be used
                          multiple times.

  -reconfigure            Reconfigure the backend, ignoring any saved
                          configuration.

  -migrate-state          Reconfigure the backend, and attempt to migrate any
                          existing state.

  -upgrade=false          If installing modules (-get) or plugins, ignore
                          previously-downloaded objects and install the
                          latest version allowed within configured constraints.

  -lockfile=MODE          Set a dependency lockfile mode.
                          Currently only "readonly" is valid.

  -ignore-remote-version  A rare option used for the remote backend only. See
                          the remote backend documentation for more information.
```