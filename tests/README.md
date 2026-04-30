# Tests

Validation for the `atelier` plugin itself. Run these before tagging a release.

## Structural Validation

```
bin/atelier-validate
```

Checks:
- Manifest exists and has `name: atelier` + description.
- All 9 default agents present.
- All 7 skills present.
- All process docs present.
- All bin helpers present and executable.

Exit 0 on success, 1 on any failure.

## Smoke Test (manual)

Load the plugin and run an end-to-end interview on a throwaway directory:

```bash
mkdir /tmp/atelier-verify && cd /tmp/atelier-verify
claude --plugin-dir /path/to/atelier
# then:
/atelier:init-project
```

Abort at STEP 5.5 without approving. Verify produced `docs/` tree matches expectations.

## Hook Test (manual)

```bash
# Verify forbidden ops are blocked
claude --plugin-dir /path/to/atelier -p "Run: git push origin main"    # expect blocked
claude --plugin-dir /path/to/atelier -p "Run: git commit --no-verify"  # expect blocked
```

## Forge Adapter Test (manual)

```bash
# GitHub
atelier-open-pr T99 "end-to-end check" --type chore --forge github      # expect gh pr create
atelier-check-reviews 42 --forge github                            # expect gh pr view query

# GitLab
atelier-open-pr T99 "end-to-end check" --type chore --forge gitlab      # expect glab mr create
atelier-check-reviews 42 --forge gitlab                            # expect glab api projects/.../approval_state

# Bitbucket / Gerrit (stubs)
atelier-open-pr T99 "end-to-end check" --forge bitbucket                 # expect manual-instruction stub
atelier-check-reviews 42 --forge gerrit                            # expect manual-verify stub (exit 2)
```

## Future

- Scripted integration tests with a mock forge.
- Lint rules for agent `.md` frontmatter.
- Snapshot tests for skill outputs.
