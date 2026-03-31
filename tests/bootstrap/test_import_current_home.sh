#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

source_codex="$tmpdir/source/.codex"
source_agents="$tmpdir/source/.agents"
source_orchestra="$tmpdir/source/.orchestra/quoted\"skills"
safe_repo="$tmpdir/repo"
unsafe_repo="$tmpdir/unsafe"

mkdir -p "$source_codex/skills/.system/skip-me"
mkdir -p "$source_codex/skills/local-skill"
mkdir -p "$source_codex/skills/skills-maintenance"
mkdir -p "$source_codex/skills/stray-folder"
mkdir -p "$source_codex/skills-by-origin/local-custom/local-skill"
mkdir -p "$source_codex/skills-by-origin/local-custom/skills-maintenance"
mkdir -p "$source_codex/skills-by-origin/orchestra/external-skill"
mkdir -p "$source_codex/superpowers/skills/brainstorming"
mkdir -p "$source_codex/superpowers/agents"
mkdir -p "$source_agents/skills/agent-coordination"
mkdir -p "$source_agents/skills/superpowers"
mkdir -p "$source_codex/skills-by-origin/wshobson-agents-extracted/agent-coordination"
mkdir -p "$source_orchestra/external-skill"
mkdir -p "$source_orchestra/0-autoresearch-skill"

quoted_skill_dir="$tmpdir/upstream/quoted\"skill"
mkdir -p "$quoted_skill_dir"
printf 'local\n' > "$source_codex/skills/local-skill/SKILL.md"
printf 'maintenance\n' > "$source_codex/skills/skills-maintenance/SKILL.md"
printf 'external\n' > "$quoted_skill_dir/SKILL.md"
ln -s "$quoted_skill_dir" "$source_codex/skills/external-skill"
printf 'local custom\n' > "$source_codex/skills-by-origin/local-custom/local-skill/SKILL.md"
printf 'orchestra\n' > "$source_codex/skills-by-origin/orchestra/external-skill/SKILL.md"
printf 'external\n' > "$source_orchestra/external-skill/SKILL.md"
printf 'autoresearch\n' > "$source_orchestra/0-autoresearch-skill/SKILL.md"
printf 'superpowers\n' > "$source_codex/superpowers/skills/brainstorming/SKILL.md"
printf 'agent-coordination\n' > "$source_agents/skills/agent-coordination/SKILL.md"
printf 'wshobson\n' > "$source_codex/skills-by-origin/wshobson-agents-extracted/agent-coordination/SKILL.md"
printf 'root agent\n' > "$source_codex/superpowers/agents/code-reviewer.md"

mkdir -p "$safe_repo/bootstrap" "$safe_repo/catalog" "$safe_repo/home/skills" "$safe_repo/home/agents"
ln -s "$repo_root/bootstrap/import_current_home.sh" "$safe_repo/bootstrap/import_current_home.sh"
printf 'schema_version = 1\n' > "$safe_repo/catalog/skills.toml"
printf 'schema_version = 1\n# keep-me\nexisting_root_agent = "yes"\n' > "$safe_repo/catalog/agents.toml"
cp "$safe_repo/catalog/agents.toml" "$tmpdir/agents.before"

SOURCE_CODEX_HOME="$source_codex" SOURCE_AGENTS_HOME="$source_agents" SOURCE_ORCHESTRA_ROOT="$source_orchestra" DEST_REPO_ROOT="$safe_repo" \
  bash "$repo_root/bootstrap/import_current_home.sh"

[ -d "$safe_repo/home/skills/local-skill" ]
[ ! -L "$safe_repo/home/skills/local-skill" ]
[ -f "$safe_repo/home/skills/local-skill/SKILL.md" ]
[ -d "$safe_repo/home/skills/external-skill" ]
[ ! -L "$safe_repo/home/skills/external-skill" ]
[ -f "$safe_repo/home/skills/external-skill/SKILL.md" ]
[ -d "$safe_repo/home/skills/autoresearch" ]
[ -f "$safe_repo/home/skills/autoresearch/SKILL.md" ]
[ ! -e "$safe_repo/home/skills/0-autoresearch-skill" ]
[ -d "$safe_repo/home/skills/brainstorming" ]
[ -f "$safe_repo/home/skills/brainstorming/SKILL.md" ]
[ -d "$safe_repo/home/skills/agent-coordination" ]
[ -f "$safe_repo/home/skills/agent-coordination/SKILL.md" ]
[ ! -e "$safe_repo/home/skills/skills-maintenance" ]
[ ! -e "$safe_repo/home/skills/.system" ]
[ ! -e "$safe_repo/home/skills/stray-folder" ]
[ "$(grep -c '^\[\[skill\]\]' "$safe_repo/catalog/skills.toml")" -eq 5 ]
grep -q 'id = "local-skill"' "$safe_repo/catalog/skills.toml"
grep -q 'status = "local"' "$safe_repo/catalog/skills.toml"
grep -q 'source_kind = "local-custom"' "$safe_repo/catalog/skills.toml"
grep -q 'source_ref = "local-custom/local-skill"' "$safe_repo/catalog/skills.toml"
grep -q 'id = "external-skill"' "$safe_repo/catalog/skills.toml"
grep -q 'status = "imported"' "$safe_repo/catalog/skills.toml"
grep -q 'source_kind = "orchestra"' "$safe_repo/catalog/skills.toml"
grep -q 'source_ref = "orchestra/external-skill"' "$safe_repo/catalog/skills.toml"
grep -q 'id = "autoresearch"' "$safe_repo/catalog/skills.toml"
grep -q 'source_ref = "orchestra/0-autoresearch-skill"' "$safe_repo/catalog/skills.toml"
grep -q 'id = "brainstorming"' "$safe_repo/catalog/skills.toml"
grep -q 'source_kind = "superpowers"' "$safe_repo/catalog/skills.toml"
grep -q 'source_ref = "superpowers/brainstorming"' "$safe_repo/catalog/skills.toml"
grep -q 'id = "agent-coordination"' "$safe_repo/catalog/skills.toml"
grep -q 'source_kind = "wshobson-agents-extracted"' "$safe_repo/catalog/skills.toml"
grep -q 'source_ref = "wshobson-agents-extracted/agent-coordination"' "$safe_repo/catalog/skills.toml"
escaped_orchestra_skill_dir=${source_orchestra//\"/\\\"}
grep -F -q "source_path = \"$escaped_orchestra_skill_dir/external-skill\"" "$safe_repo/catalog/skills.toml"
[ -f "$safe_repo/home/agents/code-reviewer.md" ]
[ "$(cat "$safe_repo/home/agents/code-reviewer.md")" = "root agent" ]
grep -q 'id = "code-reviewer"' "$safe_repo/catalog/agents.toml"
grep -q 'source_kind = "superpowers"' "$safe_repo/catalog/agents.toml"
grep -q 'source_ref = "superpowers/code-reviewer"' "$safe_repo/catalog/agents.toml"
grep -q '# keep-me' "$safe_repo/catalog/agents.toml"
grep -q 'existing_root_agent = "yes"' "$safe_repo/catalog/agents.toml"

unsafe_source="$tmpdir/unsafe-source/.codex"
mkdir -p "$unsafe_source/skills/only-skill" "$unsafe_repo/bootstrap" "$unsafe_repo/catalog" "$unsafe_repo/home/skills" "$unsafe_repo/home/agents"
printf 'only\n' > "$unsafe_source/skills/only-skill/SKILL.md"
printf 'schema_version = 1\n' > "$unsafe_repo/catalog/skills.toml"
printf 'schema_version = 1\n' > "$unsafe_repo/catalog/agents.toml"
printf 'sentinel\n' > "$unsafe_repo/home/skills/sentinel.txt"
printf '%s\n' '#!/usr/bin/env bash' 'echo wrong' > "$unsafe_repo/bootstrap/import_current_home.sh"

if SOURCE_CODEX_HOME="$unsafe_source" SOURCE_AGENTS_HOME="$tmpdir/unsafe-source/.agents" SOURCE_ORCHESTRA_ROOT="$tmpdir/unsafe-source/.orchestra/skills" DEST_REPO_ROOT="$unsafe_repo" \
  bash "$repo_root/bootstrap/import_current_home.sh" >/dev/null 2>&1; then
  echo "import unexpectedly succeeded for an unsafe repo root"
  exit 1
fi

[ -f "$unsafe_repo/home/skills/sentinel.txt" ]
