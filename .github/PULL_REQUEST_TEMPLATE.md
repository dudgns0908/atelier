<!--
Title format: [<task-id>] <conventional-type>: <intent>
Example:      [T07] feat: add Bitbucket forge adapter

If this is a tiny docs-only change without a task ID, use:
              docs: <intent>
-->

## Purpose

<!-- One sentence: what does this PR do and why? -->

## Roadmap link

<!-- Reference docs/roadmap/tasks/<id>-*.md or the issue that motivated this. -->

## Changes

<!-- Bullet list of changes. -->

-

## Related docs / ADRs

<!-- Links to docs/design/, docs/requirements/, docs/ssot/decisions/ if relevant. -->

## Capability additions (if any)

<!-- New skill / MCP / agent? Confirm the capability-extension entries are present. -->

- [ ] `docs/agents/capability-log.md` updated
- [ ] ADR added to `docs/ssot/decisions/` (mandatory for MCPs and per ADR triggers)

## Testing

<!-- How did you validate this works? -->

- [ ] `bin/atelier-validate` passes
- [ ] Manual end-to-end check (describe):

## Three-Reviewer Checklist

This PR will be reviewed through three independent lenses before merge.

- [ ] **Senior Software Engineer** — code quality (correctness, tests, security, scope)
- [ ] **Tech Lead** — architectural alignment (design conformance, ADR completeness, MCP/skill reuse)
- [ ] **QA Engineer** — requirements & roadmap alignment (acceptance criteria, milestone fit, no scope drift)

## DCO Sign-off

- [ ] All commits in this PR are signed off (`git commit -s`).

## Checklist

- [ ] PR title follows `[<task-id>] <type>: <intent>` format
- [ ] Conventional Commits used in all commit messages
- [ ] No `--force`, `--no-verify`, or direct push to `main`/`develop`
- [ ] CHANGELOG `Unreleased` updated if user-visible change
- [ ] Real industry job titles only (LinkedIn test) for any new agent
- [ ] No abbreviation `PM` for Product Manager / Project Manager
