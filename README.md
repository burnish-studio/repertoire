# Repertoire

A collection of skills, standards, and templates for intelligent agent work. A
standalone base layer — no dependencies, no framework assumptions. Other projects
build on it; it builds on nothing.

---

## What is in here

**Skills** are briefings for agents. Each describes a repeatable action with a
concrete outcome, written as intent rather than procedure. An agent reads a skill and
knows what to do and why — without being told how step by step.

**Standards** declare what ought to be. Normative positions and conventions that
govern how things are done. A standard does not act; it governs.

**Templates** show correct form for a document type. Copyable starting points.

The design principle running through all of it: when intelligence is in the execution
layer, specify intent and outcome — not procedure. Over-specifying is the same error
as micromanaging a capable person. Skills describe what done looks like and trust the
agent to reach it.

---

## Install

Repertoire is **local-first**: it is called into each project explicitly, like a
dependency — not installed globally and auto-injected everywhere. Starting empty and
including deliberately is the point: the context window is the most expensive resource
in agentic engineering.

The delivery tool (`rep`) is in development. It will scaffold repertoire into a
project (`rep init`), keep it updated against a pinned version (`rep update`), and
remove it cleanly (`rep remove`). Until it ships, the content is usable directly:
clone the repo and copy the skills and standards you want into your project's agent
configuration.

The previous global installation model (a `~/.agent/` convention, the `pid` launcher,
and agent-driven setup/teardown flows) is superseded — see `.plan/adr/0005` — and
preserved on the [`global-first`](https://github.com/burnish-studio/repertoire/tree/global-first)
branch.

---

## Structure

```
skills/       ← agent briefings; one directory per skill, each with SKILL.md
standards/    ← normative positions; one directory per standard, each with STANDARD.md
templates/    ← copyable forms; one directory per template, each with TEMPLATE.md
base/         ← the bootstrap injected into project context
.plan/        ← architecture decision records and design references
_work/        ← research notes and session documents
```

---

## Self-applying

This repertoire applies its own standards. Every file in the repo conforms to the
standards it asserts. To check conformance: `skills/audit/SKILL.md`.

---

## Contributing

Read `standards/programming-paradigm/STANDARD.md` before adding anything. Then
`skills/write-a-skill/SKILL.md` before writing a skill. The short version: describe
what done looks like, not how to get there.
