# pid — Reference

`pid` is the pi adapter for the `~/.agent/` convention. It sources `bin/agent-core.sh`
for all harness-agnostic logic and handles only the pi-specific translation.

For setup instructions, see [`skills/setup-repertoire/SKILL.md`](../skills/setup-repertoire/SKILL.md).
For the full convention spec, see [`docs/agent-dir.md`](agent-dir.md).

---

## What pid does

1. Sources `bin/agent-core.sh`
2. Parses flags (all delegated to the core)
3. Reads model from `~/.pi/settings.json` and injects it into session context
4. Translates `APPENDS[]` and `SKILL_PATHS[]` into pi flags
5. Executes `pi --no-context-files [--append-system-prompt ...] [--skill ...]`

The only pi-specific knowledge in pid: where to find the model name, and which flags
pi accepts.

---

## Flags

| Flag          | Description                                        |
| ------------- | -------------------------------------------------- |
| `--no-global` | Skip `~/.agent/prompts/` (base still loads)        |
| `--no-local`  | Skip `.agent/` in current directory                |
| `--no-skills` | Skip all skill path injection                      |
| `--agent-dir` | Override `~/.agent/` root                          |
| `--local-dir` | Override `.agent` local directory name             |
| `--doctor`    | Print first 3 lines of each loaded file, then exit |
| `--verify`    | Print full content of all loaded files, then exit  |
| `--update`    | Check managed repos for updates; prompt per repo   |

Flags after `--` are passed directly to pi.

---

## Environment variables

| Variable          | Default    | Description                       |
| ----------------- | ---------- | --------------------------------- |
| `AGENT_DIR`       | `~/.agent` | Override the global agent root    |
| `LOCAL_AGENT_DIR` | `.agent`   | Override the local directory name |

---

## Writing an adapter for another harness

`bin/agent-core.sh` handles everything except the harness-specific translation. To
write an adapter for Claude Code, Codex, or another harness:

1. Source `agent-core.sh`
2. Call `agent_parse_args "$@"`
3. Handle `--update` if needed: `[[ "$UPDATE" -eq 1 ]] && agent_update && exit 0`
4. Call `agent_collect`
5. Read the model from your harness's config; call `agent_inject_model "$raw" "$short"`
6. Set trap: `trap 'rm -f "${AGENT_MODEL_TMPFILE:-}"' EXIT`
7. Call `agent_print_manifest "your-harness-name"`
8. Handle `--doctor` and `--verify`
9. Translate `APPENDS[]` → `--append-system-prompt` equivalent for your harness
10. Translate `SKILL_PATHS[]` → `--skill` equivalent for your harness
11. `exec your-harness "${HARNESS_ARGS[@]}" "${USER_ARGS[@]}"`

See `bin/pid` as the worked example. A typical adapter is 40–50 lines.
