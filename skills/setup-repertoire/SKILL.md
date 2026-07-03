---
type: skill
title: Setup Repertoire
name: setup-repertoire
description: Use when asked to install, set up, or configure repertoire on this machine. Drives the interactive setup as a CLI for the user — detects OS and every present harness, wires each one, records a reversible manifest, and verifies both capabilities load.
created: 2026-05-13
updated: 2026-07-03
status: current
model: claude-opus-4-8
---

# Setup Repertoire

_Perspective: [standards/perspective/STANDARD.md](../../standards/perspective/STANDARD.md)_

Repertoire is a standalone body of agent skills, standards, and templates — the **Core** —
delivered as a git repository. Setup installs the Core into neutral storage, then wires it
into each agent harness on this machine so its content loads in every future session.

You are the installer. This is an interactive flow: you act as a CLI for the user —
detecting the environment, confirming before acting, narrating as you go, and verifying the
result. Not silent automation, and not a rigid script: reach the end state described here
using your knowledge of this machine.

---

## Two ideas that shape everything below

**Storage is separate from wiring.** The Core lives in neutral storage at `~/.agent/`,
owned by no harness. **Wiring** always means placing a pointer into a *harness's own* config
(`~/.claude/`, `~/.codex/`, a launcher on `PATH`) so that harness loads the Core itself.
`~/.agent/` is not a universal load path — only the `pid` launcher reads it directly. Every
other harness reads its own directory. So one Core is wired by one **Adapter** per harness,
and several adapters can coexist, all pointing at the same Core.

**The end state is two independent capabilities**, satisfied and verified separately for
each harness:

1. **Bootstrap loads every session** — Repertoire's proactivity instruction (`base/bootstrap.md`)
   is in context at every session start.
2. **Skills are discoverable** — Repertoire's skills can be invoked when relevant.

Some harnesses do both natively; some do one and degrade the other. Report each half
honestly per harness — never claim a capability you have not wired and verified.

---

## Capabilities check — do this first

Confirm you can:

1. Read and write files on the local file system
2. Execute shell commands
3. Run `git`

If any fails, stop and tell the user:

> "This agent lacks the capabilities needed to install repertoire — file system access and
> shell execution are both required. Run this setup from an agent with full tool access (pi,
> Claude Code, Cursor with terminal, or equivalent). A web-only agent cannot complete this."

Do not proceed past this point. Do not attempt a partial setup.

---

## Detect the environment — then confirm

Establish the facts before proposing anything. Detect; do not assume you already know your
own harness or the machine's shape.

- **OS and shell** — Linux / macOS / Windows (WSL counts as Linux); bash / zsh / fish.
- **Harnesses present** — inspect for evidence of each, because one pass can wire *several*:
  - **pi** — the `pi` binary on `PATH`, `~/.pi/`.
  - **Claude Code** — the `claude` binary, `~/.claude/`.
  - **Codex** — `~/.codex/`.
  - **Cursor** — `~/.cursor/`, or a project `.cursor/`.
- **Existing Core** — is `~/.agent/` already present? Is repertoire already cloned?
- **Existing harness config** — does `~/.claude/CLAUDE.md` already exist (it must survive)?
  Is `~/bin` on `PATH` (pi only)?

Then present what you found and what you propose, and **wait for confirmation**:

- The OS, shell, and every harness you detected — and which ones you propose to wire.
- The default Core location `~/.agent/repos/repertoire/`.
- In plain terms, the wiring each harness will get.

Ask: "Shall I proceed, or would you like to change anything?" Do not act before the user
answers. Surface only real choices — never ask about things with one sensible answer.

---

## Step 1 — Install the Core (harness-agnostic)

This part is deterministic and identical for every machine: the neutral storage layout, the
clone, and the two core symlinks that give the Core stable paths independent of repo
internals.

```bash
mkdir -p ~/.agent/{base,prompts,skills,repos}
git clone https://github.com/burnish-studio/repertoire ~/.agent/repos/repertoire
ln -sfn ~/.agent/repos/repertoire/base/bootstrap.md ~/.agent/base/bootstrap.md
ln -sfn ~/.agent/repos/repertoire/skills            ~/.agent/skills/repertoire
```

Use symlinks, not copies, so a later `git pull` in the clone propagates with no re-linking.
`install.sh` in the repo does exactly this core step and writes the core rows of the
manifest — you may run it instead of doing the above by hand. It does **only** the Core; all
harness wiring below is yours.

Record what you created versus what pre-existed as you go — see "The manifest".

---

## Step 2 — Wire each detected harness (one Adapter each)

For every harness the user confirmed, satisfy both capabilities using that harness's own
integration surface, and record the exact wiring in the manifest. Below are the concrete
end states for the harnesses supported explicitly; for anything else, use the generic path.

### pi — launcher

pi takes launch flags, not passive config, so its adapter is the `pid` launcher. It reads
the neutral storage directly and passes it to pi on every launch — satisfying **both**
capabilities at once, and it is the only harness that can also do **Clean** mode
(`--no-context-files`, suppressing the user's own context for that session).

```bash
ln -sfn ~/.agent/repos/repertoire/bin/pid ~/bin/pid   # create ~/bin if absent
chmod +x ~/.agent/repos/repertoire/bin/pid
```

If `~/bin` is not on `PATH`, add it with the user's shell's method — bash/zsh:
`export PATH="$HOME/bin:$PATH"` in `~/.bashrc` / `~/.zshrc`; fish:
`fish_add_path $HOME/bin` in `~/.config/fish/config.fish` — and record the exact line and
file in the manifest. Offer `pid` only to pi users; never mention it to others.

### Claude Code — static wiring

Claude Code reads its own `~/.claude/` directory and needs **no launcher**. Wire both halves
statically:

- **Bootstrap** — append a marker-delimited block importing the bootstrap into
  `~/.claude/CLAUDE.md` (create the file if absent). The markers make teardown exact:

  ```markdown
  <!-- repertoire:start -->
  @~/.agent/repos/repertoire/base/bootstrap.md
  <!-- repertoire:end -->
  ```

  Never rewrite the rest of `CLAUDE.md` — the user's own memory must survive untouched.
- **Skills** — symlink each skill directory into `~/.claude/skills/` under a `repertoire-`
  prefix, so Claude Code discovers each at `~/.claude/skills/repertoire-<name>/SKILL.md`
  and the prefix avoids colliding with the user's own skills:

  ```bash
  for d in ~/.agent/repos/repertoire/skills/*/; do
    name=$(basename "$d")
    ln -sfn "$d" ~/.claude/skills/repertoire-"$name"
  done
  ```

Claude Code is Additive only — static wiring cannot suppress the user's own context. (An
optional Claude Code plugin could register the whole skills dir at once; it is never
required, so prefer the symlinks above unless the user asks for the plugin.)

### Any other harness — generic paradigm-2 path

You know how this harness loads global context and discovers skills. Map the two
capabilities onto its own integration surface:

- **Bootstrap** — find the file it reads every session (a global instructions / memory /
  rules file). Append a **marker-delimited block** (`<!-- repertoire:start -->` …
  `<!-- repertoire:end -->`) — importing `base/bootstrap.md` if the file supports imports,
  otherwise inlining the bootstrap text. Never overwrite a shared file the user owns.
- **Skills** — register the Core's `skills/` with whatever skills mechanism it exposes. If
  it has none, degrade honestly: reference the skills index inside the bootstrap block
  and/or drop selected skills into its prompts directory, and report the skills half as
  **partial**.

Record every file, line, and symlink exactly, with its pre-existence flag.

### When you cannot wire it — manual fallback

If you cannot identify a mechanism, **or cannot verify the wiring worked** (see
Verification), do not fake success. Tell the user which half failed, hand them the concrete
end state to apply by hand, and record what you *did* manage plus a note that the rest is
manual (so teardown is likewise manual for that part). A no-agent install is this tier by
definition.

---

## The manifest — the contract teardown depends on

As you work, write `~/.agent/install-manifest.md`. This is the load-bearing record:
`teardown-repertoire` reverses **exactly and only** what it lists, possibly on another
machine or months later, with no chance to re-improvise. A vague manifest makes teardown
either unsafe (removes something pre-existing) or incomplete (leaves one harness dangling).
Precision here is not optional — write it as you act, not from memory after.

Structure it as Core rows plus one section per Adapter. Every entry records the exact path,
the exact line/symlink/flag, and **whether it pre-existed**. Use the *edited shared file*
entry kind — a marker-delimited block — for any in-place edit to a file the user may own
(`CLAUDE.md`, `AGENTS.md`); its reversal is "delete the block between the markers", and it
carries a `[file pre-existed]` flag so teardown knows whether to remove the emptied file.

```markdown
# Repertoire — Install Manifest
Written by setup on <UTC timestamp>. Reverses via teardown-repertoire.
Anything not listed here was pre-existing and must not be touched.

## Core (deterministic)
### Directories created
- ~/.agent/ (base/ prompts/ skills/ repos/) — created because absent
- ~/bin/ — created because absent
### Repository cloned
- ~/.agent/repos/repertoire/ ← git clone of https://github.com/burnish-studio/repertoire
### Symlinks created
- ~/.agent/base/bootstrap.md → ~/.agent/repos/repertoire/base/bootstrap.md
- ~/.agent/skills/repertoire → ~/.agent/repos/repertoire/skills

## Adapter: pi (launcher)
- symlink ~/bin/pid → ~/.agent/repos/repertoire/bin/pid
- PATH: appended `export PATH="$HOME/bin:$PATH"` to ~/.bashrc
- bootstrap + skills: satisfied at launch by pid; no static edit

## Adapter: claude-code (static wiring)
- edited shared file ~/.claude/CLAUDE.md [pre-existed: yes] — added marker block
  `<!-- repertoire:start -->` … `<!-- repertoire:end -->`; reverse = delete that block
- symlink ~/.claude/skills/repertoire-audit          → …/skills/audit
- symlink ~/.claude/skills/repertoire-codify         → …/skills/codify
- symlink ~/.claude/skills/repertoire-write-a-skill  → …/skills/write-a-skill
  [one per skill]
```

Omit any section with nothing to record. If a directory or the clone already existed, say so
(`already present — leave in place on teardown`) rather than listing it as created.

---

## Verification — per half, with teeth

Do not declare setup complete until you have confirmed the end state. In-session file and
symlink checks are only a proxy — "loads every session" is truly confirmed only by a *new*
session. So verify in two passes, per harness:

**1. Proxy check (now).** Confirm the wiring exists: the core symlinks resolve; each
harness's bootstrap edit and skills registration are in place. For pi, run `pid --doctor`
and confirm bootstrap and skills both appear. Fix anything missing before continuing.

**2. Live check (new session).** Hand the user a one-line self-check per harness:

> "Open a new <harness> session and ask it whether it can see the repertoire skills, and
> whether the repertoire bootstrap instruction is active. Both should be yes."

If a harness cannot confirm a half, treat that half as unwired: fix it, or fall to the
manual fallback and say so plainly. Do not hand off a setup you have not verified.

---

## End of setup

Summarise in three to five lines: which harnesses were wired and to what degree (per half),
where the Core lives, how to update (`pid --update`, or `cd ~/.agent/repos/repertoire &&
git pull`), and how to uninstall (ask any capable agent to run `teardown-repertoire`, which
reads the manifest and reverses every change). State honestly anything left partial or
manual. Do not pad — if it went cleanly, say so and stop.
