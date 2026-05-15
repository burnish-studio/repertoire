---
type: context
title: Repertoire
created: 2026-05-13
updated: 2026-05-14
status: current
model: sonnet-4-6
---

# Repertoire

_Perspective: [standards/perspective/STANDARD.md](standards/perspective/STANDARD.md)_

A collection of general-purpose agent skills, standards, and templates. A standalone
base layer for intelligent agent work — no dependencies, no framework assumptions.
Other projects build on it; it builds on nothing.

---

## What is in here

Three artifact types:

**Skills** are briefings for agents. Each describes a repeatable action with a
concrete outcome, written as intent and context rather than step-by-step procedure.
An agent reads a skill and knows what to do and why.

**Standards** declare what ought to be — normative positions, conventions, and
constraints that govern how things are done. A standard does not do anything; it
governs.

**Templates** show correct form for a type of document. Copyable starting points.

The test for where something belongs:

- Does this describe a repeatable action with an output? → skill
- Does this govern how things should be done generally? → standard
- Does this show correct form for something? → template

---

## Structure

```
skills/       ← agent briefings; one directory per skill, each with SKILL.md
standards/    ← normative positions; one directory per standard, each with STANDARD.md
templates/    ← copyable forms; one directory per template, each with TEMPLATE.md
_work/        ← research notes and working documents; not deployed
```

---

## Two ways to use this

**Skills only (minimal).** Add `skills/` to your existing harness configuration.
Nothing else changes. For pi: one line in `~/.pi/settings.json`. For Claude Code:
symlink into `~/.claude/skills/`. No new conventions, no new tooling.

**Skills and delivery system (full).** Use the `~/.agent/` convention and the `pid`
launcher. A harness-agnostic home for all agent infrastructure — prompts, skills,
and managed repos. Works with pi today; adapters for other harnesses follow the same
pattern.

For either path, the fastest start is:

```bash
curl -fsSL https://raw.githubusercontent.com/burnish-studio/repertoire/main/install.sh | bash
```

Or invoke the setup skill from inside any agent session:

> Read `skills/setup-repertoire/SKILL.md` from the cloned repo and follow it.

See [`skills/setup-repertoire/SKILL.md`](skills/setup-repertoire/SKILL.md) for the
full install guide covering both paths, manual steps, and verification.

---

## Self-applying

This repertoire applies its own standards. Every file in the repo must conform to the
standards the repo asserts. To check conformance, use `skills/audit/SKILL.md`.

---

## Contributing

Read `standards/programming-paradigm/STANDARD.md` first. Then read
`skills/write-a-skill/SKILL.md` before adding or modifying any skill. The
contributing principle: specify intent, not procedure.
