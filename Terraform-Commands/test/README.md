# Terraform test

```
Usage: terraform test [options]

  This is an experimental command to help with automated integration
  testing of shared modules. The usage and behavior of this command is
  likely to change in breaking ways in subsequent releases, as we
  are currently using this command primarily for research purposes.

  In its current experimental form, "test" will look under the current
  working directory for a subdirectory called "tests", and then within
  that directory search for one or more subdirectories that contain
  ".tf" or ".tf.json" files. For any that it finds, it will perform
  Terraform operations similar to the following sequence of commands
  in each of those directories:
      terraform validate
      terraform apply
      terraform destroy

  The test configurations should not declare any input variables and
  should at least contain a call to the module being tested, which
  will always be available at the path ../.. due to the expected
  filesystem layout.

  The tests are considered to be successful if all of the above steps
  succeed.

  Test configurations may optionally include uses of the special
  built-in test provider terraform.io/builtin/test, which allows
  writing explicit test assertions which must also all pass in order
  for the test run to be considered successful.

  This initial implementation is intended as a minimally-viable
  product to use for further research and experimentation, and in
  particular it currently lacks the following capabilities that we
  expect to consider in later iterations, based on feedback:
    - Testing of subsequent updates to existing infrastructure,
      where currently it only supports initial creation and
      then destruction.
    - Testing top-level modules that are intended to be used for
      "real" environments, which typically have hard-coded values
      that don't permit creating a separate "copy" for testing.
    - Some sort of support for unit test runs that don't interact
      with remote systems at all, e.g. for use in checking pull
      requests from untrusted contributors.

  In the meantime, we'd like to hear feedback from module authors
  who have tried writing some experimental tests for their modules
  about what sorts of tests you were able to write, what sorts of
  tests you weren't able to write, and any tests that you were
  able to write but that were difficult to model in some way.

Options:

  -compact-warnings  Use a more compact representation for warnings, if
                     this command produces only warnings and no errors.

  -junit-xml=FILE    In addition to the usual output, also write test
                     results to the given file path in JUnit XML format.
                     This format is commonly supported by CI systems, and
                     they typically expect to be given a filename to search
                     for in the test workspace after the test run finishes.

  -no-color          Don't include virtual terminal formatting sequences in
                     the output.
```