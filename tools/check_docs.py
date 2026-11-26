#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyyaml>=6"]
# ///
"""Check KSA project documentation structure and cross-references.

Rules come from ADR-SBC-0001 here, and the claude-scaffold "documents and
IDs" convention (ID scheme and document structure):

* every document under docs/ (except README.md and template.md) has YAML
  front matter with id, title, kind, status and date;
* IDs are unique, carry the SBC slug, and numbered kinds' file names start
  with the ID; the H1 starts with the ID and an "In short" summary follows;
* "Machine-readable" registers (requirements, tests, threats) parse and their
  IDs are unique;
* every SBC ID mentioned anywhere in the repo's Markdown exists;
* every must requirement is proven by at least one test (an error once the
  PRD is approved, a warning while it is a draft);
* the ADR index agrees with each ADR's status.

Usage:
    uv run tools/check_docs.py            # check, exit 1 on errors
    uv run tools/check_docs.py --matrix   # also print requirement -> tests
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

import yaml

# Project slug used in every ID (ADR-<SLUG>-0001). The only line to change
# when copying this file to another project.
SLUG = "SBC"

ROOT = Path(__file__).resolve().parent.parent
DOCS = ROOT / "docs"

KINDS = {
    # kind: (id prefix, numbered file name, allowed statuses)
    "adr": ("ADR", True, {"draft", "proposed", "accepted", "rejected", "withdrawn", "superseded", "deprecated"}),
    "prd": ("PRD", True, {"draft", "approved", "shipped", "retired"}),
    "design": ("DES", True, {"draft", "approved", "superseded"}),
    "runbook": ("RB", True, {"draft", "active", "retired"}),
    "architecture": ("ARC", False, {"draft", "approved"}),
    "test-plan": ("TST", False, {"draft", "approved"}),
    "threat-model": ("TM", False, {"draft", "approved"}),
}
REQ_ID = re.compile(rf"^(FR-{SLUG}-[A-Z]+-\d{{4}}|NFR-{SLUG}-\d{{4}})$")
THR_ID = re.compile(rf"^THR-{SLUG}-\d{{4}}$")
# Any SBC ID mentioned in prose. Placeholders (NNNN, AREA) do not match.
MENTION = re.compile(rf"\b((?:ADR|PRD|DES|RB|ARC|TST|TM|THR|NFR)-{SLUG}-\d{{4}}|FR-{SLUG}-[A-Z]+-\d{{4}})\b")
PRIORITIES = {"must", "should", "could"}
REQ_STATUSES = {"draft", "approved", "shipped", "dropped"}
RESIDUAL = {"low", "medium", "high", "unknown"}
STRIDE = set("STRIDE")
TEST_LEVELS = {"static", "template", "build", "integration", "security", "carrier"}


class Report:
    def __init__(self) -> None:
        self.errors: list[str] = []
        self.warnings: list[str] = []

    def error(self, where: Path | str, msg: str) -> None:
        self.errors.append(f"ERROR   {rel(where)}: {msg}")

    def warn(self, where: Path | str, msg: str) -> None:
        self.warnings.append(f"WARNING {rel(where)}: {msg}")


def rel(p: Path | str) -> str:
    return str(p.relative_to(ROOT)) if isinstance(p, Path) else p


def split_front_matter(text: str) -> tuple[dict | None, str]:
    if not text.startswith("---\n"):
        return None, text
    end = text.find("\n---\n", 4)
    if end < 0:
        return None, text
    return yaml.safe_load(text[4:end]) or {}, text[end + 5:]


def machine_block(body: str) -> dict | None:
    m = re.search(r"^## Machine-readable\s*$(.*?)^```yaml\n(.*?)^```", body, re.M | re.S)
    return yaml.safe_load(m.group(2)) if m else None


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--matrix", action="store_true", help="print requirement -> tests traceability")
    args = ap.parse_args()
    r = Report()

    docs: dict[str, dict] = {}          # id -> front matter (+ _path, _body)
    for path in sorted(DOCS.rglob("*.md")):
        if path.name in ("README.md", "template.md"):
            continue
        fm, body = split_front_matter(path.read_text(encoding="utf-8"))
        if fm is None:
            r.error(path, "missing YAML front matter")
            continue
        for field in ("id", "title", "kind", "status", "date"):
            if field not in fm:
                r.error(path, f"front matter missing '{field}'")
        kind, doc_id, status = fm.get("kind"), str(fm.get("id", "")), fm.get("status")
        if kind not in KINDS:
            r.error(path, f"unknown kind '{kind}'")
            continue
        prefix, numbered, statuses = KINDS[kind]
        if not re.fullmatch(rf"{prefix}-{SLUG}-\d{{4}}", doc_id):
            r.error(path, f"id '{doc_id}' should look like {prefix}-{SLUG}-NNNN")
        if status not in statuses:
            r.error(path, f"status '{status}' not one of {sorted(statuses)}")
        if status == "superseded" and not fm.get("superseded_by"):
            r.error(path, "superseded documents need 'superseded_by'")
        if numbered and not path.name.startswith(doc_id + "-"):
            r.error(path, f"file name should start with '{doc_id}-'")
        if doc_id in docs:
            r.error(path, f"duplicate id {doc_id} (also {rel(docs[doc_id]['_path'])})")
        if not re.search(rf"^# {re.escape(doc_id)}: ", body, re.M):
            r.error(path, f"H1 should start with '# {doc_id}: '")
        if "> **In short:**" not in body:
            r.error(path, "missing '> **In short:**' summary under the title")
        fm["_path"], fm["_body"] = path, body
        docs[doc_id] = fm

    # Registers
    requirements: dict[str, dict] = {}
    proposed: dict[str, dict] = {}
    tests: dict[str, dict] = {}
    threats: dict[str, dict] = {}
    prd_approved = False

    def load(kind: str) -> list[tuple[Path, dict]]:
        out = []
        for d in docs.values():
            if d["kind"] == kind:
                data = machine_block(d["_body"])
                if data is None:
                    r.error(d["_path"], "missing '## Machine-readable' yaml block")
                else:
                    out.append((d["_path"], data))
        return out

    for path, data in load("prd"):
        prd_approved |= docs_by_path(docs, path).get("status") in ("approved", "shipped")
        for q in data.get("requirements") or []:
            qid = q.get("id", "")
            if not REQ_ID.match(qid):
                r.error(path, f"bad requirement id '{qid}'")
            if qid in requirements:
                r.error(path, f"duplicate requirement {qid}")
            if q.get("priority") not in PRIORITIES:
                r.error(path, f"{qid}: priority must be one of {sorted(PRIORITIES)}")
            if q.get("status") not in REQ_STATUSES:
                r.error(path, f"{qid}: status must be one of {sorted(REQ_STATUSES)}")
            if not q.get("title"):
                r.error(path, f"{qid}: missing title")
            requirements[qid] = q | {"_path": path}

    for path, data in load("threat-model"):
        for q in data.get("proposed_requirements") or []:
            qid = q.get("id", "")
            if not REQ_ID.match(qid):
                r.error(path, f"bad proposed requirement id '{qid}'")
            if qid in requirements:
                r.error(path, f"proposed {qid} already exists in a PRD; remove it from proposed_requirements")
            proposed[qid] = q | {"_path": path}
        for t in data.get("threats") or []:
            tid = t.get("id", "")
            if not THR_ID.match(tid):
                r.error(path, f"bad threat id '{tid}'")
            if tid in threats:
                r.error(path, f"duplicate threat {tid}")
            if not set(t.get("stride") or []) <= STRIDE or not t.get("stride"):
                r.error(path, f"{tid}: stride must be a non-empty list of S, T, R, I, D, E")
            if t.get("residual") not in RESIDUAL:
                r.error(path, f"{tid}: residual must be one of {sorted(RESIDUAL)}")
            threats[tid] = t | {"_path": path}

    for path, data in load("test-plan"):
        for t in data.get("tests") or []:
            tid = t.get("id", "")
            if tid in tests:
                r.error(path, f"duplicate test {tid}")
            if t.get("level") not in TEST_LEVELS:
                r.error(path, f"{tid}: level must be one of {sorted(TEST_LEVELS)}")
            tests[tid] = t | {"_path": path}

    known = set(docs) | set(requirements) | set(proposed) | set(threats)

    # Cross-references inside registers
    for tid, t in tests.items():
        for q in t.get("proves") or []:
            if q not in requirements and q not in proposed:
                r.error(t["_path"], f"test {tid} proves unknown requirement {q}")
    for tid, t in threats.items():
        for q in t.get("requirements") or []:
            if q not in requirements and q not in proposed:
                r.error(t["_path"], f"threat {tid} cites unknown requirement {q}")
        for x in t.get("tests") or []:
            if x not in tests:
                r.error(t["_path"], f"threat {tid} cites unknown test {x}")
    for qid, q in list(requirements.items()) + list(proposed.items()):
        for ref in (q.get("adr") or []) + (q.get("threats") or []):
            if ref not in known:
                r.error(q["_path"], f"{qid} cites unknown {ref}")

    # Front matter references
    for doc_id, d in docs.items():
        for field in ("related", "supersedes", "delivers"):
            for ref in d.get(field) or []:
                if ref not in known:
                    r.error(d["_path"], f"{field}: unknown id {ref}")
        sb = d.get("superseded_by")
        if sb and sb not in docs:
            r.error(d["_path"], f"superseded_by: unknown id {sb}")

    # Every SBC ID mentioned in any Markdown file must exist
    md_files = [p for p in ROOT.rglob("*.md")
                if ".git" not in p.parts and "work" not in p.parts and p.name != "template.md"]
    for p in md_files:
        for n, line in enumerate(p.read_text(encoding="utf-8").splitlines(), 1):
            for m in MENTION.finditer(line):
                if m.group(1) not in known:
                    r.error(f"{rel(p)}:{n}", f"mentions unknown id {m.group(1)}")

    # Coverage: every must requirement has a test
    proven = {q for t in tests.values() for q in t.get("proves") or []}
    for qid, q in requirements.items():
        if q.get("priority") == "must" and q.get("status") != "dropped" and qid not in proven:
            (r.error if prd_approved else r.warn)(q["_path"], f"must requirement {qid} has no test")

    # ADR index agrees with ADR status
    index = DOCS / "adr" / "README.md"
    if index.exists():
        rows = dict(re.findall(rf"^\| \[(ADR-{SLUG}-\d{{4}})\][^|]*\|[^|]*\| ([^|]+?) \|", index.read_text(), re.M))
        for doc_id, d in docs.items():
            if d["kind"] != "adr":
                continue
            listed = rows.get(doc_id)
            if listed is None:
                r.error(index, f"{doc_id} missing from the index")
            elif not listed.lower().startswith(str(d["status"])):
                r.error(index, f"{doc_id} listed as '{listed}' but its status is '{d['status']}'")

    if args.matrix:
        print("requirement".ljust(22), "priority".ljust(8), "tests")
        for qid, q in requirements.items():
            ts = [t for t, v in tests.items() if qid in (v.get("proves") or [])]
            print(qid.ljust(22), q.get("priority", "").ljust(8), ", ".join(ts) or "-")
        print()

    for line in r.warnings + r.errors:
        print(line)
    print(f"{len(docs)} documents, {len(requirements)} requirements ({len(proposed)} proposed), "
          f"{len(tests)} tests, {len(threats)} threats: {len(r.errors)} errors, {len(r.warnings)} warnings")
    return 1 if r.errors else 0


def docs_by_path(docs: dict[str, dict], path: Path) -> dict:
    return next(d for d in docs.values() if d["_path"] == path)


if __name__ == "__main__":
    sys.exit(main())
