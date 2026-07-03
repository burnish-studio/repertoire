---
type: research-doc
title: Harness Conventions Audit — how major harnesses load content
created: 2026-07-03
updated: 2026-07-03
status: current
model: opus-4-8
---

# Harness Conventions Audit

How the major agent harnesses actually load global context and discover skills, and how
two reference skill-libraries (Superpowers, Matt Pocock) deliver across them. Gathered to
test Repertoire's delivery architecture against real convention rather than assumption.
Terms (Core, Adapter, static wiring, launcher, scope, mode) are defined in
[../CONTEXT.md](../CONTEXT.md).

---

## Per-harness loading conventions

### Claude Code

- **Global context (bootstrap half):** `~/.claude/CLAUDE.md` is loaded in full at the
  start of every session (user scope). Supports `@path` imports — relative, absolute, or
  `~/`-anchored — expanded at launch, depth up to four. So the bootstrap adapter is a
  single line: `@~/.agent/repos/repertoire/base/bootstrap.md`.
- **Rules alternative:** `~/.claude/rules/*.md` (user scope) also load every session;
  supports symlinks and path-scoped frontmatter. Another valid bootstrap home.
- **Skills (skills half):** discovered as `~/.claude/skills/<name>/SKILL.md` (user) and
  `./.claude/skills/<name>/SKILL.md` (project). **One directory per skill** — flat, not a
  pointer to a skills root. Follows the agentskills.io open standard.
- **Plugins:** a `.claude-plugin/plugin.json` can bundle a whole `skills/` dir + `hooks/`
  + `commands/`, installed via a marketplace or local path. This is the only native way to
  register a *whole skills directory* at once and to fire a SessionStart hook.
- **System-prompt injection (launcher path):** `--append-system-prompt <text>` — must be
  passed every invocation, so it belongs to a launcher/wrapper, not static config.

### pi

- **No convention-based global load.** pi loads nothing global by directory convention;
  content is passed as launch flags: `--append-system-prompt <file>`, `--skill <dir>`,
  `--no-context-files`. Hence pi *needs* a launcher (`pid`) to be ergonomic.
- **Skills granularity:** `--skill <path>` takes a **skills directory** (whole-dir), the
  opposite granularity to Claude Code's per-skill entries.
- **Clean mode is native:** `--no-context-files` suppresses the user's own context — pi
  can do Clean because the launcher controls the whole load.

### Gemini CLI

- **Context file:** `gemini-extension.json` sets `contextFileName` (e.g. `GEMINI.md`);
  that file is loaded and supports `@./path` imports (same shape as Claude Code).
- Adapter is therefore static: an extension manifest + an import line.

### Cursor / Codex / opencode

- Each has its own plugin/extension manifest (`.cursor-plugin/`, `.codex-plugin/`,
  `.opencode/plugins/*.js`) and, for Cursor, a `hooks-cursor.json` sessionStart hook.
- Shape matches the others: a per-harness manifest, optionally a session-start hook.

---

## Reference libraries — how they deliver

### Superpowers (obra) — push model, maximum harness coverage

- Ships a **separate native manifest per harness**: `.claude-plugin/`, `.codex-plugin/`,
  `.cursor-plugin/`, `gemini-extension.json`, `.opencode/plugins/*.js`; `AGENTS.md` is a
  symlink to `CLAUDE.md`.
- **Enforced bootstrap via SessionStart hook.** `hooks/hooks.json` (Claude) and
  `hooks-cursor.json` (Cursor) run `run-hook.cmd session-start`, which injects the
  `using-superpowers` bootstrap so skills auto-trigger. Gemini gets the same effect via
  `GEMINI.md` `@`-importing the bootstrap skill.
- **Their stated acceptance test for a new harness:** open a clean session, send one
  prompt, confirm a skill auto-triggers — explicitly rejecting "copying files" or
  "`npx` at-runtime shims" as non-integrations. Bootstrap-loads-every-session is their
  hard bar.
- **Cost:** every harness is a manifest + hook config to maintain. This is the
  multi-manifest maintenance tax — real and visible in the repo.

### Matt Pocock skills — pull model, Claude-centric

- Single `.claude-plugin/plugin.json` listing skill paths; `scripts/link-skills.sh`
  symlinks them into `~/.claude/skills/`.
- User-invoked (`/skill-name`); no session-start auto-trigger. Simpler, narrower, one
  harness.

---

## Implications for Repertoire's design

1. **The bootstrap half is nearly uniform.** Claude Code and Gemini both take an
   `@import` line in a global context file; pi takes `--append-system-prompt`. "Bootstrap
   loads every session" is a clean abstract intent with a one-line realisation per
   harness. Confirms the storage/wiring split — `~/.agent/` holds `bootstrap.md`; each
   adapter just points its harness at it.

2. **The skills half differs in granularity, and this is the real wiring cost.** pi wants
   a whole *skills dir* (`--skill`); Claude Code wants *per-skill* entries
   (`~/.claude/skills/<name>/`). The current `~/.agent/skills/repertoire → Core/skills`
   symlink is pi-shaped and breaks Claude Code discovery (smoke-test finding #2 confirmed
   at the convention level). An adapter must either enumerate per-skill symlinks or use
   the harness's native plugin to register the whole dir.

3. **Clean mode is a launcher capability, confirmed by convention.** Only pi's
   `--no-context-files` (a launcher flag) can suppress the user's existing setup. Static
   wiring is structurally Additive-only. (Parks the Q2 fork on solid ground.)

4. **Native plugin vs hand-rolled wiring is a genuine fork.** Every non-pi harness has a
   native plugin/extension format. Using it (Superpowers' path) is idiomatic and handles
   skills-granularity + session-start hooks for free, but starts the multi-manifest tax.
   Hand-rolling minimal symlinks+imports (agent-written, paradigm-2) keeps Core as the
   sole source with zero repo-side manifest surface, but must enumerate skills and be
   re-reasoned per harness.

5. **Our SKILL.md should conform to the agentskills.io open standard** so a single skill
   file is portable across every harness that reads that standard — cheapening every
   adapter. Worth verifying our frontmatter against it.
