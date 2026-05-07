---
name: add-skill
description: "Add a new project-specific skill mid-project. Wraps the capability-extension procedure: reuse audit, skill-creator invocation, capability-log entry, user approval, and reload reminder. Use when an authorized agent identifies a missing helper-skill capability during Phase 1 STEP 2/3 or anywhere in Phase 2."
---

# Add a Project-Specific Skill

You are the Conductor (or a delegated authorized agent) running the end-to-end skill-creation flow. The actual `SKILL.md` drafting is delegated to the bundled `skill-creator` (Apache 2.0, at `skills/skill-creator/`). This wrapper enforces governance around the drafting.

## Authorization

Only these agents may invoke this skill:
- `chief-ai-officer`
- `software-architect`
- project implementation agents (CAIO-authored from `docs/templates/software-engineer-template.md`) — task-helper scope only
- `tech-lead` (escalation-level helpers only)

Reviewers (Senior Software Engineer, QA Engineer), Product Manager, Project Manager, and Technical Writer must escalate to one of the authorized agents.

## Invocation

```
/atelier:add-skill <kebab-skill-name> "<reason>"
```

- `<kebab-skill-name>` — the new skill's directory name (e.g., `slack-thread-summarizer`).
- `<reason>` — one sentence explaining the capability gap.

## Workflow

### 1. Reuse audit (mandatory)

Run the four-step audit per `docs/process/capability-management.md`:

1. **Inventory** — list installed plugins / skills / MCP servers.
2. **Search** — query Anthropic skills marketplace, public marketplaces, MCP registry, language libraries.
3. **Evaluate** — does any candidate cover ≥80% of the need?
4. **Decide** — reuse / extend / create.

Record the audit evidence (candidates considered, why rejected) — this evidence is required for the capability-log entry.

If reuse is possible: stop, use the existing skill, do not create.

### 2. Invoke the bundled `skill-creator`

Delegate to `/atelier:skill-creator` (the Apache-2.0-licensed bundled skill at `skills/skill-creator/`). Provide:
- The skill name and reason.
- The intended location (almost always `<user-project>/.claude/skills/<name>/`).
- Any inputs/outputs specification.

`skill-creator` returns a draft `SKILL.md` following Anthropic's authoritative structure.

### 3. Place the file

Project-specific skills go to `<user-project>/.claude/skills/<kebab-skill-name>/SKILL.md`.

Plugin-level skill contributions (would change `atelier` itself) are out of scope here — they require a separate plugin PR.

### 4. Capability-log entry

Append to `docs/agents/capability-log.md`:

```markdown
| <YYYY-MM-DD> | skill | <kebab-skill-name> | <invoking-agent> | <reuse audit summary> | <one-sentence justification> | — |
```

### 5. User approval (per involvement level)

| Involvement | Behavior |
|---|---|
| Fully Autonomous | Notify via `atelier-notify` (if configured); proceed. |
| Milestone Checkpoints (default) | Wait for explicit user approval. |
| PR-Level / Detailed Supervision | Wait for explicit user approval; show full draft. |

### 6. Reload reminder

Print:
```
Skill created at .claude/skills/<name>/SKILL.md.
Run `/reload-plugins` to activate it before the next task.
```

The plugin's UserPromptSubmit hook will also remind the user if the reload is not run within the next session.

## Anti-patterns

- Creating a skill whose purpose duplicates an existing one (audit must show "not a fit").
- Inventing a skill name that does not match the kebab-case file name.
- Skipping the capability-log entry.
- Bypassing user approval when involvement level requires it.
- Creating plugin-level skills via this flow (those need a plugin PR, not a project addition).

## Reference Documents

- `docs/process/capability-management.md`
- `skills/skill-creator/SKILL.md` (bundled drafting engine)
