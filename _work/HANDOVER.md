---
type: context
title: Repertoire — Handover
created: 2026-05-13
updated: 2026-05-14 (session 2)
status: current
model: sonnet-4-6
---

# Repertoire — Handover

_Perspective: [standards/perspective/STANDARD.md](../standards/perspective/STANDARD.md)_

Read this in full before doing anything. Do not re-litigate settled decisions.

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

## Build queue — in dependency order

### 1. Fedora laptop test ← NEXT ACTION

Fresh Fedora machine with only pi installed. Test the full install path:

```bash
curl -fsSL https://raw.githubusercontent.com/burnish-projects/repertoire/main/install.sh | bash
```

Or via agent: open a bare pi session and paste the curl command. Confirm:

- `pid --doctor` shows correct manifest
- Skills from repertoire appear in a session
- Bootstrap is active (skills auto-trigger without prompting)

This is the real-world validation of everything built in session 2.

### 2. Skills backlog

`write-a-skill` is done. Read all four benchmarks before building any of these.
Matt Pocock’s deprecated `ubiquitous-language` is the best external benchmark for that
skill specifically.

- `grill-me` — keep it simple; risk is over-engineering
- `ubiquitous-language` — needs output format, rules, example dialogue; richest of the set
- `caveman` — persistence rules, auto-clarity exception, before/after examples
- `write-up` — capture a completed session into a structured document
- `grill-you` — user interrogates the agent about its own nature or tendencies
- `introspect` — agent conducts structured self-reflection on a topic

### 3. Audit

Session 2 added new files (`base/bootstrap.md`, `bin/`, `docs/`, `skills/setup-repertoire/`,
`install.sh`). These must conform to repertoire’s standards. Run audit before or
during the next session that touches skills/standards/templates.

Note: `bin/` shell scripts and `install.sh` are outside the standard document audit
scope but should be reviewed for correctness.

### 4. Bibliography convention

Formalise where references to external sources live (distinct from reference files
the agent loads). Options: `REFERENCES.md` in skill/standard directory, or a
`sources` extended frontmatter field. Decide and add to a standard.

### 5. Open-shop / close-shop with the plate

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
- Audit was last run and clean as of the 2026-05-13 audit session. Session 2 added new repo files; audit should be run at start of next session before building more skills.
