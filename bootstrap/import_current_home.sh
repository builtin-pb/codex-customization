#!/usr/bin/env bash
set -euo pipefail

script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/$(basename "${BASH_SOURCE[0]}")"
repo_root="${DEST_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)}"
source_codex_home="${SOURCE_CODEX_HOME:-$HOME/.codex}"
source_agents_home="${SOURCE_AGENTS_HOME:-$HOME/.agents}"
source_orchestra_root="${SOURCE_ORCHESTRA_ROOT:-$HOME/.orchestra/skills}"

skills_src="$source_codex_home/skills"
superpowers_skills_src="$source_codex_home/superpowers/skills"
superpowers_agents_src="$source_codex_home/superpowers/agents"
wshobson_skills_src="$source_agents_home/skills"
orchestra_skills_src="$source_orchestra_root"
skills_dest="$repo_root/home/skills"
agents_dest="$repo_root/home/agents"
local_custom_root="$source_codex_home/skills-by-origin/local-custom"
skills_catalog="$repo_root/catalog/skills.toml"
agents_catalog="$repo_root/catalog/agents.toml"
managed_agents_begin="# BEGIN IMPORTED ROOT AGENTS"
managed_agents_end="# END IMPORTED ROOT AGENTS"

fail() {
  printf '%s\n' "$1" >&2
  exit 1
}

resolve_path() {
  local path="$1"
  local target

  if [ ! -L "$path" ]; then
    printf '%s\n' "$path"
    return 0
  fi

  target="$(readlink "$path")"
  case "$target" in
    /*)
      printf '%s\n' "$target"
      ;;
    *)
      printf '%s/%s\n' "$(cd "$(dirname "$path")" && pwd -P)" "$target"
      ;;
  esac
}

toml_escape() {
  local value="$1"
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/\\r}
  value=${value//$'\t'/\\t}
  printf '%s' "$value"
}

portable_source_ref() {
  local name="$1"
  local candidate

  if [ -d "$source_codex_home/skills-by-origin" ]; then
    while IFS= read -r candidate; do
      [ -d "$candidate/$name" ] || continue
      printf '%s/%s\n' "${candidate#"$source_codex_home"/}" "$name"
      return 0
    done < <(find "$source_codex_home/skills-by-origin" -mindepth 1 -maxdepth 1 -type d | LC_ALL=C sort)
  fi

  printf 'skills/%s\n' "$name"
}

write_skill_entry() {
  local id="$1"
  local status="$2"
  local source_kind="$3"
  local source_ref="$4"
  local source_path="$5"
  local notes="$6"

  cat >> "$skills_catalog" <<EOF

[[skill]]
id = "$(toml_escape "$id")"
type = "skill"
repo_path = "home/skills/$(toml_escape "$id")"
status = "$(toml_escape "$status")"
source_kind = "$(toml_escape "$source_kind")"
source_ref = "$(toml_escape "$source_ref")"
source_path = "$(toml_escape "$source_path")"
notes = "$(toml_escape "$notes")"
EOF
}

write_agent_entry() {
  local id="$1"
  local repo_path="$2"
  local status="$3"
  local source_kind="$4"
  local source_ref="$5"
  local source_path="$6"
  local notes="$7"

  cat >> "$agents_catalog_entries" <<EOF

[[agent]]
id = "$(toml_escape "$id")"
repo_path = "$(toml_escape "$repo_path")"
status = "$(toml_escape "$status")"
source_kind = "$(toml_escape "$source_kind")"
source_ref = "$(toml_escape "$source_ref")"
source_path = "$(toml_escape "$source_path")"
notes = "$(toml_escape "$notes")"
EOF
}

canonical_repo_skill_name() {
  local source_name="$1"

  case "$source_name" in
    0-autoresearch-skill)
      printf 'autoresearch\n'
      ;;
    *)
      printf '%s\n' "$source_name"
      ;;
  esac
}

validate_repo_root() {
  case "$repo_root" in
    ""|"/")
      fail "unsafe DEST_REPO_ROOT: $repo_root"
      ;;
  esac

  [ -d "$repo_root" ] || fail "repo root is not a directory: $repo_root"
  [ ! -L "$repo_root" ] || fail "repo root must not be a symlink: $repo_root"
  [ "$repo_root" != "$source_codex_home" ] || fail "repo root must not equal the source Codex home"

  [ -d "$repo_root/bootstrap" ] || fail "missing bootstrap directory: $repo_root/bootstrap"
  [ -d "$repo_root/catalog" ] || fail "missing catalog directory: $repo_root/catalog"
  [ -d "$repo_root/home" ] || fail "missing home directory: $repo_root/home"
  [ -d "$repo_root/home/skills" ] || fail "missing home skills directory: $repo_root/home/skills"
  [ -d "$repo_root/home/agents" ] || fail "missing home agents directory: $repo_root/home/agents"
  [ -f "$repo_root/catalog/skills.toml" ] || fail "missing catalog/skills.toml in repo root"
  [ -f "$repo_root/catalog/agents.toml" ] || fail "missing catalog/agents.toml in repo root"
  [ -e "$repo_root/bootstrap/import_current_home.sh" ] || fail "missing bootstrap/import_current_home.sh in repo root"

  cmp -s "$repo_root/bootstrap/import_current_home.sh" "$script_path" || fail "repo root bootstrap/import_current_home.sh does not match this importer"
}

validate_repo_root
[ -d "$skills_src" ] || fail "missing Codex skills source: $skills_src"
[ -d "$orchestra_skills_src" ] || fail "missing Orchestra skills source: $orchestra_skills_src"

mkdir -p "$repo_root/home"
find "$skills_dest" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} + 2>/dev/null || true
mkdir -p "$skills_dest"
mkdir -p "$agents_dest"
find "$agents_dest" -mindepth 1 -maxdepth 1 ! -name '.gitkeep' -exec rm -rf -- {} + 2>/dev/null || true

cat > "$skills_catalog" <<'EOF'
# Source of truth for tracked skills in this repository.
# Each [[skill]] entry must be updated whenever a skill is added, removed,
# renamed, imported, or modified.
schema_version = 1
EOF

if [ ! -e "$agents_catalog" ]; then
  cat > "$agents_catalog" <<'EOF'
# Source of truth for tracked root-level agents in this repository.
# Nested agents that ship inside skills are tracked with the parent skill.
schema_version = 1

# No root-level agents are tracked yet.
EOF
fi

preserved_agents_catalog="$(mktemp)"
agents_catalog_entries="$(mktemp)"
seen_skills="$(mktemp)"
trap 'rm -f "$preserved_agents_catalog" "$agents_catalog_entries" "$seen_skills"' EXIT

awk -v begin="$managed_agents_begin" -v end="$managed_agents_end" '
  $0 == begin { skip = 1; next }
  $0 == end { skip = 0; next }
  !skip { print }
' "$agents_catalog" > "$preserved_agents_catalog"

import_skill() {
  local name="$1"
  local skill_root="$2"
  local status="$3"
  local source_kind="$4"
  local source_ref="$5"
  local source_path="$6"
  local notes="$7"
  local dest="$skills_dest/$name"

  [ -f "$skill_root/SKILL.md" ] || return 0
  if grep -Fxq "$name" "$seen_skills"; then
    fail "duplicate skill import target: $name"
  fi

  printf '%s\n' "$name" >> "$seen_skills"
  rm -rf -- "$dest"
  cp -R "$skill_root" "$dest"
  write_skill_entry "$name" "$status" "$source_kind" "$source_ref" "$source_path" "$notes"
}

while IFS= read -r src; do
  [ -n "$src" ] || continue
  [ -d "$src" ] || continue

  name="$(basename "$src")"
  [ "$name" = "skills-maintenance" ] && continue
  import_skill \
    "$name" \
    "$src" \
    "local" \
    "local-custom" \
    "local-custom/$name" \
    "$src" \
    "Local skill preserved as a repo-owned copy."
done < <(find "$local_custom_root" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | LC_ALL=C sort)

while IFS= read -r src; do
  [ -n "$src" ] || continue
  [ -d "$src" ] || continue
  source_name="$(basename "$src")"
  name="$(canonical_repo_skill_name "$source_name")"
  [ -f "$src/SKILL.md" ] || continue
  import_skill \
    "$name" \
    "$src" \
    "imported" \
    "orchestra" \
    "orchestra/$source_name" \
    "$src" \
    "Imported from the canonical Orchestra skills checkout into repo-owned storage."
done < <(find "$orchestra_skills_src" -mindepth 1 -maxdepth 2 -type d -print | LC_ALL=C sort)

if [ -d "$superpowers_skills_src" ]; then
  while IFS= read -r src; do
    [ -n "$src" ] || continue
    [ -d "$src" ] || continue
    name="$(basename "$src")"
    import_skill \
      "$name" \
      "$src" \
      "imported" \
      "superpowers" \
      "superpowers/$name" \
      "$src" \
      "Imported from the local Superpowers checkout into repo-owned storage."
  done < <(find "$superpowers_skills_src" -mindepth 1 -maxdepth 1 -type d -print | LC_ALL=C sort)
fi

if [ -d "$wshobson_skills_src" ]; then
  while IFS= read -r src; do
    [ -n "$src" ] || continue
    [ -d "$src" ] || continue
    name="$(basename "$src")"
    [ "$name" = "superpowers" ] && continue
    import_skill \
      "$name" \
      "$src" \
      "imported" \
      "wshobson-agents-extracted" \
      "wshobson-agents-extracted/$name" \
      "$src" \
      "Imported from the local wshobson/agents extraction into repo-owned storage."
  done < <(find "$wshobson_skills_src" -mindepth 1 -maxdepth 1 -type d -print | LC_ALL=C sort)
fi

if [ -d "$superpowers_agents_src" ]; then
  while IFS= read -r src; do
    [ -n "$src" ] || continue
    [ -f "$src" ] || continue
    base="$(basename "$src")"
    id="${base%.*}"
    cp "$src" "$agents_dest/$base"
    write_agent_entry \
      "$id" \
      "home/agents/$base" \
      "imported" \
      "superpowers" \
      "superpowers/$id" \
      "$src" \
      "Imported from the local Superpowers checkout into repo-owned storage."
  done < <(find "$superpowers_agents_src" -mindepth 1 -maxdepth 1 -type f -print | LC_ALL=C sort)
fi

cat "$preserved_agents_catalog" > "$agents_catalog"
printf '\n%s\n' "$managed_agents_begin" >> "$agents_catalog"
if [ -s "$agents_catalog_entries" ]; then
  cat "$agents_catalog_entries" >> "$agents_catalog"
else
  printf '# No imported root agents were found.\n' >> "$agents_catalog"
fi
printf '%s\n' "$managed_agents_end" >> "$agents_catalog"
