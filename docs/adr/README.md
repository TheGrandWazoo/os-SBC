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
| **Superseded by ADR-SBC-NNNN** | Replaced by a newer ADR. Kept as history. |
| **Deprecated** | Was accepted, no longer applies, and nothing replaces it. |

## Rules

- IDs are `ADR-SBC-NNNN`: project slug plus four digits, sequential, never
  reused. The file name starts with the ID. Full scheme: ADR-SBC-0001.
- Never edit the **Decision** section of an Accepted ADR. Write a new ADR and
  mark the old one `Superseded by ADR-SBC-NNNN`.
- Context and Consequences of an Accepted ADR may get light fixes (typos,
  links). A note pointing forward is fine; rewriting history is not.
- An ADR that changes the shape of the system also updates `ROADMAP.md` and
  any affected PRD in the same PR.

## Index

| ADR | Title | Status |
|---|---|---|
| [ADR-SBC-0001](ADR-SBC-0001-record-architecture-decisions.md) | Record architecture and product decisions | Accepted |
| [ADR-SBC-0002](ADR-SBC-0002-kamailio-and-rtpproxy-replace-asterisk.md) | Kamailio and rtpproxy replace Asterisk as the SBC engine | Accepted |
| [ADR-SBC-0003](ADR-SBC-0003-media-anchoring-not-dynamic-pinholes.md) | Anchor media on the firewall instead of opening dynamic pf pinholes | Proposed |
| [ADR-SBC-0004](ADR-SBC-0004-branching-and-release-model.md) | Branching and release model: `next` plus `release/N.x` | Accepted |
| [ADR-SBC-0005](ADR-SBC-0005-versioning-and-package-channels.md) | Versioning and package channels | Accepted |
| [ADR-SBC-0006](ADR-SBC-0006-package-repository-and-opnsense-integration.md) | Signed package repository that OPNsense lists as plugins | Accepted |
| [ADR-SBC-0007](ADR-SBC-0007-ci-pipeline.md) | CI pipeline: lint, test, build, integrate, publish | Proposed |
| [ADR-SBC-0008](ADR-SBC-0008-registration-pass-through-with-path.md) | Registration pass-through: the PBX stays the registrar | Proposed |
