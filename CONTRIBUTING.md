# Contributing to atelier

Thank you for considering a contribution. `atelier` is a structured-governance plugin, so the contribution flow itself is structured. This document explains how to propose changes that we can confidently merge.

## Table of Contents

- [Ways to Contribute](#ways-to-contribute)
- [Before You Start](#before-you-start)
- [Development Setup](#development-setup)
- [Dogfooding: Use atelier on atelier](#dogfooding-use-atelier-on-atelier)
- [Conventions](#conventions)
- [Submitting Changes](#submitting-changes)
- [Pull Request Process](#pull-request-process)
- [Style Guide](#style-guide)
- [Working with Hooks](#working-with-hooks)
- [Working with Agents](#working-with-agents)
- [Working with Skills](#working-with-skills)
- [Testing](#testing)
- [Release Process](#release-process)
- [Sign-off](#sign-off)
- [Questions](#questions)

---

## Ways to Contribute

| Contribution | Effort | Notes |
|---|---|---|
| Report a bug | Low | Use the bug issue template. Reproduction steps are essential. |
| Improve documentation | Low | README, process docs, inline comments. PR with the change is fine. |
| Add a forge adapter (Bitbucket / Gerrit) | Medium | Mirror the GitHub/GitLab pattern in `bin/atelier-open-pr` and `atelier-check-reviews`. |
| Add a new skill | Medium | New skills must justify themselves against `docs/process/agent-team-sizing.md` and `docs/process/capability-management.md`. |
| Add a new agent (default roster) | High | Requires governance review — open a discussion first. |
| Harden a soft rule into a hook | High | Identify the soft rule, propose the hook semantics, ensure it is bypass-resistant. |
| Translate documentation | Low to Medium | Translations of `README.md`, `docs/process/` welcome (e.g., `README.ko.md`). |

For non-trivial changes, **open an issue or discussion first**. Avoid surprise PRs.

---

## Before You Start

1. Read the [README](README.md) end-to-end.
2. Skim [docs/process/](docs/process/) — especially `agent-team-sizing.md`, `capability-management.md`, `change-review-workflow.md`, and `git-flow.md`.
3. Read this CONTRIBUTING.md fully.
4. Read [GOVERNANCE.md](meta/GOVERNANCE.md) to understand how decisions are made.
5. Read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md). Participation implies acceptance.

If you are reporting a security vulnerability, do **not** file a public issue. See [SECURITY.md](SECURITY.md).

---

## Development Setup

```bash
git clone <atelier repo URL>
cd atelier

# One-time dev setup — installs pre-push hook + verifies required tools
# (jq, shellcheck) + runs validate. Aborts with an install hint if
# anything is missing.
bash tools/dev-setup.sh

# Already covered by dev-setup.sh, but if you ever want to re-verify:
bin/atelier-validate           # confirm plugin structure is intact
```

To test changes locally with Claude Code:

```bash
claude --plugin-dir /absolute/path/to/atelier
```

When you edit hooks, agents, or skills, run `/reload-plugins` inside the Claude Code session.

### Required tools

- `bash` (4+), `git`, `jq`, `shellcheck`.
- `gh` if you contribute to the GitHub adapter; `glab` for the GitLab adapter.

### No GitHub Actions by default

atelier-itself maintenance does **not** rely on forge CI. All regression checks (atelier-validate, bash -n on bin/* and on hook commands, jq -e on hooks.json, shellcheck, --help check) run **locally via `tools/git-hooks/pre-push`**. This honors atelier's STEP 0.5 default `I.b CI = None` — minimize forge minutes, do everything locally that can be done locally.

If you skip the `git config core.hooksPath tools/git-hooks` step, your push won't be checked. Reviewers will catch most issues, but please install the hook before pushing.

See [`tools/git-hooks/README.md`](tools/git-hooks/README.md) for what runs and when to (re)introduce CI.

---

## Dogfooding: Use atelier on atelier

Substantial features should be developed *using* atelier, not just for it. Concretely:

1. **Open an issue** describing the desired change.
2. **Run `/atelier:add-agent` or `/atelier:add-skill`** if your change introduces a new role or capability.
3. **File a task** in the project's `docs/roadmap/tasks/` (we maintain this for atelier itself).
4. **Open a PR** that follows the same three-reviewer model as user-project PRs.

This is not always practical for tiny doc fixes, but for anything that touches agents, hooks, or skills, dogfooding catches issues that no abstract review would.

---

## Conventions

### Real Job Titles
Every agent must use a real industry job title (the LinkedIn test). Invented labels (`Code Wizard`, `Master Builder`, `Synthesizer`) are rejected.

### No PM Abbreviation
`Product Manager` and `Project Manager` are spelled out everywhere. The abbreviation `PM` is **forbidden** in all artifacts because of the ambiguity.

### Single Source of Truth
A fact lives in one canonical document. References cross-link; they don't duplicate. PRs that introduce duplication are rejected.

### English for Artifacts, Domain-Native for Terms
All agent files, skill SKILL.md, code, commits, and PR bodies are in English. Domain-specific terms are preserved in the original language (e.g., `전자금융거래법`, `信託`, `ﻊﻘﺑ`). Add domain terms to `docs/ssot/glossary.md` with an English gloss.

### Conventional Commits
Every commit follows [Conventional Commits 1.0.0](https://www.conventionalcommits.org/). Allowed types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `build`, `ci`, `style`. Example:

```
feat(hooks): add reload-reminder for new skills/MCPs

When a new file appears under .claude/skills/, .claude/agents/, or
.mcp.json, the UserPromptSubmit hook prints a reminder until the user
runs /reload-plugins and acks via .atelier/last-reload-ack.
```

### ADR for Significant Decisions
If your change fires any [ADR mandatory trigger](docs/README.md#ssot-schema), include an ADR in the same PR. Tech Lead reviews will block merge if an ADR is missing.

---

## Submitting Changes

### Change-tier policy (3-tier)

Every change goes through a feature branch + PR. **No direct commits to `main` or `develop`** at any tier — audit trail and reviewability are preserved even for trivial changes. Review depth varies by tier:

| Tier | Examples | Review depth | Approval |
|---|---|---|---|
| **L1 — Trivial** | typo, logo refresh, single-line doc fix, comment update | Single approve, no lens template required | Solo single approve OK |
| **L2 — Substantive docs / templates** | process rule change, ROADMAP update, agent persona refinement, flow doc, capability-management update | Solo single-voice **3-lens** review template (`[Code Quality]` / `[Architecture]` / `[Requirements]`) | Solo OK if only maintainer; ≥1 independent reviewer if team grows |
| **L3 — Hooks / agents (new) / skills (new) / `bin/*` / `.claude-plugin/` | new agent file, hook regex change, new skill, change to atelier-open-pr / atelier-check-reviews / atelier-validate / atelier-status / atelier-migrate | Mandatory 3-lens review (solo single-voice OR 3 independent reviewers) + regression test if hook touched | Cannot be skipped |

Pre-push hook (`tools/git-hooks/pre-push`) enforces the same regression checks across all tiers. CI is intentionally absent — see Development Setup.

### 1. Branch from `develop`

```
git checkout develop && git pull
git checkout -b feature/<task-id>-<kebab-slug>
```

For atelier-itself contributions, use the task ID we agreed on in the issue (e.g., `feature/t42-add-bitbucket-adapter`).

### 2. Make focused commits

One logical change per commit. If your change is large, split it into a series of small commits — easier to review, easier to revert.

### 3. Update tests / docs / changelog

- Add or update `docs/process/` if you change a policy.
- Add a migration note to `meta/version-history.md` if your change affects existing user projects (atelier ships no CHANGELOG.md by design — Living Documentation principle).
- Add an ADR to `docs/ssot/decisions/` if a mandatory trigger fired.
- Run `bin/atelier-validate` and ensure it passes.

### 4. Push and open a Pull Request

```
git push -u origin feature/<task-id>-<kebab-slug>
gh pr create --base develop
```

Use the PR template if one exists in `.github/`.

---

## Pull Request Process

### Three-Reviewer Model (mirroring atelier itself)

| Reviewer | Lens |
|---|---|
| **Senior Software Engineer** (or designated reviewer) | Code quality: correctness, tests, readability, security |
| **Tech Lead** (or designated reviewer) | Architectural alignment: design conformance, ADR completeness, MCP/skill reuse |
| **QA Engineer** (or designated reviewer) | Requirements & roadmap alignment: matches the issue, no scope creep, all ACs covered |

For tiny docs-only changes, a single maintainer approval is acceptable. For changes that touch agents, skills, or hooks, all three lenses must approve (a single maintainer can voice all three lenses if the team is small, but explicitly).

### Solo-maintainer review template (small-team explicit-three-lens pattern)

When the team is one maintainer and the change touches `hooks/`, `agents/`, `skills/`, `bin/`, or `.claude-plugin/`, post **one** review comment with three explicit blocks:

```
APPROVE — solo-maintainer review per CONTRIBUTING.md (single voice, three lenses).

[Code Quality]
- <correctness, tests, readability, security findings — or "no issues"; cite specific concerns>

[Architecture]
- <design conformance, ADR completeness, MCP/skill reuse findings>

[Requirements]
- <issue-match, scope, AC coverage, vision alignment findings>

All three lenses pass. Merging.
```

This is **not** a self-merge bypass. The atelier rule "Conductor never self-merges" (in user-project `CLAUDE.md`) forbids merging *without* the 3-lens gate; it does not forbid the merger executing the merge command after the gate. Solo-maintainer voicing three lenses explicitly *is* the gate, just collapsed into one author.

When a second maintainer joins, this template retires — independent reviewers are always preferred when available.

### Approval Policy

- **Default**: unanimous approval from the three reviewers (or their stand-ins).
- Disagreement is recorded in the PR. We don't merge "with dissent" without explicit user-facing reasoning.

### Merge Style

Default: merge commit (preserves per-commit history). Squash for trivial PRs.

### After Merge

- Branches are auto-deleted (`gh pr merge --delete-branch`).
- Technical Writer (or its stand-in) reconciles affected docs in the next merged PR if not already done in this one.
- The `atelier-post-merge` hook (when running in a Claude Code session) does this automatically.

---

## Style Guide

### Markdown
- Use `#` once per file (the title).
- Two-blank-line separation before major sections.
- Code blocks always have a language hint.
- Table headers use bold for emphasis instead of italics.

### Bash
- `set -euo pipefail` at the top of every script.
- Quote all variable expansions: `"$var"`.
- Prefer `[[ ... ]]` over `[ ... ]` in bash, but `[ ... ]` for POSIX-portable hooks.
- No invocation of forge CLIs without a forge auth check.

### JSON
- 2-space indent.
- Keep `hooks/hooks.json` validated with `python3 -c "import json; json.load(open(...))"`.

---

## Working with Hooks

Hooks live in `hooks/hooks.json`. They run at the Claude Code harness layer.

When adding a hook:

1. Identify the event (`PreToolUse`, `PostToolUse`, `SessionStart`, `UserPromptSubmit`, `Notification`, `PreCompact`, `Stop`).
2. Decide block vs warn vs notify (block = `exit 2` with a message; warn = `>&2 ...; exit 0`; notify = `>&2 ...; exit 0`).
3. Make commands robust to missing tools (`command -v jq >/dev/null 2>&1 || ...`).
4. Validate JSON: `python3 -c "import json; json.load(open('hooks/hooks.json'))"`.
5. Run `bin/atelier-validate`.
6. Document the hook in `CLAUDE.md` "Hooks Behavior" and add a row to README's enforcement matrix.

Hooks must be **idempotent** and **fast** (target <100ms). Hooks must not write to user-visible state without a clear reason (the `Stop` and `SessionStart` hooks are exceptions, documented).

---

## Working with Agents

Agent files live in `agents/`. Each is an `<agent-name>.md` with YAML frontmatter and a body.

When adding or modifying an agent:

1. Use a real industry job title.
2. Frontmatter must include `name` (matching filename) and `description` (when to invoke).
3. Body sections: Role, Phase Activation, Persona, Primary Responsibilities, Inputs, Outputs, Collaboration, Critical Thinking Obligations, Reference Documents, Language Policy.
4. Keep the persona compact — agent files contain *only* persona/responsibilities/IO, not domain knowledge. Reference docs for the latter.
5. Update `CLAUDE.md` if the agent changes the team's role boundaries.
6. Run `bin/atelier-validate` to confirm frontmatter is well-formed.

---

## Working with Skills

Skill SKILL.md files live in `skills/<name>/SKILL.md`.

When adding or modifying a skill:

1. Frontmatter must include `description` — used by Claude Code to decide when to invoke.
2. Body: instructions to the model, ordered steps, anti-patterns, reference documents.
3. Use `$ARGUMENTS` for user-supplied input.
4. Document the skill in README's "User Skills" table.
5. Update `bin/atelier-validate` required-skills list.
6. Place project-specific skills under `<user-project>/.claude/skills/` — atelier-shipped skills go in `skills/`.

---

## Testing

### Structural validation

```bash
bin/atelier-validate
```

This is the minimum bar. Every PR must pass.

### Manual end-to-end check

Run a real `/atelier:init-project` on a throwaway directory and inspect the output. Even better, take it through one Phase 2 task.

### Hook tests

Hooks can be tested by running their command lines manually with a fake `tool_input`:

```bash
echo '{"tool_input":{"command":"git push --force"}}' | jq -r '.tool_input.command' | grep -qE '...'
```

### Forge adapter tests

See `tests/README.md` for the manual matrix. Automated forge tests are out of scope for v0.x.

---

## Release Process

See [docs/process/release-process.md](docs/process/release-process.md). Releases of atelier itself follow the same `develop → main` cycle as user projects.

A maintainer cuts a release by running `/atelier:release` (when atelier is dogfooded) or by following the manual checklist in `release-process.md`.

---

## Sign-off

We use [Developer Certificate of Origin](https://developercertificate.org/) (DCO). Every commit must be signed off:

```
git commit -s -m "feat: ..."
```

This appends a `Signed-off-by: Your Name <email>` line. By signing off, you affirm that you have the right to contribute the code under the project's license.

---

## Questions

- General discussion: open a GitHub Discussion.
- Bug reports: file an issue with the bug template.
- Security: see [SECURITY.md](SECURITY.md).
- Governance / decision-making: see [GOVERNANCE.md](meta/GOVERNANCE.md).
- Conduct concerns: see [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

Thank you for contributing!
