---
type: standard
title: Self-Contained Files
created: 2026-05-12
updated: 2026-05-13
status: current
model: sonnet-4-6
---

# Self-Contained Files

A file must be fully intelligible when loaded cold — with no surrounding conversation,
no session history, and no ambient context.

This is the baseline assumption under which all files in this collection are written.
An agent or person encountering a file for the first time must be able to read and use
it without needing anything beyond what the file itself provides or explicitly
references.

A file that only makes sense with prior knowledge of a session or project is not done.

## References

Explicit references are permitted and encouraged where a file depends on another. A
reference must name the file it depends on. The dependency must be resolvable — a
reader must be able to find and load the referenced file without further guidance.

Implicit dependencies — terms, conventions, or context assumed but not stated — are
a defect.
