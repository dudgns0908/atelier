# Capability Management — Agent / Skill / MCP Reuse, Creation, Governance

`atelier`'s policy for adding new capabilities — **agents (roles)**, **skills**, **MCP servers**. Combines the *reuse-first* principle with a uniform *approval chain*.

> **Principle: reuse-first, create-last.** Audit existing options before authoring anything new. Document the audit. Never silently reinvent.

> **Principle: any-agent may propose; Tech Lead routes; CAIO approves.** Capability additions never sneak in via a single agent's unilateral decision.

---

## Approval Chain (uniform across agent / skill / MCP)

```
   Any agent detects a gap
            │
            ▼ proposes via /atelier:add-agent | add-skill | add-mcp
   ┌───────────────────────────┐
   │ Tech Lead (router)        │  ← validates reuse audit, scope, real gap
   │ • duplicate of existing?  │     non-duplicate, fit, security
   │ • reuse audit complete?   │
   │ • scope appropriate?      │
   └───────────┬───────────────┘
               │ forwards (or rejects with reason)
               ▼
   ┌───────────────────────────┐
   │ Chief AI Officer (final)  │  ← decides addition; authors agent files;
   │ • approves / rejects      │     writes ADR for MCPs; updates capability-log
   │ • drafts artifacts         │
   └───────────┬───────────────┘
               │
               ▼ involvement-level dependent
   ┌───────────────────────────┐
   │ User approval             │  ← MCP: ALWAYS. Agent/Skill: per level.
   └───────────┬───────────────┘
               ▼
       Capability live + capability-log entry
```

**Rules**:
- Phase 1 STEP 2/3 is the only context where Software Architect / CAIO bypass the proposer step (they ARE the initial discoverers).
- After Phase 1, **any agent** that discovers a gap mid-flight uses the chain above.
- Tech Lead may NOT skip CAIO. CAIO may NOT skip Tech Lead's validation when reactivated for a Phase 2 capability addition.
- `/atelier:add-agent`, `/atelier:add-skill`, `/atelier:add-mcp` skills enforce the chain procedurally.

---

## Who This Binds

- **Any agent** (Phase 1 or Phase 2) — may propose a capability addition when a gap is detected.
- **Tech Lead** — capability gap router during Phase 2; first validator in the approval chain.
- **Chief AI Officer** — final approver for capability additions; primary discoverer at STEP 3 (init) and `/atelier:milestone-checkpoint`.
- **Software Architect** — primary discoverer at STEP 2 (init) for tooling/MCP; may bypass chain at STEP 2 only.
- **Reviewers (Senior SW Engineer / QA Engineer)** — propose via comment on a PR ("missing capability X — Tech Lead, please route"); never author capability artifacts directly.
- **Product Manager / Project Manager / Technical Writer** — propose via chat; never author capability artifacts.

---

## Authorization Matrix

| Agent | Propose? | Validate (route)? | Final approve? | Author artifact? |
|---|---|---|---|---|
| Any agent (incl. implementation, reviewer) | ✅ | ❌ | ❌ | ❌ |
| Tech Lead | ✅ | ✅ | ❌ | ❌ (except own draft ADR) |
| Software Architect | ✅ (STEP 2 also primary discoverer) | ✅ (technical fit) | ❌ | ✅ (ADR, integration spec) |
| **Chief AI Officer** | ✅ (STEP 3 / milestone-checkpoint primary) | ✅ (team/capability fit) | ✅ | ✅ (`.claude/agents/*`, capability-log) |
| User | implicit (any time) | n/a | required for MCP always; per involvement-level otherwise | n/a |

---

## The Four-Step Reuse Audit (mandatory before any creation)

### 1. Inventory
List what's already available:
- **Installed plugins**: `/plugin` listing.
- **Installed MCP servers**: `.mcp.json` and global MCP config.
- **Installed skills**: `/help` or `~/.claude/skills/`.

### 2. Search externally
- **Anthropic Agent Skills marketplace** (`anthropics/skills`).
- **Community plugin marketplaces** the user has configured.
- **Public MCP registries** (modelcontextprotocol.io, GitHub `mcp-server` topic).
- **Industry libraries** for the chosen stack.

### 3. Evaluate each candidate
- **Fit**: covers ≥80% of the need?
- **Maintenance**: actively maintained?
- **Licensing**: compatible?
- **Security**: trusted publisher, auditable surface?

### 4. Decide
| Situation | Action |
|---|---|
| Perfect fit exists | **Reuse.** Add as dependency. Record in ADR. |
| Partial fit exists | **Extend** (fork or wrap). Record extension scope in ADR. |
| No acceptable fit | **Create.** ADR with "no acceptable alternative found" evidence. |

---

## Bundled and Optional Dependencies

`atelier` bundles `skill-creator` at `skills/skill-creator/` (Apache 2.0). No external install required for skill creation — agents invoke it as `/atelier:skill-creator` to draft new SKILL.md files.

Optional, only when the user opts in at STEP 0.5 G:
- Notification MCP (Slack / Discord) — user installs separately, configures via `.mcp.json`.

---

## Workflow — Adding a New Agent (role)

**Recommended path**: `/atelier:add-agent <title> "<reason>"`. Wrapper orchestrates.

Manual procedure:
1. **Proposer** (any agent) drafts gap statement: which work is unowned, why existing team can't absorb.
2. **Tech Lead** validates: against `docs/agents/team-composition.md` — is this a real gap or a duplicate? Sizing trigger satisfied (orthogonal domain / critical expertise / parallel track per `agent-team-sizing.md`)? Routes to CAIO with verdict.
3. **CAIO** decides: approve / revise / reject. If approved, drafts the agent file from `docs/templates/software-engineer-template.md` following STEP 3 authoring discipline (batched propose + cross-agent challenge per involvement level).
4. **User approval** — required for new agents at all involvement levels (team change is always user-visible).
5. **CAIO writes** `<user-project>/.claude/agents/<title>.md` + appends row to `docs/agents/team-composition.md` + `docs/agents/capability-log.md`.
6. User runs `/reload-plugins`.

---

## Workflow — Creating a New Skill

**Recommended path**: `/atelier:add-skill <name> "<reason>"`. Wrapper orchestrates the steps.

Manual procedure:
1. **Proposer** runs the four-step reuse audit. Documents candidates considered.
2. **Proposer** drafts proposal: purpose, trigger, inputs/outputs, why no existing skill fits, scope (project-only vs cross-project).
3. **Tech Lead** validates: reuse audit complete? Scope appropriate (project-only vs plugin-PR)? Forwards to CAIO with verdict.
4. **CAIO** decides: approve / revise / reject. If approved, invokes `/atelier:skill-creator` to draft SKILL.md.
5. **User approval** if involvement level ≥ Milestone Checkpoints.
6. Place at `<user-project>/.claude/skills/<name>/SKILL.md`. (Cross-project skills going back to `atelier` itself require a plugin PR.)
7. Append to `docs/agents/capability-log.md`.
8. User runs `/reload-plugins`. UserPromptSubmit hook reminds.

---

## Workflow — Adding a New MCP Server

**Recommended path**: `/atelier:add-mcp <name> "<reason>"`. Wrapper orchestrates.

Manual procedure:
1. **Proposer** runs the four-step reuse audit (especially modelcontextprotocol.io).
2. **Proposer** drafts proposal: server name, purpose, auth requirements, exposed commands, security implications.
3. **Tech Lead** validates: reuse audit complete, security surface acceptable, integration fit. Forwards to CAIO; Software Architect challenges in same chat for technical fit.
4. **CAIO** decides: approve / revise / reject. If approved, drafts the ADR.
5. **User approval REQUIRED** — MCPs add privileged surface area. User always approves regardless of involvement level.
6. User runs install commands. **Agents do not run `npm install` for MCPs without explicit user authorization.**
7. Update `.mcp.json`.
8. ADR mandatory: `docs/ssot/decisions/adr-NNN-mcp-<name>.md` (CAIO drafts; Architect co-signs).
9. Append to `docs/agents/capability-log.md`.
10. User runs `/reload-plugins`.

---

## Capability Log

At `docs/agents/capability-log.md` — append-only record:

```markdown
# Capability Log

| Date | Type | Name | Added by | Trigger | Justification | ADR |
|---|---|---|---|---|---|---|
| 2026-04-25 | skill | claim-ticket | backend-engineer | task-helper gap in T12 | no existing skill covers ticket-claim coordination | — |
| 2026-04-28 | mcp | slack-notifier | chief-ai-officer | STEP 0.5 G chose Slack | official slack MCP adopted | adr-007 |
```

---

## ADR Evidence Requirements

When the audit concludes "no acceptable alternative", the ADR must contain:
- Candidates considered (name + source).
- Fit assessment per candidate.
- The specific gap that forced a build decision.
- Scope of the new artifact.

This makes every "we built it" decision auditable.

---

## Anti-Patterns

- Custom HTTP client when an MCP server wraps the same API.
- Bespoke "requirements doc generator" skill when Product Manager already produces it.
- Hand-rolling a GitHub PR helper when a GitHub MCP exists.
- New agent whose responsibility overlaps an existing skill.
- Adding an MCP without user approval — even at Fully Autonomous involvement level.
- Bypassing the ADR requirement for MCPs.
- Agents creating plugin-level skills (those need a plugin PR, not a project addition).

---

## Governance Gate

At each `/atelier:milestone-checkpoint`, Chief AI Officer reviews `capability-log.md`. If a single milestone added more than **3 skills or 2 MCPs**, the team composition is flagged as potentially over-engineered — discuss with user.
