# Adapters are agent-written minimal wiring; native plugins are opt-in

An **Adapter** — the per-harness binding that makes the Core load — is realised as the
minimal wiring the local agent writes: either **static wiring** (an `@import` line into
the harness's global context file + skill registration) or a **launcher** (a runtime
shim like `pid`, for harnesses that accept only launch flags). Core ships **no**
harness-specific manifests. A native plugin (e.g. a Claude Code plugin) is offered only
where it clearly reduces work, never as the primary mechanism.

We chose agent-written wiring over shipping a native manifest per harness (the
Superpowers model) because an `@import` already achieves "bootstrap loads every session",
so native manifests buy little while imposing the multi-manifest maintenance tax the
project explicitly wants to avoid (N schemas that drift as each harness changes).

## Consequences

**Clean** composition mode (suppress the user's existing setup) is achievable only by a
launcher — e.g. pi's `--no-context-files`. Static-wiring harnesses are **Additive-only**
by convention; each adapter declares its composition capability per harness rather than
promising Clean uniformly.
