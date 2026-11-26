# os-SBC documentation map

| Document | Answers | Status |
|---|---|---|
| [prd/](prd/README.md) | What to build, for whom, how we know it worked | PRD-0001 Draft |
| [adr/](adr/README.md) | Why we chose each approach | 0001–0002 Accepted, rest Proposed |
| [architecture.md](architecture.md) | How the pieces fit, ports, data flows | Draft |
| [design/](design/) | How a feature works in detail | 0001 Kamailio routing: Draft |
| [testing/test-plan.md](testing/test-plan.md) | What is tested, where, and which requirement each test proves | Draft |
| [security/threat-model.md](security/threat-model.md) | What could go wrong and what stops it | Draft |
| [runbooks/](runbooks/) | Step-by-step operations | 0001 Cut a release |
| [../ROADMAP.md](../ROADMAP.md) | Milestones, parking lot, resolved items | Living |
| [../CONTRIBUTING.md](../CONTRIBUTING.md) | How to work in the repo | Living |

Design docs are numbered `NNNN-title.md` like ADRs. A design doc moves from
Draft to Approved when its **[verify]** items are resolved in the lab, and is
updated (not replaced) as the code changes.
