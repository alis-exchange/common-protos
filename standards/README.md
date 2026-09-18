# Standards Protos

This directory holds first-party protobuf versions of financial industry data
standards: due diligence questionnaires, regulatory returns, industry data
templates, and the report file layouts produced by fund administrators and
asset managers.

## Why It Exists

The source standards are published as spreadsheets, PDFs or JSON schemas.
Modelling each one as a message gives every product the same typed contract
for collecting, validating and exchanging the answers.

## What It Contains

| Package | Contents |
| ------- | -------- |
| [`standards.open.v1`](https://buf.build/alis-build/common-protos/docs/main:standards.open.v1) | Questionnaires, CSSF regulatory returns, ESG and fund data templates, the `DataFile` wrapper, and shared answer types |
| [`standards.open.fundholdings.v1`](https://buf.build/alis-build/common-protos/docs/main:standards.open.fundholdings.v1) | Holdings, instruments, `SECDIST`, `FTRDIST` and portfolio valuation file layouts from Apex, JTC, Prescient and State Street |
| [`standards.open.distributions.v1`](https://buf.build/alis-build/common-protos/docs/main:standards.open.distributions.v1) | JTC `SECDIST` (security positions) and `TRADDIST` (transactions) CSV file layouts |
| [`standards.open.secdist.v1`](https://buf.build/alis-build/common-protos/docs/main:standards.open.secdist.v1) | JTC `SECDIST` CSV file layout, with the same records as in `standards.open.distributions.v1` |
| [`standards.open.statementm.v1`](https://buf.build/alis-build/common-protos/docs/main:standards.open.statementm.v1) | Monthly Statement M report layouts from Aluwani Asset Management and the GAMS platform |

Each package's page on the Buf Schema Registry has the full overview and a
description of every message and field.

## Conventions

- In `standards.open.v1`, each standard is a top-level message named by its
  `RT` code, for example `RT000MBG3` for the ICI Distributor Due Diligence
  Questionnaire. Most also have an `RT..._batch` message for several responses
  at once.
- Questionnaire fields carry the `(standards.open.v1.fdx_options)` field
  option, defined in `fieldOptionsExtentions.proto`. It records the question
  number and wording, section headings, validation pattern, default answer and
  the earlier answer a follow-up question depends on.
- A completed standard is stored as a `standards.open.v1.DataFile`, which packs
  the standard's message into a `google.protobuf.Any` alongside per-field
  annotations and supporting attachments.
- The `*_definitions.yaml` files next to some questionnaires are glossaries of
  the terms those questionnaires use (for example `KYC` and `CDD`). They are
  not compiled into the schema.

## Practical Use

Import a standard from the repository root:

```proto
import "standards/open/v1/RT000MBG3.proto";
```

Consumers of the Buf Schema Registry module get these packages from
`buf.build/alis-build/common-protos`. Generated Go code lives under
`go.alis.build/common/standards/open/...`.
