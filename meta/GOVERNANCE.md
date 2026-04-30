# Governance

How decisions are made for `atelier`. This document is intentionally brief: the project is small, but it ships governance opinions, so the project itself should have clear governance.

## Roles

### User
Anyone who installs and uses `atelier`. Users have no obligation to contribute, but their bug reports and feedback drive priorities.

### Contributor
Anyone who has had a pull request merged. Contributors are listed in the GitHub contributors graph. By contributing, they accept the [Code of Conduct](CODE_OF_CONDUCT.md) and the [DCO sign-off](CONTRIBUTING.md#sign-off).

### Maintainer
A small group with merge rights. Maintainers are added by existing-maintainer consensus after a sustained pattern of high-quality contribution.

### Steward
The current steward holds tie-breaker authority on contested decisions and represents the project externally. The steward role rotates by maintainer agreement.

## Decision-making

Most decisions are **lazy consensus**: a proposal merged after 72 hours of no objection from any maintainer counts as accepted.

For decisions that affect:

- **The default agent roster** (adding/removing/renaming a default agent)
- **Hook semantics** (changing what hooks block or allow)
- **The plugin manifest** (`name`, `version`, license)
- **Forge adapter contracts** (breaking the open-pr / check-reviews interface)
- **Documentation tree structure** (renaming `docs/process/`, `docs/ssot/`, etc.)

…we use **consensus-seeking**:

1. Proposal opened as a discussion or RFC issue.
2. Maintainers comment with concerns.
3. Proposer addresses concerns; iterates until no maintainer is blocking.
4. If consensus cannot be reached after one week, the steward decides and documents the rationale.

## RFC Process

For significant changes, we strongly encourage an RFC:

1. Open an RFC issue with template `RFC-<NN>: <Title>`.
2. Sections: Motivation, Detailed Design, Drawbacks, Alternatives Considered, Migration / Compatibility, Open Questions.
3. Two-week comment period (shorter if urgent, longer if controversial).
4. Outcome: Accepted (move to PR) / Postponed / Rejected (with rationale).
5. Accepted RFCs are filed under `docs/ssot/decisions/` as ADRs after merge.

## Compatibility Commitments

`atelier` follows [SemVer](https://semver.org/):

- A **MAJOR** version bump may break agent interfaces, skill argument shapes, doc tree paths, or required user actions. Breaking changes are accompanied by:
  - A migration guide section in `meta/version-history.md`.
  - An entry in `bin/atelier-migrate` for the from→to version.
  - A deprecation notice in the prior MINOR release.
- A **MINOR** release adds capability without breaking existing projects.
- A **PATCH** release fixes bugs and tunes prompts. No interface changes.

The current major (1.x once GA) is fully supported. The previous major receives critical fixes for 6 months after the next major ships.

## Communication Channels

- **GitHub Issues** — bugs, feature requests, RFCs.
- **GitHub Discussions** — questions, ideas, open-ended threads.
- **Security** — see [SECURITY.md](SECURITY.md). Do **not** discuss vulnerabilities in public channels.

## Maintainer Onboarding & Offboarding

A maintainer is added when:
- They have ≥3 substantive merged PRs.
- They have demonstrated familiarity with the architecture (especially hooks, agents, capability extension).
- An existing maintainer nominates them and others do not object within 7 days.

A maintainer is offboarded when:
- They request stepping down.
- They have been inactive (no review or commit) for ≥6 months.
- The Code of Conduct enforcement process recommends removal.

## Trademark & Brand

The name "atelier" is used for this project. We do not register a trademark. We ask that derivative or fork projects use a distinct name to avoid confusion.

## Project Lifecycle & API Stability Commitment (v1.0+)

`atelier` is **GA from v1.0 onward**. The API stability commitment:

1. **SemVer-frozen surfaces** are declared in [`v1-api-surface.md`](v1-api-surface.md): skill names, agent `name:` frontmatter values, `bin/*` argument shapes, hook event/exit-code contracts, file path schema under `docs/`, frontmatter schemas, and `atelier-status --json` schema (currently `schema_version: "1"`).
2. **Within v1.x** — no breaking changes to any frozen surface. New skills / agents / hooks / fields are additive only. `atelier-api-audit` (run in pre-push) blocks drift.
3. **Across major versions** (v1 → v2) — breakings are permitted but require:
   - Documentation in [`version-history.md`](version-history.md) with surface category, impact, migration recipe.
   - Deprecation overlap of ≥ 1 minor version with the old surface still functional.
   - A migration script verifiable by `tests/verify-migration.sh`.
4. **Patch versions (v1.x.Y)** — internal fixes, prompt tuning, doc clarifications. No interface change.

Pre-v1.0 (v0.x) behavior — breakings allowed in MINOR releases with migration guide — is **historical only**. The v0.1 → v1.0 transitions are catalogued in `version-history.md`.

The roadmap (see [ROADMAP.md](ROADMAP.md)) is the authoritative direction for v1.x and beyond.

## Support Window

When v1.0 ships, the maintainer commits to supporting v1.x (security patches + documented breakages) for **at least 12 months from the v1.0 GA tag date**. Renewal of the support window happens at each minor release.

## Amendment

This document can be amended by consensus of current maintainers via PR. Amendments take effect on merge and are recorded in this file's git history. Cross-cutting policy changes are also noted in [`version-history.md`](version-history.md). atelier-itself ships no CHANGELOG by design — see [README.md](README.md).
