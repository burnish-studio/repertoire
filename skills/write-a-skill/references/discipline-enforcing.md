---
type: context
title: Discipline-Enforcing Skills — Design Patterns
created: 2026-05-13
updated: 2026-05-13
status: current
model: sonnet-4-6
---

# Discipline-Enforcing Skills

_Perspective: [standards/perspective/STANDARD.md](../../standards/perspective/STANDARD.md)_

_Reference file for `skills/write-a-skill/SKILL.md`. Load when writing or updating a
discipline-enforcing skill — a skill that encodes a mandatory practice the agent must
follow even under pressure._

Examples: test-driven development, systematic debugging, verification before completion.

---

## Why these skills are different

Discipline-enforcing skills govern practices the agent will be under pressure to skip:
time pressure, sunk cost, apparent simplicity, authority from the user. A well-written
technique skill will be followed; a poorly written discipline-enforcing skill will be
followed when convenient and rationalised away under pressure. The design must account
for this.

LLMs respond to the same persuasion mechanisms as humans because they are trained on
human text where those mechanisms precede compliance. Use this deliberately.

---

## Persuasion mechanisms

Four mechanisms are directly applicable. Use them in combination for discipline-enforcing
skills; use them sparingly or not at all for technique, pattern, or reference skills.

**Authority** — imperative language removes decision fatigue and eliminates the
"is this an exception?" question.

```
# ✗ Leaves room for rationalisation
Consider writing tests first when feasible.

# ✓ Removes the decision
Write the test first. No exceptions.
```

**Commitment** — requiring a declaration before acting creates consistency pressure.
A stated commitment is harder to walk back than an unstated one.

```
# Example: announce before proceeding
Before running any fix, state: "Root cause identified: [X]. Proposed fix: [Y]."
```

**Scarcity** — framing requirements as time-bound prevents deferral.

```
# ✗ Deferrable
Verify the fix worked.

# ✓ Time-bound, not deferrable
Verify the fix worked before reporting completion. Do not proceed to the next task first.
```

**Social proof** — establishing universality frames compliance as the norm and
non-compliance as deviance.

```
# ✓ Universality framing
Every fix must be preceded by a failing test that reproduces the bug. Every time.
```

You must not use liking (warmth, praise) in discipline-enforcing skills. It produces
sycophancy and undermines honest feedback.

---

## Rationalization tables

Run the target scenario without the skill present. Record exactly what the agent says
to justify not following the rule. Every verbatim rationalisation becomes a row in
the table.

This is not invented content — it is captured from observed failures and turned into
explicit counters. The table works because the agent has seen these rationalisation
patterns followed by challenge in training data; the table activates the challenge
response before the rationalisation takes hold.

```markdown
## Common rationalisations

| Excuse                                  | Reality                                                         |
| --------------------------------------- | --------------------------------------------------------------- |
| "The fix is obvious — no need to trace" | Obvious fixes address symptoms, not causes. Trace first.        |
| "There's no time for a test"            | Systematic is faster than guess-and-check thrashing.            |
| "I already manually verified it"        | Manual verification has no record and cannot re-run.            |
| "This case is different because..."     | It is not. The rule exists because cases always seem different. |
```

Add rows as new rationalisations emerge from testing. The table is never finished — it
grows with each pressure test.

---

## Red flags lists

A red flags list targets the moment before a violation, when the agent is still in the
state of noticing it is about to rationalise. It names internal thoughts or states that
are reliable indicators of impending violation.

The framing is critical: "if you catch yourself thinking X" — not "don't do X".

```markdown
## Red flags — stop and reconsider

If you find yourself thinking any of the following, stop:

- "This is simple enough to skip the process"
- "I'll verify after, not before"
- "One more attempt first"
- "This case is different because..."

All of these mean the rule applies. Follow it.
```

---

## The Iron Law pattern

For skills where the rule must hold absolutely, state it as an Iron Law with explicit
enumeration of the exceptions (none):

```markdown
## The rule

**No fix without a root cause identified first.**

This applies when:

- The fix seems obvious
- You are under time pressure
- You have already tried multiple fixes
- The user has asked you to just try something

No exceptions.
```

The explicit enumeration of pressure scenarios inside the law itself is the key
technique. It removes the agent's ability to claim its situation is not covered.

---

## Iteration discipline

Discipline-enforcing skills require more rigorous iteration than other skill types.
After each update:

1. Re-run the original pressure scenarios to confirm they still pass.
2. Introduce new pressure combinations. Agents find new loopholes when old ones close.
3. Add new rationalisations to the table as they emerge.
4. Re-test until the skill holds across all pressure types.

The skill is stable when it holds under maximum pressure — time, sunk cost, authority,
apparent simplicity — in combination.
