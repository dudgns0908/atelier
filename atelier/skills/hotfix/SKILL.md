---
name: hotfix
description: Produce a production hotfix — branch from main, fix, change-review back into main, then merge the fix back into develop. Use when a bug in the released version (main) must be patched without waiting for the normal develop→main cycle.
---

# Hotfix

You are the Conductor coordinating a production-path fix that bypasses the normal develop cycle.

## When to Use

- A bug exists in `main` (released) that cannot wait for the next milestone release.
- Security vulnerability.
- Data-integrity issue.

Not for: ordinary bugs found in `develop` — use the normal task cycle.

## Workflow

### 1. Assignment
- Project Manager creates a hotfix task: `docs/roadmap/tasks/h<NN>-<slug>.md`.
- Assigns to the relevant implementation agent (prefer the domain owner from team-composition).

### 2. Branch from main
```
git checkout main && git pull
git checkout -b fix/h<NN>-<kebab-slug>
```

### 3. Minimal Fix + Test
- Write a regression test that reproduces the issue.
- Apply the **smallest possible** code change to fix.
- No refactors, no cleanup. Scope is the regression only.

### 4. Three-Reviewer Gate (Expedited)
Open change request against `main`. All three reviewers still required, but reviewers **acknowledge expedited status** and aim for same-day turnaround:
- **Senior Software Engineer**: code quality + regression test confirms fix.
- **Tech Lead**: architectural neutrality — fix must not introduce debt.
- **QA Engineer**: verifies the regression test fails pre-fix and passes post-fix.

Unanimous approval required (no relaxation to majority for hotfixes).

### 5. Merge to main + Tag
```
atelier-check-reviews <CR-NUMBER> --policy unanimous
<forge> merge --delete-source-branch
git checkout main && git pull
git tag vX.Y.<Z+1>  # patch version bump
git push origin vX.Y.<Z+1>
```

### 6. Back-Merge to develop
```
git checkout develop && git pull
git merge main   # or cherry-pick if divergence is large
# resolve conflicts, prefer develop's version for non-hotfix code
git push origin develop
```

If the back-merge conflicts materially with in-flight develop work, escalate to Tech Lead for resolution before push.

### 7. Post-Hotfix Documentation
- Technical Writer updates changelog with the patch version.
- ADR recorded if the hotfix exposed a design flaw.
- Lessons-learned entry in `docs/roadmap/lessons-learned.md`.

### 8. Postmortem (if severity warranted)
- For security / data-loss hotfixes, run a short postmortem: timeline, root cause, preventative actions.
- Append to `docs/roadmap/postmortems/pm-<NN>-<slug>.md`.

## Forbidden

- Skipping the three-reviewer gate even for "obvious" fixes.
- Combining a hotfix with unrelated changes.
- Merging to `main` without also planning the back-merge to `develop`.
- Hotfixing `develop` directly — that's a regular task, not a hotfix.

## Reference Documents

- `docs/process/change-review-workflow.md` (expedited variant of the normal cycle)
- `docs/process/git-flow.md` (hotfix branch pattern)
- `docs/process/release-process.md`
