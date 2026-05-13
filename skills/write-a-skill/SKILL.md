---
type: skill
title: Write a Skill
name: write-a-skill
description: Use when creating, writing, or updating an agent skill. Covers what a skill is, when to create one, structure, frontmatter, content principles, and what done looks like.
created: 2026-05-13
updated: 2026-05-13
status: current
model: sonnet-4-6
---

# Write a Skill

_Perspective: [standards/perspective/STANDARD.md](../../standards/perspective/STANDARD.md)_

A skill is a briefing for an intelligence. It defines what done looks like and trusts
the agent to reach it. A skill is not a procedure, a checklist, or a set of steps.

The prohibition is specific: do not enumerate generic procedure an agent can derive.
Domain-specific insight that happens to be structured as steps is legitimate — the test
is whether the content encodes something the agent would not know without being told.

---

## When not to create a skill

**If the constraint is mechanically enforceable, automate it. Do not write a skill.**

Documentation for something deterministically enforceable trains the agent to treat
hard constraints as soft guidance. Skills are for judgement calls — non-obvious decisions,
domain-specific traps, and context the agent cannot derive from general knowledge.

Create a skill when:

- The technique was not intuitively obvious
- The failure mode is non-obvious without domain knowledge
- The pattern applies across sessions and contexts

Do not create a skill for:

- One-off solutions or project-specific conventions (those belong in CLAUDE.md / AGENTS.md)
- Standard practices already in the agent's general knowledge
- Anything enforceable by a linter, schema, or script

---

## Skill types

Skill type governs what patterns to apply. Identify the type before writing.

| Type                     | Description                                           | Primary design need                                                                |
| ------------------------ | ----------------------------------------------------- | ---------------------------------------------------------------------------------- |
| **Technique**            | Concrete method with steps that encode domain insight | Edge case modelling; gotchas; one strong example                                   |
| **Pattern**              | Mental model for a class of problems                  | Recognition guidance; counter-examples                                             |
| **Reference**            | API docs, syntax, tool documentation                  | Table of contents; retrieval-oriented structure                                    |
| **Discipline-enforcing** | Mandatory practice that must hold under pressure      | Rationalization tables; red flags lists — see `references/discipline-enforcing.md` |

Most skills are techniques. Discipline-enforcing skills need substantially more
anti-rationalisation scaffolding than the others.

---

## Frontmatter

```yaml
---
type: skill
title: Skill Title
name: skill-name
description: Use when [specific trigger conditions and user intent]. [One-line capability summary.]
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: draft
model: sonnet-4-6
---
```

### The description field

The description is the only content loaded at startup. It is the sole basis on which the
agent decides whether to activate this skill. The full SKILL.md loads only if the description
triggers it. Get this wrong and the skill is invisible.

**Frame as a trigger, in imperative form:**

> Use this skill when the user asks to analyse a dataset, compare datasets, or produce a summary from tabular data.

Not a label. Not a summary of the skill's process. A trigger condition.

**Never summarise the workflow in the description.** This is a tested failure mode: if the
description contains a workflow summary, the agent treats it as an executable summary and
skips the skill body. The skill appears to activate while being bypassed.

```
# ✗ Summarises workflow — agent will follow this and skip the body
description: Use when executing plans — dispatches subagent per task with code review between tasks.

# ✓ Trigger conditions only — agent reads the body to learn the process
description: Use when executing implementation plans with independent tasks.
```

**Write in third person.** The description is injected into the system prompt as context
about the skill. First person ("I can help you...") breaks the framing.

**Include specific keywords** the user would naturally use: error messages, symptom terms,
tool names, domain vocabulary. The agent matches descriptions against what the user said.

---

## Content principles

These govern every sentence in the skill body. Apply them as editing criteria.

### Behavioural specificity

Every sentence must change a specific, observable behaviour. If a sentence could not
fail — if no output would violate it — remove it.

```
# ✗ Cannot fail — "comprehensive" rationalises anything
Provide comprehensive and thoughtful assistance.

# ✓ Can fail — either the output opens with filler or it does not
Never open a response with "Great question!", "I'd be happy to help!", or "Absolutely!".
```

Short beats long. Sharp beats vague. A sharp rule has an edge: it cuts off some outputs
and permits others. Sharpness is a structural property, not a stylistic one.

### The competent-agent test

Only include what the agent would not know without being told. General knowledge, common
practices, and well-documented patterns are already present. Skills add domain-specific
context, non-obvious constraints, and project-specific facts.

```
# ✗ The agent already knows what PDFs are and that pdfplumber exists
PDF (Portable Document Format) files are a common file format. Use pdfplumber
because it handles most cases well.

# ✓ Adds what the agent lacks — the fallback for a specific case
Use pdfplumber for text extraction. For scanned documents, fall back to
pdf2image with pytesseract.
```

### Match specificity to fragility

Not every section needs the same prescriptiveness. Where multiple approaches are valid
and the task tolerates variation, give the agent freedom and explain the intent rather
than specifying the method. Where the operation is fragile, consistency is critical, or
a specific sequence must be followed exactly, be prescriptive.

Calibrate each section independently. Most skills have both kinds of content.

### Defaults, not menus

When multiple tools or approaches could work, name a default and mention alternatives
briefly. Do not present options as equal choices. The agent must decide; a menu does not
help it decide.

### Effort prioritisation

Where one part of a skill matters more than others, say so explicitly. Without this,
all guidance receives equal weight. Name the part that carries the most consequence and
instruct the agent to spend disproportionate effort there.

---

## Content patterns

### The competent-agent test in practice — before/after examples

For any rule where the wrong version is non-obvious, show both. Abstract rules without
examples require the agent to infer the failure mode. Examples make the failure
visible.

One excellent example beats many mediocre ones. One strong example in the most relevant
context is better than the same example in five languages — the agent can port it; the
skill cannot compensate for five weak examples by having five of them.

### Gotchas

The highest-value content in many skills. Concrete corrections to mistakes the agent
will make without being told — specific environment facts that defy reasonable
assumptions.

```markdown
## Gotchas

- The `users` table uses soft deletes. Every query must include
  `WHERE deleted_at IS NULL` or results include deactivated accounts.
- The field is `user_id` in the database, `uid` in the auth service,
  and `accountId` in the billing API. All three refer to the same value.
```

Not general cautions. Specific traps with specific consequences.

### Output format

When the skill produces a specific artefact with a defined shape, specify the shape.
Do not leave the agent to infer what done looks like from first principles.

If the output is open-ended, describe its properties instead (what makes it correct,
what makes it wrong). Both cases require an exit criterion the agent can verify.

### Named anti-patterns

Name failure modes, label them, and explain the mechanism. A named anti-pattern is
memorable and referenceable. A prohibition without a causal explanation is just a rule;
the agent may follow its letter while violating its intent.

---

## File structure

```
skill-name/
  SKILL.md                          ← always required; must stand alone
  references/
    [topic].md                      ← supplementary detail; loaded on demand
  scripts/
    [utility].sh / [utility].py     ← deterministic utilities
```

**Reference files** are for content the agent rarely needs for the primary task — heavy
API reference, format specifications, or patterns that apply only to a subtype of use.
You must specify in SKILL.md exactly when to load each reference file. "See
`references/`" is not sufficient — the agent will not know when to open it.

**Nesting depth:** all reference files must link directly from SKILL.md. If SKILL.md
references `advanced.md` and `advanced.md` references `details.md`, the agent may read
the intermediate file partially and miss the actual content.

**Table of contents:** reference files longer than 100 lines should have a table of
contents at the top so the agent can orient even when reading partially.

**Scripts** are appropriate when the operation is deterministic and would otherwise be
regenerated identically each session. Generated code varies; scripts are stable.

**Splitting:** split only when secondary content is reference material the agent rarely
needs for the primary task. A skill that cannot stand without its reference file is not
a skill — it is a fragment. Merge it.

---

## Iteration

Skills are not written once. They fail — agent behaviour diverges from intended
behaviour — and the correct response is to update the skill. Treat each failure as
information: what did the agent do instead, and what does the skill need to say to
prevent it?

The minimum viable update process: observe the divergence, identify the missing or
ambiguous guidance, add it, and re-deploy. The skill is stable when failures stop.

For discipline-enforcing skills, this process involves more structured pressure testing.
See `references/discipline-enforcing.md`.

---

## What done looks like

A SKILL.md that can be dropped into any deployment, loaded cold with no surrounding
conversation, and used without changes. Every sentence in it either changes a specific,
observable behaviour or it is not there.

---

## What not to do

- **You must not enumerate generic procedure.** If the steps are derivable from general
  knowledge, you have written a manual. Rewrite at the level of intent. Exception:
  domain-specific steps that encode non-obvious insight are legitimate.
- **You must not summarise the workflow in the description.** This causes the agent to
  bypass the skill body. Trigger conditions only.
- **You must not write a bare trigger as the description.** Include capability context
  alongside the trigger so the agent can choose correctly among many skills.
- **You must not write for the current session.** The skill loads in a future session
  with no ambient context.
- **You must not break self-containment by splitting.** If the primary file only works
  with the reference file, merge them.
- **You must not include content that does not change observable behaviour.** Apply the
  behavioural specificity test to every sentence. Vague aspirational rules ("be helpful",
  "be thorough") are dead weight.
- **You must not present a menu of equal options.** Name a default.
