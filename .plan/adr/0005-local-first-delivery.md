---
type: context
title: ADR-0005 — Local-First Delivery
created: 2026-07-03
updated: 2026-07-03
status: current
model: deepseek-v4-pro
---

# Repertoire is installed per-project, not globally

Repertoire's delivery model is **local-first**: it is called into each project explicitly
(like a dependency), not installed once and auto-injected everywhere. Global storage has
zero value under this model — the clone is a few hundred KB of markdown; re-downloading
per project is noise, and a shared global clone creates a sync problem with no upside.

A CLI tool (`rep`) scaffolds repertoire into a project on demand (`rep init`, `rep add`,
`rep update`, `rep remove`). The `npx`-style zero-friction path and the installed-binary
speed path are the same tool, two access patterns. Every project stands alone — no
`~/.agent/`, no global bootstrap injection, no launcher wiring.

## Why

The global-install model collapsed install and activation into a single step: installing
repertoire globally injected its bootstrap and skills into every session by default. The
only escape was pi's `--no-context-files`, a sledgehammer that suppressed everything.
There was no per-project gate, no `import repertoire`.

Local-first enforces a hygiene practice: start empty, include explicitly. This forces
consideration of what goes into the context window — the single most expensive resource
in agentic engineering. It mirrors how every other dependency works (`npm install next`,
not a global Next.js auto-injected into every project).

## Consequences

- The delivery architecture built in 0001–0004 (`~/.agent/`, global storage, harness
  adapters, `pid` launcher, multi-harness wiring) is **superseded** and preserved on the
  `global-first` branch for posterity.
- The bootstrap shifts from skills-discovery nudge to operative philosophy injection:
  every project that calls in repertoire gets the same baseline stance (fallibilism,
  collaboration norms, programming paradigm). Skills and standards are what the user
  explicitly selects beyond that.
- Harness wiring is now per-project: a `@import` in the project's context file pointing
  at the local `repertoire/` directory. No launcher required.
