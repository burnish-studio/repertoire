# Core is neutral storage; wiring targets each harness's own config

Repertoire's canonical content (the **Core**) lives in a neutral location owned by no
harness (`~/.agent/`), and "wiring" always means placing a pointer into the **harness's
own** config location — not into `~/.agent/`. We split these because treating `~/.agent/`
as the universal load path was a pi-ism: only pi (via the `pid` launcher) reads it. Every
other harness reads its own directory (`~/.claude/`, `GEMINI.md`, `.cursor/`), so pi
becomes one adapter among many rather than the definition of the core.

## Consequences

Dissolves the 2026-07-02 smoke-test findings where a non-pi agent had to improvise a
bridge from `~/.agent/skills/repertoire` into the harness's real loader: there is no
universal wiring to improvise, only a neutral store plus a per-harness pointer. `~/.agent/`
survives purely as storage (the clone, user prompts/skills, the launcher).
