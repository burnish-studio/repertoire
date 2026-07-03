#!/usr/bin/env bash
# install.sh — core-only installer for repertoire.
# Does the harness-agnostic Core: the ~/.agent/ storage layout, the clone, and the two
# core symlinks — plus the core rows of the install manifest. It does NO harness wiring:
# with no agent to detect and wire each harness, wiring is the user's to apply, so this
# script prints the wiring end-state and stops. The agent-driven setup-repertoire skill
# does Core + per-harness adapters in one interactive pass.
# Safe to re-run: existing files and symlinks are updated, not duplicated.
set -euo pipefail

REPO_URL="${REPERTOIRE_REPO:-https://github.com/burnish-studio/repertoire}"
AGENT_DIR="${AGENT_DIR:-$HOME/.agent}"
REPO_DIR="$AGENT_DIR/repos/repertoire"

# ── helpers ───────────────────────────────────────────────────────────────────
step() { echo "  → $*"; }
ok() { echo "  ✓ $*"; }
fail() {
	echo "  ✗ $*" >&2
	exit 1
}

# ── checks ────────────────────────────────────────────────────────────────────
echo ""
echo "┌─ repertoire install (core only) ────────────────────"
echo "│ agent dir: $AGENT_DIR"
echo "│ repo:      $REPO_DIR"
echo "└─────────────────────────────────────────────────────"
echo ""

command -v git >/dev/null 2>&1 || fail "git not found — install git and retry"
command -v bash >/dev/null 2>&1 || fail "bash not found"

# ── directories ───────────────────────────────────────────────────────────────
# Record pre-existence before creating anything, so the manifest lists only what
# this run created — teardown must never remove a directory that was already here.
AGENT_DIR_EXISTED=$([[ -d "$AGENT_DIR" ]] && echo yes || echo no)
REPO_EXISTED=$([[ -d "$REPO_DIR/.git" ]] && echo yes || echo no)

step "creating ~/.agent/ structure"
mkdir -p "$AGENT_DIR/base"
mkdir -p "$AGENT_DIR/prompts"
mkdir -p "$AGENT_DIR/skills"
mkdir -p "$AGENT_DIR/repos"
ok "directories ready"

# ── clone or update ───────────────────────────────────────────────────────────
if [[ -d "$REPO_DIR/.git" ]]; then
	step "updating existing clone"
	git -C "$REPO_DIR" pull --ff-only --quiet
	ok "repertoire updated"
else
	step "cloning repertoire"
	git clone --quiet "$REPO_URL" "$REPO_DIR"
	ok "repertoire cloned"
fi

# ── core symlinks ─────────────────────────────────────────────────────────────
# Neutral-storage pointers only: a stable path to the bootstrap and to the skills
# dir, independent of repo internals. No harness wiring here.
step "creating core symlinks"
ln -sfn "$REPO_DIR/base/bootstrap.md" "$AGENT_DIR/base/bootstrap.md"
ln -sfn "$REPO_DIR/skills" "$AGENT_DIR/skills/repertoire"
ok "core symlinks created"

# ── install manifest (core rows) ──────────────────────────────────────────────
# Record what this run changed, so teardown-repertoire can reverse it cleanly. The
# agent-driven path appends one Adapter section per harness it wires; this script
# writes only the Core section.
step "writing install manifest (core rows)"
MANIFEST="$AGENT_DIR/install-manifest.md"
{
	echo "# Repertoire — Install Manifest"
	echo ""
	echo "Written by install.sh on $(date -u +%Y-%m-%dT%H:%M:%SZ). Reverses via"
	echo "teardown-repertoire; anything not listed here was pre-existing and must not be"
	echo "touched. install.sh writes the Core rows only — no harness wiring was done."
	echo ""
	echo "## Core (deterministic)"
	echo "### Directories created"
	if [[ "$AGENT_DIR_EXISTED" == no ]]; then
		echo "- $AGENT_DIR/ (with base/ prompts/ skills/ repos/) — created because absent"
	else
		echo "- (none — $AGENT_DIR/ already existed; leave in place on teardown)"
	fi
	echo "### Repository cloned"
	if [[ "$REPO_EXISTED" == yes ]]; then
		echo "- $REPO_DIR/ — already present, updated not created; leave in place on teardown"
	else
		echo "- $REPO_DIR/ ← git clone of $REPO_URL"
	fi
	echo "### Symlinks created"
	echo "- $AGENT_DIR/base/bootstrap.md → $REPO_DIR/base/bootstrap.md"
	echo "- $AGENT_DIR/skills/repertoire → $REPO_DIR/skills"
} >"$MANIFEST"
ok "manifest written to $MANIFEST"

# ── wiring end-state (the part this script deliberately does not do) ───────────
cat <<EOF

┌─ next: wire your harness(es) ───────────────────────────
│ The Core is installed but not yet wired into any harness.
│ Wiring means pointing a harness's own config at the Core.
│
│ pi:
│   ln -sfn "$REPO_DIR/bin/pid" "\$HOME/bin/pid"   # + put ~/bin on PATH
│   then: pid --doctor
│
│ Claude Code:
│   append to ~/.claude/CLAUDE.md (create if absent):
│     <!-- repertoire:start -->
│     @$REPO_DIR/base/bootstrap.md
│     <!-- repertoire:end -->
│   symlink each skill into ~/.claude/skills/:
│     for d in "$REPO_DIR"/skills/*/; do
│       ln -sfn "\$d" ~/.claude/skills/repertoire-"\$(basename "\$d")"
│     done
│
│ Any other harness, or to have this done and recorded for you:
│   open a capable agent session and run setup-repertoire, which
│   detects and wires every harness and updates the manifest.
└─────────────────────────────────────────────────────────

done (core installed).
EOF
