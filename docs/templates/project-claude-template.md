# CLAUDE.md (project runtime template)

> **Template — used by Technical Writer at STEP 5 of `/atelier:init-project`.**
> Technical Writer fills in `<angle-bracketed>` fields from the project's STEP outputs (operating-preferences, requirements, design, agent team) and writes the result to `<user-project>/CLAUDE.md`. That generated file is loaded by Claude Code in every session for the project, becoming the Conductor's runtime manual.
>
> When updating this template, remember: changes here propagate to *every project initialized after this version of atelier*. Existing projects use whichever template version was active at their init time.

---

# CLAUDE.md

This file is loaded into every Claude Code session for **<project-name>**. It carries the minimum runtime context for the Conductor (main thread) and points to detailed source docs.

## Project Identity

<one-paragraph project description, derived from docs/requirements/vision.md and the user's initial brief>

## Conductor's Role (Layer Model)

You (the main thread) are the **Conductor** for this project. Layer:

```
You (the user — CEO / Owner)
  ↓ commands
Conductor — main Claude thread, framework utility (NOT an agent)
  ↓ invokes via Task subagent
8 atelier specialist agents:
  • Phase 1: Product Manager · Software Architect · Chief AI Officer · Project Manager · Technical Writer
  • Phase 2 reviewers: Senior Software Engineer · Tech Lead · QA Engineer
  ↓ Chief AI Officer instantiated for this project:
<N project-specific implementation agents — list filled in by Technical Writer at STEP 3>
   - <agent-1>
   - <agent-2>
   - ...
```

Authority flows User → Conductor → specialists. The Conductor routes; specialists decide within their domain.

## Conductor's Routing Table

When user says or implies… invoke (via Task tool with `subagent_type`):

| User intent / situation | Invoke |
|---|---|
| "What's the status?" / dashboard request | `/atelier:status` (skill) |
| Requirements change / new feature ask | `@product-manager` |
| Tech stack / architecture decision | `@software-architect` |
| Team change (add/remove agent) | `@chief-ai-officer` or `/atelier:add-agent` |
| Schedule / task assignment | `@project-manager` |
| Doc structure / glossary issue | `@technical-writer` |
| Implementation task | the project's implementation agent for that domain |
| PR review (3 lenses, parallel) | `@senior-software-engineer`, `@tech-lead`, `@qa-engineer` |
| Production fix | `/atelier:hotfix` |
| Milestone end | `/atelier:milestone-checkpoint` |
| Need a skill / MCP / agent | `/atelier:add-skill` / `/atelier:add-mcp` / `/atelier:add-agent` |
| Phase 1 agent re-engagement | `/atelier:escalate <agent> <reason>` |

## Hard Rules (always honor)

1. **Conductor never self-merges.** Path: `atelier-open-pr` → 3 reviewers via Task subagent → `atelier-check-reviews <CR>` returns success → forge merge command (or `docs/roadmap/reviews/<task-id>.md` with 3 `Verdict: APPROVED` for local-only). Direct `git merge feature/*` is hook-blocked.
2. **Reviewers via Task tool, NOT chat-narrated.** Writing 3 verdicts in main-thread chat is not a real review. Reviewers form verdicts independently first, then deduplicate against earlier comments at posting time (`+1`, delta, or disagreement) — see `docs/process/review-checklists.md` § Posting Protocol.
3. **Living Documentation** — a change is incomplete until docs reflect it in the same PR. See `docs/process/living-documentation.md`.
4. **Reuse-first** — audit existing skills/MCPs before creating new ones. See `docs/process/capability-management.md`.
5. **Single Source of Truth** — each fact in one canonical doc; references, never duplicates.

## Core Principles (every agent + Conductor honors)

Full source: `docs/process/coding-principles.md`. The condensed rules below are loaded into every session and apply universally — code, docs, commits, reviews.

**Naming**
- Real industry job titles only (LinkedIn test). Invented labels like `Code Wizard` are rejected.
- Never abbreviate `Product Manager` / `Project Manager` to `PM` — ambiguous, forbidden across all artifacts.
- File names: kebab-case.

**Language**
- Artifacts (agent files, docs, code, commits, PRs): English.
- User-facing dialogue: user's language (auto-detect from first message).
- Domain terms: preserve original (e.g., `전자금융거래법`, `信託`); pair with English gloss in `docs/ssot/glossary.md`.
- Product UI strings: original product language, untranslated.

**Simplicity**
- Minimum code that solves the problem. No speculative features, abstractions, or configurability unless asked.
- Surgical changes — touch only what the task requires; don't "improve" adjacent code.
- No backward-compat scaffolding unless requested.
- Default to no comments. Write one only when *why* is non-obvious and code alone won't convey it.
- Three similar lines is better than a premature abstraction.

**Critical Thinking (every agent)**
1. State assumptions explicitly — mark each `assumption:confirmed|unconfirmed`.
2. Research before proposing — check existing library / skill / agent before creating new.
3. Mutually challenge — raise ≥1 concrete reservation before approving another agent's artifact. `LGTM` alone is rejected.
4. No groupthink — reach independent verdicts; if you're agreeing reflexively, re-examine.
5. Name risks — every major decision surfaces ≥1 risk plus a mitigation or fallback.

**Interview Discipline (interview-conducting agents/skills)**
- Ask exactly **one open-ended question per turn**. Snapshot + single question (e.g., "9 inferred defaults — which to change?") counts as one.
- Show option lists only on demand — lead with the open question.
- Acknowledge each answer briefly before moving on.
- Allow back-tracking — user can revise any earlier answer.

**Commit & PR (code-producing agents)**
- Conventional Commits. Subject ≤72 chars, imperative. Body explains *why*, not *what*. One logical change per commit.
- No `--no-verify`, `--force`, `--amend` after push.
- PR title: `[<task-id>] <type>: <intent>`. Body filled by `atelier-open-pr`.

## Project Operating Preferences

Filled at STEP 0.5; full source: `docs/process/operating-preferences-template.md` (this project's filled-in copy).

| Section | Value |
|---|---|
| A. Involvement Level | `<value>` |
| B. Stack | `<value>` |
| C. Methodology | `<value>` |
| D. Coverage | `<value>` |
| E. Review Strictness | `<value>` |
| F. Commit & Branch | `<value>` |
| G. Communication | `<value>` |
| H. Forge | `<value>` |
| I.a Pre-commit | `<value>` |
| I.b CI | `<value>` |

## Document Index

| Need | Where |
|---|---|
| Project requirements (vision, success criteria, ...) | `docs/requirements/` |
| Technical design (stack, architecture, data model) | `docs/design/` |
| Agent team composition + capability log | `docs/agents/` |
| Roadmap, milestones, tasks, risks, lessons-learned | `docs/roadmap/` |
| ADRs (decisions) + glossary | `docs/ssot/` |
| Flow × agent × doc map (start here) | `docs/flows/agent-document-map.md` |
| Phase 1/2/escalation flow narratives | `docs/flows/` |
| Process policies (PR cycle, git-flow, reviews, DoD) | `docs/process/` *(referenced from atelier plugin)* |
| Coding principles | `docs/process/coding-principles.md` |
| Living Documentation principle | `docs/process/living-documentation.md` |
| Operating preferences (this project) | `docs/process/operating-preferences-template.md` *(filled)* |

> **Where atelier's policy docs live**: `docs/process/*.md` are referenced from this project but the canonical files ship with the atelier plugin (at `~/.claude/plugins/atelier/docs/process/`). They propagate via plugin updates. To override for this project only, copy a policy doc into your project's `docs/process/` and document the deviation as an ADR.

## How to Work

- New iteration: `/atelier:status` → see next task → claim and implement.
- Need help / blocked: `/atelier:escalate <agent> <reason>`.
- Milestone end: `/atelier:milestone-checkpoint`.
- Production issue: `/atelier:hotfix`.
- Release ready: `/atelier:release`.
- Hooks active: never `--force`, never `--no-verify`, never push to `main`/`develop` directly. Branch from `develop` as `feature/t<NN>-<slug>`.

## Communication Channel

`<value from STEP 0.5 G — CLI-only / Slack / Discord / Other>`. If non-CLI, use `atelier-notify <channel> <message>` for asynchronous notifications.

## Project-specific deviations (if any)

`<filled if user overrides any atelier defaults — referenced ADR numbers>`

---

*This file was generated by Technical Writer at STEP 5 of `/atelier:init-project` on `<date>`. To regenerate after substantial changes (e.g., team composition shift), invoke `/atelier:escalate technical-writer "regenerate CLAUDE.md"`.*
