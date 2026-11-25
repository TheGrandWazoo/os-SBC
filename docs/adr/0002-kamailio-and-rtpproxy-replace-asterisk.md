# ADR-0002: Kamailio and rtpproxy replace Asterisk as the SBC engine

**Date**: 2026-11-25
**Status**: Accepted
**Deciders**: Kevin Adams
**Related**: ADR-0003, ADR-0006, ADR-0008, PRD-0001

## Context

The 2019 code on `master` drives Asterisk (PJSIP). Asterisk is a back-to-back
user agent (B2BUA) and a PBX. Used as an SBC, it makes you rebuild the PBX's
endpoints, AoRs, identities and dialplan on the firewall. The 2019 UI was
heading that way (seven settings sections before a single call could pass).

What os-SBC needs:

- Pass SIP signalling between the WAN (trunks, remote phones) and the PBX on
  the LAN without becoming a second PBX.
- Relay media per call, opening ports only for the life of the call.
- Pass phone registrations through to the PBX.
- Live call view, statistics and a path to HA.

Packaging facts (checked 2026-11-25):

| Component | FreeBSD port | In OPNsense 26.7's package set |
|---|---|---|
| Kamailio 6.1.3 (`net/kamailio`) | yes; includes the `rtpproxy`, `rtpengine`, `dialog`, `dmq`, `topos`, `path`, `ipops`, `pike` modules | **no** |
| rtpproxy 3.1.1 (`net/rtpproxy`) | yes | **no** |
| OpenSIPS (`net/opensips`) | yes | no |
| rtpengine | **no port** (Linux only) | no |
| Asterisk | yes | no |
| siproxd (`net/siproxd`) | yes | yes (`os-siproxd`) |

## Decision

Use **Kamailio** as the SIP proxy and **rtpproxy** as the media relay, both
running on the firewall. Make the media engine a setting, so Kamailio can
instead drive an **rtpengine** running on a separate Linux host.

- Kamailio stays a proxy, not a B2BUA. The PBX keeps dialplan, users and
  authentication.
- rtpproxy runs in bridge mode, LAN address first and WAN address second.
- The Asterisk code on `master` is frozen, not maintained (see ADR-0004).

## Alternatives considered

- **Keep Asterisk.** Rejected: duplicates the PBX, scales poorly as an SBC, and
  every PBX feature has to be modelled twice.
- **OpenSIPS + rtpproxy.** Technically comparable. Kamailio chosen because of
  existing experience (the `TheGrandWazoo/kamailio` fork, `build-kamailio`), a
  larger community, and a current FreeBSD port.
- **siproxd.** Already packaged for OPNsense, but too limited: no call state,
  no statistics API, no HA story.
- **rtpengine on the firewall.** Not possible: no FreeBSD port, and it relies on
  Linux-only interfaces. Kept as a remote option.

## Consequences

- os-SBC must build and host Kamailio and rtpproxy itself, because OPNsense
  does not ship them (ADR-0006, ADR-0007). This is the largest ongoing cost of
  this decision.
- No transcoding with rtpproxy. Transcoding or WebRTC needs the remote
  rtpengine option.
- The 2019 Asterisk model, forms and templates are removed from `next` by a
  feature PR, after this ADR is merged.

## References

- [FreshPorts net/kamailio](https://freshports.org/net/kamailio)
- [FreshPorts net/rtpproxy](https://freshports.org/net/rtpproxy/)
- [rtpengine overview](https://rtpengine.readthedocs.io/en/latest/overview.html)
- opnsense/tools `config/26.7/ports.conf` (only `net/siproxd` among SIP software)
