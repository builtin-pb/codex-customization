# Managed Global AGENTS Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a repo-managed global `home/AGENTS.md` that is installed into `~/.codex/AGENTS.md` by `bootstrap/setup.sh`.

**Architecture:** Extend the existing symlink-based home bootstrap model with one additional managed root file. The setup script will treat `AGENTS.md` as a managed root artifact alongside the existing managed `agents/` root and managed per-skill links, while tests and docs are updated to reflect the new contract.

**Tech Stack:** Bash, Markdown, shell tests, symlinks on macOS/Linux

---

### Task 1: Add Red-State Coverage For Global `AGENTS.md`

**Files:**
- Modify: `tests/bootstrap/test_setup.sh`
- Test: `tests/bootstrap/test_setup.sh`

- [x] **Step 1: Extend the bootstrap fixture with a managed source file and a conflicting live file**
Observed: Updated `tests/bootstrap/test_setup.sh` to create `"$test_repo/home/AGENTS.md"` and a conflicting live `"$codex_home/AGENTS.md"` fixture without touching any non-test files.

Add these lines near the existing test repo and Codex home fixture setup:

```bash
mkdir -p "$test_repo/bootstrap" "$test_repo/home/skills/execution/managed-skill" "$test_repo/home/agents"
cp "$repo_root/bootstrap/setup.sh" "$test_repo/bootstrap/setup.sh"
printf 'managed skill\n' > "$test_repo/home/skills/execution/managed-skill/SKILL.md"
printf 'managed agent\n' > "$test_repo/home/agents/agent.txt"
printf 'managed global agents\n' > "$test_repo/home/AGENTS.md"

mkdir -p "$codex_home/skills/.system" "$codex_home/skills/managed-skill" "$codex_home/skills/custom-unmanaged" "$codex_home/agents" "$codex_home/rules"
printf 'system default\n' > "$codex_home/skills/.system/default.txt"
printf 'stale managed skill\n' > "$codex_home/skills/managed-skill/README.txt"
printf 'custom skill\n' > "$codex_home/skills/custom-unmanaged/README.txt"
printf 'stale agent\n' > "$codex_home/agents/README.txt"
printf 'existing global agents\n' > "$codex_home/AGENTS.md"
printf 'leave me alone\n' > "$codex_home/rules/runtime.txt"
```

- [x] **Step 2: Add assertions for install, backup, and idempotence**
Observed: Added first-run assertions for the managed `AGENTS.md` symlink and backup content, then tightened the second-run check to assert `"$backup_root/AGENTS.md.1"` does not exist so reruns cannot silently churn backups.

Insert these checks after the first and second setup runs:

```bash
[ -L "$codex_home/AGENTS.md" ]
[ "$(readlink "$codex_home/AGENTS.md")" = "$test_repo/home/AGENTS.md" ]
[ "$(cat "$codex_home/AGENTS.md")" = "managed global agents" ]
[ -f "$backup_root/AGENTS.md" ]
[ "$(cat "$backup_root/AGENTS.md")" = "existing global agents" ]
```

Keep these assertions after the second setup run as well:

```bash
[ -L "$codex_home/AGENTS.md" ]
[ "$(readlink "$codex_home/AGENTS.md")" = "$test_repo/home/AGENTS.md" ]
[ "$(cat "$codex_home/AGENTS.md")" = "managed global agents" ]
[ -f "$backup_root/AGENTS.md" ]
```

- [x] **Step 3: Run the shell test to verify it fails before implementation**
Observed: Ran `bash tests/bootstrap/test_setup.sh` and got the intended red state with exit status `1`; the failure still comes from `AGENTS.md` remaining unmanaged in `bootstrap/setup.sh`.

Run: `bash tests/bootstrap/test_setup.sh`

Expected: exit status `1` because `bootstrap/setup.sh` does not yet create `~/.codex/AGENTS.md`, so one of the new `AGENTS.md` assertions fails.

### Task 2: Implement Managed Global `AGENTS.md` Linking

**Files:**
- Create: `home/AGENTS.md`
- Modify: `bootstrap/setup.sh`
- Test: `tests/bootstrap/test_setup.sh`

- [x] **Step 1: Create the repo-owned global instruction file**
Observed: Created `home/AGENTS.md` with the exact minimal always-on content from the plan and no extra policy text.

Create `home/AGENTS.md` with a minimal always-on file that is valid immediately and explains how to maintain it:

```markdown
# Global AGENTS

This file is the repo-managed global instruction file for Codex.

Edit this file when you want to change standing preferences that should apply to every session using this managed Codex home.
```

- [x] **Step 2: Add managed source tracking and a root-file linker to `bootstrap/setup.sh`**
Observed: Added `managed_global_agents_file` and a `link_global_agents_file()` helper in `bootstrap/setup.sh`, reusing the existing backup and idempotence pattern used for other managed paths.

Near the managed path declarations, add a dedicated variable:

```bash
managed_global_agents_file="$managed_root/AGENTS.md"
```

Add this helper next to `link_agents_root()`:

```bash
link_global_agents_file() {
  local rel="AGENTS.md"
  local src="$managed_global_agents_file"
  local dest="$codex_home/$rel"

  if [ ! -f "$src" ]; then
    printf 'missing managed source file: %s\n' "$src" >&2
    exit 1
  fi

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    linked_paths+=("$rel already linked")
    return 0
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    backup_conflict "$rel"
  fi

  ln -s "$src" "$dest"
  linked_paths+=("$rel -> $src")
}
```

- [x] **Step 3: Exclude `AGENTS.md` from unmanaged-root reporting and call the new linker**
Observed: Updated `record_unmanaged_root_paths()` to skip `AGENTS.md` and called `link_global_agents_file` before unmanaged-path reporting so the new root file is treated as managed.

Update the root-path filter:

```bash
case "$name" in
  skills|agents|AGENTS.md)
    continue
    ;;
esac
```

Call the new helper in the main flow before unmanaged path reporting:

```bash
link_global_agents_file
link_agents_root
record_unmanaged_root_paths
record_unmanaged_skill_paths
print_summary
```

- [x] **Step 4: Run the bootstrap test to verify the green state**
Observed: Ran `bash tests/bootstrap/test_setup.sh` and got exit status `0`; the test confirmed managed `AGENTS.md` linking, one-time backup behavior, rerun stability, and preservation of `rules/`.

Run: `bash tests/bootstrap/test_setup.sh`

Expected: exit status `0`, with the test confirming that `~/.codex/AGENTS.md` is linked, conflicting live content is backed up, reruns are idempotent, and `rules/` remains untouched.

- [x] **Step 5: Commit the implementation**
Observed: Intentionally skipped committing because the worktree already contains unrelated user changes; the implementation was left uncommitted for the main session to integrate safely.

Run:

```bash
git add bootstrap/setup.sh home/AGENTS.md tests/bootstrap/test_setup.sh
git commit -m "feat: manage global codex agents file"
```

Expected: a new commit containing the bootstrap logic, test coverage, and the repo-owned global `AGENTS.md`.

### Task 3: Update Repo Documentation For The New Managed Surface

**Files:**
- Modify: `AGENTS.md`
- Modify: `README.md`
- Test: `tests/bootstrap/test_setup.sh`

- [x] **Step 1: Update the maintenance contract in `AGENTS.md`**
Observed: Updated `AGENTS.md` so the source-of-truth contract now covers the managed global `home/AGENTS.md` file and the setup section explicitly states that `~/.codex/AGENTS.md` is repo-managed.

Adjust the source-of-truth and setup sections so they explicitly include `home/AGENTS.md` as a managed home artifact. Make these edits:

```markdown
Before changing tracked skills, agents, setup behavior, or provenance, read:
- `AGENTS.md`
- `README.md`
- `catalog/skills.toml`
- `catalog/agents.toml`
- `bootstrap/setup.sh`

## Source Of Truth

1. The repo-owned `home/` tree defines what is live on a machine.
2. If a managed skill, root-level agent, or global `AGENTS.md` file should exist in `~/.codex`, it must be present here under `home/`.
```

And in setup guidance add:

```markdown
- `~/.codex/AGENTS.md` is repo-managed through `home/AGENTS.md`.
```

- [x] **Step 2: Update the user-facing README**
Observed: Updated `README.md` to list `home/AGENTS.md` in the managed layout and added the `~/.codex/AGENTS.md` symlink step to the setup flow description.

Revise the scope and setup sections so they include the new managed file:

```markdown
This repository currently defines the managed Codex layout for:
- `home/skills/`
- `home/agents/`
- `home/AGENTS.md`
- provenance and maintenance records under `catalog/`
- setup and bootstrap checks under `bootstrap/` and `tests/bootstrap/`
```

And update the setup summary bullets:

```markdown
The setup flow is intended to:
- create `~/.codex` if needed
- back up conflicting managed paths
- discover managed skill leaf directories under `home/skills/<classification>/` and symlink them into `~/.codex/skills/` while preserving `~/.codex/skills/.system`
- symlink the repo-owned `home/agents/` tree into `~/.codex/agents/`
- symlink the repo-owned `home/AGENTS.md` file into `~/.codex/AGENTS.md`
- prune stale managed skill symlinks that no longer exist under `home/skills/`
- preserve unmanaged Codex state outside the repo-owned layout
```

- [x] **Step 3: Re-run the bootstrap test after the docs-only changes**
Observed: Re-ran `bash tests/bootstrap/test_setup.sh` after the doc edits and again during final verification; both runs exited `0`.

Run: `bash tests/bootstrap/test_setup.sh`

Expected: exit status `0`. This is a regression check to ensure the documentation edits did not accidentally accompany uncommitted behavior changes.

- [x] **Step 4: Commit the documentation update**
Observed: Intentionally skipped committing because the worktree contains unrelated user changes; the docs are updated locally and verified without creating a mixed-scope commit.

Run:

```bash
git add AGENTS.md README.md
git commit -m "docs: document managed global agents file"
```

Expected: a commit that updates the repo contract and setup documentation without changing runtime behavior.

## Self-Review

**Spec coverage:** The plan covers the new managed file, bootstrap behavior, documentation changes, conflict backup behavior, idempotence, and preservation of unmanaged paths.

**Placeholder scan:** No `TODO`, `TBD`, or implied steps remain. Each code-edit step includes the concrete content to add.

**Type consistency:** The plan consistently uses `home/AGENTS.md` as the managed source file and `~/.codex/AGENTS.md` as the deployed target, and the bootstrap helper name is used consistently across implementation steps.
