# Contributing to os-SBC

## Workflow

1. **Issue first.** Every change starts as a GitHub issue with a milestone.
2. **Design docs.** ADR if a significant decision is made; update the PRD and
   `ROADMAP.md` if scope moves.
3. **Code and tests** on a working branch.
4. **User docs**: test scenarios, examples, troubleshooting notes.
5. **Close the issue** with the version, commit SHA and doc pointers.

## Branches

The full model is [ADR-0004](docs/adr/0004-branching-and-release-model.md).
In short:

| Branch | What it is |
|---|---|
| `next` | Default branch. All work merges here. Builds `os-sbc-devel`. |
| `release/N.x` | One per major line. Fixes only, via backport PRs. Tags `vN.M.P` live here. |
| `archive/*` | Frozen history. |

```bash
git switch next && git pull
git switch -c feat/12-rtpproxy-service      # <type>/<issue>-<slug>
# ... work, commit ...
git push -u origin feat/12-rtpproxy-service
gh pr create --base next
```

Types: `feat`, `fix`, `docs`, `ci`, `chore`, `refactor`, `spike`, `backport`.

Rules: one issue → one branch → one PR. Never stack PRs. Merge commits only.
Kevin merges. Branches are deleted on merge.

### Backporting a fix to a release line

The fix merges to `next` first, then:

```bash
git switch -c backport/31-bye-leak-1.x origin/release/1.x
git cherry-pick -x <sha-on-next>
gh pr create --base release/1.x --title "fix: ... (backport #31)"
```

## Commits

Conventional commits (`feat:`, `fix:`, `docs:`, `ci:`, `chore:`, `refactor:`).
The message explains why; the diff shows what. Never amend published commits,
never skip hooks.

## Checks

A PR merges only when `lint`, `test` and `build` pass
([ADR-0007](docs/adr/0007-ci-pipeline.md)). Anything that could only be tested
on a real OPNsense box must say so in the PR.

## Releases

See [docs/runbooks/0001-cut-a-release.md](docs/runbooks/0001-cut-a-release.md).
