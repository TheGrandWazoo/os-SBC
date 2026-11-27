---
id: PRD-SBC-0001
title: "os-sbc 1.0: SBC for an on-prem PBX behind OPNsense"
kind: prd
status: draft
date: 2026-11-25
owners: [Kevin Adams]
related: [ADR-SBC-0002, ADR-SBC-0003, ADR-SBC-0006, ADR-SBC-0008, ARC-SBC-0001, DES-SBC-0001, TST-SBC-0001, TM-SBC-0001]
---

# PRD-SBC-0001: os-sbc 1.0: SBC for an on-prem PBX behind OPNsense

> **In short:** Version 1.0 lets a PBX on the LAN take carrier calls and
> serve remote phones without ever being exposed to the internet. The
> firewall handles SIP and relays audio per call, opening ports only while a
> call is up. Admins see live calls and load in the OPNsense UI, and install
> it from the plugin list like any other plugin.

## The problem

A PBX behind OPNsense today needs static port forwards for SIP and a wide
RTP range, or the limited `os-siproxd` plugin. Port forwards expose the PBX
directly, leave thousands of UDP ports open all the time, and still produce
one-way audio behind NAT. Remote phones are hard to support safely, and
nobody can see which calls are up or how loaded the system is.

## Who it is for

- **SMB or branch admin** running FreePBX/Asterisk (or similar) on the LAN,
  with one or more SIP trunks and some remote or home-office phones.
- **MSP** looking after several such sites, who wants the same plugin, config
  backup and HA story everywhere.

## Goals

1. The PBX is never reachable from the internet directly. Only the SBC is.
2. Audio ports exist only while a call uses them.
3. Remote phones register and call through the SBC with two-way audio.
4. An admin can see live calls and load from the OPNsense UI.
5. It installs and updates like any OPNsense plugin.

## Not in 1.0

- Being a PBX or registrar: no users, dialplan or voicemail on the SBC.
- Transcoding, WebRTC, SRTP termination (they need the remote rtpengine
  option, later).
- IPv6.
- Keeping calls up through an HA failover. Settings sync and failover of new
  calls are in 1.0; live call replication comes later.

## What 1.0 does, by area

The full, authoritative list with priorities and milestones is in the
[Machine-readable](#machine-readable) section at the bottom.

| Area | In plain words | Requirements |
|---|---|---|
| Service (`SVC`) | Turn the SBC on and off, start and stop it, see its status. A bad config is refused instead of breaking a running service. | SVC-0001, 0002 |
| Network (`NET`) | Pick the outside and inside interfaces, SIP port and transports, and an advertised address for double-NAT sites. | NET-0001 to 0003 |
| PBX and trunks (`PBX`, `TRK`) | Point the SBC at one PBX and any number of carrier trunks. Carrier calls go to the PBX; the PBX's outbound calls go to the right trunk. | PBX-0001, TRK-0001, 0002 |
| Remote phones (`REG`) | Phones on the internet register through the SBC to the PBX and make and take calls through NAT. | REG-0001, 0002 |
| Media (`MEDIA`) | Audio is relayed per call and the ports close when the call ends. Firewall rules are added automatically. Optionally use a remote rtpengine instead. | MEDIA-0001 to 0003 |
| Monitoring (`MON`) | A live calls page, load figures, a dashboard widget, and logs in the OPNsense log viewer. | MON-0001 to 0004 |
| Security (`SEC`) | Flood protection with temporary bans, scanners dropped, optional allow-lists, internal addresses hidden, optional TLS. Bans for password guessing the PBX cannot see, only the PBX may talk to the SBC from the LAN, per-source call limits, audio locked to the negotiated peer, and a read-only live view. | SEC-0001 to 0010 |
| HA (`HA`) | Settings sync to the backup firewall, and the SBC listens on the shared CARP addresses. | HA-0001, 0002 |
| Packaging (`PKG`) | Appears in System > Firmware > Plugins once the KSA repository is added. | PKG-0001 |

Quality targets (non-functional) cover idle port exposure, capacity, apply
time, supported OPNsense versions, safe upgrades, test coverage, hostile-input
tests for settings, and a signing-key rotation procedure: NFR-SBC-0001 to 0008.

## How we know it worked

- A FreePBX lab with one trunk and two remote phones works end to end with no
  port forwards on the firewall.
- Inbound and outbound calls on the Flowroute test number, through the HA
  backup firewall, with two-way audio and no ports left open afterwards.
- No relay ports are open at idle (port scan from the WAN).
- A clean OPNsense VM goes from nothing to a working call in under 10 minutes
  using only the docs.

## Test environment

| Layer | What | Used for |
|---|---|---|
| Automated | OPNsense 26.7 VM on lab Proxmox, FreePBX VM, SIPp | CI `integration` job, every release candidate |
| Real world | The **HA backup** physical OPNsense firewall | Real NAT and WAN behaviour, installs from the devel and testing tracks; later the HA tests |
| Real world | Flowroute account with a test number | Inbound and outbound PSTN calls through a real carrier trunk |

The backup belongs to the production HA pair, so testing on it follows
[RB-SBC-0002](../runbooks/RB-SBC-0002-prepare-ha-backup-for-testing.md):
stop config sync from the primary, leave CARP running so production can still
fail over, bind the test SBC to the backup's own addresses (never the CARP
addresses), and point the Flowroute test number at the backup's own WAN
address. Flowroute credentials stay out of the repo.

## Open questions

1. Which PBXes to document and test for Path support beyond Asterisk PJSIP?
2. Is 100 concurrent calls the right capacity target for the expected sites?
3. Should the PBX tell trunk traffic from phone traffic by a separate port
   (current plan) or by a header?
4. Does the HA pair's ISP give each firewall its own public address? Carrier
   tests on the backup need one.

## Change log

| Date | Change |
|---|---|
| 2026-11-25 | First draft. |
| 2026-11-26 | IDs carry the project slug. Split into human and machine-readable parts. Test environment: the second firewall is the HA backup. |
| 2026-11-27 | Added FR-SBC-SEC-0006 to 0010 and NFR-SBC-0007, 0008 from the threat model (TM-SBC-0001), with tests (#8). |

## Machine-readable

Authoritative requirement register. `tools/check_docs.py` validates it.
Priorities: `must`, `should`, `could`. Status: `draft`, `approved`,
`shipped`, `dropped`.

```yaml
requirements:
  - {id: FR-SBC-SVC-0001, priority: must, milestone: 1.0.0-alpha.1, status: draft,
     title: "Enable/disable, start/stop/restart and status for Kamailio and rtpproxy from the UI and API"}
  - {id: FR-SBC-SVC-0002, priority: must, milestone: 1.0.0-alpha.1, status: draft,
     title: "Config generated from the OPNsense model; an invalid config is refused before restart (kamailio -c)"}
  - {id: FR-SBC-NET-0001, priority: must, milestone: 1.0.0-alpha.1, status: draft,
     title: "Choose external and internal interfaces; listen on their addresses or a CARP VIP"}
  - {id: FR-SBC-NET-0002, priority: should, milestone: 1.0.0-alpha.1, status: draft,
     title: "Optional advertised external address for double-NAT setups"}
  - {id: FR-SBC-NET-0003, priority: must, milestone: 1.0.0-alpha.1, status: draft,
     title: "SIP over UDP and TCP; port configurable"}
  - {id: FR-SBC-PBX-0001, priority: must, milestone: 1.0.0-alpha.1, status: draft, adr: [ADR-SBC-0008],
     title: "One PBX target (address, port) plus an optional separate port for trunk traffic"}
  - {id: FR-SBC-TRK-0001, priority: must, milestone: 1.0.0-alpha.1, status: draft,
     title: "Several SIP trunks: address, port, allowed inbound source networks, enabled flag"}
  - {id: FR-SBC-TRK-0002, priority: must, milestone: 1.0.0-alpha.1, status: draft,
     title: "Inbound calls from a trunk go to the PBX; outbound calls from the PBX go to the chosen trunk"}
  - {id: FR-SBC-REG-0001, priority: must, milestone: 1.0.0-alpha.1, status: draft, adr: [ADR-SBC-0008],
     title: "Remote phones register through the SBC to the PBX using Path"}
  - {id: FR-SBC-REG-0002, priority: must, milestone: 1.0.0-alpha.1, status: draft,
     title: "Calls to and from registered remote phones work through NAT"}
  - {id: FR-SBC-MEDIA-0001, priority: must, milestone: 1.0.0-alpha.1, status: draft, adr: [ADR-SBC-0003],
     title: "Media relayed per call; ports allocated on offer, released on BYE, CANCEL, failure or timeout"}
  - {id: FR-SBC-MEDIA-0002, priority: must, milestone: 1.0.0-alpha.1, status: draft, adr: [ADR-SBC-0003],
     title: "Configurable relay port range; automatic pf rule for it, which can be turned off"}
  - {id: FR-SBC-MEDIA-0003, priority: should, milestone: 1.0.0-beta.1, status: draft, adr: [ADR-SBC-0002],
     title: "Media engine setting: local rtpproxy or remote rtpengine"}
  - {id: FR-SBC-MON-0001, priority: must, milestone: 1.0.0-alpha.2, status: draft,
     title: "Live calls page: caller, callee, trunk or phone, state, duration; refreshes without reload"}
  - {id: FR-SBC-MON-0002, priority: must, milestone: 1.0.0-alpha.2, status: draft,
     title: "Load: active calls, active relay sessions, SIP requests per second, failures, memory"}
  - {id: FR-SBC-MON-0003, priority: should, milestone: 1.0.0-alpha.2, status: draft,
     title: "Dashboard widget with active calls and service status"}
  - {id: FR-SBC-MON-0004, priority: should, milestone: 1.0.0-alpha.2, status: draft,
     title: "SIP and media logs visible in the OPNsense log viewer"}
  - {id: FR-SBC-SEC-0001, priority: must, milestone: 1.0.0-beta.1, status: draft,
     title: "Flood protection per source IP with temporary bans"}
  - {id: FR-SBC-SEC-0002, priority: must, milestone: 1.0.0-beta.1, status: draft,
     title: "Drop known SIP scanner user agents"}
  - {id: FR-SBC-SEC-0003, priority: should, milestone: 1.0.0-beta.1, status: draft,
     title: "Optional allow-list of source networks for remote phones"}
  - {id: FR-SBC-SEC-0004, priority: should, milestone: 1.0.0-beta.1, status: draft,
     title: "Hide internal addresses and headers from the WAN side (topology hiding)"}
  - {id: FR-SBC-SEC-0005, priority: could, milestone: 1.0.0-beta.1, status: draft,
     title: "SIP over TLS on the WAN side, certificate from the OPNsense trust store"}
  - {id: FR-SBC-SEC-0006, priority: must, milestone: 1.0.0-alpha.1, status: draft, threats: [THR-SBC-0003],
     title: "Ban a WAN source after N authentication failures returned by the PBX within M minutes"}
  - {id: FR-SBC-SEC-0007, priority: must, milestone: 1.0.0-alpha.1, status: draft, threats: [THR-SBC-0014],
     title: "Accept LAN-side requests only from the configured PBX address"}
  - {id: FR-SBC-SEC-0008, priority: should, milestone: 1.0.0-beta.1, status: draft, threats: [THR-SBC-0011],
     title: "Limit concurrent dialogs per WAN source"}
  - {id: FR-SBC-SEC-0009, priority: must, milestone: 1.0.0-beta.1, status: draft, threats: [THR-SBC-0010],
     title: "Media latching locked to the negotiated peer where the engine supports it; documented otherwise"}
  - {id: FR-SBC-SEC-0010, priority: should, milestone: 1.0.0-alpha.2, status: draft, threats: [THR-SBC-0016, THR-SBC-0017],
     title: "Read-only ACL for the live-call page"}
  - {id: FR-SBC-HA-0001, priority: must, milestone: 1.0.0-beta.1, status: draft,
     title: "Config sync to the HA peer (OPNsense XMLRPC sync)"}
  - {id: FR-SBC-HA-0002, priority: must, milestone: 1.0.0-beta.1, status: draft,
     title: "Listen on CARP VIPs so the backup takes over signalling and media"}
  - {id: FR-SBC-PKG-0001, priority: must, milestone: 1.0.0-alpha.1, status: draft, adr: [ADR-SBC-0006],
     title: "Installable from the KSA repository through System > Firmware > Plugins"}
  - {id: NFR-SBC-0001, priority: must, milestone: 1.0.0-alpha.1, status: draft,
     title: "No relay port answers when no call is up", target: "verified by integration test"}
  - {id: NFR-SBC-0002, priority: must, milestone: 1.0.0-beta.1, status: draft,
     title: "Capacity on a 4-core x86 OPNsense box", target: "100 concurrent G.711 calls without audio loss (to be measured)"}
  - {id: NFR-SBC-0003, priority: must, milestone: 1.0.0-beta.1, status: draft,
     title: "Applying settings is quick", target: "under 10 s; calls in progress survive where the engine allows"}
  - {id: NFR-SBC-0004, priority: must, milestone: 1.0.0, status: draft,
     title: "Supported OPNsense", target: "the current series (26.7 at time of writing)"}
  - {id: NFR-SBC-0005, priority: must, milestone: 1.0.0, status: draft, adr: [ADR-SBC-0005],
     title: "Upgrades never cross a major version without the admin choosing to"}
  - {id: NFR-SBC-0006, priority: must, milestone: 1.0.0, status: draft,
     title: "Every must requirement has an automated test", target: "100 %"}
  - {id: NFR-SBC-0007, priority: must, milestone: 1.0.0-alpha.1, status: draft, threats: [THR-SBC-0015],
     title: "Template tests include hostile input for every free-text field", target: "100 % of text fields"}
  - {id: NFR-SBC-0008, priority: must, milestone: 1.0.0, status: draft, threats: [THR-SBC-0019],
     title: "Signing key rotation runbook exists before the first stable release"}
```
