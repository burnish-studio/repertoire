#!/usr/bin/env bash
# agent-core.sh — harness-agnostic core library for the ~/.agent/ convention.
# Source this file from a harness adapter. Do not execute directly.
#
# Usage in an adapter:
#   source "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/agent-core.sh"
#   agent_parse_args "$@"
#   agent_collect
#   agent_inject_model "claude-sonnet-4.6" "sonnet-4-6"
#   trap 'rm -f "${AGENT_MODEL_TMPFILE:-}"' EXIT
#   agent_print_manifest "my-harness"
#   [[ "$DOCTOR" -eq 1 ]] && agent_doctor && exit 0
#   [[ "$VERIFY" -eq 1 ]] && agent_verify && exit 0
#   # build harness-specific flags from APPENDS[] and SKILL_PATHS[]
#   # exec harness ...

# ── state (readable by adapter after calling functions) ───────────────────────
APPENDS=()
SKILL_PATHS=()
USER_ARGS=()
NO_GLOBAL=0
NO_LOCAL=0
NO_SKILLS=0
VERIFY=0
DOCTOR=0
UPDATE=0
RAW_MODEL=""
SHORT_MODEL=""
PROMPT_MODE="global"
AGENT_MODEL_TMPFILE=""

# ── defaults (adapter may override before calling agent_parse_args) ───────────
AGENT_DIR="${AGENT_DIR:-$HOME/.agent}"
LOCAL_AGENT_DIR="${LOCAL_AGENT_DIR:-.agent}"

# ── arg parsing ───────────────────────────────────────────────────────────────
# Parses known flags; unknown args accumulate in USER_ARGS for the adapter.
agent_parse_args() {
	while [[ $# -gt 0 ]]; do
		case "$1" in
		--agent-dir)
			AGENT_DIR="$2"
			shift 2
			;;
		--local-dir)
			LOCAL_AGENT_DIR="$2"
			shift 2
			;;
		--no-global)
			NO_GLOBAL=1
			shift
			;;
		--no-local)
			NO_LOCAL=1
			shift
			;;
		--no-skills)
			NO_SKILLS=1
			shift
			;;
		--verify)
			VERIFY=1
			shift
			;;
		--doctor)
			DOCTOR=1
			shift
			;;
		--update)
			UPDATE=1
			shift
			;;
		--)
			shift
			USER_ARGS+=("$@")
			return
			;;
		*)
			USER_ARGS+=("$1")
			shift
			;;
		esac
	done
}

# ── internal: derive paths ────────────────────────────────────────────────────
_agent_derive_paths() {
	BASE_DIR="$AGENT_DIR/base"
	PROMPTS_DIR="$AGENT_DIR/prompts"
	SKILLS_DIR="$AGENT_DIR/skills"
	REPOS_DIR="$AGENT_DIR/repos"
	LOCAL_PROMPTS_DIR="$PWD/$LOCAL_AGENT_DIR/prompts"
	LOCAL_SKILLS_DIR="$PWD/$LOCAL_AGENT_DIR/skills"
	LOCAL_REPLACE_DIR="$LOCAL_PROMPTS_DIR/_replace"
	LOCAL_APPEND_DIR="$LOCAL_PROMPTS_DIR/_append"
}

# ── internal: collect helpers ─────────────────────────────────────────────────
_collect_dir() {
	local dir="$1"
	if [[ -d "$dir" ]]; then
		while IFS= read -r -d '' f; do
			APPENDS+=("$f")
		done < <(find -L "$dir" -maxdepth 1 -type f -name '*.md' -print0 | sort -z)
	fi
}

_add_skills() {
	local dir="$1"
	if [[ -d "$dir" ]]; then
		local resolved
		resolved=$(realpath "$dir" 2>/dev/null || echo "$dir")
		for existing in "${SKILL_PATHS[@]:-}"; do
			[[ "$(realpath "$existing" 2>/dev/null || echo "$existing")" == "$resolved" ]] && return 0
		done
		SKILL_PATHS+=("$dir")
	fi
}

# ── collect ───────────────────────────────────────────────────────────────────
# Populates APPENDS[] and SKILL_PATHS[] from ~/.agent/ and local .agent/.
agent_collect() {
	_agent_derive_paths

	# Base — always loaded; no flag suppresses this
	_collect_dir "$BASE_DIR"

	# Warn if both _replace/ and _append/ are present
	if [[ "$NO_LOCAL" -eq 0 && -d "$LOCAL_REPLACE_DIR" && -d "$LOCAL_APPEND_DIR" ]]; then
		echo "⚠  warning: both _replace/ and _append/ found in $LOCAL_PROMPTS_DIR"
		echo "   using _replace/ only — _append/ ignored"
	fi

	# Prompts — global unless local _replace/ is present
	if [[ "$NO_LOCAL" -eq 0 && -d "$LOCAL_REPLACE_DIR" ]]; then
		PROMPT_MODE="replace (local)"
		_collect_dir "$LOCAL_REPLACE_DIR"
	else
		[[ "$NO_GLOBAL" -eq 0 ]] && _collect_dir "$PROMPTS_DIR"
		if [[ "$NO_LOCAL" -eq 0 && -d "$LOCAL_APPEND_DIR" ]]; then
			_collect_dir "$LOCAL_APPEND_DIR"
			PROMPT_MODE="global + append (local)"
		fi
	fi

	# Skills — always additive
	if [[ "$NO_SKILLS" -eq 0 ]]; then
		[[ "$NO_GLOBAL" -eq 0 ]] && _add_skills "$SKILLS_DIR"
		[[ "$NO_LOCAL" -eq 0 ]] && _add_skills "$LOCAL_SKILLS_DIR"
	fi
}

# ── model injection ───────────────────────────────────────────────────────────
# Creates a temp file with model context and prepends it to APPENDS[].
# Adapter must set: trap 'rm -f "${AGENT_MODEL_TMPFILE:-}"' EXIT
agent_inject_model() {
	local raw="$1"
	local short="$2"
	RAW_MODEL="$raw"
	SHORT_MODEL="$short"
	if [[ -n "$RAW_MODEL" ]]; then
		AGENT_MODEL_TMPFILE=$(mktemp /tmp/agent-model-XXXX.md)
		cat >"$AGENT_MODEL_TMPFILE" <<EOF
<!-- model context injected by agent-core -->
Your current model is **${RAW_MODEL}** (short form for filenames and frontmatter: \`${SHORT_MODEL}\`).
EOF
		APPENDS=("$AGENT_MODEL_TMPFILE" "${APPENDS[@]}")
	fi
}

# ── manifest ──────────────────────────────────────────────────────────────────
agent_print_manifest() {
	local harness="${1:-agent}"
	echo "┌─ $harness ──────────────────────────────────────────"
	echo "│ cwd:     $PWD"
	echo "│ prompts: $PROMPT_MODE"
	[[ -n "$RAW_MODEL" ]] && echo "│ model:   $RAW_MODEL ($SHORT_MODEL)"
	echo "│"
	if [[ ${#APPENDS[@]} -eq 0 ]]; then
		echo "│ appends: (none)"
	else
		echo "│ appends (${#APPENDS[@]}):"
		for i in "${!APPENDS[@]}"; do
			printf "│   %02d. %s\n" "$((i + 1))" "${APPENDS[$i]}"
		done
	fi
	echo "│"
	if [[ ${#SKILL_PATHS[@]} -eq 0 ]]; then
		echo "│ skills:  (none)"
	else
		echo "│ skills (${#SKILL_PATHS[@]}):"
		for i in "${!SKILL_PATHS[@]}"; do
			printf "│   %02d. %s\n" "$((i + 1))" "${SKILL_PATHS[$i]}"
		done
	fi
	echo "└─────────────────────────────────────────────────────"
}

# ── doctor ────────────────────────────────────────────────────────────────────
agent_doctor() {
	echo ""
	for f in "${APPENDS[@]}"; do
		echo "=== $(basename "$f") ==="
		head -3 "$f"
		echo ""
	done
}

# ── verify ────────────────────────────────────────────────────────────────────
agent_verify() {
	echo ""
	echo "Full content of all files loaded as system prompt:"
	echo ""
	for f in "${APPENDS[@]}"; do
		echo "════════════════════════════════════════════════════"
		echo "FILE: $f"
		echo "════════════════════════════════════════════════════"
		cat "$f"
		echo ""
	done
}

# ── update ────────────────────────────────────────────────────────────────────
# Checks all git repos under $AGENT_DIR/repos/ for updates; prompts per repo.
agent_update() {
	_agent_derive_paths

	if [[ ! -d "$REPOS_DIR" ]]; then
		echo "no repos directory found at $REPOS_DIR — nothing to update"
		return 0
	fi

	local found=0
	for repo_dir in "$REPOS_DIR"/*/; do
		[[ -d "$repo_dir/.git" ]] || continue
		found=1
		local name
		name=$(basename "$repo_dir")

		echo "┌─ update: $name ──────────────────────────────────"

		if ! git -C "$repo_dir" fetch --quiet 2>/dev/null; then
			echo "│ ✗  fetch failed (offline?)"
			echo "└─────────────────────────────────────────────────────"
			continue
		fi

		local current latest
		current=$(git -C "$repo_dir" rev-parse --short HEAD 2>/dev/null)
		latest=$(git -C "$repo_dir" rev-parse --short FETCH_HEAD 2>/dev/null)

		if [[ "$current" == "$latest" ]]; then
			echo "│ already up to date ($current)"
			echo "└─────────────────────────────────────────────────────"
			continue
		fi

		local cur_msg lat_msg
		cur_msg=$(git -C "$repo_dir" log -1 --format="%s" HEAD 2>/dev/null | cut -c1-48)
		lat_msg=$(git -C "$repo_dir" log -1 --format="%s" FETCH_HEAD 2>/dev/null | cut -c1-48)

		echo "│ current:  $current  $cur_msg"
		echo "│ latest:   $latest  $lat_msg"
		echo "│"

		local changes
		changes=$(git -C "$repo_dir" diff --name-status HEAD FETCH_HEAD 2>/dev/null) || true
		if [[ -n "$changes" ]]; then
			echo "│ changes:"
			while IFS=$'\t' read -r status file; do
				case "$status" in
				A) printf "│   + %s\n" "$file" ;;
				D) printf "│   - %s\n" "$file" ;;
				*) printf "│   ~ %s\n" "$file" ;;
				esac
			done <<<"$changes"
		fi

		echo "│"
		printf "│ update? [y/N] "
		read -r answer </dev/tty
		echo "└─────────────────────────────────────────────────────"

		if [[ "${answer,,}" == "y" ]]; then
			git -C "$repo_dir" pull --ff-only --quiet
			echo "✓ $name updated to $latest"
		else
			echo "  $name skipped"
		fi
	done

	[[ $found -eq 0 ]] && echo "no managed repos found in $REPOS_DIR"
	return 0
}
