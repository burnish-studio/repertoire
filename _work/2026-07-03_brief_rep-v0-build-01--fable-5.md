---
type: context
title: Build Brief — rep v0
created: 2026-07-03
updated: 2026-07-03
status: current
model: fable-5
---

# Build Brief — rep v0

A complete, self-contained brief for building the `rep` CLI. The executor needs no
session context beyond this file and the repository it sits in. Where this brief is
precise, follow it exactly — the layout, lockfile, block format, and wiring below are
locked decisions (ADRs 0005–0008 in `.plan/adr/`), not suggestions. Where it is silent,
use ordinary engineering judgement.

## Context

Repertoire is "rational firmware" for agent projects: standards (normative positions),
skills (agent briefings), and templates (correct forms), plus the authoring skills to
create more of each inside a host project. `rep` is the deterministic delivery tool: it
vendors this repo's content into a consumer project, injects a stance block into the
project's context file, and manages update/removal via a lockfile. Glossary of terms
(Vendored, Authored, Lock, Stance block, Norm compilation, Pointer, Tree): `CONTEXT.md`
at the repo root.

## Deliverables

1. `package.json` — name `repertoire`, `"type": "module"`, `"bin": { "rep": "./bin/rep.mjs" }`,
   Node `>=20`. No dependencies. No npm publishing.
2. `bin/rep.mjs` — the entire tool, one file, plain modern JS. Allowed imports:
   `node:fs`, `node:path`, `node:crypto`, `node:child_process`, `node:process`,
   `node:url`, `node:os`. `git` may be shelled out to. Nothing else.
3. `test/rep-test.sh` — bash acceptance script (see Acceptance below), runnable with no
   arguments from the repo root, exiting non-zero on any failure.

POSIX only for v0; Windows is out of scope.

## Source of content

`rep` vendors from **its own package directory** (resolve via `import.meta.url`) — the
tool ships inside the content repo, so the running package *is* the content version
(ADR-0008). Record in the lock a best-effort `ref`: `gitHead` from package.json if
present, else the output of `git rev-parse HEAD` if the package dir is a git checkout,
else `"unknown"`. The per-file hashes are the authoritative identity either way.

## The project tree rep creates (ADR-0006)

```
project/
├─ .agents/
│  ├─ skills/<name>/            ← vendored skill dirs (whole dir incl. references/, scripts/)
│  ├─ standards/<name>/         ← ALL standards — an indivisible set
│  ├─ templates/<name>/         ← all templates
│  ├─ base/bootstrap.md         ← firmware preamble source
│  └─ repertoire.lock
├─ .claude/skills/<name> → ../../.agents/skills/<name>   ← relative symlink per skill
├─ AGENTS.md                    ← carries the stance block
└─ CLAUDE.md                    ← contains the line `@AGENTS.md`
```

Vendored and authored artefacts share this tree; **rep touches only paths listed in the
lock, plus the block between its own markers.** Everything else is the project's and
must never be modified or deleted. Both Claude Code wirings (the `@AGENTS.md` pointer
and the relative skill symlinks) were verified working empirically on 2026-07-03; do
not redesign them.

## The lockfile — `.agents/repertoire.lock`

JSON, modelled on the `skills` CLI's lock (a copy sits at `skills-lock.json` in this
repo root for reference, gitignored). Exact shape:

```json
{
  "version": 1,
  "source": "github:burnish-studio/repertoire",
  "ref": "<sha or 'unknown'>",
  "skills": ["write-a-skill", "write-a-standard", "codify", "audit"],
  "files": {
    ".agents/skills/write-a-skill/SKILL.md": "<sha256 hex>",
    ".agents/standards/fallibilism/STANDARD.md": "<sha256 hex>",
    ".agents/base/bootstrap.md": "<sha256 hex>"
  },
  "wiring": {
    "stance": { "file": "AGENTS.md", "created": true },
    "pointers": [ { "file": "CLAUDE.md", "created": false } ],
    "symlinks": [ ".claude/skills/write-a-skill" ]
  }
}
```

`files` lists every vendored file with its content hash. `created` records whether rep
created that file or only added its line/block to a pre-existing one — removal honours
this (delete the file only if rep created it and nothing else remains in it).

## The stance block (ADR-0007)

One marker-delimited block in `AGENTS.md`, created or replaced as a unit; user content
outside the markers is never touched. Format:

```markdown
<!-- repertoire:start -->
<contents of .agents/base/bootstrap.md>

## Operative norms

### <standard title>
<extracted norm>

### <next standard title>
...
<!-- repertoire:end -->
```

**Norm extraction rule (locked):** from each `.agents/standards/*/STANDARD.md` —
vendored *and* authored alike — strip YAML frontmatter, the `# h1` line, and any
`_Perspective: …_` line; the norm is the remaining body **above the first `---` line**;
if the body contains no `---`, the whole remaining body is the norm. Extraction is
verbatim — never summarise or rephrase. Standard title comes from frontmatter `title:`,
falling back to the h1 text.

## Command surface

- `rep init [--skills a,b,c | --all-skills]` — create the tree; vendor all standards,
  all templates, `base/bootstrap.md`, and the selected skills (default:
  `write-a-skill, write-a-standard, codify, audit`); compile and inject the stance
  block; write the `CLAUDE.md` pointer line (append if the file exists without it);
  create `.claude/skills` symlinks; write the lock. Refuse with a clear message if a
  lock already exists.
- `rep add <skill>…` / `rep remove <skill>…` — vendor or remove individual skills
  (dir + symlink + lock entries). `remove` refuses names not in the lock's `skills`
  list (never deletes authored skills).
- `rep remove --all` — reverse init: delete every lock-listed file and symlink, delete
  the stance block between markers, remove the pointer line, honour every `created`
  flag, remove now-empty directories rep created, delete the lock last.
- `rep update` — re-vendor every lock-listed file from the running package, recompile
  the stance block, rewrite lock hashes/ref. Before overwriting, diff hashes: if a
  vendored file was hand-edited (drift), refuse for that file and report, unless
  `--force`. Print a unified diff of the old vs new stance block — this is the
  human-reviewable record that the project's operative stance changed.
- `rep compile` — recompile the stance block only, from all standards currently in
  `.agents/standards/` (this is how an authored standard's norm enters the block).
- `rep status` — verify every lock-listed file's hash, symlink resolution, block
  presence and freshness (does a recompile match what's in `AGENTS.md`?), pointer
  presence; list drifted/missing items; count authored artefacts. Exit non-zero if
  anything is wrong.

Every command must be idempotent where re-running makes sense, narrate what it did in
a few plain lines, and never write outside the project directory.

## Acceptance — `test/rep-test.sh`

Run everything in a `mktemp -d` sandbox project that is `git init`-ed and committed
empty, invoking the local checkout's `bin/rep.mjs` directly. Assert at least:

1. **init**: tree exists as specified; lock is valid JSON with correct hashes
   (recompute and compare); `AGENTS.md` has exactly one marker block containing the
   bootstrap text and one `###` section per standard; `CLAUDE.md` contains the
   `@AGENTS.md` line; every `.claude/skills` symlink resolves.
2. **pre-existing files survive**: with a project that already has `AGENTS.md` and
   `CLAUDE.md` containing user content, init appends (block/pointer) and
   `remove --all` restores both files **byte-identical**.
3. **add/remove round-trip** for one skill.
4. **drift**: hand-edit a vendored file → `status` exits non-zero naming it; `update`
   refuses without `--force`.
5. **authored norm**: create `.agents/standards/test-local/STANDARD.md` with
   frontmatter, an h1, a one-line norm, `---`, and a thesis → `compile` puts exactly
   that line into the block; `remove --all` leaves the authored standard in place.
6. **byte-clean removal**: after `remove --all` in the fresh-project case,
   `git status --porcelain` is empty.

## Out of scope for v0

Windows; npm publish; pinning to arbitrary refs in `update` (updating = running a newer
package); any harness beyond the AGENTS.md convention + Claude Code; interactivity
(rep is non-interactive — the conversational layer is the agent driving it).

## Style

Match the repo's tone in user-facing strings (plain, direct, UK English). Small
functions, no cleverness. The code will be reviewed against this brief line by line.
