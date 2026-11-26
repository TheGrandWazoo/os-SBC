"""Tests for tools/check_docs.py (ADR-SBC-0001 document rules).

Each test copies the repository's docs and the checker into a temporary
tree, optionally breaks something, and runs the checker there. The checker
finds its root from its own location, so the copy is checked in isolation.
"""

from __future__ import annotations

import re
import shutil
import subprocess
import sys
from pathlib import Path

import pytest

REPO = Path(__file__).resolve().parent.parent


@pytest.fixture()
def tree(tmp_path: Path) -> Path:
    shutil.copytree(REPO / "docs", tmp_path / "docs")
    (tmp_path / "tools").mkdir()
    shutil.copy2(REPO / "tools" / "check_docs.py", tmp_path / "tools")
    for md in REPO.glob("*.md"):
        shutil.copy2(md, tmp_path)
    return tmp_path


def run(root: Path, *args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(root / "tools" / "check_docs.py"), *args],
        capture_output=True, text=True, check=False,
    )


def edit(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    assert old in text, f"fixture text not found in {path.name}: {old!r}"
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def test_repository_docs_pass(tree: Path) -> None:
    result = run(tree)
    assert result.returncode == 0, result.stdout + result.stderr
    assert " 0 errors" in result.stdout


def test_matrix_lists_every_requirement(tree: Path) -> None:
    result = run(tree, "--matrix")
    assert result.returncode == 0, result.stdout
    assert re.search(r"^FR-SBC-MEDIA-0001\s+must\s+\S", result.stdout, re.MULTILINE)


def test_unknown_id_in_prose_is_an_error(tree: Path) -> None:
    edit(tree / "ROADMAP.md", "# os-SBC roadmap", "# os-SBC roadmap\n\nSee ADR-SBC-0999.")
    result = run(tree)
    assert result.returncode == 1
    assert "mentions unknown id ADR-SBC-0999" in result.stdout


def test_test_proving_unknown_requirement_is_an_error(tree: Path) -> None:
    edit(tree / "docs/testing/test-plan.md",
         "proves: [FR-SBC-REG-0001], title: \"phone registers",
         "proves: [FR-SBC-REG-0099], title: \"phone registers")
    result = run(tree)
    assert result.returncode == 1
    assert "proves unknown requirement FR-SBC-REG-0099" in result.stdout


def test_missing_in_short_is_an_error(tree: Path) -> None:
    adr = next((tree / "docs/adr").glob("ADR-SBC-0003-*.md"))
    edit(adr, "> **In short:**", "> Summary:")
    result = run(tree)
    assert result.returncode == 1
    assert "missing '> **In short:**'" in result.stdout


def test_adr_index_must_match_status(tree: Path) -> None:
    adr = next((tree / "docs/adr").glob("ADR-SBC-0003-*.md"))
    edit(adr, "status: proposed", "status: accepted")
    result = run(tree)
    assert result.returncode == 1
    assert "ADR-SBC-0003 listed as 'Proposed' but its status is 'accepted'" in result.stdout


def test_uncovered_must_requirement_warns_while_draft(tree: Path) -> None:
    plan = tree / "docs/testing/test-plan.md"
    edit(plan, "proves: [FR-SBC-REG-0001], title: \"phone registers",
         "proves: [], title: \"phone registers")
    result = run(tree)
    assert result.returncode == 0, result.stdout
    assert "WARNING" in result.stdout and "FR-SBC-REG-0001 has no test" in result.stdout


def test_uncovered_must_requirement_fails_once_approved(tree: Path) -> None:
    plan = tree / "docs/testing/test-plan.md"
    edit(plan, "proves: [FR-SBC-REG-0001], title: \"phone registers",
         "proves: [], title: \"phone registers")
    prd = next((tree / "docs/prd").glob("PRD-SBC-0001-*.md"))
    edit(prd, "status: draft", "status: approved")
    result = run(tree)
    assert result.returncode == 1
    assert "ERROR" in result.stdout and "FR-SBC-REG-0001 has no test" in result.stdout
