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

Open any agent session with file system and shell access and paste:

```
Set up repertoire on this machine:
https://raw.githubusercontent.com/burnish-studio/repertoire/master/skills/setup-repertoire/SKILL.md
```

The agent fetches the skill, checks capabilities, assesses the environment, and walks
through setup interactively. Works with pi, Claude Code, Cursor, and any agent that
can read files and run shell commands. Web-only agents cannot complete this
installation — the skill will say so immediately.

**Requirements:** git, an agent with file system access and shell execution.

### Manual install (no agent)

If you would rather run it yourself, clone the repo and run the installer. It creates
the `~/.agent/` structure, clones into it, symlinks bootstrap/skills/pid, and writes
an install manifest:

```
git clone https://github.com/burnish-studio/repertoire ~/.agent/repos/repertoire
bash ~/.agent/repos/repertoire/install.sh
```

The installer is idempotent — safe to re-run to update. Harness wiring beyond pid is
harness-specific; the agent-driven path above handles it for you.

### Uninstall

Ask any capable agent to run the `teardown-repertoire` skill. It reads
`~/.agent/install-manifest.md` and reverses every recorded change interactively,
removing only what the install created.

---

## Structure

```
skills/       ← agent briefings; one directory per skill, each with SKILL.md
standards/    ← normative positions; one directory per standard, each with STANDARD.md
templates/    ← copyable forms; one directory per template, each with TEMPLATE.md
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
