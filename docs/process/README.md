# Process Docs

**Owner**: Shared. Authored during Phase 1; maintained by Technical Writer during Phase 2.

Operational rules every agent follows. Agents reference these documents rather than inlining the rules.

## Files (15)

| File | Contents |
|---|---|
| `coding-principles.md` | Universal behavioral contract — naming, language, simplicity, critical thinking, interview discipline. Every agent and the Conductor honor this. |
| `living-documentation.md` | Docs are load-bearing infrastructure: same-PR doc updates, SSOT rule, what "up-to-date" means concretely. |
| `change-review-workflow.md` | Change-review lifecycle (GitHub PR / GitLab MR / Bitbucket pull request / Gerrit change) — includes conflict-resolution. |
| `git-flow.md` | Branching model, naming conventions, commit standards, hotfix lifecycle. |
| `review-checklists.md` | Three reviewer checklists (Code Quality / Architecture / Requirements) + Posting Protocol for deduplication. |
| `definition-of-done.md` | Task-level DoD every change request must satisfy before merge. |
| `discovery-interview-guide.md` | Structured 6-round question bank for STEP 1 (one question per turn). |
| `agent-team-sizing.md` | Rules for Chief AI Officer when specializing the team — incl. STEP 0 project type recognition + service-with-UI default trio. |
| `user-involvement-levels.md` | Four involvement presets (Fully Autonomous → Detailed Supervision). |
| `capability-management.md` | Reuse-first policy + add-agent / add-skill / add-mcp procedures + approval chain (proposer → Tech Lead → CAIO). |
| `code-quality-automation.md` | Pre-commit + CI configuration per stack and forge. *Audience: user projects.* |
| `release-process.md` | `develop → main` release cycle, versioning, release notes. *Audience: user projects.* |
| `issue-management.md` | Issue lifecycle, multi-agent triage protocol, label scheme, assign-and-execute path. |
| `status-schema.md` | `atelier-status --json` schema reference + consumer examples. |
| `task-frontmatter.md` | Authoritative spec for `docs/roadmap/tasks/t<NN>-*.md` frontmatter (lane, epic, depends_on, acceptance, …). |

## Companion locations

- **`docs/templates/`** — fillable templates: `operating-preferences-template.md`, `software-engineer-template.md`, `designer-template.md`, `project-claude-template.md`.
- **`docs/flows/`** — flow diagrams + agent-communication protocol + master quick-ref + milestone flow.
- **`docs/ssot/glossary.md`** — domain-term template (filled per project).
- **`docs/roadmap/lessons-learned.md`** — append-only memory template (filled per project).
- **`meta/`** — maintainer-only docs: `ROADMAP.md`, `GOVERNANCE.md`, `version-history.md`, `v1-api-surface.md`, `dogfood-plan.md`. Not loaded into user sessions.

## Update Rules

- Plugin-shipped policy files (everything in this folder) live in atelier's plugin directory and propagate via plugin updates.
- Project-specific overrides belong in the project's filled `operating-preferences-template.md` or as ADRs in `docs/ssot/decisions/`, not in these policy files.
- Living Documentation principle applies: when behavior changes here, update agent personas and skill bodies that reference the changed rule, in the same PR.
