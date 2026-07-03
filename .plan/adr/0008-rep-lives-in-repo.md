---
type: context
title: ADR-0008 — rep Lives in the Repertoire Repo
created: 2026-07-03
updated: 2026-07-03
status: current
model: fable-5
---

# rep ships inside the repertoire repo; tool and content version in lockstep

The `rep` CLI is part of the repertoire repository itself: a `package.json` with a
`bin` entry pointing at a single dependency-free Node script (`bin/rep.mjs`) that shells
out to `git`. Invocation is `npx github:burnish-studio/repertoire <command>` with no npm
publishing required; a scoped npm name is published later only if outside adoption
warrants it.

## Why

Own-stack-first (the settled optimisation target) makes a second repo and npm release
process pure overhead now. Co-locating tool and content means one pinned ref in
`repertoire.lock` covers both — a given `rep` always understands the content layout it
shipped with, so no tool/content compatibility matrix exists.

## Consequences

- The repo gains a small deterministic-code surface (`bin/rep.mjs`, `package.json`)
  alongside its markdown content; the programming-paradigm standard's own rule applies —
  delivery mechanics are deterministic, so they live in code, not in skills.
- `rep update` updates content *and* tool together by advancing the pinned ref.
- The paste-URL agent front door remains: a short setup skill whose job is to run
  `npx github:burnish-studio/repertoire init` and verify, not to improvise file
  operations.
