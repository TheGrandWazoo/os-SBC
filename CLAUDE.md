# os-SBC — Claude context (KSA Technologies)

This file is the baseline context for any Claude conversation in a KSA
Technologies workspace. Project-specific details are added on top of this.

---

## Environment

- **Shell:** WSL (Linux). Always use bash/Linux syntax — `export VAR=value`,
  forward slashes, `source .venv/activate`. Never PowerShell, never cmd.exe.
- **OS:** WSL2 on Windows. Paths under `/mnt/c/Users/ksatl/OneDrive - ksatechnologies.com/workspace/`.

---

## Agent / Minion Rules

- **Minions are research-only.** They search, read, and web-fetch. They return
  findings to main Claude. They never write files, commit, push, or delete.
- **Minions do not talk to each other.** All findings route through main Claude.
- **Main Claude does all writing, committing, and pushing.**

---

## File Rules

- **New files:** write freely.
- **Changes to existing files:** use targeted edits only — add or modify,
  never blank out content.
- **Total replacement of an existing file:** write the replacement as a NEW
  file first, explain to the user why the old file needs replacing, wait for
  explicit approval. Never silently overwrite.
- **Briefs and reports:** always new dated files. Never overwrite a previous
  brief. The historical record grows forward, never shrinks.

---

## Permission Levels

| Actor | Permissions |
|---|---|
| **User** | Full control — can do anything including delete |
| **Main Claude** | Pre-approved: read, write, edit, commit, push, gh CLI. Must ask before any delete unless user has explicitly pre-authorized it. |
| **Minions** | Research only — read, search, web-fetch. No write, commit, push, or delete. |

---

## Workflow Order

Always follow this sequence. Never skip ahead:

1. **Open a GitHub issue** — captures the problem/feature before any code
2. **Update design/architecture docs** — ADR if warranted, roadmap, architecture
3. **Implement code** — with tests
4. **Update docs** — test-scenarios, user examples, troubleshooting callouts
5. **Close the issue** — with version, commit, and doc pointers

---

## Documentation Discipline

Every feature, breaking change, or config change ships with:
- Code + tests
- Test-scenario examples
- Troubleshooting callouts where relevant
- Architecture/design doc update if the shape changed
- ADR if a significant technology decision was made
- Roadmap `Resolved` update

Never ship a feature without its docs.

---

## Issue Lifecycle

- Close issues when work ships — include version, commit SHA, and doc pointers
- User-filed bugs: add `fixed — awaiting-feedback` label if user confirmation needed
- Dependabot patch/minor: merge when CI is green (ad-hoc, no milestone)
- Dependabot major: open an issue, add to a milestone, test intentionally
- Dependabot CVE: link PR to the security issue, include in relevant milestone

---

## SAFe Hierarchy (GitHub Issues)

| Level | GitHub object | When to use |
|---|---|---|
| **Milestone** | GitHub Milestone | PI / sprint container, ties to a semver release |
| **Feature** | Issue (`enhancement` label + milestone) | Single deployable unit of value — this is the default issue type |
| **Epic** | Issue (`epic` label, no milestone, task list of linked features) | Only when work spans multiple milestones |
| **Story** | Sub-task within a feature | Only when multiple contributors need independently assignable units |

Default: **milestone → feature**. Add epic and story layers only when the
team size and cross-milestone scope justify the overhead.

---

## Technology Governance

Follow the original developer when a project forks due to governance or
ownership breakdown. Validated examples:
- pfSense → **OPNsense** (m0n0wall founder Kasper endorsed it)
- CentOS → **Rocky Linux** (co-founder Kurtzer created it within days)
- nginx → watch **freenginx** (core developer Dounin forked over F5 governance)
- OpenOffice → **LibreOffice** (original developers moved there)

**Avoid:** Oracle (hostile OSS track record), F5/nginx (governance broken),
Bitnami (stale images since 2024 paid tier split).

**Preferred stack:**
- Server OS: Rocky Linux, Debian
- Container base (community): `python:slim-bookworm`
- Container base (production): `python:alpine`
- Container base (enterprise/FIPS): `cgr.dev/chainguard/python`
- CNI: Cilium
- Ingress: Kubernetes Gateway API (Cilium native implementation)
- Secrets: HashiCorp Vault sidecar / CSI driver
- Postgres (single node): `postgres:16-alpine` custom subchart
- Postgres (HA): CloudNativePG operator

---

## ADR Process

ADRs follow an RFC lifecycle: **Draft → Proposed → Accepted / Rejected /
Withdrawn**. When a decision changes, a new ADR is created and the old one
is marked **Superseded** — the historical record is never deleted.

See `ADR-000-process.md` in any project that uses ADRs for the full format
and lifecycle definition.

---

## Git Commit Style

- Conventional commits: `feat:`, `fix:`, `docs:`, `chore:`, `ci:`, `refactor:`
- Co-author line on every commit:
  `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`
- Commit message: why, not what. The diff shows what; the message explains why.
- Never amend published commits. Create new commits instead.
- Never skip hooks (`--no-verify`) unless explicitly instructed.

---

## Memory System

Memory lives at:
`.claude/projects/<workspace-path>/memory/MEMORY.md`

On starting a new session, read `MEMORY.md` first. It indexes all
project-specific memories. Update memory when:
- User corrects an approach or confirms a non-obvious one
- A significant project decision is made
- User preferences or constraints are stated

Never save ephemeral task details to memory — use the todo list for that.

---

## This project: os-SBC

OPNsense plugin (`os-sbc`) that turns the firewall into a SIP Session Border
Controller: Kamailio for signalling, rtpproxy for media (ADR-0002).

- **Repo:** `TheGrandWazoo/os-SBC`. Default and integration branch is `next`.
  Branch, release and backport rules: ADR-0004 and `CONTRIBUTING.md`.
- **Docs layout:** ADRs in `docs/adr/NNNN-*.md`, PRDs in `docs/prd/NNNN-*.md`,
  runbooks in `docs/runbooks/`, design docs in `docs/design/NNNN-*.md`,
  plus `docs/architecture.md`, `docs/testing/test-plan.md` and
  `docs/security/threat-model.md`. Map: `docs/README.md`. Plan and parking
  lot in `ROADMAP.md`.
- **Target platform:** OPNsense 26.7 (FreeBSD 15.1, PHP 8.5, Python 3.13,
  OpenSSL 3.5 from ports). OPNsense does not ship Kamailio or rtpproxy, so this
  project builds and hosts them (ADR-0006, ADR-0007).
- **Plugin layout:** standard opnsense/plugins tree. The package lives at
  `net/sbc` when dropped into an opnsense/plugins checkout.
- **Cannot be tested from WSL:** anything that needs OPNsense, Kamailio or
  FreeBSD runs in CI or on a lab VM. Say so plainly in PRs and issues.
