---
description: Add a new project-specific agent mid-project, with Chief AI Officer drafting the definition and justification, and the user approving. Use when project scope expands (new domain emerges, a parallel track is needed, or critical expertise is missing) during Phase 2.
---

# Add a Project-Specific Agent

You are the Conductor. The user or an existing agent has identified a capability gap during Phase 2. You run the Chief AI Officer to produce a justified addition, then obtain user approval.

## Invocation

User invokes `/atelier:add-agent <proposed-title> <reason>`.

- `<proposed-title>` must be a real industry job title (see `docs/process/agent-team-sizing.md`).
- `<reason>` cites the capability gap.

## Workflow

### 1. Invoke Chief AI Officer

Provide:
- Proposed title and reason.
- Current `docs/agents/team-composition.md`.
- The triggering artifact (PR, task, escalation note).

### 2. Chief AI Officer Drafts

Chief AI Officer produces:
- **Specialization trigger citation** — exactly one of:
  - *Orthogonal domain*
  - *Critical expertise*
  - *Parallel track*
- **Gap analysis** — which existing agent "could but shouldn't" absorb this work, and why.
- **Agent file draft** — `<user-project>/.claude/agents/<kebab-title>.md` with persona, inputs, outputs, collaboration, reference docs.
- **Team-composition update** — amended `docs/agents/team-composition.md` with the new agent and justification row.
- **Flow update** — amended `docs/flows/agent-document-map.md` showing how the new agent fits.

### 3. Cross-Agent Review

Before presenting to user:
- **Software Architect** verifies the new agent aligns with architecture and tech stack.
- **Project Manager** estimates roadmap impact (does this add tasks? shift milestones?).

### 4. User Approval

Show the user:
- The proposed agent file.
- The trigger citation and gap analysis.
- Impact on roadmap (if any).

Ask:
> "Approve adding `<title>` to the team?"

- **Approve** → commit the new agent file and doc updates. Project Manager integrates the agent into upcoming task assignments.
- **Reject** → discard the draft. Log the rejection in `docs/agents/team-composition.md` under "Considered and declined".

## Rules

- **Refuse invented titles.** Chief AI Officer must map to a LinkedIn-grade real job title.
- **Refuse feature-level splits.** Adding `Backend Engineer (Billing)` alongside existing `Backend Engineer` requires proof of orthogonality, critical expertise, or parallel-track necessity.
- **Refuse duplicate roles.** If the proposed agent duplicates an existing responsibility, merge instead of add.
- **Cap on compound churn**: if more than one agent is added per milestone, flag team instability and escalate to user for a team review.

## Reference Documents

- `docs/process/agent-team-sizing.md`
- `docs/agents/team-composition.md`
- `docs/flows/agent-document-map.md`
