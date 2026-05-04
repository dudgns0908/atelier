# Flows

**Owner**: Conductor + Chief AI Officer.

Diagrams and narratives describing who does what, in what order, with which docs, and when to escalate.

## Files

| File | Contents |
|---|---|
| `agent-document-map.md` | **Master quick-reference**. Per-flow tables of agent × purpose × references × outputs. Visual ASCII walkthroughs for all four flows (Initialization / Execution / Escalation / Trigger-driven). Per-agent index. Forbidden patterns. **Start here.** |
| `agent-communication.md` | Protocol contract — Conductor-mediated routing, 5 canonical scenarios, forbidden patterns, anti-pattern detection. |
| `milestone-flow.md` | Per-milestone loop in detail (plan-milestone → tasks → 3-reviewer cycle → milestone-checkpoint retro → next-milestone or remediate or pivot). Sequence + decision-branch detail. |
| `escalation-log.md` | Append-only log of past escalations (created on first `/atelier:escalate` invocation). |

> v0.9 consolidation: the previous `initialization-flow.md`, `execution-flow.md`, and `escalation-flow.md` files were removed; their visual walkthroughs and mermaid diagrams are now consolidated into `agent-document-map.md` (which already serves as the master ref). Per-flow narrative depth on milestone-level mechanics lives in `milestone-flow.md`.

## Update Rules

- `agent-document-map.md` is the **single source of truth for the flow × agent × doc mapping**. Update it whenever a flow gains/loses a step, an agent's reference set changes, or a new trigger-driven skill is added.
- `milestone-flow.md` is updated when a milestone-level workflow changes (plan-milestone, milestone-checkpoint, retro structure).
- `agent-communication.md` is stable; updated only when the cross-agent protocol shape changes.
- `escalation-log.md` is logged by Conductor every time `/atelier:escalate` runs.
