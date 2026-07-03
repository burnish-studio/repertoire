#!/usr/bin/env bash
set -euo pipefail

REP="$(cd "$(dirname "$0")/.." && pwd)/bin/rep.mjs"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [ ! -f "$REP" ]; then
  echo "ERROR: rep.mjs not found at $REP"
  exit 1
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "  PASS: $*"; }

# ── helpers ─────────────────────────────────────────────────────────────────

json_field() {
  node -e "const d=require('$1'); console.log(d.$2 || '')"
}

file_contains() {
  grep -qF "$2" "$1" 2>/dev/null
}

# ── setup ───────────────────────────────────────────────────────────────────

cd "$TMPDIR"
git init --quiet
git config user.email "test@test.test"
git config user.name "Test"
git commit --allow-empty -m "empty" --quiet

echo "=== Test 1: init ==="

node "$REP" init --skills write-a-skill,audit

# Tree exists as specified
[ -d ".agents/skills/write-a-skill" ] || fail "skill dir not created"
[ -f ".agents/skills/write-a-skill/SKILL.md" ] || fail "SKILL.md missing"
[ -f ".agents/skills/audit/SKILL.md" ] || fail "audit SKILL.md missing"
[ -d ".agents/standards/fallibilism" ] || fail "standards not created"
[ -f ".agents/standards/fallibilism/STANDARD.md" ] || fail "standard file missing"
[ -d ".agents/templates/frontmatter" ] || fail "templates not created"
[ -f ".agents/base/bootstrap.md" ] || fail "bootstrap missing"
pass "tree exists"

# Lock is valid JSON with correct hashes
LOCK=".agents/repertoire.lock"
[ -f "$LOCK" ] || fail "lockfile missing"
node -e "JSON.parse(require('fs').readFileSync('$LOCK','utf-8'))" || fail "lock not valid JSON"

# Verify hashes: every file in lock matches current content
node --input-type=module -e "
import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
const lock = JSON.parse(readFileSync('$LOCK', 'utf-8'));
let ok = true;
for (const [f, h] of Object.entries(lock.files)) {
  const actual = createHash('sha256').update(readFileSync(f, 'utf-8')).digest('hex');
  if (actual !== h) { console.error('Hash mismatch:', f); ok = false; }
}
if (!ok) process.exit(1);
" || fail "lock hashes don't match content"
pass "lock hashes valid"

# AGENTS.md has marker block with bootstrap + one ### section per standard
[ -f "AGENTS.md" ] || fail "AGENTS.md missing"
file_contains "AGENTS.md" '<!-- repertoire:start -->' || fail "marker start missing"
file_contains "AGENTS.md" '<!-- repertoire:end -->' || fail "marker end missing"
file_contains "AGENTS.md" 'This project carries repertoire' || fail "bootstrap text missing"
file_contains "AGENTS.md" '## Operative norms' || fail "operative norms heading missing"

# Count ### sections (excluding the bootstrap section)
STD_COUNT=$(grep -c '^### ' AGENTS.md || true)
PKG_STD_COUNT=$(ls -1d "$REPO_DIR"/standards/*/ | wc -l)
[ "$STD_COUNT" -eq "$PKG_STD_COUNT" ] || fail "standard count in block: $STD_COUNT, expected $PKG_STD_COUNT"
pass "stance block valid ($STD_COUNT standard sections)"

# CLAUDE.md has @AGENTS.md
file_contains "CLAUDE.md" '@AGENTS.md' || fail "CLAUDE.md missing @AGENTS.md pointer"
pass "CLAUDE.md pointer present"

# Symlinks resolve
for link in .claude/skills/*; do
  if [ -L "$link" ]; then
    TARGET=$(readlink "$link")
    [ -d "$link/../$TARGET" ] || fail "symlink $link → $TARGET does not resolve"
  fi
done
pass "skill symlinks resolve"

echo ""
echo "=== Test 2: byte-clean removal ==="

node "$REP" remove --all

# git status should be empty
if [ -n "$(git status --porcelain)" ]; then
  echo "Files left behind:"
  git status --porcelain
  fail "byte-clean removal: files left behind"
fi
pass "byte-clean removal"

echo ""
echo "=== Test 3: pre-existing files survive ==="

# Re-init git
rm -rf .git
git init --quiet
git config user.email "test@test.test"
git config user.name "Test"

# Create pre-existing AGENTS.md and CLAUDE.md with user content
echo "# My Project

Some user content here." > AGENTS.md
echo "# Claude Instructions

My custom claude stuff." > CLAUDE.md

# Snapshot original content
ORIG_AGENTS=$(cat AGENTS.md)
ORIG_CLAUDE=$(cat CLAUDE.md)

git add -A && git commit -m "pre-existing" --quiet

node "$REP" init --skills write-a-skill

# AGENTS.md should still start with user content
grep -q "^# My Project" AGENTS.md || fail "AGENTS.md lost user heading"
grep -q "Some user content here" AGENTS.md || fail "AGENTS.md lost user content"
file_contains "AGENTS.md" '<!-- repertoire:start -->' || fail "stance block not added to existing AGENTS.md"
pass "AGENTS.md user content preserved, block added"

# CLAUDE.md should have @AGENTS.md appended
grep -q "^# Claude Instructions" CLAUDE.md || fail "CLAUDE.md lost user heading"
file_contains "CLAUDE.md" '@AGENTS.md' || fail "pointer not added to existing CLAUDE.md"
pass "CLAUDE.md user content preserved, pointer added"

# Now remove --all
node "$REP" remove --all

RESTORED_AGENTS=$(cat AGENTS.md)
RESTORED_CLAUDE=$(cat CLAUDE.md)

[ "$ORIG_AGENTS" = "$RESTORED_AGENTS" ] || fail "AGENTS.md not restored byte-identical"
[ "$ORIG_CLAUDE" = "$RESTORED_CLAUDE" ] || fail "CLAUDE.md not restored byte-identical"
pass "both files restored byte-identical"

echo ""
echo "=== Test 4: add/remove round-trip ==="

# Clean up for fresh test
rm -rf .git .agents .claude AGENTS.md CLAUDE.md
git init --quiet
git config user.email "test@test.test"
git config user.name "Test"
git commit --allow-empty -m "empty" --quiet

node "$REP" init --skills write-a-skill

# Ensure codify is NOT there
[ ! -d ".agents/skills/codify" ] || fail "codify should not be present initially"

node "$REP" add codify
[ -d ".agents/skills/codify" ] || fail "codify not added"
file_contains ".agents/repertoire.lock" '"codify"' || fail "codify not in lock skills list"
[ -L ".claude/skills/codify" ] || fail "codify symlink not created"
pass "add works"

node "$REP" remove codify
[ ! -d ".agents/skills/codify" ] || fail "codify not removed"
[ ! -L ".claude/skills/codify" ] || fail "codify symlink not removed"
pass "remove works"

echo ""
echo "=== Test 5: drift detection ==="

# Hand-edit a vendored file
echo "DRIFT CONTENT" >> .agents/skills/write-a-skill/SKILL.md

# status should exit non-zero and name the file
if node "$REP" status > /dev/null 2>&1; then
  fail "status should exit non-zero after drift"
fi
STATUS_OUT=$(node "$REP" status 2>&1 || true)
echo "$STATUS_OUT" | grep -q "DRIFTED" || fail "status should report DRIFTED"
pass "status detects drift"

# update should refuse without --force
if node "$REP" update 2>&1; then
  fail "update should refuse without --force on drifted file"
fi
pass "update refuses without --force"

# update --force should succeed
node "$REP" update --force
# After force update, status should be clean
node "$REP" status > /dev/null || fail "status not clean after --force update"
pass "update --force works"

echo ""
echo "=== Test 6: authored norm ==="

mkdir -p .agents/standards/test-local
cat > .agents/standards/test-local/STANDARD.md << 'STDEOF'
---
type: standard
title: Test Local Standard
created: 2026-07-03
updated: 2026-07-03
status: current
model: test
---

# Test Local Standard

Every project must have a local standard for testing purposes.

---

This is the thesis explaining why local standards matter.
STDEOF

node "$REP" compile
file_contains "AGENTS.md" "Test Local Standard" || fail "authored standard title not in block"
file_contains "AGENTS.md" "Every project must have a local standard" || fail "authored norm not in block"
pass "authored norm enters stance block"

# remove --all should leave authored standard in place
node "$REP" remove --all
[ -d ".agents/standards/test-local" ] || fail "authored standard removed by remove --all"
[ -f ".agents/standards/test-local/STANDARD.md" ] || fail "authored STANDARD.md removed"
pass "authored standard survives remove --all"

echo ""
echo "=== Test 7: --all-skills ==="

rm -rf .git .agents .claude AGENTS.md CLAUDE.md
git init --quiet
git config user.email "test@test.test"
git config user.name "Test"
git commit --allow-empty -m "empty" --quiet

ALL_COUNT=$(ls -1d "$REPO_DIR"/skills/*/ | wc -l)
node "$REP" init --all-skills

VENDORED=$(ls -1d .agents/skills/*/ | wc -l)
[ "$VENDORED" -eq "$ALL_COUNT" ] || fail "--all-skills: vendored $VENDORED, expected $ALL_COUNT"
pass "--all-skills vendored all $ALL_COUNT skills"

echo ""
echo "=== Test 8: update never claims authored content ==="

rm -rf .git .agents .claude AGENTS.md CLAUDE.md
git init --quiet
git config user.email "test@test.test"
git config user.name "Test"
git commit --allow-empty -m "empty" --quiet

node "$REP" init --skills write-a-skill

mkdir -p .agents/standards/test-local
cat > .agents/standards/test-local/STANDARD.md << 'STDEOF'
---
type: standard
title: Test Local Standard
created: 2026-07-03
updated: 2026-07-03
status: current
model: test
---

# Test Local Standard

Every project must have a local standard for testing purposes.

---

This is the thesis explaining why local standards matter.
STDEOF

node "$REP" compile
node "$REP" update

if grep -q "test-local" ".agents/repertoire.lock"; then
  fail "update claimed the authored standard into the lock"
fi
pass "authored standard stays outside the lock after update"

node "$REP" remove --all
[ -f ".agents/standards/test-local/STANDARD.md" ] || fail "authored standard deleted after update + remove --all"
pass "authored standard survives update + remove --all"

echo ""
echo "=== Test 9: byte-identical restore with trailing whitespace ==="

rm -rf .git .agents .claude AGENTS.md CLAUDE.md
git init --quiet
git config user.email "test@test.test"
git config user.name "Test"

printf 'My project notes.\n\n\n' > AGENTS.md
printf '# Claude notes\n\nStuff.\n\n' > CLAUDE.md
git add -A && git commit -m "messy whitespace" --quiet

node "$REP" init --skills write-a-skill
node "$REP" remove --all

if [ -n "$(git status --porcelain)" ]; then
  git status --porcelain
  git diff
  fail "round-trip altered files with trailing blank lines"
fi
pass "byte-identical restore including trailing whitespace"

echo ""
echo "=== Test 10: refuses to clobber a user-owned .claude/skills dir ==="

rm -rf .git .agents .claude AGENTS.md CLAUDE.md
git init --quiet
git config user.email "test@test.test"
git config user.name "Test"

mkdir -p .claude/skills/audit
echo "the project's own audit skill" > .claude/skills/audit/SKILL.md
git add -A && git commit -m "user skill" --quiet

if node "$REP" init --skills write-a-skill,audit > /dev/null 2>&1; then
  fail "init should refuse when .claude/skills/<name> is a real directory"
fi
[ -f ".claude/skills/audit/SKILL.md" ] || fail "user skill dir was destroyed"
if [ -n "$(git status --porcelain)" ]; then
  git status --porcelain
  fail "refused init still left changes behind"
fi
pass "init refuses cleanly and touches nothing"

echo ""
echo "=== All tests passed ==="
