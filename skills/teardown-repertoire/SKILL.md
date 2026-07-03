---
type: skill
title: Teardown Repertoire
name: teardown-repertoire
description: Use when asked to uninstall, remove, or tear down repertoire from this machine. Reads the install manifest and reverses every change setup made — per harness adapter then the shared core — interactively, confirming before each removal and removing only what the manifest records.
created: 2026-07-01
updated: 2026-07-03
status: current
model: claude-opus-4-8
---

# Teardown Repertoire

_Perspective: [standards/perspective/STANDARD.md](../../standards/perspective/STANDARD.md)_

Teardown removes a repertoire installation by reversing exactly what setup did. It is the
counterpart to [setup-repertoire](../setup-repertoire/SKILL.md): setup writes an install
manifest recording every change it made; teardown reads that manifest and walks each change
back. The manifest is the source of truth — teardown removes what is listed and nothing
else. Setup is a creative forward act; teardown is a replay. It cannot re-improvise, only
reverse the record — so it is only ever as safe as the manifest is precise.

---

## Capabilities check — do this first

Confirm you can read and write files on the local file system and execute shell commands.
If either fails, stop and tell the user this must be run from an agent with file system
access and shell execution. Do not attempt a partial teardown.

---

## Find and read the manifest

The manifest lives at `~/.agent/install-manifest.md`. Read it in full before acting. Its
shape is **Core rows plus one section per Adapter** (one per harness wired). You will
reverse the adapters first, then the shared Core.

**If the manifest is missing**, do not guess. Tell the user:

> "No install manifest was found at `~/.agent/install-manifest.md`, so I cannot know exactly
> what the installation changed. I can reconstruct the likely changes by inspecting the
> system (the `~/.agent/` structure, `~/bin/pid`, shell config, and each harness's config)
> and show you each for confirmation before removing anything — or you can point me at the
> manifest if it lives elsewhere."

Only reconstruct if the user agrees, and treat every reconstructed item as unconfirmed until
approved. A missing manifest means more caution, not less.

---

## The one rule

Remove only what the manifest records. Anything not in the manifest was pre-existing and
must not be touched. Every entry carries a pre-existence flag; honour it. If a directory,
clone, or shared file is marked as pre-existing, it stays. When in doubt about whether setup
created something, leave it and say so.

---

## Present the teardown plan

Do not remove anything silently. After reading the manifest, present:

- Each Adapter and what it wired, and the Core, grouped as the manifest is written.
- What you will remove, in plain terms.
- Anything you will deliberately leave, and why — pre-existing dirs, a shared file the user
  owns (you remove only your marker block from it), an entry that no longer matches reality.

Ask: "Shall I proceed with removing these, or would you like to keep any of them?" Wait for
confirmation before removing anything.

---

## Reverse each Adapter, then the Core

Undo the harness adapters first — so no session tries to load Core content that is about to
disappear — then remove the shared Core last. Narrate each step.

### For each Adapter section

- **Edited shared file** (e.g. the marker block in `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`):
  delete only the block between `<!-- repertoire:start -->` and `<!-- repertoire:end -->`,
  markers included. Leave the rest of the file exactly as it is. Then honour the
  pre-existence flag: if the manifest says the file pre-existed, keep it even if now empty;
  only if setup created the file *and* it is now empty may you remove it.
- **Symlinks** (`~/bin/pid`, `~/.claude/skills/repertoire-*`): verify each is a symlink
  pointing into the Core before removing it. If a path is a real file or points elsewhere,
  stop and flag it rather than deleting.
- **PATH / shell config**: remove the exact line the manifest records from the exact file.
  If the line is absent (already removed, or hand-edited), say so and move on — delete
  nothing else.
- **Launcher-only entries** (pid's "bootstrap + skills satisfied at launch; no static edit"):
  nothing to reverse beyond the pid symlink and PATH line already handled.

### Then the Core

1. **Symlinks** — remove the recorded core symlinks (`~/.agent/base/bootstrap.md`,
   `~/.agent/skills/repertoire`). Verify each points into the clone before removing.
2. **Repository clone** — remove `~/.agent/repos/repertoire/` (confirm the recorded path
   before `rm -rf`), unless the manifest marks it as pre-existing.
3. **Directories** — remove only directories the manifest records as *created by setup*, and
   only if now empty. If `~/.agent/` or `~/bin/` still holds other content, leave it and say
   what remains.
4. **The manifest itself** — remove `~/.agent/install-manifest.md` last, once everything it
   records is gone.

```
→ Adapter claude-code: removing marker block from ~/.claude/CLAUDE.md (file pre-existed, kept)... done
→ Adapter claude-code: removing 5 skill symlinks from ~/.claude/skills/... done
→ Adapter pi: removing symlink ~/bin/pid... done
→ Adapter pi: removing PATH line from ~/.bashrc... done
→ Core: removing symlinks ~/.agent/base/bootstrap.md, ~/.agent/skills/repertoire... done
→ Core: removing clone ~/.agent/repos/repertoire/... done
→ Core: removing ~/.agent/ (now empty)... done
→ Removing install manifest... done
```

---

## Verification

Do not declare teardown complete until you have confirmed the removals. Check:

- Each recorded symlink no longer exists.
- Each edited shared file no longer contains the marker block (and the user's own content is
  intact); any file you kept is reported with why.
- The clone directory is gone (unless it was pre-existing).
- The PATH line is absent from the shell config.
- No harness still references repertoire — inspect each wired harness's config; run
  `pid --doctor` only if pid still exists elsewhere.
- Any directory left in place is reported to the user with what remains in it.

---

## End of teardown

Summarise in three to five lines: what was removed per adapter and for the Core, what was
deliberately left and why, and any manual step (open a new shell so the PATH change takes
effect, restart the harness). If everything reversed cleanly, say so and stop. Do not pad.
