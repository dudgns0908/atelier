# Lessons Learned

Append-only log. Updated at every `milestone-checkpoint` and after every `hotfix` / `release`. Agents consult this file before starting new tasks to avoid repeating mistakes.

## Why this exists

Knowledge accrued during a project does not automatically carry forward between tasks. This file is the **persistent memory** of what worked, what failed, and what to watch for.

## Entry Format

Each entry is a level-3 heading with structured fields.

```markdown
### 2026-04-25 — <short title>

- **Context**: task / milestone / PR that triggered the lesson.
- **Observation**: what happened (good or bad).
- **Root cause** (if negative): why it happened.
- **Lesson**: the generalizable takeaway.
- **Action applied**: what change was made to process, docs, or code.
- **Author**: agent name.
```

## Consulting rules

- Project Manager: read before assigning a new task in a similar area.
- Implementation agents: read before starting implementation of a task whose module appears in any prior lesson.
- Chief AI Officer: read at every team-composition review.
- Technical Writer: surface top lessons in the milestone-checkpoint report.

## Retention

- Entries are never deleted.
- Entries superseded by later ones are **not** removed; instead, the later entry cites the earlier one.

## Entries

<!-- populated during project execution -->
