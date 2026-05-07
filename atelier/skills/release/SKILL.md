---
name: release
description: "Cut a release — promote develop to main, generate changelog, tag a semver version, and publish release notes. Use when Project Manager marks a milestone complete and the user approves."
---

# Release

You are the Conductor running a release cycle. The target: `main` now reflects the completed milestone, with a tag and a public-facing set of release notes.

## Preconditions

- Active milestone marked complete by Project Manager.
- `milestone-checkpoint` for that milestone approved by the user.
- All target tasks merged to `develop`.
- CI green on `develop`.

If any precondition fails, abort and report which.

## Workflow

### 1. Version Selection
- Follow SemVer based on change scope:
  - **MAJOR** — breaking API/behavior changes (require explicit user confirmation).
  - **MINOR** — new features, backward compatible.
  - **PATCH** — fixes only (usually via hotfix skill instead).
- Record choice in `docs/ssot/decisions/adr-NNN-release-vX.Y.Z.md` if non-obvious.

### 2. Changelog Generation
Technical Writer compiles the changelog from:
- Merged PRs since the last release tag (per Conventional Commit type).
- ADRs added in this cycle.
- Hotfixes back-merged since last release.

Write to `CHANGELOG.md`:
```markdown
## [vX.Y.Z] — YYYY-MM-DD
### Added
- <feat entries>
### Changed
- <refactor/perf/style entries>
### Fixed
- <fix entries>
### Removed
- <entries marked BREAKING CHANGE or removing features>
### Notes
- <ADRs, migrations, operational notes>
```

### 3. Release Change Request (develop → main)
Open change request from `develop` to `main` with:
- Title: `[release] vX.Y.Z`
- Body: changelog entry, linked milestone, migration notes.

Reviewers:
- **Senior Software Engineer** — holistic code quality across all merged PRs.
- **Tech Lead** — architectural coherence.
- **QA Engineer** — every milestone success criterion verified.

Unanimous approval required.

### 4. Merge + Tag
```
atelier-check-reviews <CR> --policy unanimous
<forge> merge   # NO --delete-source-branch for release CRs
git checkout main && git pull
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin vX.Y.Z
```

`develop` is not deleted — it is the ongoing integration branch.

### 5. Publish Release Notes
- GitHub: `gh release create vX.Y.Z --notes-file <path>`
- GitLab: `glab release create vX.Y.Z --notes "..."`
- Other forges: follow forge convention; record in `docs/process/release-process.md`.

### 6. Post-Release
- Technical Writer updates:
  - `docs/roadmap/roadmap.md` to mark milestone as released.
  - `docs/roadmap/lessons-learned.md` with release retrospective.
- Project Manager selects the next milestone's first task.
- If Fully Autonomous involvement level: announce via `atelier-notify release "<summary>"`.

## Forbidden

- Tagging `main` without a passing CI build.
- Force-pushing tags.
- Skipping the three-reviewer gate for release CRs.
- Partial releases that include unmerged features as "planned".

## Reference Documents

- `docs/process/release-process.md`
- `docs/process/change-review-workflow.md`
- `docs/process/git-flow.md`
- `CHANGELOG.md`
