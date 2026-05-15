# The ~/.agent/ Convention

This document specifies the `~/.agent/` directory convention. It is the contract that
`agent-core.sh` implements and that any harness adapter must respect.

---

## Purpose

`~/.agent/` is a harness-agnostic home for agent infrastructure. It belongs to the
user, not to any specific harness. Pi, Claude Code, Codex — all are consumers of
this directory. Nothing harness-specific lives here.

---

## Structure

```
~/.agent/
  base/           ← always loaded; no signal suppresses this
  prompts/        ← loaded every session unless local _replace/ is present
  skills/         ← skill paths; use symlinks to point at skill repos
  repos/          ← managed git clones (installed via install.sh or agent)
```

### base/

Loaded in every session regardless of project context. Use for infrastructure
instructions that must always be present — skill bootstrap, model context, anything
whose absence would break basic session behaviour. A symlink or copy of
`repertoire/base/bootstrap.md` belongs here.

Files load in alphabetical order. Numeric prefixes control order where it matters.

Subdirectories are ignored.

### prompts/

Loaded every session unless a local `.agent/prompts/_replace/` is present. Use for
character, behaviour, and context that applies globally but may legitimately vary
per project.

To deactivate a prompt, move it into any subdirectory. To activate it, move it back
to the top level. No scripts, no config — the filesystem is the configuration.

Files load in alphabetical order. Numeric prefixes control order.

Subdirectories (other than those named `_replace/` or `_append/` in a local context)
are inert library space.

### skills/

Skill paths loaded every session. Use symlinks to point at skill repo `skills/`
directories — changes to the source are immediately visible.

```bash
ln -s /path/to/repertoire/skills ~/.agent/skills/repertoire
```

### repos/

Git clones managed by `install.sh` or the `--update` mechanism. Each subdirectory
is a cloned repo. Symlinks in `base/`, `prompts/` (if any), and `skills/` point back
into here.

---

## Local overrides

A `.agent/` directory in a project repo modifies what loads for that project only.

```
.agent/
  prompts/
    _append/    ← files added to the global prompt set
    _replace/   ← files used instead of the global prompt set
  skills/       ← skill paths added to the global skill set (always additive)
```

### \_replace/ semantics

When `_replace/` is present:

- Global `prompts/` is skipped entirely
- Sibling `_append/` is also ignored
- `base/` still loads — it is immune to all local signals
- Local `skills/` still loads — skills are always additive

`_replace/` is an absolute declaration: "I know exactly what prompts this project
needs." If you also want additions, put them in `_replace/`.

### \_append/ semantics

When `_append/` is present without `_replace/`:

- Global `prompts/` loads first
- `_append/` files load after

If both are present, `agent-core.sh` warns and uses `_replace/` only.

---

## Harness adapters

A harness adapter is a thin script that sources `agent-core.sh`, provides
harness-specific inputs (model identity, settings file path), translates the
populated `APPENDS[]` and `SKILL_PATHS[]` arrays into harness flags, and execs the
harness.

See `bin/pid` for the pi adapter as a worked example. An adapter for any other
harness follows the same pattern: source core, collect, inject model, translate,
exec.

---

## Environment variables

| Variable          | Default    | Description                       |
| ----------------- | ---------- | --------------------------------- |
| `AGENT_DIR`       | `~/.agent` | Override the global agent root    |
| `LOCAL_AGENT_DIR` | `.agent`   | Override the local directory name |

Both are read by `agent-core.sh` and can be overridden before sourcing or via
`--agent-dir` / `--local-dir` flags.
