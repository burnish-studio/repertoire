---
type: standard
title: Unknown Values
created: 2026-05-12
updated: 2026-05-13
status: current
model: sonnet-4-6
---

# Unknown Values

When a field value cannot be determined, a sentinel value must be used — never omit the field or leave it blank.

| Situation                             | Value     |
| ------------------------------------- | --------- |
| Value exists but cannot be retrieved  | `unknown` |
| Field does not apply to this document | `n/a`     |

These are the only two permitted substitutes for a real value. Do not invent
alternatives.
