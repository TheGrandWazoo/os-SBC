# ADR-0001: Record architecture and product decisions

**Date**: 2026-11-25
**Status**: Accepted
**Deciders**: Kevin Adams

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

- **ADRs**: `docs/adr/NNNN-title.md`, indexed in `docs/adr/README.md`, using the
  lifecycle and rules defined there. This follows the layout proposed in the
  cross-project alignment notes (convention 1), so os-SBC does not add a fifth
  variant.
- **PRDs**: `docs/prd/NNNN-title.md`, indexed in `docs/prd/README.md`. A PRD says
  *what* a release must do and for whom; ADRs say *how* and *why that way*.
- **Runbooks**: `docs/runbooks/NNNN-title.md` (alignment convention 2).
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
