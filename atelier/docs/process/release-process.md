# Release Process

Authoritative process for `develop → main` promotion, tagging, and release notes. Invoked via `/atelier:release`.

> **Audience**: this document is for **user projects** that adopt atelier. atelier-itself follows a similar but lighter flow — see `meta/README.md` (no CHANGELOG; GitHub Releases for history; per-version migration in `upgrade-guide.md` + `breaking-changes.md`).

## Versioning

SemVer: `MAJOR.MINOR.PATCH`.

| Bump | Trigger |
|---|---|
| MAJOR | Breaking API or behavior change. Requires explicit user confirmation and a migration ADR. |
| MINOR | New feature, backward compatible. |
| PATCH | Bug fix only (usually originated from a hotfix). |

## Cadence

- **Milestone-aligned** *(default)* — one release per milestone.
- **Time-based** — fixed cadence (e.g., biweekly); user configures in `operating-preferences-template.md` overrides.

## Release Checklist

- [ ] Milestone marked complete by Project Manager.
- [ ] `milestone-checkpoint` approved by user.
- [ ] CI green on `develop` head.
- [ ] All hotfixes since last release are back-merged to `develop`.
- [ ] CHANGELOG entry drafted (Technical Writer) — *only if the project maintains a CHANGELOG; otherwise GitHub/GitLab Release notes serve the same purpose*.
- [ ] Version bumped in relevant package manifests (if the stack has one: `package.json`, `Cargo.toml`, `pyproject.toml`, etc.).
- [ ] Release change request opened (`develop → main`).
- [ ] Three-reviewer unanimous approval.
- [ ] Merge to `main` (no source-branch deletion — `develop` stays).
- [ ] Tag `vX.Y.Z` created and pushed.
- [ ] Release notes published on forge.
- [ ] Roadmap milestone marked as released.
- [ ] Lessons-learned updated.

## Forge-Specific Release Publishing

| Forge | Command |
|---|---|
| GitHub | `gh release create vX.Y.Z --notes-file <path>` |
| GitLab | `glab release create vX.Y.Z --notes "..."` |
| Bitbucket | manual via web UI or API |
| Gerrit | tag only (no release-notes primitive); publish to separate channel |
| Local-only | record only in `CHANGELOG.md` |

## Migration Notes (MAJOR releases)

- Document each breaking change with before/after snippets.
- Provide a migration script when automation is possible.
- Include explicit version-gate in runtime code if feasible.

## Rollback

If a released version must be rolled back:
1. Revert the release merge on `main` in a new change request.
2. Tag the reverted state as `vX.Y.Z+1` with a `revert-of` note.
3. Run postmortem (see hotfix skill step 8).
4. Re-release with fix once ready.

## Reference

- `skills/release/SKILL.md` — the skill that runs this process.
- `skills/hotfix/SKILL.md` — interleaving fix releases.
- `CHANGELOG.md` — the produced artifact.
