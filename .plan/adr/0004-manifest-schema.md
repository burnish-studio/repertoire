---
type: context
title: ADR-0004 — Manifest Schema
created: 2026-07-03
updated: 2026-07-03
status: deprecated
model: opus-4-8
---

# The install manifest is a defined, per-adapter, verifiable schema

> **Superseded by [ADR-0005](0005-local-first-delivery.md)** (local-first delivery).
> The principle — a deterministic, verifiable record of what delivery changed — survives
> as the `rep` lockfile.

The install manifest is a **structured record with a mandated schema**, not free-form
prose. Three layers: `install.sh` writes the deterministic core rows (dirs / clone /
symlinks, each with a pre-existence flag); the setup flow adds a **required structured
entry per adapter** (harness, each file touched, each exact line / symlink / flag, and
whether it pre-existed); and a `doctor` flow re-derives actual system state and **diffs**
it against the manifest.

We chose a defined schema over a lightweight free-form log because the manifest is the
load-bearing contract every replay operation (teardown, update, doctor) depends on —
possibly on another machine or months later. The 2026-07-02 smoke test round-tripped
cleanly only because a capable agent *happened* to write a precise manifest; quality was
luck, not structure. Multi-harness install makes this acute: the manifest must record N
adapters' exact wiring and which parts pre-existed, or teardown becomes unsafe (removes
something pre-existing) or incomplete (leaves one harness's wiring dangling).

## Consequences

The schema is a coupling surface kept in sync across `install.sh` (writer),
`setup-repertoire` (writer), and `teardown` / `update` / `doctor` (readers). Small and
well-defined — the price of a safe, verifiable lifecycle.
