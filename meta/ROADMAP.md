# Roadmap to v1.0

This document tracks **atelier plugin's** path from current pre-GA to a stable, production-grade v1.0 release.

> **Two SemVer axes — don't confuse them.**
> - **atelier plugin version** (this document) — current `0.1` → `1.0` GA.
> - **Your project's version** when you use atelier (e.g., your fintech app `1.2.3`) — managed by your `/atelier:release` skill, **completely independent**.

> Status legend: ✅ done · 🚧 in progress · ⏳ planned · ❌ rejected (with rationale)

---

## Philosophy — what counts as v1.0

v1.0 is a **stability and trust commitment**, not a feature ceiling. The plugin is "v1.0 ready" when:

1. **It demonstrably works.** atelier-on-atelier (dogfood) has driven a real change-cycle end-to-end with no manual workaround.
2. **It cannot regress silently.** Hook surface, agent personas, skills, and forge adapters have lightweight regression checks in CI (shell syntax, shellcheck, JSON parse, frontmatter schema, sanity checks for high-blast-radius hook regexes). Heavyweight unit/snapshot test infrastructure is rejected as over-engineering for a plugin (markdown + hook one-liners + tiny bash helpers).
3. **It is integrable.** Status, validation, and migration commands produce machine-readable output for external dashboards / CI / migration scripts.
4. **It is upgradable.** A project initialized at v0.x can move to v1.0 without manual doc-tree surgery.
5. **API is frozen.** Agent names, skill names, hook contracts, and file paths are SemVer-stable; breaking changes only on major versions.

Everything below is selected against these five criteria. Items that are nice-to-have but don't block any of these are listed in **Deferred** at the bottom — they ship after v1.0 as needed.

---

## Version Map

| Version | Theme | Status |
|---|---|---|
| **v0.1** | Initial scaffolding — agents, skills, hooks, forge adapters | ✅ |
| **v0.2** | CI + machine-readable surface (status --json, frontmatter lint) | 🚧 current focus |
| **v0.3** | Robustness — migration + lightweight regression checks (syntax, shellcheck, sanity checks) | ⏳ |
| **v0.9** | RC — dogfood + API freeze | ✅ |
| **v1.0 GA** | Stability commitment | ⏳ |

---

## v0.1 — Initial Scaffolding ✅

- 8 default agents (Phase 1: Product Manager, Software Architect, Chief AI Officer, Project Manager, Technical Writer; Phase 2 reviewers: Senior Software Engineer, Tech Lead, QA Engineer).
- 9 user skills + bundled `skill-creator`.
- 12 hooks across 7 events.
- 6 hard-enforced gates (force-push block, 6-file STEP 5.5 gate, unanimous-merge, task-link, direct-merge block, develop-push block).
- GitHub + GitLab forge adapters (Bitbucket/Gerrit emit "not implemented" — deferred).
- 13 process docs + 5 flow docs + 3 templates.
- Capability approval chain (`proposer → Tech Lead → CAIO → user-per-level`).
- 3-reviewer Posting Protocol (deduplicate at posting, preserve independence).
- `bin/atelier-validate` self-validation.
- Apache 2.0 + bundled skill-creator attribution (`NOTICE.md`).
- Collaboration infrastructure: `LICENSE`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `GOVERNANCE.md`, `.github/` templates.
- `README.md` + `README.ko.md`.

---

## v0.2 — CI + Machine-Readable Surface 🚧

**Goal**: build the infrastructure that lets us trust later changes — automated regression checks and machine-readable interfaces. Dogfood happens after this infrastructure exists to catch issues.

### v0.2.1 Regression checks for atelier itself (criterion 2 foundation) — local pre-push, NOT CI

Aligned with atelier's STEP 0.5 default `I.b CI = None` — minimize forge minutes; do everything locally that can be done locally. GitHub Actions are not used by default for atelier-itself maintenance.

- [x] `tools/git-hooks/pre-push` — local pre-push hook running atelier-validate + bash -n on bin/* and on hook commands + jq -e on hooks.json + shellcheck on bin/* + --help check. Setup: `git config core.hooksPath tools/git-hooks` once after clone.
- [x] `tools/git-hooks/README.md` — what runs, when to (re)introduce CI (multi-maintainer, public, branch-protection-required scenarios).
- [x] CONTRIBUTING.md and CLAUDE.md — 3-tier change policy (L1 trivial / L2 substantive / L3 hooks-agents-skills-bin) all going through PR; pre-push hook setup as part of dev setup.
- [ ] *(deferred to post-v1.0 if needed)* Optional minimal CI workflow for when the project goes public or branch protection requires status checks.

### v0.2.2 `/atelier:status --json` (criterion 3)

- [ ] `bin/atelier-status` (or skill body) emits stable JSON: current milestone, in-progress tasks, open PRs, escalations active, capability-log delta since last checkpoint.
- [ ] JSON schema documented at `docs/process/status-schema.md`.
- [ ] Validate output against schema in CI.

### v0.2.3 Frontmatter linter (criterion 2 / 4)

- [ ] Extend `bin/atelier-validate` to fully validate YAML frontmatter for every `agents/*.md` and `skills/*/SKILL.md` (currently checks `name` matches filename + `description` non-empty; extend to required-keys schema, character limits, allowed-values for `name`).
- [ ] Same check covers project-side `.claude/agents/*.md` when run from inside a user project.

### v0.2.4 hooks.json structural validation (criterion 2)

- [ ] `bin/atelier-validate` parses `hooks/hooks.json` with `jq -e .` (rejects malformed JSON).
- [ ] Verifies every handler has the expected event/matcher/command keys.

---

## v0.3 — Robustness 🚧 (largely complete; v0.3.4 in progress)

**Goal**: close "not yet implemented" gaps + lightweight regression checks appropriate for a plugin (markdown + hook one-liners + small bash helpers — no compiled artifacts to deep-test).

### v0.3.1 Migration tooling

- [x] **`bin/atelier-migrate` real implementation** — currently a stub. Procedure: read `docs/INIT-APPROVAL.md` for plugin version at init, diff against current schema, apply renames + structural moves, leave a migration log under `docs/ssot/migrations/`.

### v0.3.2 Lightweight regression checks (the v1.0 "cannot regress" criterion)

A plugin is *content + tiny shell glue*; deep test infrastructure (bats + mock CLIs + snapshot trees) is over-engineered. Instead:

- [ ] **`bash -n` syntax check** on every `bin/*` helper and every hook command extracted from `hooks/hooks.json`. Catches typos at PR time without running anything.
- [x] **`shellcheck`** on `bin/*` (warnings = fail). Standard linter; flags unquoted vars, useless cats, etc.
- [x] **`jq -e .` parse** of `hooks/hooks.json` (rejects malformed JSON).
- [x] **End-to-end checks** for the 3 critical hook regexes only (force-push block, develop-push block, direct-feature-merge block) — 5–10 lines each. Pipe a known-bad command into the hook command, assert exit 2. Pipe a known-good command, assert exit 0. **Not** comprehensive; just the high-blast-radius gates.
- [x] **Help-flag check** for every `bin/*` — `--help` returns 0, doesn't crash on missing args (returns non-zero with usage text).

All of the above hooks into `bin/atelier-validate` and runs in CI from v0.2.1 onward.

### v0.3.3 Naming + frontmatter lint expansion

- [ ] **Frontmatter linter expansion** (extends v0.2.3) — strict schema for `docs/agents/capability-log.md` rows, ADR template structure, task file structure.
- [x] **`pr-workflow.md` → `change-review-workflow.md`** renamed (forge-agnostic terminology). All references updated.

### v0.3.4 Active-milestone task management — forge-aware kanban + GitHub Issues integration

**Gap**: PM decomposes tasks at STEP 4 (init) and reflects at `/atelier:milestone-checkpoint`, but the *start of an active milestone* — "we just entered milestone m02; let's break it into PR-sized tasks now with current context" — has no explicit step. The roadmap stays high-level, mid-milestone task creation is implicit, and there's no visual way to see "what's where" without parsing each task file. External stakeholders also can't see/contribute via the forge's native Issue tracker.

Design follows the **forge-adapter philosophy** (mirroring `atelier-open-pr` / `atelier-check-reviews`): GitHub mode integrates with Issues + Projects v2; GitLab/Bitbucket/local-only fall back to markdown + ASCII renderer. atelier's SSOT principle is preserved — `docs/roadmap/tasks/*.md` is always the source-of-truth; forge artifacts are one-way mirrors.

Contributes to v1.0 criterion #3 (integrable).

#### Common (all forges)

- [x] **`/atelier:plan-milestone <m-id>`** skill — multi-agent decomposition mirroring STEP 2/3/4 challenge pattern (not PM-solo):
  1. **PM (proposer)** drafts PR-sized tasks (~½–2 days, ~100–500 LOC) with epics, deps, ACs as checkboxes, lane=backlog.
  2. **Tech Lead (mandatory challenger)** in same chat: architectural fit (vs `architecture.md`), module-boundary check (vs `team-composition.md`), current code state, sizing audit.
  3. **CAIO (conditional challenger)** — only if PM or Tech Lead flagged a capability gap or team-composition concern. May trigger parallel `/atelier:add-agent` / `add-skill` / `add-mcp` chain.
  4. **PM revises** based on challenges; files written after revision settles.
  5. **User review** per involvement level (Detailed Sup = every plan; Milestone+ = scope-shift only; Fully Auto = log-only).
  6. Output: `docs/roadmap/tasks/t<NN>-*.md` per task. GitHub mode also creates Issue mirrors via `atelier-sync-tasks`.
- [x] **Task frontmatter extension** (additive, non-breaking):
  - `lane:` — kanban position (`backlog | todo | in-progress | in-review | done`).
  - `epic:` — slug grouping related tasks within a milestone (optional; absent = standalone).
  - `depends_on:` — task IDs that must complete first.
  - `acceptance:` — checkbox list (`[ ]` / `[x]`) for AC tracking.
- [x] **`atelier-status --json` extension** — adds `lanes: {backlog: [], todo: [], in_progress: [], in_review: [], done: []}` and `epics: {<slug>: [task_ids]}` keys. `schema_version` stays `"1"` (additive).
- [x] **PM persona update** — `/atelier:milestone-checkpoint` audit list gains "lane drift" check: any task in `in-progress` lane but `status: assigned` (or vice versa) is a stale-bookkeeping defect. WIP overflow (default `in-progress > 2`) is **soft warn** — flagged with ⚠️ but not blocked.
- [x] **`/atelier:kanban`** skill — forge-aware output. Default = ASCII column board grouping current task files by `lane:` frontmatter. Columns: BACKLOG / TODO / IN-PROGRESS / IN-REVIEW / DONE. WIP overflow flagged with ⚠️.

#### GitHub mode (when STEP 0.5 H.Forge = GitHub)

- [x] **`bin/atelier-sync-tasks`** — one-way `md → Issues` sync. `--dry-run` default; `--apply` mutates. Each `docs/roadmap/tasks/t<NN>-*.md` becomes a GitHub Issue with body templated from md (synopsis, ACs as checkboxes, depends_on as `Depends on #<N>`). Lane stored as label (`lane:backlog`, `lane:todo`, etc.). `epic:` slug → label `epic:<slug>` OR GitHub sub-issue parent (preferred when set up).
- [ ] **`atelier-open-pr` extension** — when a task has a mirrored Issue, PR body auto-includes `Closes #<issue-number>` so merge auto-closes the Issue.
- [ ] **STEP 0.5 sub-question H.1** — *"GitHub Projects v2 board?"* Three choices:
  1. *(default)* Yes — repo-level project auto-generated by Software Architect at STEP 2. Custom fields: Lane (single-select), Epic (single-select), Depends-on (Issue refs). Default views: Kanban / Milestone / Backlog.
  2. No — Issues only (label-based lane tracking, no Projects v2 GUI).
  3. Org-level — user provides existing org board URL.
- [ ] **`/atelier:kanban` GitHub branch** — output GitHub Projects URL + ASCII fallback. When Projects v2 is disabled, render a label-based board pulled via `gh issue list`.
- [ ] **Inbox triage workflow (PM)** — `/atelier:plan-milestone` and `/atelier:milestone-checkpoint` both poll `gh issue list --label kind:request` and surface untriaged Issues. PM decision: accept (→ task md + `kind:task` label + sub-issue link) / defer (→ `kind:milestone-candidate` label) / reject (→ close with reason).
- [ ] **Bug Issue → hotfix integration** — `/atelier:hotfix <issue#>` skill extension: reads the Issue, creates a hotfix branch + task md, links them, closes Issue at merge.

#### GitLab mode (deferred to v0.5+)

`glab issue` + GitLab Issue Boards via `glab board`. Same SOT-in-md model. Out of v0.3.4 scope.

#### Bitbucket / Local-only

ASCII `/atelier:kanban` only. Acceptable for v1.0 since Bitbucket/Gerrit adapters are deferred to post-v1.0 (see Deferred section).

#### Explicitly out of scope (v0.3.4)

- Notion MCP / Notion sync — adds external surface, splits SSOT. Notion users can build their own Issue → Notion sync separately; not atelier's responsibility.
- Two-way sync (`Issue → md`) — drift risk too high. md is SOT; users edit md and push, not Issue.
- Burn-down charts, story points, time tracking — atelier stays text-first; consumers can build these from `--json`.
- Drag-drop GUI in atelier — GitHub Projects v2 already provides this.

---

## v0.9 → v1.0 RC closure ✅

**Goal**: prove the v1.0 commitment is shippable. Closed during the v0.9.0-rc.1 → v0.9.0-rc.5 cycle: automated checks, dogfood evidence (D1), API freeze, marketplace metadata in tree.

### Automated (closed in RC cycle)

- [x] **API surface drift detector** — `bin/atelier-api-audit` runs all 7 v1-api-surface.md categories. Pre-push hook gates it. Zero drift on develop tip.
- [x] **Migration end-to-end check** — `tests/verify-migration.sh` exercises v0.1 → v0.3 path end-to-end on a synthetic fixture (legacy refs replaced, version stamped, deprecated dir removed, log written). Pre-push hook gates it.
- [x] **Breaking changes catalog** — `meta/version-history.md`. 3 entries for v0.1 → v0.3. v0.2 → v0.3 transition was additive (no breakings).
- [x] **API freeze decision** — `meta/v1-api-surface.md` declares the 7 frozen categories. Pre-freeze TODO checklist updated to reflect automated checks already in place.
- [x] **Dogfood plan** — `meta/dogfood-plan.md` defines D1/D2/D3 slot criteria and per-project log format.

### Lived experience (recommended, not blocking GA)

atelier ships v1.0 on automated guarantees + atelier-on-atelier (D1) maintenance evidence + deliberate API freeze. Multi-domain dogfood (D2/D3) is a post-v1.0 hardening exercise that informs v1.x patches.

- [x] **D1 — atelier-on-atelier dogfood** — every PR since v0.2 has been merged through atelier's own discipline (feature branches, 3-tier change policy, Conventional Commits, atelier-validate gate, pre-push hook). The plugin source repo IS the dogfood log; the plugin source repo's git history IS the dogfood log.
- [ ] **D2 — independent web/SaaS project** — *recommended for v1.x stabilization, not v1.0 gate.* See `meta/dogfood-plan.md`.
- [ ] **D3 — independent data/CLI project** — *recommended for v1.x stabilization, not v1.0 gate.*
- [ ] **Multi-forge coverage** — *deferred to v1.x.* GitHub adapter is exercised by D1; GitLab/local-only adapters work by inspection but lack production evidence.
- [ ] **Independent documentation reviewer** — *recommended; not blocking.* Solo-maintainer self-review is the v1.0 baseline.
- [ ] **User involvement levels (1–4) coverage** — *deferred to v1.x.*

### Distribution — metadata IN v1.0, publish action deferred

Splitting "ready to publish" from "actually published":

- **In v1.0**: marketplace-required metadata is authored + validated. Plugin is *publish-ready* but not yet published.
- **Post-v1.0**: actual publish to a Claude Code marketplace happens whenever the maintainer chooses. No code change needed at publish time — only marketplace registration.

This is the same pattern as a `setup.py`-equipped Python package that hasn't been pushed to PyPI yet: ready, just not live.

- [ ] **Marketplace metadata authored** — `.claude-plugin/marketplace.json` (and any other Claude Code-required files). Validated by `bin/atelier-api-audit` § 8 (new). **In v1.0.**
- [ ] **Metadata end-to-end check** — `tests/verify-marketplace-metadata.sh` confirms required fields present + values match `.claude-plugin/plugin.json`. **In v1.0.**
- [x] **README install section honest** — explicitly documents `--plugin-dir` as the v1.0 install path; marketplace publish flagged as future. **Done.**
- [ ] **Published to a marketplace.** *Post-v1.0; maintainer's call.*
- [ ] **`/plugin install atelier` works for fresh users.** *Activates when published; metadata is already correct.*

The automated portion + metadata + atelier-on-atelier dogfood form the v1.0 gate. Multi-domain lived experience and actual marketplace publish are post-v1.0 hardening.

---

## v1.0 GA ⏳

**Goal**: stable, API-frozen, install-via-`--plugin-dir`-or-symlink-ready, marketplace-publish-ready (publish action itself happens whenever).

### Required for v1.0 GA

- [x] All RC automated criteria met (`atelier-api-audit` zero drift, `tests/verify-migration.sh` passes, pre-push hook gates both).
- [x] **D1 atelier-on-atelier dogfood** — every PR since v0.2 was merged through atelier's own discipline. Plugin source git history IS the dogfood log.
- [ ] **v1 acceptance test suite** — single command `bash tests/v1-acceptance.sh` runs all gates (validate + audit + migration + helper sanity checks + hook bypass-resistance check + marketplace metadata verification). Exit 0 = ready to tag v1.0.
- [ ] **Marketplace metadata in tree** — `.claude-plugin/marketplace.json` authored + validated. Publishing the metadata to a real marketplace can happen later; the plugin is publish-ready.
- [ ] `GOVERNANCE.md` updated with API stability commitment language (post-v1.0 SemVer rules: no breaking changes within v1.x; v2.0 required for any).
- [ ] No open Critical or High security issues per `SECURITY.md` triage.
- [ ] **Hook bypass-resistance audit** — every hook in `hooks/hooks.json` reviewed against the bypass patterns documented in CLAUDE.md (force-push, --no-verify, --amend after push, develop-direct-merge, feature-direct-merge). Findings either fixed or accepted as ADR.
- [ ] Final README pass — install instructions, status badge, version reference all consistent.
- [ ] `meta/version-history.md` includes v0.3 → v1.0 section (additive only — no breakings).

### Explicitly NOT required for v1.0 GA (deferred to v1.x)

- Marketplace publish action (metadata is in tree; publish is a separate registration step).
- D2 / D3 dogfood (independent web/SaaS + data/CLI projects).
- Documentation pass by an independent reviewer.
- User involvement levels 1–4 coverage across multiple projects.
- Multi-forge production validation (GitHub is the only forge with real evidence; GitLab adapter compiles + has unit-level checks; Bitbucket/Gerrit are stubbed).
- Public release announcement (channel + timing maintainer's call).

### Post-v1.0 declarations (when GA tag ships)

- First support window: `v1.x supported for ≥ 12 months from v1.0 tag date`.
- API freeze in effect: any change to surfaces in `meta/v1-api-surface.md` requires v2.0 bump + 1-minor-version deprecation overlap.

---

## Deferred (post-v1.0, as needed)

These were in earlier roadmaps but don't gate v1.0. They ship after GA when there's pull from real users.

| Item | Why deferred |
|---|---|
| Bitbucket / Gerrit forge adapters | GitHub + GitLab + local-only covers >95% of users. The "not implemented" message is acceptable as a v1.0 surface — community PR welcome. |
| Per-stack `.pre-commit-config.yaml` templates | `capability-management.md` already mandates reuse-first; users pick from existing pre-commit ecosystem. Templates would be redundant. |
| Standard repo file generator (`.gitignore`, `.editorconfig`, `CODEOWNERS`) | Software Architect can decide per project; not a hard guarantee atelier needs to ship. |
| `docs/process/incident-response.md` | One doc; can be added any minor release without breakage. |
| `docs/process/security-baseline.md` | Same — one doc, additive. |
| `/atelier:dependency-audit` skill | Reuse-first principle says: integrate existing tools (`npm audit`, `pip-audit`) via MCP if needed; new skill is unjustified bloat. |
| `/atelier:retrospective` skill | `/atelier:milestone-checkpoint` already covers retrospectives. Splitting them is overkill. |
| Glossary auto-population from domain dictionaries | Every project's domain language is bespoke; auto-pop creates noise. |
| Internationalization for ≥3 languages | Plugin is dialogue-language-aware (auto-detects from user). Doc translation is community contribution territory, not v1.0 gate. |
| Stop / PreCompact hook polish (markdown summaries, doc suggestions) | Current hooks already warn; richer output is UX polish. |
| Telemetry policy | Opt-in only and atelier currently transmits nothing. Adding telemetry is a deliberate post-v1.0 decision, not an inclusion gate. |
| Brand assets, marketplace listings | Adoption-marketing concerns, not technical readiness. |
| Maintainer team ≥3 with succession process | Organizational, not engineering. Important but not gating the technical v1.0. |
| Multi-language interview / project portfolio view / live agent metrics / self-improving prompts / compliance modes / cross-team collaboration | All speculative v1.x ideas — not necessary for stability commitment. |

### Explicitly rejected ❌

| Item | Reason |
|---|---|
| `examples/<name>/` sample project directory | atelier-on-atelier is the canonical reference. A separate sample drifts; maintenance burden > value. (Removed in v0.2.) |
| Plugin-shipped CHANGELOG.md | Source docs are kept current (Living Documentation). Per-version migration notes live in `meta/version-history.md`. |
| `docs/agents/agent-specs/` separate spec files | The executable `.claude/agents/<name>.md` IS the spec. Duplication rejected. |
| Per-PR CAIO review (4th reviewer) | Tech Lead carries delegated team-boundary check; no overlapping lens needed. |
| **Heavyweight test infrastructure** (`bats` + mock `gh`/`glab` + skill snapshot trees + 70% line coverage) | atelier is **a plugin**: markdown + hook one-liners + small bash helpers. Most "behavior" is text Claude interprets. Snapshot-testing an interactive interview is impractical without stubbing Claude itself. Lightweight checks (`bash -n`, `shellcheck`, `jq -e`, sanity checks for critical regexes — see v0.3.2) deliver 90% of the regression confidence at <10% of the cost. |

---

## How to Influence the Roadmap

- **Bug**: file an issue.
- **Feature request**: open a discussion. Strong cases get added to a version with rationale.
- **Cross-cutting change**: open an RFC per `GOVERNANCE.md`.
- **Want a Deferred item promoted into a version?**: argue the case against the five v1.0 criteria. If it doesn't move the needle on stability / regression-proofness / integrability / upgradability / API freeze, it stays Deferred.

This roadmap is updated with every minor release. Last updated: see git history of this file.
