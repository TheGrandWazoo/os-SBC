# os-sbc: SIP Session Border Controller for OPNsense

> **In short:** os-sbc turns an OPNsense firewall into a SIP Session Border
> Controller, so a PBX on the LAN can take carrier calls and serve remote
> phones without being exposed to the internet. It uses Kamailio for SIP and
> rtpproxy for audio, opening media ports only while a call is up. It is in
> early development: the 1.0 plan is in the
> [PRD](docs/prd/PRD-SBC-0001-os-sbc-1.0.md).

## Status

| | |
|---|---|
| Version | 1.0.0 in development (`os-sbc-devel`); nothing released yet |
| OPNsense | 26.7 |
| Engine | Kamailio 6.1, rtpproxy 3.1 ([ADR-SBC-0002](docs/adr/ADR-SBC-0002-kamailio-and-rtpproxy-replace-asterisk.md)) |
| Plan | [ROADMAP.md](ROADMAP.md), epic #12 |

The development package installs, but it does not do anything useful yet:
the Kamailio integration starts with milestone 1.0.0-alpha.1. Kamailio and
rtpproxy are not in OPNsense's own repository, so the KSA repository carries
our builds of them, made against OPNsense's own packages
([ADR-SBC-0010](docs/adr/ADR-SBC-0010-build-dependencies-on-hosted-freebsd-vms.md)).

## Install

1. Add the KSA package repository (once per firewall), from a shell:

   ```sh
   pkg add https://thegrandwazoo.github.io/opnsense-repo/os-ksa-repo.pkg
   ```

2. Open **System > Firmware > Plugins**, click **Check for updates**, and
   install **os-sbc** (released versions) or **os-sbc-devel** (latest
   development build of `next`).

Details, tracks and the manual method:
[TheGrandWazoo/opnsense-repo](https://github.com/TheGrandWazoo/opnsense-repo).

## Documentation

Start at [docs/README.md](docs/README.md). Contributing:
[CONTRIBUTING.md](CONTRIBUTING.md).
