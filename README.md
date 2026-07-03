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

The agent fetches the skill, checks capabilities, detects your OS and every agent
harness on the machine, and wires each one in a single interactive pass — recording a
reversible manifest as it goes. It has explicit support for **pi** (via the `pid`
launcher) and **Claude Code** (via `~/.claude/` wiring), and a generic path for any
other harness that loads global context and discovers skills. Web-only agents cannot
complete this installation — the skill will say so immediately.

**Requirements:** git, an agent with file system access and shell execution.

### Manual install (no agent)

The Core installs the same everywhere; only the per-harness wiring differs. If you would
rather run it yourself, clone the repo and run the installer. It does the harness-agnostic
**Core** — the `~/.agent/` storage layout, the clone, the core symlinks, and the core rows
of the install manifest — then prints the wiring end-state for your harness(es):

```
git clone https://github.com/burnish-studio/repertoire ~/.agent/repos/repertoire
bash ~/.agent/repos/repertoire/install.sh
```

The installer is idempotent — safe to re-run to update. It deliberately does **no** harness
wiring (with no agent to detect and record it, wiring is yours to apply from the printed
end-state). The agent-driven path above detects and wires every harness for you.

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
