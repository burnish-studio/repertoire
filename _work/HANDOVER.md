---
type: context
title: Repertoire — Handover
created: 2026-05-13
updated: 2026-05-13
status: current
model: sonnet-4-6
---

# Repertoire — Handover

_Perspective: [standards/perspective.md](../standards/perspective/STANDARD.md)_

Read this in full before doing anything. Do not re-litigate settled decisions.

---

## What this repo is

Repertoire is a collection of general-purpose agent skills, standards, and templates
for intelligent agent work. It is a standalone base layer — no dependencies on any
framework or downstream project. It builds on nothing; others build on it.

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
It is the philosophical foundation — short and essential.

---

## What is settled — do not re-litigate

- Repertoire is standalone. No framework-specific concepts from any downstream project.
- Skills are paradigm-2 briefings. Specify intent and outcome. Procedure must not be specified.
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

---

## Current state of the repo

### Standards

| Directory                       | Purpose                                                              |
| ------------------------------- | -------------------------------------------------------------------- |
| `agentic-programming-paradigm/` | The philosophical foundation. Read first.                            |
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

| Directory        | Purpose                                                       |
| ---------------- | ------------------------------------------------------------- |
| `write-a-skill/` | How to write a skill. Use for all subsequent skill authoring. |
| `audit/`         | Two-phase conformance check — diagnose then fix.              |
| `codify/`        | Place a discussed concept correctly into the repertoire.      |

---

## What to build next

### Skills backlog (in no particular order)

- `write-up` — capture a completed session into a structured document
- `grill-me` — interrogate a plan or design until it is robust
- `grill-you` — user interrogates the agent about its own nature or tendencies
- `introspect` — agent conducts structured self-reflection on a topic
- `ubiquitous-language` — extract a DDD-style ubiquitous language glossary
- `caveman` — compressed communication mode; minimal tokens

### Research task — quality benchmarking

Before adding further skills, check the current work against high-quality external
references. The goal is to ensure our skills have the same precision and sting as the
best examples online, while maintaining the paradigm-2 framing.

References to review:

- **Matt Pocock's skills** — known for sharp, effective agent skills; look for how
  specificity and clarity are achieved without procedural enumeration
- **Superpowers repo** — review skills and content for structural and stylistic insights
- **agentskills.io** — the specification we deferred to on description field guidance;
  review best practice examples and recommendations
- **Anthropic / Claude docs (openclaw)** — best practices for prompting and briefing
  agents; particularly relevant for how to write with authority and precision

What to look for: how the best examples achieve domain sharpness and specificity while
remaining briefings rather than procedures. Our paradigm-2 stance is not a licence for
vagueness — the content must have the same power as the best procedural equivalents,
just framed correctly: writing to a human expert, not programming a parser.

Where we expect to deviate: anything that implies step enumeration or checklist
structure. Hold our approach; evaluate whether the insight can be expressed in
paradigm-2 terms instead.

### Templates

Do not design ahead of need. Templates will emerge from building skills.

---

## Practical notes

- Owner: Adam
- Environment: WSL2 (Fedora), pi with Claude via GitHub Copilot
- Tone: direct, no fluff, technically precise
- Run `skills/audit/SKILL.md` at the start of any session where files have been touched
  since the last audit
