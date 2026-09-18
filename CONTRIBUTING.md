# Contributing to common-protos

This repository holds first-party Alis Build protos alongside vendored copies of
upstream protos. Most of the rules below come down to one question: do we own
the namespace you are changing?

## Change the namespace you own

- Update `alis/` and other first-party packages here as part of normal API work.
- Treat `google/` and `lf/` as vendored upstream sources unless there is a very
  deliberate reason to patch them locally.
- If an upstream dependency is refreshed, keep the README for that namespace in
  sync with the source and intent of the imported package set.

## Compatibility

For first-party packages:

- prefer additive changes
- avoid reusing field numbers
- version packages when making breaking changes
- document deprecations before removal

For vendored upstream packages:

- preserve upstream package names and import paths
- avoid local edits that drift from the upstream source unnecessarily

## Documenting protos

The Buf Schema Registry builds this module's reference documentation from the
comments in the `.proto` files, and code generators copy the same comments
into generated code. CI does not check for them, so review them like code.

- Put a `//` comment directly above every service, RPC, message, field, oneof,
  enum and enum value. Say what it is for, and give formats, units and what an
  empty value means where they are not obvious.
- Leave no blank line between a comment and its element. A separated comment
  is detached and does not appear in the docs. Do not use trailing comments.
- Give every package an overview in a comment directly above its `package`
  line. When a package spans several files, the BSR sorts them by path and uses
  the first one that has a package comment, so keep the overview in that file
  only and update it when the package changes.
- Comments render as Markdown (CommonMark and GitHub Flavored Markdown), so use
  backticks for identifiers and lists where they help.
- When you add a package, add it to the table in `alis/README.md` or
  `standards/README.md`.

## Checks before you open a pull request

```bash
buf build
buf breaking --against '.git#branch=main'
```

The `Buf CI` workflow runs the same build and breaking-change checks on every
pull request that touches protos. Lint and format checks are off until the
existing protos are cleaned up.

If a breaking change is intended, add the `buf skip breaking` label to the pull
request and explain why in its description.

## Publishing to the Buf Schema Registry

The first-party protos are published as
[`buf.build/alis-build/common-protos`](https://buf.build/alis-build/common-protos).
There is nothing to run by hand: every push publishes a commit, with the branch
or tag name as its label, and `main` is the default label consumers get.
Deleting a branch archives its label.

`google/` is not part of the published module. Consumers get those files from
`buf.build/googleapis/googleapis` instead, which avoids duplicate-file errors
for anyone who depends on both.

## Vendored upstream protos

`google/` comes from [googleapis/googleapis](https://github.com/googleapis/googleapis)
and `lf/a2a/v1/` from
[a2aproject/A2A](https://github.com/a2aproject/A2A/tree/main/specification).

The weekly `Upstream drift` workflow compares them with upstream and keeps one
issue labelled `upstream-drift` open while their definitions differ. It only
looks at packages already vendored here, and it compares compiled definitions,
so comment and copyright changes are listed but not counted. Run
`.github/scripts/upstream-drift.sh` to see the same report locally.

When refreshing a vendored package:

- Copy the upstream files as they are, then re-apply only the local edits listed
  in the script's `IGNORED` array.
- Check `go_package` changes before merging. Upstream has been moving Google's Go
  packages from `google.golang.org/genproto/...` to `cloud.google.com/go/...`,
  which changes the import paths that Go code generation produces.

When a local edit to a vendored file is deliberate, add it to `IGNORED` with a
reason. The drift issue lists every ignored field with its reason, so readers
can tell an intended difference from an overlooked one.
