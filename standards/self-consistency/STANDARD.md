---
type: standard
title: Self-Consistency
created: 2026-05-13
updated: 2026-05-13
status: current
model: sonnet-4-6
---

# Self-Consistency

The repertoire must at all times conform to its own standards.

This is not a secondary concern — it is a defining property of a normative system. A
rule set that does not follow its own rules is incoherent. Every file in this repertoire
is simultaneously a rule that governs other documents and an artifact that must itself
be governed by those rules.

A violation anywhere in the set is a defect in the set, not just in the offending file.
When a standard is added or changed, all existing files become candidates for review.

---

## What self-consistency requires

Every file must conform to all applicable standards. At minimum:

- Frontmatter is present and complete per `templates/frontmatter/TEMPLATE.md`
- Normative statements use intent language per `standards/intent-language/STANDARD.md`
- Files using first or second person pronouns reference `standards/perspective/STANDARD.md`
- Files are intelligible cold per `standards/self-contained-files/STANDARD.md`
- Unresolvable field values apply `standards/unknown-values/STANDARD.md`
- File and directory names follow `standards/file-naming/STANDARD.md`

This list is not exhaustive. As new standards are added, they apply retroactively to
all existing files.

---

## Coherence state

The repertoire is in a coherent state when no file violates any standard the set
asserts. Achieving and maintaining this state is the purpose of the audit skill —
see `skills/audit/SKILL.md`.
