# Google Protos

This directory is the local copy of the Google common proto set used by this
repository.

## Why It Exists

Our first-party APIs import standard Google packages such as:

- `google/api`
- `google/rpc`
- `google/type`
- `google/iam`
- `google/logging`
- `google/longrunning`

Keeping those definitions in-tree makes `protoc` generation predictable and
avoids every downstream consumer having to source the same dependencies
separately.

## What To Expect

This is vendored upstream material, not Alis-specific schema design.

Use this tree for:

- API annotations like HTTP bindings and field behavior
- shared request and response error models
- common value types
- long-running operation contracts
- IAM and related support messages

Do not treat this folder as the place to invent new platform-specific messages.
That work belongs under `alis/` or another first-party namespace.

## Update Posture

When these protos need to change, the default action should be to refresh them
from the relevant Google upstream source rather than editing them ad hoc.

Local consumers should depend on the package names and import paths exactly as
provided here, for example:

```proto
import "google/api/annotations.proto";
import "google/rpc/status.proto";
```
