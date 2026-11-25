# os-SBC roadmap

Agile, not waterfall: milestones are sprints tied to a version. Scope is set
by [PRD-0001](docs/prd/0001-os-sbc-1.0.md); decisions are in
[docs/adr](docs/adr/README.md). New ideas go in the **Parking lot** first and
become issues when we pick them up.

Hierarchy: GitHub milestone → feature issues (`enhancement`). Work spanning
several milestones gets an `epic` issue.

## Milestones

### 0 — Foundation (no release)
- Governance docs: ADRs 0001–0008, PRD-0001, this roadmap, CONTRIBUTING, templates
- Branch cutover and protection (ADR-0004)
- Labels and milestones on GitHub
- CI `lint`, `test` and `build` jobs (ADR-0007)
- Package repository and `os-ksa-repo` bootstrap (ADR-0006)
- Lab: FreeBSD 15.1 builder VM, OPNsense 26.7 test VM, FreePBX VM, SIPp
- Real-world test bed: the second physical OPNsense firewall plus the Flowroute
  test trunk and number (see PRD-0001 "Test environment")

### 1.0.0-alpha.1 — Calls pass through
- Remove the Asterisk model, forms and templates from `next`
- Model, settings UI and API: general, interfaces, PBX, trunks
- Kamailio and rtpproxy services, configd actions, boot setup, config check
- Automatic pf rule for SIP and the relay range
- Registration pass-through, inbound and outbound trunk calls, remote phone calls
- Kamailio and rtpproxy built and published to the devel track
- FR-SVC-1/2, FR-NET-1/2/3, FR-PBX-1, FR-TRK-1/2, FR-REG-1/2, FR-MEDIA-1/2, FR-PKG-1

### 1.0.0-alpha.2 — See what's happening
- Live calls page and load statistics (Kamailio JSON-RPC, rtpproxy stats)
- Dashboard widget; log viewer integration
- FR-MON-1..4

### 1.0.0-beta.1 — Harden and HA
- Flood protection and bans, scanner drop, allow-lists, topology hiding, TLS
- Remote rtpengine option
- HA config sync and CARP VIP listening
- FR-SEC-1..5, FR-MEDIA-3, FR-HA-1/2

### 1.0.0 — Release
- Cut `release/1.x`, release candidates, integration suite green, docs complete

## Parking lot (ideas, not yet scheduled)

- Call state replication across HA peers (Kamailio `dmq` + dialog sync)
- Restrict the relay range to active peers with a pf table (ADR-0003 follow-up)
- CDRs (Kamailio `acc`), CSV/syslog export
- Per-trunk statistics and health checks (OPTIONS pings), trunk failover
- Prometheus exporter / OPNsense monitoring integration
- Auto-ban attackers into a pf table (fail2ban style)
- IPv6
- WebRTC and SRTP termination (remote rtpengine)
- Contact-rewrite fallback for PBXes without Path (ADR-0008)
- SIP trace capture per call (HEP to Homer)
- SBOM and build provenance for published packages
- Submit the plugin to opnsense/plugins upstream

## Resolved

| Date | Item | Where |
|---|---|---|
| 2026-11-25 | Engine is Kamailio + rtpproxy, not Asterisk | ADR-0002 |
