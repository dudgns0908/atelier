---
name: add-mcp
description: Add a new MCP server to the project mid-project. Wraps the capability-management procedure — external MCP search, ADR draft, .mcp.json update, user install instructions, and capability-log entry. User approval is mandatory regardless of involvement level. Use when an authorized agent identifies a missing external integration.
---

# Add an MCP Server

You are the Conductor (or a delegated authorized agent) orchestrating MCP server addition. MCP servers add privileged surface area (network access, secrets, tool execution), so this flow has stricter gates than skill creation.

## Authorization

Only these agents may invoke this skill:
- `chief-ai-officer`
- `software-architect`
- `tech-lead` (infrastructure additions only)

All other agents must escalate.

## Invocation

```
/atelier:add-mcp <mcp-name> "<reason>"
```

- `<mcp-name>` — the MCP server identifier (e.g., `@modelcontextprotocol/slack`).
- `<reason>` — one sentence explaining the capability gap.

## Workflow

### 1. Reuse audit (mandatory)

Per `docs/process/capability-management.md`. Especially check:
- **Anthropic-curated MCP catalog** at modelcontextprotocol.io.
- **Community marketplaces** the user has configured.
- **Existing `.mcp.json`** entries — is something already covering this need?

Record the audit evidence.

### 2. Search externally

Use WebFetch / WebSearch to find candidates:
- modelcontextprotocol.io official directory.
- GitHub topic `mcp-server`.
- The vendor's official repo (e.g., for Slack, Jira, Notion).

Evaluate each: maintenance status, license, security review, auth model.

### 3. Draft an ADR (mandatory — never optional)

Create `docs/ssot/decisions/adr-NNN-mcp-<name>.md` from the template in `docs/README.md#ssot-schema`. Required content:

- **Status**: Proposed.
- **Context**: capability gap and why no existing tool fits.
- **Decision**: which MCP server, version, install method.
- **Consequences**: privileged surface added, secrets required, alternatives rejected.
- **Alternatives Considered**: candidates from the audit, with rejection reasons.

### 4. User approval — MANDATORY

Show the user:
- The proposed MCP server (name, source repo, license).
- The privileged surface (network domains, file system access, tool list).
- Required secrets / tokens.
- The drafted ADR.

Ask:
> "Approve adding `<mcp-name>` to this project's MCP servers?"

Do NOT proceed without explicit approval, regardless of involvement level (Fully Autonomous still requires approval here).

### 5. Update `.mcp.json`

Once approved, add the MCP entry to the project's `.mcp.json`. Reference secrets by environment variable name only — the user installs and configures the actual secrets in their MCP configuration, not in repo files.

### 6. Provide install instructions to the user

Print the exact commands the user must run, e.g.:

```bash
# Install the MCP server
npm install -g @modelcontextprotocol/slack

# Configure auth (user fills with real token)
export SLACK_BOT_TOKEN="<your-token>"

# Reload Claude Code plugins
/reload-plugins
```

The agent does NOT run install commands itself — MCP installation is a user-privileged action.

### 7. Capability-log entry

Append to `docs/agents/capability-log.md`:

```markdown
| <YYYY-MM-DD> | mcp | <mcp-name> | <invoking-agent> | <reuse audit summary> | <one-sentence justification> | adr-NNN |
```

### 8. ADR status update

Once user has installed and reloaded, update the ADR status: `Proposed` → `Accepted`.

## Anti-patterns

- Adding an MCP without an ADR.
- Bypassing user approval (Fully Autonomous level does not waive this gate).
- Running `npm install` / equivalent on the user's behalf for MCP servers.
- Storing secrets in repo files instead of referencing env-var names.
- Adding an MCP whose purpose duplicates an existing one.
- Skipping the privileged-surface disclosure.

## Compound-churn cap

If more than 2 MCP additions occur within a single milestone, Chief AI Officer is automatically re-invoked at the next `milestone-checkpoint` to review whether the project's external dependency footprint has grown unhealthily.

## Reference Documents

- `docs/process/capability-management.md`
- `docs/README.md#ssot-schema`
