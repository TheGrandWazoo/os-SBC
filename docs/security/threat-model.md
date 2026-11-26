# os-sbc threat model

**Status**: Draft
**Date**: 2026-11-26
**Method**: STRIDE per trust boundary
**Related**: PRD-SBC-0001 (FR-SBC-SEC-*), ADR-SBC-0003, ADR-SBC-0006, ADR-SBC-0008,
[design/DES-SBC-0001-kamailio-routing.md](../design/DES-SBC-0001-kamailio-routing.md)

An SBC faces the internet by design. This document lists what could go wrong,
what stops it, and what risk is left. Mitigations marked **(new)** are not
yet in PRD-SBC-0001; section 5 proposes adding them.

## 1. Assets

| Asset | Why it matters |
|---|---|
| Ability to place calls through the trunk | **Toll fraud** is the classic VoIP loss, often thousands of dollars in a weekend |
| PBX credentials (extension passwords) | Lead directly to toll fraud and eavesdropping |
| Call audio and metadata | Privacy; may be regulated |
| Availability of calls | Phones are often a business's front door; 911 calls |
| The firewall itself | os-sbc runs on the box that protects the whole network |
| Package signing key | Whoever holds it can push code to every install |
| Flowroute account credentials | Toll fraud against the test account |

## 2. Trust boundaries

```mermaid
flowchart LR
    I((Internet)) -- "B1: SIP 5060/5061" --> K[Kamailio]
    I -- "B2: RTP relay range" --> R[rtpproxy]
    K -- "B3: SIP to PBX" --> P[PBX]
    A((Admin)) -- "B4: Web UI / API" --> U[OPNsense MVC]
    U -- "B5: configd, templates" --> K
    K -- "B6: control, JSON-RPC" --> R
    G((GitHub CI)) -- "B7: signed packages" --> F[Firmware / pkg]
    H((HA peer)) -- "B8: XMLRPC sync" --> U
```

## 3. Threats and mitigations

### B1 — SIP from the internet

| # | STRIDE | Threat | Mitigation | Residual |
|---|---|---|---|---|
| THR-SBC-0001 | E | **Toll fraud by open relay**: attacker sends INVITE to the SBC aimed at the carrier | Design rule: WAN traffic only ever goes to the PBX, never to a trunk (design §1.2). Test I-NEG-1. | Low, if the rule holds. A regression would be severe, so I-NEG-1 is a release blocker. |
| THR-SBC-0002 | S | **Spoofed trunk source**: forged UDP from the carrier's IP to skip phone checks | Trunk traffic still only reaches the PBX's trunk port; the PBX's inbound context should only route to DIDs. TCP/TLS trunks cannot be spoofed blind. | Medium for UDP. Document: PBX trunk context must not allow outbound dialing. |
| THR-SBC-0003 | S, E | **Password guessing via REGISTER/INVITE**: the PBX sees every attempt from the SBC's LAN address, so its own fail2ban cannot ban the real source | **(new)** SBC counts 401/403 replies from the PBX per WAN source and bans repeat offenders (`htable`). | Low once added. Without it, **high**: this is the most important new item. |
| THR-SBC-0004 | D | **Flood** of REGISTER/INVITE/OPTIONS | `pike` rate limit plus temporary bans (FR-SBC-SEC-0001); pf state limits. | Medium: a large distributed flood still saturates the WAN link; nothing on the box can fix that. |
| THR-SBC-0005 | I | **Scanning and fingerprinting** | Silent drop for known scanner UAs (FR-SBC-SEC-0002); generic `Server`/`User-Agent` header; no reply to unknown requests where possible. | Low. |
| THR-SBC-0006 | I | **Internal topology leak** (PBX IPs, LAN addresses in Via/Contact/SDP to the carrier) | Topology hiding (FR-SBC-SEC-0004, `topos`). Until beta.1, document the leak. | Medium until beta.1. |
| THR-SBC-0007 | T | **Malformed SIP** exploiting a parser bug | `sanity_check`; Kamailio kept current through the deps pipeline; security updates are a patch release. | Medium: depends on upstream response time. |
| THR-SBC-0008 | E | **Pre-loaded Route headers** to bounce traffic through the SBC | Strip Route on initial WAN requests (design §4.4). Test I-NEG-3. | Low. |
| THR-SBC-0009 | I | **Eavesdropping on signalling** | TLS on WAN (FR-SBC-SEC-0005, Could). | High until TLS ships; same as today's plain-UDP setups. |

### B2 — RTP relay range

| # | STRIDE | Threat | Mitigation | Residual |
|---|---|---|---|---|
| THR-SBC-0010 | I, T | **RTP injection or "RTP bleed"**: attacker sends packets to an allocated port and the relay learns their address, hijacking or receiving audio | Short allocation windows; ports exist only during calls (ADR-SBC-0003). **(new)** Verify rtpproxy's address-latching behaviour and whether it can lock to the SDP address; prefer the stricter mode if offered. | **Unknown until verified.** This is a known class of SBC bug; it needs a lab test before beta.1. |
| THR-SBC-0011 | D | **Port exhaustion**: many fake calls hold relay ports | Calls only start after the PBX accepts them; dialog limits per source **(new)**; media timeout frees dead sessions. | Medium. |
| THR-SBC-0012 | D | **Bandwidth abuse** through the relay | Relay only forwards between the two negotiated endpoints. | Low. |

### B3 — SBC to PBX

| # | STRIDE | Threat | Mitigation | Residual |
|---|---|---|---|---|
| THR-SBC-0013 | E | **PBX trusts the SBC's address** and skips authentication for everything it sends | Docs: the PBX must authenticate phone traffic from the SBC, and accept only DID routing on the trunk port (ADR-SBC-0008). Test I-REG-1 checks the 401 path. | Medium: it is a PBX config mistake we can only document. |
| THR-SBC-0014 | S | **A LAN host pretends to be the PBX** | REGISTER refused from the LAN; **(new)** only accept LAN-side requests from the configured PBX address. | Low once added. |

### B4/B5 — Admin UI, API, configd, templates

| # | STRIDE | Threat | Mitigation | Residual |
|---|---|---|---|---|
| THR-SBC-0015 | T, E | **Config injection**: a field value (trunk description, hostname) breaks out of its place in `kamailio.cfg` or `sbc.conf` and adds directives or shell commands | Strict model validation (masks on every text field, typed fields for IPs/ports); templates only emit validated values; `sbc.conf` values quoted; **(new)** template tests with hostile fixture values. | Low with tests; high without. |
| THR-SBC-0016 | E | **Unprivileged OPNsense user** changes SBC settings | OPNsense ACL `page-services-sbc`; separate read-only ACL for the live-call page **(new)**. | Low. |
| THR-SBC-0017 | I | **Live-call page leaks phone numbers** to UI users who should not see them | Same ACL as above; no call history stored in 1.0. | Low. |

### B6 — Kamailio ⇄ rtpproxy, JSON-RPC

| # | STRIDE | Threat | Mitigation | Residual |
|---|---|---|---|---|
| THR-SBC-0018 | T | **Another local process** controls rtpproxy or Kamailio | rtpproxy control bound to 127.0.0.1 only; JSON-RPC FIFO in `/var/run/kamailio` (mode 0750). Only root and the service users run on a firewall. | Low. |

### B7 — Package supply chain

| # | STRIDE | Threat | Mitigation | Residual |
|---|---|---|---|---|
| THR-SBC-0019 | T, E | **Stolen signing key** pushes malicious packages | Key only in a protected GitHub environment with required approval; never on a laptop; rotation procedure in a runbook **(new)**. | Medium: GitHub account compromise remains a single point; consider hardware-key-protected signing later. |
| THR-SBC-0020 | T | **Compromised dependency or CI action** | Actions pinned to SHAs; Dependabot; deps built from opnsense/ports at pinned commits; SBOM and provenance in the parking lot. | Medium. |
| THR-SBC-0021 | E | **Our repo overrides an OPNsense package** | Lower priority than the OPNsense repo; only ship packages OPNsense lacks (ADR-SBC-0006). | Low. |

### B8 — HA sync

| # | STRIDE | Threat | Mitigation | Residual |
|---|---|---|---|---|
| THR-SBC-0022 | T | **Settings pushed from the wrong peer** during testing | OPNsense XMLRPC sync is authenticated; test procedure takes the test box out of sync (test plan §4). | Low. |

### Secrets in development

| # | Threat | Mitigation |
|---|---|---|
| THR-SBC-0023 | Flowroute credentials, phone numbers or SIP traces with credentials end up in the repo, issues or logs | gitleaks in CI; fixtures use fake numbers and documentation IP ranges; bug template asks for redaction; credentials only in the PBX and protected CI environments. |

## 4. Top risks

1. **THR-SBC-0003 password guessing invisible to the PBX**: add SBC-side auth-failure bans before anyone exposes this to the internet.
2. **THR-SBC-0001 open relay / toll fraud**: protected by one design rule; keep its test a release blocker.
3. **THR-SBC-0010 RTP bleed**: behaviour unknown; must be lab-tested.
4. **THR-SBC-0015 config injection**: validation plus hostile-input template tests.

## 5. Proposed additions to PRD-SBC-0001

| Proposed ID | Requirement | Priority | Milestone |
|---|---|---|---|
| FR-SBC-SEC-0006 | Ban a WAN source after N authentication failures returned by the PBX within M minutes (THR-SBC-0003) | Must | alpha.1 |
| FR-SBC-SEC-0007 | Accept LAN-side requests only from the configured PBX address (THR-SBC-0014) | Must | alpha.1 |
| FR-SBC-SEC-0008 | Limit concurrent dialogs per WAN source (THR-SBC-0011) | Should | beta.1 |
| FR-SBC-SEC-0009 | Media latching locked to the negotiated peer where the engine supports it; documented otherwise (THR-SBC-0010) | Must | beta.1 |
| FR-SBC-SEC-0010 | Read-only ACL for the live-call page (THR-SBC-0016, THR-SBC-0017) | Should | alpha.2 |
| NFR-SBC-0007 | Template tests include hostile input for every free-text field (THR-SBC-0015) | 100 % of text fields |
| NFR-SBC-0008 | Signing key rotation runbook exists before the first stable release (THR-SBC-0019) | 1.0.0 |

Add these to PRD-SBC-0001 when this threat model moves out of Draft.

## 6. Review

Revisit this document whenever a trust boundary changes (TLS, rtpengine,
call-state replication, CDRs), and before every major release.
