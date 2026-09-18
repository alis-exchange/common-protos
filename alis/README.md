# Alis Protos

This directory holds the first-party Alis Build APIs and extensions shared
across products: agent protocols and their extensions, identity and access,
support, instruments, and the platform's own tooling contracts.

## What It Contains

Each package links to its page on the Buf Schema Registry, which carries the
package overview and a description of every service, message and field.

| Package | Purpose |
| ------- | ------- |
| [`alis.a2a.extension.history.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.a2a.extension.history.v1) | Stores A2A conversations as threads of events, with per-user read and pin state |
| [`alis.a2a.extension.scheduler.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.a2a.extension.scheduler.v1) | Schedules prompts to an A2A agent on a cron schedule or at a set time |
| [`alis.adk.sessions.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.adk.sessions.v1) | Stores agent sessions: conversations, their events, and the state carried across them |
| [`alis.agui.history.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.agui.history.v1) | Thread metadata and per-user read and pin state for AG-UI conversations |
| [`alis.agui.scheduler.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.agui.scheduler.v1) | Schedules runs of AG-UI agents on a cron schedule or at a set time |
| [`alis.build.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.build.v1) | Git repositories of an Alis Build landing zone, and log search for Google Cloud projects |
| [`alis.evals.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.evals.v1) | Post-deploy integration tests, load tests, agent evaluations and infrastructure observations |
| [`alis.iam.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.iam.v1) | Incremental IAM binding changes and batched permission checks alongside `google.iam.v1` |
| [`alis.open.agent.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.open.agent.v1) | gRPC binding of the Agent2Agent (A2A) protocol: messages, tasks, push notifications and agent cards |
| [`alis.open.agent.v2`](https://buf.build/alis-build/common-protos/docs/main:alis.open.agent.v2) | The same A2A binding without `Task.name` and `Part.any` |
| [`alis.open.config.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.open.config.v1) | Product configuration passed to services as an environment variable |
| [`alis.open.cx.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.open.cx.v1) | Compliance Exchange (CX) attributes that classify an instrument under regulatory sets |
| [`alis.open.flows.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.open.flows.v1) | The steps an API request goes through, so clients can follow its progress |
| [`alis.open.iam.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.open.iam.v1) | Users, groups and roles of a product deployment, and how users sign in |
| [`alis.open.in.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.open.in.v1) | The financial instrument resource: reference data, identifiers, classifications and engine details |
| [`alis.open.notifications.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.open.notifications.v1) | Device registration and Firebase Cloud Messaging notifications |
| [`alis.open.operations.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.open.operations.v1) | A long-running operation that also stores the state needed to resume it |
| [`alis.open.options.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.open.options.v1) | Custom options for Alis code generators, currently JSON Schema generation |
| [`alis.open.pubsub.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.open.pubsub.v1) | The Pub/Sub push request body, so services receive events through an RPC |
| [`alis.open.px.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.open.px.v1) | Portfolio Exchange (PX) attributes: price data sourcing, portfolio mapping and data health |
| [`alis.open.support.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.open.support.v1) | Support issues, their activity and subscribers, and product guides |
| [`alis.open.validation.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.open.validation.v1) | Validates messages against a service's rules, and lists those rules |
| [`alis.usage.v1`](https://buf.build/alis-build/common-protos/docs/main:alis.usage.v1) | Hourly API usage snapshots that products publish about their own traffic |

## Boundary

Use `alis/a2a/...` for Alis extensions layered on the Agent2Agent protocol, and
import the base protocol from the vendored `lf/a2a/v1/` rather than
redefining it. The `alis/open/agent/...` packages are a separate, self-contained
gRPC binding of A2A and do not import `lf/`.

## Conventions

- The APIs follow Google's resource-oriented design
  ([google.aip.dev](https://google.aip.dev)). Standard methods take and return
  resources named by patterns such as `threads/{thread}`, and `buf.yaml` relaxes
  the lint rules that conflict with that style.
- Every package is versioned (`v1`, `v2`). Breaking changes go into a new
  version rather than an existing one.
- Each package's overview is the comment above its `package` line, in the
  alphabetically first file of the package. See
  [CONTRIBUTING.md](../CONTRIBUTING.md#documenting-protos).

## Practical Use

Import a package from the repository root:

```proto
import "alis/a2a/extension/history/v1/history.proto";
```

Consumers of the Buf Schema Registry module get these packages from
`buf.build/alis-build/common-protos`.
