---
type: context
title: Repertoire
created: 2026-05-13
updated: 2026-05-13
status: current
model: sonnet-4-6
---

# Repertoire

_Perspective: [standards/perspective/STANDARD.md](standards/perspective/STANDARD.md)_

A collection of general-purpose agent skills, standards, and templates. A base layer
for intelligent agent work — it builds on nothing and has no dependencies. Other
projects build on it.

The philosophical foundation is the agentic programming paradigm. Read
`standards/agentic-programming-paradigm/STANDARD.md` before contributing anything.

---

## Artifact types

Three artifact types, each with a distinct role:

**Standards** declare what ought to be. They are normative positions — values,
conventions, and constraints that govern how things are done across the whole
repertoire. A standard does not do anything; it governs.

**Skills** are briefings for agents. Each describes a repeatable action with a
concrete outcome. Skills are written in the agentic paradigm: intent and outcome,
not procedure. A skill does something and produces something.

**Templates** show what something looks like in its correct form. They are copyable
starting points. A template is descriptive, not normative.

The test for where something belongs:

- Does this govern how things should be done generally? → standard
- Does this describe a repeatable action with an output? → skill
- Does this show correct form for something? → template

---

## Structure

```
standards/    ← normative positions
skills/       ← agent briefings, one directory per skill
templates/    ← copyable forms
_work/        ← research, notes, and working documents; not deployed
```

---

## Self-applying

This repertoire is self-applying. Every standard asserted here must be followed by
every file in the repo. The repertoire is both the rule set and a member of the rule
set's domain — it must pass its own tests.

See `standards/self-consistency/STANDARD.md`. To verify and restore coherence, use
`skills/audit/SKILL.md`.
