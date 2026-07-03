---
type: context
title: ADR-0003 — Delivery Flows
created: 2026-07-03
updated: 2026-07-03
status: deprecated
model: opus-4-8
---

# Delivery is agent-driven interactive flows; install.sh is core-only

> **Superseded by [ADR-0005](0005-local-first-delivery.md)** (local-first delivery).
> Preserved as the record of the global-first design.

Each lifecycle operation — setup, teardown, and (proposed) update and doctor — is an
interactive **delivery flow** in which the local agent acts as a CLI for the user: it
detects OS and harness from environmental evidence, confirms with the user before acting
(**detect-then-confirm**), and can wire **multiple harnesses in a single pass** (one
Core, N adapters). The deterministic `install.sh` does only the harness-agnostic core —
clone + `~/.agent/` storage + install manifest — and prints the wiring end-state; all
harness wiring is delegated to the agent.

We chose this because the integration surface per harness is small and file-based (known
config files, or launch flags), which makes paradigm-2 delegation both feasible and
lower-maintenance than pre-canning every harness × OS combination. It also makes
`install.sh` an honest "no agent" fallback rather than a pi-only path masquerading as
universal (smoke-test finding #3).

## Consequences

A no-agent install is the manual/fallback tier by definition: with no agent, the human
performs the wiring `install.sh` printed. Uninstall mirrors install reversed, driven by
the manifest. The harness is a *set the user selects*, not a single value.
