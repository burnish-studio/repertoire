---
type: research-doc
title: Bootstrap and Install Design — Paradigm 2 Approach
project: repertoire
topic: bootstrap-design
created: 2026-05-15
updated: 2026-05-15
model: claude-sonnet-4-6
skill: write-up
session: 01
exchanges: 14
status: draft
---

# Bootstrap and Install Design — Paradigm 2 Approach

_Perspective: [standards/perspective/STANDARD.md](../standards/perspective/STANDARD.md)_

## What this session was

A design session examining how repertoire should be installed and wired into a user's
agent harness. Started from the intention to test the existing install path on a Fedora
laptop. Ended with a substantially revised design that leans into paradigm 2: instead
of pre-packaging adapters for every harness, the agent handles setup dynamically.

---

## The three-layer model

Repertoire sits across three layers:

- **Payload** — skills, standards, templates. Lives in git. Identical for every user.
- **Harness adapter** — the thin layer that wires the payload into a specific agent
  harness (pi, Claude Code, Cursor, etc.). Harness-specific. Currently only `pid` exists.
- **Local environment** — OS, shell, PATH, config file locations. Machine-specific.

The combinatorial problem: harnesses × operating systems × config variants is
unbounded. Pre-writing adapters for all combinations is brittle and will always be
incomplete.

---

## The paradigm 2 flip

The original design assumed adapters would be pre-packaged (pid for pi, a future `cid`
for Claude Code, etc.). This is the old paradigm: enumerate every case, write a script
for each.

The revised design: **the agent writes the adapter for its own environment.**

The agent knows:

- What harness it is running in
- What OS and shell the user has
- Where that harness loads context from
- How to wire bootstrap and skills into that harness

We provide:

- `agent-core.sh` — harness-agnostic collection library; the reference for what an
  adapter must do
- `pid` — the reference implementation for pi on Unix; not the general case, but
  proof that the pattern works and a worked example for the agent to consult
- `setup-repertoire` skill — specifies the end state to achieve; the agent handles
  the procedure

This keeps adapters out of the repo entirely for non-pi harnesses, and means
repertoire works on day one for any harness the agent understands.

---

## The single-instruction bootstrap

The entire install process can be initiated with one instruction pasted into any
agent session:

```
Set up repertoire on this machine:
https://raw.githubusercontent.com/burnish-studio/repertoire/main/skills/setup-repertoire/SKILL.md
```

What happens:

1. Agent fetches the URL — gets the setup-repertoire skill content
2. Agent reads the skill — assesses requirements, plans setup
3. Agent inspects the environment — harness, OS, shell, config locations
4. Agent presents a plan with recommendations — asks for confirmation
5. Agent executes setup — creates `~/.agent/`, clones repo, wires harness
6. Agent verifies — confirms bootstrap loads, skills are visible

The user needs nothing beyond a running agent session and internet access.

---

## Requirements check — fail fast

Repertoire requires an agent with file system access and shell execution. Web-only
agents (Claude.ai, ChatGPT web) cannot execute setup. Silent failure or going through
the motions without completing is not acceptable.

`setup-repertoire` must begin with a capabilities check:

- Can the agent read and write files on the local file system?
- Can the agent execute shell commands?
- Is git available?

If any check fails, the agent stops immediately and tells the user:

> "This agent lacks the capabilities needed to install repertoire (file system access
> and shell execution are required). Run this setup using an agent with full tool
> access — for example, pi, Claude Code, or Cursor with terminal enabled."

No partial setup. No false progress. One clear message.

---

## Interactive walkthrough design

Setup is not silent automation — it is a conversation. At each decision point the
agent presents a recommendation and asks for confirmation. The user understands what
is happening and can intervene.

Key decision points surfaced during setup:

1. **Where to clone the repo** — default: `~/.agent/repos/repertoire/`
2. **Full setup vs minimal** — full: `~/.agent/` convention + harness wiring; minimal:
   skills only, no structural changes
3. **pid launcher** — offered for pi/Unix users only; optional
4. **PATH changes** — if `~/bin` not on PATH, ask before modifying `.bashrc`
5. **Personal prompts** — offer to set up `~/.agent/prompts/` with a starter file;
   optional

The tone matches CLI tools like Homebrew or Rust's `rustup`: friendly, informative,
each step narrated, final summary of what was done.

---

## pid's role, clarified

`pid` is an optional convenience launcher for pi users on Unix. It is not required
infrastructure. What it provides:

- Automatic loading of `~/.agent/` content on every session, without manual flags
- Model injection
- `--update`, `--doctor`, `--verify` commands

Without `pid`, a pi user passes flags manually on every launch. `pid` removes that
friction. For Claude Code, Cursor, or any IDE-embedded harness, `pid` is irrelevant.

`setup-repertoire` offers `pid` as an option at the end of setup for pi/Unix users.
It is not mentioned to users on other harnesses.

---

## What setup-repertoire must become

The current skill is a human manual — step-by-step instructions for a person to
follow. It needs to become a paradigm 2 skill: specifies intent and end state, trusts
the agent to handle procedure.

Required changes:

1. **Start with capabilities check** — fail fast if requirements not met
2. **Self-contained** — handles clone itself; assumes nothing is pre-installed beyond
   git and a capable agent
3. **Environment assessment** — harness detection, OS, shell, config locations before
   any action
4. **Present plan, get confirmation** — show what will happen, ask before doing it
5. **Step-by-step narration** — visible progress, not silent execution
6. **Decision points with recommendations** — user can accept defaults or customise
7. **Harness-specific wiring via agent knowledge** — skill describes the end state;
   agent uses its own knowledge of the harness to achieve it; consults `agent-core.sh`
   and `pid` as reference
8. **Graceful degradation** — if no shell access, shift to guided-manual mode
   (narrate commands for the user to run)
9. **Verification** — confirm bootstrap loads and skills are visible before finishing
10. **pid offered as optional** — pi/Unix users only

---

## What was not resolved

- **Harness restart after setup** — some harnesses need a window reload or new
  terminal for changes to take effect. The agent knows this for its own harness and
  should tell the user. No general mechanism needed.
- **Version pinning** — for multi-machine or team use, pinning to a git tag may be
  desirable. Not urgent; `pid --update` with explicit confirmation is sufficient
  for now.
- **Windows native (non-WSL)** — `agent-core.sh` is bash; does not run natively on
  Windows without WSL or Git Bash. Deferred. WSL is the path for Windows users.
- **`CHANGELOG.md`** — improving `pid --update` to show git log summaries is still
  desirable; deferred to after setup-repertoire rewrite.

---

## Immediate next steps

1. Rewrite `setup-repertoire` to match this design
2. Test on Fedora laptop: paste the single instruction into a bare pi session,
   confirm the agent walks through setup correctly
3. After test passes: audit (session 2 delivery files still unaudited)
4. Then: skills backlog
