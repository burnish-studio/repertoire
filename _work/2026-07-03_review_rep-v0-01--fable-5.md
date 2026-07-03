---
type: review
title: rep v0 — frontier review pass and live smoke test
created: 2026-07-03
updated: 2026-07-03
status: current
model: fable-5
---

# rep v0 — frontier review pass and live smoke test

The line-by-line review of `bin/rep.mjs` against the brief
(`_work/2026-07-03_brief_rep-v0-build-01--fable-5.md`), required by the brief and the
Phase 2 receipt, plus the live smoke test. Three real defects were found, confirmed
empirically, fixed in place, and covered with regression tests (now tests 8–10 in
`test/rep-test.sh`). All 10 acceptance tests pass. The live smoke test passes.

---

## Defects found and fixed

### 1. `rep update` claimed authored content into the lock (data loss)

`buildLock` hashed **everything on disk** under `.agents/standards/` and
`.agents/templates/`, not the vendored set. After authoring a standard and running
`rep update`, the authored standard entered `lock.files`; a later `rep remove --all`
then **deleted the user's authored standard**. Confirmed live before fixing. This
violated the ADR-0006 ownership boundary (the lock defines what rep owns). A side
effect: editing one's own authored standard made `update` refuse with "drift" and
`status` report the user's own file as DRIFTED.

Fix: `buildLock` now takes the vendored standard/template name sets explicitly and
claims only those. Test 8 covers the full sequence (author → compile → update →
remove --all → authored standard survives, lock never mentions it).

The original suite missed this because test 6 ran `compile` (which does not rewrite
the lock) but never `update` with an authored standard present.

### 2. Byte-identical restore failed on trailing whitespace

`removeStanceBlock` and `removePointer` ran `content.trim()` on the user's file, so a
pre-existing `AGENTS.md`/`CLAUDE.md` with trailing blank lines came back from
`remove --all` normalised, not byte-identical. Injection also `trimEnd()`-ed the
user's bytes on the way in.

Fix: injection appends without normalising (adding a separator newline only when the
file lacks a final one); removal excises exactly the block/pointer span and leaves the
surrounding bytes untouched. The `created` flags are now genuinely honoured: a file is
deleted only when rep created it **and** nothing else remains — a pre-existing file is
never deleted, even when emptied. Test 9 covers the round-trip with messy whitespace
using `git status --porcelain` (test 3's `$(cat)` comparison strips trailing newlines,
which is how this escaped).

Known residual corner: a pre-existing file with **no** final newline gains one on
round-trip (the appended separator cannot be distinguished from an original trailing
newline without recording extra state in the lock). Judged acceptable for v0.

### 3. `rep init`/`add` silently destroyed user content at `.claude/skills/<name>`

If the project had a real directory (e.g. its own skill) at `.claude/skills/audit`,
`createSkillSymlinks` did `rmSync(..., { recursive: true })` and replaced it with a
symlink. Confirmed live. Symmetrically, removal would recursively delete a
non-symlink at that path.

Fix: a pre-flight check refuses (before touching anything) when any target path
exists and is not a symlink; removal now only ever deletes symlinks. Test 10 covers
refusal + zero changes left behind.

## Smaller corrections

- `rep status` classified authored vs vendored standards/templates by asking the
  **running package** (`pkgStandards()`), not the lock — wrong whenever package and
  project versions diverge. Now derived from lock paths; the "Vendored:" counts now
  reflect the project, not the package.
- `init`/`add` validated skill names mid-vendoring, exiting with partial state (files
  copied, lock unwritten). Both now validate everything up front.
- `remove --all` deleted `.agents/base/` recursively (would take user files placed
  there) and left an empty `.agents/` behind (cleanup ran before the lock was
  deleted). Both fixed.
- Unused imports (`stderr`, `homedir`) and the unused `opts` parameter removed.

## Accepted deviations (not changed)

- `rep update` refuses the **whole** update on any drift rather than per-file
  (brief: "refuse for that file"). All-or-nothing is safer — partial vendoring plus a
  rebuilt lock would launder the drifted file's hash — and `--force` covers intent.
- The stance-block diff is a positional line diff, not a true unified diff. Noisy on
  insertions but serviceable for v0.
- Norm extraction requires the `---` separator as an exact `\n---\n`; setext headings
  or decorated rules would confuse it. All repo standards conform.

## Live smoke test — PASS

`rep init` in a scratch project, then a cold headless Claude Code session
(`claude -p`, haiku):

- Stance block reported active; operative norms named by title.
- All 4 vendored skills discoverable (symlink wiring works).
- Intent-language norm quoted verbatim from `AGENTS.md` (pointer import works).
- `rep status` clean.

Remaining from the receipt's "what to do next": stand repertoire up inside Station AI
(the real test), and a pi-session smoke test — neither runnable from this machine's
session; both Adam-triggered.
