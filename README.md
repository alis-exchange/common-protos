# common-protos

Shared Protocol Buffers definitions for the Alis Build platform.

This repository is intended to play a similar role to Google's
[`api-common-protos`](https://github.com/googleapis/api-common-protos), but for
Alis Build services and APIs. It is the central place for protobuf types that
need to be shared across multiple services, SDKs, and generated clients.

## Purpose

Use this repository for protobuf definitions that are:

- shared by more than one service
- part of public or cross-team API contracts
- useful as common building blocks for generated clients and tooling

Examples include common resource messages, shared service definitions, request
and response types, annotations, metadata, and platform-wide event models.

## Repository Scope

This repository should contain common protobuf packages only.

Service-specific APIs that are not reused across the platform should generally
live with the owning service unless there is a clear reason to centralize them
here.

## Current Packages

The first package in this repository is:

```text
alis/a2a/extension/history/v1/history.proto
```

It defines the `alis.a2a.extension.history.v1` package and the
`A2AHistoryService`, along with shared resource and request/response messages
for A2A history and event retrieval.

As the repository grows, packages should remain versioned and organized by
domain.

## Usage

Consumers can vendor this repository, add it as a git submodule, or reference
it during protobuf code generation as an include path. The repository root is
intended to be used as a `protoc` include root.

Typical `protoc` usage looks like:

```bash
protoc -I . \
  --go_out=. \
  --go-grpc_out=. \
  alis/a2a/extension/history/v1/history.proto
```

Adjust language-specific plugins and output flags for your environment.

## Dependencies

The current proto imports definitions from:

- Google protobuf and IAM protos
- `alis/open/iam/v1`
- `lf/a2a/v1`

Those dependencies need to be available on the `protoc` include path when
generating code.

## Versioning

Follow standard protobuf API compatibility practices:

- prefer additive changes
- avoid reusing field numbers
- version packages when making breaking changes
- document deprecations before removal

## Status

The repository has started with the A2A history extension package and is
expected to grow into the shared protobuf source for Alis Build platform APIs.
