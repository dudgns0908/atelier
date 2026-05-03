# Issue Management

How issues open, get triaged, and resolve in atelier-managed projects. The same protocol applies to atelier-itself maintenance and to user projects (with adapter differences for non-GitHub forges).

> **Single source of truth**: this document. Project Manager owns triage; Tech Lead consults on technical classification; Conductor mediates the routing as always.

---

## Three sources of issues

1. **External (community / stakeholder)** — opened via GitHub Issues directly using `.github/ISSUE_TEMPLATE/` forms.
2. **Internal (any Phase 2 agent)** — agent detects a gap mid-task; raises via `/atelier:add-*` chain (capability) OR opens a tracking Issue if it's a defect / drift signal.
3. **User direct** — `/atelier:hotfix "<description>"` for urgent operational items, or `gh issue create` for everything else.

---

## Templates (`.github/ISSUE_TEMPLATE/`)

| Template | Default label | Purpose |
|---|---|---|
| `bug_report.md` | `kind:bug` | Reproducible defect — code, hook, agent persona, doc claim. |
| `feature_request.md` | `kind:request` | New capability or enhancement proposal. |
| `docs_issue.md` | `kind:docs` | Doc gap, error, dead link, contradiction. |
| (Discussions) | — | Open-ended questions, design RFCs, governance proposals — not Issues. |

`config.yml` disables blank issues and routes security to `SECURITY.md`.

---

## Required label scheme

Every issue **must** have:

1. **One `kind:*` label** at intake — `kind:bug | kind:request | kind:docs | kind:question`. The template applies it; PM verifies.
2. **One `status:*` label** after triage — `status:triaged | accepted | deferred | rejected | resolved`.

Optional labels:

- **`priority:p0|p1|p2|p3`** — `p0` = production-blocker, `p1` = next milestone, `p2` = backlog, `p3` = nice-to-have.
- **`lane:backlog|todo|in-progress|in-review|done`** — set when an issue is promoted to a task (mirrors `docs/roadmap/tasks/t<NN>-*.md` lane frontmatter; v0.3.4).
- **`epic:<slug>`** — when the issue belongs to an epic group.
- **`blocked`** — depends-on unresolved.

---

## Lifecycle

```
                          ┌──────────────┐
                          │   OPENED     │  intake template applied
                          │  kind:* set  │
                          └──────┬───────┘
                                 ▼
                          ┌──────────────┐
                          │   TRIAGE     │  PM (+ Tech Lead consult)
                          │              │  status: → triaged
                          └──────┬───────┘
                                 ▼
                ┌────────────────┼────────────────────┐
                ▼                ▼                    ▼
        ┌─────────────┐  ┌─────────────┐    ┌────────────────┐
        │ ACCEPTED    │  │ DEFERRED    │    │ REJECTED       │
        │ → task      │  │ kind:        │    │ closed with    │
        │  created    │  │ milestone-   │    │ explanation    │
        │ → assigned  │  │ candidate    │    │                │
        └──────┬──────┘  │ (next plan-  │    │ status:        │
               │        │  milestone)  │    │ rejected       │
               │        └──────┬───────┘    └────────────────┘
               ▼               │
        ┌─────────────┐        │
        │ IN PROGRESS │        │
        │ lane:       │        │
        │ in-progress │        │
        └──────┬──────┘        │
               ▼               │
        ┌─────────────┐        │
        │ IN REVIEW   │        │  PR opened with `Closes #<N>`
        │ lane:       │        │
        │ in-review   │        │
        └──────┬──────┘        │
               ▼               │
        ┌─────────────┐        │
        │ RESOLVED    │◀───────┘  PR merged or close-with-explanation
        │ lane:done   │
        │ status:     │
        │ resolved    │
        └─────────────┘
```

---

## Triage protocol

Triage is **multi-agent discussion**, not PM-solo — same `proposer → cross-agent challenge → user-when-required` pattern as `/atelier:plan-milestone` and Phase 1 STEP 2/3/4.

### Who participates

- **Project Manager** = **proposer**. Reads the issue, drafts a triage decision (kind classification + status: accepted | deferred | rejected + priority + suggested target milestone).
- **Tech Lead** = **mandatory challenger** (in same chat). Concrete questions to answer:
  - Is this really `kind:bug` or a design smell?
  - If accepted, what's the architectural impact?
  - Sizing: does PM's "1 PR or split" assessment hold?
  - Module boundary: which agent's responsibility per `team-composition.md`?
- **CAIO** = **conditional challenger**. Engaged only if PM or Tech Lead surfaces a capability/team-composition concern (e.g., "this bug pattern keeps recurring → Security Engineer missing"). When engaged, may trigger parallel `/atelier:add-*` chain.
- **Conductor** = **router**, invokes the above sequentially in the same chat. Never triages itself.
- **User** = approves per involvement level (Detailed Sup → every triage; Milestone+ → only if scope-shifting; Fully Auto → log-only).

### Triage discussion shape (in chat)

```
PM (proposer):  "Issue #42 (kind:request) — proposed status:accepted, p2,
                 target m04. Maps to 1 task (~M size, backend)."
Tech Lead:       "✓ architectural fit. ✗ sizing — touches
                 services/auth/* AND services/billing/* in same PR;
                 split into t-*-auth and t-*-billing."
CAIO:            (silent — no team gap)
PM (revised):    "Updated — split into 2 tasks. status:accepted, target m04,
                 priority p2. Creating t41-..., t42-... in m04 backlog."
Conductor:       "User involvement = Milestone+ → no scope shift, no user
                 prompt needed. PM proceeding to write task files."
```

### When

- **Continuous (incoming, untriaged)**: PM polls `status:triaged` not yet set at start of each Phase 2 day or on-demand when `/atelier:status` flags them. Each triggers the multi-agent discussion above.
- **Batched at milestone start**: `/atelier:plan-milestone <m-id>` reads `kind:request` + `kind:bug` issues with `status:accepted` and integrates into the milestone task plan.
- **Batched at milestone end**: `/atelier:milestone-checkpoint` reviews `status:deferred` items — promote / defer further / reject (full multi-agent discussion if reclassifying).

### After acceptance — assign + execute

Once the triage discussion concludes `status:accepted` and a task file (`docs/roadmap/tasks/t<NN>-*.md`) is written, the issue enters the **execution path** identical to any other task:

1. PM moves the task to `lane:todo` (or directly `in-progress` if urgent / hotfix).
2. Conductor invokes the assigned **implementation agent** via Task subagent (e.g., `backend-engineer`, `frontend-engineer`, `product-designer`) — passing the task file path + linked issue number + acceptance criteria.
3. Implementation agent:
   - Branches `feature/t<NN>-<slug>` from `develop`.
   - Implements the task; commits with Conventional Commits.
   - Pushes; runs `atelier-open-pr`. PR body auto-includes `Closes #<issue>` (GitHub mode v0.3.4).
4. PR enters the **3-reviewer cycle** (Senior SW Engineer / Tech Lead / QA Engineer) per `change-review-workflow.md` and `review-checklists.md` Posting Protocol.
5. On unanimous APPROVE → forge merge → issue auto-closes → `lane:done` → `status:resolved`.

The Conductor does **not** tell the agent informally ("go fix #42"). The handoff is structured:
- Task file is the spec (frontmatter + body + AC checkboxes).
- Issue link is the traceability.
- Agent boundaries (per `team-composition.md`) decide who.

If no implementation agent matches the task (e.g., service-with-UI project gets a backend-only issue when only Frontend Engineer exists) — that's a CAIO escalation, not a workaround.

### Decision tree

```
At triage, PM asks: what kind, then what status?
```

#### `kind:bug`

| Severity / Reproducibility | Action |
|---|---|
| Production-blocker, reproducible | `priority:p0` + `status:accepted` → `/atelier:hotfix <issue#>` immediately. Hotfix branch + task md + 3-reviewer (expedited) gate. |
| Normal bug, reproducible | `priority:p1\|p2` + `status:accepted` → task created `docs/roadmap/tasks/t<NN>-fix-*.md` referencing the issue, scheduled per priority. |
| Cannot reproduce | Comment requesting reproduction details. After 14d of no response → `status:rejected`, close with "cannot reproduce, please reopen with repro steps". |
| Duplicate | `status:rejected` + comment linking the canonical issue. |

#### `kind:request` (feature)

| Vision alignment | Action |
|---|---|
| On-roadmap, fits current milestone | `status:accepted` → task created in current milestone or candidate list. |
| On-roadmap, future milestone | `status:deferred` + `kind:milestone-candidate` label → revisit at next `/atelier:milestone-checkpoint`. |
| Pivots scope | Escalate to Product Manager via `/atelier:escalate product-manager "<rationale>"`. PM decides; if rejected, `status:rejected` + comment. |
| Off-vision | `status:rejected` + comment with rationale citing `docs/requirements/vision.md`. |
| Needs more discussion | Convert to Discussion (link from Issue), close Issue. |

#### `kind:docs`

| Type | Action |
|---|---|
| Gap or error in existing doc | `status:accepted` → small task or direct PR (single-reviewer policy applies for docs-only per `CONTRIBUTING.md`). |
| Confusion (user didn't understand) | Triage as `kind:question` first; if answer reveals doc gap, reclassify back to `kind:docs` and create a doc improvement task. |
| Translation | `status:accepted`, low priority, community-contribution-welcome. |

#### `kind:question`

| Type | Action |
|---|---|
| Answerable in a comment | Answer; close with `status:resolved`. If answer reveals a doc gap → reclassify `kind:docs` and create a doc task. |
| Ongoing / open-ended | Convert to Discussion, close Issue. |

---

## Resolution rules

1. **Auto-close via PR is preferred** — PR body contains `Closes #<N>` (or `Fixes #<N>` for bugs). `atelier-open-pr` injects this automatically when a task has a mirrored issue (v0.3.4 GitHub mode).
2. **Manual close requires explanation** — never close without a comment stating reason (rejected / duplicate / cannot-reproduce / superseded-by-#<N>).
3. **Bug fix requires a regression test** — `kind:bug` issues only resolve when the closing PR includes a test that would have failed before the fix. QA Engineer enforces at PR review.
4. **Doc-implication check** — if resolving an issue changes documented behavior, the closing PR MUST update the affected doc in the same PR (Living Documentation principle, see `docs/process/living-documentation.md`).
5. **Issue → task linkage is bidirectional** — task md `frontmatter.linked_issue: <N>` field; Issue body `Tracking: docs/roadmap/tasks/t<NN>-<slug>.md`.

---

## Forbidden patterns

- Closing without explanation.
- Merging a fix-PR that doesn't link the issue.
- Closing a `kind:bug` without a regression test.
- Accepting a `kind:request` without writing it into the roadmap or milestone candidate list.
- Triaging in chat without applying the `status:*` label (the label is the audit trail).
- Bypassing PM triage by directly creating a task — issues from external sources MUST go through triage so PM can decide acceptance.
- Letting an issue sit `status:triaged` without progressing — at every `/atelier:status` invocation, PM surfaces aged-triaged-no-progress issues.

---

## Aging policy

| State | Soft-warn after | Action |
|---|---|---|
| `status:triaged` (no further movement) | 7d | PM reviews; either accept-and-task, defer with reason, or reject. |
| `status:accepted` not lane-promoted | 14d | PM verifies; either move to current milestone or defer. |
| `status:deferred` (`kind:milestone-candidate`) | next milestone-checkpoint | Auto-surfaced at retro; promote / defer further / reject. |
| Awaiting reproduction (`kind:bug`) | 14d no response | Auto-close with comment "cannot reproduce". |

`/atelier:kanban` Signals block surfaces aged in-progress tasks (default >3 days without commit). For issues themselves, dashboards can poll `gh issue list --json updatedAt,labels` and apply the table thresholds above.

---

## Forge adapters

| Forge | Mechanism |
|---|---|
| **GitHub** *(primary in v0.3.4)* | `gh issue list/create/edit`. Labels per scheme above. Optional Projects v2 board for kanban view (STEP 0.5 H.1). |
| **GitLab** *(v0.5+)* | `glab issue list/create/edit`. Same label scheme; GitLab Issue Boards. |
| **Bitbucket / Gerrit / local-only** | Falls back to `docs/roadmap/issues/<NN>-<slug>.md` files (deferred to v0.5+). |

---

## See also

- `.github/ISSUE_TEMPLATE/` — intake forms.
- `skills/hotfix/SKILL.md` — bug-issue → hotfix path.
- `skills/milestone-checkpoint/SKILL.md` — milestone-end issue triage of `status:deferred`.
- `docs/process/change-review-workflow.md` — PR side of resolution.
- `docs/process/living-documentation.md` — same-PR doc-update rule.
- `docs/flows/milestone-flow.md` § Implement — issue close-via-PR mechanics.
- `agents/project-manager.md` — PM persona + triage responsibility.

---

## Language

Issue body and labels in **English** (artifact). User-facing comments in user's language is OK when stakeholder is non-English; PM translates key decisions to English in a closing comment for cross-team auditability.
