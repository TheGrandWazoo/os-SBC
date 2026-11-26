---
id: PRD-SBC-NNNN
title: "<title>"
kind: prd
status: draft            # draft | approved | shipped | retired
date: YYYY-MM-DD
owners: [Kevin Adams]
related: []
---

# PRD-SBC-NNNN: <title>

> **In short:** Two to four plain sentences: what this release does and for
> whom.

## The problem

What hurts today, and for whom.

## Who it is for

## Goals

Outcomes, not features.

## Not in this release

## What it does, by area

One row per area in plain words, pointing at the requirement IDs. The full
list lives in the Machine-readable section; do not repeat it here.

| Area | In plain words | Requirements |
|---|---|---|

## How we know it worked

## Open questions

## Change log

| Date | Change |
|---|---|

## Machine-readable

Authoritative requirement register, validated by `tools/check_docs.py`.
Priorities: `must`, `should`, `could`. Status: `draft`, `approved`,
`shipped`, `dropped`.

```yaml
requirements:
  - {id: FR-SBC-AREA-0001, priority: must, milestone: X.Y.Z, status: draft,
     title: "..."}
  - {id: NFR-SBC-0001, priority: must, milestone: X.Y.Z, status: draft,
     title: "...", target: "..."}
```
