# Definition of Done

A task is **done** when every item below is true. Apply per-PR; enforce at review time.

## Code
- [ ] All acceptance criteria from the task file are implemented.
- [ ] No TODOs or commented-out code introduced in this PR.
- [ ] No new warnings or lint violations.

## Tests
- [ ] Every acceptance criterion has at least one test asserting it.
- [ ] New code meets the coverage target in `operating-preferences-template.md` (project default: see section D).
- [ ] Existing tests still pass locally and in CI.

## Documentation (Living Documentation principle — see CLAUDE.md)
A task is **not done** if the docs that describe what it changed are out of date. Same PR, not "later".

- [ ] **Behavior or contract change** → corresponding `docs/design/*` updated in this PR.
- [ ] **Requirement / acceptance criterion change** → `docs/requirements/*` updated in this PR.
- [ ] **Agent added / removed / responsibility shifted** → `docs/agents/team-composition.md` + `capability-log.md` updated in this PR.
- [ ] **External dependency / MCP / tool added** → ADR drafted in `docs/ssot/decisions/` *and* `capability-log.md` row appended in this PR.
- [ ] **New domain term used in code or docs** → `docs/ssot/glossary.md` entry added in this PR.
- [ ] **Roadmap impact** (task scope change, milestone shift, new risk surfaced) → `docs/roadmap/*` updated in this PR.
- [ ] **Hook / settings / agent persona / process doc changed** → `CLAUDE.md` updated if user-facing implication, plus the relevant `docs/process/*` doc.
- [ ] **No "TODO: update doc" comments** introduced — if a doc needs updating, it must be updated *in this PR*, not deferred.

If you genuinely cannot update a doc now (e.g., the corresponding doc doesn't exist yet because it's a different layer), file a follow-up task in `docs/roadmap/tasks/` referenced from the PR body.

## Review
- [ ] PR body follows the template (Purpose, Roadmap Link, Changes, Related Docs, Review Checklist).
- [ ] Three reviewers have verdicts on record.
- [ ] Blocking comments resolved.

## Git Hygiene
- [ ] Commits follow Conventional Commits.
- [ ] No `--no-verify`, `--force`, `--amend` after push.
- [ ] Branch name matches `feature/<task-id>-<slug>`.

## Merge
- [ ] Approvals meet the configured policy (default: unanimous).
- [ ] Feature branch marked for deletion on merge.

## Post-Merge
- [ ] Technical Writer reconciles any downstream docs within the next merged PR (not this one).

A PR that does not satisfy all checkboxes is **not** merged. Exceptions require an explicit deviation note in the PR and user approval recorded.
