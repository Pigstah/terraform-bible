# Terraform get

```
Usage: terraform [global options] get [options] PATH

  Downloads and installs modules needed for the configuration given by
  PATH.

  This recursively downloads all modules needed, such as modules
  imported by modules imported by the root and so on. If a module is
  already downloaded, it will not be redownloaded or checked for updates
  unless the -update flag is specified.

  Module installation also happens automatically by default as part of
  the "terraform init" command, so you should rarely need to run this
  command separately.

Options:

  -update             Check already-downloaded modules for available updates
                      and install the newest versions available.

  -no-color           Disable text coloring in the output.
```