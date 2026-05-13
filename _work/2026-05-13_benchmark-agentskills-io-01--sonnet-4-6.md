---
type: context
title: Benchmark — agentskills.io
created: 2026-05-13
updated: 2026-05-13
status: current
model: sonnet-4-6
---

# Benchmark — agentskills.io

Source: https://agentskills.io  
Pages reviewed: Specification, Best practices for skill creators, Optimising skill descriptions

---

## What this source adds

### The description field is a triggering mechanism, not a label

At startup, the agent loads only `name` and `description` for all available skills.
The full `SKILL.md` loads only when the description causes the agent to activate the
skill. The description carries the entire burden of triggering.

Two practical consequences. First, it should be framed as an instruction to the agent,
not a summary of the skill: "Use this skill when..." rather than "This skill does...".
Second, it should target user intent, not implementation — the agent matches against
what the user asked for, not the skill's internal mechanics. A description that
accurately describes the skill but doesn't match how users phrase their requests will
not trigger.

Our current descriptions are well-formed but mostly framed as labels ("Write a new
normative standard...") rather than as activation instructions with explicit trigger
conditions.

### Progressive disclosure with explicit token limits

Skills load in three stages: metadata only at startup (~100 tokens), full SKILL.md
when activated (<5000 tokens / 500 lines recommended), and reference/asset files only
when explicitly called for. The limit on SKILL.md is practical guidance, not a hard
cap — but it formalises what the structure is trying to do.

The important implication for reference files: the agent must be told _when_ to load
them, not just that they exist. "Read `references/edge-cases.md` if X condition
applies" is useful. "See `references/` for more" is not — the agent may not recognise
when to load it.

### Add what the agent lacks — omit what it knows

Agentskills.io states this as the central content principle: focus on what the agent
wouldn't know without your skill — project-specific conventions, domain-specific
procedures, non-obvious edge cases, specific tools or APIs. Do not explain what the
agent already knows. Their before/after example:

```
<!-- Too verbose — the agent already knows what PDFs are -->
PDF (Portable Document Format) files are a common file format...
Use pdfplumber because it handles most cases well.

<!-- Better -->
Use pdfplumber for text extraction. For scanned documents,
fall back to pdf2image with pytesseract.
```

This is the competent-agent test stated as a content principle. It confirms the
heuristic already in our paradigm standard. It belongs in `write-a-skill` as a
named principle with a before/after example.

### Gotchas sections

Named explicitly as the highest-value content in many skills: concrete corrections to
mistakes the agent will make without being told. Not general advice — specific
environment facts that defy reasonable assumptions. Their example:

```
## Gotchas

- The `users` table uses soft deletes. Queries must include
  `WHERE deleted_at IS NULL` or results will include deactivated accounts.
- The user ID is `user_id` in the database, `uid` in the auth service,
  and `accountId` in the billing API. All three refer to the same value.
```

We don't have this pattern named in `write-a-skill`. It is the most direct application
of "add what the agent lacks" — it is exactly the content a competent agent would not
have without being told.

### Match specificity to fragility

Not every part of a skill needs the same prescriptiveness. Where multiple approaches
are valid and the task tolerates variation, give the agent freedom and explain _why_
rather than specifying _what_. Where operations are fragile, consistency matters, or
a specific sequence must be followed, be prescriptive.

Most skills have a mix. The guidance is to calibrate each part independently — not to
pick a single stance for the whole skill.

### Defaults, not menus

When multiple tools or approaches could work, pick a default and mention alternatives
briefly. Do not present options as equal choices. The agent must decide; a menu does
not help it decide.

### Procedures over declarations

Skills should teach the agent how to approach a class of problems, not what to produce
for a specific instance. A reusable method generalises; a specific answer to a specific
case does not. This does not prevent specific details — output format templates,
tool-specific instructions, "never output PII" — as long as the _approach_ generalises.

---

## What does not translate

### The eval/testing methodology

Agentskills.io has detailed guidance on trigger evals (20 queries, train/validation
splits, trigger rate thresholds) and output quality evals (test cases, grading,
iteration). This is production infrastructure for skills deployed at scale. It does not
apply to our use case — we are not running automated evals against a skills registry.
The underlying principle (test against real tasks, iterate on failures) is sound and
already in the paradigm standard.

### `allowed-tools` and `compatibility` fields

Experimental or environment-specific fields not relevant to our current setup.

---

## Implications for `write-a-skill` update

| Finding                                     | Action                                                         |
| ------------------------------------------- | -------------------------------------------------------------- |
| Description is a trigger, not a label       | Add trigger-framing guidance; imperative phrasing; user intent |
| Progressive disclosure with explicit limits | Note the <500 line / 5000 token recommendation for SKILL.md    |
| "Add what the agent lacks" principle        | Name it explicitly with before/after example                   |
| Gotchas sections                            | Add as a named pattern with example                            |
| Match specificity to fragility              | Add as calibration guidance                                    |
| Defaults not menus                          | Add as a named principle                                       |
| Procedures over declarations                | Already present in paradigm standard; reference from skill     |
| Reference file loading must specify when    | Add explicit guidance alongside the reference files pattern    |

---

## Quality markers — combined view

| Marker                                         | Matt Pocock | agentskills.io |   Our skills   |
| ---------------------------------------------- | :---------: | :------------: | :------------: |
| Named anti-patterns with causal reason         |      ✓      |       ✗        |       ✗        |
| Explicit effort prioritisation                 |      ✓      |       ✗        |       ✗        |
| Concrete output format when applicable         |      ✓      |       ✓        |    partial     |
| Before/after examples                          |      ✓      |       ✓        |       ✗        |
| Companion reference files                      |      ✓      |       ✓        | described only |
| Edge case / exception modelling                |      ✓      |       ✓        |       ✗        |
| Description as trigger (imperative, intent)    |      ✓      |       ✓        |    partial     |
| Gotchas sections                               |      ✗      |       ✓        |       ✗        |
| Match specificity to fragility                 |      ✗      |       ✓        |       ✗        |
| Defaults not menus                             |      ✗      |       ✓        |       ✗        |
| Progressive disclosure with explicit limits    |      ✗      |       ✓        |    partial     |
| Sharp description field (capability + trigger) |      ✓      |       ✓        |       ✓        |
| Self-containment                               |      ✓      |       ✓        |       ✓        |
| Standards layer                                |      ✗      |       ✗        |       ✓        |
| Consistent normative language                  |      ✗      |       ✗        |       ✓        |
