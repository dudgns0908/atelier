# Code Quality Automation (CI + Pre-commit)

Software Architect's STEP 2 responsibility. Both layers — local pre-commit and forge-side CI — implement the policy chosen at `operating-preferences-template.md` (templates) section I.

> Pre-commit catches problems before commit (fast, local). CI catches them at the forge (authoritative, gateable). Use both — pre-commit is bypassable; CI is not.

---

## Two layers — set independently

> **Default policy**: pre-commit ON (`Format + Lint`), CI OFF (no yaml generated). atelier opts the user IN to CI only on explicit request to avoid creating cost-bearing infrastructure they didn't ask for.

### I.a Pre-commit policy levels (local, no cost)

| Level | Hooks |
|---|---|
| None | — |
| Format only | formatter (Prettier / Black / gofmt / rustfmt) |
| Format + Lint *(default)* | + linter (ESLint / Ruff / golangci-lint / Clippy) |
| Format + Lint + Test | + fast unit tests |
| Full | + type-check + secrets scanner (detect-secrets / gitleaks) |

### I.b CI policy levels (forge-side, may incur cost)

| Level | Trigger | Jobs | Cost note |
|---|---|---|---|
| None *(default)* | — | — | atelier does NOT generate `.github/workflows/` |
| Minimal | `pull_request` only, paths-ignore docs | `pre-commit run --all-files`, `pytest` | ~30-60 min/month for typical solo project |
| Standard | `pull_request` + `push:main` | + coverage gate | ~60-120 min/month |
| Full | + `push:any`, matrix, scheduled | + multi-platform, security scans | needs public repo or paid plan |
| Custom | user-specified | user-specified | varies |

→ Most projects start with `I.b = None` and graduate to `Minimal` when external contributors arrive or the repo goes public.

---

## Pre-commit Layer

### Tool choice
Default: [`pre-commit`](https://pre-commit.com/) framework — language-agnostic. Alternatives (husky, lefthook) acceptable with an ADR.

### Config locations
- `pre-commit`: `.pre-commit-config.yaml` at repo root.
- `husky`: `.husky/pre-commit` + `package.json` scripts.
- `lefthook`: `lefthook.yml`.

### On failure (per operating-preferences I)
- **auto-fix**: run formatter auto-fix, re-stage, continue commit. Only safe for formatters.
- **block**: exit 1, reject commit.
- **warn**: report and continue.

### Bypass prohibited
`git commit --no-verify` is blocked at the Claude Code hook layer. CI's `pre-commit-check` catches external bypasses.

### Per-stack examples

**Python**
```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    hooks: [ruff, ruff-format]
  - repo: https://github.com/pre-commit/mirrors-mypy
    hooks: [mypy]
```

**TypeScript**
```yaml
repos:
  - repo: local
    hooks:
      - id: prettier
        entry: npx prettier --check
      - id: eslint
        entry: npx eslint
      - id: tsc
        entry: npx tsc --noEmit
```

**Go**
```yaml
repos:
  - repo: https://github.com/golangci/golangci-lint
    hooks: [golangci-lint]
```

**Rust**
```yaml
repos:
  - repo: local
    hooks:
      - id: fmt
        entry: cargo fmt --all -- --check
      - id: clippy
        entry: cargo clippy -- -D warnings
```

---

## CI Layer (Forge-Aware)

### Forge → CI system mapping

| Forge | CI System | Config Path |
|---|---|---|
| GitHub | GitHub Actions | `.github/workflows/ci.yml` |
| GitLab | GitLab CI | `.gitlab-ci.yml` |
| Bitbucket | Bitbucket Pipelines | `bitbucket-pipelines.yml` |
| Gerrit | Zuul / Jenkins / custom | project-specific |
| Local-only | none — pre-commit only | — |

### Branch triggers
- **PR / MR open or updated**: run all configured jobs; block merge on failure.
- **Push to `develop`**: run all jobs + publish artifacts (if any).
- **Push to `main`**: run all jobs + tag verification + release publish.

### Secrets
- Secrets live in the forge's secret store, never committed.
- CI references secrets by environment-variable name only.
- Technical Writer records required secret names in `docs/design/integrations.md`.

### Skeleton — GitHub Actions
```yaml
name: CI
on: [pull_request, push]
jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup
        run: <stack-specific>
      - name: Format
        run: <formatter> --check
      - name: Lint
        run: <linter>
      - name: Test
        run: <test runner>
      - name: Pre-commit (catch local bypasses)
        run: pre-commit run --all-files
```

### Skeleton — GitLab CI
```yaml
stages: [quality]
quality:
  stage: quality
  script:
    - <formatter> --check
    - <linter>
    - <test runner>
    - pre-commit run --all-files
```

---

## Handoff at STEP 2

Software Architect's STEP 2 outputs depend on the user's I.a and I.b choices:

**Always (if I.a ≠ None)**:
1. Pre-commit config at repo root (`.pre-commit-config.yaml` or stack-equivalent).
2. Install instructions in `docs/design/tech-stack.md`.

**Only if I.b ≠ None**:
3. CI yaml at forge-correct path (`.github/workflows/ci.yml` / `.gitlab-ci.yml` / etc.).
4. A CI job named `pre-commit-check` mirroring local pre-commit hooks (so contributors can't bypass via `--no-verify`).
5. Caching strategy (pip / pre-commit / mypy) configured per cost-sensitivity choice.

**If I.b = None**:
- atelier does NOT touch `.github/workflows/` or any forge CI directory.
- ADR records the deferral: "ADR-NNN: CI not generated at init; pre-commit only. To enable later: /atelier:escalate software-architect 'enable CI'".

Tech Lead verifies at the first PR that the configured layers actually run. CI green is a merge gate **only if I.b ≠ None**.
