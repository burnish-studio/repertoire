---
type: context
title: Repertoire — Glossary
created: 2026-07-03
updated: 2026-07-03
status: current
model: fable-5
---

# Repertoire

Repertoire is a standalone base layer of agent skills, standards, and templates, and —
first and foremost — the **authoring loop** that lets a project create its own. This
glossary fixes the language of the local-first delivery model (ADR-0005 onward) so
decisions downstream stay consistent. Terms of the superseded global-first model
(Adapter, Launcher, Harness detection, Scope, Composition mode) are retired; they remain
defined in this file's history and on the `global-first` branch.

## Language

**Core**:
The canonical content of the repertoire repository — skills, standards, templates,
bootstrap. The single source of truth that projects vendor from.
_Avoid_: package, framework, library

**Vendored**:
An artefact copied from the Core into a project by `rep` and listed in the lock.
Tool-owned: `rep update` may rewrite it, and hand-edits are drift that `rep status`
flags.
_Avoid_: installed, imported

**Authored**:
An artefact a project creates through the authoring loop. Not in the lock; never touched
by `rep`. First-class: discovered, compiled, and audited identically to vendored
artefacts.
_Avoid_: custom, local, user-defined

**Authoring loop**:
The capability repertoire installs: writing new, well-formed skills, standards, and
templates for the host project using `write-a-skill`, `write-a-standard`, `codify`, and
`audit`. The primary post-install purpose of the repertoire.
_Avoid_: meta-skills (as a name for the capability)

**Lock** (`repertoire.lock`):
The record of what `rep` vendored: source repo, pinned ref, and per-artefact path and
content hash. The ownership boundary — `rep` touches only what the lock lists — and the
input to `update`, `remove`, and `status`.
_Avoid_: manifest (the superseded global-first concept)

**Stance block**:
The single marker-delimited block (`<!-- repertoire:start -->` … `<!-- repertoire:end -->`)
`rep` writes into the project's `AGENTS.md`: the bootstrap plus the compiled operative
norms of all standards present, vendored and authored alike.
_Avoid_: bootstrap injection, context block

**Norm compilation**:
Extracting each standard's operative norm — the body content above the first `---` rule,
excluding the perspective reference — and concatenating them into the stance block. The
norm/thesis structure of standards makes this structural, not duplicated metadata.
_Avoid_: summarising (compilation is verbatim extraction)

**Pointer**:
A one-line per-harness redirection to the stance block's single home, e.g. a `CLAUDE.md`
containing `@AGENTS.md`. Written only where a harness verifiably does not read
`AGENTS.md` itself.
_Avoid_: duplicate block, mirror

**Tree**:
The uniform per-project artefact layout `.agents/{skills,standards,templates}/<name>/`,
holding vendored and authored artefacts side by side. `.agents/skills` follows the
agentskills.io open standard.
_Avoid_: install directory, repertoire directory
