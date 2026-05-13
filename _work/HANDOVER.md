---
type: context
title: Repertoire — Handover
created: 2026-05-12
updated: 2026-05-12
status: current
model: sonnet-4-6
---

# Repertoire — Handover

_Perspective: [standards/perspective.md](standards/perspective.md)_

Read this in full before doing anything. Do not re-litigate settled decisions.

---

## What this repo is

Repertoire is a collection of general-purpose agent skills, standards, and templates
for intelligent agent work. It is a standalone base layer — no dependencies on any
framework or downstream project. It builds on nothing; others build on it.

The dependency relationship for context only:

```
repertoire          ← this repo
    ↓
station-ai          ← framework for AI-native systems
    ↓
doti                ← AI personhood project
```

Repertoire is indifferent to all of this. It is written for any agent, any harness,
any project.

---

## Three artifact types

```
skills/{name}/
  SKILL.md
  CHANGELOG.md      ← optional
  _work/            ← research and notes; not deployed

standards/{name}.md

templates/{name}.md
```

The ontology: standards say _ought_, skills say _do_, templates say _is_. This
distinction matters — do not blur it.

---

## Governing philosophy

Everything here is built on the agentic programming paradigm. Read `standards/agentic-programming-paradigm.md`
before contributing anything. It is short.

---

## What is settled — do not re-litigate

- Repertoire is standalone. No Station AI concepts (stations, inboxes, HQ, soul, heart).
  If you find yourself writing about any of those, stop — you are in the wrong repo.
- Skills are paradigm-2 briefings. No step lists. No procedure. Intent and outcome only.
- The `description` field in skill frontmatter states trigger conditions only — never a
  capability summary. A capability summary causes the agent to act on the description
  instead of loading the full skill. This defeats the purpose.
- Standards use descriptive titles, not coined names. The standards folder must be
  scannable without prior knowledge.
- Any document whose body uses `I`, `me`, `you`, or `your` must reference
  `standards/perspective.md` immediately under the h1.
- Intent language (`must`, `should`, `may`) must be applied consistently per
  `standards/intent-language.md`. Do not use "ought to", "ideally", or similar
  ambiguous phrasing in normative statements.
- UK English throughout.

---

## What has been built

### Standards

All seven standards are written and current.

| File                              | Purpose                                                                           |
| --------------------------------- | --------------------------------------------------------------------------------- |
| `agentic-programming-paradigm.md` | The agentic programming paradigm — the philosophical foundation. Read this first. |
| `perspective.md`                  | Pronoun convention: I/me = user, you/your = agent.                                |
| `intent-language.md`              | Must / should / may — normative weight and agent discretion.                      |
| `self-contained-files.md`         | Files must be intelligible cold, with no ambient context.                         |
| `document-metadata.md`            | Required frontmatter fields for all documents.                                    |
| `file-naming.md`                  | Naming conventions for repo artifacts and output documents.                       |
| `unknown-values.md`               | Sentinel values for unresolvable or inapplicable fields: `unknown` / `n/a`.       |

### Templates

| File                       | Purpose                                                               |
| -------------------------- | --------------------------------------------------------------------- |
| `templates/frontmatter.md` | Base frontmatter block. Copy and complete per `document-metadata.md`. |

### Skills

None yet. This is the next area of work.

---

## What to build next

### Immediate: port `write-a-skill`

The first skill to land must be `write-a-skill`. It is the tool used to write all
subsequent skills. Port it from:

```
~/burnish-projects/station-ai/skills/write-a-skill/SKILL.md
```

Port it by hand — we do not yet have the skill to use for writing it. Once it is here,
use it for everything that follows. The station-ai copy becomes a reference to this one.

The existing content is reproduced in the original `HANDOVER.md` if needed, but reading
the source file directly is preferable.

Key things to check on port: strip any Station AI concepts, ensure frontmatter meets
`standards/document-metadata.md`, confirm the description is trigger conditions only.

### Skills to write (in no particular order after `write-a-skill`)

- `write-up` — capture a completed session into a structured document
- `grill-me` — interrogate a plan or design until it is robust
- `grill-you` — user interrogates the agent about its own nature or tendencies
- `introspect` — agent conducts structured self-reflection on a topic
- `ubiquitous-language` — extract a DDD-style ubiquitous language glossary
- `caveman` — compressed communication mode; minimal tokens

### Templates

Do not design ahead of need. Templates will emerge from building the skills. The first
will likely be an output document template and a session write-up template.

---

## What is open

- Repo name — "repertoire" is confirmed working; may be formalised later.
- Sub-namespacing (`skills/writing/`, `skills/productivity/`) — not needed yet; revisit
  when the flat list becomes unwieldy.
- Whether a `file-naming` skill and `frontmatter` skill are needed, or whether the
  standards and templates are sufficient on their own.

---

## Practical notes

- Owner: Adam
- Environment: WSL2 (Fedora), pi with Claude via GitHub Copilot
- Tone: direct, no fluff, technically precise
- Do not import Station AI concepts under any circumstances.
