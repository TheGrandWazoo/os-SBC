# os-SBC documentation map

| Document | Answers | Status |
|---|---|---|
| [prd/](prd/README.md) | What to build, for whom, how we know it worked | PRD-SBC-0001 Draft |
| [adr/](adr/README.md) | Why we chose each approach | ADR-SBC-0001–0002 Accepted, rest Proposed |
| [architecture.md](architecture.md) | How the pieces fit, ports, data flows | Draft |
| [design/](design/) | How a feature works in detail | DES-SBC-0001 Kamailio routing: Draft |
| [testing/test-plan.md](testing/test-plan.md) | What is tested, where, and which requirement each test proves | Draft |
| [security/threat-model.md](security/threat-model.md) | What could go wrong and what stops it | Draft |
| [runbooks/](runbooks/) | Step-by-step operations | RB-SBC-0001 Cut a release |
| [../ROADMAP.md](../ROADMAP.md) | Milestones, parking lot, resolved items | Living |
| [../CONTRIBUTING.md](../CONTRIBUTING.md) | How to work in the repo | Living |

IDs carry the project slug (`ADR-SBC-0004`, `FR-SBC-MEDIA-0001`); the scheme is in
ADR-SBC-0001. Design docs are `DES-SBC-NNNN-title.md`. A design doc moves from
Draft to Approved when its **[verify]** items are resolved in the lab, and is
updated (not replaced) as the code changes.
