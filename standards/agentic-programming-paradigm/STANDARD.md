---
type: standard
title: Agentic Programming Paradigm
created: 2026-05-12
updated: 2026-05-13
status: current
model: sonnet-4-6
---

# Agentic Programming Paradigm

_Perspective: [standards/perspective/STANDARD.md](../perspective/STANDARD.md)_

When intelligence is substantively in the execution layer, you must specify intent and outcome — not procedure.

The old approach to programming handles variation through explicit enumeration. An
install script for an application might run to hundreds of lines — detecting the OS,
checking existing dependencies, handling different package managers, accounting for
what is already installed. Every conditional is written in advance because the execution
layer is dumb. It can only do what it was told.

When an intelligent agent is in the execution layer, this inverts. The instruction
becomes "install application X." The agent reads the current environment, knows the
application, and installs appropriately. The script gets shorter and more capable
simultaneously — not a trade-off. The variation that previously required explicit
handling is absorbed by intelligence that can actually reason about it.

This is the agentic programming paradigm: when intelligence is substantively in the
execution layer, you must specify intent and outcome — procedure must not be specified. The intelligence
fills the gaps — and gaps filled by intelligence are not omissions, they are the point.

The inverse holds equally. Over-specification in an agentic system does not just add
unnecessary work — it actively undermines the capability you are building on. A rigid
specification constrains an intelligent system to behave like a dumb one, while
injecting your own errors and blind spots into its execution. Think of it like managing
people: handing a competent person a detailed checklist does not improve their work. It
signals distrust and forces your procedure onto their expertise. Clear goals, relevant
constraints, and room to operate produces better outcomes.

---

## When this applies

This paradigm applies when intelligence is substantively in the execution layer of what
you are building or specifying.

It does not apply universally. Building a Next.js component, writing a database schema,
or configuring infrastructure are old-paradigm work — deterministic execution where
explicit specification is correct. An agent may be used to _build_ these things, but
the output itself is non-agentic. You must specify it precisely.

Skills and briefings intended to be consumed by agents at runtime are the clearest case
for this paradigm. The entire functional stack is agentic. Writing them as procedure
lists works against the medium.

The question to ask: is intelligence part of how this thing _runs_, not just how it was
built?

If yes — you must specify intent and outcome.  
If no — you must specify as precisely as the execution layer requires.

---

## Specificity is not procedure

This paradigm does not mean vague. Specificity is still required where the intent
genuinely demands it. "The output must include a frontmatter block" is not
over-specification — it is a real constraint that closes a real gap.

The distinction is between specifying _what is required_ and specifying _how to get
there_. The former is always legitimate. The latter is only legitimate when the how is
itself the constraint — when there is genuinely one acceptable path and it must be
named.

Where determinism is the actual requirement, you should remove the operation from agentic judgment
entirely. A script that always produces the same output from the same input is the right
tool for that. Putting it inside agentic reasoning introduces variability where
variability is the enemy. This is judgment, not a rule — in the same way that holding a
door open is best done by a door stop, not a person.

---

## The test

If you removed every _how_ from your specification and left only intent and outcome,
would the intelligence still have everything it needs?

If yes: you are done.  
If no: you must add only what closes a genuine gap in intent — never procedure.

---

## Writing for an agent

You should write for a competent person. Clear, direct prose aimed at an intelligent
reader is not just easier to write — it is the most effective input. The intelligence
is calibrated on human communication and responds best to it. You should not write for
a parser. You should not fragment naturally flowing reasoning into bullets because it
looks structured. A well-written briefing outperforms a checklist.
