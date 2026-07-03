# Repertoire

Repertoire is a standalone base layer of agent skills, standards, and templates, plus
the delivery machinery that makes that content load inside any agent harness. This
glossary fixes the language of the delivery architecture so decisions downstream stay
consistent.

## Language

**Core**:
The standalone, semantically meaningful content — skills, standards, templates — stored
in a neutral location that belongs to no single harness. The canonical single source of
truth; everything else refers back to it.
_Avoid_: repo, install, package

**Adapter**:
The per-harness binding that makes the Core load inside one harness. One Adapter per
harness; many can coexist, all pointing at the single Core. Realised either as static
wiring or as a launcher.
_Avoid_: integration, plugin, connector

**Static wiring**:
An Adapter realised as symlinks or import lines placed into the harness's own config
location, so the harness loads Core content on its own. The cheap, common case.
_Avoid_: hook, glue

**Launcher**:
An Adapter realised as a runtime shim (e.g. `pid`) that controls what the harness loads
at launch — needed only by harnesses that require flag injection rather than static
config. The expensive case.
_Avoid_: wrapper, runner

**End state**:
The harness-agnostic target every Adapter aims at: the bootstrap loads on every session,
and Repertoire skills are discoverable. Stated abstractly; realised differently per
harness. The thing an install verifies and a teardown reverses.
_Avoid_: goal, config

**Integration surface**:
The set of files, locations, and launch flags a given harness exposes that external
tooling can write to or pass in order to make it load content. Static-wiring harnesses
expose config files and directories; launcher harnesses expose launch flags. Small and
file-based for most harnesses — the reason paradigm-2 delegation is viable.
_Avoid_: API, hook points

**Harness detection**:
Establishing which harness and OS the setup is running in by inspecting environmental
evidence (env vars, config directories, available flags) and confirming with the user —
rather than assuming the agent introspectively knows its own harness.
_Avoid_: sniffing, autodetect

**Delivery flow**:
An interactive, agent-driven process for one lifecycle operation — setup, teardown,
update, or doctor — in which the agent acts as a CLI for the user, detecting and
confirming before acting. Realised as a skill (the flow spec); the agent is the runtime.
_Avoid_: installer, wizard, script

**Scope**:
Whether an Adapter's binding applies everywhere (**Global**) or only inside one project
(**Local**).

**Composition mode**:
How Repertoire sits relative to the user's existing setup. **Additive**: Repertoire
joins onto the user's existing prompts and skills. **Clean**: Repertoire only, the
user's existing setup suppressed for that session.
_Avoid_: merge/override (for the pair); replace (use Clean)
