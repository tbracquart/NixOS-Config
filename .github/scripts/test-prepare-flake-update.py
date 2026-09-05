#!/usr/bin/env python3
"""Regression tests for prepare-flake-update.py."""

from __future__ import annotations

import importlib.util
import json
import tempfile
from pathlib import Path


SCRIPT = Path(__file__).with_name("prepare-flake-update.py")


spec = importlib.util.spec_from_file_location("prepare_flake_update", SCRIPT)
if spec is None or spec.loader is None:
    raise RuntimeError(f"could not load {SCRIPT}")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


def test_prepare_outputs() -> None:
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
                "alpha": {"locked": {"rev": "a", "lastModified": 100 * 86400}},
                "beta": {"locked": {"rev": "b", "lastModified": 200 * 86400}},
            }
        }
        after = json.loads(json.dumps(before))
        after["nodes"]["alpha"]["locked"]["rev"] = "a2"
        after["nodes"]["alpha"]["locked"]["lastModified"] = 102 * 86400

        before_path = root / "before.json"
        after_path = root / "after.json"
        before_path.write_text(json.dumps(before))
        after_path.write_text(json.dumps(after))

        title, body, build_hosts = module.prepare_outputs(before_path, after_path, root)

        assert title == "chore: nix flake update — alpha (+2j)"
        assert "- alpha (+2j)" in body
        assert "- `alpha`" not in body
        assert "- `A` : build" in body
        assert "- `B` : ignoré (aucune dépendance affectée)" in body
        assert build_hosts == ["A"]


test_prepare_outputs()
print("prepare-flake-update regression tests: OK")
