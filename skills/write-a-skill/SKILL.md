---
type: skill
title: Write a Skill
name: write-a-skill
description: Use when asked to create, write, or build an agent skill. Covers skill structure, frontmatter, file layout, and what done looks like.
created: 2026-05-13
updated: 2026-05-13
status: current
model: sonnet-4-6
---

# Write a Skill

_Perspective: [standards/perspective/STANDARD.md](../../standards/perspective/STANDARD.md)_

A skill is a briefing for an intelligence. It defines what done looks like and trusts
the agent to reach it. It is not a procedure, a checklist, or a set of steps. If you
are enumerating how, you have written a manual — you must rewrite at the level of intent.

---

## Frontmatter

```yaml
---
type: skill
title: Skill Title
name: skill-name
description: [what the skill does and when to use it]
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: draft
model: sonnet-4-6
---
```

### Description

The description is loaded alongside every other installed skill's description. It is
the sole basis on which the agent decides whether to load this skill. It should
describe both what the skill does and when to use it, with enough specific keywords
that the agent can reliably identify when it applies.

**Right:** `Extracts text from PDFs, fills forms, and merges documents. Use when the user asks about PDFs or needs document extraction.`

**Wrong:** `Use when the user asks about PDFs.`

The wrong form is a bare trigger with no capability context. An agent comparing many
skill descriptions needs enough signal to choose correctly — a trigger alone does not
provide it.

---

## Body structure

- **Purpose** — one sentence; what this skill produces
- **What done looks like** — concrete and observable; the exit criterion the agent can verify without knowing the process
- **How to approach it** — orientation and intent; what matters; what to hold in mind; not steps
- **What not to do** — hard limits and failure modes

---

## File structure

```
skill-name/
  SKILL.md          ← the briefing; always required
  REFERENCE.md      ← supplementary detail; loaded on demand, not by default
  scripts/          ← deterministic utilities
```

**Scripts:** use when the operation is deterministic and would otherwise be regenerated
identically each session. Generated code varies; scripts are stable.

**Splitting files:** appropriate when secondary content is reference material the agent
rarely needs for the primary task. You must not split if splitting means the primary skill no
longer stands alone — a skill that requires its reference file to make sense is not a
skill, it is a fragment.

---

## What done looks like

A SKILL.md that could be dropped into any deployment and loaded cold, with no surrounding
conversation, and used without changes. If it requires ambient context to make sense, it
is not done.

---

## What not to do

- **You must not enumerate procedure.** Numbered steps mean you've written a manual. You must rewrite at the level of intent.
- **You must not write a bare trigger as the description.** Include what the skill does as well as when to use it.
- **You must not write for the current session.** The skill will be loaded in a future session with no ambient context.
- **You must not break self-containment by splitting.** If the primary file only works with the reference file, merge them.
