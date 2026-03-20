# Linux Foundation A2A Protos

This directory contains the Linux Foundation Agent2Agent (`A2A`) protocol
definitions vendored into this repository.

## Why It Exists

Alis Build A2A extensions build on top of the shared cross-organisation A2A
contract instead of redefining the base agent protocol from scratch.

In practice, this folder provides the foundational messages and service surface
for imports such as:

```proto
import "lf/a2a/v1/a2a.proto";
```

## What It Contains

The current package is:

- `lf.a2a.v1`

That package defines the baseline A2A service and the core message model used
for agent messaging, task lifecycle management, streaming responses,
artifacts, and related protocol structures.

## Boundary

This namespace should remain a clean copy of the Linux Foundation definition
set as adopted by the repo.

Use `alis/a2a/...` for:

- Alis-specific extensions
- platform-specific resources
- additional services layered on top of the base A2A protocol

Use `lf/a2a/...` for:

- the shared upstream protocol contract
- compatibility with other A2A-capable implementations

## Practical Use

When generating code, include the repository root so imports resolve directly:

```bash
protoc -I . --go_out=. lf/a2a/v1/a2a.proto
```
