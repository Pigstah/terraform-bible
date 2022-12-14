# Terraform fmt

```
Usage: terraform [global options] fmt [options] [DIR]

        Rewrites all Terraform configuration files to a canonical format. Both
        configuration files (.tf) and variables files (.tfvars) are updated.
        JSON files (.tf.json or .tfvars.json) are not modified.

        If DIR is not specified then the current working directory will be used.
        If DIR is "-" then content will be read from STDIN. The given content must
        be in the Terraform language native syntax; JSON is not supported.

Options:

  -list=false    Don't list files whose formatting differs
                 (always disabled if using STDIN)

  -write=false   Don't write to source files
                 (always disabled if using STDIN or -check)

  -diff          Display diffs of formatting changes

  -check         Check if the input is formatted. Exit status will be 0 if all
                 input is properly formatted and non-zero otherwise.

  -no-color      If specified, output won't contain any color.

  -recursive     Also process files in subdirectories. By default, only the
                 given directory (or current directory) is processed.
```
