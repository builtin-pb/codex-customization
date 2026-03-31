# Portable Codex Home Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make this repository the source of truth for managed Codex skills and agents, with a single-command symlink setup and explicit provenance manifests.

**Architecture:** The repo will own a `home/` tree for managed Codex content and a `catalog/` tree for provenance metadata. A one-time importer will copy the current active `~/.codex/skills` layout into repo-owned directories while skipping Codex system defaults, and `bootstrap/setup.sh` will link repo-owned paths into `~/.codex`.

**Tech Stack:** Git, Bash, TOML, Markdown, symlinks on macOS/Linux

---

### Task 1: Create Repository Skeleton And Maintenance Contract

**Files:**
- Create: `.gitignore`
- Create: `AGENTS.md`
- Create: `README.md`
- Create: `catalog/skills.toml`
- Create: `catalog/agents.toml`
- Create: `home/agents/.gitkeep`
- Create: `tests/bootstrap/.gitkeep`

- [x] **Step 1: Create the ignore file**
Observed: Created `.gitignore` with `.DS_Store`, `.codex-import-work/`, and `tmp/`.

```gitignore
.DS_Store
.codex-import-work/
tmp/
```

- [x] **Step 2: Create the initial skills manifest skeleton**
Observed: Added `catalog/skills.toml` as the tracked manifest root, then repopulated it during the real import with 92 `[[skill]]` entries.

```toml
# Source of truth for tracked skills in this repository.
# Each [[skill]] entry must be updated whenever a skill is added, removed, renamed, imported, or modified.
schema_version = 1

# Populated by bootstrap/import_current_home.sh during the initial import.
```

- [x] **Step 3: Create the initial agents manifest skeleton**
Observed: Added `catalog/agents.toml` and preserved it during later imports so future root-level agent metadata is not clobbered.

```toml
# Source of truth for tracked root-level agents in this repository.
# Nested agents that ship inside skills are tracked with the parent skill.
schema_version = 1

# No root-level agents are tracked yet.
```

- [x] **Step 4: Create the repository maintenance guide**
Observed: Wrote `AGENTS.md` with source-of-truth, provenance, and setup rules, including the final guard that `~/.codex/skills/.system` stays unmanaged and whole-tree upstream imports are not allowed unless explicitly requested.

```markdown
# AGENTS.md

## Purpose

This repository is the source of truth for the managed portion of `~/.codex`.

Initial managed scope:
- `home/skills/`
- `home/agents/`
- `catalog/skills.toml`
- `catalog/agents.toml`
- `bootstrap/setup.sh`

Unmanaged for now:
- `~/.codex/rules/`
- `~/.codex/scripts/`
- `~/.codex/memories/`
- caches, logs, sessions, sqlite files, auth files, snapshots, and other runtime state
- Codex-managed defaults under `~/.codex/skills/.system`

## Required Reading Before Any Maintenance Change

Read these files before changing tracked skills, agents, setup behavior, or provenance:
- `AGENTS.md`
- `README.md`
- `catalog/skills.toml`
- `catalog/agents.toml`
- `bootstrap/setup.sh`

## Source-Of-Truth Rules

1. The live managed layout is defined by this repository, not by upstream installers.
2. If a skill or agent should exist on a machine, it must exist under `home/`.
3. Upstream origin is metadata only. Presence in `home/` is what makes an item live.
4. Do not vendor Codex system defaults from `~/.codex/skills/.system` unless the user explicitly asks for that.
5. Do not add runtime state to the repo unless the user explicitly expands scope.

## Provenance Rules

Whenever you add, remove, import, rename, or modify a tracked skill or agent:
- update the corresponding file under `catalog/`
- keep `repo_path` aligned with the file tree under `home/`
- record whether the item is `local`, `imported`, `adapted`, or `forked`
- record the best available source path or upstream identifier
- add notes for any intentional divergence from upstream

## Setup Rules

- `bootstrap/setup.sh` is the only supported machine-setup entry point.
- Preserve symlink-based deployment into `~/.codex`.
- Back up conflicting live paths before replacing them with symlinks.
- Leave unmanaged Codex paths untouched.
```

- [x] **Step 5: Create the user-facing README**
Observed: Wrote `README.md` to document scope, setup, provenance, and the final live-layout rule: managed skills are linked into the existing `~/.codex/skills/` container while `.system` is preserved.

```markdown
# codex-customization

Portable, repo-owned Codex configuration for managed skills and agents.

## Scope

This repo currently tracks:
- managed skills under `home/skills/`
- managed root-level agents under `home/agents/`
- provenance manifests under `catalog/`
- bootstrap logic under `bootstrap/setup.sh`

This repo does not currently track:
- `rules/`
- `scripts/`
- `memories/`
- caches, logs, sessions, databases, auth files, or other runtime state
- Codex system defaults under `~/.codex/skills/.system`

## Setup

Run:

```bash
bash bootstrap/setup.sh
```

The script will:
- create `~/.codex` if needed
- back up conflicting managed paths
- symlink repo-owned `skills` and `agents` into `~/.codex`

## Provenance

- `catalog/skills.toml` records the origin and maintenance status of each tracked skill.
- `catalog/agents.toml` records the origin and maintenance status of each tracked root-level agent.
- Agents nested inside a skill are tracked as part of that skill.
```

- [x] **Step 6: Create the placeholder directories**
Observed: Created `home/agents/`, `home/skills/`, and `tests/bootstrap/`; later removed `tests/bootstrap/.gitkeep` once real tests existed.

```bash
mkdir -p catalog home/skills home/agents tests/bootstrap
touch home/agents/.gitkeep tests/bootstrap/.gitkeep
```

- [x] **Step 7: Commit the skeleton**
Observed: The skeleton work was consolidated into the repo baseline rather than committed as an isolated task-only change.

```bash
git add .gitignore AGENTS.md README.md catalog/skills.toml catalog/agents.toml home/agents/.gitkeep tests/bootstrap/.gitkeep
git commit -m "chore: scaffold portable codex home repo"
```

### Task 2: Test And Implement Symlink Setup

**Files:**
- Create: `tests/bootstrap/test_setup.sh`
- Create: `bootstrap/setup.sh`

- [x] **Step 1: Write the failing setup test**
Observed: A focused shell test was written first and then evolved to cover the real behavior, including `.system` preservation, per-skill backups, root-agent linking, and overlap rejection.

```bash
#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

codex_home="$tmpdir/.codex"
backup_root="$tmpdir/backups"

mkdir -p "$codex_home/skills" "$codex_home/agents"
printf 'stale-skill\n' > "$codex_home/skills/README.txt"
printf 'stale-agent\n' > "$codex_home/agents/README.txt"

bash "$repo_root/bootstrap/setup.sh" >/tmp/codex-setup-test.log 2>&1 && {
  echo "setup unexpectedly passed before implementation"
  exit 1
}
```

- [x] **Step 2: Run the test to verify the red state**
Observed: The worker verified the red state before implementation and then replaced the temporary failure harness with the real behavior test.

Run: `bash tests/bootstrap/test_setup.sh`  
Expected: FAIL because `bootstrap/setup.sh` does not exist yet

- [x] **Step 3: Replace the red test with the real behavior test**
Observed: The final test now verifies `~/.codex/skills` stays a real directory, `.system` survives unchanged, conflicting managed skills are backed up and replaced by symlinks, unmanaged skill entries are preserved, and overlap configuration is rejected.

```bash
#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

codex_home="$tmpdir/.codex"
backup_root="$tmpdir/backups"

mkdir -p "$codex_home/skills" "$codex_home/agents"
printf 'stale-skill\n' > "$codex_home/skills/README.txt"
printf 'stale-agent\n' > "$codex_home/agents/README.txt"

CODEX_HOME="$codex_home" CODEX_BACKUP_ROOT="$backup_root" \
  bash "$repo_root/bootstrap/setup.sh"

[ -L "$codex_home/skills" ]
[ "$(readlink "$codex_home/skills")" = "$repo_root/home/skills" ]
[ -L "$codex_home/agents" ]
[ "$(readlink "$codex_home/agents")" = "$repo_root/home/agents" ]
[ -f "$backup_root/skills/README.txt" ]
[ -f "$backup_root/agents/README.txt" ]
```

- [x] **Step 4: Implement the minimal setup script**
Observed: The initial whole-directory `skills` symlink model was corrected during verification; `bootstrap/setup.sh` now links managed skills individually into `~/.codex/skills/`, preserves `.system`, keeps `~/.codex/agents` repo-managed, and blocks destructive `CODEX_HOME` overlap with `home/`.

```bash
#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
codex_home="${CODEX_HOME:-$HOME/.codex}"
backup_root="${CODEX_BACKUP_ROOT:-$HOME/.codex-backups/$(date +%Y%m%d-%H%M%S)}"

managed_paths=(
  "skills"
  "agents"
)

mkdir -p "$codex_home"

link_path() {
  local rel="$1"
  local src="$repo_root/home/$rel"
  local dest="$codex_home/$rel"

  [ -e "$src" ] || return 0

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    printf 'ok   %s -> %s\n' "$dest" "$src"
    return 0
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mkdir -p "$backup_root"
    mv "$dest" "$backup_root/$rel"
    printf 'move %s -> %s\n' "$dest" "$backup_root/$rel"
  fi

  ln -sfn "$src" "$dest"
  printf 'link %s -> %s\n' "$dest" "$src"
}

for rel in "${managed_paths[@]}"; do
  link_path "$rel"
done
```

- [x] **Step 5: Run the setup test to verify green**
Observed: `bash tests/bootstrap/test_setup.sh` passes locally after the final safety and `.system` preservation fixes.

Run: `bash tests/bootstrap/test_setup.sh`  
Expected: PASS with no output

- [x] **Step 6: Commit the setup implementation**
Observed: The setup slice was folded into the final baseline commit rather than landed as a standalone commit.

```bash
git add bootstrap/setup.sh tests/bootstrap/test_setup.sh
git commit -m "feat: add codex home symlink setup"
```

### Task 3: Test And Implement Current-Home Import

**Files:**
- Create: `tests/bootstrap/test_import_current_home.sh`
- Create: `bootstrap/import_current_home.sh`
- Modify: `catalog/skills.toml`
- Modify: `catalog/agents.toml`
- Create: `home/skills/` (generated from the current active `~/.codex/skills` layout)

- [x] **Step 1: Write the failing import test**
Observed: A focused importer test was written first and then expanded to cover the eventual real constraints: skipping `.system`, dereferencing symlinks, preserving `catalog/agents.toml`, skipping stray folders, escaping TOML, and rejecting unsafe repo roots.

```bash
#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

source_codex="$tmpdir/source/.codex"
dest_repo="$tmpdir/repo"

mkdir -p "$source_codex/skills/.system/skip-me"
mkdir -p "$source_codex/skills/local-skill"
mkdir -p "$tmpdir/upstream/external-skill"
printf 'local\n' > "$source_codex/skills/local-skill/SKILL.md"
printf 'external\n' > "$tmpdir/upstream/external-skill/SKILL.md"
ln -s "$tmpdir/upstream/external-skill" "$source_codex/skills/external-skill"
mkdir -p "$source_codex/skills-by-origin/local-custom/local-skill"

mkdir -p "$dest_repo/catalog" "$dest_repo/home/skills" "$dest_repo/home/agents"
printf 'schema_version = 1\n' > "$dest_repo/catalog/skills.toml"
printf 'schema_version = 1\n' > "$dest_repo/catalog/agents.toml"

bash "$repo_root/bootstrap/import_current_home.sh" >/tmp/codex-import-test.log 2>&1 && {
  echo "import unexpectedly passed before implementation"
  exit 1
}
```

- [x] **Step 2: Run the test to verify the red state**
Observed: The worker verified the importer red state before implementing `bootstrap/import_current_home.sh`.

Run: `bash tests/bootstrap/test_import_current_home.sh`  
Expected: FAIL because `bootstrap/import_current_home.sh` does not exist yet

- [x] **Step 3: Replace the red test with the real behavior test**
Observed: The final importer test checks local-vs-imported provenance, `source_ref` generation, TOML escaping for quoted paths, preservation of an existing `catalog/agents.toml`, stray-folder skipping, and unsafe-root rejection.

```bash
#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

source_codex="$tmpdir/source/.codex"
dest_repo="$tmpdir/repo"

mkdir -p "$source_codex/skills/.system/skip-me"
mkdir -p "$source_codex/skills/local-skill"
mkdir -p "$tmpdir/upstream/external-skill"
printf 'local\n' > "$source_codex/skills/local-skill/SKILL.md"
printf 'external\n' > "$tmpdir/upstream/external-skill/SKILL.md"
ln -s "$tmpdir/upstream/external-skill" "$source_codex/skills/external-skill"
mkdir -p "$source_codex/skills-by-origin/local-custom/local-skill"

mkdir -p "$dest_repo/catalog" "$dest_repo/home/skills" "$dest_repo/home/agents"
printf 'schema_version = 1\n' > "$dest_repo/catalog/skills.toml"
printf 'schema_version = 1\n' > "$dest_repo/catalog/agents.toml"

SOURCE_CODEX_HOME="$source_codex" DEST_REPO_ROOT="$dest_repo" \
  bash "$repo_root/bootstrap/import_current_home.sh"

[ -d "$dest_repo/home/skills/local-skill" ]
[ ! -L "$dest_repo/home/skills/local-skill" ]
[ -d "$dest_repo/home/skills/external-skill" ]
[ ! -L "$dest_repo/home/skills/external-skill" ]
[ ! -e "$dest_repo/home/skills/.system" ]
grep -q 'id = "local-skill"' "$dest_repo/catalog/skills.toml"
grep -q 'status = "local"' "$dest_repo/catalog/skills.toml"
grep -q 'id = "external-skill"' "$dest_repo/catalog/skills.toml"
grep -q 'status = "imported"' "$dest_repo/catalog/skills.toml"
grep -q 'source_path = "'"$tmpdir"'/upstream/external-skill"' "$dest_repo/catalog/skills.toml"
```

- [x] **Step 4: Implement the minimal importer**
Observed: `bootstrap/import_current_home.sh` now validates the destination repo root before cleanup, preserves `catalog/agents.toml`, imports only directories containing `SKILL.md`, writes escaped TOML, and records both `source_path` and portable `source_ref`.

```bash
#!/usr/bin/env bash
set -euo pipefail

repo_root="${DEST_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source_codex_home="${SOURCE_CODEX_HOME:-$HOME/.codex}"

skills_src="$source_codex_home/skills"
skills_dest="$repo_root/home/skills"
local_custom_root="$source_codex_home/skills-by-origin/local-custom"
skills_catalog="$repo_root/catalog/skills.toml"
agents_catalog="$repo_root/catalog/agents.toml"

mkdir -p "$skills_dest" "$repo_root/home/agents" "$repo_root/catalog"

cat > "$skills_catalog" <<'EOF'
schema_version = 1
EOF

cat > "$agents_catalog" <<'EOF'
schema_version = 1

# No root-level agents are tracked yet.
EOF

find "$skills_src" -mindepth 1 -maxdepth 1 | sort | while read -r src; do
  name="$(basename "$src")"
  [ "$name" = ".system" ] && continue

  dest="$skills_dest/$name"
  rm -rf "$dest"

  if [ -L "$src" ]; then
    resolved="$(readlink "$src")"
    rsync -aL "$src/" "$dest/"
    status="imported"
    source_path="$resolved"
    source_kind="symlink-target"
  else
    rsync -a "$src/" "$dest/"
    if [ -d "$local_custom_root/$name" ]; then
      status="local"
      source_kind="local-custom"
    else
      status="adapted"
      source_kind="copied-from-home"
    fi
    source_path="$src"
  fi

  cat >> "$skills_catalog" <<EOF

[[skill]]
id = "$name"
type = "skill"
repo_path = "home/skills/$name"
status = "$status"
source_kind = "$source_kind"
source_path = "$source_path"
notes = ""
EOF
done
```

- [x] **Step 5: Run the import test to verify green**
Observed: `bash tests/bootstrap/test_import_current_home.sh` passes locally after the importer safety and manifest fixes.

Run: `bash tests/bootstrap/test_import_current_home.sh`  
Expected: PASS with no output

- [x] **Step 6: Run the importer against the current machine**
Observed: Ran `bash bootstrap/import_current_home.sh` against the current machine; `home/skills/` now contains 92 repo-owned non-system skills, `catalog/skills.toml` has 92 matching entries, and `skills-maintenance` is recorded as `status = "local"` / `source_kind = "local-custom"`.

Run: `bash bootstrap/import_current_home.sh`  
Expected: `home/skills/` is populated with repo-owned copies of active non-system skills, `catalog/skills.toml` contains one entry per imported skill, and `catalog/agents.toml` remains a schema file with a no-root-agents note

- [x] **Step 7: Commit the imported managed state**
Observed: The imported managed state was consolidated into the final baseline commit rather than committed separately.

```bash
git add bootstrap/import_current_home.sh tests/bootstrap/test_import_current_home.sh home/skills catalog/skills.toml catalog/agents.toml
git commit -m "feat: import managed codex skills into repo"
```

### Task 4: Finalize Documentation And Verify End-To-End Setup

**Files:**
- Modify: `README.md`
- Modify: `AGENTS.md`

- [x] **Step 1: Update the docs with the final operating model**
Observed: Updated `README.md` and `AGENTS.md` with the final model, including vendored non-system skills, empty-by-design root-level `home/agents/`, nested-agent ownership by parent skill, and the distinction between `bootstrap/import_current_home.sh` and normal machine setup.

```markdown
Add these points to both documents:
- active non-system skills are vendored under `home/skills/`
- root-level `home/agents/` is currently empty by design
- agents nested inside vendored skills are part of the parent skill and are not duplicated into `home/agents/`
- future updates must edit `home/` first and update `catalog/` in the same change
- `bootstrap/import_current_home.sh` is a one-time or explicit maintenance tool, not the normal machine-setup command
```

- [x] **Step 2: Run the focused test suite**
Observed: Ran `bash tests/bootstrap/test_setup.sh && bash tests/bootstrap/test_import_current_home.sh`; both exited 0 after the final corrections.

Run: `bash tests/bootstrap/test_setup.sh && bash tests/bootstrap/test_import_current_home.sh`  
Expected: both scripts exit 0

- [x] **Step 3: Run end-to-end setup verification against a temporary Codex home**
Observed: Verified the actual repo against a temporary Codex home; `~/.codex/skills` stayed a real directory, `.system` remained intact, managed skills linked into that container, and `agents` linked to `home/agents`.

Run: `tmpdir="$(mktemp -d)" && CODEX_HOME="$tmpdir/.codex" CODEX_BACKUP_ROOT="$tmpdir/backups" bash bootstrap/setup.sh`  
Expected:
- `tmpdir/.codex/skills` is a symlink to `<repo>/home/skills`
- `tmpdir/.codex/agents` is a symlink to `<repo>/home/agents`
- no other paths are modified

- [x] **Step 4: Run end-to-end setup verification against the current machine**
Observed: Ran `bash bootstrap/setup.sh` against the live `~/.codex`; 92 managed skills were relinked into the repo, `~/.codex/agents` now points at `home/agents`, `.system` remained present, and replaced managed entries were backed up under `~/.codex-backups/20260331-110814/`.

Run: `bash bootstrap/setup.sh`  
Expected: `~/.codex/skills` and `~/.codex/agents` point to this repo's `home/skills` and `home/agents`, and any replaced managed paths were moved to a timestamped backup directory

- [x] **Step 5: Review the working tree and commit the finished baseline**
Observed: Reviewed the working tree and finalized the repository baseline in a single commit after updating this execution log.

```bash
git status --short
git add AGENTS.md README.md
git commit -m "docs: finalize codex home maintenance guide"
```

## Self-Review

- The plan covers repo scaffolding, importer, setup flow, provenance manifests, and maintenance docs.
- The plan keeps scope limited to skills and agents.
- The tests explicitly cover the two risky behaviors: replacing live paths safely and dereferencing imported symlinked skills into repo-owned copies.
- The plan reflects the current machine state: active non-system skills exist, but no root-level `~/.codex/agents` directory exists yet.
