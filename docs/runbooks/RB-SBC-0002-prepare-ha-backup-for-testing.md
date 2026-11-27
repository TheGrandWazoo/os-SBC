---
id: RB-SBC-0002
title: "Prepare the HA backup firewall for os-sbc testing, and restore it"
kind: runbook
status: draft
date: 2026-11-26
owners: [Kevin Adams]
related: [TST-SBC-0001, TM-SBC-0001, PRD-SBC-0001]
---

# RB-SBC-0002: Prepare the HA backup firewall for os-sbc testing, and restore it

> **In short:** Carrier tests run on the backup firewall of the production
> HA pair. Turn off config sync from the primary so it can't overwrite the
> test, leave CARP alone so production still fails over, and bind the test
> SBC to the backup's own addresses, never the shared CARP addresses. Undo it
> all afterwards.

Status is Draft until it has been run once for real; fix the steps as you go.

## Why it is done this way

- **CARP stays on.** If the primary fails mid-test, the backup takes over
  production as usual. Taking the backup out of CARP would leave production
  with no failover for the whole test.
- **Config sync is off.** Sync runs from primary to backup. Left on, the next
  change on the primary would wipe the test settings (THR-SBC-0022).
- **The test SBC uses the backup's own addresses.** Production traffic goes to
  the CARP addresses, which the primary holds, so the test never touches it
  (THR-SBC-0024).

## Before the test

1. Pick a quiet window. **Freeze changes on the primary** for the window:
   with sync off, anything changed there won't reach the backup, and a
   failover would run on the older config.
2. On the backup, **Interfaces > Virtual IPs > Status**: every VIP shows
   `BACKUP`.
3. Download a config backup from both firewalls
   (**System > Configuration > Backups**).
4. On the **primary**, **System > High Availability > Settings**: write down
   the current values, then clear **Synchronize Config to IP** (or untick the
   synced services) and save. Leave state sync (pfsync) as it is.
5. On the **backup**: add the KSA repository (`os-ksa-repo`), opt in to the
   devel track (`touch /usr/local/etc/pkg/KSA-devel.enable`, then reinstall
   `os-ksa-repo` from the plugin page), and install `os-sbc` from
   **System > Firmware > Plugins**.
6. Configure os-sbc on the backup:
   - external interface: WAN, using the **backup's own WAN address**, never a
     CARP VIP;
   - internal interface: LAN, the backup's own LAN address;
   - PBX: a test PBX, or a separate trunk and extension on the production PBX
     with its own inbound route;
   - trunk: Flowroute, with Flowroute's signalling address ranges as inbound
     networks.
7. In the Flowroute portal, point the **test number only** at the backup's own
   WAN address. Leave production numbers alone.
8. Run the carrier tests (TST-SBC-0001, `C-1` to `C-5`).

## If the primary fails during the test

The backup takes over production on the CARP addresses as normal. Stop the
test, disable os-sbc on the backup, and deal with the primary first.

## After the test

1. On the backup: disable os-sbc, remove `os-sbc` (plus `kamailio` and
   `rtpproxy` if nothing else needs them), delete
   `/usr/local/etc/pkg/KSA-devel.enable`, and remove the KSA repository unless
   you are keeping it for the next test.
2. Point the Flowroute test number back where it was.
3. On the **primary**, restore the HA sync settings from step 4, then run
   **System > High Availability > Status > Synchronize** and check that it
   succeeds.
4. On the backup, check **Interfaces > Virtual IPs > Status**: all `BACKUP`.
5. Note the date, package version and results in the release issue.

## Open points

- Does the ISP give the backup its own public WAN address? Without one, carrier
  tests need a different setup (PRD-SBC-0001 open question 4).
- Once os-sbc settings themselves sync over HA (FR-SBC-HA-0001), re-enabling sync
  copies the primary's os-sbc settings to the backup. Decide then whether
  that is wanted.
