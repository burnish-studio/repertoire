---
type: context
title: ADR-0006 — Uniform Project Tree
created: 2026-07-03
updated: 2026-07-03
status: current
model: fable-5
---

# Consumer projects hold one uniform artefact tree; the lockfile is the ownership boundary

A project that calls repertoire in gets **one tree** — `.agents/skills/<name>/`,
`.agents/standards/<name>/`, `.agents/templates/<name>/` — holding vendored and authored
artefacts side by side. `repertoire.lock` records what `rep` vendored (source repo, pinned
ref, per-artefact path and content hash); `rep` touches **only** what the lock lists.
Everything else in the tree is the project's own, created through the authoring loop
(`write-a-skill`, `write-a-standard`, `codify`) and never modified by `rep`.

Standards (with templates and the bootstrap) vendor as one indivisible set — they are a
mutually referencing normative system and partial installs would dangle references.
Skills are individually selectable (`rep add` / `rep remove <skill>`), preserving
ADR-0005's start-empty hygiene where the context cost actually accrues.

## Why

Repertoire's primary post-install purpose is the authoring loop: it should enable a
project to grow its *own* skills and standards (first use case: Station AI). A uniform
tree makes authored artefacts first-class with zero special cases — same discovery
(`.agents/skills` is the agentskills.io standard location), same conventions, same
tooling. Ownership by lockfile rather than by path is how package managers already work,
and the hash makes drift in vendored files detectable (`rep status`).

## Consequences

- The stance compiler treats every standard present identically: authored norms join the
  injected block exactly like vendored ones. One mechanism, no tiering.
- Norm extraction is structural, not duplicated metadata: a standard's operative norm is
  its body content above the first `---` rule (the already-settled norm/thesis structure),
  excluding the perspective reference line. `rep` parses that; `audit` enforces its
  presence. No `norm:` frontmatter field to drift from the body.
- Editing a vendored file in place is drift, not customisation — `rep status` flags it;
  the supported route is authoring a project standard/skill alongside.
- Claude Code discovery of `.agents/skills` is unverified; if absent, `rep` additionally
  writes `.claude/skills/*` symlinks for that harness (verification item).
