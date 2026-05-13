---
type: context
title: Benchmark — Matt Pocock Skills
created: 2026-05-13
updated: 2026-05-13
status: current
model: sonnet-4-6
---

# Benchmark — Matt Pocock Skills

Source: https://github.com/mattpocock/skills/  
Skills reviewed: `grill-me`, `grill-with-docs`, `write-a-skill`, `caveman`, `tdd`,
`diagnose`, `handoff`, deprecated `ubiquitous-language`

---

## What these skills do well

### Named anti-patterns with causal explanation

The best skills don't just prohibit — they name the failure mode, label it, and
explain the mechanism. `tdd` names "horizontal slicing", describes exactly what it
produces ("tests written in bulk test _imagined_ behaviour, not _actual_ behaviour"),
and contrasts it with the correct vertical approach using a simple diagram. The label
makes the anti-pattern memorable and referenceable.

Our current skills state constraints without causal reasoning. "You must not enumerate
procedure" is a rule; it does not explain what goes wrong when the rule is violated.
Where the failure mechanism is non-obvious, it should be stated.

### Explicit prioritisation of effort

`diagnose` opens Phase 1 with: _"This is the skill. Everything else is mechanical."_
It follows with: _"Spend disproportionate effort here. Be aggressive. Be creative.
Refuse to give up."_ This is not decoration — it directs where the agent's attention
and effort should concentrate. Without this, all sections receive equal weight by
default.

Our skills treat all guidance as equivalent. Where some parts of a skill matter more
than others, that should be said explicitly.

### Concrete output format when a defined output exists

The deprecated `ubiquitous-language` specifies exact table structure, grouping rules,
a required example dialogue section, flagged ambiguities format, and re-run behaviour.
When a skill produces a specific artefact, Matt specifies the form precisely. The agent
is not left to infer what "done" looks like from first principles.

Our skills describe what done looks like in terms of properties ("a file that reads
cold"), not form. That is appropriate when the output is open-ended. When the output
has a defined shape, the shape should be specified.

### Before/after examples

`caveman` shows the contrast directly:

> Not: "Sure! I'd be happy to help you with that..."  
> Yes: "Bug in auth middleware. Token expiry check use `<` not `<=`. Fix:"

Abstract rules become immediately concrete. No interpretation required.

Our current skills have no examples. For any rule where the wrong version is
non-obvious, an example is worth more than additional prose.

### Companion reference files used to preserve main-file legibility

`tdd` offloads detailed guidance into `tests.md`, `mocking.md`, `deep-modules.md`,
`refactoring.md`. The main SKILL.md stays navigable. Reference files are loaded on
demand, not by default.

`grill-with-docs` does the same with `CONTEXT-FORMAT.md` and `ADR-FORMAT.md` — format
specifications that would bloat the main file are separated out.

Our `write-a-skill` describes this pattern but no skill in the repertoire yet uses it.

### Edge case modelling

`caveman` defines an "auto-clarity exception" — specific conditions under which the
compressed mode should be dropped temporarily (security warnings, irreversible actions,
multi-step sequences where fragment order risks misread). These are cases a general
intelligence would not reliably handle without being told.

Our skills model the common path well but do not model edge cases or exceptions.

---

## What does not translate

### Procedural structure

Matt's complex skills (`tdd`, `diagnose`, `ubiquitous-language`) are heavily
procedural: numbered phases, ordered steps, checklists. This is correct for his
approach and context. It does not follow that we should adopt it.

The distinction that matters is not form but content: the test is whether the
guidance encodes non-obvious domain insight the agent does not already possess, or
whether it is generic procedure a competent agent would follow anyway. Matt's Phase 1
in `diagnose` passes that test — the ordered list of 10 ways to construct a feedback
loop is crystallised experience. Generic "reproduce the bug, form a hypothesis, fix it"
procedure would not.

Our paradigm-2 stance is correct. The refinement needed is precision about what it
prohibits: generic procedure the agent can derive, not domain-specific insight that
happens to be structured as steps.

### Absence of standards

Matt's skills embed norms inline. There is no equivalent of our standards layer — no
separate document governing intent language, perspective, self-containment, or
consistency. Each skill carries its own conventions.

This is a different architectural choice, not a quality deficiency to emulate. Our
standards layer is a deliberate investment; it pays off at scale and across
contributors. It is not something to abandon.

---

## Implications for the skills backlog

### `grill-me`

The paradigmatic simple skill. Matt's version is four lines of content and is effective.
Ours should be similarly terse. The value is in the framing and trigger conditions, not
the volume. Risk: over-engineering it in the name of completeness.

### `ubiquitous-language`

Matt's deprecated version is the most instructive single artefact in the repo. It
specifies output format, rules (be opinionated, flag conflicts), example dialogue, and
re-run behaviour. Our version will need this level of specificity — the output is
defined, the rules are non-obvious, and the example dialogue pattern is genuinely
valuable. This is the right benchmark for our implementation.

### `caveman`

Matt's version has specific persistence rules and an auto-clarity exception that we
should replicate. The before/after examples are the highest-value addition we are
missing.

### General

For every skill with a defined output shape, specify the shape. For every rule where
the wrong version is non-obvious, add an example. For every section where effort
should concentrate, say so explicitly. For every anti-pattern, name it and explain
why it fails.

---

## Quality markers — summary

| Marker                                         | In Matt's skills | In our skills  |
| ---------------------------------------------- | :--------------: | :------------: |
| Named anti-patterns with causal reason         |        ✓         |       ✗        |
| Explicit effort prioritisation                 |        ✓         |       ✗        |
| Concrete output format when applicable         |        ✓         |    partial     |
| Before/after examples                          |        ✓         |       ✗        |
| Companion reference files                      |        ✓         | described only |
| Edge case / exception modelling                |        ✓         |       ✗        |
| Sharp description field (capability + trigger) |        ✓         |       ✓        |
| Self-containment                               |        ✓         |       ✓        |
| Standards layer                                |        ✗         |       ✓        |
| Consistent normative language                  |        ✗         |       ✓        |
