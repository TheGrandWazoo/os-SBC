# os-SBC roadmap

Agile, not waterfall: milestones are sprints tied to a version. Scope is set
by [PRD-SBC-0001](docs/prd/PRD-SBC-0001-os-sbc-1.0.md); decisions are in
[docs/adr](docs/adr/README.md). New ideas go in the **Parking lot** first and
become issues when we pick them up.

Hierarchy: GitHub milestone → feature issues (`enhancement`). Work spanning
several milestones gets an `epic` issue.

## Milestones

### 0 — Foundation (no release)
- Governance docs: ADR-SBC-0001 to ADR-SBC-0008, PRD-SBC-0001, this roadmap, CONTRIBUTING, templates
- Draft and review: architecture overview, DES-SBC-0001 (Kamailio routing),
  test plan, threat model; resolve the design's [verify] items in the lab
- Fold the threat model's proposed FR-SBC-SEC-0006..0010 / NFR-SBC-0007..0008 into PRD-SBC-0001
- Branch cutover and protection (ADR-SBC-0004)
- Labels and milestones on GitHub
- CI `lint`, `test` and `build` jobs (ADR-SBC-0007)
- Package repository and `os-ksa-repo` bootstrap (ADR-SBC-0006)
- Lab: FreeBSD 15.1 builder VM, OPNsense 26.7 test VM, FreePBX VM, SIPp
- Real-world test bed: the HA backup firewall plus the Flowroute test trunk
  and number (PRD-SBC-0001 "Test environment", RB-SBC-0002)
- Shared package repo `TheGrandWazoo/opnsense-repo` (ADR-SBC-0006, ADR-SBC-0009) — live

### 1.0.0-alpha.1 — Calls pass through
- Remove the Asterisk model, forms and templates from `next`
- Model, settings UI and API: general, interfaces, PBX, trunks
- Kamailio and rtpproxy services, configd actions, boot setup, config check
- Automatic pf rule for SIP and the relay range
- Registration pass-through, inbound and outbound trunk calls, remote phone calls
- Kamailio and rtpproxy built and published to the devel track
- FR-SBC-SVC-0001/0002, FR-SBC-NET-0001/0002/0003, FR-SBC-PBX-0001, FR-SBC-TRK-0001/0002, FR-SBC-REG-0001/0002, FR-SBC-MEDIA-0001/0002, FR-SBC-PKG-0001

### 1.0.0-alpha.2 — See what's happening
- Live calls page and load statistics (Kamailio JSON-RPC, rtpproxy stats)
- Dashboard widget; log viewer integration
- FR-SBC-MON-0001..0004

### 1.0.0-beta.1 — Harden and HA
- Flood protection and bans, scanner drop, allow-lists, topology hiding, TLS
- Remote rtpengine option
- HA config sync and CARP VIP listening
- FR-SBC-SEC-0001..0005, FR-SBC-MEDIA-0003, FR-SBC-HA-0001/0002

### 1.0.0 — Release
- Cut `release/1.x`, release candidates, integration suite green, docs complete

## Parking lot (ideas, not yet scheduled)

- Call state replication across HA peers (Kamailio `dmq` + dialog sync)
- Restrict the relay range to active peers with a pf table (ADR-SBC-0003 follow-up)
- CDRs (Kamailio `acc`), CSV/syslog export
- Per-trunk statistics and health checks (OPTIONS pings), trunk failover
- Prometheus exporter / OPNsense monitoring integration
- Auto-ban attackers into a pf table (fail2ban style)
- IPv6
- WebRTC and SRTP termination (remote rtpengine)
- Contact-rewrite fallback for PBXes without Path (ADR-SBC-0008)
- SIP trace capture per call (HEP to Homer)
- SBOM and build provenance for published packages
- Submit the plugin to opnsense/plugins upstream

## Resolved

| Date | Item | Where |
|---|---|---|
| 2026-11-25 | Engine is Kamailio + rtpproxy, not Asterisk | ADR-SBC-0002 |
| 2026-11-26 | Branching (`next` + `release/N.x`), versioning and channels accepted | ADR-SBC-0004, ADR-SBC-0005 |
| 2026-11-26 | Package repo: separate shared repo, GitHub Pages, freenas-proxmox style | ADR-SBC-0006 |
| 2026-11-26 | IDs carry the project slug; docs split into human and machine-readable parts, checked by `tools/check_docs.py` | ADR-SBC-0001 |
| 2026-11-26 | Carrier tests run on the HA backup firewall | RB-SBC-0002 |
| 2026-11-26 | CI `lint`, `test`, `build` on every PR; first `os-sbc-devel` package built | ADR-SBC-0007, #3 |
| 2026-11-27 | Signed package repo live at thegrandwazoo.github.io/opnsense-repo; os-ksa-repo bootstrap; os-SBC publishes releases it pulls | ADR-SBC-0009, #4 |
