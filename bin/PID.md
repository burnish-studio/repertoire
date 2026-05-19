---
type: context
title: pid — Pi Launcher Guide
created: 2026-05-19
updated: 2026-05-19
status: current
model: sonnet-4-6
---

# pid — Pi Launcher Guide

`pid` is a bash wrapper around the `pi` CLI that implements the `~/.agent/` convention: a
structured directory layout for system prompts, identity layers, and skills that are
automatically composed and injected every time you start a session.

`~/bin/pid` is a symlink to this file's sibling: `repertoire/bin/pid`.

---

## Quick start

```bash
pid                        # launch pi with full ~/.agent/ stack loaded
pid "your task here"       # pass a prompt directly
pid --doctor               # inspect what would be loaded (first 3 lines each)
pid --verify               # dump full content of every loaded file
pid --update               # check for updates to managed repos
```

---

## How it works

### The two files

| File                | Role                                                                                             |
| ------------------- | ------------------------------------------------------------------------------------------------ |
| `bin/pid`           | Pi-specific adapter — reads model from `~/.pi/settings.json`, builds `pi` flags, calls `exec pi` |
| `bin/agent-core.sh` | Harness-agnostic library — arg parsing, file collection, model injection, manifest printing      |

`pid` sources `agent-core.sh` at runtime using `readlink -f` to resolve the real path of
the script, so the symlink in `~/bin/` works correctly.

---

### The `~/.agent/` directory layout

```
~/.agent/
├── base/           ← always loaded, unconditionally (e.g. bootstrap.md)
├── prompts/        ← global system prompt layers (loaded unless overridden locally)
│   ├── 01-runtime.md
│   ├── 02-layer-1.md
│   ├── 03-layer-2.md
│   └── 04-layer-3.md
├── skills/         ← global skill directories passed to pi --skill
└── repos/          ← git repos managed by --update (one subdirectory per repo)
```

Files in `base/` and `prompts/` are sorted alphabetically before loading — use numeric
prefixes to control order.

### Local `.agent/` override (per project)

In any working directory you can place a `.agent/` folder:

```
.agent/
├── prompts/
│   ├── _replace/   ← if present, replaces ~/.agent/prompts/ entirely
│   └── _append/    ← if present, appended after ~/.agent/prompts/
└── skills/         ← project-local skills, always additive
```

Rules:

- `_replace/` and `_append/` are mutually exclusive — if both exist, `_replace/` wins and
  a warning is printed.
- Skills are always additive; local skills are appended after global skills.

---

### What gets loaded — loading order

When you run `pid`, the following is assembled in order:

1. **Model context** (temp file) — injected first so the agent always knows what model it's
   running on. Read from `~/.pi/settings.json` → `defaultModel`.
2. **`~/.agent/base/`** — unconditional bootstrap files (e.g. skills instructions).
3. **Prompts** — one of three modes:
   - `global` — `~/.agent/prompts/` only (default)
   - `replace (local)` — `.agent/prompts/_replace/` instead of global
   - `global + append (local)` — global first, then `.agent/prompts/_append/`
4. **Skills** — `~/.agent/skills/` then `.agent/skills/` (if present)

The manifest printed at launch shows exactly what was loaded and which mode is active.

---

### The manifest

Every invocation prints a manifest before handing off to `pi`:

```
┌─ pid ──────────────────────────────────────────
│ cwd:     /home/adam/my-project
│ prompts: global
│ model:   claude-sonnet-4-5 (sonnet-4-5)
│
│ appends (5):
│   01. /tmp/agent-model-XXXX.md
│   02. /home/adam/.agent/base/bootstrap.md
│   03. /home/adam/.agent/prompts/01-runtime.md
│   04. /home/adam/.agent/prompts/02-layer-1.md
│   ...
│
│ skills (1):
│   01. /home/adam/.agent/skills
└─────────────────────────────────────────────────────
```

This is purely informational — `pi` receives the files, not this output.

---

### How pi receives everything

After collecting, `pid` builds the `pi` invocation like this:

```bash
exec pi \
  --no-context-files \
  --append-system-prompt <file1> \
  --append-system-prompt <file2> \
  ... \
  --skill <skills-dir> \
  [your passthrough args]
```

- `--no-context-files` suppresses pi's default project file discovery.
- Each collected file becomes its own `--append-system-prompt` argument.
- Each skill directory becomes a `--skill` argument.

---

## CLI flags

These are consumed by `pid`/`agent-core.sh` and do **not** pass through to `pi`:

| Flag                 | Effect                                              |
| -------------------- | --------------------------------------------------- |
| `--no-global`        | Skip `~/.agent/prompts/` and `~/.agent/skills/`     |
| `--no-local`         | Skip `.agent/` in the current working directory     |
| `--no-skills`        | Skip all skill directories                          |
| `--doctor`           | Print first 3 lines of every loaded file, then exit |
| `--verify`           | Dump full content of every loaded file, then exit   |
| `--update`           | Interactively update all repos in `~/.agent/repos/` |
| `--agent-dir <path>` | Override global agent dir (default: `~/.agent`)     |
| `--local-dir <name>` | Override local dir name (default: `.agent`)         |
| `--`                 | Everything after this passes directly to `pi`       |

Everything else is passed through to `pi` as-is.

---

## Model injection

`pid` reads `~/.pi/settings.json` and extracts `defaultModel`. It then:

1. Creates a temp file at `/tmp/agent-model-XXXX.md` containing:
   ```
   Your current model is **claude-sonnet-4-5** (short form: `sonnet-4-5`).
   ```
2. Prepends it to the appends list so it's the first thing in the system prompt.
3. Registers a `trap` to delete the temp file on exit.

The short form is derived by stripping the `claude-` prefix and replacing `.` with `-`.
It's used in frontmatter and filenames by skills that generate output files.

---

## The `--update` workflow

`--update` iterates over every subdirectory of `~/.agent/repos/` that contains a `.git`
folder. For each:

1. Runs `git fetch`
2. Compares current `HEAD` to `FETCH_HEAD`
3. If behind, shows a diff summary (added/modified/deleted files)
4. Prompts `[y/N]` — if confirmed, runs `git pull --ff-only`

This lets you keep managed prompt repos (e.g. `repertoire`) up to date without leaving
the terminal.

```bash
pid --update
```

---

## Your current prompt stack

These are the files loaded into every session (from `~/.agent/`):

| File                    | Purpose                                                               |
| ----------------------- | --------------------------------------------------------------------- |
| `base/bootstrap.md`     | Skills behaviour — load SKILL.md on demand, announce usage            |
| `prompts/01-runtime.md` | Operating mode — high-agency, pragmatic, concise, outcome-first       |
| `prompts/02-layer-1.md` | Axioms — epistemic contract, error-correction, clarity as honesty     |
| `prompts/03-layer-2.md` | Identity declaratives — analytic character, no softening              |
| `prompts/04-layer-3.md` | Directives — failure modes, push to conclusion, give a recommendation |

---

## Per-project usage patterns

### Append project context without replacing globals

```
my-project/
└── .agent/
    └── prompts/
        └── _append/
            └── 01-project.md   ← appended after global stack
```

### Replace the entire prompt stack for a specialised agent

```
my-project/
└── .agent/
    └── prompts/
        └── _replace/
            └── 01-system.md    ← replaces ~/.agent/prompts/ entirely
```

### Add project-local skills

```
my-project/
└── .agent/
    └── skills/
        └── my-skill/
            └── SKILL.md
```

### Run without any global context (fully local)

```bash
pid --no-global
```

---

## Debugging

```bash
# See what files would be loaded and their first 3 lines
pid --doctor

# See the full content of every file in the stack
pid --verify

# Run with no local overrides
pid --no-local

# Run with no skills at all
pid --no-skills
```

---

## File locations

| Path                                              | Description                                   |
| ------------------------------------------------- | --------------------------------------------- |
| `~/bin/pid`                                       | Symlink → `repertoire/bin/pid`                |
| `~/burnish-projects/repertoire/bin/pid`           | The actual launcher script                    |
| `~/burnish-projects/repertoire/bin/agent-core.sh` | Shared core library                           |
| `~/.agent/`                                       | Global agent directory                        |
| `~/.pi/settings.json`                             | Pi settings — `defaultModel` read from here   |
| `.agent/`                                         | Per-project local overrides (relative to cwd) |
