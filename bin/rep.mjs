#!/usr/bin/env node

import { readFileSync, writeFileSync, readdirSync, statSync, lstatSync, cpSync, rmSync, mkdirSync, existsSync, symlinkSync, readlinkSync } from 'node:fs';
import { join, dirname, relative, resolve } from 'node:path';
import { createHash } from 'node:crypto';
import { execSync } from 'node:child_process';
import { argv, exit, stdout } from 'node:process';
import { fileURLToPath } from 'node:url';

// ── resolve package directory ──────────────────────────────────────────────

const __filename = fileURLToPath(import.meta.url);
const PKG_DIR = resolve(dirname(__filename), '..');

// ── helpers ─────────────────────────────────────────────────────────────────

function sha256(content) {
  return createHash('sha256').update(content).digest('hex');
}

function isDir(p) { try { return statSync(p).isDirectory(); } catch { return false; } }
function isFile(p) { try { return statSync(p).isFile(); } catch { return false; } }
function isSymlink(p) { try { return lstatSync(p, { throwIfNoEntry: false })?.isSymbolicLink() ?? false; } catch { return false; } }

function readFile(p) { return readFileSync(p, 'utf-8'); }
function writeFile(p, content) {
  mkdirSync(dirname(p), { recursive: true });
  writeFileSync(p, content, 'utf-8');
}

function copyDir(src, dst) {
  rmSync(dst, { recursive: true, force: true });
  cpSync(src, dst, { recursive: true });
}

function removeDirIfEmpty(dir, projectRoot) {
  const resolved = resolve(projectRoot, dir);
  if (!isDir(resolved)) return;
  // Walk up from the deepest path, removing empty directories
  let current = resolved;
  while (true) {
    const entries = readdirSync(current);
    if (entries.length > 0) break;
    rmSync(current, { recursive: true });
    const parent = dirname(current);
    if (parent === projectRoot || !parent.startsWith(projectRoot)) break;
    current = parent;
  }
}

// List all files under a directory recursively (relative paths)
function listFiles(dir, base) {
  const files = [];
  const entries = readdirSync(dir, { withFileTypes: true });
  for (const e of entries) {
    const full = join(dir, e.name);
    if (e.isDirectory()) {
      files.push(...listFiles(full, base));
    } else if (e.isFile()) {
      files.push(relative(base, full));
    }
  }
  return files;
}

// ── resolve available content from the package ──────────────────────────────

function pkgSkills() {
  const dir = join(PKG_DIR, 'skills');
  return readdirSync(dir, { withFileTypes: true })
    .filter(e => e.isDirectory())
    .map(e => e.name);
}

function pkgStandards() {
  const dir = join(PKG_DIR, 'standards');
  return readdirSync(dir, { withFileTypes: true })
    .filter(e => e.isDirectory())
    .map(e => e.name);
}

function pkgTemplates() {
  const dir = join(PKG_DIR, 'templates');
  return readdirSync(dir, { withFileTypes: true })
    .filter(e => e.isDirectory())
    .map(e => e.name);
}

function resolveRef() {
  try {
    const pkg = JSON.parse(readFile(join(PKG_DIR, 'package.json')));
    if (pkg.gitHead) return pkg.gitHead;
  } catch {}
  try {
    return execSync('git rev-parse HEAD', { cwd: PKG_DIR, encoding: 'utf-8', stdio: ['ignore', 'pipe', 'ignore'] }).trim();
  } catch {
    return 'unknown';
  }
}

// ── norm extraction ─────────────────────────────────────────────────────────

function extractNorm(standardPath) {
  const raw = readFile(standardPath);

  // Strip YAML frontmatter (first --- delimited block)
  let body = raw;
  if (body.startsWith('---')) {
    const end = body.indexOf('---', 3);
    if (end !== -1) body = body.slice(end + 3);
  }

  // Strip leading blank lines
  body = body.replace(/^\n+/, '');

  // Strip the h1 line (first # heading)
  body = body.replace(/^# .*\n/, '');

  // Strip leading blank lines again
  body = body.replace(/^\n+/, '');

  // Strip perspective reference line if present
  body = body.replace(/^_Perspective:.*\n/, '');

  // Strip leading blank lines again
  body = body.replace(/^\n+/, '');

  // Find the first --- rule (norm/thesis separator)
  const sepIdx = body.indexOf('\n---\n');
  if (sepIdx !== -1) {
    return body.slice(0, sepIdx).trimEnd();
  }

  // No separator: entire remaining body is the norm
  return body.trimEnd();
}

function extractTitle(standardPath) {
  const raw = readFile(standardPath);

  // Try frontmatter title first
  if (raw.startsWith('---')) {
    const end = raw.indexOf('---', 3);
    if (end !== -1) {
      const fm = raw.slice(3, end);
      const m = fm.match(/^title:\s*(.+)$/m);
      if (m) return m[1].trim();
    }
  }

  // Fall back to h1 text
  let body = raw;
  if (body.startsWith('---')) {
    const end = body.indexOf('---', 3);
    if (end !== -1) body = body.slice(end + 3);
  }
  const m = body.match(/^# (.+)$/m);
  return m ? m[1].trim() : 'Unknown';
}

// ── stance block compilation ────────────────────────────────────────────────

function compileStanceBlock(projectRoot) {
  const bootstrapPath = join(projectRoot, '.agents', 'base', 'bootstrap.md');
  const standardsDir = join(projectRoot, '.agents', 'standards');

  let block = '';
  block += '<!-- repertoire:start -->\n';
  block += readFile(bootstrapPath);
  block += '\n## Operative norms\n';

  if (isDir(standardsDir)) {
    const entries = readdirSync(standardsDir, { withFileTypes: true })
      .filter(e => e.isDirectory())
      .sort((a, b) => a.name.localeCompare(b.name));

    for (const entry of entries) {
      const stdPath = join(standardsDir, entry.name, 'STANDARD.md');
      if (!isFile(stdPath)) continue;
      const title = extractTitle(stdPath);
      const norm = extractNorm(stdPath);
      block += `\n### ${title}\n${norm}\n`;
    }
  }

  block += '<!-- repertoire:end -->\n';
  return block;
}

// ── stance block inject / extract / remove ──────────────────────────────────

const MARKER_START = '<!-- repertoire:start -->';
const MARKER_END = '<!-- repertoire:end -->';

function hasStanceBlock(agentsPath) {
  if (!isFile(agentsPath)) return false;
  const content = readFile(agentsPath);
  return content.includes(MARKER_START) && content.includes(MARKER_END);
}

function readStanceBlock(agentsPath) {
  const content = readFile(agentsPath);
  const start = content.indexOf(MARKER_START);
  const end = content.indexOf(MARKER_END);
  if (start === -1 || end === -1) return null;
  return content.slice(start, end + MARKER_END.length);
}

function injectStanceBlock(projectRoot, block) {
  const agentsPath = join(projectRoot, 'AGENTS.md');

  if (isFile(agentsPath)) {
    let content = readFile(agentsPath);
    if (hasStanceBlock(agentsPath)) {
      // Replace existing block
      const start = content.indexOf(MARKER_START);
      const end = content.indexOf(MARKER_END) + MARKER_END.length;
      content = content.slice(0, start) + block.trimEnd() + '\n' + content.slice(end);
    } else {
      // Append block at end. Never normalise the user's bytes — removal must
      // restore the original file exactly.
      const sep = (content === '' || content.endsWith('\n')) ? '' : '\n';
      content = content + sep + block;
    }
    writeFile(agentsPath, content);
  } else {
    writeFile(agentsPath, block);
  }
}

function removeStanceBlock(projectRoot, created) {
  const agentsPath = join(projectRoot, 'AGENTS.md');
  if (!isFile(agentsPath)) return;

  const content = readFile(agentsPath);
  const start = content.indexOf(MARKER_START);
  let end = content.indexOf(MARKER_END);

  if (start === -1 || end === -1) return;
  end += MARKER_END.length;
  if (content[end] === '\n') end += 1;

  // Remove exactly the block (plus its trailing newline); the surrounding
  // bytes are the user's and are restored untouched.
  const remaining = content.slice(0, start) + content.slice(end);

  if (remaining.trim() === '' && created) {
    rmSync(agentsPath);
  } else {
    writeFile(agentsPath, remaining);
  }
}

// ── pointer (CLAUDE.md) operations ──────────────────────────────────────────

const POINTER_LINE = '@AGENTS.md';

function hasPointer(claudePath) {
  if (!isFile(claudePath)) return false;
  const content = readFile(claudePath);
  return content.split('\n').some(line => line.trim() === POINTER_LINE);
}

function injectPointer(projectRoot) {
  const claudePath = join(projectRoot, 'CLAUDE.md');
  if (hasPointer(claudePath)) return;

  if (isFile(claudePath)) {
    const content = readFile(claudePath);
    const sep = (content === '' || content.endsWith('\n')) ? '' : '\n';
    writeFile(claudePath, content + sep + POINTER_LINE + '\n');
  } else {
    writeFile(claudePath, POINTER_LINE + '\n');
  }
}

function removePointer(projectRoot, created) {
  const claudePath = join(projectRoot, 'CLAUDE.md');
  if (!isFile(claudePath)) return;

  const content = readFile(claudePath);
  const lines = content.split('\n').filter(line => line.trim() !== POINTER_LINE);
  const newContent = lines.join('\n');
  if (newContent === content) return;

  if (newContent.trim() === '' && created) {
    rmSync(claudePath);
  } else {
    writeFile(claudePath, newContent);
  }
}

// ── skill symlinks (.claude/skills/<name> → ../../.agents/skills/<name>) ────

// A real file or directory at .claude/skills/<name> belongs to the project;
// rep must refuse rather than replace it. Call before vendoring anything.
function assertSymlinkTargetsFree(projectRoot, skillNames) {
  for (const name of skillNames) {
    const linkPath = join(projectRoot, '.claude', 'skills', name);
    if (existsSync(linkPath) && !isSymlink(linkPath)) {
      console.log(`Error: .claude/skills/${name} already exists and is not a symlink — refusing to touch it.`);
      exit(1);
    }
  }
}

function createSkillSymlinks(projectRoot, skillNames) {
  const claudeSkillsDir = join(projectRoot, '.claude', 'skills');
  assertSymlinkTargetsFree(projectRoot, skillNames);
  mkdirSync(claudeSkillsDir, { recursive: true });

  for (const name of skillNames) {
    const linkPath = join(claudeSkillsDir, name);
    const target = join('..', '..', '.agents', 'skills', name);
    if (isSymlink(linkPath)) {
      // Already exists — verify it points correctly
      const current = readlinkSync(linkPath);
      if (current === target) continue;
      rmSync(linkPath);
    }
    symlinkSync(target, linkPath);
  }
}

function removeSkillSymlinks(projectRoot, skillNames) {
  const claudeSkillsDir = join(projectRoot, '.claude', 'skills');
  if (!isDir(claudeSkillsDir)) return;

  for (const name of skillNames) {
    const linkPath = join(claudeSkillsDir, name);
    // Only ever remove symlinks — a real file or directory here is the project's.
    if (isSymlink(linkPath)) {
      rmSync(linkPath);
    }
  }

  // Clean up empty .claude/skills and .claude dirs
  removeDirIfEmpty('.claude/skills', projectRoot);
  removeDirIfEmpty('.claude', projectRoot);
}

// ── snap a new project — record what already exists ─────────────────────────

function snapshotPreExisting(projectRoot) {
  return {
    agentsMd: isFile(join(projectRoot, 'AGENTS.md')),
    claudeMd: isFile(join(projectRoot, 'CLAUDE.md')),
  };
}

// ── lockfile ────────────────────────────────────────────────────────────────

function readLock(projectRoot) {
  const lockPath = join(projectRoot, '.agents', 'repertoire.lock');
  if (!isFile(lockPath)) return null;
  return JSON.parse(readFile(lockPath));
}

function writeLock(projectRoot, lock) {
  const lockPath = join(projectRoot, '.agents', 'repertoire.lock');
  writeFile(lockPath, JSON.stringify(lock, null, 2) + '\n');
}

function buildLock(projectRoot, skillNames, stdNames, tmplNames, preExisting, ref) {
  const files = {};

  // Record all vendored files with hashes. Only the named vendored sets are
  // claimed — authored artefacts sharing the tree stay outside the lock.
  const agentsDir = join(projectRoot, '.agents');

  // Skills
  for (const name of skillNames) {
    const skillDir = join(agentsDir, 'skills', name);
    const skillFiles = listFiles(skillDir, agentsDir);
    for (const f of skillFiles) {
      files['.agents/' + f] = sha256(readFile(join(agentsDir, f)));
    }
  }

  // Standards
  for (const name of stdNames) {
    const dir = join(agentsDir, 'standards', name);
    if (!isDir(dir)) continue;
    for (const f of listFiles(dir, agentsDir)) {
      files['.agents/' + f] = sha256(readFile(join(agentsDir, f)));
    }
  }

  // Templates
  for (const name of tmplNames) {
    const dir = join(agentsDir, 'templates', name);
    if (!isDir(dir)) continue;
    for (const f of listFiles(dir, agentsDir)) {
      files['.agents/' + f] = sha256(readFile(join(agentsDir, f)));
    }
  }

  // Base
  const baseDir = join(agentsDir, 'base');
  const baseFiles = listFiles(baseDir, agentsDir);
  for (const f of baseFiles) {
    files['.agents/' + f] = sha256(readFile(join(agentsDir, f)));
  }

  // Build wiring record
  const symlinks = skillNames.map(n => `.claude/skills/${n}`);

  return {
    version: 1,
    source: 'github:burnish-studio/repertoire',
    ref,
    skills: [...skillNames].sort(),
    files,
    wiring: {
      stance: { file: 'AGENTS.md', created: !preExisting.agentsMd },
      pointers: [{ file: 'CLAUDE.md', created: !preExisting.claudeMd }],
      symlinks,
    },
  };
}

// ── authorised file set from lock ───────────────────────────────────────────

function lockListedPaths(lock) {
  const paths = new Set();
  for (const f of Object.keys(lock.files)) {
    paths.add(f);
  }
  for (const sl of (lock.wiring.symlinks || [])) {
    paths.add(sl);
  }
  return paths;
}

// ── commands ────────────────────────────────────────────────────────────────

function cmdInit(projectRoot, skillNames) {
  if (readLock(projectRoot)) {
    console.log('Error: repertoire is already initialised in this project (repertoire.lock exists).');
    exit(1);
  }

  // Pre-flight: fail before touching anything
  const available = new Set(pkgSkills());
  for (const name of skillNames) {
    if (!available.has(name)) {
      console.log(`Error: skill '${name}' not found in repertoire. Available: ${[...available].sort().join(', ')}`);
      exit(1);
    }
  }
  assertSymlinkTargetsFree(projectRoot, skillNames);

  const preExisting = snapshotPreExisting(projectRoot);
  const ref = resolveRef();

  console.log(`Initialising repertoire in ${projectRoot}`);

  // 1. Vendor standards (all, indivisible)
  const stdNames = pkgStandards();
  for (const name of stdNames) {
    const src = join(PKG_DIR, 'standards', name);
    const dst = join(projectRoot, '.agents', 'standards', name);
    copyDir(src, dst);
  }
  console.log(`  Vendored ${stdNames.length} standards`);

  // 2. Vendor templates (all)
  const tmplNames = pkgTemplates();
  for (const name of tmplNames) {
    const src = join(PKG_DIR, 'templates', name);
    const dst = join(projectRoot, '.agents', 'templates', name);
    copyDir(src, dst);
  }
  console.log(`  Vendored ${tmplNames.length} templates`);

  // 3. Vendor base
  copyDir(join(PKG_DIR, 'base'), join(projectRoot, '.agents', 'base'));
  console.log('  Vendored base/bootstrap.md');

  // 4. Vendor skills
  for (const name of skillNames) {
    copyDir(join(PKG_DIR, 'skills', name), join(projectRoot, '.agents', 'skills', name));
  }
  console.log(`  Vendored ${skillNames.length} skills: ${skillNames.join(', ')}`);

  // 5. Stance block
  const block = compileStanceBlock(projectRoot);
  injectStanceBlock(projectRoot, block);
  console.log(`  Injected stance block into AGENTS.md ${preExisting.agentsMd ? '(appended to existing file)' : '(created)'}`);

  // 6. Claude Code pointer
  injectPointer(projectRoot);
  console.log(`  Wrote CLAUDE.md pointer ${preExisting.claudeMd ? '(appended to existing file)' : '(created)'}`);

  // 7. Skill symlinks
  createSkillSymlinks(projectRoot, skillNames);
  console.log(`  Created ${skillNames.length} skill symlinks in .claude/skills/`);

  // 8. Lockfile
  const lock = buildLock(projectRoot, skillNames, stdNames, tmplNames, preExisting, ref);
  writeLock(projectRoot, lock);
  console.log('  Wrote repertoire.lock');

  console.log('\nRepertoire initialised.');
}

function cmdAdd(projectRoot, skillNames) {
  const lock = readLock(projectRoot);
  if (!lock) {
    console.log('Error: repertoire is not initialised in this project. Run `rep init` first.');
    exit(1);
  }

  // Pre-flight: fail before touching anything
  const available = new Set(pkgSkills());
  const toAdd = skillNames.filter(n => !lock.skills.includes(n));
  for (const name of toAdd) {
    if (!available.has(name)) {
      console.log(`Error: skill '${name}' not found in repertoire. Available: ${[...available].sort().join(', ')}`);
      exit(1);
    }
  }
  assertSymlinkTargetsFree(projectRoot, toAdd);

  for (const name of skillNames) {
    if (lock.skills.includes(name)) {
      console.log(`  Skill '${name}' is already vendored — skipping`);
      continue;
    }

    copyDir(join(PKG_DIR, 'skills', name), join(projectRoot, '.agents', 'skills', name));

    // Add files to lock
    const skillDir = join(projectRoot, '.agents', 'skills', name);
    const skillFiles = listFiles(skillDir, join(projectRoot, '.agents'));
    for (const f of skillFiles) {
      lock.files['.agents/' + f] = sha256(readFile(join(projectRoot, '.agents', f)));
    }

    lock.skills.push(name);
    lock.skills.sort();

    // Add symlink
    createSkillSymlinks(projectRoot, [name]);
    lock.wiring.symlinks.push(`.claude/skills/${name}`);
    lock.wiring.symlinks.sort();

    console.log(`  Added skill '${name}'`);
  }

  lock.ref = resolveRef();
  writeLock(projectRoot, lock);
}

function cmdRemove(projectRoot, skillNames) {
  const lock = readLock(projectRoot);
  if (!lock) {
    console.log('Error: repertoire is not initialised in this project. Run `rep init` first.');
    exit(1);
  }

  for (const name of skillNames) {
    if (!lock.skills.includes(name)) {
      console.log(`  Error: skill '${name}' is not in the lock (it may be an authored skill — rep only removes vendored skills)`);
      exit(1);
    }

    // Remove skill dir
    const skillDir = join(projectRoot, '.agents', 'skills', name);
    rmSync(skillDir, { recursive: true, force: true });

    // Remove from lock.skills
    lock.skills = lock.skills.filter(s => s !== name);

    // Remove file entries from lock
    const prefix = `.agents/skills/${name}/`;
    for (const f of Object.keys(lock.files)) {
      if (f.startsWith(prefix)) delete lock.files[f];
    }

    // Remove symlink
    removeSkillSymlinks(projectRoot, [name]);
    const symlinkPath = `.claude/skills/${name}`;
    lock.wiring.symlinks = lock.wiring.symlinks.filter(s => s !== symlinkPath);

    // Clean up empty dirs
    removeDirIfEmpty(`.agents/skills/${name}`, projectRoot);

    console.log(`  Removed skill '${name}'`);
  }

  lock.ref = resolveRef();
  writeLock(projectRoot, lock);
}

function cmdRemoveAll(projectRoot) {
  const lock = readLock(projectRoot);
  if (!lock) {
    console.log('Error: repertoire is not initialised in this project.');
    exit(1);
  }

  console.log(`Removing repertoire from ${projectRoot}`);

  // 1. Delete all vendored files listed in lock.files
  const agentsDir = join(projectRoot, '.agents');
  for (const f of Object.keys(lock.files)) {
    const p = join(projectRoot, f);
    if (isFile(p) || isSymlink(p)) {
      rmSync(p, { force: true });
    } else if (isDir(p)) {
      // Shouldn't happen for files, but handle dirs too
      rmSync(p, { recursive: true, force: true });
    }
  }

  // 2. Remove stance block (file deleted only if rep created it and it is now empty)
  removeStanceBlock(projectRoot, lock.wiring.stance.created);

  // 3. Remove pointer (same rule)
  removePointer(projectRoot, lock.wiring.pointers?.[0]?.created ?? false);

  // 4. Remove symlinks
  removeSkillSymlinks(projectRoot, lock.skills);

  // 5. Remove now-empty directories that rep created
  for (const cat of ['skills', 'standards', 'templates', 'base']) {
    removeDirIfEmpty(`.agents/${cat}`, projectRoot);
  }

  // 6. Remove lockfile last, then the .agents dir itself if nothing else remains
  const lockPath = join(projectRoot, '.agents', 'repertoire.lock');
  if (isFile(lockPath)) rmSync(lockPath);
  removeDirIfEmpty('.agents', projectRoot);

  console.log('Repertoire removed.');
}

function cmdUpdate(projectRoot, opts) {
  const lock = readLock(projectRoot);
  if (!lock) {
    console.log('Error: repertoire is not initialised in this project.');
    exit(1);
  }

  // Check for drift
  const drifted = [];
  for (const [f, storedHash] of Object.entries(lock.files)) {
    const p = join(projectRoot, f);
    if (!isFile(p)) {
      drifted.push({ file: f, issue: 'missing' });
      continue;
    }
    const currentHash = sha256(readFile(p));
    if (currentHash !== storedHash) {
      drifted.push({ file: f, issue: 'modified' });
    }
  }

  if (drifted.length > 0) {
    console.log('Drifted files detected:');
    for (const d of drifted) {
      console.log(`  ${d.file} — ${d.issue}`);
    }
    if (!opts.force) {
      console.log('\nUse --force to overwrite drifted files. Drift indicates hand-edited vendored content;');
      console.log('consider creating an authored standard or skill instead.');
      exit(1);
    }
    console.log('  --force: overwriting drifted files');
  }

  // Capture old stance block for diff
  const agentsPath = join(projectRoot, 'AGENTS.md');
  const oldStance = hasStanceBlock(agentsPath) ? readStanceBlock(agentsPath) : '';

  // Re-vendor all files from the package
  // Standards
  const stdNames = pkgStandards();
  for (const name of stdNames) {
    const src = join(PKG_DIR, 'standards', name);
    const dst = join(projectRoot, '.agents', 'standards', name);
    copyDir(src, dst);
  }

  // Templates
  const tmplNames = pkgTemplates();
  for (const name of tmplNames) {
    const src = join(PKG_DIR, 'templates', name);
    const dst = join(projectRoot, '.agents', 'templates', name);
    copyDir(src, dst);
  }

  // Base
  copyDir(join(PKG_DIR, 'base'), join(projectRoot, '.agents', 'base'));

  // Skills
  for (const name of lock.skills) {
    const src = join(PKG_DIR, 'skills', name);
    if (!isDir(src)) {
      console.log(`  Warning: skill '${name}' no longer exists in repertoire — keeping current copy`);
      continue;
    }
    const dst = join(projectRoot, '.agents', 'skills', name);
    copyDir(src, dst);
  }

  // Recompile stance block
  const newBlock = compileStanceBlock(projectRoot);
  injectStanceBlock(projectRoot, newBlock);

  // Print diff of stance block (normalise trailing whitespace for comparison)
  if (oldStance.trim() !== newBlock.trim()) {
    console.log('\nStance block changed:');
    printDiff(oldStance, newBlock);
  } else {
    console.log('\nStance block unchanged.');
  }

  // Rebuild lock
  const preExisting = { agentsMd: true, claudeMd: isFile(join(projectRoot, 'CLAUDE.md')) };
  const newLock = buildLock(projectRoot, lock.skills, stdNames, tmplNames, preExisting, resolveRef());
  // Preserve original created flags
  newLock.wiring.stance.created = lock.wiring.stance.created;
  if (lock.wiring.pointers?.length > 0 && newLock.wiring.pointers?.length > 0) {
    newLock.wiring.pointers[0].created = lock.wiring.pointers[0].created;
  }
  writeLock(projectRoot, newLock);

  console.log(`\nRepertoire updated to ref ${newLock.ref}.`);
}

function cmdCompile(projectRoot) {
  const lock = readLock(projectRoot);
  if (!lock) {
    console.log('Error: repertoire is not initialised in this project.');
    exit(1);
  }

  const block = compileStanceBlock(projectRoot);
  injectStanceBlock(projectRoot, block);
  console.log('Stance block recompiled from all standards in .agents/standards/.');
}

function cmdStatus(projectRoot) {
  const lock = readLock(projectRoot);
  if (!lock) {
    console.log('Repertoire is not initialised in this project.');
    exit(1);
  }

  let ok = true;
  const issues = [];

  // Check file hashes
  for (const [f, storedHash] of Object.entries(lock.files)) {
    const p = join(projectRoot, f);
    if (!isFile(p)) {
      issues.push(`  MISSING  ${f}`);
      ok = false;
      continue;
    }
    const currentHash = sha256(readFile(p));
    if (currentHash !== storedHash) {
      issues.push(`  DRIFTED  ${f}`);
      ok = false;
    }
  }

  // Check symlinks
  for (const sl of (lock.wiring.symlinks || [])) {
    const p = join(projectRoot, sl);
    if (!isSymlink(p)) {
      if (!existsSync(p)) {
        issues.push(`  MISSING  ${sl} (symlink)`);
        ok = false;
      } else {
        issues.push(`  BROKEN   ${sl} (not a symlink)`);
        ok = false;
      }
    }
  }

  // Check stance block presence and freshness
  const agentsPath = join(projectRoot, 'AGENTS.md');
  if (!hasStanceBlock(agentsPath)) {
    issues.push(`  MISSING  stance block in AGENTS.md`);
    ok = false;
  } else {
    const newBlock = compileStanceBlock(projectRoot);
    const existingBlock = readStanceBlock(agentsPath);
    if (newBlock.trimEnd() !== (existingBlock || '').trimEnd()) {
      issues.push(`  STALE    stance block (norms differ from .agents/standards/)`);
      ok = false;
    }
  }

  // Check pointer
  if (!hasPointer(join(projectRoot, 'CLAUDE.md'))) {
    issues.push(`  MISSING  CLAUDE.md pointer (@AGENTS.md)`);
    ok = false;
  }

  // Count authored artefacts. Vendored names come from the lock — the lock is
  // the ownership boundary, not whatever the running package happens to contain.
  const vendoredStdNames = new Set();
  const vendoredTmplNames = new Set();
  for (const f of Object.keys(lock.files)) {
    let m = f.match(/^\.agents\/standards\/([^/]+)\//);
    if (m) vendoredStdNames.add(m[1]);
    m = f.match(/^\.agents\/templates\/([^/]+)\//);
    if (m) vendoredTmplNames.add(m[1]);
  }

  const authoredSkills = [];
  const authoredStandards = [];
  const authoredTemplates = [];

  const skillsDir = join(projectRoot, '.agents', 'skills');
  if (isDir(skillsDir)) {
    for (const entry of readdirSync(skillsDir, { withFileTypes: true })) {
      if (entry.isDirectory() && !lock.skills.includes(entry.name)) {
        authoredSkills.push(entry.name);
      }
    }
  }

  const stdsDir = join(projectRoot, '.agents', 'standards');
  if (isDir(stdsDir)) {
    for (const entry of readdirSync(stdsDir, { withFileTypes: true })) {
      if (entry.isDirectory() && !vendoredStdNames.has(entry.name)) {
        authoredStandards.push(entry.name);
      }
    }
  }

  const tmplDir = join(projectRoot, '.agents', 'templates');
  if (isDir(tmplDir)) {
    for (const entry of readdirSync(tmplDir, { withFileTypes: true })) {
      if (entry.isDirectory() && !vendoredTmplNames.has(entry.name)) {
        authoredTemplates.push(entry.name);
      }
    }
  }

  if (issues.length > 0) {
    console.log('Issues:');
    for (const i of issues) console.log(i);
    console.log('');
  }

  console.log(`Vendored: ${lock.skills.length} skills, ${vendoredStdNames.size} standards, ${vendoredTmplNames.size} templates, base`);
  if (authoredSkills.length > 0) console.log(`Authored skills: ${authoredSkills.join(', ')}`);
  if (authoredStandards.length > 0) console.log(`Authored standards: ${authoredStandards.join(', ')}`);
  if (authoredTemplates.length > 0) console.log(`Authored templates: ${authoredTemplates.join(', ')}`);

  if (ok) {
    console.log('\nClean — no issues.');
  } else {
    exit(1);
  }
}

// ── simple unified-diff-like output ─────────────────────────────────────────

function printDiff(oldText, newText) {
  const oldLines = oldText.split('\n');
  const newLines = newText.split('\n');

  let changed = false;
  const maxLen = Math.max(oldLines.length, newLines.length);
  for (let i = 0; i < maxLen; i++) {
    const oldL = i < oldLines.length ? oldLines[i] : null;
    const newL = i < newLines.length ? newLines[i] : null;
    if (oldL !== newL) {
      // Skip blank-line-only diffs
      if ((oldL === null || oldL.trim() === '') && (newL === null || newL.trim() === '')) continue;
      if (oldL !== null) console.log(`- ${oldL}`);
      if (newL !== null) console.log(`+ ${newL}`);
      changed = true;
    }
  }
  if (!changed) console.log('  (whitespace only)');
}

// ── CLI dispatcher ──────────────────────────────────────────────────────────

function usage() {
  stdout.write(`Usage: rep <command> [options]

Commands:
  init [--skills a,b,c | --all-skills]  Initialise repertoire in this project
  add <skill>...                         Add skills to the project
  remove <skill>...                      Remove vendored skills
  remove --all                           Remove repertoire entirely
  update [--force]                       Update vendored content from source
  compile                                Recompile the stance block
  status                                 Check integrity of the installation

Options:
  --skills     Comma-separated skill names (default: write-a-skill,write-a-standard,codify,audit)
  --all-skills Vendor all available skills
  --force      Overwrite drifted files on update
`);
}

function parseArgs(args) {
  const command = args[0];
  let i = 1;
  const opts = { force: false, allSkills: false, skills: null };
  const positional = [];

  while (i < args.length) {
    if (args[i] === '--force') {
      opts.force = true;
    } else if (args[i] === '--all-skills') {
      opts.allSkills = true;
    } else if (args[i] === '--skills') {
      opts.skills = args[++i];
    } else if (args[i] === '--all') {
      opts.all = true;
    } else if (args[i] && !args[i].startsWith('-')) {
      positional.push(args[i]);
    }
    i++;
  }

  return { command, opts, positional };
}

function main() {
  const args = argv.slice(2);
  if (args.length === 0 || args[0] === '--help' || args[0] === '-h') {
    usage();
    exit(0);
  }

  const { command, opts, positional } = parseArgs(args);
  const projectRoot = resolve('.');

  // Ensure we're not trying to operate outside a project directory
  if (!isDir(projectRoot)) {
    console.log('Error: current directory does not exist');
    exit(1);
  }

  switch (command) {
    case 'init': {
      let skillNames;
      if (opts.allSkills) {
        skillNames = pkgSkills();
      } else if (opts.skills) {
        skillNames = opts.skills.split(',').map(s => s.trim()).filter(Boolean);
        if (skillNames.length === 0) {
          console.log('Error: --skills requires at least one skill name');
          exit(1);
        }
      } else {
        skillNames = ['write-a-skill', 'write-a-standard', 'codify', 'audit'];
      }
      cmdInit(projectRoot, skillNames);
      break;
    }
    case 'add': {
      if (positional.length === 0) {
        console.log('Usage: rep add <skill>...');
        exit(1);
      }
      cmdAdd(projectRoot, positional);
      break;
    }
    case 'remove': {
      if (opts.all) {
        cmdRemoveAll(projectRoot);
      } else {
        if (positional.length === 0) {
          console.log('Usage: rep remove <skill>... or rep remove --all');
          exit(1);
        }
        cmdRemove(projectRoot, positional);
      }
      break;
    }
    case 'update': {
      cmdUpdate(projectRoot, opts);
      break;
    }
    case 'compile': {
      cmdCompile(projectRoot);
      break;
    }
    case 'status': {
      cmdStatus(projectRoot);
      break;
    }
    default: {
      console.log(`Unknown command: ${command}`);
      usage();
      exit(1);
    }
  }
}

main();
