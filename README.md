# Repertoire

Rational firmware for agent projects. Repertoire stands up, inside any project, a
philosophical stance and an authoring toolkit — standards that govern, skills that
act, templates that show form — so the project's agent is well-positioned and
well-tooled for creating artefacts meant for agent consumption. A standalone base
layer — no dependencies, no framework assumptions. Other projects build on it; it
builds on nothing.

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

From the project root:

```bash
npx -y github:burnish-studio/repertoire init
```

This vendors the standards, templates, and a chosen set of skills into `.agents/`,
injects the stance block into `AGENTS.md`, wires Claude Code (a `CLAUDE.md` pointer
plus `.claude/skills` symlinks), and records everything it owns in
`.agents/repertoire.lock`. `rep update` refreshes against the latest version and
prints a diff of the stance block; `rep remove --all` reverses the install
byte-clean, leaving anything the project authored in place.

The full walkthrough — day-to-day commands, the vendored/authored ownership rule,
and the authoring loop — is in [`docs/consumer-guide.md`](docs/consumer-guide.md).

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

Working on the repertoire itself — adding standards or skills, changing `rep`,
the session workflow — is covered in
[`docs/maintainer-guide.md`](docs/maintainer-guide.md).
