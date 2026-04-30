# Operating Preferences (Template)

This file is filled in by `/atelier:init-project` STEP 0.5. It records project-specific choices that shape every downstream decision. Update only via explicit user decision.

---

## A. User Involvement Level
<!-- One of: Fully Autonomous | Milestone Checkpoints (default) | PR-Level Checkpoints | Detailed Supervision -->

**Chosen:**

**Rationale:**

---

## B. Language & Framework Preferences

**Pre-selected languages:**
**Pre-selected frameworks/platforms:**
**Banned technologies (and why):**
**Target deployment environment:**

---

## C. Development Methodology
<!-- One or a hybrid of: TDD | BDD | Test-after | Prototype-first | Other -->

**Chosen:**

**Notes on application** (e.g., TDD for business logic, test-after for UI glue):

---

## D. Test Coverage Policy

**Overall coverage target:**
**Critical-path modules and thresholds:**
**Integration vs unit split preference:**
**Exempt paths (and why):**

---

## E. Review Strictness
<!-- One of: Unanimous (default) | Majority 2-of-3 | Custom -->

**Chosen:**

**Custom policy (if any):**

---

## F. Commit & Branch Policy

Plugin defaults assumed unless overridden below:
- Git-flow `main ← develop ← feature/*`.
- Conventional Commits required.
- No `--force`, no `--no-verify`, no direct commits to `main`/`develop`.
- Feature branches deleted after merge.

**Overrides (if any):**

---

## G. Communication Channel
<!-- One of: CLI-only (default) | CLI + Slack | CLI + Discord | Other -->

**Chosen:**

**External MCP / plugin required:**

**Target channel / webhook (reference only — secrets live in user's MCP config):**

---

## H. Code Forge & Review System
<!-- One of: GitHub (PR) | GitLab (MR) | Bitbucket (PR) | Gerrit (Change) | Local-only | Other -->

**Forge:**

**Review-artifact term** (PR / MR / Change):

**CLI used** (`gh` / `glab` / `git review` / `<none>`):

**Repository URL / remote:**

---

## I. Code Quality Automation

> **Two layers — set independently.** Pre-commit catches problems locally (free, fast, bypassable). CI is the authoritative gate (forge-side, may incur cost). atelier's defaults assume *no project context* — pre-commit on, CI off — to avoid generating cost-bearing infrastructure the user didn't ask for. User opts in to CI explicitly.

### I.a Pre-commit policy (local, no cost)
<!-- One of: None | Format only | Format+Lint (default) | Format+Lint+Test | Full -->

**Level chosen:**

**Tool selection strategy:** (Software Architect auto-picks per stack / user pre-specified)

**Specific tools (if pre-specified):**

**Failure behavior** (auto-fix / block / warn):

### I.b CI policy (forge-side, may incur cost)
<!-- One of: None (default — atelier does NOT generate CI yaml) | Minimal (PR-only, free-tier conscious) | Standard (PR + main push) | Full (matrix, multi-platform, comprehensive) | Custom -->

**Level chosen:**

**Trigger events** (pull_request / push:main / push:any / workflow_dispatch / schedule):

**Cost sensitivity** (high — minimize Actions minutes / medium / low — public repo or paid plan):

**Repo visibility** (public — Actions free unlimited / private — counts toward free tier):

**Caching strategy** (pip / pre-commit / mypy / artifacts / none):

**Notes:**

> If `I.b = None`, atelier does NOT generate `.github/workflows/` or equivalent. User can add CI later by re-running `/atelier:escalate software-architect "enable CI"` or by editing this section and re-running.

---

## Change Log

| Date | Section | Change | Approved by |
|---|---|---|---|
| | | | |
