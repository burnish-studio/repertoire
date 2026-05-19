---
type: template
title: Frontmatter
created: 2026-05-12
updated: 2026-05-13
status: current
model: sonnet-4-6
---

# Frontmatter Template

Copy the block below into a new document and complete each field.

```yaml
---
type:
title:
created:
updated:
status:
model:
---
```

---

## Base fields

Required for all documents.

| Field     | Meaning                                                        | Allowed values                                                 |
| --------- | -------------------------------------------------------------- | -------------------------------------------------------------- |
| `type`    | The kind of artefact this document is                          | `skill` · `standard` · `template` · `context` · `research-doc` |
| `title`   | Human-readable name for the document                           | Free text                                                      |
| `created` | Date first created. Set once — never updated.                  | ISO date `YYYY-MM-DD`                                          |
| `updated` | Date of most recent edit. Must be refreshed on every edit.     | ISO date `YYYY-MM-DD`                                          |
| `status`  | Current standing of this document                              | `draft` · `current` · `deprecated`                             |
| `model`   | Model that produced or last significantly edited this document | Short identifier, e.g. `sonnet-4-6`                            |

---

## Skill fields

Skills must also carry these fields, required by the harness for loading and triggering.
They sit alongside the base fields in the same frontmatter block.

| Field         | Meaning                                          | Allowed values                  |
| ------------- | ------------------------------------------------ | ------------------------------- |
| `name`        | Skill identifier. Must match the directory name. | Kebab-case, max 64 characters   |
| `description` | What the skill does and when to use it.          | Plain text, max 1024 characters |

For guidance on writing the `description` field, see `skills/write-a-skill/SKILL.md`.

---

## Extended fields

Specific document types may require additional fields beyond those listed here.
Extended fields are defined in the relevant template for that type.
