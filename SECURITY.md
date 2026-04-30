# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in `atelier`, **do not file a public issue**. Public disclosure before a fix is available could put users at risk.

Instead, report the vulnerability privately:

- **Email**: `security@<maintainer-domain>` *(replace with actual contact at v1.0)*
- **GitHub**: use [Private Vulnerability Reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing/privately-reporting-a-security-vulnerability) on the repository if available.

Include:
- A description of the vulnerability and its potential impact.
- Steps to reproduce.
- Affected versions.
- Any proposed mitigation, if you have one.
- Whether you have shared the issue with anyone else.

## Response Timeline (target)

| Stage | Target |
|---|---|
| Acknowledgement | Within 3 business days |
| Initial assessment | Within 7 business days |
| Coordinated disclosure plan | Within 14 business days |
| Fix released for supported versions | Severity-dependent (Critical: ≤14 days; High: ≤30 days; Medium/Low: next minor) |

## Supported Versions

| Version | Supported with security fixes |
|---|---|
| 1.x (current major, once GA) | ✅ |
| 0.x (pre-GA) | Best-effort; upgrade to current minor recommended |

When v1.0 ships, the previous major (0.x) will receive critical-only fixes for 6 months.

## Severity Classification

We follow a CVSS-inspired internal rubric:

| Severity | Examples |
|---|---|
| **Critical** | Hook bypass that allows force-push or unreviewed merge to `main`; arbitrary code execution via skill or agent invocation; secret leakage from the plugin into logs. |
| **High** | Logic flaw allowing PR merge without unanimous approval; privilege escalation in MCP wrapper; auth-token capture in `bin/` scripts. |
| **Medium** | Information disclosure of project metadata; denial-of-service through hook misuse; misconfigured permissions in `settings.json`. |
| **Low** | Local-only issues, predictable warnings, doc inaccuracies that mislead about security posture. |

## Coordinated Disclosure

Our default approach is **coordinated disclosure**:

1. We receive your report and acknowledge.
2. We confirm and assess severity.
3. We develop and test a fix.
4. We agree on a release date with you.
5. We publish the fix and a security advisory simultaneously.
6. We credit you in the advisory unless you prefer anonymity.

We aim to publish advisories within 90 days of report. If a vulnerability is being actively exploited in the wild, we may shorten the disclosure window.

## Hall of Thanks

Researchers who report valid vulnerabilities are credited (with permission) in the GitHub security advisories and in the corresponding GitHub Release notes (atelier-itself ships no CHANGELOG; release history lives on the forge).

## Out of Scope

The following are not vulnerabilities in `atelier`:

- Bugs in `skill-creator` (bundled from upstream `anthropics/skills`) — report those upstream.
- Bugs in Claude Code itself.
- Bugs in third-party MCP servers a user installs.
- "Issues" that require an attacker to already have full local shell access.
- Social-engineering attacks on contributors.

If you are unsure whether your finding is in scope, report it privately and we will route appropriately.
