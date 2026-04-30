# Change Review Workflow

Authoritative document for Phase 2 iteration. Every code change passes through this pipeline.

> **Forge-agnostic.** The workflow is identical across hosts; only the review-artifact noun and CLI change. See `operating-preferences-template.md` section H.

| Forge | Review artifact | CLI | Notes |
|---|---|---|---|
| GitHub *(default)* | Pull Request (PR) | `gh` | `atelier-open-pr` wraps `gh pr create`. |
| GitLab | Merge Request (MR) | `glab` | Substitute `glab mr create/merge/approve`. |
| Bitbucket | Pull Request (PR) | Bitbucket CLI/API | Helper adapts. |
| Gerrit | Change / Patchset | `git review` | Two-stage review → submit. |
| Local-only | Branch + review markdown | — | `docs/roadmap/reviews/<task-id>.md` holds reviewer verdicts. |

Throughout this document, "review" refers to the chosen forge's artifact. Any command like `gh pr create` should be read as "the equivalent command in the selected forge's CLI".

## Cycle (one task → one review)

1. **Assignment**
   - Project Manager selects the next task from `docs/roadmap/tasks/`.
   - Assigns to the appropriate implementation agent (Software Engineer or a specialized variant).

2. **Branch**
   ```
   git checkout develop && git pull
   git checkout -b feature/<task-id>-<kebab-slug>
   ```

3. **Implement & Commit**
   - Small, meaningful commits using Conventional Commits.
   - Tests for each acceptance criterion.
   - Pre-commit hooks (lint/format/test per `operating-preferences-template.md` section I) must pass.
   - No scope creep — only the task's changes.

4. **Push & Open Review**
   ```
   git push -u origin feature/<task-id>-<kebab-slug>
   atelier-open-pr   # wrapper: routes to gh | glab | bitbucket | git review based on forge
   ```

5. **Mandatory Three-Reviewer Gate**
   Parallel reviews by:
   - **Senior Software Engineer** — code quality checklist.
   - **Tech Lead** — architectural alignment checklist.
   - **QA Engineer** — requirements & roadmap alignment checklist + lint/format/CI green.
   Each reviewer leaves at least one substantive comment and a verdict: `APPROVE` / `REQUEST_CHANGES` / `COMMENT`.

6. **Iterate on Feedback**
   - Implementer pushes additional commits addressing comments (never `--force` or `--amend` on a shared branch).
   - Reviewers re-review until all blocking comments are resolved.

7. **Merge**
   - **Default policy**: unanimous `APPROVE` from all three reviewers required. `operating-preferences-template.md` may relax to 2-of-3 majority with dissent recorded.
   - Conductor (main thread) performs the merge using `atelier-check-reviews && <forge> merge --delete-source-branch`.
   - Squash vs merge policy is set in `operating-preferences-template.md`; default is merge commit to preserve per-commit history.

8. **Cleanup**
   - Feature branch deleted remotely by the forge's merge action (with `--delete-source-branch` or equivalent).
   - Local cleanup: `atelier-cleanup-feature`.
   - `develop` pulled to refresh local state.

9. **Post-Merge Doc Sync**
   - Technical Writer inspects the diff and updates affected `docs/` files.
   - New terms added to `docs/ssot/glossary.md`.
   - If a design decision was made, ADR added to `docs/ssot/decisions/`.

10. **Next Task**
    - Project Manager selects the next task; cycle repeats.
    - At milestone boundary, `/atelier:milestone-checkpoint` runs before the next milestone's first task.

## Release Cycle (`develop` → `main`)

- Triggered when Project Manager marks a milestone complete and user approves.
- Change request from `develop` to `main` reviewed by Tech Lead + QA Engineer + Senior Software Engineer.
- On merge: tag `vX.Y.Z`, Technical Writer updates changelog.

## Conflict Resolution

Parallel work creates two kinds of conflict.

### Prevention (by design)
- **Dependency graph** in `docs/roadmap/dependency-graph.md` sequences conflicting tasks.
- **Module ownership**: CAIO assigns module ranges to specialized engineers (e.g., Backend Engineer owns `src/api/`, Frontend Engineer owns `src/ui/`).
- **Lock-file discipline**: only one task may touch `package-lock.json` / `Cargo.lock` / `uv.lock` per release window; Project Manager serializes.

### Merge conflicts (line overlap)
1. Owner of the *later* task rebases and resolves.
2. Tie-breaker priorities: **Safety** (security/data integrity) > **Correctness** (tests pass) > earlier-merged convention wins.
3. Blocker: design judgment → Tech Lead; requirement intent → Product Manager.
4. Document the resolution choice in the PR body under `## Conflict Resolution`.

### Semantic conflicts (no line overlap, but contradictory behavior)
Example: Task A sets rate-limit to 100 RPS; Task B (already merged) assumed 200 RPS.
1. QA Engineer cross-references acceptance criteria during review.
2. Escalate to Product Manager (requirement) or Software Architect (design).
3. Resolve via: update requirements / introduce feature flag / revert one task.
4. ADR required if design-level decision.

### Escalation matrix
| Conflict Type | Escalate To |
|---|---|
| Line-level, same module | Tech Lead |
| Module-boundary crossing | Software Architect |
| Contradicting acceptance criteria | Product Manager |
| Scheduling / serialization issue | Project Manager |
| Team-composition gap | Chief AI Officer |

### Forbidden conflict-resolution shortcuts
- Force-pushing over the other branch.
- Deleting the other task's code to "resolve" ambiguity.
- Silent resolution — every conflict resolution leaves a written record.

## Forbidden Operations

- `git push --force` or `--force-with-lease` on `main`, `develop`, or another engineer's branch.
- `git commit --no-verify`.
- Direct commits to `main` or `develop`.
- Self-approving your own change request.
- `LGTM`-only reviews.
- Merging with unresolved `REQUEST_CHANGES`.
- Bypassing the lint/format pre-commit hook chain chosen in `operating-preferences-template.md` section I.
