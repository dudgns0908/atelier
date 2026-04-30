# Documentation Tree

This directory holds every canonical project artifact produced by the Phase 1 agents and maintained through Phase 2 by the Technical Writer.

Every fact in this tree lives in **exactly one** canonical location. Other mentions link, never duplicate.

> **For atelier maintainers**: this README is also the schema doc for the user-project tree. The plugin source itself does not populate `requirements/` / `design/` / `agents/` — user projects do, via `/atelier:init-project` and Phase 2.

## Top-level subfolders

| Folder | Owner | Purpose |
|---|---|---|
| `requirements/` | Product Manager | Vision, requirements, stakeholders, success criteria, constraints. |
| `design/` | Software Architect | Tech stack, system architecture, data model, folder structure, integrations. |
| `agents/` | Chief AI Officer | Team composition + capability log. Executable agent files live in `<project>/.claude/agents/`. |
| `flows/` | Conductor + Chief AI Officer | Plugin-shipped flow docs (master quick-ref + agent-communication + milestone-flow). |
| `roadmap/` | Project Manager | Milestones, tasks, dependency graph, risks, checkpoints, lessons-learned. |
| `process/` | Shared (authored at init, maintained by Technical Writer) | Change-review workflow, git-flow, review checklists, DoD, discovery interview, agent-team-sizing, operating preferences, …  |
| `ssot/` | Technical Writer + Software Architect | Glossary (domain terms) and ADRs. |
| `templates/` | (plugin-shipped) | Filled by agents during Phase 1. |
| `INIT-APPROVAL.md` | Conductor | Final approval record ending Phase 1. |

## `requirements/` — schema

Owner: Product Manager. Canonical source of what the project is for, who it serves, and how success is measured.

| File | Contents |
|---|---|
| `vision.md` | One-paragraph statement of why the project exists and the outcome it enables. |
| `requirements.md` | User stories with acceptance criteria. Each story is numbered and referenced by roadmap tasks. |
| `stakeholders.md` | Named stakeholders, their interests, and decision authority. |
| `success-criteria.md` | Measurable outcomes. Each must map to at least one milestone. |
| `constraints.md` | Budget, schedule, regulatory, technical, and organizational constraints. |

Update rules: changes require `/atelier:escalate product-manager <reason>`. Any change here triggers downstream review (Software Architect feasibility, Project Manager roadmap impact, QA Engineer acceptance tests). Domain terms preserved in original language; reference `ssot/glossary.md`.

## `design/` — schema

Owner: Software Architect. Canonical source of how the system is built. Tech Lead enforces conformance at every PR review.

| File | Contents |
|---|---|
| `tech-stack.md` | Language, framework, runtime, infrastructure choices with alternatives considered and rejection reasons. |
| `architecture.md` | System diagram, module boundaries, service topology, request flows. |
| `data-model.md` | Entities, relationships, key invariants, migration strategy. |
| `folder-structure.md` | Top-level directory layout and placement rules. |
| `integrations.md` | External APIs, auth providers, storage, observability, third-party services. |

Plus, when project type is *service-with-UI* (per `agent-team-sizing.md`):

| File | Contents |
|---|---|
| `design-system.md` | Design tokens, type/color/spacing/motion language. Owned by Product Designer. |
| `ui-flows.md` | Information architecture + interaction flows. |
| `accessibility.md` | WCAG conformance plan + audit results. |

Update rules: non-trivial changes require an ADR in `ssot/decisions/`. Changes require `software-architect` re-activation.

## `agents/` — schema

Owner: Chief AI Officer. Human-readable specs and composition rationale for the project-specific agent team. The *executable* agent files live in `<user-project>/.claude/agents/`.

| File | Contents |
|---|---|
| `team-composition.md` | Table of every project-specific agent with the specialization trigger (*orthogonal domain*, *critical expertise*, or *parallel track*) that justified it. Append-only; rejected proposals recorded too. |
| `capability-log.md` | Append-only record of every skill / MCP / agent addition with date, type, name, trigger, justification, ADR. |

Update rules: adding an agent requires `/atelier:add-agent <title> <reason>`. Every new row in `team-composition.md` must cite a trigger; un-cited additions are rejected. Real job titles only (LinkedIn test). See `process/agent-team-sizing.md` for full specialization rules.

## `roadmap/` — schema

Owner: Project Manager. Milestones, tasks, dependencies, risks, checkpoint records.

| File / Folder | Contents |
|---|---|
| `roadmap.md` | Ordered list of milestones with target outcomes and rough sequencing. |
| `milestones/m<NN>-<slug>.md` | Per-milestone charter: goal, scope, success-criteria mapping, scope-lock (들어갈 것 / 안 들어갈 것). |
| `tasks/t<NN>-<slug>.md` | Per-task file: see `process/task-frontmatter.md` for schema. |
| `tasks/h<NN>-<slug>.md` | Hotfix task. Same schema. |
| `risks.md` | Risk register. Per row: description, severity, likelihood, owner, mitigation, trigger. |
| `dependency-graph.md` | Task-level dependencies. mermaid preferred. |
| `checkpoints/m<NN>-retro.md` | Per-milestone retrospective produced by `/atelier:milestone-checkpoint` (sections A–K, user's language per coding-principles carve-out). |
| `lessons-learned.md` | Append-only persistent memory. ≥1 entry per milestone (mandatory). |
| `postmortems/pm-<NN>-<slug>.md` | Optional postmortem for severe incidents (post-hotfix). |

## `ssot/` — schema

Owner: Technical Writer + Software Architect.

| File / Folder | Contents |
|---|---|
| `glossary.md` | Domain terms. Each entry: original-language term, English gloss, definition, first-cited document. Preserve original language for fidelity. |
| `decisions/adr-NNN-<slug>.md` | Sequentially numbered, append-only ADRs. Once `Accepted`, immutable — superseding ADR replaces by reference. Required sections: Status, Context, Decision, Consequences. |
| `migrations/<timestamp>-<from>-to-<to>.md` | Migration logs from `bin/atelier-migrate --apply`. |
| `session-log/<YYYY-MM-DD>.md` | Per-day session log appended by `Stop` hook. |

ADR template (paste at the top of every new `decisions/adr-NNN-*.md`):

```markdown
# ADR NNN: <title>

## Status
Proposed | Accepted | Superseded by adr-MMM

## Date
YYYY-MM-DD

## Context
<the forces at play>

## Decision
<what we decided>

## Consequences
<positive, negative, and neutral impacts>
```

ADR mandatory triggers (any one fires → ADR required in same PR):

1. New external dependency (library, MCP server, SaaS).
2. Change to module boundary or service topology.
3. Cross-cutting concern (auth, logging, observability).
4. Process change touching agent personas / hook contracts.
5. Capability addition via `/atelier:add-*`.

Tech Lead blocks merge of PRs that fire a trigger without an accompanying ADR.

## Invariants

- Cross-document references are relative paths, e.g., `docs/design/architecture.md`.
- Any agent modifying a document here must notify Technical Writer (via commit message or post-merge hook) so downstream references stay consistent.
- `atelier-validate` (when run from a user-project root) checks frontmatter schema for tasks, ADR section structure, capability-log row format.
