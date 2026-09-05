#!/usr/bin/env python3
"""Regression tests for analyze-flake-impact.py using synthetic flake fixtures."""

from __future__ import annotations

import json
import subprocess
import sys
import tempfile
from pathlib import Path


SCRIPT = Path(__file__).with_name("analyze-flake-impact.py")


def run_case(changed: dict[str, str], expected: list[str]) -> None:
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "common.nix").write_text("{ }: { }\n")
        (root / "hosts").mkdir()
        (root / "hosts/A.nix").write_text("{ alpha }: { }\n")
        (root / "hosts/B.nix").write_text("{ beta }: { }\n")
        (root / "flake.nix").write_text(
            """
{
  commonModules = [ ./common.nix ];
  hostModules = host: [ ./hosts/${host}.nix ];
  nixosConfigurations.A = { alpha, ... }: {
    modules = commonModules ++ hostModules "A";
  };
  nixosConfigurations.B = { beta, ... }: {
    modules = commonModules ++ hostModules "B";
  };
}
"""
        )

        def lock(revisions: dict[str, str]) -> dict:
            nodes = {"root": {"inputs": {name: name for name in revisions}}}
            nodes.update(
                {name: {"locked": {"rev": rev}} for name, rev in revisions.items()}
            )
            return {"nodes": nodes}

        before = {"alpha": "a", "beta": "b"}
        after = dict(before)
        after.update(changed)
        before_path = root / "before.json"
        after_path = root / "after.json"
        before_path.write_text(json.dumps(lock(before)))
        after_path.write_text(json.dumps(lock(after)))

        result = subprocess.run(
            [sys.executable, str(SCRIPT), str(before_path), str(after_path), str(root)],
            text=True,
            capture_output=True,
            check=True,
        )
        actual = next(
            line.removeprefix("build-hosts=")
            for line in result.stdout.splitlines()
            if line.startswith("build-hosts=")
        )
        if json.loads(actual) != expected:
            raise AssertionError(f"expected {expected}, got {actual}")


# Host-specific inputs must only rebuild the host that references them.
run_case({"alpha": "a2"}, ["A"])
run_case({"beta": "b2"}, ["B"])

# An input unknown to the static dependency graph must conservatively rebuild all hosts.
run_case({"gamma": "g2"}, ["A", "B"])

print("analyze-flake-impact regression tests: OK")
