---
type: skill
title: Teardown Repertoire
name: teardown-repertoire
description: Use when asked to uninstall, remove, or tear down repertoire from this machine. Reads the install manifest and reverses every change setup made — clone, symlinks, PATH edits, harness wiring — interactively, confirming before each removal.
created: 2026-07-01
updated: 2026-07-01
status: current
model: claude-opus-4-8
---

# Teardown Repertoire

_Perspective: [standards/perspective/STANDARD.md](../../standards/perspective/STANDARD.md)_

Teardown removes a repertoire installation by reversing exactly what setup did. It is
the counterpart to [setup-repertoire](../setup-repertoire/SKILL.md): setup writes an
install manifest recording every change it made; teardown reads that manifest and
walks each change back. The manifest is the source of truth — teardown removes what is
listed and nothing else.

---

## Capabilities check — do this first

Before anything else, confirm:

1. You can read and write files on the local file system
2. You can execute shell commands

If either fails, stop and tell the user this must be run from an agent with file
system access and shell execution. You must not attempt a partial teardown.

---

## Find the manifest

The manifest lives at `~/.agent/install-manifest.md`. Read it in full before acting.

**If the manifest is missing**, do not guess at what to remove. Tell the user:

> "No install manifest was found at `~/.agent/install-manifest.md`, so I cannot know
> exactly what the installation changed. I can reconstruct the likely changes by
> inspecting the system (the `~/.agent/` structure, `~/bin/pid`, shell config, and
> harness settings) and show you each one for confirmation before removing anything —
> or you can point me at the manifest if it lives elsewhere."

Only proceed with reconstruction if the user agrees, and treat every reconstructed
item as unconfirmed until the user approves it. A missing manifest means more caution,
not less.

---

## The one rule

Remove only what the manifest records. Anything not in the manifest was pre-existing
and must not be touched. If `~/.agent/` held content before repertoire was installed,
that content stays. When in doubt about whether setup created something, leave it and
say so.

---

## Present the teardown plan

Do not remove anything silently. After reading the manifest, present:

- What the manifest says was installed, grouped as it is written (symlinks, clone,
  directories, PATH edits, harness wiring)
- What you will remove, in plain terms
- Anything you will deliberately leave, and why (pre-existing dirs, unrelated content,
  a manifest entry that no longer matches the system)

Ask: "Shall I proceed with removing these, or would you like to keep any of them?"

You must wait for confirmation before removing anything.

---

## Reverse in safe order

Undo changes in the reverse of the order they weaken the system, so nothing is left
dangling mid-teardown. Narrate each step.

1. **Harness wiring** — undo the config edits first, so no session tries to load
   repertoire content that is about to disappear. Reverse exactly the edit the
   manifest records (remove the added skills path, the appended line, etc.). Leave the
   rest of the config file untouched.

2. **PATH / shell config** — remove the exact line the manifest records from the shell
   config file. If the line is not present (already removed, or hand-edited), say so
   and move on — do not delete anything else.

3. **Symlinks** — remove each recorded symlink (`~/.agent/base/bootstrap.md`,
   `~/.agent/skills/repertoire`, `~/bin/pid`). Verify each is a symlink pointing into
   the repo before removing it; if a path is a real file or points elsewhere, stop and
   flag it rather than deleting.

4. **Repository clone** — remove `~/.agent/repos/repertoire/`. This is the git clone;
   confirm it is the recorded path before `rm -rf`.

5. **Directories** — remove only directories the manifest records as *created by
   setup*, and only if now empty. If `~/.agent/` or `~/bin/` still holds other content,
   leave it and tell the user what remains.

6. **The manifest itself** — remove `~/.agent/install-manifest.md` last, once
   everything it records is gone.

```
→ Removing harness wiring (skills path in ~/.claude/settings.json)... done
→ Removing PATH line from ~/.bashrc... done
→ Removing symlink ~/.agent/base/bootstrap.md... done
→ Removing symlink ~/.agent/skills/repertoire... done
→ Removing symlink ~/bin/pid... done
→ Removing clone ~/.agent/repos/repertoire/... done
→ Removing ~/.agent/ (now empty)... done
→ Removing install manifest... done
```

---

## Verification

You must not declare teardown complete until you have confirmed the removals. Check:

- The recorded symlinks no longer exist
- The clone directory is gone
- The PATH line is absent from the shell config
- The harness no longer references repertoire (run `pid --doctor` if pid was present
  and still is elsewhere; otherwise inspect the harness config)
- Any directory you left in place is reported to the user with what remains in it

---

## End of teardown

Summarise in three to five lines: what was removed, what was deliberately left and
why, and any manual step the user should take (e.g. open a new shell so the PATH change
takes effect, or restart the harness). If everything reversed cleanly, say so and stop.
Do not pad.
