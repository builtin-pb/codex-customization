#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
codex_home="${CODEX_HOME:-$HOME/.codex}"
backup_root="${CODEX_BACKUP_ROOT:-$HOME/.codex-backups/$(date +%Y%m%d-%H%M%S)}"
managed_root="$repo_root/home"
managed_skills_root="$managed_root/skills"
managed_agents_root="$managed_root/agents"

linked_paths=()
backed_up_paths=()
unmanaged_root_paths=()
unmanaged_skill_paths=()

normalize_path() {
  local input="$1"

  if [ -d "$input" ]; then
    (
      cd "$input"
      pwd -P
    )
    return 0
  fi

  if [ "$input" = "/" ]; then
    printf '/\n'
    return 0
  fi

  local parent
  local base
  parent="$(dirname "$input")"
  base="$(basename "$input")"

  printf '%s/%s\n' "$(normalize_path "$parent")" "$base"
}

ensure_backup_root() {
  mkdir -p "$backup_root"
}

unique_backup_path() {
  local base="$1"
  local candidate="$base"
  local counter=1

  while [ -e "$candidate" ] || [ -L "$candidate" ]; do
    candidate="${base}.${counter}"
    counter=$((counter + 1))
  done

  printf '%s\n' "$candidate"
}

backup_conflict() {
  local rel="$1"
  local dest="$codex_home/$rel"
  local backup_dest="$backup_root/$rel"

  ensure_backup_root
  mkdir -p "$(dirname "$backup_dest")"
  backup_dest="$(unique_backup_path "$backup_dest")"
  mv "$dest" "$backup_dest"
  backed_up_paths+=("$rel -> $backup_dest")
}

link_agents_root() {
  local rel="agents"
  local src="$managed_agents_root"
  local dest="$codex_home/$rel"

  if [ ! -d "$src" ]; then
    printf 'missing managed source directory: %s\n' "$src" >&2
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

ensure_skills_container() {
  local skills_dest="$codex_home/skills"

  if [ -d "$skills_dest" ] && [ ! -L "$skills_dest" ]; then
    return 0
  fi

  if [ -e "$skills_dest" ] || [ -L "$skills_dest" ]; then
    backup_conflict "skills"
  fi

  mkdir -p "$skills_dest"
}

link_managed_skill() {
  local src="$1"
  local name
  local rel
  local dest

  name="$(basename "$src")"
  rel="skills/$name"
  dest="$codex_home/$rel"

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

record_unmanaged_root_paths() {
  while IFS= read -r -d '' entry; do
    local name
    name="$(basename "$entry")"
    case "$name" in
      skills|agents)
        continue
        ;;
    esac
    unmanaged_root_paths+=("$name")
  done < <(find "$codex_home" -mindepth 1 -maxdepth 1 -print0)
}

record_unmanaged_skill_paths() {
  local skills_dest="$codex_home/skills"

  while IFS= read -r -d '' entry; do
    local name
    name="$(basename "$entry")"
    if [ -e "$managed_skills_root/$name" ] || [ -L "$managed_skills_root/$name" ]; then
      continue
    fi
    unmanaged_skill_paths+=("skills/$name")
  done < <(find "$skills_dest" -mindepth 1 -maxdepth 1 -print0)
}

print_summary() {
  printf 'Codex home setup summary:\n'

  if [ "${#linked_paths[@]}" -gt 0 ]; then
    printf 'Linked paths:\n'
    for line in "${linked_paths[@]}"; do
      printf '  %s\n' "$line"
    done
  else
    printf 'Linked paths: none\n'
  fi

  if [ "${#backed_up_paths[@]}" -gt 0 ]; then
    printf 'Backed up paths:\n'
    for line in "${backed_up_paths[@]}"; do
      printf '  %s\n' "$line"
    done
  else
    printf 'Backed up paths: none\n'
  fi

  if [ "${#unmanaged_root_paths[@]}" -gt 0 ]; then
    printf 'Unmanaged root paths:\n'
    for line in "${unmanaged_root_paths[@]}"; do
      printf '  %s\n' "$line"
    done
  else
    printf 'Unmanaged root paths: none\n'
  fi

  if [ "${#unmanaged_skill_paths[@]}" -gt 0 ]; then
    printf 'Unmanaged skill entries:\n'
    for line in "${unmanaged_skill_paths[@]}"; do
      printf '  %s\n' "$line"
    done
  else
    printf 'Unmanaged skill entries: none\n'
  fi
}

managed_root_abs="$(normalize_path "$managed_root")"
codex_home_abs="$(normalize_path "$codex_home")"

case "$codex_home_abs" in
  "$managed_root_abs"|"$managed_root_abs"/*)
    printf 'refusing to use CODEX_HOME inside repo-managed source tree: %s\n' "$codex_home_abs" >&2
    exit 1
    ;;
esac

if [ ! -d "$managed_skills_root" ]; then
  printf 'missing managed source directory: %s\n' "$managed_skills_root" >&2
  exit 1
fi

mkdir -p "$codex_home"
ensure_skills_container

shopt -s dotglob nullglob
for entry in "$managed_skills_root"/*; do
  link_managed_skill "$entry"
done
shopt -u dotglob nullglob

link_agents_root
record_unmanaged_root_paths
record_unmanaged_skill_paths
print_summary
