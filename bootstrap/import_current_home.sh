#!/usr/bin/env bash
set -euo pipefail

script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/$(basename "${BASH_SOURCE[0]}")"
repo_root="${DEST_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)}"
source_codex_home="${SOURCE_CODEX_HOME:-$HOME/.codex}"

skills_src="$source_codex_home/skills"
skills_dest="$repo_root/home/skills"
local_custom_root="$source_codex_home/skills-by-origin/local-custom"
skills_catalog="$repo_root/catalog/skills.toml"
agents_catalog="$repo_root/catalog/agents.toml"

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

mkdir -p "$repo_root/home"
find "$skills_dest" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} + 2>/dev/null || true
mkdir -p "$skills_dest"

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

while IFS= read -r src; do
  [ -n "$src" ] || continue
  [ -d "$src" ] || [ -L "$src" ] || continue

  name="$(basename "$src")"
  [ "$name" = ".system" ] && continue

  if [ -L "$src" ]; then
    resolved_src="$(resolve_path "$src")"
    skill_root="$resolved_src"
    source_kind="copied-from-home"
    source_ref="$(portable_source_ref "$name")"
    source_path="$resolved_src"
  else
    skill_root="$src"
    source_path="$src"
    if [ -d "$local_custom_root/$name" ]; then
      source_kind="local-custom"
      source_ref="skills-by-origin/local-custom/$name"
    else
      source_kind="copied-from-home"
      source_ref="$(portable_source_ref "$name")"
    fi
  fi

  [ -f "$skill_root/SKILL.md" ] || continue

  dest="$skills_dest/$name"
  rm -rf -- "$dest"
  cp -R "$skill_root" "$dest"

  if [ "$source_kind" = "local-custom" ]; then
    status="local"
    notes="Local skill preserved as a repo-owned copy."
  else
    status="imported"
    notes="Imported from the active Codex home and dereferenced into a repo-owned copy."
  fi

  write_skill_entry \
    "$name" \
    "$status" \
    "$source_kind" \
    "$source_ref" \
    "$source_path" \
    "$notes"
done < <(find "$skills_src" -mindepth 1 -maxdepth 1 -print | LC_ALL=C sort)
