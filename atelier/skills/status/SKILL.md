---
name: status
description: Show a dashboard of the current project state — active milestone, in-progress tasks, open PRs with review status, recent risks, and escalation signals. Use whenever the user asks "where are we?", "what's open?", or "what's blocked?". Pass `--json` for machine-readable output (schema at docs/process/status-schema.md).
---

# Project Status

You are the Conductor summarizing current state. Gather facts, do not guess.

## Invocation

- `/atelier:status` — human-readable markdown report (default).
- `/atelier:status --json` — machine-readable output via `bin/atelier-status --json`. Schema documented at `docs/process/status-schema.md`. Use for integration with external dashboards, Slack bots, CI scripts.

## Data Sources (read these in order)

1. `docs/roadmap/roadmap.md` — active milestone.
2. `docs/roadmap/milestones/m<NN>-*.md` — current milestone's tasks.
3. `docs/roadmap/tasks/t<NN>-*.md` — task status (read each for `status:` field).
4. `git branch` — existing `feature/*` branches.
5. `gh pr list --state open --json number,title,author,reviews,isDraft` — open PRs with reviewer status.
6. `docs/roadmap/risks.md` — top risks.
7. `docs/flows/agent-document-map.md` — any recorded escalations in progress.

## Output Shape

Render a concise markdown report with these sections:

### Active Milestone
- Name, target date, completion ratio (completed tasks / total tasks).

### In-Progress Tasks
- Task id, title, assigned agent, branch name.

### Open PRs
- For each open PR: id, title, author agent, reviewer approvals (Senior Software Engineer / Tech Lead / QA Engineer), blocking comments count.

### Waiting on User
- Any checkpoint requiring user approval (from `milestone-checkpoint`).

### Top Risks
- Up to 5, highest severity first.

### Escalations in Flight
- Any Phase 1 agent currently re-activated.

## Rules

- Do not fabricate. If a file is missing, report "unavailable" for that section.
- Do not take actions. This skill is read-only.
- If called before Phase 1 completes, report the current step of `init-project` and which artifacts exist.

## Reference Documents

- `docs/flows/agent-document-map.md`
- `docs/process/change-review-workflow.md`
