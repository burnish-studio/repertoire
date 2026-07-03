---
type: context
title: Setup Scenarios — Global-First End States
created: 2026-07-03
updated: 2026-07-03
status: deprecated
model: opus-4-8
---

# Setup Scenarios — the ideal end state per harness and OS

> **Superseded by [ADR-0005](../adr/0005-local-first-delivery.md)**: these scenarios
> describe global-scope wiring. The harness-convention findings (§ "Findings that feed
> back into the design", esp. items 5–6 on the `.agents/skills` standard and the `skills`
> CLI) remain live input to the `rep` design.

Spec-by-example for Repertoire delivery. Each scenario describes the *ideal* concrete end
state a setup flow should reach, the exact wiring it performs, and the manifest it writes.
Terms in [../../CONTEXT.md](../../CONTEXT.md); decisions in [../adr/](../adr/).

Primary axis is the **harness** (it determines the Adapter shape). **OS** is a set of
deltas noted per harness — Mac ≈ Linux; Windows differs on home path, shell, and symlink
privilege.

---

## The End state is two independent capabilities

We had been treating the End state as one thing. The scenarios show it is **two
capabilities an Adapter satisfies separately**, to the degree the harness allows:

1. **Bootstrap loads every session** — Repertoire's proactivity instruction is in context
   at every session start.
2. **Skills are discoverable** — Repertoire's skills can be invoked when relevant.

Some harnesses do both natively (Claude Code); some do bootstrap easily but have **no
skills primitive** (Codex); one can only do the skills half programmatically and needs a
manual step for the bootstrap half (Cursor, Global). An Adapter therefore reports its
capability *per half*, not as a single pass/fail.

---

## pi — launcher, does both halves natively

- **Integration surface:** launch flags only (`--append-system-prompt`, `--skill`,
  `--no-context-files`). No passive files.
- **Adapter kind:** launcher (`pid`). This is the *only* harness that structurally needs
  a launcher.
- **Bootstrap:** `pid` passes `~/.agent/base/bootstrap.md` via `--append-system-prompt`.
- **Skills:** `pid` passes the whole dir via `--skill ~/.agent/skills/repertoire`.
- **Composition:** Additive (default) **and Clean** (`--no-context-files`) — the only
  harness that can do Clean.
- **Scope:** Global (`~/.agent/`) and Local (project `.agent/`).
- **OS deltas:** Linux/Mac identical; fish uses `fish_add_path $HOME/bin` for PATH.
  Windows: pi is a Unix tool — native Windows is out of scope; use WSL (then treat as
  Linux).

## Claude Code — static wiring, does both halves natively

- **Integration surface:** `~/.claude/CLAUDE.md` (loads every session, supports `@import`),
  `~/.claude/skills/<name>/` (one dir per skill), `~/.claude/rules/`, `settings.json`.
- **Adapter kind:** static wiring — **no launcher needed**. (An optional `clauder`
  launcher could be offered later for people who want live controls + a terminal readout,
  but it is never required.)
- **Bootstrap:** append `@~/.agent/repos/repertoire/base/bootstrap.md` to
  `~/.claude/CLAUDE.md` (create the file if absent).
- **Skills:** **per-skill** — symlink each `Core/skills/<name>` to
  `~/.claude/skills/repertoire-<name>/`. (Alternatively an opt-in Claude Code plugin
  registers the whole dir at once — the one place a native plugin clearly pays for itself.)
- **Composition:** Additive only (static wiring cannot suppress the user's own context).
- **Scope:** Global (`~/.claude/`) and Local (project `./.claude/`).
- **OS deltas:** Windows symlinks need admin/Developer Mode — prefer the plugin path, or
  copy skill dirs, and the `@import` line works without any symlink. Home is
  `%USERPROFILE%\.claude\`.

## Codex — static wiring into a *shared single file*; no skills primitive

- **Integration surface:** `~/.codex/AGENTS.md` (global instructions — **first non-empty
  file wins**, so it is a *single shared file*, not a drop-in dir), `~/.codex/config.toml`,
  `~/.codex/prompts/`. No `@import` in AGENTS.md.
- **Adapter kind:** static wiring, but into a file the user may already own.
- **Bootstrap:** **append a marker-delimited block** into `~/.codex/AGENTS.md`
  (`<!-- repertoire:start -->` … `<!-- repertoire:end -->`), inlining the bootstrap text
  (no import mechanism). Never replace the file — the user's own AGENTS.md must survive.
- **Skills:** Codex has **no native skills-discovery primitive**. The skills half degrades
  to: reference the skills index inside the AGENTS.md block, and/or drop selected skills
  into `~/.codex/prompts/`. Report the skills half as *partial* for Codex.
- **Composition:** Additive only.
- **Scope:** Global (`~/.codex/`) and Local (project `AGENTS.md`).
- **OS deltas:** `%USERPROFILE%\.codex\` on Windows; `$CODEX_HOME` overrides the home.

## Cursor — GUI; Global bootstrap is partly blocked; Local is clean

- **Integration surface:** **User Rules live in Cursor's in-app Settings, not a writable
  file** — so Global bootstrap cannot be wired programmatically. `.cursor/rules/*.mdc`
  (with `alwaysApply: true`) *is* file-based and writable. Cursor can also **consume
  Claude Code skills/plugins** (applied as agent-decided rules). GUI — **no launcher
  possible.**
- **Adapter kind:** static wiring, Local-only for full automation.
- **Bootstrap (Global):** **tier-3 manual** — instruct the user to paste the bootstrap
  into Settings → Rules (or rely on the consumed Claude plugin). This is the scenario that
  earns the manual fallback tier.
- **Bootstrap (Local):** write `.cursor/rules/repertoire.mdc` with `alwaysApply: true`
  containing the bootstrap — fully automatable.
- **Skills:** via `.cursor/rules/` (agent-decided) or by consuming a Claude Code plugin.
- **Composition:** Additive only (no launcher → no Clean).
- **OS deltas:** cross-platform GUI; project `.cursor/` path identical across OS.

---

## Capability matrix

| Harness | Bootstrap Global | Bootstrap Local | Skills | Additive | Clean | Launcher |
| ------- | ---------------- | --------------- | ------ | -------- | ----- | -------- |
| pi | ✓ (launcher) | ✓ | ✓ whole-dir | ✓ | ✓ | required |
| Claude Code | ✓ (`@import`) | ✓ | ✓ per-skill / plugin | ✓ | ✗ | optional |
| Codex | ✓ (append block) | ✓ | ✓ via plugin (`skills:./skills/`) | ✓ | ✗ | n/a |
| Cursor | ✓ via plugin hook | ✓ (`.mdc`) | ✓ via plugin (`skills:./skills/`) | ✓ | ✗ | impossible |

> **Correction (2026-07-03, from Superpowers' actual manifests):** the native **plugin**
> format carries `"skills": "./skills/"` for Claude Code, Codex, *and* Cursor, and a
> sessionStart hook for Claude and Cursor. So Codex *does* have a skills mechanism and
> Cursor's Global bootstrap is *not* blocked (the User-Rules limitation applies only to
> the non-plugin static-rules path). The plugin path is uniform across the three and is
> Superpowers' real mechanism — reconsider ADR-0002's "plugin = opt-in only" weighting:
> it may be the primary tier-1 recipe for plugin-supporting harnesses, with hand-rolled
> wiring kept for pi and no-plugin fallbacks.

---

## Sample manifest — flagship case: Linux, one pass wiring pi + Claude Code

```markdown
# Repertoire — Install Manifest
Written by setup on 2026-07-03T10:00:00Z. Reverses via teardown-repertoire.
Anything not listed here was pre-existing and must not be touched.

## Core (deterministic — written by install.sh)
### Directories created
- ~/.agent/ (base/ prompts/ skills/ repos/) — created because absent
- ~/bin/ — created because absent
### Repository cloned
- ~/.agent/repos/repertoire/ ← git clone of https://github.com/burnish-studio/repertoire
### Symlinks created
- ~/.agent/base/bootstrap.md → ~/.agent/repos/repertoire/base/bootstrap.md
- ~/.agent/skills/repertoire → ~/.agent/repos/repertoire/skills

## Adapter: pi (launcher)
- symlink ~/bin/pid → ~/.agent/repos/repertoire/bin/pid
- PATH: appended `export PATH="$HOME/bin:$PATH"` to ~/.bashrc
- bootstrap: satisfied at launch by pid (--append-system-prompt); no static edit
- skills: satisfied at launch by pid (--skill); no static edit

## Adapter: claude-code (static wiring)
- config edit: appended `@~/.agent/repos/repertoire/base/bootstrap.md`
  to ~/.claude/CLAUDE.md  [file pre-existed: yes → remove only this line on teardown]
- symlink ~/.claude/skills/repertoire-audit     → ~/.agent/repos/repertoire/skills/audit
- symlink ~/.claude/skills/repertoire-codify    → ~/.agent/repos/repertoire/skills/codify
- symlink ~/.claude/skills/repertoire-write-a-skill → …/skills/write-a-skill
  [one per skill]
```

The two adapters share one Core; each records its own wiring. Teardown reverses per
adapter, and the `[file pre-existed]` / per-line notes are what keep it safe.

---

## Findings that feed back into the design

1. **End state is two independent capabilities** (bootstrap, skills) — Adapters must
   report per-half, not pass/fail. Update the abstract end-state wording accordingly.
2. **The manifest must record more than created files/symlinks.** Codex (append a block to
   a shared `AGENTS.md`) and Claude Code (append a line to a possibly-pre-existing
   `CLAUDE.md`) require recording **in-place edits to shared files** with exact,
   reversible boundaries (markers / the exact line). This extends the ADR-0004 schema:
   an entry kind for *edited shared file* with a precise reversal, distinct from
   *created file*.
3. **Some harnesses lack a skills primitive** (Codex) — "skills discoverable" degrades
   gracefully to references/prompts. The setup flow must state the degraded capability
   honestly rather than claim success.
4. **GUI harnesses can block Global wiring** (Cursor User Rules) — the tier-3 manual
   fallback is not an edge case, it is the *expected* path for one whole capability of a
   mainstream harness. It must be first-class, not an afterthought.
5. **Native plugins can be cross-consumed** — Cursor reads Claude Code skills/plugins. A
   single Claude Code plugin (opt-in) could serve two harnesses, which strengthens the
   "plugin where it clearly pays" clause of ADR-0002.

6. **The skills half is largely a solved, standardised problem.** The `skills` npm CLI
   (used by Matt Pocock) supports **72 agents**, and a large "Universal" cluster —
   Amp, Antigravity, Codex, Cursor, Gemini CLI, GitHub Copilot, OpenCode, Warp, Zed,
   Cline, Kimi, Deep Agents, … — all read **one standard location, `.agents/skills`**
   (the agentskills.io open standard). Only holdouts need a bespoke path: **Claude Code**
   (`.claude/skills`) and **pi** (launcher `--skill`). Implication: the skills-half wiring
   reduces to "place skills in `.agents/skills` + special-case Claude Code and pi", and we
   may lean on the `skills` CLI rather than build our own installer. The remaining genuine
   per-harness variation is the **bootstrap half** (context-file import / sessionStart hook
   / launcher flag). **To verify next:** the exact canonical `.agents/skills` paths for
   Global vs Project scope in the agentskills.io standard.
