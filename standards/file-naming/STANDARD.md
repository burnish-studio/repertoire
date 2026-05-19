---
type: standard
title: File Naming
created: 2026-05-12
updated: 2026-05-13
status: current
model: sonnet-4-6
---

# File Naming

All files must follow one of two naming patterns — enduring artefacts or point-in-time documents.

---

## Enduring artefacts

Standards, skills, and templates are enduring — they have long lifespans, may be
edited over time, and are canonical within the repository. Each lives in its own
named directory.

The directory name is the artefact identifier:

- Lowercase kebab-case
- Describes what the artefact is, not when it was created
- No date, no model identifier

The file inside the directory is named by type, in uppercase:

| Type     | Filename      |
| -------- | ------------- |
| Skill    | `SKILL.md`    |
| Standard | `STANDARD.md` |
| Template | `TEMPLATE.md` |

Example: `standards/programming-paradigm/STANDARD.md`

Co-located assets — scripts, references, changelogs — live inside the same directory
alongside the primary file.

---

## Point-in-time documents

Write-ups, research notes, session records, and any document created at a specific
moment must follow this pattern:

```
YYYY-MM-DD_<topic>-<nn>--<model>.md
```

| Segment      | Description                                                  |
| ------------ | ------------------------------------------------------------ |
| `YYYY-MM-DD` | ISO date of creation. Enables chronological sorting.         |
| `<topic>`    | Kebab-case topic slug. Describes the subject matter.         |
| `<nn>`       | Zero-padded two-digit sequence number. Increments per topic. |
| `<model>`    | Short model identifier, e.g. `sonnet-4-6`.                   |

Example: `2026-05-13_agentic-paradigm-01--sonnet-4-6.md`

The double dash before `<model>` is a deliberate visual separator — it sets provenance
apart from subject matter at a glance.

If the model cannot be determined, apply `standards/unknown-values/STANDARD.md`.

---

## Optional type segment

Point-in-time documents may include an optional type segment between the date and topic:

```
YYYY-MM-DD_<type>_<topic>-<nn>--<model>.md
```

Use this when the type adds meaningful disambiguation — for example, distinguishing
research documents from session records within the same `_work/` directory.

Example: `2026-05-15_research-doc_bootstrap-design-01--sonnet-4-6.md`

The type segment is optional and must not be used merely to restate what the topic
already makes clear.
