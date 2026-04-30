# Coding Principles

Behavioral guidelines for every agent that produces code, documents, or artifacts. Consolidates naming, language, simplicity, critical thinking, and interview discipline.

## Naming Discipline

- **All agent titles are real industry job titles.** LinkedIn test: if a human couldn't hold this title, don't use it. Invented labels (`Code Wizard`, `Master Builder`, `Synthesizer`) are rejected.
- **Full names only.** Never abbreviate `Product Manager` or `Project Manager` to `PM` — the abbreviation is ambiguous and forbidden across all artifacts.
- File names use kebab-case (e.g., `software-architect.md`, `backend-engineer-payments.md`).

## Language Policy

- **Artifacts** (agent files, docs, code, commits, PR bodies): English.
- **User-facing dialogue during interviews**: user's language — model auto-detects from user's first message.
- **Domain-specific terms**: preserve in original language (e.g., `전자금융거래법`, `信託`, `MTS`). `docs/ssot/glossary.md` pairs each term with an English gloss.
- **User-facing UI strings / copy in product code**: original product language, untranslated.
- **Retrospective records** (`docs/roadmap/checkpoints/m<NN>-retro.md`, `docs/roadmap/lessons-learned.md` content): **user's language** — primary reader is the human owner; the retro is a human ritual. Section identifiers (Header / Keep / Lacking / Try / Decision / etc.) stay English for tooling. See `skills/milestone-checkpoint/SKILL.md` § Language Policy.

## Simplicity Guidelines

- **Minimum code that solves the problem.** No speculative features, abstractions, or configurability unless explicitly requested.
- **Surgical changes.** Touch only what the task requires. Do not "improve" adjacent code.
- **No backward-compat scaffolding** unless requested.
- **Default to no comments.** Write a comment only when WHY is non-obvious and the code alone won't convey it.
- **Delete dead code you created in the same change.** Leave pre-existing dead code alone unless the task targets it.
- Three similar lines is better than a premature abstraction.

## Critical Thinking Obligations (all agents)

1. **State assumptions explicitly.** Mark each as `assumption:confirmed|unconfirmed`.
2. **Research before proposing.** Check if an existing library, service, skill, or agent solves the need before creating a new one.
3. **Mutually challenge.** Before approving another agent's artifact, raise at least one concrete reservation. `LGTM` alone is rejected.
4. **No groupthink.** Reach independent verdicts. If you find yourself agreeing reflexively after others, re-examine.
5. **Name risks.** Every major decision must surface at least one risk and a mitigation or fallback.

## Interview Discipline (for interview-conducting agents and skills)

Applicable at: STEP 0, 0.5, 1 (`init-project`); `milestone-checkpoint`; `hotfix` scoping; `escalate` intake.

1. **Ask exactly one open-ended question per turn.** Never enumerate multiple distinct open prompts in a single message. Snapshot + single question (e.g., "here are 9 inferred defaults — which to change?") counts as one question.
2. **Show option lists only on demand.** Lead with an open question; reveal preset choices only after the user asks for options or gives a too-vague answer.
3. **Acknowledge each answer briefly before moving on.** Don't rush; confirm understanding so the user knows you heard them.
4. **Allow back-tracking.** The user can revise any earlier answer; loop back gracefully.

Forbidden anti-patterns:
- Asking 5 distinct discovery questions in one message.
- "Please answer the following: 1) ... 2) ... 3) ..." where each item demands a separate substantive answer.
- Posting all sections (A through I) of STEP 0.5 in one message expecting per-section answers.

## Commit & PR Behavior

See `docs/process/git-flow.md` (branch/commit conventions) and `docs/process/change-review-workflow.md` (PR cycle). Key constraints relevant to all code-producing agents:

- Conventional Commits format. Subject ≤72 chars, imperative mood. Body explains *why*, not *what*.
- One logical change per commit.
- No `--no-verify`, `--force`, `--amend` after push.
- PR title: `[<task-id>] <type>: <intent>`.
- PR body must include: Purpose, Roadmap Link, Changes, Related Docs, Review Checklist (filled by `atelier-open-pr`).

## Reference

- `docs/process/git-flow.md` — branching/commits in detail.
- `docs/process/change-review-workflow.md` — change-review cycle.
- `docs/process/review-checklists.md` — 3 reviewer lenses.
- `docs/process/definition-of-done.md` — task completion criteria.
- `docs/process/discovery-interview-guide.md` — Phase 1 STEP 1 question bank.
