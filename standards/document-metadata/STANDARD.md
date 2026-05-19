---
type: standard
title: Document Metadata
created: 2026-05-12
updated: 2026-05-13
status: current
model: sonnet-4-6
---

# Document Metadata

_Perspective: [standards/perspective/STANDARD.md](../perspective/STANDARD.md)_

All documents must open with a YAML frontmatter block. Metadata makes a document
self-describing — it can be read, indexed, and handled correctly without depending
on its location or surrounding context. A document without frontmatter requires
ambient knowledge to interpret and is not complete.

The required fields, their meanings, and their allowed values are defined in
`templates/frontmatter/TEMPLATE.md`. That template is the authority on form.

Where a field value cannot be determined, you must apply `standards/unknown-values/STANDARD.md`.

---

## Exemptions

Two categories of file are exempt from the frontmatter requirement:

**`README.md`** — The repository root README is a public-facing document rendered by
GitHub. YAML frontmatter renders as a visible table on GitHub, degrading the reading
experience. The README must not carry frontmatter.

**Runtime-injection files** — Files in `base/` are injected directly into agent system
prompts at session start. Frontmatter in these files would appear verbatim in the
context window and pollute the prompt. Files in `base/` must not carry frontmatter.

All other files in the repository, including files in `docs/`, `bin/`, and `_work/`,
are subject to the standard.
