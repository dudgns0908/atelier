#!/usr/bin/env bash
# tests/verify-migration.sh — end-to-end check atelier-migrate against synthetic v0.1 fixture.
#
# Creates a temporary directory mimicking a v0.1-initialized project, runs
# atelier-migrate --auto --apply against it, verifies expected mutations.
#
# Run from repo root: bash tests/verify-migration.sh
# Exit 0 if all expected migrations applied; 1 otherwise.

set -eo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FIXTURE=$(mktemp -d -t atelier-verify-migration.XXXXXX)
trap 'rm -rf "$FIXTURE"' EXIT

echo "Migration end-to-end check"
echo "===================="
echo "Fixture: $FIXTURE"

# --- Set up synthetic v0.1 project ---

mkdir -p "$FIXTURE/docs/templates" "$FIXTURE/docs/requirements" "$FIXTURE/docs/design" \
         "$FIXTURE/docs/agents" "$FIXTURE/docs/roadmap" "$FIXTURE/docs/process" \
         "$FIXTURE/docs/agents/agent-specs"

# Six required STEP outputs (so 6-file gate is satisfied)
cat > "$FIXTURE/docs/templates/operating-preferences-template.md" <<'EOF'
# Operating Preferences (filled)
| § | Section | Value |
|---|---|---|
| H | Forge | GitHub |
EOF
echo "# Requirements" > "$FIXTURE/docs/requirements/requirements.md"
echo "# Architecture" > "$FIXTURE/docs/design/architecture.md"
echo "# Team Composition" > "$FIXTURE/docs/agents/team-composition.md"
echo "# Roadmap" > "$FIXTURE/docs/roadmap/roadmap.md"

# INIT-APPROVAL.md WITHOUT plugin version (v0.1 didn't write that line)
cat > "$FIXTURE/docs/INIT-APPROVAL.md" <<'EOF'
# Initialization Approval

Approved by user: 2026-04-15

Phase 1 outputs reviewed and accepted.
EOF

# A doc referencing the legacy pr-workflow.md filename
cat > "$FIXTURE/docs/process/some-rule.md" <<'EOF'
# A Rule

See `docs/process/pr-workflow.md` for the PR cycle.

Also: `docs/process/pr-workflow.md` is referenced from this file.
EOF

# Deprecated agent-specs/ directory with a stub
echo "stale spec" > "$FIXTURE/docs/agents/agent-specs/old-spec.md"

# --- Run migration ---

echo ""
echo "Pre-migration state:"
echo "  - INIT-APPROVAL.md has 'Atelier plugin version' line: $(grep -c 'Atelier plugin version' "$FIXTURE/docs/INIT-APPROVAL.md" || true)"
echo "  - pr-workflow references in some-rule.md: $(grep -c 'pr-workflow.md' "$FIXTURE/docs/process/some-rule.md" || true)"
echo "  - docs/agents/agent-specs/ exists: $([[ -d "$FIXTURE/docs/agents/agent-specs" ]] && echo yes || echo no)"

cd "$FIXTURE"
"$REPO_ROOT/atelier/bin/atelier-migrate" --from 0.1.0 --to 0.3.0 --apply >/tmp/atelier-verify-migration.log 2>&1 || {
  echo "FAIL: atelier-migrate exited non-zero"
  cat /tmp/atelier-verify-migration.log
  exit 1
}

# --- Verify expected mutations ---

echo ""
echo "Post-migration verification:"

FAIL=0

# 1. pr-workflow.md references should be replaced (only docs/ scope per current migrate)
remaining=$( (grep -c 'pr-workflow.md' "$FIXTURE/docs/process/some-rule.md" 2>/dev/null || true) | head -n1)
remaining="${remaining:-0}"
if [[ "$remaining" -eq 0 ]]; then
  echo "  [OK]  pr-workflow.md references replaced"
else
  echo "  [FAIL] $remaining pr-workflow.md references still present" >&2
  FAIL=1
fi

# 2. change-review-workflow.md should now appear in the rule doc
new_refs=$( (grep -c 'change-review-workflow.md' "$FIXTURE/docs/process/some-rule.md" 2>/dev/null || true) | head -n1)
new_refs="${new_refs:-0}"
if [[ "$new_refs" -ge 2 ]]; then
  echo "  [OK]  change-review-workflow.md replacement applied ($new_refs refs)"
else
  echo "  [FAIL] expected ≥2 change-review-workflow.md refs, got $new_refs" >&2
  FAIL=1
fi

# 3. INIT-APPROVAL.md should now have plugin version stamp
if grep -q '^Atelier plugin version:' "$FIXTURE/docs/INIT-APPROVAL.md"; then
  echo "  [OK]  INIT-APPROVAL.md plugin version stamped"
else
  echo "  [FAIL] INIT-APPROVAL.md missing plugin version stamp" >&2
  FAIL=1
fi

# 4. agent-specs/ should be removed
if [[ ! -d "$FIXTURE/docs/agents/agent-specs" ]]; then
  echo "  [OK]  docs/agents/agent-specs/ removed"
else
  echo "  [FAIL] docs/agents/agent-specs/ still exists" >&2
  FAIL=1
fi

# 5. Migration log should exist
log_count=$(find "$FIXTURE/docs/ssot/migrations" -name "*-0.1.0-to-0.3.0.md" 2>/dev/null | wc -l)
log_count="${log_count// /}"
if [[ "$log_count" -ge 1 ]]; then
  echo "  [OK]  migration log written ($log_count file)"
else
  echo "  [FAIL] no migration log under docs/ssot/migrations/" >&2
  FAIL=1
fi

cd "$REPO_ROOT"

echo "===================="
if [[ $FAIL -eq 0 ]]; then
  echo "Migration end-to-end check PASSED."
  exit 0
else
  echo "Migration end-to-end check FAILED ($FAIL check(s) failed)." >&2
  exit 1
fi
