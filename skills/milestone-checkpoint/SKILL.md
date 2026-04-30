---
description: Run a milestone completion checkpoint — summarize what was delivered against the milestone's success criteria, surface risks and debt, and either obtain user approval to proceed to the next milestone or route back for remediation. Required when user involvement level is "Milestone Checkpoints" or stricter.
---

# Milestone Checkpoint

You are the Conductor conducting a milestone completion review. The goal is an explicit user decision: proceed, remediate, or pivot.

## When This Runs

- Automatically triggered by Project Manager when all tasks in the active milestone reach `status: merged`.
- Or on-demand by the user.

## Workflow

### 1. Gather Milestone Facts
Read:
- `docs/roadmap/milestones/m<NN>-*.md` — original milestone definition.
- `docs/roadmap/tasks/t<NN>-*.md` for every task under this milestone — final outcomes.
- `docs/requirements/success-criteria.md` — criteria this milestone was meant to advance.
- Merged PRs linked to these tasks.
- `docs/roadmap/risks.md` — which risks materialized.

### 2. Prepare the Retrospective File

Write `docs/roadmap/checkpoints/m<NN>-retro.md` (one file per milestone, **append-only after milestone closes**). The file IS the milestone's retrospective record — preserved in git, referenced by future agents working in the same area.

Required sections, in this order:

#### A. Header
- **Milestone**: `m<NN>` `<title>`
- **Window**: `<start-date>` → `<end-date>`
- **Goal** (original statement, copied verbatim from `docs/roadmap/milestones/m<NN>-*.md`)

#### B. What worked — Keep doing
Concrete things that should be repeated next milestone. Cite specific tasks/PRs as evidence. Examples:
- "Pre-PR design discussions in chat (t04, t07) — caught 2 bugs before review."
- "Strict one-question-per-turn in interview saved time vs Thorough mode."

#### C. What's lacking / didn't work — Fix or correct
Specific gaps, surprises, or failures. Cite evidence; avoid generalities.
- "Task t12 underestimated; took 4 days vs 1-day plan. Sizing rule '1 PR = ½–2 days' was violated."
- "Tech debt around `auth/middleware.go` flagged in 3 separate PRs but never scheduled — debt accrual."

#### D. What to try — New experiments next milestone
1–3 concrete experiments. Falsifiable so the next retro can judge if they worked.
- "Try: split tasks > 300 LOC at plan time."
- "Try: Tech Lead opens a remediation task for any 2nd-mention tech debt."

#### E. Decision
> **Approve `m<NN>` and proceed to `m<NN+1>` / Remediate listed items first / Pivot scope?**

User's explicit answer goes here. Implicit approval forbidden.

If **Remediate**: list the specific items as bulleted task IDs (or "create new task tNN-remediate-*"). `m<NN+1>` cannot start until those merge.
If **Pivot**: route to `/atelier:escalate <agent>` and pause `m<NN+1>`.

#### F. Tasks delivered (table)
| Task | Outcome | PR | Notes |
|---|---|---|---|
| `t01-...` | merged | #12 | (1-line) |

#### G. Success criteria status
For each criterion in `docs/requirements/success-criteria.md` related to this milestone: ✅ met / ⏳ partial / ❌ unmet, with 1-line evidence.

#### H. Risks
- **Materialized**: which risk-register entries fired, with handling.
- **Newly discovered**: added to `docs/roadmap/risks.md` (with row reference).

#### I. Tech debt incurred
Explicit list, sourced from Tech Lead's PR review comments and ADR-deferred decisions. Each item: where, why deferred, when to remediate.

#### J. Next milestone preview
`m<NN+1>` goal + first 1–2 tasks PM has scoped. Confirms DoR (Definition of Ready: clear AC, no blocking dep, sized to PR).

#### K. User reflection (optional — 1 line, user-written)
Space for the human owner to write one sentence of their own — what *they* felt about this milestone. Not parsed by atelier; preserved as-is.

### 3. Agents' Input — all 8 default agents (Phase 1 standby agents reactivate here)

Milestone-checkpoint is one of the **explicit reactivation triggers** for Phase 1 STANDBY agents. Every default agent contributes a 2-sentence assessment in the same chat. Conductor invites them sequentially (or in parallel via Task subagent).

**Phase 1 (5)** — re-engaged from STANDBY for this checkpoint, then return to STANDBY:

- **Product Manager** — did this milestone advance the user's success criteria? Any acceptance-criterion drift visible across the merged PRs?
- **Software Architect** — is the system still coherent? Any compounding debt that crosses module boundaries? ADR-worthy decisions made implicitly during the milestone?
- **Chief AI Officer** — did the agent team's composition serve this milestone? Over/under-staffing observed? Any capability gap (skill/MCP) that surfaced repeatedly?
- **Project Manager** — is the schedule still realistic for remaining milestones? Velocity vs estimate accuracy? Any task that should have been split earlier?
- **Technical Writer** — is documentation in lockstep with code? Any glossary additions? Doc drift caught at post-merge sync vs missed?

**Phase 2 reviewers (3)** — already active per PR; here they synthesize cross-PR patterns:

- **Senior Software Engineer** — code-quality patterns repeated across the milestone (e.g., "test coverage thinned in `services/billing/*` — 3 PRs missed assertions").
- **Tech Lead** — architectural drift signals or boundary erosions noticed across the milestone's PRs.
- **QA Engineer** — quality patterns across PRs, regression risk areas, scope-drift incidents (escalations to Product Manager).

Project-specific implementation agents are **not** asked individually — their observations are already captured in PR comments and merged code. PM may surface notable patterns from them in their assessment if any.

The 8 assessments together populate sections B (Keep), C (Lacking), D (Try), and contribute evidence to E (Decision).

### 4. Present to User

Show the checkpoint report with the agent assessments. Ask:

> "Approve milestone `m<NN>` and proceed to `m<NN+1>`, remediate specific items, or pivot scope?"

### 5. Decision Handling

- **Approve** → append `Approved: <date>` to the checkpoint file. Project Manager starts the next milestone's first task.
- **Remediate** → list the specific items. Project Manager creates remediation tasks and schedules them before `m<NN+1>` begins.
- **Pivot** → escalate to `product-manager` or `software-architect` depending on pivot type.

### 6. Required Lessons-Learned Entry

Before closing the checkpoint, Technical Writer MUST append at least one entry to `docs/roadmap/lessons-learned.md` for this milestone. Even a "nothing notable" milestone produces an entry stating that. The entry captures:
- What worked well (continue doing).
- What failed or surprised (correct next time).
- Any accumulated tech debt noted during reviews.
- Risks that materialized and how they were handled.

Agents must consult this file before starting future tasks in the same area.

## Rules

- Do not skip the checkpoint even if "everything passed". The ritual matters.
- Do not mark approval implicitly. Require the user's explicit word.
- If the user is unavailable and involvement level allows, record the delay and hold `m<NN+1>` start.

## Language Policy — retrospective file is in user's language

The retro file `docs/roadmap/checkpoints/m<NN>-retro.md` is **written in the user's language** (auto-detected from STEP 0.5 dialogue language; preserved across sessions). This is an explicit carve-out from atelier's general "artifacts in English" rule because:

1. The primary reader is the human owner — the retro is a human ritual (decisions, sentiment, learning), not a machine-consumed contract.
2. Lessons-learned and "Try" experiments are most actionable in the language the team thinks in.
3. Section K (user reflection) was already designed for user prose.

What stays English: section identifiers (Header / Keep / Lacking / Try / Decision / Tasks delivered / Success criteria / Risks / Tech debt / Next milestone preview) — for cross-project regex/linting consistency. Bullet content beneath each section is user's language.

Domain terms still follow the global rule: **original language preserved** (e.g., `전자금융거래법`, `信託`); add to `docs/ssot/glossary.md` if new.

When future agents read a past retro, they may translate as needed — same as they handle bilingual code comments. Atelier's "Living Documentation" requires the retro to be **truthful and current**, not English-only.

`docs/roadmap/lessons-learned.md` aggregate file follows the same rule: user's language for content, English for structural keys.

## Reference Documents

- `docs/templates/operating-preferences-template.md`
- `docs/process/definition-of-done.md`
- `docs/flows/agent-document-map.md`
- `docs/process/coding-principles.md` § Language Policy (retrospective is the explicit user-language carve-out)
