---
type: context
title: Consumer guide — using repertoire in a project
created: 2026-07-03
updated: 2026-07-03
status: current
model: fable-5
---

# Consumer guide — using repertoire in a project

How to stand repertoire up inside a project, live with it day to day, and use the
authoring loop it installs. This guide is self-contained; the glossary at the repo
root (`CONTEXT.md`) defines the terms used here (Vendored, Authored, Lock, Stance
block, Pointer, Tree).

## What repertoire installs

Three things, in one pass:

1. **A stance** — a marker-delimited block in the project's `AGENTS.md` carrying the
   bootstrap (operative philosophy: fallibilism, collaboration, intent-not-procedure)
   plus the compiled operative norm of every standard present. Loaded into the agent's
   context every session.
2. **Content** — all standards (an indivisible set), all templates, and a chosen set
   of skills, vendored into the project tree.
3. **The authoring loop** — the capability to write new, well-formed skills, standards,
   and templates *for the host project*, via the `write-a-skill`, `write-a-standard`,
   `codify`, and `audit` skills. This is the primary purpose, not a bonus: repertoire
   installed means the project can grow its own repertoire.

## Requirements

Node ≥ 20, POSIX (Windows is out of scope for v0), and a project directory to run in.

## Install

From the project root:

```bash
npx -y github:burnish-studio/repertoire init
```

Options: `--skills a,b,c` selects skills (default: `write-a-skill`,
`write-a-standard`, `codify`, `audit`); `--all-skills` vendors every skill in the
repertoire. `init` refuses if a `repertoire.lock` already exists.

What lands in the project:

```
project/
├─ .agents/
│  ├─ skills/<name>/            ← vendored skill directories
│  ├─ standards/<name>/         ← all standards
│  ├─ templates/<name>/         ← all templates
│  ├─ base/bootstrap.md         ← stance preamble source
│  └─ repertoire.lock           ← what rep owns, with content hashes
├─ .claude/skills/<name>        ← relative symlink per skill (Claude Code discovery)
├─ AGENTS.md                    ← carries the stance block
└─ CLAUDE.md                    ← contains the pointer line `@AGENTS.md`
```

Pre-existing `AGENTS.md`/`CLAUDE.md` content survives: the block and pointer are
appended, and `rep remove --all` restores both files byte-identical.

**Commit all of it**, including the lock and the symlinks. Vendoring means the content
travels with the project — no install step for collaborators or CI.

To verify the install: open a fresh agent session and ask whether a repertoire stance
block is active and which skills are discoverable. In-session file checks are a proxy;
a new session is the real test.

## The ownership rule

The lock is the boundary. Everything `rep` vendored is listed in
`.agents/repertoire.lock` with a content hash; `rep` touches only those paths plus its
own marker block and pointer line. Everything else in the tree is the project's and is
never modified or deleted by `rep`.

Two consequences:

- **Vendored files must not be hand-edited.** An edit is drift: `rep status` flags it
  and `rep update` refuses to overwrite it without `--force`. To disagree with a
  vendored standard, author a project standard instead — do not patch the vendored one.
- **Authored artefacts are first-class and untouchable.** Anything created in the tree
  by the project sits outside the lock: compiled, discovered, and audited identically
  to vendored content, and left in place even by `rep remove --all`.

## Day-to-day commands

| Command | Effect |
|---|---|
| `rep status` | Verify hashes, symlinks, stance freshness, pointer. Lists drift and authored artefacts. Non-zero exit on any issue. |
| `rep add <skill>…` | Vendor further skills from the repertoire. |
| `rep remove <skill>…` | Remove vendored skills (refuses names not in the lock). |
| `rep update [--force]` | Re-vendor everything from the running package, recompile the stance, print a diff of the old vs new stance block. Refuses on drift without `--force`. |
| `rep compile` | Recompile the stance block from all standards in `.agents/standards/` — vendored and authored alike. |
| `rep remove --all` | Full reversal: everything the lock lists is removed, the block and pointer are taken out, pre-existing files are restored byte-identical, authored content stays. |

`rep` is non-interactive by design; the conversational layer is the agent driving it.

## The authoring loop

Growing the project's own repertoire is the intended use:

- **A norm keeps being repeated in review?** Ask the agent to use `write-a-standard`
  to codify it as `.agents/standards/<name>/STANDARD.md`, then run `rep compile` —
  the new standard's norm enters the stance block and is active in every session
  from then on.
- **A workflow keeps being re-explained?** `write-a-skill` produces
  `.agents/skills/<name>/SKILL.md`. For Claude Code discovery, add the symlink
  `rep` uses for vendored skills:
  `ln -s ../../.agents/skills/<name> .claude/skills/<name>`
  (`rep` only manages symlinks for lock-listed skills).
- **Unsure whether something is a standard, a skill, or a template?** The `codify`
  skill exists to place a discussed concept correctly.
- **Checking conformance** of the project's authored artefacts: the `audit` skill.

Standards follow a norm/thesis structure: the operative norm (one to three binding
sentences) sits above the first `---` rule; the thesis (rationale) sits below it. Only
the norm is compiled into the stance block, so it must stand alone.

## Updating

`rep update` re-vendors from whatever package version runs it — so
`npx -y github:burnish-studio/repertoire update` updates to the latest `master`.
The printed stance-block diff is the human-reviewable record that the project's
operative stance changed; read it before committing.

## Harness support

v0 wires two conventions: `AGENTS.md` (read natively by a growing set of agents) and
Claude Code (which reads neither `AGENTS.md` nor `.agents/skills/` natively — hence
the `CLAUDE.md` pointer and the `.claude/skills` symlinks, both verified working).
Other harnesses that read `AGENTS.md` work as-is; harnesses that need different
wiring are not yet handled by `rep`.
