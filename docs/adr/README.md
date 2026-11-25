# Architecture Decision Records

ADRs record the significant decisions about os-SBC: what was decided, why,
and what it costs. Copy [`template.md`](template.md) to start a new one.

## Lifecycle

| Status | Meaning |
|---|---|
| **Draft** | Being written. Not binding. Edit freely. |
| **Proposed** | Written down and ready for a decision. Still open for argument. |
| **Accepted** | Decided and in effect. Guides implementation. |
| **Rejected** | Decided against. Kept so we remember why. |
| **Withdrawn** | Dropped before a decision was made. |
| **Superseded by ADR-NNNN** | Replaced by a newer ADR. Kept as history. |
| **Deprecated** | Was accepted, no longer applies, and nothing replaces it. |

## Rules

- Numbers are sequential, four digits, and never reused.
- Never edit the **Decision** section of an Accepted ADR. Write a new ADR and
  mark the old one `Superseded by ADR-NNNN`.
- Context and Consequences of an Accepted ADR may get light fixes (typos,
  links). A note pointing forward is fine; rewriting history is not.
- An ADR that changes the shape of the system also updates `ROADMAP.md` and
  any affected PRD in the same PR.

## Index

| ADR | Title | Status |
|---|---|---|
| [0001](0001-record-architecture-decisions.md) | Record architecture and product decisions | Accepted |
| [0002](0002-kamailio-and-rtpproxy-replace-asterisk.md) | Kamailio and rtpproxy replace Asterisk as the SBC engine | Accepted |
| [0003](0003-media-anchoring-not-dynamic-pinholes.md) | Anchor media on the firewall instead of opening dynamic pf pinholes | Proposed |
| [0004](0004-branching-and-release-model.md) | Branching and release model: `next` plus `release/N.x` | Proposed |
| [0005](0005-versioning-and-package-channels.md) | Versioning and package channels | Proposed |
| [0006](0006-package-repository-and-opnsense-integration.md) | Signed package repository that OPNsense lists as plugins | Proposed |
| [0007](0007-ci-pipeline.md) | CI pipeline: lint, test, build, integrate, publish | Proposed |
| [0008](0008-registration-pass-through-with-path.md) | Registration pass-through: the PBX stays the registrar | Proposed |
