---
type: skill
title: Write a Standard
name: write-a-standard
description: Write a new normative standard for the repertoire. Use when asked to create, write, or draft a standard, or when a norm discussed in a session needs to be placed into the repertoire as a standard.
created: 2026-05-13
updated: 2026-05-13
status: current
model: sonnet-4-6
---

# Write a Standard

_Perspective: [standards/perspective/STANDARD.md](../../standards/perspective/STANDARD.md)_

A standard is a normative statement about how things ought to be. It is not a skill
(which says what to do) and not a template (which shows correct form). If you are
telling the agent what to do step by step, you have written a skill. If you are
showing the correct form of an artefact, you have written a template. Rewrite accordingly.

---

## Structure

Every standard has two parts, in this order:

**Operative norm** — the binding statement. One to three sentences. Tight. Must stand
alone: a reader with only the norm and no thesis must still know exactly what is required.
Written to be injectable — compact enough to be present in a context window without
significant token cost.

**Thesis** — the rationale and elaboration. Explains why the norm is correct, what it
means at the edges, and what failure looks like. Must provide enough reasoning that a
competent reader can understand, apply, and — critically — dispute the norm. Does not
restate the norm in different words. Adds to it.

Both parts are required. A norm without a thesis cannot be challenged or improved. A
thesis without a clear operative norm cannot be acted on.

---

## Frontmatter

```yaml
---
type: standard
title: Standard Title
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: draft
model: sonnet-4-6
---
```

Standards do not carry `name` or `description` fields. Those are skill-specific.

---

## Other requirements

Normative statements must use intent language per
`standards/intent-language/STANDARD.md`. This applies throughout — in both the norm
and the thesis.

Any standard whose body uses `I`, `me`, `you`, or `your` must reference
`standards/perspective/STANDARD.md` immediately under the h1.

The finished standard must pass the self-consistency check per
`standards/self-consistency/STANDARD.md`.

---

## What done looks like

A STANDARD.md whose operative norm can be read in isolation and still be fully
actionable. A thesis that provides the reasoning a reader needs to apply the norm
correctly to cases the author did not anticipate, and to argue against the norm if
they believe it is wrong. The file conforms to all applicable standards and reads
cold — no surrounding context required.

---

## What not to do

- **You must not write a skill.** If the standard tells the agent what to do rather
  than what ought to be, rewrite it.
- **You must not omit the thesis.** The norm alone is not a complete standard.
  Without rationale, it cannot be understood, applied to edge cases, or corrected.
- **You must not omit the operative norm.** The thesis is elaboration of something.
  That something must be stated first, precisely.
- **You must not restate the norm in the thesis.** The thesis adds reasoning, not
  repetition.
- **You must not over-specify.** Standards govern what ought to be. How that is
  achieved is the agent's domain.
