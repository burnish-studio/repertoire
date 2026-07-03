---
type: context
title: Maintainer guide — improving and expanding repertoire itself
created: 2026-07-03
updated: 2026-07-03
status: current
model: fable-5
---

# Maintainer guide — improving and expanding repertoire itself

How to update, improve, and expand the repertoire repository (the Core) — using
repertoire's own machinery on itself. The consumer view is in
`docs/consumer-guide.md`; the glossary is `CONTEXT.md` at the repo root.

## Ground rules

- **The repertoire is self-applying.** Every file in this repo must conform to every
  standard in `standards/` — including the standards themselves. The `skills/audit/`
  skill runs the conformance check; run it in any session where skills, standards, or
  templates were touched.
- **Read `_work/HANDOVER.md` first, in full.** It records what is settled; settled
  decisions must not be re-litigated. It also lists exemptions (README and `base/`
  files carry no frontmatter; everything else does).
- **House style is binding**: UK English throughout; normative statements use intent
  language (`must` / `should` / `may` — `standards/intent-language/`); any document
  whose body uses `I`, `me`, `you`, or `your` references `standards/perspective/`
  immediately under its h1; frontmatter per `templates/frontmatter/`; enduring
  artefacts live at `{type-plural}/{name}/UPPERCASE.md`, point-in-time documents at
  `_work/YYYY-MM-DD_<type>_<topic>-<nn>--<model>.md` (`standards/file-naming/`).
- **The governing design principle** (`standards/programming-paradigm/`): when
  intelligence is in the execution layer, specify intent and outcome, not procedure.
  Over-specification is the failure mode.

## The ontology and the placement test

Standards say *ought*, skills say *do*, templates say *is*. Before adding anything:

- Governs how things should be done generally? → standard
- Describes a repeatable action with an output? → skill
- Shows correct form for something? → template

The `codify` skill applies this test to a concept that emerged in discussion.

## Changing or adding a standard

Use `skills/write-a-standard/`. Structural facts that make standards load-bearing:

- **Norm/thesis structure.** The operative norm (one to three binding sentences,
  standing alone) sits above the first `---` rule; the thesis (rationale, elaboration)
  below it. The norm must be intelligible without the thesis.
- **Norm compilation is verbatim and structural.** `rep` strips the frontmatter, the
  h1, and any `_Perspective: …_` line; whatever remains above the first `---` *is* the
  norm that lands in every consumer's stance block. The title comes from frontmatter
  `title:`, falling back to the h1. Write the norm knowing exactly that text ships.
- **Every norm costs context in every consumer session, every session.** Standards
  vendor as an indivisible set, so adding one puts its norm into every consuming
  project's context window on their next `rep update`. Keep norms short; the three
  philosophical standards are short deliberately and must not be expanded without
  explicit instruction.
- After editing, run `bash test/rep-test.sh` — the suite compiles the stance block
  from real repo content and will catch a standard that breaks extraction.

## Changing or adding a skill

Use `skills/write-a-skill/` — it encodes the lessons of the four benchmark studies in
`_work/` (Matt Pocock, agentskills.io, Superpowers, OpenClaw); read them before
building any new skill. Non-negotiables it enforces: the `description` frontmatter
field states both what the skill does *and* when to use it (trigger conditions alone
are insufficient, workflow summaries are a tested failure mode); every sentence must
change an observable behaviour — if it cannot fail, remove it.

New skills are à la carte for consumers: not vendored unless selected, so a new skill
does not tax existing projects. Whether it joins the default `init` set
(`write-a-skill`, `write-a-standard`, `codify`, `audit` — the authoring loop) is a
deliberate decision, not a default.

## Changing the tool (`rep`)

`bin/rep.mjs` is a single dependency-free file. Its specification is
`_work/2026-07-03_brief_rep-v0-build-01--fable-5.md`; its locked design decisions are
ADRs 0005–0008 in `.plan/adr/` (local-first delivery, the project tree and lock, the
stance block and pointer, tool-in-content-repo). Change behaviour only in ways
consistent with those, or write a new ADR first.

The gate is `bash test/rep-test.sh` — 10 acceptance tests run against a sandbox
project, covering init, byte-clean removal, byte-identical restoration of pre-existing
files, add/remove, drift, authored-content ownership, and refusal to touch
project-owned paths. The invariants the suite protects, in order of importance:

1. **The lock is the ownership boundary.** `rep` touches only lock-listed paths plus
   its own marker block and pointer line. Authored artefacts must never enter the lock.
2. **Removal is byte-clean.** After `rep remove --all`, pre-existing files are
   byte-identical and `git status --porcelain` is empty in the fresh-project case.
3. **Refuse rather than clobber.** Anything at a target path that `rep` does not own
   causes a pre-flight refusal, not a replacement.

Every change to `rep` gets a frontier-model review pass against the brief before it
ships — the Phase 2 review (`_work/2026-07-03_review_rep-v0-01--fable-5.md`) found
three data-loss defects in code whose tests all passed; the suite verifies what it
covers, not what it omits.

## Session workflow

The working rhythm this repo uses, endorsed in the handover:

1. **Grill** contested questions with the owner; record locked decisions as ADRs in
   `.plan/adr/` and settled language in `CONTEXT.md`.
2. **Brief** execution work as a self-contained `_work/` document a cheaper model can
   run without session context; include acceptance tests.
3. **Delegate** the build (frontier models for grills, ADRs, norm prose, and reviews;
   cheaper models for execution against briefs with verifiers).
4. **Review** the result against the brief line by line (frontier pass), fix, and
   record a receipt/review document in `_work/`.
5. **Update `_work/HANDOVER.md`** before the session ends — it is the only continuity
   between sessions.

## Shipping

Work lands on `master` directly — solo project, forward speed preferred, no branches.
Pushing requires the `burnish-studio` GitHub account:
`gh auth switch --user burnish-studio`, push, then switch back to `flintec-studio`.
Consumers pick changes up with `rep update` via `npx github:burnish-studio/repertoire`,
which prints the stance-block diff as their review record — which is why every content
edit should assume it will be read in that diff by someone deciding whether to accept
the new stance.
