#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

test_repo="$tmpdir/test-repo"
mkdir -p "$test_repo/bootstrap" "$test_repo/home/skills/managed-skill" "$test_repo/home/agents"
cp "$repo_root/bootstrap/setup.sh" "$test_repo/bootstrap/setup.sh"
printf 'managed skill\n' > "$test_repo/home/skills/managed-skill/SKILL.md"
printf 'managed agent\n' > "$test_repo/home/agents/agent.txt"

codex_home="$tmpdir/.codex"
backup_root="$tmpdir/backups"

mkdir -p "$codex_home/skills/.system" "$codex_home/skills/managed-skill" "$codex_home/skills/custom-unmanaged" "$codex_home/agents" "$codex_home/rules"
printf 'system default\n' > "$codex_home/skills/.system/default.txt"
printf 'stale managed skill\n' > "$codex_home/skills/managed-skill/README.txt"
printf 'custom skill\n' > "$codex_home/skills/custom-unmanaged/README.txt"
printf 'stale agent\n' > "$codex_home/agents/README.txt"
printf 'leave me alone\n' > "$codex_home/rules/runtime.txt"
ln -s "$test_repo/home/skills/removed-skill" "$codex_home/skills/removed-skill"

CODEX_HOME="$codex_home" CODEX_BACKUP_ROOT="$backup_root" \
  bash "$test_repo/bootstrap/setup.sh"

[ -d "$codex_home/skills" ]
[ ! -L "$codex_home/skills" ]
[ -d "$codex_home/skills/.system" ]
[ "$(cat "$codex_home/skills/.system/default.txt")" = "system default" ]
[ -d "$codex_home/skills/custom-unmanaged" ]
[ "$(cat "$codex_home/skills/custom-unmanaged/README.txt")" = "custom skill" ]
[ -L "$codex_home/skills/managed-skill" ]
[ -d "$codex_home/skills/managed-skill" ]
[ "$(readlink "$codex_home/skills/managed-skill")" = "$test_repo/home/skills/managed-skill" ]
[ "$(cat "$codex_home/skills/managed-skill/SKILL.md")" = "managed skill" ]
[ -f "$backup_root/skills/managed-skill/README.txt" ]
[ "$(cat "$backup_root/skills/managed-skill/README.txt")" = "stale managed skill" ]
[ -L "$codex_home/agents" ]
[ -d "$codex_home/agents" ]
[ "$(readlink "$codex_home/agents")" = "$test_repo/home/agents" ]
[ -f "$backup_root/agents/README.txt" ]
[ "$(cat "$backup_root/agents/README.txt")" = "stale agent" ]
[ "$(cat "$codex_home/rules/runtime.txt")" = "leave me alone" ]
[ ! -L "$codex_home/skills/removed-skill" ]
[ ! -e "$codex_home/skills/removed-skill" ]

CODEX_HOME="$codex_home" CODEX_BACKUP_ROOT="$backup_root" \
  bash "$test_repo/bootstrap/setup.sh"

[ -d "$codex_home/skills" ]
[ ! -L "$codex_home/skills" ]
[ -d "$codex_home/skills/.system" ]
[ "$(cat "$codex_home/skills/.system/default.txt")" = "system default" ]
[ -L "$codex_home/skills/managed-skill" ]
[ -d "$codex_home/skills/managed-skill" ]
[ "$(readlink "$codex_home/skills/managed-skill")" = "$test_repo/home/skills/managed-skill" ]
[ -f "$backup_root/skills/managed-skill/README.txt" ]
[ -L "$codex_home/agents" ]
[ -d "$codex_home/agents" ]
[ "$(readlink "$codex_home/agents")" = "$test_repo/home/agents" ]
[ "$(cat "$codex_home/rules/runtime.txt")" = "leave me alone" ]
[ ! -L "$codex_home/skills/removed-skill" ]
[ ! -e "$codex_home/skills/removed-skill" ]

overlap_repo="$tmpdir/overlap-repo"
mkdir -p "$overlap_repo/bootstrap" "$overlap_repo/home/skills/managed-skill" "$overlap_repo/home/agents"
cp "$repo_root/bootstrap/setup.sh" "$overlap_repo/bootstrap/setup.sh"

overlap_home="$overlap_repo/home/portable-home"

if CODEX_HOME="$overlap_home" CODEX_BACKUP_ROOT="$tmpdir/overlap-backups" \
  bash "$overlap_repo/bootstrap/setup.sh" >"$tmpdir/overlap.log" 2>&1; then
  echo "expected overlap configuration to be rejected"
  exit 1
fi

grep -q 'refusing to use CODEX_HOME inside repo-managed source tree' "$tmpdir/overlap.log"
[ -d "$overlap_repo/home/skills" ]
[ ! -L "$overlap_repo/home/skills" ]
[ -d "$overlap_repo/home/agents" ]
[ ! -L "$overlap_repo/home/agents" ]
[ ! -e "$overlap_home" ]
