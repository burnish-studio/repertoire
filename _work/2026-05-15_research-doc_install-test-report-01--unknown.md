---
type: research-doc
title: Setup Repertoire — First Installation Test Run Report
created: 2026-05-15
updated: 2026-05-15
status: current
model: unknown
---

# Setup Repertoire — First Installation Test Run Report

This report covers the first real-world test of the `setup-repertoire` skill, where
installation was delegated to an agent (pi, Claude Sonnet 4.6) operating in its own
environment. The goal was to assess how much of the harness wiring the skill could
successfully outsource to the agent, and where it broke down.

---

## Environment

- **Machine:** Linux Fedora, x86_64
- **Shell:** fish (not bash)
- **Harness:** pi (`~/.pi/agent/` config dir, launched via pnpm)
- **Pre-existing state:** No `~/.agent/` directory, no repo clone, no `~/bin`

---

## What Worked Well

### Skill structure and framing
The skill document was well-structured. The agent read and followed it in sequence
without getting lost. The capabilities check, assessment phase, and plan-before-acting
pattern all worked as intended — the agent surfaced a coherent plan before touching
anything and waited for confirmation.

### `pid --doctor` as a verification tool
This was the single most useful part of the whole process. Once the agent ran
`pid --doctor`, it immediately had a concrete, unambiguous view of what was and
wasn't loading. Problems became visible rather than speculative. This pattern should
be preserved and leaned into further.

### Symlink approach
The agent correctly understood and executed the symlink strategy — repo cloned once,
everything else pointing into it. No files were copied. This part required no
correction.

### End-state framing
Defining setup as "three things must be true" (bootstrap loads, skills visible,
verification passes) gave the agent a clear target to work toward rather than a
checklist to execute blindly. It re-checked against this target after each step.

### Harness knowledge
The agent correctly identified pi's `--append-system-prompt` and `--skill` flags,
understood how `pid` wraps them, and knew where pi's settings live
(`~/.pi/agent/settings.json`). No guessing was needed here.

---

## What Didn't Work

### 1. Wrong branch in the skill URL — immediate 404

**What happened:** The SKILL.md URL given to the user used `main` as the branch, but
the repository's default branch is `master`. The first `curl` returned a 404.

**Agent recovery:** The agent fetched the GitHub API to inspect the repo, discovered
`"default_branch": "master"`, and retried with the correct URL. Recovery was
successful but took two extra tool calls and added friction at the very start.

**Recommendation:** Fix the URL in the skill to use `master`, or switch the repo's
default branch to `main`. Also consider adding a branch-detection step early in the
skill, or hosting a redirect.

---

### 2. `find -type f` does not follow symlinks — bootstrap silently did not load

**What happened:** `agent-core.sh`'s `_collect_dir` function uses:
```bash
find "$dir" -maxdepth 1 -type f -name '*.md' -print0 | sort -z
```
Without the `-L` flag, `find` does not dereference symlinks. Since
`~/.agent/base/bootstrap.md` is a symlink (as the skill instructs), it has type `l`
not `f`, and is silently skipped. The first `pid --doctor` run showed:
```
│ appends: (none)
```
despite the symlink being correctly in place and resolving correctly.

**Agent recovery:** The agent diagnosed the issue (tested `find` with and without
`-L`), identified it as a bug, and patched `agent-core.sh` in the clone:
```bash
find -L "$dir" -maxdepth 1 -type f -name '*.md' -print0 | sort -z
```
After the fix, `pid --doctor` correctly showed bootstrap loading.

**This is a genuine bug in `agent-core.sh`.** The skill explicitly instructs the use
of symlinks for `~/.agent/base/`, but the code that reads that directory does not
handle symlinks. These two are in direct contradiction. The fix is one character
(`-L`). It should be applied to the repo directly.

**Note:** This bug would affect anyone following the setup instructions on any
Unix/Mac system, not just this test run.

---

### 3. `~/bin` PATH guidance assumes bash — machine was using fish

**What happened:** The decision table in the skill recommends:
```
Add `export PATH="$HOME/bin:$PATH"` to `.bashrc` — do it now
```
This syntax is bash-specific and would not work in a fish config. The machine's shell
was fish (`/usr/bin/fish`), which uses a completely different syntax:
```fish
fish_add_path $HOME/bin
```

**Agent recovery:** The agent detected the fish shell during environment assessment
(`echo $SHELL` returned `/usr/bin/fish`) and applied the correct fish idiom
(`fish_add_path`) to `~/.config/fish/config.fish` without needing to be told. The
bash example in the skill was not followed literally.

**Recommendation:** The skill's PATH section should either:
- Give shell-specific examples (bash/zsh: `export PATH=...` in `.bashrc`/`.zshrc`;
  fish: `fish_add_path $HOME/bin` in `config.fish`), or
- State the intent generically ("add `~/bin` to PATH using the appropriate method for
  your shell") and trust the agent to apply the right idiom.

The current bash-only example could mislead a less capable agent into writing
bash syntax into a fish config.

---

### 4. Duplicate skills path in `pid --doctor` output

**What happened:** Running `pid` from the home directory (`~`) produces:
```
│ skills (2):
│   01. /home/alex/.agent/skills
│   02. /home/alex/.agent/skills
```
The global skills dir is `$AGENT_DIR/skills` = `~/.agent/skills`.
The local skills dir is `$PWD/$LOCAL_AGENT_DIR/skills` = `~/.agent/skills` (same
path, because `PWD` is `~` and `LOCAL_AGENT_DIR` defaults to `.agent`).

**Impact:** Benign — pi deduplicates skill discovery internally, and in normal use
`pid` is run from a project directory, not `~`. But the output looks wrong and could
confuse users during verification.

**Recommendation:** `agent-core.sh` should deduplicate `SKILL_PATHS` before output,
or skip adding `LOCAL_SKILLS_DIR` when it resolves to the same path as `SKILLS_DIR`.

---

## Process Length Assessment

The installation took longer than it should have, primarily due to:

1. The branch mismatch (2 extra round-trips before even reading the skill)
2. The `find -L` bug (diagnosis + fix added 3–4 extra tool calls)
3. Shell detection adding a small amount of conditional reasoning

Without those two bugs, the process would have been: read skill → assess environment
→ confirm plan → run 5 shell commands → verify. That's a fast, clean installation.
The length was bug-driven, not structure-driven. The skill's structure itself was not
the problem.

---

## Summary of Actionable Issues

| # | Issue | Severity | Fix |
|---|-------|----------|-----|
| 1 | `main` branch in skill URL returns 404 | High — breaks entry point | Change URL to `master` or fix default branch |
| 2 | `find -type f` misses symlinks in `agent-core.sh` | High — bootstrap silently doesn't load | Add `-L` flag to `find` in `_collect_dir` |
| 3 | PATH guidance is bash-only | Medium — wrong for fish/zsh users | Make shell-agnostic or add per-shell examples |
| 4 | Duplicate skills path when run from `~` | Low — cosmetic/confusing | Deduplicate `SKILL_PATHS` in `agent-core.sh` |

---

## What the Agent Did Well (process observations)

- Did not proceed past the capabilities check without verifying all three conditions
- Presented a clear plan and waited for explicit confirmation before acting
- Narrated each step as it executed
- Used `pid --doctor` proactively to verify state (not just declared "done")
- Correctly identified and fixed a bug rather than declaring the failure unexplained
- Applied fish-specific PATH syntax without being prompted

The outsourcing model — letting the agent handle harness-specific wiring — worked.
The agent had enough knowledge of pi's internals to complete the job. The failures
were in the source material (the skill doc and the repo code), not in the agent's
execution.
