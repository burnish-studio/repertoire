---
type: standard
title: Document Metadata
created: 2026-05-12
updated: 2026-05-13
status: current
model: sonnet-4-6
---

# Document Metadata

All documents must open with a YAML frontmatter block. Metadata makes a document
self-describing — it can be read, indexed, and handled correctly without depending
on its location or surrounding context. A document without frontmatter requires
ambient knowledge to interpret and is not complete.

The required fields, their meanings, and their allowed values are defined in
`templates/frontmatter/TEMPLATE.md`. That template is the authority on form.

Where a field value cannot be determined, you must apply `standards/unknown-values/STANDARD.md`.
