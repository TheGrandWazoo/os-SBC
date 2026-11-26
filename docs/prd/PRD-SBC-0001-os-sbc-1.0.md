# PRD-SBC-0001: os-sbc 1.0: SBC for an on-prem PBX behind OPNsense

**Date**: 2026-11-25
**Status**: Draft
**Owner**: Kevin Adams
**Related**: ADR-SBC-0002, ADR-SBC-0003, ADR-SBC-0008; milestones `1.0.0-alpha.1` to `1.0.0`

## Problem

A PBX behind OPNsense today needs static port forwards for SIP and a wide RTP
range, or the SIP ALG-style `os-siproxd`. Static forwards expose the PBX
directly, leave thousands of UDP ports open all the time, and still produce
one-way audio behind NAT. Remote phones are hard to support safely. There is no
view of what calls are up or how loaded the system is.

## Users

- **SMB / branch admin** running FreePBX/Asterisk (or similar) on the LAN, with
  one or more SIP trunks and some remote or home-office phones.
- **MSP** managing several such sites, who wants the same plugin, config backup
  and HA story everywhere.

## Goals

1. The PBX is never reachable from the internet directly. Only the SBC is.
2. Media ports exist only while a call uses them.
3. Remote phones register and call through the SBC with working two-way audio.
4. An admin can see live calls and load from the OPNsense UI.
5. Installs and updates like any OPNsense plugin (ADR-SBC-0006).

## Non-goals (1.0)

- Being a PBX or registrar (no users, dialplan or voicemail on the SBC).
- Transcoding, WebRTC, SRTP termination (need the remote rtpengine option, later).
- IPv6 (parking lot).
- Call-state survival on HA failover (config sync and VIP listening are in 1.0;
  live call replication is later).

## Requirements

### Functional

| ID | Requirement | Priority | Milestone |
|---|---|---|---|
| FR-SBC-SVC-0001 | Enable/disable, start/stop/restart and status for Kamailio and rtpproxy from the UI and API | Must | alpha.1 |
| FR-SBC-SVC-0002 | Config generated from the OPNsense model; invalid config is refused before restart (`kamailio -c`) | Must | alpha.1 |
| FR-SBC-NET-0001 | Choose external and internal interfaces; listen on their addresses (or a CARP VIP) | Must | alpha.1 |
| FR-SBC-NET-0002 | Optional advertised external address for double-NAT setups | Should | alpha.1 |
| FR-SBC-NET-0003 | SIP over UDP and TCP; port configurable | Must | alpha.1 |
| FR-SBC-PBX-0001 | One PBX target (address, port), plus an optional separate port for trunk traffic (ADR-SBC-0008) | Must | alpha.1 |
| FR-SBC-TRK-0001 | Several SIP trunks: address, port, allowed inbound source networks, enabled flag | Must | alpha.1 |
| FR-SBC-TRK-0002 | Inbound calls from a trunk go to the PBX; outbound calls from the PBX go to the chosen trunk | Must | alpha.1 |
| FR-SBC-REG-0001 | Remote phones register through the SBC to the PBX using Path (ADR-SBC-0008) | Must | alpha.1 |
| FR-SBC-REG-0002 | Calls to and from registered remote phones work through NAT | Must | alpha.1 |
| FR-SBC-MEDIA-0001 | Media relayed per call; ports allocated on offer, released on BYE/CANCEL/failure/timeout (ADR-SBC-0003) | Must | alpha.1 |
| FR-SBC-MEDIA-0002 | Configurable relay port range; automatic pf rule for it, which can be turned off | Must | alpha.1 |
| FR-SBC-MEDIA-0003 | Media engine setting: local rtpproxy or remote rtpengine | Should | beta.1 |
| FR-SBC-MON-0001 | Live calls page: caller, callee, trunk or phone, state, duration; refreshes without reload | Must | alpha.2 |
| FR-SBC-MON-0002 | Load: active calls, active relay sessions, SIP requests/s, failures, memory | Must | alpha.2 |
| FR-SBC-MON-0003 | Dashboard widget with active calls and service status | Should | alpha.2 |
| FR-SBC-MON-0004 | SIP and media logs visible in the OPNsense log viewer | Should | alpha.2 |
| FR-SBC-SEC-0001 | Flood protection per source IP with temporary bans | Must | beta.1 |
| FR-SBC-SEC-0002 | Drop known SIP scanner user agents | Must | beta.1 |
| FR-SBC-SEC-0003 | Optional allow-list of source networks for remote phones | Should | beta.1 |
| FR-SBC-SEC-0004 | Hide internal addresses and headers from the WAN side (topology hiding) | Should | beta.1 |
| FR-SBC-SEC-0005 | SIP over TLS on the WAN side, certificate from the OPNsense trust store | Could | beta.1 |
| FR-SBC-HA-0001 | Config sync to the HA peer (OPNsense XMLRPC sync) | Must | beta.1 |
| FR-SBC-HA-0002 | Listen on CARP VIPs so the backup takes over signalling and media | Must | beta.1 |
| FR-SBC-PKG-0001 | Installable from the KSA repository through System > Firmware > Plugins (ADR-SBC-0006) | Must | alpha.1 |

### Non-functional

| ID | Requirement | Target |
|---|---|---|
| NFR-SBC-0001 | No relay port answers when no call is up | Verified by integration test |
| NFR-SBC-0002 | Capacity on a 4-core x86 OPNsense box | 100 concurrent G.711 calls without audio loss (to be measured) |
| NFR-SBC-0003 | Applying settings | Under 10 s, and calls in progress survive a settings apply where the engine allows |
| NFR-SBC-0004 | Supported OPNsense | The current series (26.7 at time of writing) |
| NFR-SBC-0005 | Upgrades | Never crosses a major version without the admin choosing to (ADR-SBC-0005) |
| NFR-SBC-0006 | Every Must requirement has an automated test (unit, template or SIPp) | 100 % |

## Test environment

| Layer | What | Used for |
|---|---|---|
| Automated | OPNsense 26.7 VM on lab Proxmox, FreePBX VM, SIPp | CI `integration` job, every release candidate |
| Real world | Second physical OPNsense firewall | Install from the devel/testing tracks, real NAT and WAN behaviour |
| Real world | Flowroute account with a test number | Inbound and outbound PSTN calls through a real carrier trunk |

Rules for the real-world layer:

- Flowroute credentials, the test number's routing and any IP allow-list
  entries stay out of the repo: GitHub Actions secrets or the PBX only.
- Test calls are manual or scheduled, never on every PR (carrier costs).
- If the second firewall is the backup of an HA pair, take it out of CARP and
  disable config sync for the test first, so neither box overwrites the other.

## Success measures

- A FreePBX lab with one trunk and two remote phones works end to end with no
  port forwards on the firewall.
- Inbound and outbound calls on the Flowroute test number, through the second
  firewall, with two-way audio and no ports left open afterwards.
- No relay ports are open at idle (port scan from WAN).
- Lab install from a clean OPNsense VM in under 10 minutes using only the docs.

## Open questions

1. Which PBXes to document and test for Path support beyond Asterisk PJSIP?
2. Is 100 concurrent calls the right capacity target for the expected sites?
3. Should trunk-vs-phone separation at the PBX use a separate port (current
   plan), or a header the PBX can match on?
4. Shared KSA repository vs repository inside os-SBC (ADR-SBC-0006).

## Change log

| Date | Change |
|---|---|
| 2026-11-25 | First draft. |
