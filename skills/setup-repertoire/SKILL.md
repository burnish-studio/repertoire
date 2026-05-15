---
name: setup-repertoire
description: Set up repertoire on this machine. Covers both minimal (skills only) and full (agent-dir convention + pid) installation. Use when a user asks to install repertoire, set up their agent skills, or get started with repertoire.
---

# Setup Repertoire

_Perspective: [standards/perspective/STANDARD.md](../../standards/perspective/STANDARD.md)_

This document is the install guide for repertoire. It is written for an intelligent
reader — human or agent. Follow the path that fits the situation. Verify at the end.

---

## Before starting

Establish two things:

1. **Where repertoire will live.** Default: `~/.agent/repos/repertoire/`. If the user
   has a preference, use that instead.

2. **Which setup path.** Two options:
   - **Minimal** — skills only; no changes to existing harness setup beyond adding a
     skills path. Right for someone who just wants the skills.
   - **Full** — skills plus the `~/.agent/` convention and the `pid` launcher. Right
     for someone starting fresh or wanting the complete delivery system.

If in doubt, ask. One question is worth asking; more than one is not.

---

## Path A — Minimal (skills only)

Installs repertoire skills into whatever harness is already in use. No `~/.agent/`
setup, no pid.

**1. Clone the repo**

```bash
git clone https://github.com/burnish-projects/repertoire ~/.agent/repos/repertoire
```

(Adjust the destination if the user prefers a different location.)

**2. Add skills to the harness**

For **pi** — add to `~/.pi/settings.json`:

```json
{
  "skills": ["/path/to/repertoire/skills"]
}
```

For **Claude Code** — symlink into `~/.claude/skills/`:

```bash
ln -s /path/to/repertoire/skills/write-a-skill ~/.claude/skills/write-a-skill
# repeat for each skill, or symlink the whole directory
```

For **other harnesses** — consult the harness documentation for where it discovers
skills. Point it at `repertoire/skills/`.

**3. Verify**

Open a session. The skills should appear in the harness's available skills list. Test
by invoking one: `/skill:audit` or equivalent for your harness.

---

## Path B — Full (agent-dir convention + pid)

Installs everything: skills, the `~/.agent/` convention, the `pid` launcher for pi.

**1. Create the directory structure**

```bash
mkdir -p ~/.agent/base
mkdir -p ~/.agent/prompts
mkdir -p ~/.agent/skills
mkdir -p ~/.agent/repos
mkdir -p ~/bin
```

**2. Clone the repo**

```bash
git clone https://github.com/burnish-projects/repertoire ~/.agent/repos/repertoire
```

**3. Create symlinks**

```bash
# Bootstrap into base
ln -sfn ~/.agent/repos/repertoire/base/bootstrap.md ~/.agent/base/bootstrap.md

# Skills
ln -sfn ~/.agent/repos/repertoire/skills ~/.agent/skills/repertoire

# pid launcher (pi only)
ln -sfn ~/.agent/repos/repertoire/bin/pid ~/bin/pid
chmod +x ~/.agent/repos/repertoire/bin/pid
```

**4. Ensure ~/bin is on PATH**

```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/bin:$PATH"
```

Skip if `~/bin` is already on PATH.

**5. Add personal prompts (optional)**

Place any global system prompt files in `~/.agent/prompts/`. Numeric prefixes
control load order. These are personal — repertoire does not provide them.

```
~/.agent/prompts/
  01-runtime.md     ← example: your runtime behaviour preferences
  02-identity.md    ← example: agent identity/character
```

**6. Verify**

```bash
pid --doctor
```

Expected output: manifest showing model, bootstrap, any prompts, and the repertoire
skills path. If `pid` is not found, check that `~/bin` is on PATH.

Open a session with `pid`. Skills from repertoire should be available. Bootstrap
instruction is active — the agent will check for relevant skills before responding.

---

## Updating

Repertoire is installed as a live git clone. To update:

```bash
pid --update        # shows changes, prompts for confirmation
```

Or manually:

```bash
cd ~/.agent/repos/repertoire && git pull
```

All symlinks update immediately — no re-linking required.

---

## Adding more skill collections

```bash
git clone https://github.com/someone/their-skills ~/.agent/repos/their-skills
ln -sfn ~/.agent/repos/their-skills/skills ~/.agent/skills/their-skills
```

Available in the next session.

---

## Reference

- `docs/agent-dir.md` — the `~/.agent/` convention in full
- `bin/agent-core.sh` — the harness-agnostic core; read this to write an adapter for
  a harness not yet covered
- `docs/pid-setup.md` — pid flags and behaviour reference
