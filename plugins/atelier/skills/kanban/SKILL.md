---
description: Render the active milestone's tasks as a kanban board grouped by lane (backlog / todo / in-progress / in-review / done). Forge-aware — GitHub mode shows the Projects v2 URL alongside ASCII fallback; other forges render ASCII only. WIP overflow is flagged but not blocked. Use whenever the user asks "what's where" or wants a quick board view.
---

# Kanban

You are the Conductor rendering the active milestone's task board. Read-only — never mutates state.

---

## When This Runs

- User invokes `/atelier:kanban` to see current board state.
- Often paired with `/atelier:status` (status gives summary; kanban gives lane-organized view).
- After every `/atelier:plan-milestone` to confirm the new tasks are correctly positioned.

---

## Workflow

### 1. Detect forge

Read `H. Forge` from `docs/process/operating-preferences-template.md` (filled). Possible values: `GitHub`, `GitLab`, `Bitbucket`, `Gerrit`, `Local-only`.

### 2. Read tasks

Iterate `docs/roadmap/tasks/t*-*.md` (and `h*-*.md` for hotfix tasks). Group by `lane:` frontmatter:

| Lane | Display column |
|---|---|
| `backlog` | BACKLOG |
| `todo` | TODO |
| `in-progress` | IN PROGRESS |
| `in-review` | IN REVIEW |
| `done` | DONE |

Tasks without `lane:` are placed in BACKLOG with a ⚠️ marker (drift signal — PM should classify at next milestone-checkpoint).

### 3. Render output (always ASCII)

```
BACKLOG          │ TODO            │ IN PROGRESS     │ IN REVIEW       │ DONE
─────────────────┼─────────────────┼─────────────────┼─────────────────┼─────────────────
t12-future       │ t11-welcome     │ t10-survey ⚠️   │ t08-auth-jwt    │ t01-schema
                 │                 │ t09-onboarding  │                 │ t02-routes
                 │                 │ (2/2 WIP)       │                 │ t05-cors

Epics: epic-onboarding (t10, t11) · epic-auth (t08, t09)
WIP limit: in-progress ≤ 2 (configurable). Currently: 2 ✅
```

Each task cell shows the task id and slug (truncated to fit column width). When a task has unresolved `depends_on`, append `🔗N` where N is the count of unresolved deps. When `acceptance` checklist is partially complete in `in-progress` / `in-review`, show `[X/Y]`.

### 4. Forge augmentation (when GitHub)

If forge is GitHub AND `H.1` (Projects v2) was set to `Yes` or `Org-level` at STEP 0.5:

```
GitHub Projects v2 board: https://github.com/users/<owner>/projects/<N>
(or: https://github.com/<org>/<repo>/projects/<N> for repo-level)

For drag-drop kanban view, open the URL above. ASCII below is the snapshot.
```

If GitHub mode but Projects v2 disabled, omit the URL line. ASCII is enough.

If forge is GitLab and Issue Boards enabled (v0.5+ when implemented), same pattern with `glab board` URL.

### 5. WIP & drift signals

After the board, append a short "Signals" block:

```
Signals:
- WIP: in-progress 2/2 ✅ · in-review 0/3 ✅
- Aged in-progress (> 3d without commit): t09-onboarding (5d)
- Stale lane (lane mismatched with status): t10-survey (lane=in-progress, status=assigned) ⚠️
- Blocked: t11-welcome (depends_on t10-survey)
```

`Aged` threshold default = 3 days; configurable via `--age <N>` flag (or `OPS_AGE_DAYS` env).

`Stale lane` flags entries where lane and status disagree (per `docs/process/task-frontmatter.md` lane↔status table). PM should resolve at next milestone-checkpoint.

`Blocked` lists tasks whose `depends_on` references unresolved tasks (any task not in `done` lane).

---

## Output rules

- **Read-only**. Never modify task md files. PM modifies them via `/atelier:plan-milestone` or task assignment workflow.
- **No fabrication**. If `docs/roadmap/tasks/` is empty or absent, report "No tasks. Run `/atelier:plan-milestone <m-id>` to decompose the active milestone."
- **No forge calls when not needed**. Issuing `gh` calls just to render kanban is wasteful when md is local SOT. Only fetch forge state if the user explicitly asks for forge sync via `--with-forge` flag (computes `gh issue list` summary alongside).
- **Truncate long titles**. Column width caps task display at ~20 chars. Long slugs are visible in the md file directly.

---

## Reference Documents

- `docs/process/task-frontmatter.md` — schema for `lane:` and `epic:` fields.
- `docs/process/status-schema.md` — `lanes:` and `epics:` in `--json`.
- `skills/plan-milestone/SKILL.md` — produces tasks; kanban renders them.
- `skills/milestone-checkpoint/SKILL.md` — closes a milestone; kanban shows `done` lane filling up.
- `skills/status/SKILL.md` — sibling, machine-readable surface.
- `bin/atelier-status` — `--json` output is the data source for programmatic kanban rendering by external tools.

---

## Language Policy

Output (column headers, signals) in English (artifact). Task titles preserved as written in the md. Domain terms in original language.
