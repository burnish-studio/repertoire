---
type: context
title: ADR-0007 — Stance Home
created: 2026-07-03
updated: 2026-07-03
status: current
model: fable-5
---

# The stance block lives in AGENTS.md; other context files get one-line pointers

`rep` injects the **stance block** — `base/bootstrap.md` plus the compiled operative
norms of all standards present in the project — as a single marker-delimited block
(`<!-- repertoire:start -->` … `<!-- repertoire:end -->`) in the project's `AGENTS.md`,
creating the file if absent. Harnesses that do not read `AGENTS.md` get a one-line
pointer instead of a copy — e.g. a `CLAUDE.md` containing `@AGENTS.md` for Claude Code's
import mechanism. The block is written only once, in one file.

## Why

`AGENTS.md` is the cross-harness convention (Codex, Cursor, Gemini, the Universal
cluster). Duplicating the block per context file would drift; pointing keeps a single
source of truth and makes updates a one-file rewrite. Marker delimiting keeps removal
deterministic (delete between markers), carrying forward the one load-bearing idea from
the superseded manifest design (ADR-0004).

## Consequences

- Claude Code does **not** read `AGENTS.md` natively (verified empirically 2026-07-03,
  headless probe), so the `CLAUDE.md` → `@AGENTS.md` pointer is required for it — and
  verified working the same day (imported content and a probe answer round-tripped).
- `rep update` regenerates the block in place (norms may have changed); the diff of the
  block is the human-reviewable record that the project's operative stance changed.
- User content in `AGENTS.md` outside the markers is never touched.
