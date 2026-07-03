---
type: context
title: Phase 2 build complete — rep v0 receipt
created: 2026-07-03
updated: 2026-07-03
status: current
model: fable-5
---

# Phase 2 build complete — rep v0 receipt

Phase 2 (build `rep` v0) is done. Three files were created; no existing files were
modified. All 7 acceptance tests pass. The tool is ready for live smoke testing.

---

## What was built

From the brief at `_work/2026-07-03_brief_rep-v0-build-01--fable-5.md`, against ADRs
0005–0008 in `.plan/adr/`.

### Files created

| File | Purpose |
|------|---------|
| `package.json` | `"repertoire"`, ESM, Node ≥20, zero deps, `bin/rep` → `./bin/rep.mjs` |
| `bin/rep.mjs` | ~30KB single-file CLI, all commands |
| `test/rep-test.sh` | 7 acceptance tests, run from repo root with no args |

### Command surface

| Command | Behaviour |
|---------|-----------|
| `rep init [--skills a,b,c \| --all-skills]` | Vendors standards (all, indivisible), templates (all), base, selected skills (default: write-a-skill, write-a-standard, codify, audit). Compiles stance block into `AGENTS.md`. Writes `CLAUDE.md` pointer. Creates `.claude/skills/<name>` symlinks. Writes `.agents/repertoire.lock`. Refuses if lock exists. |
| `rep add <skill>…` | Vendors one skill at a time: copies dir, adds symlink, updates lock. Skips already-vendored skills with a message. |
| `rep remove <skill>…` | Removes a vendored skill: deletes dir + symlink, cleans lock entries. Refuses skills not in the lock (authored skills are never touched). |
| `rep remove --all` | Full reversal: deletes lock-listed files, removes stance block between markers, removes pointer line, cleans symlinks and empty dirs, honours `created` flags for pre-existing files, deletes lock last. |
| `rep update [--force]` | Re-vendors all content from the running package. Checks each file's hash against the lock — refuses on drift without `--force`. Recompiles stance block and diffs old vs new. Prints "Stance block unchanged." when clean. |
| `rep compile` | Recompiles stance block from all standards in `.agents/standards/` — vendored and authored alike — and writes it into `AGENTS.md`. This is how an authored standard's norm enters the block. |
| `rep status` | Verifies file hashes, symlink resolution, stance block presence and freshness, pointer presence. Counts authored artefacts. Exits non-zero on any issue. |

### Key implementation details

**Norm extraction** follows the locked rule from ADR-0006: strip YAML frontmatter, the
`# h1` line, and any `_Perspective: …_` line; the norm is the remaining body above the
first `---`; if no `---`, the whole remaining body is the norm. Title comes from
frontmatter `title:`, falling back to h1 text.

**Lockfile paths** are project-root-relative (e.g. `.agents/skills/write-a-skill/SKILL.md`),
matching the shape in the brief's example. Hashes are SHA-256 hex.

**Symlink detection** uses `lstatSync` (not `statSync`) — `statSync` follows symlinks
and would misidentify them as regular directories.

**Content source** is the running package directory — `rep` reads from its own
`skills/`, `standards/`, `templates/`, `base/` subdirectories. The `ref` in the lock is
`git rev-parse HEAD` of the package directory, or `"unknown"` if that fails.

### Acceptance tests (all passing)

1. **init** — tree exists, lock hashes valid, stance block has correct standard count, CLAUDE.md pointer present, symlinks resolve
2. **byte-clean removal** — after `remove --all`, `git status --porcelain` is empty
3. **pre-existing files survive** — AGENTS.md and CLAUDE.md with user content are restored byte-identical after remove
4. **add/remove round-trip** — skill added, skill removed, lock consistent
5. **drift detection** — status reports DRIFTED, update refuses, `--force` overrides
6. **authored norm** — creating `.agents/standards/test-local/STANDARD.md` and running `compile` injects it; `remove --all` leaves it in place
7. **--all-skills** — vends all 4 skills from the package

### Files NOT modified

No existing repo files were touched. Only `package.json`, `bin/rep.mjs`, and
`test/rep-test.sh` are new.

---

## What to do next

Per the handover at `_work/HANDOVER.md`, the next step is:

> **Phase 2 — live smoke test:** run `rep init` in a scratch project, then open fresh
> Claude Code + pi sessions, confirm the stance is active and skills trigger. Then stand
> it up inside Station AI (the real test).

The brief at `_work/2026-07-03_brief_rep-v0-build-01--fable-5.md` also says:

> Review the built code against the brief line by line (frontier-model review pass).

So there are two review actions:
1. **Code review** — read `bin/rep.mjs` against the brief line by line and verify every
   requirement is met
2. **Live smoke test** — `rep init` in a real project, test in actual agent sessions

### For the smoke test

The tool can be invoked directly without npm link:

```bash
node /path/to/repertoire/bin/rep.mjs init
```

Or via `npx` from the repo:

```bash
npx github:burnish-studio/repertoire init
```

Post-init, verify in a fresh agent session:
- The stance block appears in the context window
- Skills in `.agents/skills/` are discoverable and trigger
- `CLAUDE.md` → `@AGENTS.md` import works (for Claude Code)

---

## Git state

Working tree is clean except for the three new files. They are untracked:

```
?? bin/rep.mjs
?? package.json
?? test/rep-test.sh
```

Ready to commit. The `.gitignore` should be checked — `node_modules/` should already
be ignored if `npx` or `npm install` is run.
