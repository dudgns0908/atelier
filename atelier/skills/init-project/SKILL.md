---
name: init-project
description: Initialize a new project with a structured, multi-agent workflow — discovery interview, operating preferences, technical design, agent team formation, roadmap construction, documentation consolidation, and a final user approval gate. Use when the user starts a fresh project and wants a rigorous setup before any code is written.
---

# Initialize Project

You are the Conductor (main thread) orchestrating Phase 1 — the initialization of a brand-new project. You coordinate five Phase 1 agents in sequence and MUST obtain explicit user approval before handing off to Phase 2 (execution).

## Orchestration Rules

1. **Run steps in order. Do not parallelize.** Each step depends on artifacts from prior steps.
2. **You do not author artifacts yourself.** You delegate to the appropriate Phase 1 agent and relay questions/answers between the user and the agent.
3. **★ Ask exactly ONE question per turn. ★** Never list multiple OPEN-ENDED questions in a single message.
   - **Forbidden** (multiple open-ended questions at once):
     - Asking 5 distinct discovery questions in one message ("What's the vision? Who are the users? What features?...").
     - Saying "Please answer the following: 1) ... 2) ... 3) ..." where each item demands a separate substantive answer.
   - **Allowed** (single question with structured context): showing a configuration snapshot, default list, or summary table as *context* and asking ONE question about the whole picture (e.g., "Here are 9 inferred defaults — which would you like to change?"). The user's reply can identify multiple items to change at once; that is fine because the *question* was one.
   - This distinction matters: Standard mode of STEP 0.5 *legitimately* posts all 9 default presets at once and asks "which to change?". That is one question, not nine.
4. **User speaks the user's language.** You and the agents respond in the language the user uses. All written artifacts are in English, except domain-specific terms which are preserved in original language.
5. **Every step produces artifacts in `docs/`.** If a step cannot produce the expected artifact, pause and escalate to the user.
6. **User must approve at STEP 5.5 before Phase 2 can begin.** No exceptions.

---

## STEP 0 — Welcome, Context, Mode Selection

Conduct STEP 0 as a **strict one-question-per-turn** sequence.

### Turn 1 — Auto-detect new vs existing

**Do NOT ask the user.** Inspect the current working directory and decide:

| Detected state | Action |
|---|---|
| Empty (or only hidden config files like `.atelier/`) | Treat as **new project**. Announce: *"Empty directory detected — starting a brand-new project."* No question. |
| `.git/` directory present | Treat as **existing repo retrofit**. Announce: *"Existing git repo detected — we'll retrofit atelier into it."* No question. |
| Code files present but no `.git/` | This is the only ambiguous case. Ask one question: *"I see code files but no git repo. Should I retrofit atelier into this directory, or do you want to start atelier in a fresh empty directory and reference these files as prior art?"* |

Detection commands the Conductor runs silently:
```bash
ls -A | head        # any non-hidden files?
[ -d .git ]         # git repo?
```

Skip Turn 1's question entirely in the unambiguous cases — just announce the detected state and move to Turn 2.

### Turn 2 — Init mode selection ★ (Phase 1 speed control)

Ask **only this single question**, with the three modes presented as choices:

> "How thorough should the setup be? Three modes available:
>
> **(a) Quick** — give me a one-line brief, I'll infer all defaults, you review and approve at the end. ~5 minutes. Best for trivial CLIs, scripts, prototypes.
>
> **(b) Standard** *(default)* — smart defaults with one-line confirmation per section. You can override anything. ~15-20 minutes. Best for most projects.
>
> **(c) Thorough** — full discovery interview (one question per turn, 6 rounds). ~45-60 minutes. Best for complex / regulated / multi-stakeholder projects.
>
> Which?"

Record the choice. The rest of Phase 1 adapts:

#### Mode (a) Quick path
1. STEP 0.5: ask user for a one-paragraph brief; **infer all 9 sections** (A~I); show inferred defaults in one summary; ask "looks right? changes?"
2. STEP 1: derive vision/requirements/stakeholders/success/constraints from the brief; show summary; one round of "anything missing?" — not 6 rounds.
3. STEP 2-5: agents propose drafts directly without intermediate Q&A. User reviews drafts at each STEP boundary.
4. STEP 5.5: full approval gate (unchanged — non-skippable).

#### Mode (b) Standard path *(default)*
1. STEP 0.5: smart defaults shown per section, user confirms or adjusts. Single turn per section, but the *question* is "use this default or change?" rather than open-ended.
2. STEP 1: 3 rounds (Vision+Users / Features+Success / Constraints) instead of 6. One question per turn within each round.
3. STEP 2-5: as standard.
4. STEP 5.5: full approval gate.

#### Mode (c) Thorough path
- All STEPs run as fully described below — strict one-question-per-turn for every section and round. No batching, no defaults shortcut.

### Turn 3 — Confirm and start

State briefly:

> "Got it — running in **{mode}** mode. We'll start STEP 0.5 now. You can switch modes mid-stream by saying 'switch to {other}'."

Then proceed to STEP 0.5 in the chosen mode.

> Note on `skill-creator`: it is bundled at `skills/skill-creator/` (Apache 2.0, see `NOTICE.md`). No external install required.

---

## STEP 0.5 — Operating Preferences Intake

Before requirements, establish how the user wants the project to operate. This shapes every downstream decision.

**Behavior depends on the mode chosen at STEP 0 Turn 2**:

- **Quick mode** (~1-2 turns): ask for a one-paragraph brief. Infer all sections A~I from the brief + sensible defaults. Present a single summary and ask "Accept? Change which?". Move on once confirmed.

- **Standard mode** *(default, ~1-3 turns)*: present **all 9 defaults in a single, visually-clear snapshot** plus one question *"Which sections to change?"*. The user can reply:
  - `all defaults` → done in 1 turn.
  - `change C, I` → ask follow-up only for those (2-3 short turns).
  - `change all` → fall through to Thorough behavior.

  **Required format** (use this exact structure — markdown table with header section, footer with reply options, bold defaults):

  ```markdown
  ## Operating Preferences — Inferred Defaults

  | § | Section | Default | Alternatives |
  |---|---------|---------|---|
  | **A** | Involvement Level | **Milestone Checkpoints** | Fully Autonomous · PR-Level · Detailed Supervision |
  | **B** | Stack | **<project-derived, e.g., Python 3.11 + Click + pytest>** | replaceable; based on your brief |
  | **C** | Methodology | **TDD** | BDD · Test-after · Prototype-first |
  | **D** | Coverage | **80% line · 100% on `core/`** | adjust target / scope |
  | **E** | Review Strictness | **Unanimous (3-of-3)** | Majority (2-of-3) |
  | **F** | Commit & Branch | **Plugin defaults** (git-flow + Conventional Commits) | override only with a specific reason |
  | **G** | Communication | **CLI-only** | Slack · Discord · custom |
  | **H** | Forge | **GitHub** (`gh` CLI) | GitLab · Bitbucket · Gerrit · Local-only |
  | **I.a** | Pre-commit (local) | **Format + Lint** (ruff or stack-equivalent) | None · Format only · +Test · Full |
  | **I.b** | CI (forge-side) | **None** *(no CI yaml generated)* | Minimal (PR-only, free-tier safe) · Standard (PR+main) · Full (matrix) · Custom |

  ---

  **Reply with one of:**
  - `all defaults` — accept all 9 as-is
  - `change C, I` — tweak only those (I'll ask briefly per item)
  - `change all` — walk through each section in turn
  ```

  Adapt only the *Default* column to project context (B reflects the brief; D may differ for non-CRUD projects). Keep the table structure, headers, bold defaults, and the reply-options footer **exactly** as shown — that's what gives the snapshot its scannability.

- **Thorough mode** (~9-15 turns): ask the open-ended question for each section, one per turn. Show preset options only after the user requests them or gives a vague answer.

In all modes, document answers progressively in `docs/templates/operating-preferences-template.md`.

### A. User Involvement Level

Present four presets and ask the user to pick (or describe a custom level):

1. **Fully Autonomous** — Agents run end-to-end. User sees the roadmap, then only final delivery and post-merge summaries.
2. **Milestone Checkpoints** *(default recommendation)* — User approves at each milestone boundary; otherwise agents proceed autonomously.
3. **PR-Level Checkpoints** — User reviews and signs off on every merged PR before the next task begins.
4. **Detailed Supervision** — User reviews each task plan before coding starts AND signs off on every PR.

### B. Language & Framework Preferences

- Any pre-selected languages? (Python, TypeScript, Go, Rust, Kotlin, etc.)
- Any pre-selected frameworks or platforms? (Next.js, FastAPI, Spring, etc.)
- Any bans? (e.g., "we cannot use technology X for compliance reasons")
- Target deployment environment? (cloud provider, on-prem, edge)

### C. Development Methodology

- **TDD** (write tests first, make them pass)
- **BDD** (behavior specs drive implementation)
- **Test-after** (implement, then cover with tests)
- **Prototype-first** (validate approach, then harden with tests)
- Other / hybrid?

### D. Test Coverage Target

- Overall coverage target (e.g., 80% line, 70% branch)
- Critical-path coverage policy (e.g., 100% on payment / auth modules)
- Integration-vs-unit split preference
- Any code paths explicitly exempt? (migrations, generated code, etc.)

### E. Review Strictness

- **Unanimous approval** from all 3 reviewers (Senior Software Engineer, Tech Lead, QA Engineer) — default
- **Majority (2 of 3)** approval with dissent recorded
- Custom policy

### F. Commit & Branch Policy Confirmations

Confirm plugin defaults (the user can override):
- Git-flow: `main` ← `develop` ← `feature/<task-id>-<slug>`
- Conventional Commits required
- `--no-verify`, `--force` forbidden
- Direct commits to `main` or `develop` forbidden
- Feature branches deleted after merge

### G. Communication Channel

Ask the user which channel agents should use when they need user attention (questions, approval requests, checkpoint pings, risk alerts):

1. **CLI-only** *(default)* — all interactions happen inside Claude Code. No external setup.
2. **CLI + Slack notifications** — agents post notifications to a Slack channel; user still answers in CLI.
3. **CLI + Discord notifications** — same as Slack, but Discord.
4. **Other** — custom channel documented by user.

If the user picks Slack or Discord:
- Tell them to install the corresponding MCP server or plugin (do not bundle it). Example hints:
  - Slack: `@modelcontextprotocol/slack` MCP server.
  - Discord: a Discord MCP server or a webhook-based plugin.
- Ask for the target channel name/webhook and any auth tokens. Record only references, not secrets; the user must add secrets to their own MCP configuration.
- The plugin exposes `bin/atelier-notify <channel> <message>` which routes to the selected channel; if the channel is unconfigured, it silently falls back to CLI stdout.

Fully async (answering from Slack/Discord without returning to CLI) is not supported in v0.1. Record the user's preference for future upgrade.

### H. Code Forge & Review System

Ask which forge hosts the code and how change requests work there. The review terminology and helper CLI differ per forge:

1. **GitHub** *(default)* — Pull Request (PR), `gh` CLI.
2. **GitLab** — Merge Request (MR), `glab` CLI.
3. **Bitbucket** — Pull Request (PR), Bitbucket CLI or API.
4. **Gerrit** — Change / Patchset, `git review` / Gerrit REST.
5. **Local-only / self-hosted** — no forge; change requests simulated via branches and local review markdown.
6. **Other** — user describes; plugin adapts.

Record the chosen forge and its review-artifact name (PR / MR / Change). Downstream docs, helper scripts, and agent prompts substitute the correct term. The three mandatory reviewer lenses (code quality / architectural alignment / requirements alignment) remain identical across forges.

### I. Code Quality Automation (two layers — set independently)

> **Default policy**: pre-commit ON, CI OFF. atelier does NOT generate `.github/workflows/` (or equivalent) by default — the user opts in to CI explicitly. This avoids generating cost-bearing infrastructure for users who don't yet know whether their repo will be public/private, paid/free tier, etc.

#### I.a Pre-commit policy (local, no cost)

Ask which pre-commit level (one question, with the default highlighted):

1. **None** — rely on reviewer judgment only.
2. **Format only** — formatter (Prettier / Black / gofmt / rustfmt).
3. **Format + Lint** *(default recommendation)* — formatter + linter (ESLint / Ruff / golangci-lint / Clippy).
4. **Format + Lint + Test** — + fast unit tests on commit.
5. **Full** — + type-check + secrets scanner.

Also capture: tool selection (auto / pre-specified), failure behavior (auto-fix / block / warn).

#### I.b CI policy (forge-side, may incur cost) — opt-in

Ask which CI level (default is **None** — atelier does NOT generate CI yaml unless user picks otherwise):

1. **None** *(default — no CI yaml generated)* — pre-commit only. CI can be added later via `/atelier:escalate software-architect "enable CI"`.
2. **Minimal** — PR-only, single Python version, ubuntu-latest, timeout 3min, aggressive caching, paths-ignore for docs. Targets free-tier private repos (≤60 min/month typical).
3. **Standard** — PR + push:main, single platform, basic matrix optional. Public repos or paid plans.
4. **Full** — multi-platform matrix, security scans, coverage gate, scheduled runs. Public repos or generous budgets.
5. **Custom** — user specifies triggers/jobs.

If user picks ≠ None, also capture:
- **Cost sensitivity** (high / medium / low). High → Architect enables aggressive caching, paths-ignore, single matrix, timeout caps.
- **Repo visibility** (public — Actions free unlimited / private — counts toward 2000-min free tier).
- **Trigger events** (pull_request / push:main / push:any / workflow_dispatch / schedule).

Software Architect will include concrete tooling in `docs/design/tech-stack.md` and (if I.b ≠ None) generate the CI yaml. QA Engineer enforces pre-commit green on every PR; CI green only if I.b ≠ None.

Once A–I are captured, write `docs/templates/operating-preferences-template.md` and show the summary to the user for confirmation before moving on.

---

## STEP 1 — Requirements Interview (Product Manager)

Invoke the `product-manager` agent. Depth depends on mode:

- **Quick**: PM derives requirements from the STEP 0.5 one-paragraph brief; presents the derived requirements doc; asks user "anything missing or wrong?" in one turn.
- **Standard** *(default)*: 3 consolidated rounds — (1) Vision + Users + Stakeholders, (2) Features + Success Criteria, (3) Constraints + Existing Solutions. One question per turn within each round. ~10-15 turns total.
- **Thorough**: 6 rounds as defined in `discovery-interview-guide.md`, one question per turn. ~25-30 turns total.

Coverage in all modes:

- **Vision & Purpose** (why this project exists)
- **Target Users & Stakeholders**
- **Core Features & Deliverables** (what to ship)
- **Success Criteria** (measurable)
- **Constraints** (budget, time, regulatory, tech)
- **Existing Solutions** (what's already out there; differentiation)

Artifacts:
- `docs/requirements/vision.md`
- `docs/requirements/requirements.md`
- `docs/requirements/stakeholders.md`
- `docs/requirements/success-criteria.md`
- `docs/requirements/constraints.md`

Before moving on, confirm with the user that the requirements faithfully capture their intent.

---

## STEP 2 — Technical Design (Software Architect)

Invoke the `software-architect` agent. It proposes:

- **Technology Stack** (honoring STEP 0.5 B preferences)
- **System Architecture**
- **Data Model**
- **Folder Structure**
- **Integration Points**
- **ADRs** for significant decisions

Software Architect also produces the **CI configuration and pre-commit setup** matching the forge (STEP 0.5 H) and the quality-automation level (STEP 0.5 I). See `docs/process/code-quality-automation.md` and `docs/process/code-quality-automation.md`.

Artifacts:
- `docs/design/tech-stack.md`
- `docs/design/architecture.md`
- `docs/design/data-model.md`
- `docs/design/folder-structure.md`
- `docs/design/integrations.md`
- `docs/ssot/decisions/adr-NNN-*.md`
- CI config file (GitHub Actions `.github/workflows/ci.yml` / GitLab `.gitlab-ci.yml` / forge-equivalent)
- Pre-commit config (`.pre-commit-config.yaml` or stack-equivalent)

Have Product Manager challenge any mismatch with requirements. Resolve before moving on.

---

## STEP 3 — Agent Team Design + Capability Survey (Chief AI Officer)

Invoke the `chief-ai-officer` agent. STEP 3 has **two sub-phases**:

**3a. Capability Survey (discovery, before deciding team)**

Per `docs/process/capability-management.md` four-step reuse audit, CAIO runs:
1. **Inventory** existing capabilities — bundled atelier skills (`skills/`), user-installed plugins (`/plugin` listing), MCP servers (`.mcp.json`).
2. **Search externally** — Anthropic Skills marketplace (`anthropics/skills`), modelcontextprotocol.io, public MCP registries, community plugin marketplaces.
3. **Evaluate** each candidate — fit ≥ 80%, maintenance, license, security.
4. **Decide path per need** — reuse / extend / create.

CAIO produces a **capability survey table** in chat:

| Need | Existing match? | Path | Source/Citation |
|---|---|---|---|
| LLM API call | Anthropic Skills `chat-completion` | reuse | github.com/anthropics/skills/... |
| GitHub PR ops | atelier bundled `bin/atelier-open-pr` | reuse | atelier plugin |
| Web search for trend | none with adequate fit | create skill `web-search-trends` | (no candidate) |
| Slack notify | Slack MCP | extend (project config) | github.com/.../slack-mcp |

This survey precedes team design — it grounds the team's tooling.

**3b. Agent Team Design**

CAIO decides:

- Which implementation agents to create (per `docs/process/agent-team-sizing.md`)
- Persona, inputs, outputs, collaboration for each
- Execution flow (who does what, in what order)
- Escalation rules (when to re-activate Phase 1 agents)

Authoring discipline at STEP 3 — involvement-aware (see `agents/chief-ai-officer.md` for full procedure). The design-review step is always preserved; only its placement shifts.

- **Fully Autonomous** (level 1): self-review → write → 1-line summary per agent.

- **Milestone Checkpoints / PR-Level** (levels 2–3, **default — batched propose + cross-agent challenge**):
  1. CAIO determines team + self-reviews (7-point checklist).
  2. **Batched propose** — one chat message with team table + full proposed file content for each agent as code blocks. *Nothing written yet.*
  3. **Cross-agent challenge** in the same chat: PM (covers requirements?), Architect (consistent with design?), PMO (deliverable on schedule?) — each 1-line verdict + concrete objection if any.
  4. CAIO incorporates valid critiques.
  5. **User intervention window**: stay silent / continue → CAIO writes; object → CAIO revises; reject → return to step 1.
  6. Write all files to `.claude/agents/<name>.md` + index.
  7. Canonical user sign-off remains at STEP 5.5.

- **Detailed Supervision** (level 4): spec-first flow.
  1. Propose each agent in chat as a code block (full file content) + trigger. **No file written yet.**
  2. Wait for explicit per-agent approval.
  3. Then write to disk + index.

Across all levels, design review exists. The difference is whether the spec is *in chat* (levels 2–3 post-hoc, level 4 pre-write) or *internal to CAIO* (level 1 self-review only). No separate spec file at any level.

Artifacts produced:
- `<user-project>/.claude/agents/<name>.md` per agent (the canonical, approved file)
- `docs/agents/team-composition.md` — table (Agent | Trigger | 1-line justification | File path)
- `docs/agents/capability-log.md` — append-only event log
- `docs/flows/agent-document-map.md`, `docs/flows/agent-document-map.md`

`docs/agents/agent-specs/` is *not* part of the v0.1.1+ output schema — the executable file IS the human-readable spec.

Software Architect challenges whether the team can execute the design. Resolve before moving on.

---

## STEP 4 — Roadmap Construction (Project Manager)

Invoke the `project-manager` agent. It produces:

- Milestones mapped to success criteria
- Tasks small enough to fit one PR each
- Dependency graph
- Risk register
- Honors the user's involvement level — if "Milestone Checkpoints" or stricter, milestones are explicit approval gates.

Artifacts:
- `docs/roadmap/roadmap.md`
- `docs/roadmap/milestones/m<NN>-<slug>.md`
- `docs/roadmap/tasks/t<NN>-<slug>.md`
- `docs/roadmap/risks.md`
- `docs/roadmap/dependency-graph.md`

Chief AI Officer challenges whether the team can actually deliver the roadmap. Resolve before moving on.

---

## STEP 5 — Documentation Consolidation (Technical Writer)

Invoke the `technical-writer` agent. It:

- Ensures every `docs/` folder has a current `README.md`.
- Cross-references all artifacts.
- **Generates the project's `CLAUDE.md`** by filling `docs/templates/project-claude-template.md` with values from STEP 0.5/1/2/3 — this becomes the Conductor's runtime manual for the project. (Note: this is *separate* from atelier's own `CLAUDE.md`, which is maintainer-facing; the project gets its own.)
- Builds `docs/ssot/glossary.md`.

Artifacts:
- `docs/README.md` and all subfolder `README.md` files updated
- `CLAUDE.md` updated
- `docs/ssot/glossary.md`

---

## STEP 5.5 — Final Approval Gate ★ (User signs off here)

Before Phase 2 can begin, you present a **consolidated summary** to the user and obtain explicit approval.

Produce a single approval document `docs/INIT-APPROVAL.md` containing:

1. **Vision & Success Criteria** (from STEP 1)
2. **Tech Stack & Architecture Summary** (from STEP 2)
3. **Agent Team Composition** (from STEP 3) — listed by real job title with the specialization justification for each
4. **Roadmap Overview** (from STEP 4) — milestones with target completion order
5. **Operating Preferences** (from STEP 0.5) — involvement level, methodology, test coverage target, review strictness
6. **Key Risks** (top 3-5 from the risk register)

Present this summary to the user. Ask:

> "Ready to start Phase 2 (execution)? If you want to adjust any part — requirements, tech, team, roadmap, preferences — name which one and we'll re-open that step."

- **User says "proceed" / "go" / equivalent** → transition all Phase 1 agents to STANDBY and start Phase 2.
- **User requests changes** → re-invoke the relevant Phase 1 agent, then return to STEP 5.5.

Do not begin Phase 2 without an explicit user approval recorded in `docs/INIT-APPROVAL.md` (append a final line: `Approved by user: <yyyy-mm-dd>`).

---

## STEP 6 — Handoff to Phase 2

Once approved:

1. Initialize git with `git-flow` structure: create `main` and `develop` branches.
2. Make the initial commit with the full `docs/` tree and plugin-generated scaffolding.
3. Switch all Phase 1 agents to STANDBY (they only re-activate on escalation — see `docs/flows/agent-document-map.md`).
4. Project Manager selects the first task from the roadmap and assigns it to the appropriate implementation agent.
5. The implementation agent creates `feature/<task-id>-<slug>`, begins work, and the PR-based execution cycle starts.

Phase 2 is governed by `docs/process/change-review-workflow.md`. Your role as Conductor continues: route tasks, monitor blockers, and honor the user involvement level for checkpoint decisions.

---

## Error Handling & Escalation

- If an agent produces an artifact that contradicts a prior artifact, pause and have the relevant agents reconcile before continuing.
- If the user changes their mind at any step, unwind to that step and re-run forward.
- If the user asks to skip a step, warn them of the downstream risk and record the decision in `docs/ssot/decisions/`.

## Anti-Patterns (forbid these)

- Skipping STEP 0.5 and assuming defaults.
- Writing code or creating feature branches before STEP 5.5 approval.
- Allowing any agent to invent its own job title (must be from `docs/process/agent-team-sizing.md`).
- Abbreviating Product Manager or Project Manager as "PM" anywhere.
