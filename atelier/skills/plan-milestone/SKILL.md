---
name: plan-milestone
description: "Decompose an active milestone into PR-sized tasks via multi-agent discussion (PM proposes, Tech Lead challenges, CAIO conditional). Use at the start of every milestone in Phase 2 — it's the bridge between the high-level roadmap and per-PR execution. Produces task files with lane/epic/depends_on/acceptance frontmatter and (in GitHub mode) mirrored Issues."
---

# Plan Milestone

You are the Conductor orchestrating the **decomposition of an active milestone into PR-sized tasks**. This is the bridge between Phase 1's high-level roadmap and Phase 2's per-PR execution loop. Without this step, milestones stay too coarse to assign and tasks get created ad-hoc mid-milestone.

This skill is **multi-agent** — mirrors the cross-agent challenge pattern used at Phase 1 STEP 2/3/4 and at issue-triage. PM is proposer, not solo authority.

---

## When This Runs

- **Default trigger**: at the start of every milestone in Phase 2. Either auto-fired by Project Manager when the previous milestone closes via `/atelier:milestone-checkpoint`, or invoked on-demand by the user.
- **On-demand**: user invokes `/atelier:plan-milestone <m-id>` to (re)decompose a milestone — useful when scope shifts mid-milestone or when a milestone's existing tasks turn out to be wrongly sized.
- **Not for hotfixes**: emergency fixes use `/atelier:hotfix` which creates its own task without going through plan-milestone.

---

## Inputs

- `docs/roadmap/milestones/m<NN>-*.md` — the milestone charter (goal, scope, success-criteria mapping). Must exist before plan-milestone runs; if missing, escalate to Project Manager to draft it first.
- `docs/requirements/*` — to verify acceptance criteria coverage.
- `docs/design/*` — to verify architectural fit.
- `docs/agents/team-composition.md` — to map task domains to implementation agents.
- `docs/agents/capability-log.md` — to detect capability gaps requiring CAIO.
- `docs/roadmap/lessons-learned.md` — to honor prior milestones' "Try" experiments and avoid repeated mistakes.
- Forge state (GitHub mode): existing untriaged Issues with `kind:request` / `kind:bug` / `status:accepted` (per `docs/process/issue-management.md`).

---

## Workflow — Multi-Agent Decomposition

### 1. PM (proposer) drafts the task breakdown

Project Manager produces an initial task list. Each task:

- **Sized to one PR** — half-day to two-day, ~100–500 LOC; PM compresses anything bigger into multiple tasks or promotes to a sub-milestone. See `docs/process/agent-team-sizing.md` for the sizing rule.
- **Grouped under epics when warranted** — `epic: <slug>` field on the task md frontmatter; an epic is "a coherent thread of 3–6 tasks that ship together as a feature". Standalone tasks have no epic.
- **Acceptance criteria as checkboxes** — `acceptance:` list with `[ ]` items. Each AC is independently verifiable.
- **Dependencies explicit** — `depends_on:` list of task IDs that must complete before this task starts.
- **Initial lane** — `lane: backlog` (or `lane: todo` for the next 1–2 to be picked up).

PM also pulls accepted issues from the forge (`status:accepted` Issues that were triaged into this milestone per `docs/process/issue-management.md`) and either folds them into existing tasks or promotes them to new tasks.

PM posts the proposed breakdown **in chat as a single message** (not by writing files yet). Format:

```markdown
## Proposed task decomposition for m<NN>

| Task | Title | Epic | Size | Depends-on | Acceptance count |
|---|---|---|---|---|---|
| t01 | ... | epic-auth | M | — | 3 |
| t02 | ... | epic-auth | S | t01 | 2 |
| ...

### Full task content (per task)

\`\`\`yaml
# t01-<slug>.md
---
id: t01
title: ...
status: assigned
lane: backlog
epic: epic-auth
size: M
depends_on: []
acceptance:
  - [ ] ...
---
\`\`\`

(repeat per task)
```

### 2. Tech Lead — mandatory challenger

Tech Lead reviews the proposal in the same chat. Required questions answered with concrete reservations:

- **Architectural fit**: do these tasks respect `docs/design/architecture.md`? Any task assumes a service / module that doesn't exist?
- **Module boundary**: does each task fall within one implementation agent's declared boundary per `docs/agents/team-composition.md`? Cross-boundary tasks must be split.
- **Sizing audit**: any task that smells like > 2-day work? List specifically.
- **Current code state**: any task assumes code that doesn't exist yet but isn't gated by `depends_on`?
- **ADR triggers**: does any task fire an ADR-mandatory trigger per `docs/README.md#ssot-schema`? If yes, an ADR task must precede.

Tech Lead's verdict format:

```markdown
[Architecture] Verdict: <APPROVE | REQUEST_CHANGES>

Concerns:
- (concrete reservation 1)
- (concrete reservation 2)
```

If APPROVE with no reservations, say so explicitly — `LGTM` alone is rejected per `docs/process/coding-principles.md`.

### 3. Chief AI Officer — conditional challenger

CAIO is engaged **only if** PM or Tech Lead surfaces a capability or team-composition concern, e.g.:

- "These tasks recurring in security-sensitive code suggest we need a Security Engineer."
- "Three tasks reference a Slack notification — we don't have a Slack MCP yet."
- "Frontend tasks but project type was classified API; reconsider service-with-UI?"

When engaged, CAIO uses `/atelier:add-agent` / `add-skill` / `add-mcp` chain in parallel — these run separately with their own approval chain (`proposer → Tech Lead → CAIO → user`). plan-milestone does not block on them; it captures the dependency in the task md (`depends_on: [capability:add-agent-X]` or similar) and continues.

If no capability gap surfaces, CAIO stays silent. This is normal.

### 4. PM revises based on challenges

PM incorporates the challenges in chat. Revised proposal posted (only the affected rows + diff explanation, not the full table re-pasted). Iterate until Tech Lead's reservations are addressed or explicitly deferred to a future milestone.

### 5. User intervention window

Per the project's involvement level (`operating-preferences-template.md` § A):

- **Detailed Supervision (level 4)**: every plan-milestone presents the revised proposal to the user; user must approve or revise before files are written.
- **PR-Level Checkpoints (level 3)**: user is shown the proposal but only intervenes if they object; silent reply = approve.
- **Milestone Checkpoints (level 2)**: user only sees the proposal if scope shifted from the milestone charter (e.g., a new epic was added that wasn't in the charter); otherwise PM proceeds.
- **Fully Autonomous (level 1)**: no user prompt; PM logs the proposal for the next milestone-checkpoint to review.

### 6. Files written

PM writes to disk only after the discussion settles:

- `docs/roadmap/tasks/t<NN>-<slug>.md` per task — frontmatter + body. Body includes:
  - **Description** (1–3 sentences).
  - **Linked requirement** (which `docs/requirements/*` section).
  - **Linked design** (which `docs/design/*` section).
  - **Acceptance criteria** (already in frontmatter as checkbox list, repeated in body for human readability).
  - **Implementation notes** (any non-obvious constraints).
  - **Linked issue** (GitHub mode: `linked_issue: <N>` if mirrored).

### 7. Forge mirroring (GitHub mode only)

If `H. Forge = GitHub` per operating preferences AND `H.1 = Yes/Org-level` (Projects v2):

- Invoke `bin/atelier-sync-tasks --apply` to create one Issue per task md. Issue body templated: synopsis, ACs as `- [ ]` lines, `Depends on #<N>` references, `Tracking: docs/roadmap/tasks/t<NN>-<slug>.md`. Labels: `kind:task`, `lane:backlog`, `epic:<slug>` (if any).
- Project v2 board auto-picks up via repo-level project's auto-add filter.

If GitHub mode but Issue mirror disabled, skip; tasks live only in md.

### 8. Update lessons-learned

Append a short note to `docs/roadmap/lessons-learned.md`:

```markdown
### <date> — m<NN> planned

- N tasks across K epics; sizing distribution: <S:x M:y L:z>.
- Tech Lead concerns surfaced and resolved: <count>.
- CAIO engaged: <yes/no, brief reason if yes>.
- Capability gaps triggering parallel /atelier:add-* chain: <list or none>.
```

This is process telemetry — not the milestone retro (which runs at close).

---

## Output Summary

After plan-milestone completes:

1. `docs/roadmap/tasks/t<NN>-<slug>.md` — N task files (lane=backlog/todo).
2. (GitHub mode) Forge Issues mirrored 1:1 with task IDs.
3. Chat record of the multi-agent discussion (proposer/challenger/revision).
4. `docs/roadmap/lessons-learned.md` — short planning-event note.

The milestone is now **ready for execution** — PM picks the first task (lane → in-progress), Conductor invokes the assigned implementation agent, and the per-PR cycle begins per `docs/flows/agent-document-map.md`.

---

## Rules

- **PM is proposer, not solo author.** Skip Tech Lead → invalid plan-milestone; the audit trail must show challenge applied.
- **Solo-maintainer carve-out**: when only one human maintainer exists (per `CONTRIBUTING.md` L2/L3 small-team carve-out), the multi-agent discussion is voiced by the maintainer with explicit `[PM]` / `[Tech Lead]` / `[CAIO]` blocks. Same audit trail, single author.
- **Scope-lock is mandatory**: the milestone charter (`docs/roadmap/milestones/m<NN>-*.md`) is the contract. plan-milestone cannot add tasks outside the charter's stated scope without escalating to `/atelier:escalate product-manager` for charter amendment first. (m01 lesson: scope creep happens when this gate is absent.)
- **Tasks always size to one PR.** If PM/Tech Lead can't get there, the work is not yet ready for plan-milestone — escalate to Software Architect for design clarification.
- **Don't run plan-milestone for an inactive milestone.** A milestone is "active" once the previous milestone is closed (retro approved) and the user has signaled intent to begin. plan-milestone before that is premature.
- **Don't decompose more than the next milestone**. Future milestones stay at charter level until they become active. This avoids stale task files that drift before they're picked up.

---

## Reference Documents

- `docs/flows/milestone-flow.md` — the full milestone loop (plan → execute → retro → next).
- `skills/milestone-checkpoint/SKILL.md` — the sibling skill that closes a milestone.
- `docs/process/agent-team-sizing.md` — sizing rule (one PR = ½–2 days, 100–500 LOC).
- `docs/process/issue-management.md` — how triaged issues feed into plan-milestone.
- `docs/process/capability-management.md` — when CAIO's parallel `/atelier:add-*` chain fires.
- `docs/process/coding-principles.md` — `LGTM` rejection, mutual challenge obligation.
- `docs/templates/operating-preferences-template.md` — involvement level affects user-intervention window.
- `agents/project-manager.md` — PM's proposer role (responsibility #2).
- `agents/tech-lead.md` — Tech Lead's mandatory challenger role.
- `agents/chief-ai-officer.md` — CAIO's conditional challenger role.

---

## Language Policy

The chat discussion (proposer / challenger / revision) follows the user-facing dialogue language (auto-detected from STEP 0.5). Task md files (frontmatter + body) are in **English** per the artifact rule in `docs/process/coding-principles.md` § Language Policy. Domain terms preserved in original language.
