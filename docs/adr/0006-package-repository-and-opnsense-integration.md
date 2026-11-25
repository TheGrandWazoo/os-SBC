# ADR-0006: Signed package repository that OPNsense lists as plugins

**Date**: 2026-11-25
**Status**: Proposed
**Deciders**: Kevin Adams
**Related**: ADR-0002, ADR-0005, ADR-0007

## Context

Goal: an admin adds one repository to OPNsense, and `os-sbc` appears in
**System > Firmware > Plugins** like any official plugin.

OPNsense reads extra package repositories from
`/usr/local/etc/pkg/repos/*.conf`, and its plugin list shows `os-*` packages
from every enabled repository. Community repositories already work this way.

Two facts shape the repository:

- OPNsense 26.7 does not ship Kamailio, rtpproxy, or some of their libraries,
  so our repository must carry them too (ADR-0002).
- Packages must match OPNsense's ABI and libraries: FreeBSD 15.1, PHP 8.5,
  Python 3.13, OpenSSL 3.5 from ports (opnsense/tools `config/26.7/build.conf`).
  Building against stock FreeBSD packages risks library mismatches.

## Decision

- Publish a **signed FreeBSD pkg repository on GitHub Pages**, the same hosting
  choice as freenas-proxmox's apt repo (its ADR-003 and ADR-010).
- **Repo layout:** `https://<pages-host>/${ABI}/<track>/`, where pkg fills in
  `${ABI}` (e.g. `FreeBSD:15:amd64`) and `<track>` is `devel`, `v1/testing` or
  `v1/stable` (ADR-0005).
- **Contents:** `os-sbc` / `os-sbc-devel`, plus Kamailio, rtpproxy and any of
  their libraries missing from OPNsense's own repository. Nothing that
  OPNsense already ships.
- **Priority:** lower than the OPNsense repository, so our repository can never
  replace an OPNsense package.
- **Signing:** repository signed with an RSA key (`pkg repo` with a signing
  command). The private key is a GitHub Actions secret, usable only in a
  protected `publish` environment. Users trust it through a fingerprint file.
- **Bootstrap:** a tiny package, `os-ksa-repo`, installs the repo config and
  fingerprint. One command on a fresh firewall:
  `pkg add https://<pages-host>/os-ksa-repo.pkg`. After that, the plugin list
  shows `os-sbc` and `os-sbc-devel`, and updates arrive through normal firmware
  updates. The manual way (two files) is documented too.

### Open question for the decision

Host the repository **inside os-SBC** (`gh-pages` branch), or in a **separate
shared repo** (e.g. `TheGrandWazoo/opnsense-repo`) that os-netmaker could also
publish to. Recommendation: the shared repo, because the bootstrap package and
signing key belong to "KSA's OPNsense repository", not to one plugin.

## Alternatives considered

- **Submit to the official opnsense/plugins.** Worth doing later for the plugin
  itself, but upstream would also have to accept Kamailio and rtpproxy into
  their package set. Not something to depend on for 1.0.
- **GitHub Releases assets.** No pkg repository metadata, so no plugin listing
  and no firmware updates.
- **Self-hosted web server.** Another thing to run. Pages is free, versioned
  and already used for freenas-proxmox.

## Consequences

- Every OPNsense major series (27.1, ...) needs a rebuild of Kamailio, rtpproxy
  and their libraries. That becomes a release-runbook step.
- GitHub Pages limits (about 1 GB per site, 100 MB per file) are fine for a few
  dozen packages, but old versions need pruning.
- Supply chain: repository signing plus protected publishing. SBOMs and
  provenance are in the parking lot.
