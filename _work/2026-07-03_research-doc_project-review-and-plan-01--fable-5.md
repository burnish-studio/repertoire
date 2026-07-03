---
type: research-doc
title: Full Project Review and Forward Plan
created: 2026-07-03
updated: 2026-07-03
status: current
model: fable-5
---

# Full Project Review and Forward Plan

A cold, whole-repo review requested by the owner: philosophy, form, semantic content,
structure, use case, installation and update method, participation in AI workflows, and
the seam between deterministic and paradigm-2 execution. Everything in the repo and its
history was read before writing this. The verdict and plan below supersede nothing on
their own — they are input to the next grill session.

---

## Verdict in one paragraph

The philosophy is the strongest asset and should be treated as the product's moat. The
local-first pivot (ADR-0005) is the right call and dissolves most of the delivery
complexity that consumed the previous three months — but the pivot is currently declared,
not executed, and master is internally contradictory. The largest genuine gap is
object-level content: the repertoire is a beautifully self-consistent toolkit for
maintaining itself, with almost nothing yet that an end user would install it for. The
highest-leverage move available is to productise the project's own proven working
practices (handover, grill, write-up, ADR, audit) as the first wave of real skills, and
to build `rep` as a deliberately boring deterministic CLI that the agent drives — the
seam the repo's own programming-paradigm standard already prescribes.

---

## 1. Philosophy — keep; sharpen its delivery

The paradigm-2 stance (intent over procedure), fallibilism, and collaboration-as-peers
form a coherent, differentiated epistemology. No comparable skills library has a
standards layer or a stated theory of why its content is shaped the way it is — the
repo's own benchmark matrix confirms this is its unique column. Endorsed without
reservation.

The **norm/thesis split** is the single best structural idea in the repo: it anticipates
that always-on context is the scarce resource. Recommendation: take it one step further
and make the operative norm **machine-extractable** — a `norm:` frontmatter field or a
marked section — so tooling can compile the norms of all installed standards into one
compact injectable block. The standards then have two lives: the compiled stance (always
in context) and the full text with thesis (on-demand depth). This turns the philosophy
from documentation into an operative layer, which is where it earns its keep.

Guard: philosophy only matters if it changes behaviour. The rewritten `base/bootstrap.md`
(stance injection, per ADR-0005) becomes the most important file in the repo. It should
be short (~15 lines) and every line must pass the repo's own behavioural-specificity
test.

## 2. The pivot — right call, half-executed

Local-first is correct for reasons beyond those recorded in ADR-0005:

- It matches where the ecosystem has converged: project-scoped `AGENTS.md`,
  `.agents/skills` (agentskills.io), `./.claude/skills`. Project-level wiring is far more
  uniform across harnesses than global wiring — most of the harness-matrix problem
  (ADRs 0001–0004, the tier ladder, the launcher) simply vanishes at project scope.
- It makes destructive-reversal structurally trivial. The teardown/manifest problem that
  consumed enormous design effort was a symptom of global mutation: when install means
  "files in a project plus one marker block", uninstall means deleting them, and git
  tracks everything. A lesson worth codifying: prefer designs where reversal is
  structurally trivial over designs that require a perfect ledger.

Defects found:

1. **The `global-first` branch did not exist**, though ADR-0005 and the handover both
   claim the superseded work is preserved on it. Fixed this session — branch created at
   master HEAD (which contains all of that work). Push pending the
   `gh auth switch --user burnish-studio` step.
2. **Master contradicts itself.** The README's front-door install is the superseded
   global flow; `install.sh`, `bin/`, `docs/agent-dir.md`, `docs/pid-setup.md`,
   `setup-repertoire`, and `teardown-repertoire` all still live on master. A cold agent
   following the README today installs the superseded architecture. This violates
   self-consistency at the architectural level and should be the first thing fixed.

## 3. The seam — the repo's own standard already answers it

`standards/programming-paradigm/`: "Where determinism is the actual requirement, remove
the operation from agentic judgement entirely — use a script." Delivery mechanics are
exactly such an operation, and the 2026-07-02 smoke test proved it empirically: manifest
quality was luck, not structure. The 600 lines of careful prose in `setup-repertoire` and
`teardown-repertoire` were compensating in natural language for missing determinism — a
category error the pivot corrects.

The correct division:

- **Deterministic (`rep` CLI):** file sync, project layout, version pinning, the
  manifest/lockfile, norms compilation, marker-block wiring writes, status checks.
- **Paradigm-2 (agent):** deciding what to include, interpreting the project, driving
  `rep` conversationally, resolving anomalies, and the paste-URL setup skill that ends by
  invoking `rep`.

The agent is the interactive front-end; the CLI is the transactional back-end. Both entry
paths — a human running `npx`, an agent running the setup skill — converge on the same
deterministic core, so the manifest problem dissolves rather than being disciplined away.

## 4. Form and structure — endorse with specific changes

- **Three-type ontology** (standards say ought, skills say do, templates say is): keep
  unchanged. Clean, teachable, and the standards layer is the differentiator.
- **Define a distribution surface.** The repo currently mixes product (`skills/`,
  `standards/`, `templates/`, `base/`) with workshop (`_work/`, `.plan/`, `docs/`,
  `bin/`). Make the boundary explicit — a vendoring manifest of what `rep` ships.
  Workshop material stays repo-only.
- **Selection granularity:** standards ship as a set — they are a mutually referencing
  normative system (perspective, intent-language, unknown-values all cross-link) and
  per-standard selection would break resolvability. Skills are individually selectable.
  This also settles how cross-artefact relative links survive vendoring.
- **The `model:` frontmatter field on enduring artefacts:** recommend dropping (a settled
  decision worth reopening). Git records provenance; the field goes stale and invites
  false precision on files edited by many models over time. Keep it on point-in-time
  `_work/` documents, where provenance is genuinely informative.
- **agentskills.io conformance** should be a hard requirement for skill frontmatter — it
  makes every skill portable to the large "Universal" harness cluster for free. The
  open research item (verify extra-field tolerance and canonical `.agents/skills` paths)
  is ~30 minutes of work and should close in the next design session.
- UK English, perspective convention, intent language: keep. They cost little and give
  the corpus a recognisable voice and unambiguous normative weight.

## 5. Installation and update — concrete design for `rep`

**`rep init`** vendors content into the project:

- Skills → `.agents/skills/<name>/` (the open standard the Universal cluster reads), with
  a Claude Code special case (`./.claude/skills/` symlinks or copies — verify whether
  current Claude Code reads `.agents/skills` natively before special-casing).
- Standards + templates → one vendored directory (e.g. `.agents/repertoire/`), full text
  including theses.
- Stance → a compiled, marker-delimited block (`<!-- repertoire:start/end -->`) appended
  to the project's `AGENTS.md` and/or `CLAUDE.md`: the bootstrap plus the operative norms
  of the installed standards.
- A lockfile (e.g. `.agents/repertoire.lock`): source repo, pinned tag/commit, exact file
  list. This *is* the manifest, written deterministically every time.

**`rep update`**: fetch, re-vendor, honour the pin. Vendored files are tool-owned and
never hand-edited — project-specific content lives beside them, not inside them. The
update must surface a **norm-level diff**: changing a standard changes the project's
operative stance, and the human should review that like a code diff. This is the feature
that makes repertoire a living participant in the workflow rather than a static drop.

**`rep remove`**: delete the lockfile's list plus the marker block. Trivial, because
local.

**`rep status`**: verify vendored files match the lock and the wiring block is present.

**Distribution:** one package, npx-first; installed binary later if wanted. Implement as
a small Node/TS tool with no dependency beyond git — boring and testable. Keep the
paste-URL front door as a short setup skill whose job is: check environment, explain,
run `rep init`, verify in a fresh session.

**Considered and rejected:** delegating entirely to the existing `skills` npm CLI. It
covers only the skills half — no standards, no norms compilation, no stance injection.
But adopt its layout standard so repertoire skills are *also* installable by it for free:
compatibility, not dependency. Also rejected: an MCP server. Files are the right medium
for normative content — they version, diff, vendor, and load without a runtime.

## 6. Semantic content — the real gap, and the highest-leverage move

Today the product is five meta-skills for maintaining itself, ten standards, one
template. Self-consistent and elegant — and nearly empty for an end user. Three months
went to delivery machinery for content that fits in a pocket: the classic infrastructure
trap.

The irony is that the most valuable practices this project has developed are not shipped
— they are the project's own workflow, proven in use in this very repo:

- **`handover`** — write/refresh a HANDOVER.md for session continuity. The pattern
  demonstrably works; this review was possible because of it.
- **`grill`** — the structured interrogation pattern (grill-with-docs) that produced
  ADR-0005.
- **`write-up`** — capture a session into a point-in-time document (already in backlog).
- **`adr`** — record a decision in the house style already visible in `.plan/adr/`.
- **`audit`** — generalise from "check the repertoire against its own standards" to
  "check a document set against its declared standards", keeping the repertoire as the
  default case.

That is a first content wave with zero invention risk — every item has already survived
contact with real use. The existing meta-skills (`write-a-skill` is genuinely excellent,
benchmark-hardened) remain as the maintainer's set. The old speculative backlog (caveman
etc.) stays dead.

## 7. Participation in AI workflows — the layered gradient

The end state is a progressive-disclosure gradient, each layer paying rent for its
context cost:

1. **Stance** (always in context): compiled bootstrap + norms block, small and sharp.
2. **Skill descriptions** (always, tiny): native per-harness discovery; description as
   trigger — already well understood in `write-a-skill`.
3. **Skill bodies** (on trigger).
4. **Theses, references, templates** (on demand).

Updates flow through `rep update` with human-reviewable norm diffs. Verification is a
fresh-session check (stance visible, a skill triggers), not an in-session proxy — the
lesson from the smoke test, kept.

## 8. Defect and decision list

| # | Item | Action |
|---|------|--------|
| 1 | `global-first` branch missing | **Fixed** (local); push after account switch |
| 2 | README/master describe superseded model | Phase 0 rewrite/prune |
| 3 | Superseded machinery on master | Phase 0 prune (after branch pushed) |
| 4 | `base/bootstrap.md` still a discovery nudge | Phase 3 rewrite (stance injection) |
| 5 | `.plan/` + `CONTEXT.md` frontmatter ruling open | Decide in Phase 0; recommend conform (`type: context`) |
| 6 | No LICENSE despite "repo public" being a v1 goal | Phase 0; owner picks (MIT suggested) |
| 7 | No version tags; `rep` pinning needs them | Phase 0; start `v0.x` |
| 8 | agentskills.io paths + frontmatter compat unverified | Phase 1 research (~30 min) |
| 9 | `model:` field on enduring artefacts | Phase 1 decision; recommend drop |

## 9. The plan

**Phase 0 — hygiene (one short session).** Push `global-first`; prune superseded
machinery from master; rewrite README (short, honest, local-first, "CLI coming");
resolve the `.plan/` frontmatter ruling; add LICENSE; tag `v0.1`.

**Phase 1 — finish the grill, lock the design (one session).** Remaining questions 2
(agent behaviour) and 3 (human workflow); then ADR-0006 locking: `rep` command surface,
project layout, lockfile format, norms compilation, selection granularity, the `model:`
field decision. Close the agentskills.io verification item.

**Phase 2 — build `rep` v0 (one to two sessions).** `init` / `update` / `remove` /
`status`; norms compiler; marker-block wiring; agentskills layout plus Claude Code
special case. Acceptance test, cold: empty project → `rep init` → new agent session →
stance active and a skill auto-triggers; `rep remove` → project byte-clean.

**Phase 3 — content (parallelisable with 2).** Rewrite `base/bootstrap.md`; add norm
markup to standards; build the first practice-skill wave (`handover`, `grill`,
`write-up`, `adr`); generalise `audit`.

**Phase 4 — publish v1.** README landing; paste-URL setup skill; tag `v1.0`; cold test
on the Fedora laptop (now testing `rep`, not the old flow).

**v1 success criteria (replacing the 2026-07-01 definition):** in an empty project,
`npx`-invoked `rep init` plus one fresh agent session yields active stance and triggering
skills; `rep update` shows a norm diff; `rep remove` leaves the project byte-clean; and
the repertoire ships at least four object-level skills a stranger would want.

## 10. Settled things this review endorses unchanged

Standalone/framework-free boundary (nothing from Station AI leaks down); the three-type
ontology; norm/thesis structure; UK English; perspective and intent-language conventions;
short philosophical standards; local-first (ADR-0005); descriptions as triggers; the
decision to keep tier-1 harness ambition small.
