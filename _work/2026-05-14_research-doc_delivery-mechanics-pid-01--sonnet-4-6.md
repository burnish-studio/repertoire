---
type: research-doc
title: Delivery Mechanics and Pid Rewrite — Planning Session
project: repertoire
topic: delivery-mechanics-pid
created: 2026-05-14
updated: 2026-05-14
model: claude-sonnet-4-6
skill: write-up
session: 01
exchanges: 22
status: draft
---

# Delivery Mechanics and Pid Rewrite — Planning Session

_Perspective: [standards/perspective/STANDARD.md](../standards/perspective/STANDARD.md)_

## What this session was

A planning discussion covering how repertoire's skills get delivered into agent sessions,
working through two external reference models (Matt Pocock and Superpowers), a three-layer
delivery vision, the role of station-hq, and the scope of a pid rewrite. The session
produced concrete decisions on directory conventions and the pid rewrite scope, with
heavier architectural questions deferred.

---

## Key insights

### Two delivery models — pull vs push

**Matt Pocock (pull model).** Skills are installed via a symlink script into
`~/.claude/skills/`. A `plugin.json` manifest lists all skill directories. The harness
discovers skills and exposes them as slash commands. User-initiated only — the agent does
not use skills unless explicitly invoked. For pi, this model is already mostly implemented
natively: pi scans configured skill locations, injects descriptions as `available_skills`
XML, and exposes `/skill:name` commands.

**Superpowers (push model).** A `SessionStart` hook fires on every session open. It reads
`skills/using-superpowers/SKILL.md` and injects its full content as `additionalContext`
into the session context. This bootstrap skill instructs the agent to check for and
auto-trigger relevant skills before any response. Skills are the default behaviour, not
tools the user reaches for. Multi-harness: separate hook formats for Claude Code, Cursor,
Copilot CLI, Gemini.

**The structural difference:** Pocock's skills are tools. Superpowers' skills are default
behaviour implemented as skills. The trigger for a skill is not the user invoking it — it
is the agent checking whether it applies.

### Pi's role in discovery vs behaviour

Pi handles **discovery and description injection** only. At startup it scans configured
skill locations, extracts names and descriptions, and injects them as `available_skills`
XML. It does not instruct the agent on how aggressively to use skills. That behaviour has
to be explicitly instructed — via an appended system prompt file in pid's case. Clean
separation: pi handles discovery; pid's append mechanism handles the proactivity
instruction (the bootstrap).

### Harness-agnosticism is non-negotiable

The operative content (system prompt files, stacks, skills) belongs to the user, not to
any harness. Putting it inside `.pi/` makes pi the owner. The correct relationship is
reversed: the content has its own home, and harnesses read from it. This is a prerequisite
for the long-term vision of one location feeding pi, Claude Code, Codex etc.

### Station-hq is a station

Station-hq does not require a special global concept with different rules. It is a station
whose domain happens to be global and whose role is to maintain the shared layer. Same
inbox/outbox interface, same agent-as-handler pattern. The station master is the agent
responsible for it.

The local→global promotion flow works the same way: send a message to the station master,
they decide what belongs globally and build it in. No promotion scripts — brief the station
master, let them handle procedure. Paradigm 2 throughout.

### Pid contains legacy coupling

Pid was built with doti as the frame of reference. Paths like `~/.pi/agent/doti/operative/`
are burned in. Doti is a downstream consumer of general infrastructure, so pid should be
agnostic at this level. The stack system, model injection, and manifest print are all
sound — the coupling is in the paths and the absence of skills support.

---

## Decisions reached

1. **`~/.agent/` as the harness-agnostic root.** All agent infrastructure lives here.
   Harnesses are configured to read from it. Not inside `.pi/` or any other harness
   directory. Simple, non-colliding, readable.

2. **Directory structure under `~/.agent/`:**

   ```
   ~/.agent/
     operative/    ← always-on system prompt files (pid appends these every session)
     stacks/       ← named stacks of system prompt files
     skills/       ← harness-agnostic skills (pi and other harnesses point here)
   ```

3. **Pid to be rewritten in one pass.** Scope:
   - Replace all `~/.pi/agent/doti/operative/` references with `~/.agent/operative/`
   - Replace stacks path with `~/.agent/stacks/`
   - Add skills support: collect skill paths (global, stack-specific, local project),
     pass as `--skill <path>` flags to pi, mirroring the existing append logic
   - Add a bootstrap file mechanism: `~/.agent/operative/` contains a dedicated
     `bootstrap.md` for the skills proactivity instruction
   - Keep: model injection, verify/doctor flags, manifest print, local project overrides,
     stack system concept, env var overrides

4. **Pi settings to point at `~/.agent/skills/`** for repertoire skill discovery.

5. **Bootstrap instruction** — a `.md` file in `~/.agent/operative/` that tells the agent
   to check available skills proactively before responding. Pi handles discovery;
   this file handles the behaviour. Equivalent to Superpowers' `using-superpowers`
   injection.

6. **Layer 3 INSTALL.md deferred.** When station AI is standing, the install process will
   be paradigm-2: an `INSTALL.md` specifying intent, an agent reading it and handling
   procedure for whatever harness it finds. A conventional fallback for non-agent users
   may sit alongside it. Not yet.

7. **Station-hq deferred.** Architecture is clear in principle. Design of the local→global
   correspondence format and the station master's build-out process will be worked out
   when station AI is being implemented.

---

## Open questions

- **What currently lives in `~/.pi/agent/doti/operative/`?** Needs inspection before
  migration. Pid rewrite should not proceed without knowing what will be moved.

- **Skills proactivity bootstrap — what should it say?** The instruction needs to be
  written. Should reference the Superpowers `using-superpowers` pattern as a benchmark
  but be calibrated to repertoire's skill set and pi's native discovery.

- **Layer 2 delivery** (anyone can use repertoire). Deferred. A `plugin.json` manifest
  and conventional INSTALL instructions when there is a real consumer.

- **Pid stack-scoped skills.** Should stacks be able to include their own skill paths
  (not just system prompt files)? Left open — add when the need is felt.

- **Station-hq calling convention.** The desire to call station master from anywhere
  (a global command or pid flag) was noted. Not designed yet.

---

## Notable exchanges

> "Ultimately seems like the user's call, maybe opening a discussion with station-master
> is how we work it out. You sort of call station master to chat about something, then he
> sorts it out."

Captures the paradigm-2 stance on station-hq governance: no formal criterion, no
promotion script — conversation with the station master is the mechanism.

> "What is the value of having these locales inside the .pi directory as opposed to their
> own home/root location?"

The question that surfaced the harness-agnosticism principle cleanly. The answer — limited
value, and directionally wrong — settled the `~/.agent/` decision.
