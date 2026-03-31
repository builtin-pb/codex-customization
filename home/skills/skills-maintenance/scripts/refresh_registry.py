#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import shutil
import subprocess
from datetime import datetime, timezone
from pathlib import Path


def run(*args: str) -> str:
    result = subprocess.run(args, capture_output=True, text=True)
    if result.returncode != 0:
        return ""
    return result.stdout.strip()


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def relink(dst: Path, src: Path) -> None:
    if dst.exists() or dst.is_symlink():
        if dst.is_dir() and not dst.is_symlink():
            shutil.rmtree(dst)
        else:
            dst.unlink()
    dst.symlink_to(src)


def list_skill_dirs(root: Path) -> list[Path]:
    if not root.exists():
        return []
    return sorted([p for p in root.iterdir() if p.is_dir()])


def write_json(path: Path, data: object) -> None:
    path.write_text(json.dumps(data, indent=2, sort_keys=False) + "\n")


def expand_path(raw: str) -> Path:
    return Path(os.path.expandvars(os.path.expanduser(raw)))


def load_json(path: Path) -> dict:
    if not path.exists():
        return {}
    return json.loads(path.read_text())


def origin_skill_names(origin: dict, resolved_paths: dict[str, Path], context: dict) -> list[str]:
    source_type = origin["source_type"]
    root = resolved_paths.get(origin.get("root_ref", ""))

    if source_type in {"directory", "git-skills-root"}:
        return [p.name for p in list_skill_dirs(root)] if root else []

    if source_type == "named-active-skills":
        return sorted(context["local_custom_skills"].keys())

    if source_type == "active-root-remainder":
        active_root = root
        if not active_root:
            return []
        names = [p.name for p in list_skill_dirs(active_root)]
        excluded = set(origin.get("exclude_names", []))
        for key in origin.get("exclude_origin_keys", []):
            excluded.update(context["origin_skill_map"].get(key, []))
        return sorted([name for name in names if name not in excluded])

    raise ValueError(f"Unsupported source_type: {source_type}")


def build_origin_record(origin: dict, resolved_paths: dict[str, Path], overrides: dict, skills: list[str]) -> dict:
    record: dict = {
        "root": str(resolved_paths.get(origin.get("root_ref", ""), "")),
        "count": len(skills),
        "skills": skills,
    }

    if "update_method" in origin:
        record["update_method"] = origin["update_method"]
    if "repo_url" in origin:
        record["repo"] = origin["repo_url"]

    origin_key = origin["key"]
    origin_notes = overrides.get("origin_notes", {}).get(origin_key, [])
    if origin_notes:
        record["notes"] = origin_notes

    skill_customizations = overrides.get("skill_customizations", {}).get(origin_key, {})
    if skill_customizations:
        record["customized"] = skill_customizations

    if origin["source_type"] == "git-skills-root":
        repo_root = resolved_paths.get(origin.get("repo_root_ref", ""))
        remote = ""
        if repo_root:
            remote = run("git", "-C", str(repo_root), "remote", "get-url", "origin")
        record["repo"] = remote or origin.get("repo_url_fallback", "")
        if "symlink_ref" in origin:
            record["discovery"] = str(resolved_paths.get(origin["symlink_ref"], ""))
        status_lines = run("git", "-C", str(repo_root), "status", "--short").splitlines() if repo_root else []
        modified_files = []
        for line in status_lines:
            line = line.rstrip()
            if not line:
                continue
            parts = line.split(maxsplit=1)
            if len(parts) == 2:
                modified_files.append(parts[1])
            else:
                modified_files.append(parts[0])
        record["customized_files"] = modified_files

    if origin["source_type"] == "named-active-skills":
        record["skills"] = overrides.get("local_custom_skills", {})
        record["count"] = len(record["skills"])

    return record


def main() -> int:
    codex_home = Path(os.environ.get("CODEX_HOME", str(Path.home() / ".codex"))).expanduser().resolve()
    skill_root = codex_home / "skills" / "skills-maintenance"
    origins_path = skill_root / "data" / "origins.json"
    overrides_path = skill_root / "data" / "origin-overrides.json"
    registry_md = codex_home / "SKILLS-ORIGINS.md"
    registry_json = codex_home / "SKILLS-ORIGINS.json"

    origins_config = load_json(origins_path)
    overrides = load_json(overrides_path)

    path_refs = origins_config.get("path_refs", {})
    resolved_paths = {key: expand_path(value) for key, value in path_refs.items()}
    grouped_root = resolved_paths["grouped_root"]

    if grouped_root.exists():
        shutil.rmtree(grouped_root)
    ensure_dir(grouped_root)

    context = {
        "local_custom_skills": overrides.get("local_custom_skills", {}),
        "origin_skill_map": {},
    }

    origins = origins_config.get("origins", [])
    for origin in origins:
        skills = origin_skill_names(origin, resolved_paths, context)
        context["origin_skill_map"][origin["key"]] = skills

    registry = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "generated_from": {
            "origins_config": str(origins_path),
            "overrides_config": str(overrides_path),
        },
        "discovery_roots": {key: str(path) for key, path in resolved_paths.items()},
        "origins": {},
    }

    lines = [
        "# Skills Origins Registry",
        "",
        "> Generated file. Do not edit by hand.",
        "",
        f"Generated: `{registry['generated_at']}`",
        "",
        "## Source Files",
        "",
        f"- Origins config: `{origins_path}`",
        f"- Overrides config: `{overrides_path}`",
        "",
        "## Discovery Roots",
        "",
    ]
    for key, path in resolved_paths.items():
        lines.append(f"- `{key}`: `{path}`")

    lines.extend(["", "## Origin Groups", ""])

    for origin in origins:
        key = origin["key"]
        display = origin["display_name"]
        skills = context["origin_skill_map"][key]
        record = build_origin_record(origin, resolved_paths, overrides, skills)
        registry["origins"][key] = record

        group_dir = grouped_root / key
        group_view = origin.get("group_view", "per-skill")
        if group_view == "root":
            root = resolved_paths.get(origin.get("root_ref", ""))
            if root and root.exists():
                relink(group_dir, root)
        else:
            ensure_dir(group_dir)
            root = resolved_paths.get(origin.get("root_ref", ""))
            if root:
                for name in skills:
                    src = root / name
                    if src.exists():
                        relink(group_dir / name, src)

        lines.extend([
            f"### {display} ({record['count']})",
            "",
        ])
        if record.get("repo"):
            lines.append(f"- Source: `{record['repo']}`")
        if record.get("discovery"):
            lines.append(f"- Discovery: `{record['discovery']}`")
        if record.get("update_method"):
            lines.append(f"- Update: {record['update_method']}")
        if record.get("notes"):
            for note in record["notes"]:
                lines.append(f"- Note: {note}")
        lines.append("")

        if origin["source_type"] == "named-active-skills":
            skills_meta = overrides.get("local_custom_skills", {})
            if skills_meta:
                for name, info in sorted(skills_meta.items()):
                    lines.append(f"- `{name}`: {info.get('notes', '')}")
            else:
                lines.append("- none")
        else:
            for name in skills:
                lines.append(f"- `{name}`")
            if not skills:
                lines.append("- none")

        customized = record.get("customized", {})
        if customized:
            lines.extend(["", "Customized skills:"])
            for name, info in sorted(customized.items()):
                lines.append(f"- `{name}`: {info.get('notes', '')}")

        customized_files = record.get("customized_files", [])
        if customized_files:
            lines.extend(["", "Modified tracked files:"])
            for path in customized_files:
                lines.append(f"- `{path}`")

        lines.append("")

    lines.extend([
        "## Update Playbook",
        "",
        "1. Edit config files, not generated inventory files.",
        "2. Install, remove, or modify the actual skills on disk.",
        "3. Run `python3 ~/.codex/skills/skills-maintenance/scripts/refresh_registry.py`.",
        "4. Read `~/.codex/SKILLS-ORIGINS.md` and inspect `~/.codex/skills-by-origin/`.",
    ])

    registry_md.write_text("\n".join(lines) + "\n")
    write_json(registry_json, registry)
    print(f"Updated {registry_md}")
    print(f"Updated {registry_json}")
    print(f"Updated grouped view at {grouped_root}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
