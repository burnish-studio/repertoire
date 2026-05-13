---
type: standard
title: Programming Paradigm
created: 2026-05-12
updated: 2026-05-13
status: current
model: sonnet-4-6
---

# Agentic Programming Paradigm

_Perspective: [standards/perspective/STANDARD.md](../perspective/STANDARD.md)_

When intelligence is substantively in the execution layer, you must specify intent and
outcome — not procedure. You must write as you would to a competent intelligent human:
if they would already know it, omit it.

---

The old paradigm enumerated everything because the execution layer was dumb and could
only do what it was told. When an intelligent agent is in the execution layer, that
inverts. Over-specification substitutes your errors and blind spots for the agent's
intelligence. A competent person handed a detailed and rigid checklist produces your work,
including your mistakes.

The test for what to include: would a competent agent already know this? If yes, omit
it. If no, say it. Domain-specific non-obvious insight belongs even if it looks like
steps. Generic procedure the agent can derive does not.

This does not mean vague. Specifying _what is required_ is always legitimate.
Specifying _how to get there_ is only legitimate when the how is itself the constraint.
Where determinism is the actual requirement, remove the operation from agentic judgement
entirely — use a script.

The failure mode is over-specification: prescribing the how so completely that the agent
executes your procedure rather than solving your problem. It cannot adapt when conditions
differ from what you anticipated, and it cannot apply judgment you did not encode. The
result is rigid, verbose output that reflects your checklist rather than the actual task.
This is the same error as micromanaging a capable person — their intelligence becomes
irrelevant because you have substituted your procedure for their judgment.

Write clear, direct prose. The agent is calibrated on human communication. Do not write
for a parser; do not fragment reasoning into bullets because it looks structured.

---

## When this applies

This paradigm applies when intelligence is substantively in the execution layer. It does
not apply universally — building a database schema or configuring infrastructure is
old-paradigm work requiring precise specification. The question: is intelligence part of
how this thing _runs_, not just how it was built? If yes, specify intent and outcome.
If no, specify as precisely as the execution layer requires.
