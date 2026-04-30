# v1.0 API Surface

This document declares atelier's **public API surface** that becomes SemVer-frozen at v1.0 GA. Any change to a frozen item after v1.0 requires a major version bump per `GOVERNANCE.md`.

> **Status**: pre-freeze (v0.x). This document is the *plan*. Changes are still allowed during 0.x but must update this file.

---

## Frozen surface — what users / integrations depend on

### 1. Skill names (slash commands)

These are typed by users. Renaming any one is a breaking change.

| Skill | Frozen at | Notes |
|---|---|---|
| `/atelier:init-project` | v1.0 | Phase 1 entry point. |
| `/atelier:status` | v1.0 | Plus `--json` output (see schema below). |
| `/atelier:escalate` | v1.0 | `<agent> <reason>` argument shape frozen. |
| `/atelier:milestone-checkpoint` | v1.0 | |
| `/atelier:add-agent` | v1.0 | Approval chain `proposer → Tech Lead → CAIO`. |
| `/atelier:add-skill` | v1.0 | Same chain. |
| `/atelier:add-mcp` | v1.0 | Same chain + mandatory ADR. |
| `/atelier:hotfix` | v1.0 | |
| `/atelier:release` | v1.0 | |

### 2. Agent names (`name:` frontmatter values)

Project authors and the Conductor reference these via `@<name>` and Task subagent invocations. Renaming breaks every prior session record.

| Agent | Frozen `name` |
|---|---|
| Product Manager | `product-manager` |
| Software Architect | `software-architect` |
| Chief AI Officer | `chief-ai-officer` |
| Project Manager | `project-manager` |
| Technical Writer | `technical-writer` |
| Senior Software Engineer | `senior-software-engineer` |
| Tech Lead | `tech-lead` |
| QA Engineer | `qa-engineer` |

### 3. `bin/*` argument shapes

Helpers called from hooks, CI, dashboards, and shell aliases.

| Helper | Frozen invocation |
|---|---|
| `atelier-open-pr <task-id> "<title>" "<body>"` | task-id as first positional arg, title and body as quoted strings |
| `atelier-check-reviews <change-request-id>` | numeric or alphanumeric CR identifier |
| `atelier-cleanup-feature <branch-or-task-id>` | accepts both forms |
| `atelier-notify <channel> <message>` | channel name then message; channel ∈ `{cli, slack, discord}` |
| `atelier-post-merge` | no args; reads merge context from environment |
| `atelier-migrate --from <v> --to <v> [--apply]` and `--auto [--apply]` | dry-run by default |
| `atelier-status [--json]` | output schema in `docs/process/status-schema.md` |
| `atelier-validate` | no args; structural validation |

All helpers must support `--help` returning exit 0 with usage text.

### 4. Hook contracts

Hook handlers receive JSON on stdin (Claude Code's hook format) and signal blocking via exit code.

- **Exit 0**: allow.
- **Exit 1**: warn (printed to stderr; tool call proceeds).
- **Exit 2**: block (tool call refused).

Frozen events: `PreToolUse`, `PostToolUse`, `SessionStart`, `UserPromptSubmit`, `Notification`, `PreCompact`, `Stop`. Adding a new event requires Claude Code support and an additive (non-breaking) change.

### 5. File path schema (project-side)

These paths appear in atelier-generated files, hook commands, and external tooling. Changing the path is a breaking change.

```
<user-project>/
├── CLAUDE.md                                    ← runtime manual (generated at STEP 5)
├── .claude/
│   └── agents/<role>.md                          ← project-specific implementation agents
├── docs/
│   ├── INIT-APPROVAL.md                         ← STEP 5.5 sign-off (6-file gate)
│   ├── requirements/{vision,success-criteria,stakeholders,constraints,requirements}.md
│   ├── design/{architecture,data-model,folder-structure,integrations}.md
│   ├── design/design-system.md                  ← when service-with-UI project type
│   ├── design/ui-flows.md                       ← when service-with-UI project type
│   ├── agents/{team-composition,capability-log}.md
│   ├── roadmap/{roadmap,risks,lessons-learned,dependencies}.md
│   ├── roadmap/milestones/m<NN>-*.md
│   ├── roadmap/tasks/t<NN>-*.md
│   ├── ssot/decisions/adr-*.md
│   ├── ssot/glossary.md
│   ├── ssot/migrations/<timestamp>-<from>-to-<to>.md
│   ├── flows/escalation-log.md
│   ├── flows/escalation-flow.md
│   ├── process/                                  ← references to plugin-shipped policy docs
│   └── templates/operating-preferences-template.md
└── .mcp.json                                     ← project MCP config (when MCPs added)
```

### 6. Frontmatter schema (agent + skill files)

```yaml
---
name: kebab-case-id           # required, matches filename
description: |                # required, ≥30 chars
  When to invoke this agent / skill.
---
```

Validated by `bin/atelier-validate`. Adding optional fields is non-breaking; removing required fields is breaking.

### 7. Status schema

`docs/process/status-schema.md` declares `schema_version: "1"` for `atelier-status --json`. Field changes follow that doc's stability commitment.

---

## NOT frozen (reserved for evolution)

These can change between minor versions without notice — integrations should not depend on them.

- Internal markdown headings inside agent persona / skill body.
- Internal docstring of `bin/*` (only `--help` text is part of stable surface).
- Hook *implementations* (regexes, error wording) — only the contract (exit codes, blocking semantics) is frozen.
- The `docs/templates/*-template.md` content — templates evolve as patterns improve. CAIO uses the latest version.
- Process docs (`docs/process/*.md`) — refined as we learn. Renaming a process doc requires a migration note in `upgrade-guide.md` (e.g., the v0.3 `pr-workflow.md → change-review-workflow.md` rename).
- The `meta/*` directory — maintainer-internal.

---

## Adding to the frozen surface

After v1.0 GA, additions to this surface are:
1. Proposed via RFC per `GOVERNANCE.md`.
2. Listed under "v1.x additions" with the version they shipped in.
3. Once shipped, they are frozen on the same SemVer terms.

## Removing from the frozen surface

After v1.0 GA, removing or renaming any item in §§ 1–6 above requires:
1. Major version bump (v1.0 → v2.0).
2. A migration recipe in `meta/version-history.md` and `bin/atelier-migrate`.
3. A deprecation period of at least one minor version with the old surface still functional + warnings.

---

## Pre-freeze TODO checklist (before v1.0 ships)

- [x] All skill names listed and stable since v0.1 (11 skills at v0.3.1: 9 original + plan-milestone + kanban — additive only, no removals).
- [x] All agent `name:` frontmatter values listed and stable since v0.1 (8 default agents unchanged).
- [x] All `bin/*` helper argument shapes documented (10 helpers at v0.3.1: 7 original + status / sync-tasks / kanban / migrate-real + audit; new helpers additive, existing shapes unchanged).
- [x] Hook event list aligned with Claude Code's documented events.
- [x] File path schema documented.
- [x] Frontmatter schema documented (validated by `atelier-validate`).
- [x] Status JSON schema documented (`status-schema.md`); `lanes` and `epics` keys added in v0.3 (additive, `schema_version: "1"` preserved).
- [x] **Automated drift detection** — `bin/atelier-api-audit` runs all 7 categories; pre-push hook gates it. Zero drift on develop tip as of v1.0 GA.
- [x] **Migration paths verified** — `tests/verify-migration.sh` exercises v0.1 → v0.3 path (`pr-workflow.md → change-review-workflow.md`, `INIT-APPROVAL` version stamp, `agent-specs/` removal); pre-push hook gates it.
- [x] Breaking-changes catalog written (`meta/version-history.md`); 3 entries for v0.1 → v0.3.
- [ ] **All §§ 1–6 reviewed by someone other than original author.** *(Cannot be self-completed; requires external reviewer or ≥1-month distance re-read by same author.)* — see `meta/dogfood-plan.md`.
- [ ] **D1 — atelier-on-atelier dogfood** for ≥ 1 full real milestone. Requires lived experience.
- [ ] **D2 — independent web/SaaS project** ≥ 1 milestone.
- [ ] **D3 — independent data pipeline OR CLI project** ≥ 1 milestone.
- [ ] **User involvement levels (1–4) coverage** — at least one project run at each level, OR explicit accept-risk note here.
