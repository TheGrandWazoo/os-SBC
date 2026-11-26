# os-SBC documentation map

> **In short:** Start with the PRD (what we're building) and the
> architecture page (how it fits together). ADRs explain why each choice was
> made. Every document opens with a plain-English "In short"; lists that tools
> track live in a "Machine-readable" section at the bottom.

## Where to find things

| Document | Answers | ID | Status |
|---|---|---|---|
| [PRD](prd/PRD-SBC-0001-os-sbc-1.0.md) | What 1.0 must do, for whom, and how we know it worked | PRD-SBC-0001 | Draft |
| [Architecture overview](architecture.md) | How the pieces fit, ports, data flows | ARC-SBC-0001 | Draft |
| [ADRs](adr/README.md) | Why we chose each approach | ADR-SBC-0001 to 0008 | 0001, 0002, 0004–0007 Accepted; rest Proposed |
| [Kamailio routing design](design/DES-SBC-0001-kamailio-routing.md) | How each SIP message is routed and media relayed | DES-SBC-0001 | Draft |
| [Test plan](testing/test-plan.md) | What is tested, where, and which requirement each test proves | TST-SBC-0001 | Draft |
| [Threat model](security/threat-model.md) | What could go wrong and what stops it | TM-SBC-0001 | Draft |
| [Release runbook](runbooks/RB-SBC-0001-cut-a-release.md) | How to cut and ship a release | RB-SBC-0001 | Active |
| [HA backup test runbook](runbooks/RB-SBC-0002-prepare-ha-backup-for-testing.md) | How to use the HA backup firewall for testing safely | RB-SBC-0002 | Draft |
| [Roadmap](../ROADMAP.md) | Milestones, ideas parking lot, resolved items | — | Living |
| [Contributing](../CONTRIBUTING.md) | How to work in the repo | — | Living |

## How every document is laid out

1. **Front matter**: a small YAML header (ID, status, date, related IDs).
   GitHub shows it as a table at the top. It's for tools; you can skip it.
2. **In short**: two to four plain sentences. Read this first.
3. **Body**: written for people.
4. **Machine-readable** (PRD, test plan, threat model only): the full list
   of requirements, tests or threats as YAML. This is the authoritative copy;
   the body summarises it in words.

IDs carry the project slug (`ADR-SBC-0004`, `FR-SBC-MEDIA-0001`) so they never
clash with other KSA projects. The full scheme is in
[ADR-SBC-0001](adr/ADR-SBC-0001-record-architecture-decisions.md).

A design doc moves from Draft to Approved when its **[verify]** items are
resolved in the lab, and is updated (not replaced) as the code changes.

## Checking the docs

```bash
uv run tools/check_docs.py            # structure, IDs, references, coverage
uv run tools/check_docs.py --matrix   # which tests prove which requirement
```

It will run in CI on every pull request once the `lint` job exists. New
documents start from the `template.md` in each folder.
