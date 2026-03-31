#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

source_codex="$tmpdir/source/.codex"
safe_repo="$tmpdir/repo"
unsafe_repo="$tmpdir/unsafe"

mkdir -p "$source_codex/skills/.system/skip-me"
mkdir -p "$source_codex/skills/local-skill"
mkdir -p "$source_codex/skills/stray-folder"
mkdir -p "$source_codex/skills-by-origin/local-custom/local-skill"
mkdir -p "$source_codex/skills-by-origin/orchestra/external-skill"

quoted_skill_dir="$tmpdir/upstream/quoted\"skill"
mkdir -p "$quoted_skill_dir"
printf 'local\n' > "$source_codex/skills/local-skill/SKILL.md"
printf 'external\n' > "$quoted_skill_dir/SKILL.md"
ln -s "$quoted_skill_dir" "$source_codex/skills/external-skill"
printf 'orchestra\n' > "$source_codex/skills-by-origin/orchestra/external-skill/SKILL.md"

mkdir -p "$safe_repo/bootstrap" "$safe_repo/catalog" "$safe_repo/home/skills" "$safe_repo/home/agents"
ln -s "$repo_root/bootstrap/import_current_home.sh" "$safe_repo/bootstrap/import_current_home.sh"
printf 'schema_version = 1\n' > "$safe_repo/catalog/skills.toml"
printf 'schema_version = 1\n# keep-me\nexisting_root_agent = "yes"\n' > "$safe_repo/catalog/agents.toml"
cp "$safe_repo/catalog/agents.toml" "$tmpdir/agents.before"

SOURCE_CODEX_HOME="$source_codex" DEST_REPO_ROOT="$safe_repo" \
  bash "$repo_root/bootstrap/import_current_home.sh"

[ -d "$safe_repo/home/skills/local-skill" ]
[ ! -L "$safe_repo/home/skills/local-skill" ]
[ -f "$safe_repo/home/skills/local-skill/SKILL.md" ]
[ -d "$safe_repo/home/skills/external-skill" ]
[ ! -L "$safe_repo/home/skills/external-skill" ]
[ -f "$safe_repo/home/skills/external-skill/SKILL.md" ]
[ ! -e "$safe_repo/home/skills/.system" ]
[ ! -e "$safe_repo/home/skills/stray-folder" ]
[ "$(grep -c '^\[\[skill\]\]' "$safe_repo/catalog/skills.toml")" -eq 2 ]
grep -q 'id = "local-skill"' "$safe_repo/catalog/skills.toml"
grep -q 'status = "local"' "$safe_repo/catalog/skills.toml"
grep -q 'source_kind = "local-custom"' "$safe_repo/catalog/skills.toml"
grep -q 'source_ref = "skills-by-origin/local-custom/local-skill"' "$safe_repo/catalog/skills.toml"
grep -q 'id = "external-skill"' "$safe_repo/catalog/skills.toml"
grep -q 'status = "imported"' "$safe_repo/catalog/skills.toml"
grep -q 'source_kind = "copied-from-home"' "$safe_repo/catalog/skills.toml"
grep -q 'source_ref = "skills-by-origin/orchestra/external-skill"' "$safe_repo/catalog/skills.toml"
escaped_quoted_skill_dir=${quoted_skill_dir//\"/\\\"}
grep -F -q "source_path = \"$escaped_quoted_skill_dir\"" "$safe_repo/catalog/skills.toml"
cmp -s "$tmpdir/agents.before" "$safe_repo/catalog/agents.toml"

unsafe_source="$tmpdir/unsafe-source/.codex"
mkdir -p "$unsafe_source/skills/only-skill" "$unsafe_repo/bootstrap" "$unsafe_repo/catalog" "$unsafe_repo/home/skills" "$unsafe_repo/home/agents"
printf 'only\n' > "$unsafe_source/skills/only-skill/SKILL.md"
printf 'schema_version = 1\n' > "$unsafe_repo/catalog/skills.toml"
printf 'schema_version = 1\n' > "$unsafe_repo/catalog/agents.toml"
printf 'sentinel\n' > "$unsafe_repo/home/skills/sentinel.txt"
printf '%s\n' '#!/usr/bin/env bash' 'echo wrong' > "$unsafe_repo/bootstrap/import_current_home.sh"

if SOURCE_CODEX_HOME="$unsafe_source" DEST_REPO_ROOT="$unsafe_repo" \
  bash "$repo_root/bootstrap/import_current_home.sh" >/dev/null 2>&1; then
  echo "import unexpectedly succeeded for an unsafe repo root"
  exit 1
fi

[ -f "$unsafe_repo/home/skills/sentinel.txt" ]
