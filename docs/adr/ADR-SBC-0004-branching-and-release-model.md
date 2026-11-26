# ADR-SBC-0004: Branching and release model: `next` plus `release/N.x`

**Date**: 2026-11-25
**Status**: Proposed
**Deciders**: Kevin Adams
**Related**: ADR-SBC-0005, ADR-SBC-0007, `CONTRIBUTING.md`, `docs/runbooks/RB-SBC-0001-cut-a-release.md`

## Context

The repo has one branch, `master`, holding unreleased Asterisk code from 2019.
Nothing has ever been released. We want a Debian-like model: one branch where
work happens, and release branches that only take fixes.

freenas-proxmox ADR-013 solved the same naming problem: name branches by
**role**, never by a rolling label, so no file or CI rule needs editing at a
cutover (Debian DEP-14). That model has `main` (current stable line), `next`
(next major) and `release/N.x` (archived majors). os-SBC has no stable line yet,
so it needs a simpler variant.

## Decision

### Long-lived branches

| Branch | Role | Who writes to it |
|---|---|---|
| `next` | **Integration branch and GitHub default.** All work lands here first. Builds the `os-sbc-devel` package. | PRs only |
| `release/N.x` | **One per major release line** (e.g. `release/1.x`), cut from `next` when N.0.0 goes to release candidate. Takes fixes only. All `vN.M.P` tags live here. Builds `os-sbc`. | Backport PRs only |
| `release/N.M` | Only if an older minor must be patched after `release/N.x` has moved on. Not created by default. | Backport PRs only |
| `archive/*` | Frozen history: `archive/v0-asterisk` (today's `master`), `archive/2018-skeleton` (the pre-git local copy). | Nobody |

Names never change once assigned. A new major gets a new `release/N.x`;
`next` stays `next`.

### Working branches

- Named `<type>/<issue>-<slug>`: `feat/12-rtpproxy-service`, `fix/31-bye-leak`,
  `docs/`, `ci/`, `chore/`, `refactor/`, `spike/`. Backports use
  `backport/<issue>-<slug>-N.x`.
- One issue, one branch, one PR. No stacked PRs. Branch from `next`, PR into
  `next`.
- Fixes for a release line land on `next` first, then are cherry-picked
  (`git cherry-pick -x`) into a backport PR against `release/N.x`. The only
  exception is a fix for code that no longer exists on `next`.
- PRs merge with merge commits. Kevin merges. Branches are deleted on merge.

### Protection

On `next` and `release/*`: PR required, required status checks (the `lint`,
`test` and `build` jobs from ADR-SBC-0007), no force pushes, no deletions, rules
apply to admins. `archive/*` is locked read-only.

### Cutover from today's state

1. Create `next` from `master` (history kept), make it the default branch.
2. Rename `master` to `archive/v0-asterisk` using GitHub's rename API, which
   redirects old links. Tag its tip `v0.1.0-asterisk`.
3. Push `archive/2018-skeleton`.
4. Apply protection, then do all further work through PRs into `next`.

## Alternatives considered

- **ADR-013 as-is (`main` + `next`).** Rejected for now: with no released line,
  `main` and `next` would be the same thing. If os-SBC ever needs a current
  stable line developed separately from the next major, adopt `main` by
  superseding this ADR.
- **Git-flow (`develop`/`master`/`release/*`/`hotfix/*`).** More branches than a
  single maintainer needs, and `master` would become a rolling "latest release"
  pointer, the exact defect DEP-14 warns about.
- **Trunk only with tags.** No place to patch 1.x while `next` carries 2.0 work.

## Consequences

- `next` must always build and pass checks; it is what `os-sbc-devel` users run.
- The OPNsense project uses the same shape (`master` plus `stable/YY.M`), so
  contributors from there will recognise it.
- Differs from freenas-proxmox (no `main`). Recorded in the cross-project
  alignment notes as a deliberate variant, not drift.

## References

- freenas-proxmox ADR-013 (role-based branching)
- [DEP-14](https://dep-team.pages.debian.net/deps/dep14/)
