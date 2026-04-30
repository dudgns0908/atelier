# Living Documentation

Documents are **load-bearing infrastructure**, not write-once artifacts. Stale documentation is a defect with the same severity as broken code.

## Principle

A change is **incomplete** until the documents that describe it have been updated in the *same* change request. There is no "I'll update the docs later" — the doc update is part of the task, not after it.

## Mechanisms

- **Post-merge auto-trigger**: `atelier-post-merge` runs Technical Writer on every merged change request to reconcile affected docs and append to glossary / ADRs.
- **Definition of Done**: every task's DoD includes "affected docs updated in same PR" — see `docs/process/definition-of-done.md`.
- **Reviewer obligation**: every reviewer (Senior Software Engineer, Tech Lead, QA Engineer) checks doc freshness within their lens. A diff that changes behavior without touching the matching doc is grounds for `REQUEST_CHANGES`.
- **PreCompact hook** warns when ADRs are unfinalized or `lessons-learned.md` lags behind milestone count, before context compaction.

## Source-of-Truth

- Every fact lives in **exactly one** canonical document. All other mentions link to it.
- Duplication is a defect. Technical Writer flags and merges duplicates.
- Agent `.md` files contain **only persona, inputs/outputs, responsibilities, and document references** — not inline domain knowledge.

## What "up-to-date" means concretely

| Change kind | Doc that must be updated in same PR |
|---|---|
| Behavior or contract change in code | `docs/design/architecture.md`, `data-model.md`, or relevant section |
| New requirement / removed feature | `docs/requirements/*.md` |
| New / changed agent | `docs/agents/team-composition.md` + `capability-log.md` |
| New external dependency / MCP / tool | ADR in `docs/ssot/decisions/` + `capability-log.md` |
| New domain term used in code or docs | `docs/ssot/glossary.md` |
| Roadmap shift (scope, milestone, risk) | `docs/roadmap/*` |
| Hook / settings / agent persona / process change | `CLAUDE.md` (if user-facing implication) + relevant `docs/process/*` |
| Bug fix that contradicts a doc claim | The doc claim |

If you change something not on this list, ask: *"would another agent reading this in 3 months know what we decided?"* If no, document it.

## Doc-freshness — quick reference for reviewers

A diff is **not approvable** if any of the following is true:

1. Code changed behavior, but no `docs/design/*` or `docs/requirements/*` reflects it.
2. New external dependency / tool / MCP, no ADR in `docs/ssot/decisions/`.
3. New agent / skill, no row in `docs/agents/capability-log.md`.
4. New domain term used in code or copy, missing from `docs/ssot/glossary.md`.
5. Comment / docstring contradicts the implementation it describes.

Treat doc drift as a code defect. Reviewers cite this rule explicitly when issuing `REQUEST_CHANGES`.

## Anti-patterns

- "TODO: docs later" comments in code.
- Updating docs in a follow-up PR instead of the same PR.
- Docs that describe the previous behavior because no one updated them after a feature change.
- Two documents claiming different facts about the same thing — one of them is wrong, fix the canonical source and link the other.
- Agent personas containing domain knowledge that should live in `docs/ssot/`.

## Continuous Freshness Workflow (Technical Writer, post-merge)

Triggered automatically by `atelier-post-merge`:

1. Inspect the diff. Categorize affected areas: code only / docs only / mixed.
2. For each modified module/file, identify which `docs/` documents describe it (use the mapping table above).
3. If any document describes outdated behavior → update in a follow-up PR (or, ideally, the original PR's reviewers should have caught this and required the update inline).
4. Append to `docs/ssot/glossary.md` any new domain term that appeared in the merged diff.
5. If an ADR trigger fired and no ADR was committed, raise `REQUEST_CHANGES` retroactively as a follow-up issue.
6. Update the project's `CHANGELOG.md` (if the project maintains one — atelier itself does not) when the merge represents a user-visible behavior change.
