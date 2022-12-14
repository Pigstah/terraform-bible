# Terraform untaint

```
Usage: terraform [global options] untaint [options] name

  Terraform uses the term "tainted" to describe a resource instance
  which may not be fully functional, either because its creation
  partially failed or because you've manually marked it as such using
  the "terraform taint" command.

  This command removes that state from a resource instance, causing
  Terraform to see it as fully-functional and not in need of
  replacement.

  This will not modify your infrastructure directly. It only avoids
  Terraform planning to replace a tainted instance in a future operation.

Options:

  -allow-missing          If specified, the command will succeed (exit code 0)
                          even if the resource is missing.

  -lock=false             Don't hold a state lock during the operation. This is
                          dangerous if others might concurrently run commands
                          against the same workspace.

  -lock-timeout=0s        Duration to retry a state lock.

  -ignore-remote-version  A rare option used for the remote backend only. See
                          the remote backend documentation for more information.

  -state, state-out, and -backup are legacy options supported for the local
  backend only. For more information, see the local backend's documentation.
```