# Agent Communication Patterns

How agents talk to each other in atelier — the *protocol*, not just the sequence.

This document complements the three flow diagrams (`initialization-flow.md`, `execution-flow.md`, `escalation-flow.md`) by making the **communication contract** explicit.

---

## Foundational Principle — All Communication Routes Through Conductor

```
                        [User]
                          │
                          ▼
                     [Conductor]              ← all routing happens here
                  ╱   │   │   │   ╲
                 ▼   ▼   ▼   ▼    ▼
          [PM] [Architect] [CAIO] [PMO] [Tech Writer] ...
          (8 specialist agents — never talk to each other directly)
```

**Rule**: agents do NOT message each other directly. Every cross-agent message — challenge, hand-off, comment — goes through Conductor as routing layer.

**Why**:
- Single point of orchestration → predictable order, no race conditions.
- Audit trail — every interaction visible in the main thread.
- No emergent agent-to-agent loops or echo chambers.
- Conductor can apply involvement-level policy uniformly.

**Exception**: cross-agent challenges within a single chat message (STEP 2 / 3 / 4 in Phase 1) appear as if agents converse, but they are *Conductor inviting peers to challenge in sequence within one routed exchange*. Still Conductor-mediated.

---

## Communication Surfaces

There are three surfaces by which information moves between agents:

### 1. Conductor invocation (synchronous, ephemeral)
Conductor invokes a specialist with a brief: *"Run STEP 2. Inputs: docs/requirements/. Output: docs/design/*."*
The specialist runs, returns control, often with a chat message summarizing what they did.

### 2. Documents on disk (asynchronous, durable)
Every artifact lives in `docs/*` or `.claude/agents/*`. Subsequent agents read these files. This is the **primary** communication channel — durable, reviewable, version-controlled.

### 3. Chat messages (synchronous, conversational)
- Visible to the user (transparency).
- Used for cross-agent challenges, proposals (Detailed Supervision), summary reports, escalations.
- Ephemeral but recorded in the conversation log.

→ **Documents > chat > invocation** in terms of authority. Disagreements are resolved by reference to documents, not chat memory.

---

## 5 Canonical Scenarios

### Scenario 1 — Phase 1 hand-off chain (STEP 0 → 5.5)

```
User /atelier:init-project
   ▼
Conductor: "STEP 0 detected empty dir. STEP 0.5 — defaults snapshot. ..."
   ▼ user replies
Conductor invokes Product Manager
   ▼
Product Manager interviews user, writes docs/requirements/*
   ▼ "STEP 1 done"
Conductor invokes Software Architect
   ▼ reads docs/requirements/*, writes docs/design/* + ADRs
   ◀── Conductor invites Product Manager to challenge ("requirements 정합?")
Software Architect responds in chat to PM's concrete objection
   ▼ "STEP 2 done"
Conductor invokes Chief AI Officer
   ▼ batched propose in chat (full file content of N agents)
   ◀── Conductor invites PM/Architect/PMO challenges in same chat
   ◀── User can object during this window
   ▼ CAIO incorporates feedback, writes .claude/agents/*
   ▼
Conductor invokes Project Manager
   ▼ writes docs/roadmap/*
   ◀── Conductor invites CAIO challenge ("팀이 일정 감당?")
   ▼
Conductor invokes Technical Writer
   ▼ updates all README + glossary + CLAUDE.md
   ▼
Conductor: writes INIT-APPROVAL.md, presents 6-section summary to user
   ▼ user "proceed"
Conductor: appends "Approved by user: <date>" → 6-file gate satisfied → Phase 2
```

**Communication characteristics**:
- Sequential STEPs (no parallelism in Phase 1).
- Each STEP's specialist reads prior STEP's docs, writes own.
- Cross-agent challenges happen in chat, not via doc.
- All routing is Conductor's; no agent invokes another agent.

### Scenario 2 — Phase 2 single-PR cycle

```
Project Manager (active for routing): selects t<NN> from roadmap
   ▼ writes status: assigned in docs/roadmap/tasks/t<NN>-*.md
Conductor invokes implementation agent (e.g., backend-engineer)
   ▼ implementer reads task + docs/design/* + docs/roadmap/lessons-learned.md
   ▼ git checkout -b feature/t<NN>-* (6-file gate verified)
   ▼ implements, commits (Conventional Commits + pre-commit hook)
   ▼ pushes
   ▼ atelier-open-pr (task-file gate verified)
Conductor invokes 3 reviewers in parallel
   ├── Senior Software Engineer reads diff + linked task + review-checklists.md
   ├── Tech Lead reads diff + docs/design/* + team-composition.md
   └── QA Engineer reads diff + linked task + docs/requirements/*
Each reviewer leaves substantive comment(s) in PR + verdict
   ▼ if any REQUEST_CHANGES → implementer iterates → re-review loop
   ▼ unanimous APPROVE
Conductor: atelier-check-reviews (forge API verification)
   ▼ unanimous confirmed
Conductor: forge merge command
   ▼ PostToolUse hook auto-fires
   ▼ atelier-post-merge (git pull, branch cleanup)
Technical Writer auto-activated (Continuous Freshness Workflow)
   ▼ inspects diff, updates affected docs/, glossary, ADRs, CHANGELOG
   ▼ ready for next task
Project Manager selects next task → cycle repeats
```

**Communication characteristics**:
- Parallel reviewer invocation (no order between SSE / TL / QA).
- Reviewer-to-implementer communication = via PR comments, *not* direct chat.
- Implementer responds with new commits, not chat (PR is the channel).
- Technical Writer is *automatically* invoked by hook, not by Conductor.

### Scenario 3 — Cross-agent challenge in Phase 1 STEP 3

```
CAIO: "Team proposal — 3 agents. [code blocks]. PM/Architect/PMO 검토 부탁."
   ▼ Conductor routes to PM, Architect, PMO sequentially in same chat thread
PM (in chat):       "✓ requirements 커버. but X 누락 가능성, persona Y 추가 권고"
Architect (in chat): "✓ design 정합. config 모듈은 cli-engineer가 흡수 권고"
PMO (in chat):      "⚠️ 일정 빠듯. 분배 권고"
   ▼ Conductor passes critique to CAIO
CAIO updates proposal in chat (revised code blocks)
   ▼ User can object (involvement level dependent)
   ▼ Conductor: "no objection. proceeding."
CAIO writes files
```

**Communication characteristics**:
- All three peers visible in same chat thread.
- Each peer's verdict is a single chat message — concise, concrete.
- Agents don't address each other ("@PM"); each addresses Conductor with a verdict.
- CAIO's revision is also addressed to Conductor, who relays.

### Scenario 4 — Escalation (Phase 2 → Phase 1)

```
backend-engineer mid-task: detects design assumption needs change
   ▼ implementer reports to Conductor in chat (no direct call to Architect)
Conductor: pauses Phase 2, runs /atelier:escalate software-architect
   ▼ writes docs/flows/escalation-log.md
Conductor invokes Software Architect (re-activates from STANDBY)
   ▼ Architect reads current design + escalation reason + implementer's evidence
   ▼ analyzes, decides
   ▼ writes updated docs/design/* + new ADR
   ▼ reports decision in chat to Conductor
Conductor: relays decision to implementer, resumes Phase 2
   ▼ Architect returns to STANDBY
implementer continues task with updated design
```

**Communication characteristics**:
- Implementation agent never directly invokes Phase 1 agent — must go through Conductor.
- Escalation log is the durable record (chat may be compacted).
- ADR is the authoritative decision (chat justification optional).
- Resuming Phase 2 is Conductor's decision, not the escalated agent's.

### Scenario 5 — Tech Lead's team-boundary catch (CAIO indirectly involved)

```
backend-engineer PR includes UI template changes (out of declared boundary)
   ▼ PR submitted via atelier-open-pr
   ▼ Conductor routes to 3 reviewers
Tech Lead reads diff:
   - architectural alignment ✓
   - team-boundary ✗ (per docs/agents/team-composition.md, frontend is CLI engineer's)
   ▼ Tech Lead leaves PR comment: "REQUEST_CHANGES — out-of-scope. Split or escalate to CAIO."
   ▼ implementer reads comment in PR, decides
implementer (Option A): split the PR
   ▼ removes UI changes from this PR, asks Conductor for follow-up task
   ▼ Conductor routes to Project Manager → new task assigned to cli-engineer
implementer (Option B): if scope is genuinely ambiguous
   ▼ requests Conductor: "/atelier:escalate chief-ai-officer 'team-boundary clarification'"
   ▼ CAIO re-activates, examines team-composition.md, decides
   ▼ if team needs adjustment → updates team-composition.md + .claude/agents/*
```

**Communication characteristics**:
- Tech Lead's signal stays at the PR (durable forge artifact).
- CAIO is *only* involved if the implementer or Tech Lead explicitly escalates — most cases resolve without CAIO.
- Conductor mediates the escalation request, not the implementer directly invoking CAIO.

---

## Activation Frequency Matrix

| Agent | Phase 1 | Phase 2 default | Phase 2 trigger-only |
|---|---|---|---|
| Conductor | always active | always active | always |
| Product Manager | STEP 1 owner, challenger STEP 2 | STANDBY | escalate / milestone-checkpoint |
| Software Architect | STEP 2 owner, challenger STEP 3 | STANDBY | escalate / milestone-checkpoint |
| **Chief AI Officer** | **STEP 3 owner, challenger STEP 4** | **STANDBY** | **add-agent / add-mcp / escalate / hotfix-with-team-impact / milestone-checkpoint** |
| Project Manager | STEP 4 owner, active routing in Phase 2 | active (task selection) | always (per-task) |
| Technical Writer | STEP 5 owner | post-merge auto-fire | always (every merge) |
| Senior Software Engineer | — | per-PR reviewer | always (every PR) |
| Tech Lead | — | per-PR reviewer | always (every PR) |
| QA Engineer | — | per-PR reviewer | always (every PR) |
| Implementation agents (CAIO-made) | — | per-task implementer | always (assigned tasks) |

Conductor is the only entity always active; CAIO is the most STANDBY-leaning of all agents (Phase 1 STEP 3 + 5 trigger types).

---

## Forbidden Communication Patterns

These violate the protocol:

1. **Direct agent-to-agent invocation.** *"Software Architect, ask Tech Writer to update the glossary."* Wrong: Architect should report to Conductor; Conductor decides routing.

2. **Bypassing the document layer.** Disagreement resolved only in chat without updating the relevant doc. The doc must reflect the resolution; chat alone is ephemeral.

3. **Cross-Phase direct activation.** Implementation agent calling CAIO directly for team change. Must go through Conductor → escalate.

4. **Reviewer-to-implementer direct chat.** Review feedback goes in PR comments, not in chat threads outside the PR.

5. **Phase 1 agent silently reactivating mid-Phase-2.** Phase 1 agents are STANDBY by default in Phase 2; explicit trigger required (escalate / milestone-checkpoint / add-agent / hotfix-with-team-impact).

6. **Self-narrating without action.** An agent says it will do X without writing the corresponding artifact. Communication without artifact is noise.

---

## Common Anti-Patterns (and how to detect)

| Pattern | How to detect | Fix |
|---|---|---|
| Agents talking to each other "directly" in chat | Look for `@<agent-name>` style addressing without Conductor mediation | Re-route through Conductor |
| Decisions in chat but not in docs | Doc still says old behavior after chat resolution | Update doc *in this PR*, not "later" |
| CAIO invoked for every PR | activity log shows >5 CAIO activations / milestone | Tech Lead should own boundary checks; only escalate exceptional cases |
| Conductor authoring domain content | Conductor writes `docs/design/*` directly | Re-route to Software Architect |
| Reviewer leaving chat-only feedback | PR has no comments but chat has discussion | Move to PR comments for durability |
| Phase 1 agent making Phase 2 decisions | Architect dictating PR-level merge decision | Architect issues design guidance; Tech Lead enforces at PR |

---

## See Also

- `docs/flows/agent-document-map.md` — Phase 1 sequence (mermaid)
- `docs/flows/agent-document-map.md` — Phase 2 PR cycle (mermaid)
- `docs/flows/agent-document-map.md` — escalation routing (mermaid)
- `docs/flows/escalation-log.md` — append-only history of past escalations
- `CLAUDE.md` "Layer Model — User, Conductor, Agents" — foundational hierarchy
- `agents/chief-ai-officer.md` — CAIO's intentional STANDBY default in Phase 2
- `agents/tech-lead.md` — team-boundary delegation from CAIO
