---
type: context
title: Repertoire — Handover
created: 2026-05-13
updated: 2026-07-03 (delivery architecture grill — ADRs, CONTEXT, scenarios in .plan/)
status: current
model: claude-opus-4-8
---

# Repertoire — Handover

_Perspective: [standards/perspective/STANDARD.md](../standards/perspective/STANDARD.md)_

Read this in full before doing anything. Do not re-litigate settled decisions.

---

## Start here (updated 2026-07-03)

**⚠ The delivery architecture was re-grilled from first principles on 2026-07-03. The
authoritative design now lives in `.plan/`, not in the "multi-harness three-tier" write-up
below (which is superseded in its specifics).** Read, in order:
`CONTEXT.md` (glossary) → `.plan/adr/0001–0004` (settled decisions) →
`.plan/reference/setup-scenarios.md` (spec-by-example + capability matrix + sample
manifest) → the "2026-07-03 session" log entry below. The 2026-07-02 three-tier entry is
kept for history but the ADRs supersede it.

**One-line state:** the architectural spine is settled and recorded; nothing in
`skills/`/`install.sh` has been rewritten yet. Next build step is "step A" — rewrite
`setup-repertoire` against the scenarios. Working tree has uncommitted new files
(`CONTEXT.md`, `.plan/`, the 2026-07-03 research doc) + this handover; nothing committed
or pushed this session.

**We are finishing repertoire to a shippable v1.** The "v1 done" definition is locked
(see the 2026-07-01 session log below): install works + uninstall exists + manual
fallback documented + the 5 existing meta-skills + public repo/README. General-purpose
skills, a dedicated site, bibliography convention, and open-shop/close-shop are all
**post-v1, not v1 gates.**

**Everything buildable up to 2026-07-01 is pushed** to `master` (commit `78a0d76`):
install manifest, `teardown-repertoire` skill, manual-install README section.

**⚠ Working tree is NOT clean — `_work/HANDOVER.md` has uncommitted edits from the
2026-07-02 session** (this file: smoke-test log + architecture write-up). Nothing else
changed. No repo code (skills/standards/install.sh) was touched this session. If you're a
fresh agent on the same machine, you're already reading the latest. To push, note the
gh-account gotcha at the bottom (`gh auth switch --user burnish-studio`).

**Two live threads:**

1. **Fedora laptop retest** (build queue item 1) — the locked v1 gate. Adam-run on the
   physical laptop (a fresh agent here cannot reach it); exact three-step check
   (install → manifest → uninstall) in item 1. Tests the pi/pid path. Once it passes,
   v1-as-scoped is done. Unaffected by thread 2.
2. **Multi-harness support** (build queue item 1a) — NEW as of 2026-07-02. Adam wants it;
   we designed a three-tier ladder (explicit specs / generic paradigm-2 / manual
   fallback). **The design is written up in the 2026-07-02 "Architecture discussion"
   session entry — read that in full before doing any of this work.** Resume by getting
   Adam's explicit yes on the `install.sh = core-only` split (item 1a, resume action 1),
   then it's a rewrite of `setup-repertoire` + `install.sh` + README.

**2026-07-02 smoke test (context for both threads):** a cold general-purpose agent
(Claude Code harness, zero project context) ran the full `setup-repertoire` →
`teardown-repertoire` loop against a throwaway `$HOME`. The round-trip **passed cleanly**
(nothing dangling; real `~/.agent` verified byte-identical before/after) — but surfaced
that the non-pi path is under-specified, which is what opened thread 2.

---

## What this repo is

Repertoire is a collection of general-purpose agent skills, standards, and templates
for intelligent agent work. It is a standalone base layer — no dependencies on any
framework or downstream project. It builds on nothing; others build on it.

It is layer-one tooling for a broader system: Repertoire → Station AI → Doti. Getting
it right matters because errors here propagate up the entire stack.

---

## Three artifact types

```
skills/{name}/
  SKILL.md          ← always required
  scripts/          ← deterministic utilities; co-located
  references/       ← supplementary material; loaded on demand

standards/{name}/
  STANDARD.md

templates/{name}/
  TEMPLATE.md
```

The ontology: standards say _ought_, skills say _do_, templates say _is_.

The test for where something belongs:

- Does this govern how things should be done generally? → standard
- Does this describe a repeatable action with an output? → skill
- Does this show correct form for something? → template

---

## Governing philosophy

Three short standards cover the philosophical foundation. They are intentionally brief.
Do not expand them without explicit instruction.

- `standards/fallibilism/` — no idea is above challenge; fallibilism as an optimistic
  stance; sycophancy named as the failure mode of collaboration
- `standards/programming-paradigm/` — the most important standard; when intelligence is
  in the execution layer, specify intent not procedure; over-specification (the
  micromanagement error) named as the failure mode
- `standards/collaboration/` — human and agent as peers; human brings unique insight and
  taste, not gospel authority; agent may know better; half of collaboration is doing,
  half is discovering while doing

---

## What is settled — do not re-litigate

- Repertoire is standalone. No framework-specific concepts from any downstream project.
- The `description` field in skill frontmatter must describe both what the skill does
  and when to use it. Trigger conditions alone are insufficient.
- Standards use descriptive titles, not coined names.
- Any document whose body uses `I`, `me`, `you`, or `your` must reference
  `standards/perspective/STANDARD.md` immediately under the h1.
- Normative statements must use intent language per `standards/intent-language/STANDARD.md`.
  This applies to all artifact types without exception.
- All enduring artifacts follow the directory pattern: `{type-plural}/{name}/UPPERCASE.md`.
- The repertoire is self-applying. Every standard must be followed by every file in
  the repo, including the standards themselves.
- UK English throughout.
- Standard directory names are concise: `fallibilism`, `collaboration`,
  `programming-paradigm` — not `fallibilism-and-epistemology` etc.
- The philosophical standards are kept short deliberately. Do not expand them without
  explicit instruction.

### Standard structure — settled

Every standard has two parts:

1. **Operative norm** — the binding statement. One to three sentences. Stands alone.
   Injectable — compact enough to be useful in a context window without the thesis.
2. **Thesis** — rationale and elaboration. Adds reasoning. Does not restate the norm.
   Required for understanding, application to edge cases, and error-correction.

---

## Current state of the repo

### Standards

| Directory               | Purpose                                                                     |
| ----------------------- | --------------------------------------------------------------------------- |
| `collaboration/`        | Human-agent peer relationship; taste and judgment as input not gospel.      |
| `document-metadata/`    | All documents must have complete frontmatter.                               |
| `fallibilism/`          | No idea is above challenge; fallibilism; sycophancy as failure mode.        |
| `file-naming/`          | Enduring artifacts vs point-in-time documents — two naming patterns.        |
| `intent-language/`      | Must / should / may — normative weight.                                     |
| `perspective/`          | I/me = user, you/your = agent.                                              |
| `programming-paradigm/` | Intent not procedure; over-specification (micromanagement) as failure mode. |
| `self-consistency/`     | The repertoire must conform to its own standards at all times.              |
| `self-contained-files/` | Every file must be intelligible cold and autonomous.                        |
| `unknown-values/`       | Sentinel values: `unknown` / `n/a`.                                         |

### Templates

| Directory      | Purpose                                             |
| -------------- | --------------------------------------------------- |
| `frontmatter/` | Copyable frontmatter block with field descriptions. |

### Skills

| Directory           | Purpose                                                      |
| ------------------- | ------------------------------------------------------------ |
| `write-a-skill/`    | How to write a skill. Benchmarked and updated — current.     |
| `write-a-standard/` | How to write a standard.                                     |
| `audit/`            | Two-phase conformance check — diagnose then fix.             |
| `codify/`           | Place a discussed concept correctly into the repertoire.     |
| `setup-repertoire/` | Install guide for repertoire; covers minimal and full paths. |

`write-a-skill/` has a `references/discipline-enforcing.md` file covering
rationalisation tables, red flags lists, and persuasion mechanisms for that skill type.

### Delivery infrastructure (not skills/standards/templates — lives in bin/, base/, docs/)

| File / Directory    | Purpose                                                                                   |
| ------------------- | ----------------------------------------------------------------------------------------- |
| `base/bootstrap.md` | General-purpose skills proactivity instruction. Symlinked to `~/.agent/base/` on install. |
| `bin/agent-core.sh` | Harness-agnostic core library. Sources into any harness adapter.                          |
| `bin/pid`           | Pi adapter. Sources agent-core.sh; ~45 lines of pi-specific logic.                        |
| `install.sh`        | One-command install. Creates `~/.agent/`, clones repo, symlinks.                          |
| `docs/agent-dir.md` | The `~/.agent/` convention as a full spec.                                                |
| `docs/pid-setup.md` | Pid flags reference and adapter-writing guide.                                            |

### Research output

| File                                                          | Contents                                            |
| ------------------------------------------------------------- | --------------------------------------------------- |
| `_work/2026-05-13_benchmark-matt-pocock-01--sonnet-4-6.md`    | Matt Pocock skills benchmark.                       |
| `_work/2026-05-13_benchmark-agentskills-io-01--sonnet-4-6.md` | agentskills.io benchmark.                           |
| `_work/2026-05-13_benchmark-superpowers-01--sonnet-4-6.md`    | Superpowers (obra) benchmark. New this session.     |
| `_work/2026-05-13_benchmark-openclaw-01--sonnet-4-6.md`       | OpenClaw (Steinberger) benchmark. New this session. |

Read all four before building any backlog skill.

---

## What was done last session (2026-05-13, previous)

- **Benchmarked Superpowers** (`github.com/obra/superpowers`) — ten new findings
  captured in `_work/2026-05-13_benchmark-superpowers-01--sonnet-4-6.md`. Key additions:
  description-as-workflow-summary is a tested failure mode; rationalization tables; red
  flags lists; persuasion principles as design tool; skill type taxonomy; when not to
  create a skill.
- **Benchmarked OpenClaw** (Steinberger) — four principles captured in
  `_work/2026-05-13_benchmark-openclaw-01--sonnet-4-6.md`. Key addition: the behavioral
  specificity test — every sentence must change a specific, observable behaviour; if it
  cannot fail, remove it.
- **Updated `skills/write-a-skill/SKILL.md`** — substantial rewrite incorporating all
  four benchmarks. New sections: when not to create a skill; skill type taxonomy;
  description field guidance (including workflow-summary prohibition); content principles
  (behavioral specificity, competent-agent test, match specificity to fragility, defaults
  not menus, effort prioritisation); content patterns (gotchas, output format, named
  anti-patterns, before/after examples); iteration as a maintenance practice.
- **Updated `standards/programming-paradigm/STANDARD.md`** — replaced the sycophancy
  paragraph (wrong failure mode for this standard) with the correct failure mode:
  over-specification producing rigidity and brittleness, same error as micromanaging a
  capable person.
- **Renamed `standards/epistemology/` → `standards/fallibilism/`** and rewrote the
  standard. Now leads with fallibilism as the normative stance; names sycophancy as the
  failure mode of collaboration; drops Deutschian jargon ("explanations") in favour of
  plain language.

**Audit status:** run and clean. 7 findings fixed — see below.

## What was done this session (2026-05-13, audit run)

Audit run. 7 findings fixed, all mechanical:

- **F1** `standards/document-metadata/STANDARD.md` — added missing perspective reference (used `you` without declaring convention)
- **F2** `skills/write-a-skill/references/discipline-enforcing.md` — added missing perspective reference (same)
- **F3** `standards/programming-paradigm/STANDARD.md` — converted bare imperatives to intent language (`must`/`must not`): "Write clear, direct prose" and "Do not write for a parser"
- **F4** UK English: `artifact` → `artefact` across `standards/file-naming/`, `standards/self-consistency/`, `skills/codify/`, `templates/frontmatter/`, `skills/audit/`
- **F5** UK English: `behavioral/Behavioral` → `behavioural/Behavioural` in `skills/write-a-skill/SKILL.md`
- **F6** UK English: `rationalization/rationalized` → `rationalisation/rationalised` in `skills/write-a-skill/SKILL.md` and `references/discipline-enforcing.md`
- **F7** UK English: `judgment` → `judgement` in `standards/programming-paradigm/`, `skills/audit/`, `skills/write-a-skill/SKILL.md`

Repo is in a clean, self-consistent state.

## What was done this session (2026-05-15, bootstrap design)

Research and design only — no files modified beyond this handover and research doc.

**Settled: paradigm 2 bootstrap design.**

- **Single-instruction install.** Entire setup initiated by pasting one line into any
  capable agent session: a natural language instruction + raw URL pointing to
  `setup-repertoire/SKILL.md`. Agent fetches the skill, assesses the environment,
  walks through setup interactively.

- **Agent writes the adapter.** The combinatorial problem (harnesses × OS × config
  variants) is unsolvable with pre-packaged scripts. The agent knows its own harness
  and environment. `setup-repertoire` specifies the end state; the agent handles
  procedure. `pid` is the reference implementation for pi/Unix, not the general case.

- **Requirements check first.** `setup-repertoire` must fail fast and clearly if the
  agent lacks file system access or shell execution. No partial setup, no silent
  failure. One clear message directing the user to a capable agent.

- **Interactive walkthrough.** Setup is a conversation, not silent automation. Each
  decision point surfaces a recommendation and asks for confirmation. User understands
  what happened when it's done.

- **pid's role clarified.** Optional convenience launcher for pi/Unix users. Not
  required infrastructure. Not offered to users on other harnesses.

- **`setup-repertoire` must be rewritten.** Current version is a human manual (old
  paradigm). Needs to become a paradigm 2 skill: end state + agent judgment, not
  procedure enumeration.

Full session research doc: `_work/2026-05-15_research-doc_bootstrap-design-01--sonnet-4-6.md`

---

## What was done this session (2026-05-14, delivery research)

No files were modified. Research only.

**Researched delivery and loading mechanisms** for Matt Pocock’s skills repo and Superpowers (obra). Key findings:

- **Matt Pocock — pull model.** Skills installed via `npx skills@latest add`, symlinked into `~/.claude/skills/` by `scripts/link-skills.sh`. Plugin manifest at `.claude-plugin/plugin.json`. Skills triggered by user slash commands (`/grill-me` etc.). User-initiated; agent doesn’t use them unless asked.

- **Superpowers — push model.** Multi-harness plugin manifests (`.claude-plugin/`, `.codex-plugin/`, `.cursor-plugin/`). A `SessionStart` hook fires on session open, reads `skills/using-superpowers/SKILL.md`, and injects its full content as `additionalContext`. That bootstrap skill instructs the agent to check for and auto-trigger relevant skills before any response. Skills are the default behaviour, not tools you reach for.

- **Key distinction for repertoire:** Pi already solves skill discovery via `available_skills` in the system prompt. What repertoire lacks is a bootstrap equivalent to `using-superpowers` — a meta-skill that tells the agent when and how aggressively to auto-trigger the others.

- Both repos cloned at `/tmp/` — will not persist; re-fetch as needed.

## What was done this session (2026-05-14, session 2 — delivery infrastructure build)

1. **`~/.agent/` as harness-agnostic root.** Content belongs to the user, not to any harness.

2. **Structure:**

   ```
   ~/.agent/
     base/       ← always loaded, protected — no local signal can suppress
     prompts/    ← global prompts; subdirectories are inert library space
     skills/     ← skills; use symlinks to point at skill repos
     repos/      ← managed git clones (install.sh / --update)
   ```

3. **Local repo overrides** via `.agent/` in the project directory:
   - `prompts/_append/` — add to global prompts
   - `prompts/_replace/` — ignore globals, use only these (absolute; base immune)
   - `skills/` — always additive
   - Pid warns if both `_replace/` and `_append/` are present

4. **`bin/agent-core.sh`** — harness-agnostic core library. All collection, model
   injection, manifest print, doctor/verify, update logic lives here. Adapters source
   this file; they do not reimplement it.

5. **`bin/pid`** — thin pi adapter (~45 lines). Sources agent-core.sh. Pi-specific
   only: reads model from `~/.pi/settings.json`, translates `APPENDS[]` and
   `SKILL_PATHS[]` to pi flags (`--no-context-files`, `--append-system-prompt`,
   `--skill`), execs pi. Writing an adapter for another harness: follow same pattern.

6. **`~/bin/pid`** now symlinks to `repertoire/bin/pid` — updates via `git pull`.

7. **`install.sh`** — one-command install. Creates `~/.agent/` structure, clones
   to `~/.agent/repos/repertoire/`, symlinks bootstrap/skills/pid, verifies.

8. **`skills/setup-repertoire/SKILL.md`** — the install document. Covers minimal
   path (skills only, no convention buy-in) and full path (agent-dir + pid). Written
   for human or agent — same document, both audiences.

9. **`base/bootstrap.md`** — general-purpose skills proactivity instruction now
   lives in the repo; symlinked to `~/.agent/base/` by install.sh.

10. **`docs/agent-dir.md`** — the `~/.agent/` convention as a full spec.

11. **`docs/pid-setup.md`** — rewritten as pid flags reference and adapter guide.

12. **Pi settings** — skills array removed. Pid is sole controller.

13. **Philosophical point settled:** INSTALL.md and a setup skill are the same thing.
    Instructions for an intelligent reader work for human or agent. One document,
    two access paths. Optimise for clarity, not for which reader type.

Full session research doc: `_work/2026-05-14_research-doc_delivery-mechanics-pid-01--sonnet-4-6.md`

---

## What was done this session (2026-07-01, v1 scoping + uninstall)

**Defined "v1 done" and executed the buildable parts.** The prior build queue was a
sonnet-4-6 draft; the general-purpose skills backlog (grill-me, caveman, etc.) was
*not* endorsed by Adam and is deliberately dropped from v1.

**v1 "done" definition (locked with Adam):**

1. Install verified — Fedora retest passes (Adam-triggered; the 4 fixes are already in
   code from the previous commit).
2. Uninstall exists — install manifest + `teardown-repertoire`. **Done this session.**
3. Manual copy-paste fallback documented. **Done this session** (README "Manual
   install" section pointing at `install.sh`).
4. Skills = the 5 existing meta-skills. No new general-purpose skills in v1 — that is a
   deliberately-scoped **post-v1** track, not a v1 gate.
5. Repo public + README landing. No dedicated site in v1 (post-v1).

Deferred to post-v1: general-purpose skills, bibliography convention, open-shop/
close-shop, dedicated site.

**Built:**

- `skills/setup-repertoire/SKILL.md` — new "Record the install — the manifest" section.
  Setup now writes `~/.agent/install-manifest.md` as it works, recording only what it
  actually created (the safety rule: teardown removes exactly what the manifest lists,
  nothing pre-existing). Execution narration and end-of-setup updated to mention the
  manifest and uninstall.
- `skills/teardown-repertoire/SKILL.md` — new skill. Reads the manifest, presents a
  plan, reverses every change in safe order (harness wiring → PATH → symlinks → clone →
  empty dirs → manifest), confirming before removals. Handles a missing manifest by
  offering cautious reconstruction rather than guessing.
- `install.sh` — now writes the same manifest, capturing directory/clone pre-existence
  before `mkdir`/clone so scripted installs are equally reversible. Verified end-to-end
  against a throwaway HOME: fresh install records what it created; idempotent re-run
  correctly marks pre-existing dirs/clone as "leave in place".
- `README.md` — added "Manual install (no agent)" and "Uninstall" sections.
- `.gitignore` already ignores `/.claude` (session plugin cache — not repo content).

Self-consistency checked on touched files: UK English clean, perspective refs present,
frontmatter complete, intent language used.

**Still open for v1:** the Fedora retest (item 1) — Adam-run, on the laptop.

---

## What was done this session (2026-07-02, cold-agent smoke test)

Ran the local smoke-test the previous handover flagged as adjacent work. No repo code
changed — this session is verification + logging only (this handover is the only edit).

**Method.** Spawned a fresh general-purpose agent under the Claude Code harness with
**no project context** — it got only the exact user paste line (install instruction +
raw `setup-repertoire` URL on master) plus one sandbox constraint: a throwaway `$HOME`
so it could not touch the real `~/.agent`. It fetched the skill cold, installed, wrote
the manifest, then found and ran `teardown-repertoire` to reverse everything. Observed
from outside without coaching, to keep the legibility test honest (the current session
agent is contaminated — it knows the intent — so it cannot be the executor).

**Result — round-trip PASSES.** Install completed first try (no errors); the manifest
recorded exactly what was created; teardown read the manifest, presented a plan matching
the install 1:1, reversed in safe order, and left nothing dangling. Independently
verified: real `~/.agent` byte-identical to a pre-test snapshot (413 entries), `~/bin/pid`
intact, sandbox home empty. The paradigm-2 "manifest is the agent's own record" design
works.

**Findings — the non-pi harness path is under-specified.** All three cluster on the skill
being pi-centric while the README claims it "works with pi, Claude Code, Cursor, and any
agent":

1. **Claude Code harness wiring is improvised.** `setup-repertoire` frames the target end
   state around `~/.agent/`, which Claude Code does not read. The wiring section (SKILL.md
   "Harness wiring") says "use your knowledge of how that harness loads global context" and
   gives `~/.claude/CLAUDE.md` only as an example. The cold agent had to invent the concrete
   wiring (a `~/.claude/CLAUDE.md` import line + a `~/.claude/skills` symlink). Because
   teardown reverses "exactly what the manifest records," teardown safety depends on that
   improvised manifest, not on the skill — a different agent would wire (and record) it
   differently.
2. **The skills-symlink shape assumes pi's loader.** SKILL.md's end state is
   `~/.agent/skills/repertoire → skills/`, which under Claude Code's discovery
   (`~/.claude/skills/<name>/SKILL.md`) points at a non-existent `repertoire/SKILL.md`. The
   agent had to silently correct the model to make discovery work.
3. **`install.sh` diverges from `SKILL.md` and is never mentioned by it.** Verified in
   code: `install.sh` has no harness detection — it unconditionally creates `~/bin` and the
   `pid` symlink (pi-only artefacts) and does **zero** harness wiring. So on a non-pi
   harness it produces a broken install (spurious unusable `~/bin/pid`; bootstrap/skills
   never actually load) and a different manifest than the skill's path. Yet the README
   offers `install.sh` as the "manual install (no agent)" fallback for any user. SKILL.md
   is, by contrast, explicitly harness-aware ("pid… pi/Unix only", "Do not mention it to
   users on other harnesses").

### Architecture discussion (same session, 2026-07-02) — three-tier harness support

**Adam's direction (stated this session):** he *does* want to support multiple harnesses.
The paradigm-2 ideal is to offload environment specifics to the local AI. He proposed:
do something explicit for a few major harnesses, a generic paradigm-2 catch-all for the
rest, and — when the catch-all can't manage it — surface the failure and point the user
to set it up manually. This is a graceful-degradation ladder. It is the agreed **shape**;
the detail below is the current-agent's refinement, mostly endorsed, with **one point
still needing Adam's explicit yes** (the `install.sh` split — see end).

**The key insight the ladder was missing.** The smoke test's tier-2 path *succeeded* —
the cold agent wired Claude Code correctly by improvisation. The fragility is one level
down and is **orthogonal to the tier count**: install is a creative forward act, but
**teardown is a replay** — it must reverse *exactly and only* what install did, possibly
on another machine / another agent / months later. Teardown can't re-improvise; it can
only replay a record. So the load-bearing artefact is the **manifest** — the contract
between two independent paradigm-2 acts. The round-trip was clean only because the agent
*happened* to write a precise manifest. That "happened to" is the real problem: manifest
quality was luck, not enforced. **Install and teardown are asymmetric; naming that
asymmetry is the design.**

**The layered model reached:**

- **Universal core (harness-agnostic spine — all tiers build on it):**
  - the `~/.agent/` structure + clone + symlinks;
  - the wiring contract stated **abstractly**: "bootstrap loads on every session start;
    skills are discoverable" — the testable target every tier aims at;
  - **manifest discipline as a hard requirement, not an emergent property of a capable
    agent** — every concrete mutation, exact path/file/line, whether it pre-existed. This
    is what makes tier-2 improvisation *safe* rather than *lucky*;
  - **verification with teeth**: "loads every session" is only truly confirmable by a
    *new* session; in-session file/symlink presence is a proxy. Skill should say so and
    hand the user a one-line self-check ("open a new session, ask if it sees the
    repertoire skills"). Tier 2 must confirm the end state or fall to tier 3.
- **Tier 1 — explicit — specs, NOT adapters.** Distinguish a *launcher* (`pid`: runtime,
  model injection, session start) from *wiring* (install-time static config). Most
  harnesses wire via static config (Claude Code = a `CLAUDE.md` import + a skills dir;
  Cursor similar) and need **no adapter** — just a concrete end-state spec so the manifest
  is deterministic. Only pi is heavyweight because pi *also* has a launcher. So tier-1
  support is cheap for static-config harnesses; write exact end states, don't build
  adapters you don't need.
- **Tier 2 — generic paradigm-2 catch-all.** Agent maps the abstract wiring contract onto
  its own harness, **must** write a precise manifest, **must** verify the end state, and
  falls to tier 3 if it can't identify a mechanism *or can't confirm the wiring worked*
  (not just "can't do it" — "can't verify it").
- **Tier 3 — manual fallback.** Surface the failure honestly and hand the user the
  end-state spec to wire themselves (and note teardown is then manual too — symmetric).
  Insight: **a no-agent install is tier 3 by definition** — with no agent, the human does
  the paradigm-2 wiring.

**The load-bearing move that dissolves finding #3 — NEEDS ADAM'S EXPLICIT YES:**

> **`install.sh` = tier 3's automation of the universal core.** It does the deterministic
> part (structure + clone + symlinks + manifest) and does **no** harness wiring — it
> prints the manual wiring end-state and stops. The agent path (`setup-repertoire`) does
> core + tier-1/2 wiring on top.

This removes install.sh's hidden pi hard-coding and makes it an honest "no agent" fallback
(matching what the README already claims). The current divergence wasn't a bug to patch —
it was a sign the two paths had overlapping responsibilities. Adam ran out of time before
confirming this split; **first thing to confirm on resume.**

**Scope guidance for v1:** the *architecture* is cheap to decide now (it's just how
`setup-repertoire` is structured + the `install.sh` split). *Populating* tier-1 is the
cost. For v1: lock the three-tier structure + manifest/verification hardening + the
install.sh split; seed tier-1 with **pi (done) + Claude Code (now known from the smoke
test)**; Cursor and the rest ride tier-2/3 until actually tested. **Resist growing
tier-1** — every explicit harness is a promise that drifts when that harness changes its
config mechanism (Superpowers pays exactly this multi-manifest maintenance tax). None of
this blocks the pi-path Fedora retest (item 1), which is unaffected.

## What was done this session (2026-07-03, delivery architecture grill)

Ran a `grill-with-docs` session on the delivery architecture. No `skills/`/`install.sh`
code changed — output is design docs in a new `.plan/` tree + `CONTEXT.md` + one research
doc. **These supersede the 2026-07-02 three-tier specifics.**

**Settled and recorded (`.plan/adr/`):**
- **0001 Storage/wiring split** — `~/.agent/` is neutral *storage*; "wiring" always means
  a pointer into the *harness's own* config. pi is one adapter, not the core. Dissolves
  smoke-test findings #2/#3 architecturally.
- **0002 Adapter model** — an Adapter is agent-written minimal wiring (static: import line
  + skill registration; or a launcher like `pid`). B-spine + native-plugin opt-in. Clean
  mode is launcher-only; static-wiring harnesses are Additive-only. *(Weighting under
  review — see open item 1.)*
- **0003 Delivery flows** — lifecycle ops (setup/teardown/update/doctor) are agent-driven
  interactive "CLI-style" flows; detect-then-confirm OS+harness; **one pass can wire
  multiple harnesses** (one Core, N adapters); `install.sh` is core-only + honest manual
  fallback.
- **0004 Manifest schema** — the manifest is a defined, per-adapter, verifiable schema
  (install.sh writes deterministic core rows; the flow adds per-adapter rows; `doctor`
  diffs against reality). **New requirement:** an "edited shared file" entry kind
  (marker-delimited block) for Codex `AGENTS.md` / Claude `CLAUDE.md` in-place edits.

**Key findings (in `.plan/reference/setup-scenarios.md` — capability matrix + a sample
multi-harness manifest):**
- The **End state is two independent capabilities** (bootstrap-loads; skills-discoverable),
  reported per-half.
- **"What to do" is liftable from working integrations** (Superpowers manifests/hooks;
  Matt Pocock `link-skills.sh`); **"who does it" stays paradigm-2.** This reframes the
  build as *adaptation of known-good recipes*, not invention.
- **The skills half is largely a solved standard problem:** the `skills` npm CLI supports
  72 agents; a big "Universal" cluster reads one standard dir `.agents/skills`
  (agentskills.io). Only Claude Code (`.claude/skills`) and pi (launcher) are special.
  The remaining per-harness variation is the **bootstrap half**.
- Superpowers' **plugin format is uniform** across Claude/Codex/Cursor (`"skills":
  "./skills/"` + sessionStart hooks) — the "multi-manifest tax" is smaller than feared,
  which may promote the plugin from opt-in to primary tier-1 recipe (open item 1).

**Open for next session (all light, none blocking):**
1. Re-weigh ADR-0002: lift Superpowers' plugin manifests as the *primary* tier-1 recipe
   for plugin-harnesses (keep hand-rolled for pi + no-plugin fallbacks)?
2. Verify exact canonical `.agents/skills` paths (Global vs Project) in the agentskills.io
   standard; fold End-state-is-two-capabilities + Codex/Cursor corrections into ADR-0004.
3. Housekeeping: does the `document-metadata` standard govern `.plan/` + `CONTEXT.md`, or
   are they exempt like README/`base/`? (Currently left frontmatter-free; the 2026-07-03
   research doc *does* have frontmatter — reconcile.)
4. **Then step A** — rewrite `setup-repertoire` against the scenarios, then `install.sh`
   (core-only) + README, then re-run the cold-agent smoke test.

Nothing committed/pushed this session. New untracked: `CONTEXT.md`, `.plan/`,
`_work/2026-07-03_research-doc_harness-conventions-audit-01--opus-4-8.md`.

## Build queue — in dependency order

### 1. Fedora laptop retest ← NEXT ACTION (the last open v1 item)

This is the only thing between here and v1. All code is pushed to `master`
(commit `78a0d76`, 2026-07-01). The four earlier install bugs are fixed (branch name,
find -L, PATH guidance, duplicate skills path), audit is clean, and this session added
the install manifest + teardown. Retest by pasting into a bare pi session on the
Fedora laptop (fresh env, fish shell — the point of using this machine):

```
Set up repertoire on this machine:
https://raw.githubusercontent.com/burnish-studio/repertoire/master/skills/setup-repertoire/SKILL.md
```

**Confirm, in one pass:**

1. **Install** — capabilities check passes, plan presented before acting, interactive
   walkthrough, bootstrap loads in a new session, skills visible and auto-trigger,
   `pid --doctor` shows bootstrap + skills path.
2. **Manifest** — `~/.agent/install-manifest.md` exists and accurately lists what was
   created (dirs, clone, symlinks, any PATH/shell-config edit).
3. **Uninstall** — ask the agent to run `teardown-repertoire`; confirm it reads the
   manifest, presents a plan, reverses cleanly, and leaves nothing dangling (pid gone,
   symlinks gone, PATH line removed, pre-existing content untouched).

Report what breaks; fix in the same push-to-master-and-retest loop (no branches — solo
project, forward speed is the explicit preference).

### 1a. Multi-harness support — three-tier design (from the 2026-07-02 architecture discussion)

Adam wants multi-harness support. The **shape is agreed** (three-tier ladder); the full
design is written up in the 2026-07-02 "Architecture discussion" session entry above —
read it before touching anything. Summary of the layered model: universal harness-agnostic
core (structure + abstract wiring contract + **enforced manifest discipline** + real
verification) → tier 1 explicit **end-state specs** (not adapters; pi + Claude Code for
v1) → tier 2 generic paradigm-2 catch-all (must write manifest, must verify, else
fall through) → tier 3 manual fallback (surface failure, hand user the end-state spec).

**Resume actions, in order:**

1. **Get Adam's explicit yes on the load-bearing move:** `install.sh` becomes
   **core-only** (structure + clone + symlinks + manifest, **no** harness wiring; prints
   the manual wiring end-state and stops). `setup-repertoire` does core + tier-1/2 wiring.
   This dissolves finding #3. Everything below assumes this yes.
2. **Rewrite `setup-repertoire/SKILL.md`** around the three tiers: state the wiring
   contract abstractly; add concrete tier-1 end-state specs for pi and Claude Code
   (Claude Code = `~/.claude/CLAUDE.md` import line + skills registration at
   `~/.claude/skills/<name>/SKILL.md` shape — note the current `~/.agent/skills/repertoire
   → skills/` symlink assumes pi's loader, finding #2); make manifest discipline a hard
   requirement for every tier; add a verification step + user self-check; specify the
   tier-3 fall-through trigger ("can't identify a mechanism *or can't verify*").
3. **Rework `install.sh`** to core-only per the split; drop the unconditional `~/bin`/`pid`
   creation and pi assumptions; have it print the manual (tier-3) wiring end-state.
4. **Reconcile the README:** its "works with pi, Claude Code, Cursor, and any agent" claim
   becomes honest under the tiers; keep the `install.sh` manual-install section but frame
   it as core-only + manual wiring.
5. **Update `teardown-repertoire`** only if the manifest format changes — its contract
   (reverse exactly what the manifest records) already holds; verify it still does.
6. Run `skills/audit/SKILL.md` after (skills/standards/templates touched). Then re-run the
   cold-agent smoke test to confirm the new tier-2 path + manifest hold.

**Resist growing tier-1** beyond pi + Claude Code for v1 (Cursor etc. ride tier-2/3 until
tested). Does not block item 1 (Fedora retest exercises the pi path, unaffected).

### 2. Skills backlog — POST-V1, NOT a v1 gate

Deliberately **out of v1** (Adam's call, 2026-07-01). The list below was a prior
session's draft Adam did not endorse — `caveman` and others overlap with Matt Pocock's
skills and were never scoped for repertoire. Do **not** treat these as pending work.
When a post-v1 general-purpose-skills track opens, scope it fresh with Adam rather than
inheriting this list. Read all four benchmarks before building any skill.

- `grill-me` — keep it simple; risk is over-engineering
- `ubiquitous-language` — needs output format, rules, example dialogue; richest of the set
- `caveman` — persistence rules, auto-clarity exception, before/after examples
- `write-up` — capture a completed session into a structured document
- `grill-you` — user interrogates the agent about its own nature or tendencies
- `introspect` — agent conducts structured self-reflection on a topic

### 4. Audit — clean as of 2026-05-19

All F1–F6 applied. D1–D4 resolved:

- **D1** `README.md` exempted from frontmatter standard — YAML renders badly on GitHub.
  Exemption added to `standards/document-metadata/STANDARD.md`.
- **D2** `base/` files exempted from frontmatter standard — runtime-injection category;
  frontmatter would pollute the system prompt. Same standard updated.
- **D3** `research-doc` added as an allowed `type` value in
  `templates/frontmatter/TEMPLATE.md`.
- **D4** Optional type segment codified in `standards/file-naming/STANDARD.md`.
  Pattern `YYYY-MM-DD_<type>_<topic>-<nn>--<model>.md` is now valid.

F6 file renamed to `2026-05-15_research-doc_install-test-report-01--unknown.md`.
`bin/PID.md` added (pid launcher documentation, colocated with script). Frontmatter
applied to `docs/agent-dir.md`, `docs/pid-setup.md`, and `bin/PID.md`.

Next audit: run after the skills backlog items are built.

### 5. Uninstall — install manifest and teardown skill ← DONE 2026-07-01

Both parts built this session — see the session log above. `install-manifest.md` is
written by both `setup-repertoire` (agent path) and `install.sh` (scripted path);
`teardown-repertoire` reverses it interactively. Original requirement preserved below.

During the first real install test (Fedora, 2026-05-15), manually reversing the
installation was needed and the process was opaque. Two things are needed:

**Install manifest** — during setup, the agent should write a log of every change
made to the system: directories created, symlinks added, PATH modifications, files
written. Location: `~/.agent/install-manifest.md` (or similar). Format: a simple
list of reversible actions with enough detail to undo each one.

**Uninstall skill / command** — a `teardown-repertoire` skill (or equivalent
one-line agent instruction) that reads the manifest and walks back every change,
confirming with the user at each step. Same interactive pattern as install: present
what will be removed, confirm, execute, verify.

This is a natural extension of the paradigm 2 install approach. The manifest is the
agent's own record of what it did; the uninstall uses it rather than guessing.

### 6. Bibliography convention

Formalise where references to external sources live (distinct from reference files
the agent loads). Options: `REFERENCES.md` in skill/standard directory, or a
`sources` extended frontmatter field. Decide and add to a standard.

### 7. Open-shop / close-shop with the plate

Open-shop spins up a session temp folder (`_work/plate-{date}/` or similar). All
in-session artifacts land there. Close-shop processes the folder — promotes permanent
content, cleans ephemeral content. The plate is the staging area for live session
work. Detail to be worked out when building the skills.

---

## Standards structure note

Standards are always-applicable — not loaded on demand like skills. Their volume
therefore has a token cost in every context. Standards should be concise by design.
The norm/thesis structure helps: the norm is compact and injectable; the thesis is
available but not always needed. Future consideration: a mechanism to inject only
the operative norms of all standards. This is a harness/layer concern, not
a repertoire concern — the repertoire just needs to make its content usable by
whatever mechanism is implemented above.

---

## Practical notes

- Owner: Adam
- Environment: WSL2 (Fedora), pi with Claude via GitHub Copilot. Also: fresh Fedora laptop (only pi installed) available for install testing.
- Tone: direct, no fluff, technically precise
- Run `skills/audit/SKILL.md` at the start of any session where skills/standards/templates have been touched since the last audit
- Matt Pocock skills repo is cloned at `/tmp/pi-github-repos/mattpocock/skills` — may not persist across sessions; re-fetch from `https://github.com/mattpocock/skills/` if needed
- Superpowers repo is cloned at `/tmp/pi-github-repos/obra/superpowers` — may not persist across sessions; re-fetch from `https://github.com/obra/superpowers/` if needed
- `~/.pi/agent/doti/operative/` still exists — old location, safe to delete once confident nothing is missing from it
- Audit clean as of 2026-05-19. All F1–F6 applied, D1–D4 resolved. See build queue item 4.
- **Pushing to `master`:** git uses gh's active account as its credential helper
  (`credential.helper = gh auth git-credential`). The default active account is
  `flintec-studio`, which **cannot** push to `burnish-studio/repertoire` (403). Two
  gh accounts are logged in; before pushing run `gh auth switch --user burnish-studio`
  (switch back with `gh auth switch --user flintec-studio` if you want to restore the
  default). Adam's workflow: push straight to `master`, test against latest pushed,
  no branches.
