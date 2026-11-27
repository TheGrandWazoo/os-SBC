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
| Version | 1.0.0 in development (devel track only); nothing released yet |
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

   Then open **System > Firmware > Plugins**, find `os-ksa-repo` (it shows as
   *misconfigured*, because `pkg add` does not tell OPNsense it was chosen)
   and click **reinstall**. That registers it and records its repository.

2. Until 1.0 ships, os-sbc exists only on the **devel** track, which is off
   by default so production firewalls only ever see releases
   ([ADR-SBC-0011](docs/adr/ADR-SBC-0011-plain-os-sbc-on-an-opt-in-devel-track.md)).
   To test development builds, opt in:

   ```sh
   touch /usr/local/etc/pkg/KSA-devel.enable
   ```

   and reinstall `os-ksa-repo` from the plugin page once more, so the change
   is applied. Delete the file (and reinstall again) to leave the devel track.

3. **System > Firmware > Plugins**, **Check for updates**, install **os-sbc**.

Details, tracks and the manual method:
[TheGrandWazoo/opnsense-repo](https://github.com/TheGrandWazoo/opnsense-repo).

### Switching from os-sbc-devel

Early builds were named `os-sbc-devel`, which OPNsense hides in
the plugin list. To move to `os-sbc`: opt in to the devel track (step 2),
remove `os-sbc-devel` from the plugin page (or `pkg delete os-sbc-devel`), and
install `os-sbc`.

## Documentation

Start at [docs/README.md](docs/README.md). Contributing:
[CONTRIBUTING.md](CONTRIBUTING.md).
