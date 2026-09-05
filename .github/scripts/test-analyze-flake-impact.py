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


def run_transitive_case() -> None:
    """A nested lock-node change must affect the top-level input that reaches it."""
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "hosts").mkdir()
        (root / "hosts/A.nix").write_text("{ alpha }: { }\n")
        (root / "hosts/B.nix").write_text("{ beta }: { }\n")
        (root / "flake.nix").write_text(
            """
{
  hostModules = host: [ ./hosts/${host}.nix ];
  nixosConfigurations.A = { alpha, ... }: {
    modules = hostModules "A";
  };
  nixosConfigurations.B = { beta, ... }: {
    modules = hostModules "B";
  };
}
"""
        )

        before = {
            "nodes": {
                "root": {"inputs": {"alpha": "alpha", "beta": "beta"}},
                "alpha": {"locked": {"rev": "a"}, "inputs": {"child": "child"}},
                "beta": {"locked": {"rev": "b"}},
                "child": {"locked": {"rev": "child-a"}},
            }
        }
        after = json.loads(json.dumps(before))
        after["nodes"]["child"]["locked"]["rev"] = "child-b"

        before_path = root / "before.json"
        after_path = root / "after.json"
        before_path.write_text(json.dumps(before))
        after_path.write_text(json.dumps(after))

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
        if json.loads(actual) != ["A"]:
            raise AssertionError(f"expected ['A'], got {actual}")


def run_unreferenced_input_case() -> None:
    """An unused top-level input must conservatively rebuild every host."""
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "hosts").mkdir()
        (root / "hosts/A.nix").write_text("{ alpha }: { }\n")
        (root / "hosts/B.nix").write_text("{ beta }: { }\n")
        (root / "flake.nix").write_text(
            """
{
  hostModules = host: [ ./hosts/${host}.nix ];
  nixosConfigurations.A = { alpha, ... }: {
    modules = hostModules "A";
  };
  nixosConfigurations.B = { beta, ... }: {
    modules = hostModules "B";
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

        before = lock({"alpha": "a", "beta": "b", "gamma": "g"})
        after = lock({"alpha": "a", "beta": "b", "gamma": "g2"})
        before_path = root / "before.json"
        after_path = root / "after.json"
        before_path.write_text(json.dumps(before))
        after_path.write_text(json.dumps(after))

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
        if json.loads(actual) != ["A", "B"]:
            raise AssertionError(f"expected ['A', 'B'], got {actual}")


def run_parent_relative_case() -> None:
    """Parent-relative imports must be followed from the importing file."""
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "common").mkdir()
        (root / "hosts" / "A").mkdir(parents=True)
        (root / "hosts" / "B").mkdir(parents=True)
        (root / "common" / "default.nix").write_text("{ alpha }: { }\n")
        (root / "hosts" / "A" / "configuration.nix").write_text(
            "{ ... }:\n{ imports = [ ../../common ]; }\n"
        )
        (root / "hosts" / "B" / "configuration.nix").write_text("{ beta }: { }\n")
        (root / "flake.nix").write_text(
            """
{
  nixosConfigurations.A = { alpha, ... }: {
    modules = [ ./hosts/A/configuration.nix ];
  };
  nixosConfigurations.B = { beta, ... }: {
    modules = [ ./hosts/B/configuration.nix ];
  };
}
"""
        )

        before = {
            "nodes": {
                "root": {"inputs": {"alpha": "alpha", "beta": "beta"}},
                "alpha": {"locked": {"rev": "a"}},
                "beta": {"locked": {"rev": "b"}},
            }
        }
        after = json.loads(json.dumps(before))
        after["nodes"]["alpha"]["locked"]["rev"] = "a2"

        before_path = root / "before.json"
        after_path = root / "after.json"
        before_path.write_text(json.dumps(before))
        after_path.write_text(json.dumps(after))

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
        if json.loads(actual) != ["A"]:
            raise AssertionError(f"expected ['A'], got {actual}")


# Host-specific inputs must only rebuild the host that references them.
run_case({"alpha": "a2"}, ["A"])
run_case({"beta": "b2"}, ["B"])

# An input unknown to the static dependency graph must conservatively rebuild all hosts.
run_case({"gamma": "g2"}, ["A", "B"])

# A transitive lock-node change must rebuild hosts using the affected top-level input.
run_transitive_case()

# An unused top-level input must also rebuild all hosts conservatively.
run_unreferenced_input_case()

# Parent-relative imports such as ../../common must be followed correctly.
run_parent_relative_case()

print("analyze-flake-impact regression tests: OK")
