#!/usr/bin/env bash
# install.sh — one-command install for repertoire.
# Sets up the ~/.agent/ convention, clones the repo, creates all symlinks.
# Safe to re-run: existing files and symlinks are updated, not duplicated.
set -euo pipefail

REPO_URL="${REPERTOIRE_REPO:-https://github.com/burnish-studio/repertoire}"
AGENT_DIR="${AGENT_DIR:-$HOME/.agent}"
REPO_DIR="$AGENT_DIR/repos/repertoire"
BIN_DIR="$HOME/bin"

# ── helpers ───────────────────────────────────────────────────────────────────
step() { echo "  → $*"; }
ok() { echo "  ✓ $*"; }
fail() {
	echo "  ✗ $*" >&2
	exit 1
}

# ── checks ────────────────────────────────────────────────────────────────────
echo ""
echo "┌─ repertoire install ────────────────────────────────"
echo "│ agent dir: $AGENT_DIR"
echo "│ repo:      $REPO_DIR"
echo "│ bin:       $BIN_DIR"
echo "└─────────────────────────────────────────────────────"
echo ""

command -v git >/dev/null 2>&1 || fail "git not found — install git and retry"
command -v bash >/dev/null 2>&1 || fail "bash not found"

# ── directories ───────────────────────────────────────────────────────────────
# Record pre-existence before creating anything, so the manifest lists only what
# this run created — teardown must never remove a directory that was already here.
AGENT_DIR_EXISTED=$([[ -d "$AGENT_DIR" ]] && echo yes || echo no)
BIN_DIR_EXISTED=$([[ -d "$BIN_DIR" ]] && echo yes || echo no)
REPO_EXISTED=$([[ -d "$REPO_DIR/.git" ]] && echo yes || echo no)

step "creating ~/.agent/ structure"
mkdir -p "$AGENT_DIR/base"
mkdir -p "$AGENT_DIR/prompts"
mkdir -p "$AGENT_DIR/skills"
mkdir -p "$AGENT_DIR/repos"
mkdir -p "$BIN_DIR"
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

# ── symlinks ──────────────────────────────────────────────────────────────────
step "creating symlinks"

ln -sfn "$REPO_DIR/base/bootstrap.md" "$AGENT_DIR/base/bootstrap.md"
ln -sfn "$REPO_DIR/skills" "$AGENT_DIR/skills/repertoire"
ln -sfn "$REPO_DIR/bin/pid" "$BIN_DIR/pid"
chmod +x "$REPO_DIR/bin/pid"

ok "symlinks created"

# ── install manifest ──────────────────────────────────────────────────────────
# Record what this run changed, so teardown-repertoire can reverse it cleanly.
step "writing install manifest"
MANIFEST="$AGENT_DIR/install-manifest.md"
{
	echo "# Repertoire — Install Manifest"
	echo ""
	echo "Written by install.sh on $(date -u +%Y-%m-%dT%H:%M:%SZ). Records every change"
	echo "this run made. \`teardown-repertoire\` reverses these; anything not listed here"
	echo "was pre-existing and must not be touched."
	echo ""
	echo "## Directories created"
	[[ "$AGENT_DIR_EXISTED" == no ]] && echo "- $AGENT_DIR/ (with base/ prompts/ skills/ repos/) — created because absent"
	[[ "$BIN_DIR_EXISTED" == no ]] && echo "- $BIN_DIR/ — created because absent"
	[[ "$AGENT_DIR_EXISTED" == yes && "$BIN_DIR_EXISTED" == yes ]] && echo "- (none — both ~/.agent/ and ~/bin/ already existed)"
	echo ""
	echo "## Repository cloned"
	if [[ "$REPO_EXISTED" == yes ]]; then
		echo "- $REPO_DIR/ — already present, updated not created; leave in place on teardown"
	else
		echo "- $REPO_DIR/ ← git clone of $REPO_URL"
	fi
	echo ""
	echo "## Symlinks created"
	echo "- $AGENT_DIR/base/bootstrap.md → $REPO_DIR/base/bootstrap.md"
	echo "- $AGENT_DIR/skills/repertoire → $REPO_DIR/skills"
	echo "- $BIN_DIR/pid → $REPO_DIR/bin/pid"
	echo ""
	echo "## PATH / shell config"
	echo "- (none — install.sh only warns; PATH was not edited by this run)"
} >"$MANIFEST"
ok "manifest written to $MANIFEST"

# ── PATH check ────────────────────────────────────────────────────────────────
if ! echo "$PATH" | grep -q "$BIN_DIR"; then
	echo ""
	echo "  ⚠  $BIN_DIR is not on your PATH"
	echo "     add this to ~/.bashrc or ~/.zshrc:"
	echo "     export PATH=\"\$HOME/bin:\$PATH\""
fi

# ── verify ────────────────────────────────────────────────────────────────────
echo ""
echo "┌─ verification ──────────────────────────────────────"
if command -v pid >/dev/null 2>&1; then
	pid --doctor
else
	echo "│ pid not on PATH yet — run: export PATH=\"\$HOME/bin:\$PATH\""
	echo "│ then: pid --doctor"
	echo "└─────────────────────────────────────────────────────"
fi

echo ""
echo "done. run 'pid' to start a session."
