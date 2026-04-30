# Version History — Upgrade & Breaking Changes

Single document covering both **how to upgrade** and **what's broken** between atelier versions. Replaces the former `upgrade-guide.md` and `breaking-changes.md` (consolidated for v1.0).

> **Why no `CHANGELOG.md`?** atelier is a Claude Code plugin, not a library. Users install/update via the plugin manager, never browse the source. Release announcements live on the forge (`gh release` / `glab release`). Per-version migration recipes live here. CHANGELOG would duplicate the forge channel — atelier doesn't ship one.

The companion `v1-api-surface.md` declares what surfaces become SemVer-frozen at v1.0 GA.

---

## Where to find each kind of information

| If you want to know… | Read this |
|---|---|
| How atelier works right now | `README.md`, source docs in `docs/`, `agents/`, `CLAUDE.md` |
| What's new in the latest release | The forge release notes (GitHub/GitLab releases page) |
| What broke between two versions | The "Breaking changes" sections below |
| What needs migrating between two versions | The "Per-version migration" section below + `bin/atelier-migrate` |
| What's frozen at v1.0 GA | `v1-api-surface.md` |
| Who merged what | `git log` |
| How to contribute | `CONTRIBUTING.md` |

---

## Versioning scheme

`atelier` follows SemVer at the plugin level:

- **MAJOR** — breaking change to agent interfaces, skill arguments, doc tree paths, or required user actions. Migration entry required below.
- **MINOR** — new agent / skill / hook / capability. Backward-compatible additive change. Pre-v1.0, MINOR may include breakings (must be documented here); post-v1.0 it cannot.
- **PATCH** — internal fixes, prompt tuning, doc clarifications. No interface change.

---

## Upgrade workflow

1. Read every "Per-version migration" section between your current and target version.
2. Run `bin/atelier-migrate --from <current> --to <target>` (dry-run by default).
3. Review proposed changes to your project's `docs/` tree.
4. Apply with `bin/atelier-migrate --apply`.
5. Run `/reload-plugins` in Claude Code.
6. Run `/atelier:status` to verify project state is intact.

If the migrator refuses (because your `docs/` was customized beyond defaults), follow the manual reconciliation note in that version's section.

**Downgrade** is not supported by the migrator. Manual revert via git history if necessary.

---

## Breaking changes since v0.1

### v0.1 → v0.2 — `pr-workflow.md` rename

- **Surface category**: § 5 (file path schema).
- **Why**: forge-agnostic terminology — the document covers GitHub PRs, GitLab MRs, Bitbucket pull requests, Gerrit changes uniformly. "PR" was misleading.
- **Impact**: any user-project doc, agent persona override, skill body, hook command, or external script that references `docs/process/pr-workflow.md` does not resolve.
- **Migration recipe**: `atelier-migrate --from 0.1 --to 0.2 --apply` automates the rewrite. `tests/verify-migration.sh` verifies it on a synthetic fixture.

### v0.1 → v0.2 — `docs/agents/agent-specs/` removal

- **Surface category**: § 5.
- **Why**: the executable `<user-project>/.claude/agents/<role>.md` files are now the single source of truth for agent specs. The separate spec doc in `docs/` was deprecated as duplicating content.
- **Impact**: workflows that read `docs/agents/agent-specs/` find nothing.
- **Migration recipe**: `atelier-migrate --auto --apply` deletes the directory. Copy custom files out first to preserve.

### v0.1 → v0.2 — `INIT-APPROVAL.md` gains plugin-version line

- **Surface category**: § 5 (soft-breaking).
- **Why**: `atelier-migrate --auto` needs the source version to determine the migration path.
- **Impact**: existing v0.1 projects don't have this line; `atelier-migrate --auto` falls back to requiring `--from <version>` explicitly.
- **Migration recipe**: `atelier-migrate --auto --apply` appends the line on first run after detecting absence (with explicit `--from`).

### v0.2 → v0.3 — additive (no breakings)

The v0.3 cycle (v0.3.0, v0.3.1) is **additive only**:

- New skills `/atelier:plan-milestone` and `/atelier:kanban`.
- New `bin/*` helpers `atelier-sync-tasks`, `atelier-kanban`, `atelier-api-audit`.
- New process docs `task-frontmatter.md`; expanded `issue-management.md`.
- Extended `atelier-status --json` with `lanes` and `epics` keys (schema_version stays `"1"` — additive per stability commitment).
- Extended `bin/atelier-validate` with ADR / capability-log / task-frontmatter checks.
- Stricter pre-push hook (shellcheck-missing now hard-fails; bypass via `ATELIER_SHELLCHECK_OPTIONAL=1`).

No existing surface was removed or renamed.

### v0.3 → v1.0 — additive + verification infrastructure + docs reorganization

The path from v0.3 to v1.0 GA is additive:

- New `bin/atelier-api-audit` — verifies frozen API surface stays intact.
- New `tests/verify-migration.sh` — exercises v0.1 → v0.3 migration path on a synthetic fixture.
- New `tests/v1-acceptance.sh` — single-command GA-readiness gate.
- New `tests/verify-marketplace-metadata.sh` — confirms `.claude-plugin/marketplace.json` + `plugin.json` are publish-ready (called manually before publish; not in pre-push).
- New `.claude-plugin/marketplace.json` — single-plugin marketplace metadata. Plugin is publish-ready; actual publish to a Claude Code marketplace happens whenever the maintainer chooses.
- Docs reorganized: maintainer-only files moved to `meta/`; user-facing docs consolidated under `docs/`. 11 redundant files removed (3 flow narratives whose content lives in `agent-document-map.md`, 2 maintainer files merged into this version-history, 6 user-project subdir READMEs folded into `docs/README.md`).
- Pre-push hook adds `atelier-api-audit` and `verify-migration` gates.

No user-project artifact change. `atelier-migrate 0.3 → 1.0` is a no-op.

---

## Per-version migration

### Upgrading TO `0.2.x` (from `0.1.x`)

Apply the three v0.1 → v0.2 breakings above via `atelier-migrate --auto --apply`. Then run `/reload-plugins` and `/atelier:status` to verify.

### Upgrading TO `0.3.x` (from `0.2.x`)

No migration needed (additive only). Run `/reload-plugins` to pick up new skills and helpers.

### Upgrading TO `1.0.x` (from `0.3.x`)

No migration needed (additive only). Run `bash tools/dev-setup.sh` if you maintain atelier-itself, to pick up the stricter pre-push hook with `atelier-api-audit` and `verify-migration` gates.

---

## v1.0 promise

After v1.0 GA:

- This document becomes **append-only** for breaking-change entries.
- New breakings require a major version bump (v1.0 → v2.0).
- Each breaking row must include: surface category, impact, migration recipe, deprecation period (≥ 1 minor version of overlap with the old surface), and a migration script verifiable by `tests/verify-migration.sh`.

---

## When `atelier-migrate` has no entry for your target version

The migrator is best-effort. Manual reconciliation:

1. Diff your `docs/` against the new version's expected structure (per `docs/README.md`).
2. Reconcile differences manually.
3. Document custom deviations in `docs/ssot/decisions/adr-NNN-custom-docs-layout.md`.
