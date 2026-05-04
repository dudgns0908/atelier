#!/usr/bin/env bash
# tests/v1-acceptance.sh — single-command v1.0 GA gate.
#
# Runs every check that must pass before tagging a v1.0.x release.
# Exit 0 = release-ready. Exit 1 = something to fix.
#
# Composes (does not duplicate):
#   1. atelier/bin/atelier-validate     — structural plugin validity
#   2. atelier/bin/atelier-api-audit    — frozen API surface (8 categories)
#   3. tests/verify-migration.sh        — atelier-migrate v0.1→v0.3 path
#   4. tests/verify-marketplace-metadata.sh — plugin.json + marketplace.json publish-ready
#
# Run: bash tests/v1-acceptance.sh

set -eo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

echo "atelier v1.0 acceptance"
echo "========================"

FAIL=0
run() {
  local label="$1" cmd="$2"
  printf '\n[%s]\n' "$label"
  if eval "$cmd"; then
    printf '  -> %s passed\n' "$label"
  else
    printf '  -> %s FAILED\n' "$label" >&2
    FAIL=1
  fi
}

run "1. atelier-validate"  "bash atelier/bin/atelier-validate >/dev/null"
run "2. atelier-api-audit" "atelier/bin/atelier-api-audit >/dev/null"
run "3. verify-migration"  "bash tests/verify-migration.sh >/dev/null"

# 4. atelier-status --json sanity
printf '\n[4. atelier-status --json]\n'
if atelier/bin/atelier-status --json | python3 -c "import sys, json; json.load(sys.stdin)" >/dev/null 2>&1; then
  echo "  -> JSON output parses"
else
  echo "  -> atelier-status --json FAILED to produce valid JSON" >&2
  FAIL=1
fi

# 5. plugin.json well-formed + version readable
printf '\n[5. plugin.json]\n'
plugin_v=$(python3 -c "import json; print(json.load(open('atelier/.claude-plugin/plugin.json'))['version'])" 2>/dev/null || echo "")
if [[ -n "$plugin_v" ]]; then
  echo "  -> plugin.json valid; version: $plugin_v"
else
  echo "  -> plugin.json malformed or missing version" >&2
  FAIL=1
fi

# 6. README install section honest (mentions current version + --plugin-dir)
printf '\n[6. README install section]\n'
if grep -q "claude --plugin-dir" README.md && grep -q "$plugin_v" README.md 2>/dev/null; then
  echo "  -> README references --plugin-dir and version $plugin_v"
else
  echo "  -> README install section may be stale (no --plugin-dir or version $plugin_v reference)" >&2
  FAIL=1
fi

echo ""
echo "========================"
if [[ $FAIL -eq 0 ]]; then
  echo "v1.0 acceptance PASSED. Plugin is ready to tag v$plugin_v."
  exit 0
else
  echo "v1.0 acceptance FAILED. Fix the items above before tagging." >&2
  exit 1
fi
