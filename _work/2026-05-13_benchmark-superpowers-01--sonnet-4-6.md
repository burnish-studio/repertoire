---
type: context
title: Benchmark — Superpowers (obra)
created: 2026-05-13
updated: 2026-05-13
status: current
model: sonnet-4-6
---

# Benchmark — Superpowers (obra)

_Perspective: [standards/perspective/STANDARD.md](../standards/perspective/STANDARD.md)_

Source: https://github.com/obra/superpowers/  
Files reviewed: `skills/writing-skills/SKILL.md`, `skills/writing-skills/anthropic-best-practices.md`,
`skills/writing-skills/persuasion-principles.md`, `skills/systematic-debugging/SKILL.md`,
`skills/test-driven-development/SKILL.md`

---

## Orientation

Superpowers is a software development methodology built as a composable skill library. Its
`writing-skills` skill is the closest external analogue to our `write-a-skill`. It is the most
technically detailed source reviewed so far — both in skill structure and in the theory of why
skills fail. Much of what it covers overlaps with the Matt Pocock and agentskills.io benchmarks.
This document records only what is **genuinely new** relative to those two sources.

---

## What this source adds

### Description must not summarise workflow — empirically tested

The agentskills.io benchmark established that descriptions should be trigger conditions, not
labels. Superpowers sharpens this with a specific, tested failure mechanism:

> When a description summarises the skill's workflow, Claude may follow the description instead
> of reading the full skill content. A description saying "code review between tasks" caused
> Claude to do ONE review, even though the skill's flowchart clearly showed TWO reviews (spec
> compliance then code quality). Changing the description to just triggering conditions fixed it.

This is not the same as "frame as a trigger". It is a harder prohibition: **do not put any
workflow content in the description at all**, because the model will treat it as an executable
summary and skip the body. The failure is silent — the model appears to be using the skill while
actually bypassing it.

The rule: description = when to invoke; nothing else. Any process detail, however brief, is a
risk.

### Rationalization tables

Superpowers' discipline-enforcing skills (TDD, systematic-debugging) include explicit tables
mapping every known rationalization to a rebuttal. These are not invented — they are captured
verbatim from baseline testing (running the skill scenario without the skill present, recording
exactly what the agent said to justify violating the rule), then used to populate the table.

The pattern:

```
| Excuse | Reality |
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "Emergency, no time for process" | Systematic is faster than guess-and-check thrashing. |
| "Tests after achieve the same goals" | Tests-after = "what does this do?" Tests-first = "what should this do?" |
```

This is more precise than the Matt Pocock benchmark's "named anti-patterns with causal
explanation". Anti-patterns describe wrong approaches; rationalization tables close specific
loopholes the agent will use under pressure. They work because LLMs trained on human text have
seen these exact patterns of reasoning followed by compliance, and the table short-circuits them.

### Red flags lists

A companion pattern to rationalization tables: a list of internal states or thoughts that signal
the agent is about to violate a rule, formatted as a self-check.

```
## Red Flags — STOP and Start Over

- Code before test
- "I already manually tested it"
- "Tests after achieve the same purpose"
- "This is different because..."

All of these mean: Delete code. Start over.
```

The function is different from both anti-patterns and rationalization tables. Anti-patterns name
wrong approaches. Rationalization tables rebut post-hoc justifications. Red flags lists operate
earlier — they are early-warning signals the agent can use before the violation occurs, when it
is still in a state of noticing that it is about to rationalise. The phrase "if you catch
yourself thinking X" is the key framing.

### Persuasion principles as a design tool

Superpowers includes `persuasion-principles.md`, grounded in Meincke et al. (2025) — a study of
N=28,000 LLM conversations that found persuasion techniques more than doubled compliance rates
(33% → 72%, p < .001). The core insight is that LLMs respond to the same persuasion mechanisms
as humans because they are trained on human text where those mechanisms precede compliance.

Four principles are directly applicable to skill design:

- **Authority** — imperative language ("YOU MUST", "No exceptions") removes decision fatigue and
  eliminates the "is this an exception?" question. Effective for discipline-enforcing skills.
- **Commitment** — requiring the agent to announce or declare before acting creates consistency
  pressure. "When you find a skill, MUST announce: 'I'm using [Skill Name]'" creates a
  public commitment that subsequent actions must be consistent with.
- **Scarcity** — framing requirements as time-bound ("IMMEDIATELY after X", "BEFORE proceeding")
  prevents procrastination. Effective for verification steps that would otherwise be deferred.
- **Social proof** — establishing universality ("Every time", "Always", "X without Y = failure.
  Every time.") frames compliance as the norm and non-compliance as deviance.

**Avoid liking** — warmth and praise in skill text actively produce sycophancy. Do not write
skills that are designed to be liked.

The mechanism underlying all of this: LLMs have seen "YOU MUST [X]. No exceptions." followed by
compliance thousands of times in training data. The pattern activates the compliance response.
This is not manipulation — it is precision in instruction design.

Practical implication for our skills: the normative language standard (must / should / may)
maps to authority. The word "must" is not just semantic precision — it is a persuasion
mechanism. This reinforces the existing standard and adds a reason to enforce it strictly.

### TDD as a methodology for creating skills

Superpowers applies the full RED-GREEN-REFACTOR cycle to skill creation:

- **RED** — run the target scenario with a subagent _without_ the skill. Document exact
  failures and verbatim rationalisations. You must watch the agent fail. Without this, you do
  not know whether the skill is teaching the right thing.
- **GREEN** — write the minimum skill that addresses the specific failures documented in RED.
  Do not add hypothetical content.
- **REFACTOR** — after GREEN passes, run more pressure scenarios. When new rationalisations
  emerge, add explicit counters. Re-test until bulletproof.

"Write skill before testing? Delete it. Start over."

This is not just a recommendation — it is framed as the same Iron Law as TDD for code. The
reason it matters: a skill that has not been tested against failure may appear correct but
teach the wrong thing, or fail to close the loopholes the agent will actually use. The only
way to know is to watch the failure first.

We do not currently have the infrastructure to run subagent pressure tests. The underlying
principle — write against observed failures, not anticipated ones — translates directly to
iterative development and post-failure updates.

### Skill type taxonomy with differentiated design requirements

Superpowers distinguishes four skill types, each requiring different design:

| Type                     | Description                                               | Primary design need                                     |
| ------------------------ | --------------------------------------------------------- | ------------------------------------------------------- |
| **Technique**            | Concrete method with steps (condition-based-waiting)      | Application scenarios; edge case coverage               |
| **Pattern**              | Mental model for a class of problems (flatten-with-flags) | Recognition tests; counter-examples                     |
| **Reference**            | API docs, syntax, tool documentation                      | Retrieval tests; table of contents for >100 lines       |
| **Discipline-enforcing** | Mandatory practice that resists pressure (TDD)            | Rationalization tables; red flags lists; pressure tests |

Most of our current skills are techniques. The skill type should determine how much
anti-rationalization scaffolding is needed — reference skills need none; discipline-enforcing
skills need extensive hardening.

### When not to create a skill

Superpowers states this as a design criterion: "If it's enforceable with regex/validation,
automate it — save documentation for judgment calls."

The principle: mechanical constraints belong in tooling; judgment calls belong in skills.
Documentation for something deterministically enforceable wastes tokens and trains the agent
to treat hard constraints as soft guidance. When something can be checked programmatically,
check it programmatically and do not write a skill about it.

### Token efficiency with specific targets

Superpowers gives concrete word-count targets by skill category:

- Getting-started / frequently-loaded skills: **< 150 words each**
- Other frequently-loaded skills: **< 200 words total**
- Other skills: **< 500 words** (still be concise)

Techniques for achieving this: move parameter details to `--help` output rather than
documenting them in the skill; use cross-references rather than repeating content; compress
examples (minimal example at 20 words beats verbose example at 42 words). Do not repeat
content that is already in a referenced skill.

### References must be one level deep from SKILL.md

If SKILL.md references advanced.md, and advanced.md references details.md, Claude may read
the intermediate file with `head -100` and miss the actual content. All reference files must
link directly from SKILL.md. Nesting references more than one level deep is a reliability
failure, not just an organisational preference.

For reference files longer than 100 lines, include a table of contents at the top so Claude
can orient even when reading partially.

### One excellent example beats many mediocre ones

Named as a specific anti-pattern: **multi-language dilution** — providing the same example in
five languages produces five mediocre examples with maintenance burden. Provide one excellent
example in the most relevant language. The agent can port it; the skill cannot compensate for
five weak examples by having five of them.

---

## What does not translate

### The Iron Law enforcement framing

Superpowers uses "Iron Law", "delete means delete", "no exceptions", "mandatory" as structural
elements throughout. This produces discipline-enforcing skills that are extremely hardened
against rationalization. The technique is valid and we should apply it selectively — specifically
for our discipline-enforcing skills. It is not the right register for techniques, patterns, or
reference skills, where heavy authority language would be noise.

### Subagent pressure testing infrastructure

The full RED-GREEN-REFACTOR methodology requires running subagent scenarios, which requires
multi-agent harness capability. The principle applies; the infrastructure does not currently
exist. Note for future: when subagent capability is available, this methodology should govern
skill creation.

### Flowchart syntax (graphviz .dot)

Superpowers uses graphviz .dot format for flowcharts with a render script. The underlying
principle — use flowcharts only for non-obvious decision points, never for linear instructions
or reference material — translates. The format does not; our rendering environment differs.

---

## Implications for `write-a-skill` update

| Finding                                 | Action                                                                                    |
| --------------------------------------- | ----------------------------------------------------------------------------------------- |
| Description must not summarise workflow | Strengthen the trigger-framing guidance with this specific failure mechanism and example  |
| Rationalization tables                  | Add as a named pattern for discipline-enforcing skills; explain why they work             |
| Red flags lists                         | Add as a named pattern; distinguish from anti-patterns and rationalization tables         |
| Persuasion principles                   | Add a section on why normative language works mechanically; reinforce must / should / may |
| Skill type taxonomy                     | Add taxonomy; note that design requirements differ by type                                |
| When not to create a skill              | Add a "when not to create" section                                                        |
| Token efficiency targets                | Add specific word-count guidance                                                          |
| One-level reference depth               | Add to reference file loading guidance                                                    |
| One excellent example                   | Add to examples guidance; name multi-language dilution as an anti-pattern                 |

---

## Updated quality markers — combined view

| Marker                                       | Matt Pocock | agentskills.io | Superpowers |             Our skills             |
| -------------------------------------------- | :---------: | :------------: | :---------: | :--------------------------------: |
| Named anti-patterns with causal reason       |      ✓      |       ✗        |      ✓      |                 ✗                  |
| Explicit effort prioritisation               |      ✓      |       ✗        |      ✓      |                 ✗                  |
| Concrete output format when applicable       |      ✓      |       ✓        |      ✓      |              partial               |
| Before/after examples                        |      ✓      |       ✓        |      ✓      |                 ✗                  |
| Companion reference files                    |      ✓      |       ✓        |      ✓      |           described only           |
| Edge case / exception modelling              |      ✓      |       ✓        |      ✓      |                 ✗                  |
| Description as trigger (no workflow summary) |      ✓      |       ✓        | ✓ (tested)  |              partial               |
| Gotchas sections                             |      ✗      |       ✓        |      ✗      |                 ✗                  |
| Match specificity to fragility               |      ✗      |       ✓        |      ✓      |                 ✗                  |
| Defaults not menus                           |      ✗      |       ✓        |      ✓      |                 ✗                  |
| Progressive disclosure with explicit limits  |      ✗      |       ✓        |      ✓      |              partial               |
| Rationalization tables                       |      ✗      |       ✗        |      ✓      |                 ✗                  |
| Red flags lists                              |      ✗      |       ✗        |      ✓      |                 ✗                  |
| Persuasion principles as design tool         |      ✗      |       ✗        |      ✓      | partial (intent-language standard) |
| Skill type taxonomy                          |      ✗      |       ✗        |      ✓      |                 ✗                  |
| When not to create a skill                   |      ✗      |       ✗        |      ✓      |                 ✗                  |
| Token efficiency targets                     |      ✗      |    partial     |      ✓      |                 ✗                  |
| One-level reference depth rule               |      ✗      |       ✗        |      ✓      |                 ✗                  |
| One excellent example (anti-dilution)        |      ✗      |       ✗        |      ✓      |                 ✗                  |
| Sharp description field                      |      ✓      |       ✓        |      ✓      |                 ✓                  |
| Self-containment                             |      ✓      |       ✓        |      ✓      |                 ✓                  |
| Standards layer                              |      ✗      |       ✗        |      ✗      |                 ✓                  |
| Consistent normative language                |      ✗      |       ✗        |      ✗      |                 ✓                  |
