# Task Frontmatter Schema

Authoritative schema for `docs/roadmap/tasks/t<NN>-<slug>.md` (and `h<NN>-*.md` for hotfix tasks). Validated by `bin/atelier-validate` when invoked from a user-project root.

## Schema (v1)

```yaml
---
id: t<NN>                  # required. matches filename prefix.
title: <one-line title>     # required. <= 80 chars, imperative mood preferred.
status: <enum>              # required. assigned | in-progress | done | merged | blocked
lane: <enum>                # required. backlog | todo | in-progress | in-review | done
epic: <slug>                # optional. omit for standalone task.
size: <enum>                # required. S | M | L (S ~= half day, M ~= 1 day, L ~= 2 days; >L should be split)
depends_on: [<id>, ...]     # required. empty list [] if no deps.
acceptance:                 # required. checkbox list. each item independently verifiable.
  - [ ] <criterion>
  - [x] <criterion>         # check after PR merge resolving the AC
linked_issue: <N>           # optional. forge issue number when mirrored (GitHub mode).
linked_requirement: <path>  # optional but recommended. e.g., docs/requirements/auth.md#login
linked_design: <path>       # optional but recommended. e.g., docs/design/architecture.md#auth-flow
assignee: <agent-name>      # optional until lane >= todo. e.g., backend-engineer
branch: feature/t<NN>-<slug># optional until lane >= in-progress.
pr: <number>                # optional until lane >= in-review.
---
```

## Body sections (after frontmatter)

```markdown
# t<NN> — <title>

## Description
<1-3 sentences. What is this task? Why is it needed?>

## Linked
- Requirement: <link or "n/a">
- Design: <link or "n/a">
- Issue: <link or "n/a">

## Acceptance Criteria
<repeat the checkbox list from frontmatter for human readability>
- [ ] ...

## Implementation notes
<non-obvious constraints, gotchas, prior-art references. Optional.>
```

## Lane → Status mapping

| `lane:` | implied `status:` | meaning |
|---|---|---|
| `backlog` | `assigned` (or empty) | known but not yet scheduled |
| `todo` | `assigned` | next up; ready to start |
| `in-progress` | `in-progress` | branch exists, code being written |
| `in-review` | `in-progress` (still) | PR opened, 3-reviewer cycle |
| `done` | `merged` | PR merged, AC all checked |

`lane` and `status` may temporarily disagree during transitions (e.g., PR merged but status not yet updated). PM's `/atelier:milestone-checkpoint` audit catches stale bookkeeping.

## Forbidden patterns

- `size: XL` or larger. Split into multiple tasks. > 2-day work doesn't fit one PR.
- Empty `acceptance`. Every task has at least one verifiable criterion.
- `depends_on` cycles. Validate must reject.
- `id` mismatch with filename. Both must agree.
- Multiple tasks with the same `id`.
- `lane: done` with any unchecked `acceptance:` item.

## Validation

`bin/atelier-validate` (when invoked in a user-project root with `docs/roadmap/tasks/`) checks:

- All required keys present.
- `id` matches filename prefix (`t<NN>` or `h<NN>`).
- `status` and `lane` values from the enum.
- `size` from {S, M, L}.
- `depends_on` references resolve to existing task ids.
- Acyclic `depends_on` graph.
- `lane: done` ⇒ all acceptance items checked.

Validation in plugin-self-check mode (no `docs/roadmap/tasks/`) is a no-op — the directory is user-project content, not plugin content.

## See also

- `skills/plan-milestone/SKILL.md` — produces task files following this schema.
- `skills/milestone-checkpoint/SKILL.md` § "Lane drift" audit — catches stale bookkeeping.
- `docs/process/agent-team-sizing.md` — sizing rule (one PR = ½–2 days).
- `docs/process/issue-management.md` — `linked_issue:` ↔ Issue cross-reference rules.
- `docs/process/status-schema.md` — `lanes:` and `epics:` fields in `atelier-status --json`.
