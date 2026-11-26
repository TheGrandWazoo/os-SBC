---
id: ADR-SBC-0008
title: "Registration pass-through: the PBX stays the registrar"
kind: adr
status: proposed
date: 2026-11-25
deciders: [Kevin Adams]
supersedes: []
related: [ADR-SBC-0002, PRD-SBC-0001, FR-SBC-REG-0001, FR-SBC-REG-0002]
---

# ADR-SBC-0008: Registration pass-through: the PBX stays the registrar

> **In short:** Phones register through the SBC, but the PBX still checks passwords and remembers where each phone is. The SBC only adds a header so calls can find their way back to the phone through its NAT.

## Context

Remote phones on the internet need to register to the PBX behind OPNsense.
The SBC could either be a registrar itself (store locations, authenticate) or
forward registrations to the PBX.

## Decision

Forward registrations. The PBX stays the only registrar and the only place
users and passwords live.

- Phones register to the SBC's WAN address.
- Kamailio adds a `Path` header (RFC 3327) carrying the phone's real NAT
  address, and forwards the REGISTER to the PBX.
- The PBX authenticates and stores the contact plus the Path. Calls to the phone
  come back through the SBC, which uses the Path to reach the phone through its
  NAT.
- NAT keepalive is left to the phones (or the PBX's qualify/OPTIONS) in 1.0.

## Alternatives considered

- **SBC as registrar.** Duplicates users onto the firewall. Rejected for 1.0.
- **Rewrite contacts instead of Path.** Works with PBXes that lack Path support,
  but breaks when a phone has several contacts. Possible later fallback setting.

## Consequences

- The PBX must support Path. In Asterisk PJSIP this is `support_path=yes` on the
  AoR and endpoint. Other PBXes (FreeSWITCH, 3CX, FreePBX) need checking and a
  line each in the docs.
- Registration flood protection on the SBC is still needed (pike, bans), even
  though authentication happens on the PBX.
- The PBX needs a way to tell trunk traffic from phone traffic, since both now
  arrive from the SBC's LAN address. 1.0 sends trunk traffic to a separate PBX
  port (setting), and documents that.
