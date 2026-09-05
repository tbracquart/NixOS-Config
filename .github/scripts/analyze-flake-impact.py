#!/usr/bin/env python3
"""Conservatively determine which NixOS hosts are affected by flake input changes.

The analysis starts at each nixosConfiguration declared in flake.nix, follows
relative Nix paths found in that configuration and in reachable files, and
records every input reference it encounters. Unknown constructs are handled
conservatively by building every host.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

HOST_RE = re.compile(r"nixosConfigurations\.([A-Za-z0-9_-]+)\s*=")
INPUT_RE = re.compile(r"\binputs\.([A-Za-z0-9_-]+)\b")
# Match complete relative paths, including parent-relative imports such as
# ../../common and ../modules. The dot in the lookbehind prevents matching a
# suffix like ./common inside ../../common.
PATH_RE = re.compile(r"(?<![A-Za-z0-9_.])(?:\.\.?/)+[^\s\"']+")


def load(path: Path):
    with path.open() as f:
        return json.load(f)


def root_input_ref(data, name):
    return data.get("nodes", {}).get("root", {}).get("inputs", {}).get(name)


def node_name(ref):
    return ref if isinstance(ref, str) else ref[-1]


def reachable_nodes(data, name):
    """Return every lock node reachable from a top-level root input."""
    ref = root_input_ref(data, name)
    if ref is None:
        return set(), False

    nodes = data.get("nodes", {})
    queue = [node_name(ref)]
    seen: set[str] = set()
    failed = False
    while queue:
        current = queue.pop()
        if current in seen:
            continue
        node = nodes.get(current)
        if node is None:
            failed = True
            continue
        seen.add(current)
        for child_ref in node.get("inputs", {}).values():
            queue.append(node_name(child_ref))
    return seen, failed


def root_locked(data, name):
    ref = root_input_ref(data, name)
    if ref is None:
        return None
    return data.get("nodes", {}).get(node_name(ref), {}).get("locked")


def changed_inputs(before, after):
    """Return top-level inputs whose complete lock closure changed."""
    before_names = set(before.get("nodes", {}).get("root", {}).get("inputs", {}))
    after_names = set(after.get("nodes", {}).get("root", {}).get("inputs", {}))
    changed = []

    for name in sorted(before_names | after_names):
        before_nodes, before_failed = reachable_nodes(before, name)
        after_nodes, after_failed = reachable_nodes(after, name)
        if before_failed or after_failed:
            changed.append(name)
            continue
        if before_nodes != after_nodes:
            changed.append(name)
            continue
        if root_locked(before, name) != root_locked(after, name):
            changed.append(name)
            continue
        for node in before_nodes:
            before_data = before.get("nodes", {}).get(node, {})
            after_data = after.get("nodes", {}).get(node, {})
            if (
                before_data.get("locked") != after_data.get("locked")
                or before_data.get("inputs", {}) != after_data.get("inputs", {})
            ):
                changed.append(name)
                break
    return changed


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
    candidate = (source.parent / raw).resolve() if raw.startswith(".") else None
    if candidate is None or (root not in candidate.parents and candidate != root):
        return None
    if candidate.is_file():
        return candidate
    if candidate.is_dir():
        default = candidate / "default.nix"
        return default if default.is_file() else None
    nix_file = candidate.with_suffix(".nix")
    return nix_file if nix_file.is_file() else None


def analyze_host(
    root: Path,
    initial_paths: list[str],
    direct_inputs: set[str],
    file_cache: dict[Path, str],
    path_cache: dict[tuple[Path, str], Path | None],
    input_cache: dict[Path, set[str]],
) -> tuple[set[str], bool]:
    inputs: set[str] = set()
    seen: set[Path] = set()
    queue: list[Path] = []

    def resolve_cached(source: Path, raw: str) -> Path | None:
        key = (source, raw)
        if key not in path_cache:
            path_cache[key] = resolve_relative(root, source, raw)
        return path_cache[key]

    for raw in initial_paths:
        path = resolve_cached(root / "flake.nix", raw)
        if path:
            queue.append(path)

    while queue:
        path = queue.pop()
        if path in seen:
            continue
        seen.add(path)
        try:
            text = file_cache.get(path)
            if text is None:
                text = path.read_text()
                file_cache[path] = text
        except (OSError, UnicodeDecodeError):
            return inputs, True

        parsed_inputs = input_cache.get(path)
        if parsed_inputs is None:
            parsed_inputs = set(INPUT_RE.findall(text))
            input_cache[path] = parsed_inputs
        inputs.update(parsed_inputs)

        # Host definitions in flake.nix receive flake inputs as bare variables
        # (for example `nix-cachyos-kernel.overlays...`), so inspect the host
        # block separately instead of requiring an `inputs.` prefix.
        if path == root / "flake.nix":
            inputs.update(
                name for name in direct_inputs if re.search(rf"\b{re.escape(name)}\b", text)
            )
        # Following every relative path literal is deliberately conservative:
        # a false positive costs a build, while a missed dependency could make
        # the CI accept an unbuilt host configuration.
        for raw in PATH_RE.findall(text):
            child = resolve_cached(path, raw)
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

    direct_inputs = set(after.get("nodes", {}).get("root", {}).get("inputs", {}))
    host_inputs: dict[str, set[str]] = {}
    analysis_failed = False
    file_cache: dict[Path, str] = {root / "flake.nix": flake}
    path_cache: dict[tuple[Path, str], Path | None] = {}
    input_cache: dict[Path, set[str]] = {}
    for host in hosts:
        try:
            start = flake.find(f"nixosConfigurations.{host} =")
            block = matching_block(flake, start)
            paths = expand_helper_paths(flake, host)
            paths.extend(PATH_RE.findall(block))
            found, failed = analyze_host(
                root,
                paths,
                direct_inputs,
                file_cache,
                path_cache,
                input_cache,
            )
            found.update(
                name for name in direct_inputs if re.search(rf"\b{re.escape(name)}\b", block)
            )
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
