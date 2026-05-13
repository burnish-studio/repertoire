---
type: context
title: Repertoire — Handover
created: 2026-05-13
updated: 2026-05-13
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

Everything here is built on the agentic programming paradigm. Read
`standards/agentic-programming-paradigm/STANDARD.md` before contributing anything.

**This standard needs to be rewritten.** See settled decisions and build queue below.

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

### Paradigm-2 — settled but needs sharper framing

The prohibition on procedure has been clarified this session. The correct test is not
"does this look like steps?" but **"would a competent agent already know this?"** If
yes, omit. If no, say it — in whatever form serves the communication. Domain-specific
non-obvious insight belongs in a skill even if it is structured. Generic procedure
the agent can derive does not.

The deeper framing: the relationship between agent and human is not
specification → execution. It is **conjecture → criticism → better conjecture**
(Deutsch/Popper). The agent is a participant in knowledge growth, not an executor of
fixed intent. The human is not a gospel source of rigid specification — they are a
generative engine. Even the ends are subject to revision and improvement.

This framing must be reflected in `agentic-programming-paradigm` and in any new
standards written this session.

### Standard structure — settled

Every standard has two parts:

1. **Operative norm** — the binding statement. One to three sentences. Stands alone.
   Injectable — compact enough to be useful in a context window without the thesis.
2. **Thesis** — rationale and elaboration. Adds reasoning. Does not restate the norm.
   Required for understanding, application to edge cases, and error-correction.

This is the law-operative / law-rationale distinction. The norm is what is enforced;
the thesis is what enables the norm to be understood and disputed.

---

## Current state of the repo

### Standards

| Directory                       | Purpose                                                              |
| ------------------------------- | -------------------------------------------------------------------- |
| `agentic-programming-paradigm/` | The philosophical foundation. **Needs rewrite — see build queue.**   |
| `document-metadata/`            | All documents must have complete frontmatter.                        |
| `file-naming/`                  | Enduring artifacts vs point-in-time documents — two naming patterns. |
| `intent-language/`              | Must / should / may — normative weight.                              |
| `perspective/`                  | I/me = user, you/your = agent.                                       |
| `self-consistency/`             | The repertoire must conform to its own standards at all times.       |
| `self-contained-files/`         | Every file must be intelligible cold.                                |
| `unknown-values/`               | Sentinel values: `unknown` / `n/a`.                                  |

### Templates

| Directory      | Purpose                                             |
| -------------- | --------------------------------------------------- |
| `frontmatter/` | Copyable frontmatter block with field descriptions. |

### Skills

| Directory           | Purpose                                                               |
| ------------------- | --------------------------------------------------------------------- |
| `write-a-skill/`    | How to write a skill. Needs update after agentskills.io benchmark.    |
| `write-a-standard/` | How to write a standard. New this session. Use for all new standards. |
| `audit/`            | Two-phase conformance check — diagnose then fix.                      |
| `codify/`           | Place a discussed concept correctly into the repertoire.              |

### Research output

| File                                                       | Contents                                                           |
| ---------------------------------------------------------- | ------------------------------------------------------------------ |
| `_work/2026-05-13_benchmark-matt-pocock-01--sonnet-4-6.md` | Matt Pocock skills benchmark. Read before building backlog skills. |

---

## Build queue — in dependency order

### 1. `standards/epistemology-of-knowledge-growth/` — NEW

A standalone standard for the Deutsch/Popper epistemological foundation. General
enough to stand on its own — not specific to agentic programming. Covers:

- Knowledge grows through conjecture and criticism, not through authority or procedure
- Error-correction as the fundamental epistemic mechanism
- No source is authoritative — only explanations that have survived criticism
- Substrate independence: what matters is the abstract structure, not the encoding
- The implication: participants in any knowledge-creating enterprise are peers in a
  conjecture-criticism loop, not authority and executor

This standard is the foundation. Everything else derives from it.

### 2. `standards/agentic-programming-paradigm/` — REWRITE

Rewrite to reference `epistemology-of-knowledge-growth` and derive from it. The
practical implications of the epistemology in the specific context of programming
with agents. Key points to land:

- The correct heuristic: write to the agent as a competent intelligent human
- The test for what to include: would a competent agent already know this?
- The relationship is conjecture → criticism → better conjecture, not
  specification → execution
- Domain-specific non-obvious insight belongs even if it looks procedural
- Generic procedure the agent can derive does not belong

### 3. `standards/collaborative-epistemology/` — NEW

The human-agent relationship model. Distinct from the paradigm standard (which is
about the agent) — this is about the collaboration. Key points:

- The human is not a fixed source of specification; they are a generative engine
- Even ends are subject to revision and improvement
- The right orientation: characterise what makes a good end, not specify a fixed end
- Characterisation of quality is more powerful than specification of output

### 4. Benchmark agentskills.io

Review agentskills.io for skill quality standards and description field guidance.
Capture findings in `_work/` using the same pattern as the Matt Pocock benchmark.
Do this before updating `write-a-skill`.

### 5. `skills/write-a-skill/` — UPDATE

Update after the agentskills.io benchmark. Changes expected based on Matt Pocock
benchmark findings:

- The competent-human heuristic
- Named anti-patterns with causal explanation
- Explicit effort prioritisation where relevant
- Concrete output format specification when a skill has a defined output
- Before/after examples for non-obvious rules

### 6. Skills backlog

Build these against the updated foundation. Matt Pocock's deprecated
`ubiquitous-language` is the best external benchmark for that skill specifically —
read it before building.

- `grill-me` — keep it simple; risk is over-engineering
- `ubiquitous-language` — needs output format, rules, example dialogue; richest of the set
- `caveman` — persistence rules, auto-clarity exception, before/after examples
- `write-up` — capture a completed session into a structured document
- `grill-you` — user interrogates the agent about its own nature or tendencies
- `introspect` — agent conducts structured self-reflection on a topic

### 7. Bibliography convention

Formalise where references to external sources live (distinct from reference files
the agent loads). Options: `REFERENCES.md` in skill/standard directory, or a
`sources` extended frontmatter field. Decide and add to a standard.

### 8. Open-shop / close-shop with the plate

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
- Environment: WSL2 (Fedora), pi with Claude via GitHub Copilot
- Tone: direct, no fluff, technically precise
- Run `skills/audit/SKILL.md` at the start of any session where files have been touched
  since the last audit
- Matt Pocock skills repo is cloned at `/tmp/pi-github-repos/mattpocock/skills` —
  may not persist across sessions; re-fetch from `https://github.com/mattpocock/skills/`
  if needed
