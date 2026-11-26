# Product Requirements Documents

A PRD says **what** a release must do, **for whom**, and **how we know it
worked**. ADRs say how and why that way. Copy [`template.md`](template.md).

## Rules

- One PRD per release line or large feature, ID `PRD-SBC-NNNN`, never reused.
- Requirements have stable IDs (`FR-SBC-<AREA>-NNNN`, `NFR-SBC-NNNN`). Issues, tests and PRs
  refer to them.
- PRDs are living documents while **Draft**. Once **Approved**, scope changes
  are made with a dated entry in the Change log, not silent edits.
- New ideas go to the `ROADMAP.md` parking lot first, not straight into a PRD.

## Status

Draft → Approved → Shipped (in version X) → Retired

## Index

| PRD | Title | Status |
|---|---|---|
| [PRD-SBC-0001](PRD-SBC-0001-os-sbc-1.0.md) | os-sbc 1.0: SBC for an on-prem PBX behind OPNsense | Draft |
