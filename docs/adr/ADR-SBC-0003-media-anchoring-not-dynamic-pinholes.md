---
id: ADR-SBC-0003
title: "Anchor media on the firewall instead of opening dynamic pf pinholes"
kind: adr
status: proposed
date: 2026-11-25
deciders: [Kevin Adams]
supersedes: []
related: [ADR-SBC-0002, PRD-SBC-0001, FR-SBC-MEDIA-0001, FR-SBC-MEDIA-0002]
---

# ADR-SBC-0003: Anchor media on the firewall instead of opening dynamic pf pinholes

> **In short:** Audio for every call goes through the firewall's own relay, which opens a port pair when the call starts and closes it when the call ends. We do not open firewall pinholes or port forwards to the PBX.

## Context

The goal is to open RTP ports only while a call needs them, based on the SDP
in the SIP messages, and close them when the call ends. There are two ways to
get that on OPNsense:

1. **Dynamic pinholes (ALG style).** Watch SIP, read the SDP, add pf rules to
   an anchor for each call, remove them on BYE.
2. **Media anchoring.** Kamailio rewrites the SDP so both sides send media to
   the firewall itself, and rtpproxy relays between WAN and LAN. Each call gets
   its own port pair, which rtpproxy opens on offer and closes on BYE, CANCEL,
   failure or media timeout.

## Decision

Use **media anchoring**. The plugin adds one automatic pf rule per enabled
external interface: allow UDP to *this firewall* on the configured relay range.
Nothing in that range answers unless rtpproxy has allocated the port to a live
call.

- Kamailio calls the relay on INVITE, re-INVITE, UPDATE, ACK and replies with
  SDP, and tears the session down on BYE, CANCEL and failure replies.
- Idle sessions also expire through rtpproxy's own media timeout, so a lost
  BYE cannot leave a port open forever.
- The automatic rule can be turned off for admins who want to write their own.

## Alternatives considered

- **Dynamic pf pinholes.** Rejected:
  - it cannot read SDP once signalling is encrypted (TLS), which is on the roadmap;
  - it still forwards media to internal hosts, so the SBC is not really in the path;
  - pf rule churn on every call, and stale rules if a BYE is missed;
  - one-way-audio NAT problems it cannot fix without rewriting SDP anyway.
- **Static port forwards to the PBX.** Today's workaround; this is what we are
  replacing.

## Consequences

- Media always flows through the firewall. Plan CPU and bandwidth for it
  (rtpproxy is userspace on FreeBSD).
- SRTP passes through untouched. Terminating SRTP needs the rtpengine option.
- An optional later step: also restrict the relay range to known peers with a
  pf table fed from active sessions. Tracked in the roadmap parking lot, not
  part of 1.0.
