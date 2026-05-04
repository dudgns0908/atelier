# Git Flow Conventions

## Branch Model

```
main ─── release only, tagged, protected
 ↑
develop ── integration, feature PRs target this
 ↑
feature/<task-id>-<slug> ── one task, one branch
```

## Branch Naming

- `feature/t<NN>-<kebab-slug>` — one task.
- `fix/h<NN>-<kebab-slug>` — post-release hotfix (branched from `main`, merged into `main` then back-merged into `develop`). See `skills/hotfix/SKILL.md`.
- `release/vX.Y.Z` *(optional)* — when a release needs stabilization before the `main` merge.
- Task id format: `T01`, `T02` for features; `H01`, `H02` for hotfixes; lowercase in branch names.

## Hotfix Branch Lifecycle

```
main (v1.2.0) ─●─────────────────●── (v1.2.1 tagged after hotfix merge)
                \               /
fix/h01-*        ●───fix + test●
                                 \
develop ─●──●──●──●──●──●──●──●───●── (back-merge from main)
```

Governance is stricter than feature branches:
- Always unanimous reviewer approval (no majority relaxation).
- Must include a regression test that fails pre-fix and passes post-fix.
- Merged to `main` triggers patch version bump; immediate back-merge into `develop`.

## Commit Messages (Conventional Commits)

```
<type>(<optional-scope>): <imperative subject ≤72 chars>

<optional body explaining *why*, wrapped at 80>

<optional footer: BREAKING CHANGE, Refs, Co-Authored-By>
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `build`, `ci`, `style`.

Rules:
- One logical change per commit.
- Subject in imperative mood ("add", not "added" or "adds").
- Body explains *why*. The diff shows *what*.
- Breaking changes include a `BREAKING CHANGE:` footer.

## PR Title

```
[<TASK-ID>] <type>: <intent>
```

Example: `[T07] feat: add JWT-based user authentication`

## Protected Operations (plugin hooks enforce)

- No direct commits to `main` or `develop`.
- No `--force` or `--force-with-lease` pushes to shared branches.
- No `--no-verify` commits.
- No `--amend` after push on a shared branch.

## Post-Merge Cleanup

After a feature PR merges:
```
git checkout develop && git pull
git branch -d feature/<task-id>-<slug>
git fetch --prune
```

The `atelier-cleanup-feature` helper performs these steps idempotently.
