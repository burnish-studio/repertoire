#!/usr/bin/env bash
# install.sh — one-command install for repertoire.
# Sets up the ~/.agent/ convention, clones the repo, creates all symlinks.
# Safe to re-run: existing files and symlinks are updated, not duplicated.
set -euo pipefail

REPO_URL="${REPERTOIRE_REPO:-https://github.com/burnish-projects/repertoire}"
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
