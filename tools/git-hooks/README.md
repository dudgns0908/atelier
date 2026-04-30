# Local git hooks

Replaces GitHub Actions CI for atelier-itself maintenance. Same checks, runs locally before push, costs zero forge minutes — aligned with atelier's STEP 0.5 default `I.b CI = None`.

## Setup (once after cloning)

```bash
git config core.hooksPath tools/git-hooks
```

After this, the `pre-push` hook runs automatically on every `git push`. To verify:

```bash
git config core.hooksPath
# expected output: tools/git-hooks
```

## What runs (pre-push)

1. `bin/atelier-validate` — structural validation.
2. `hooks/hooks.json` JSON validity (`jq -e .`).
3. `bash -n` syntax check on every `bin/*` helper.
4. `bash -n` on every hook command extracted from `hooks.json`.
5. `shellcheck bin/*` (warnings = fail). Install via `apt install shellcheck` (or your platform's equivalent).
6. `--help` sanity check for every `bin/*` helper.

If any check fails, the push is aborted with a clear error. Fix and re-push.

## Why local instead of CI

- **Zero forge cost** — no GitHub Actions minutes consumed.
- **Faster feedback** — caught at push time, not after PR creation.
- **Honest with atelier's defaults** — `I.b CI` defaults to `None` for user projects; atelier-itself follows the same philosophy.
- **No discipline tax for solo maintainer** — push will fail loudly if something is broken; no need for a separate review-time CI gate.

## When to keep using CI

Reintroduce a minimal CI workflow when:
- Multiple maintainers exist and not all configure local hooks reliably.
- Project goes public and external contributors push to forks.
- Branch protection on the forge requires status checks (post-v1.0 governance).

Until then, local hooks are sufficient.

## Bypass (emergency)

```bash
git push --no-verify
```

Discouraged. Atelier's `coding-principles.md` says: never `--no-verify` unless the user explicitly authorizes. If you need to bypass to ship a hotfix, document the reason in the next commit's body.

## Adding more checks

Add steps to `tools/git-hooks/pre-push`. Keep checks fast (<5s total) — slow hooks tempt people to bypass.
