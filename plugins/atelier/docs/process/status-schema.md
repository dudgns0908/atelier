# `atelier-status --json` schema

Stable, versioned JSON contract for `bin/atelier-status --json`. Use for external dashboards, Slack bots, CI scripts, anything that needs to know the project's state without parsing markdown.

The schema is **versioned** — `schema_version` appears in every payload. Breaking changes increment the major version per atelier's overall SemVer commitment (frozen at v1.0). Additive (non-breaking) changes do not bump the version.

## Current version: `"1"`

## Top-level shape

```json
{
  "schema_version": "1",
  "phase": "phase2",
  "active_milestone": {
    "id": "m02-onboarding",
    "target": "2026-05-30"
  },
  "tasks": {
    "total": 14,
    "done": 9,
    "in_progress": ["t10-onboarding-survey"],
    "assigned": ["t11-welcome-email"]
  },
  "lanes": {
    "backlog": ["t12-future-feature"],
    "todo": ["t11-welcome-email"],
    "in_progress": ["t10-onboarding-survey"],
    "in_review": [],
    "done": ["t01-schema", "t02-routes"]
  },
  "epics": {
    "epic-onboarding": ["t10-onboarding-survey", "t11-welcome-email"]
  },
  "open_change_requests": [
    {
      "number": 23,
      "title": "[t10] feat: survey step",
      "author": {"login": "frontend-engineer"},
      "isDraft": false
    }
  ],
  "escalation_active": null,
  "risks_count": 3,
  "capability_log_rows": 7
}
```

## Field reference

| Field | Type | Meaning |
|---|---|---|
| `schema_version` | string | Version of this schema. Currently `"1"`. |
| `phase` | enum | `"not_initialized"`, `"phase1_in_progress"`, `"phase2"`. Derived from the 6-file gate: all six STEP outputs present + non-empty + INIT-APPROVAL has `Approved by user:` line. |
| `active_milestone.id` | string | Active milestone basename without `.md`, e.g. `"m02-onboarding"`. Empty string when none. |
| `active_milestone.target` | string | Target date or version from milestone file's `target:` field. Empty string when missing. |
| `tasks.total` | integer | Count of `docs/roadmap/tasks/t*-*.md` files. |
| `tasks.done` | integer | Tasks with `status:` ∈ `{done, completed, merged}`. |
| `tasks.in_progress` | string[] | Task basenames with `status:` ∈ `{in-progress, active}`. |
| `tasks.assigned` | string[] | Task basenames with `status:` ∈ `{assigned, claimed}`. |
| `lanes.<lane>` | string[] | Task basenames whose `lane:` frontmatter field equals the key. Lanes: `backlog`, `todo`, `in_progress`, `in_review`, `done`. (Note: JSON keys use snake_case; task `lane:` values use kebab-case `in-progress` / `in-review`.) |
| `epics` | object | Map from epic slug to array of task basenames. Tasks without `epic:` are not represented here. |
| `open_change_requests` | array | Verbatim `gh pr list --json` (or `glab mr list --output json`) result. Empty array when no forge auth or no PRs. |
| `escalation_active` | string \| null | Last open escalation header from `docs/flows/escalation-log.md`, or `null`. |
| `risks_count` | integer | Bullet rows in `docs/roadmap/risks.md`. |
| `capability_log_rows` | integer | Date-prefixed rows in `docs/agents/capability-log.md`. |

## Status enum

The `status:` frontmatter field on task files (`docs/roadmap/tasks/t*-*.md`) accepts:

- `assigned` / `claimed` — picked but not yet started.
- `in-progress` / `active` — work underway, branch may exist.
- `done` / `completed` / `merged` — task closed.
- `blocked` — surfaces in escalation log, not in task counters.

## Stability commitment

- `schema_version` field is **always** present.
- Adding new fields is backwards-compatible (clients ignore unknown fields).
- Removing or renaming fields is a **breaking change** and requires `schema_version` bump.
- Version bumps follow atelier's overall SemVer once v1.0 ships.

## Consumer examples

### Slack bot — post unfinished tasks daily

```bash
atelier-status --json | jq -r '.tasks.in_progress[]' | \
  while read t; do echo "Still in progress: $t"; done
```

### CI gate — block merge if escalation is active

```bash
escalation=$(atelier-status --json | jq -r '.escalation_active')
[ "$escalation" != "null" ] && { echo "Blocked: open escalation $escalation"; exit 1; }
```

### Dashboard — milestone burn rate

```bash
total=$(atelier-status --json | jq '.tasks.total')
done=$(atelier-status --json | jq '.tasks.done')
echo "scale=2; $done / $total * 100" | bc
```

## Validation

The schema is enforced at CI time via `bin/atelier-validate` (v0.3+ extends validation to run `atelier-status --json` from a synthetic project and verify the output parses + has required keys).
