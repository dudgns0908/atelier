# Review Checklists

Three reviewers; each owns a distinct lens; each must leave at least one substantive comment and a verdict. `LGTM` alone is rejected.

## Senior Software Engineer — Code Quality

- **Correctness**: edge cases, error handling, concurrency, null/empty/boundary inputs, off-by-one, time-zone handling.
- **Readability**: naming, structure, cognitive load, dead code, magic numbers.
- **Tests**: coverage of changed behavior, meaningful assertions, no flakiness, no over-mocking.
- **Performance**: obvious hot paths, N+1 queries, unbounded loops, allocations in hot code.
- **Security**: input validation, secret handling, dependency hygiene, injection vectors, path traversal, deserialization safety.
- **Scope**: diff matches task scope; no drive-by "improvements".
- **Idiomaticity**: follows project style in `docs/design/folder-structure.md` and language conventions.
- **Doc freshness (code-level)**: any code-level documentation (docstrings, inline comments where mandated, README sections that describe modules touched) is updated. If a function signature changed and a docstring lies, this is a defect.

## Tech Lead — Architectural Alignment

- **Design conformance**: matches `docs/design/architecture.md`.
- **Boundaries**: modules/services/layers remain well-separated; no cross-cutting leakage.
- **Team-boundary** *(delegated CAIO concern; CAIO is not a PR reviewer by design)*: PR's author agent stays within its `team-composition.md` responsibility. Out-of-scope drift → `REQUEST_CHANGES` and route to `/atelier:add-agent` or `/atelier:escalate chief-ai-officer`.
- **Data model**: entities and relationships align with `docs/design/data-model.md`; migrations safe and reversible.
- **Folder structure**: placement follows `docs/design/folder-structure.md`.
- **Tech debt**: change does not introduce shortcuts that compound later; if a shortcut is necessary, it is explicitly tracked.
- **Extensibility**: change does not paint into a corner the near-term roadmap.
- **ADR**: if any mandatory trigger fired (see `docs/README.md#ssot-schema`), an ADR is included in this PR. Absent ADR → `REQUEST_CHANGES`.
- **MCP/Skill reuse**: if the PR introduces new tooling, `docs/process/capability-management.md` audit evidence is included.
- **Doc freshness (architectural)**: if `docs/design/architecture.md`, `data-model.md`, `folder-structure.md`, or `integrations.md` describe behavior the diff changes, those docs are updated *in this PR*. Out-of-sync architecture docs are blocking.
- **Capability log**: if a new skill / MCP / agent was added, `docs/agents/capability-log.md` has a row.

## QA Engineer — Requirements & Roadmap Alignment

- **Acceptance criteria**: each AC from the task file is met and has a corresponding test.
- **Milestone fit**: change belongs to the active milestone.
- **Vision alignment**: change is consistent with `docs/requirements/vision.md`.
- **Scope bounds**: no features outside the task scope.
- **User-facing correctness**: copy, UX, i18n, edge cases match `docs/requirements/requirements.md`.
- **Regression risk**: does this break a previously delivered acceptance criterion? Regression tests updated if so.
- **Traceability**: PR body links to the task and the relevant requirement section.
- **Doc freshness (requirements/roadmap)**: if the diff implies a change to `docs/requirements/*` (success criteria, stakeholders, constraints) or `docs/roadmap/*` (task status, risks, lessons-learned), those docs are updated *in this PR*. Glossary should reflect any new domain term used in user-facing copy.

## Doc-freshness — quick reference for all reviewers

A diff is **not approvable** if any of the following is true:

- Code changed behavior, but no `docs/design/*` or `docs/requirements/*` reflects it.
- New external dependency / tool / MCP, no ADR in `docs/ssot/decisions/`.
- New agent / skill, no row in `docs/agents/capability-log.md`.
- New domain term used in code or copy, missing from `docs/ssot/glossary.md`.
- Comment / docstring contradicts the implementation it describes.

Treat doc drift as a code defect.

## Posting Protocol — Deduplicate as You Go

Reviewers run in parallel via Task subagent, but in practice their comments land on the PR sequentially (whichever subagent finishes first posts first). Rather than every reviewer posting their full comment list — producing 3× near-duplicate noise on shared findings — each reviewer **forms verdict independently first, then deduplicates against existing comments at posting time**.

**Order of operations (mandatory, in this order):**

1. **Form your verdict & comment list independently.** Read the diff, apply your lens (Code Quality / Architecture / Requirements), draft your `APPROVE` / `REQUEST_CHANGES` / `COMMENT` plus the comments you would post. Do **not** read other reviewers' comments yet — this preserves independence (see Groupthink Prevention below).
2. **Read existing PR comments.** Only after your draft is locked in.
3. **Reconcile each of your draft comments against existing ones:**
   - **Net-new finding** (no overlap) → post as-is, prefixed with your lens (`[Code Quality]`, `[Architecture]`, `[Requirements]`).
   - **Same finding, same reasoning** → don't repost. Instead, post a one-line concur: `[<your lens>] +1 to <reviewer>'s comment on <line/topic> — same concern from <your lens> perspective.`
   - **Same finding, different angle** → post a delta comment: `[<your lens>] Agree with <reviewer> on <X>. Adding from <your lens>: <the new angle>.`
   - **Conflicting finding** (you disagree with an earlier reviewer) → post explicitly: `[<your lens>] Disagree with <reviewer> on <X>: <reasoning>.` Do not stay silent.
4. **Post your verdict line last**, summarizing your independent judgment regardless of what others said.

This keeps each reviewer's independent judgment intact (step 1) while sparing the PR author from reading the same finding three times (step 3).

## Groupthink Prevention

Each reviewer must reach their verdict *independently*. The Posting Protocol above enforces this by requiring you to draft your comments **before** reading anyone else's. Additionally, before approving when the other two have already approved:
- Re-read the diff without referencing prior comments.
- Ask: *What is a concrete thing that could still be wrong?*

A `+1` (concur) is only valid if you would have raised the same finding independently. Don't concur out of social pressure.

## Verdicts

- `APPROVE` — all checklist items considered and passed; at least one substantive comment on record.
- `REQUEST_CHANGES` — one or more blocking items; list them specifically.
- `COMMENT` — non-blocking suggestions; use sparingly.
