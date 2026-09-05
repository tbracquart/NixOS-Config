#!/usr/bin/env python3
"""Prepare outputs for the automated flake update pull request."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path


ANALYZER = Path(__file__).with_name("analyze-flake-impact.py")


def run_analyzer(before: Path, after: Path, root: Path) -> dict[str, str]:
    result = subprocess.run(
        [sys.executable, str(ANALYZER), str(before), str(after), str(root)],
        text=True,
        capture_output=True,
        check=True,
    )
    output: dict[str, str] = {}
    for line in result.stdout.splitlines():
        if "=" in line:
            key, value = line.split("=", 1)
            output[key] = value
    return output


def locked_node(data: dict, name: str) -> dict | None:
    ref = data.get("nodes", {}).get("root", {}).get("inputs", {}).get(name)
    if ref is None:
        return None
    node_name = ref if isinstance(ref, str) else ref[-1]
    return data.get("nodes", {}).get(node_name, {}).get("locked")


def input_changes(before: dict, after: dict, names: list[str]) -> list[str]:
    changes = []
    for name in names:
        locked_before = locked_node(before, name)
        locked_after = locked_node(after, name)
        lm_before = locked_before.get("lastModified") if locked_before else None
        lm_after = locked_after.get("lastModified") if locked_after else None
        if lm_before is not None and lm_after is not None:
            delta_days = round((lm_after - lm_before) / 86400)
            sign = "+" if delta_days >= 0 else ""
            changes.append(f"{name} ({sign}{delta_days}j)")
        else:
            changes.append(name)
    return changes


def prepare_outputs(before_path: Path, after_path: Path, root: Path) -> tuple[str, str, list[str]]:
    before = json.loads(before_path.read_text())
    after = json.loads(after_path.read_text())
    impact = run_analyzer(before_path, after_path, root)

    changed_names = [name for name in impact["changed-inputs"].split(",") if name]
    changed = input_changes(before, after, changed_names)

    if changed:
        title = "chore: nix flake update — " + ", ".join(changed)
        body_lines = [f"- {change}" for change in changed]
    else:
        title = "chore: nix flake update (auto)"
        body_lines = ["- Aucun changement détecté dans les inputs de premier niveau"]

    build_hosts = json.loads(impact["build-hosts"])
    body_lines += ["", "## Hosts à builder"]
    for key in sorted(key for key in impact if key.startswith("host-inputs-")):
        host = key.removeprefix("host-inputs-")
        if host in build_hosts:
            body_lines.append(f"- `{host}` : build")
        else:
            body_lines.append(f"- `{host}` : ignoré (aucune dépendance affectée)")

    return title[:70], "\n".join(body_lines), build_hosts


def write_github_output(title: str, body: str, build_hosts: list[str]) -> None:
    print(f"title={title}")
    print("body<<BODY_EOF")
    print(body)
    print("BODY_EOF")
    print("build-hosts=" + json.dumps(build_hosts, separators=(",", ":")))


def main() -> int:
    if len(sys.argv) != 4:
        print(f"usage: {sys.argv[0]} BEFORE_LOCK AFTER_LOCK REPO_ROOT", file=sys.stderr)
        return 2

    before, after, root = map(Path, sys.argv[1:])
    title, body, build_hosts = prepare_outputs(before, after, root)
    write_github_output(title, body, build_hosts)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
