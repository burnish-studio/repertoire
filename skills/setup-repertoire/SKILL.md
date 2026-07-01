---
type: skill
title: Setup Repertoire
name: setup-repertoire
description: Use when asked to install, set up, or configure repertoire on this machine. Guides through the complete interactive setup process for any harness and operating system.
created: 2026-05-13
updated: 2026-05-15
status: current
model: sonnet-4-6
---

# Setup Repertoire

_Perspective: [standards/perspective/STANDARD.md](../../standards/perspective/STANDARD.md)_

Repertoire is a collection of agent skills, standards, and templates delivered as a
git repository. Setup means cloning it, establishing the `~/.agent/` structure, and
wiring it into the active harness so that bootstrap and skills load in every future
session.

---

## Capabilities check — do this first

Before anything else, confirm:

1. You can read and write files on the local file system
2. You can execute shell commands
3. `git` is available

If any of these fail, stop immediately and tell the user:

> "This agent lacks the capabilities needed to install repertoire — file system
> access and shell execution are both required. Run this setup from an agent with
> full tool access (pi, Claude Code, Cursor with terminal, or equivalent). A
> web-only agent cannot complete this installation."

You must not proceed past this point. You must not attempt partial setup.

---

## Environment assessment

Establish before presenting a plan:

- **Harness** — what agent harness is this session running in?
- **OS and shell** — Linux/Mac/Windows (WSL?); bash/zsh/other
- **Existing `~/.agent/` directory** — does it exist? What's in it?
- **Existing repo clone** — is repertoire already cloned somewhere?
- **`~/bin` on PATH** — relevant for pi/Unix users only

---

## The end state

Three things must be true when setup is complete:

1. **Bootstrap loads in every session** — `~/.agent/base/bootstrap.md` exists (as a
   symlink to the repo) and the harness is configured to load it globally
2. **Skills are visible** — `~/.agent/skills/repertoire/` exists (symlink to repo's
   `skills/`) and the harness registers it as a skill source
3. **Verification passes** — a new session shows the skills listed and the bootstrap
   instruction active

How to achieve this is harness-specific. You know how your harness loads global
context and discovers skills — apply that knowledge to reach this end state.
Consult `bin/agent-core.sh` and `bin/pid` in the cloned repo for the pi/Unix
reference implementation.

---

## The setup conversation

Present a plan before doing anything. Do not execute silently.

**After assessment, present:**

- What you found (harness, OS, whether repo already exists)
- What you are about to do, in plain terms
- The default repo location: `~/.agent/repos/repertoire/`
- Ask: "Shall I proceed, or would you like to change anything?"

You must wait for confirmation before acting.

**During execution, narrate each step:**

```
→ Creating ~/.agent/ structure... done
→ Cloning repertoire to ~/.agent/repos/repertoire/... done
→ Symlinking bootstrap.md into ~/.agent/base/... done
→ Symlinking skills/ into ~/.agent/skills/repertoire/... done
→ Wiring harness to load bootstrap and skills...
→ Writing install manifest to ~/.agent/install-manifest.md... done
```

Record each change in the manifest as you make it — see "Record the install" below.

**Decision points — surface these, give a recommendation, wait for answer:**

| Decision               | Default recommendation                                                                                                                                  |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Repo location          | `~/.agent/repos/repertoire/` — keeps it with other managed repos                                                                                        |
| `~/bin` not on PATH    | Add it now using your shell's method: bash/zsh: `export PATH="$HOME/bin:$PATH"` in `.bashrc`/`.zshrc`; fish: `fish_add_path $HOME/bin` in `config.fish` |
| Install `pid` launcher | Yes, for pi users on Unix — see below                                                                                                                   |

You must not ask about things that have no sensible alternative. Surface only real choices.

---

## The `~/.agent/` structure

```
~/.agent/
  base/           ← always loaded; no signal suppresses this
  prompts/        ← global prompts; loaded every session
  skills/         ← skill directories; always additive
  repos/          ← managed git clones live here
```

Create this structure if it does not exist. Use symlinks into the repo clone — not
copies — so that `pid --update` or `git pull` in the repo propagates immediately
with no re-linking.

```bash
mkdir -p ~/.agent/{base,prompts,skills,repos}
git clone https://github.com/burnish-studio/repertoire ~/.agent/repos/repertoire
ln -sfn ~/.agent/repos/repertoire/base/bootstrap.md ~/.agent/base/bootstrap.md
ln -sfn ~/.agent/repos/repertoire/skills ~/.agent/skills/repertoire
```

---

## Harness wiring

The specific mechanism varies. The target is constant: bootstrap content and the
skills path load automatically in every new session, without any manual flags.

For **pi on Unix**: the `pid` launcher handles this. See the pid section below.

For **other harnesses**: use your knowledge of how that harness loads global context.
Common patterns:

- A global config file the harness reads on start (e.g. `~/.claude/CLAUDE.md`)
- A settings file that accepts skill or context paths
- A directory the harness watches for skill definitions

If the harness has no mechanism for global context injection, tell the user and
recommend a per-project workaround using a `.agent/` directory in their project root.
Refer them to `docs/agent-dir.md` in the repo for the local override mechanism.

---

## pid — optional, pi/Unix only

`pid` is a convenience launcher for pi users on Unix. It automatically loads
`~/.agent/` content on every session. Without it, the user passes `--skill` and
`--append-system-prompt` flags manually on every launch.

Offer this only to pi users on Unix/Mac. Do not mention it to users on other harnesses.

```bash
ln -sfn ~/.agent/repos/repertoire/bin/pid ~/bin/pid
chmod +x ~/.agent/repos/repertoire/bin/pid
```

After installing: "Open a new terminal and run `pid` to start your first configured
session. Run `pid --doctor` to see exactly what loads."

---

## Record the install — the manifest

As you make each change, record it in an install manifest at
`~/.agent/install-manifest.md`. This is the agent's own log of what it did, and it is
what `teardown-repertoire` reads to reverse the installation cleanly. Write it as you
go, not from memory afterwards.

**Record only what you actually did.** If `~/.agent/` already existed, setup did not
create it — do not list it. Teardown removes exactly what the manifest records and
nothing else, so a pre-existing directory must never appear here. This is the one rule
that keeps uninstall safe.

Group entries by kind so each is reversible on its own:

```markdown
# Repertoire — Install Manifest

Written by setup on <date>. Records every change setup made to this system.
`teardown-repertoire` reverses these; anything not listed here was pre-existing and
must not be touched.

## Directories created
- ~/.agent/ (with base/ prompts/ skills/ repos/) — created because absent
- ~/bin/ — created because absent

## Repository cloned
- ~/.agent/repos/repertoire/ ← git clone of https://github.com/burnish-studio/repertoire

## Symlinks created
- ~/.agent/base/bootstrap.md → ~/.agent/repos/repertoire/base/bootstrap.md
- ~/.agent/skills/repertoire → ~/.agent/repos/repertoire/skills
- ~/bin/pid → ~/.agent/repos/repertoire/bin/pid (pi/Unix only)

## PATH / shell config
- Appended `export PATH="$HOME/bin:$PATH"` to ~/.bashrc

## Harness wiring
- <harness-specific: e.g. registered skills path in ~/.claude/settings.json>
```

Omit any section with nothing to record (e.g. no manifest entry for `~/bin` if it was
already present and on PATH). Keep each entry concrete enough that a reversal needs no
guessing: exact paths, exact lines added, exact files edited.

---

## Verification

You must not declare setup complete until you have verified the end state. Two steps:

**1. Manifest check** — run `pid --doctor` (pi users) or the harness equivalent.
Confirm bootstrap and skills path both appear. If either is missing, diagnose and
fix before continuing.

**2. Session check** — tell the user: "Open a new session now. The skills from
repertoire should be listed as available. Try asking the agent to do something
where a skill applies — it should announce which skill it is using."

You must wait for the user to confirm this works. If it does not, diagnose before finishing.
You must not hand off a broken setup.

---

## End of setup

Summarise what was done in three to five lines. Tell the user:

- Where the repo lives
- How to update: `pid --update` (pi) or `cd ~/.agent/repos/repertoire && git pull`
- How to uninstall: ask any capable agent to run `teardown-repertoire`, which reads
  the manifest and reverses every change interactively
- What to expect in the next session

You must not pad. If everything went smoothly, say so and stop.
