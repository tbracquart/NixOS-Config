#!/usr/bin/env python3
"""Conservatively determine which NixOS hosts are affected by flake input changes.

The analysis starts at each nixosConfiguration declared in flake.nix, follows
relative Nix paths found in that configuration and in reachable files, and
records every inputs.<name> reference it encounters. Unknown constructs are
handled conservatively by building every host.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

HOST_RE = re.compile(r"nixosConfigurations\.([A-Za-z0-9_-]+)\s*=")
INPUT_RE = re.compile(r"\binputs\.([A-Za-z0-9_-]+)\b")
PATH_RE = re.compile(r"(?<![A-Za-z0-9_])\./[^\s\"']+")


def load(path: Path):
    with path.open() as f:
        return json.load(f)


def root_locked(data, name):
    ref = data.get("nodes", {}).get("root", {}).get("inputs", {}).get(name)
    if ref is None:
        return None
    node_name = ref if isinstance(ref, str) else ref[-1]
    return data.get("nodes", {}).get(node_name, {}).get("locked")


def changed_inputs(before, after):
    before_names = set(before.get("nodes", {}).get("root", {}).get("inputs", {}))
    after_names = set(after.get("nodes", {}).get("root", {}).get("inputs", {}))
    return [
        name
        for name in sorted(before_names | after_names)
        if root_locked(before, name) != root_locked(after, name)
    ]


def matching_block(text: str, start: int) -> str:
    brace = text.find("{", start)
    if brace < 0:
        raise ValueError("could not find host block")
    depth = 0
    in_string = False
    escaped = False
    for i in range(brace, len(text)):
        c = text[i]
        if in_string:
            if escaped:
                escaped = False
            elif c == "\\":
                escaped = True
            elif c == '"':
                in_string = False
            continue
        if c == '"':
            in_string = True
        elif c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                return text[brace : i + 1]
    raise ValueError("unterminated host block")


def expand_helper_paths(flake: str, host: str) -> list[str]:
    paths: list[str] = []
    common = re.search(r"commonModules\s*=\s*\[(.*?)\];", flake, re.S)
    if common:
        paths.extend(PATH_RE.findall(common.group(1)))
    host_modules = re.search(r"hostModules\s*=\s*host\s*:\s*\[(.*?)\];", flake, re.S)
    if host_modules:
        paths.extend(p.replace("${host}", host) for p in PATH_RE.findall(host_modules.group(1)))
    return paths


def resolve_relative(root: Path, source: Path, raw: str) -> Path | None:
    raw = raw.rstrip("];,)>}")
    candidate = (source.parent / raw[2:]).resolve() if raw.startswith("./") else None
    if candidate is None or (root not in candidate.parents and candidate != root):
        return None
    if candidate.is_file():
        return candidate
    if candidate.is_dir():
        default = candidate / "default.nix"
        return default if default.is_file() else None
    nix_file = candidate.with_suffix(".nix")
    return nix_file if nix_file.is_file() else None


def analyze_host(root: Path, initial_paths: list[str]) -> tuple[set[str], bool]:
    inputs: set[str] = set()
    seen: set[Path] = set()
    queue: list[Path] = []
    for raw in initial_paths:
        path = resolve_relative(root, root / "flake.nix", raw)
        if path:
            queue.append(path)

    while queue:
        path = queue.pop()
        if path in seen:
            continue
        seen.add(path)
        try:
            text = path.read_text()
        except (OSError, UnicodeDecodeError):
            return inputs, True
        inputs.update(INPUT_RE.findall(text))
        # Following every relative path literal is deliberately conservative:
        # a false positive costs a build, while a missed dependency could make
        # the CI accept an unbuilt host configuration.
        for raw in PATH_RE.findall(text):
            child = resolve_relative(root, path, raw)
            if child:
                queue.append(child)
    return inputs, False


def main() -> int:
    if len(sys.argv) != 4:
        print(f"usage: {sys.argv[0]} BEFORE_LOCK AFTER_LOCK REPO_ROOT", file=sys.stderr)
        return 2

    before = load(Path(sys.argv[1]))
    after = load(Path(sys.argv[2]))
    root = Path(sys.argv[3]).resolve()
    flake = (root / "flake.nix").read_text()
    changed = changed_inputs(before, after)
    print(f"changed-inputs={','.join(changed)}")

    hosts = HOST_RE.findall(flake)
    if not hosts:
        print("analysis-error=no-nixos-configurations", file=sys.stderr)
        return 1

    host_inputs: dict[str, set[str]] = {}
    analysis_failed = False
    for host in hosts:
        try:
            start = flake.find(f"nixosConfigurations.{host} =")
            block = matching_block(flake, start)
            paths = expand_helper_paths(flake, host)
            paths.extend(PATH_RE.findall(block))
            found, failed = analyze_host(root, paths)
            host_inputs[host] = found
            analysis_failed |= failed
        except (OSError, ValueError):
            analysis_failed = True

    if analysis_failed:
        print("analysis-error=dependency-scan-failed", file=sys.stderr)

    changed_set = set(changed)
    affected_hosts = []
    for host in hosts:
        affected = bool(changed_set & host_inputs.get(host, set()))
        if analysis_failed:
            affected = True
        if affected:
            affected_hosts.append(host)
        print(f"host-inputs-{host}={','.join(sorted(host_inputs.get(host, set())))}")

    # A changed input not observed by any host means the syntax is more dynamic
    # than the scanner can prove. Never turn that uncertainty into a false skip.
    mapped = set().union(*host_inputs.values()) if host_inputs else set()
    if changed_set - mapped or analysis_failed:
        affected_hosts = hosts

    print("build-hosts=" + json.dumps(affected_hosts, separators=(",", ":")))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
