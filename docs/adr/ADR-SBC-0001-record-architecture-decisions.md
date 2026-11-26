---
id: ADR-SBC-0001
title: "Record architecture and product decisions"
kind: adr
status: accepted
date: 2026-11-25
decided: 2026-11-25
deciders: [Kevin Adams]
supersedes: []
related: []
---

# ADR-SBC-0001: Record architecture and product decisions

> **In short:** We write decisions down as ADRs and product scope as PRDs, in this repo, next to the code. Every ID carries the project slug (`ADR-SBC-0001`, `FR-SBC-MEDIA-0001`) so it never clashes with another KSA project's IDs.

## Context

os-SBC is restarting after five years idle (last commit 2019-12-02) with a new
engine, a new release model and a package repository of its own. Decisions
like these get lost in chat history and commit messages. The other KSA
projects (freenas-proxmox, mock-idp, slm-saas-poc) already keep ADRs, but each
keeps them in a different place and format
(`claude-scaffold/docs/alignment/2026-10-05-cross-project-alignment.md`).

## Decision

Record decisions as ADRs and product scope as PRDs, both in the repo next to
the code.

- **ADRs**: `docs/adr/ADR-SBC-NNNN-title.md`, indexed in `docs/adr/README.md`,
  using the lifecycle and rules defined there. This follows the folder layout
  proposed in the cross-project alignment notes (convention 1), with the
  project slug added to the ID.
- **PRDs**: `docs/prd/PRD-SBC-NNNN-title.md`, indexed in `docs/prd/README.md`.
  A PRD says *what* a release must do and for whom; ADRs say *how* and *why
  that way*.
- **Design docs**: `docs/design/DES-SBC-NNNN-title.md`.
- **Runbooks**: `docs/runbooks/RB-SBC-NNNN-title.md` (alignment convention 2).

### ID scheme

Every ID that might be quoted outside this repo carries the project slug
`SBC`, so IDs stay unique when KSA projects reference each other (for example
`ADR-SBC-0004` next to freenas-proxmox's `ADR-013`).

| Kind | Format | Example |
|---|---|---|
| Architecture decision | `ADR-SBC-NNNN` | `ADR-SBC-0002` |
| Product requirements doc | `PRD-SBC-NNNN` | `PRD-SBC-0001` |
| Design doc | `DES-SBC-NNNN` | `DES-SBC-0001` |
| Runbook | `RB-SBC-NNNN` | `RB-SBC-0001` |
| Functional requirement | `FR-SBC-<AREA>-NNNN` | `FR-SBC-MEDIA-0001` |
| Non-functional requirement | `NFR-SBC-NNNN` | `NFR-SBC-0008` |
| Threat | `THR-SBC-NNNN` | `THR-SBC-0003` |
| Architecture overview | `ARC-SBC-NNNN` | `ARC-SBC-0001` |
| Test plan | `TST-SBC-NNNN` | `TST-SBC-0001` |
| Threat model | `TM-SBC-NNNN` | `TM-SBC-0001` |

- Numbers are four digits, sequential within their kind (and area, for
  FRs), and never reused.
- Test IDs (`I-REG-1`, `C-1`, ...) stay local to the test plan; outside the
  repo, refer to the requirement a test proves instead.
- For numbered kinds (ADR, PRD, DES, RB) the file name starts with the ID,
  so `git grep ADR-SBC-0004` finds the document and every reference to it.
  One-of-a-kind documents keep their usual names (`architecture.md`,
  `test-plan.md`, `threat-model.md`) and carry their ID in the front matter.

### Document structure: one part for people, one for machines

Every document has the same four parts, in this order, so a reader always
knows where to look and tools never have to parse prose:

1. **Front matter** (machine): a short YAML header with `id`, `title`,
   `kind`, `status`, `date`, owners or deciders, and `related` IDs. GitHub
   shows it as a small table.
2. **"In short"** (people): two to four plain sentences right under the
   title. Someone who reads nothing else still knows what the document says.
3. **Body** (people): prose, tables and diagrams written for a reader. IDs
   appear only where they help someone follow a link.
4. **"Machine-readable"** (machines), only for documents that hold a list
   someone will track: requirements (PRD), tests (test plan), threats
   (threat model). One fenced `yaml` block, and it is the authoritative copy.
   The body summarises it in words and never repeats it item by item.

`tools/check_docs.py` checks all of it: front matter fields and statuses,
unique IDs, file names, that every referenced ID exists, and that every
`must` requirement has a test. It runs in the CI `lint` job.
- **Plan**: `ROADMAP.md` holds the milestones, the ideas parking lot and a
  Resolved log. New ideas land in the parking lot first, then get an issue.

## Consequences

- A decision is not settled until its ADR is Accepted. Code PRs that depend on
  a Proposed ADR say so.
- If the KSA-wide convention settles differently, os-SBC moves to match with a
  new ADR that supersedes this one.

## References

- `claude-scaffold/docs/alignment/2026-10-05-cross-project-alignment.md`
- freenas-proxmox `.claude/cos/adrs/README.md` (lifecycle rules reused here)
- slm-saas-poc `docs/adr/template.md` (section layout reused here)
