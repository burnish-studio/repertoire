---
type: context
title: Benchmark — OpenClaw (Steinberger)
created: 2026-05-13
updated: 2026-05-13
status: current
model: sonnet-4-6
---

# Benchmark — OpenClaw (Steinberger)

_Perspective: [standards/perspective/STANDARD.md](../standards/perspective/STANDARD.md)_

Source: https://docs.openclaw.ai/  
Pages reviewed: `concepts/soul` (SOUL.md Personality Guide), `reference/templates/SOUL`,
`reference/templates/AGENTS`, `reference/templates/IDENTITY`, `reference/templates/USER`,
`reference/templates/BOOT`

---

## Orientation

OpenClaw is a self-hosted gateway connecting messaging apps to AI agents. As a product it is
not relevant to this repertoire. What is relevant is Peter Steinberger's approach to structuring
information fed to models — specifically how he designs the files that constitute an agent's
context. His practice is grounded in OpenAI's prompt engineering guidance and has been iterated
on in a production system used across many surfaces (iMessage, Discord, WhatsApp, etc.).

The SOUL.md concept and the template system it sits within represent a considered architecture
for context management. Several principles from that architecture apply directly to how we write
skills and standards.

---

## What this source adds

### Behavioral specificity as the primary content test

The SOUL.md guide states this directly: do not include content that has no behavioral effect.
The named anti-patterns — "life story", "changelog", "security policy dump", "giant wall of
vibes with no behavioral effect" — all describe the same failure: content that is present,
coherent, even accurate, but that does not change how the agent behaves.

The corollary is stated as a contrast between effective and ineffective rules:

**Effective (specific, behavioral):**

- have a take
- skip filler
- be funny when it fits
- call out bad ideas early
- stay concise unless depth is actually useful

**Ineffective (generic, aspirational):**

- maintain professionalism at all times
- provide comprehensive and thoughtful assistance
- ensure a positive and supportive experience

The difference is not tone or length — it is whether the rule constrains a specific, observable
behaviour. "Maintain professionalism" cannot fail; there is no output the model would produce
that it could not rationalize as professional. "Skip filler" can fail — the model either opens
with "Great question!" or it does not. The test is: can the model tell from this rule whether a
specific output violates it?

This is the sharpest single formulation of the "add what the agent lacks" principle found in
any source reviewed. It applies to every sentence in every file fed to a model — skills,
standards, and the `write-a-skill` skill itself.

**The test:** for every sentence in a skill, ask: does this change a specific, observable
behaviour? If not, remove it.

### Single-purpose file separation by cognitive function

OpenClaw's template system separates context into distinct files with strictly single purposes:

| File          | Cognitive function                     | What it must not contain         |
| ------------- | -------------------------------------- | -------------------------------- |
| `SOUL.md`     | Voice, tone, stance, style             | Operating rules, security policy |
| `AGENTS.md`   | Operating rules, boundaries, behaviour | Personality, tone                |
| `USER.md`     | Context about the person being helped  | Rules, personality               |
| `IDENTITY.md` | Self-concept (name, vibe, self-image)  | Everything else                  |
| `MEMORY.md`   | Curated long-term memory               | Real-time operating state        |
| `TOOLS.md`    | Capability-specific notes              | Character, rules                 |

The design principle is explicit: "Personality is not permission to be sloppy. Keep AGENTS.md
for operating rules. Keep SOUL.md for voice, stance, and style."

The reason this matters for skill design is that mixed-purpose content creates context
confusion — the model receives contradictory signals about which mode or register it is in.
A skill that mixes "what to do" with "why you should care" with "who you are when doing this"
asks the model to hold three different frames simultaneously. Single-purpose files are more
reliable because the model's activation is unambiguous.

Applied to our skills: a skill may contain motivation (the why), procedure (the what), and
edge cases (the where-this-breaks) — but these should be clearly separated within the skill,
not blended. The agentskills.io guidance on progressive disclosure addresses this structurally;
Steinberger's insight adds the cognitive reason it matters.

### Short beats long, sharp beats vague — as a primary constraint

This is not a style preference in OpenClaw's treatment — it is the primary design constraint
stated at the top of the SOUL.md guide:

> Short beats long. Sharp beats vague.

The word "sharp" is doing specific work here. It means the rule has an edge — it cuts off some
outputs and permits others. A vague rule has no edge; it permits everything while appearing to
constrain something. Sharpness is a structural property, not a stylistic one.

This maps directly to the behavioral specificity test above, but adds the dimension of
length: a sharp rule that is also short is better than a sharp rule that is long, because every
token in a file loaded into a model competes with everything else in the context. The goal is
maximum behavioral effect per token.

This principle should be applied as an editing criterion when reviewing our skills:
for each rule, is it sharp (has an edge)? Can it be shorter while remaining sharp?

### Iteration as a maintenance mindset

Steinberger cites OpenAI's prompt engineering guidance approvingly: "treat prompts like
something you iterate on, pin, and evaluate, not magical prose you write once and forget."

The emphasis is on the maintenance posture. Skills are not written once and stored. They are
living artefacts that should be updated when they fail — when observed agent behaviour diverges
from intended behaviour. This frames skill creation as the beginning of a maintenance
relationship, not an act of documentation.

The practical implication: every skill should have a mechanism for identifying when it is
failing. Superpowers' red flags lists and rationalization tables are one implementation. The
minimum viable version is: someone using a skill should be able to recognize when agent
behaviour diverges, and the skill should be updated in response.

This aligns with our epistemology standard (error-correction as the fundamental mechanism) and
makes that standard concrete for skill maintenance.

### What the soul/rules separation reveals about our standards

OpenClaw's separation of SOUL.md (voice, stance) from AGENTS.md (operating rules) maps onto
something we have not explicitly resolved: the difference between what an agent _is_ and what
an agent _does_.

Our standards currently operate mostly on behaviour — what agents must do, how they must frame
things, what they should not produce. This is the AGENTS.md layer. We do not have an explicit
equivalent of SOUL.md — a file that governs how the agent presents itself, its register, its
stance toward the work.

The `standards/collaboration/` standard comes closest. But it governs the relationship, not
the voice. The doti stack-files in the system prompt (layers 1-3) are closer to SOUL.md in
function — they are identity-layer content, not rule-layer content.

This is not a gap that needs filling in this benchmark, but it is a structural observation
worth preserving: our standards are rule-layer; voice/stance is currently handled at the harness
level (stack-files). Keeping that separation clean is correct; conflating them would be the
error.

---

## What does not translate

### The memory and session management system

AGENTS.md, MEMORY.md, and the heartbeat system are specific to OpenClaw's architecture:
persistent personal agent, cross-session memory, proactive background tasks. None of this
applies to skills-based agent work in a coding context.

### IDENTITY.md

This is for agents that have persistent identity across sessions and a user relationship that
develops over time. Not applicable to skills-based task execution.

### Group chat and social behaviour rules

Specific to messaging surfaces. Not relevant.

---

## Implications for `write-a-skill` update

| Finding                                 | Action                                                                                                                            |
| --------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| Behavioral specificity test             | Add as a named editing criterion: "does this sentence change a specific, observable behaviour? If not, remove it."                |
| Effective vs. ineffective rule contrast | Add the before/after example — it is the clearest single illustration of what good normative content looks like                   |
| Short beats long, sharp beats vague     | Add as an editing principle with a definition of "sharp" (has an edge; can fail)                                                  |
| Iteration as maintenance mindset        | Add to the section on reference files and ongoing use — skills should be updated when they fail                                   |
| Soul/rules separation                   | Note the boundary: skills govern behaviour; identity/voice is a separate layer. Do not let skills drift into voice-layer content. |
