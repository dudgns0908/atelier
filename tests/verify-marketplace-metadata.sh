#!/usr/bin/env bash
# tests/verify-marketplace-metadata.sh — verify .claude-plugin/marketplace.json
# and .claude-plugin/plugin.json are well-formed and internally consistent.
#
# Required for v1.0 GA gate. Pre-publish verification; does not actually publish.

set -eo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

echo "Marketplace metadata end-to-end check"
echo "==============================="

FAIL=0
ok()   { printf '  [OK]   %s\n' "$1"; }
bad()  { printf '  [FAIL] %s\n' "$1" >&2; FAIL=1; }

PLUGIN_JSON="atelier/.claude-plugin/plugin.json"
MARKETPLACE_JSON=".claude-plugin/marketplace.json"

# 1. plugin.json exists + parses
if [[ ! -f "$PLUGIN_JSON" ]]; then
  bad "$PLUGIN_JSON missing"
  exit 1
fi

if command -v jq >/dev/null 2>&1; then
  if jq -e . "$PLUGIN_JSON" >/dev/null 2>&1; then
    ok "$PLUGIN_JSON parses"
  else
    bad "$PLUGIN_JSON malformed JSON"
    exit 1
  fi
else
  python3 -c "import json; json.load(open('$PLUGIN_JSON'))" 2>/dev/null && \
    ok "$PLUGIN_JSON parses (python fallback)" || { bad "$PLUGIN_JSON malformed"; exit 1; }
fi

# 2. plugin.json required fields
read_json() {
  local path="$1" file="$2"
  if command -v jq >/dev/null 2>&1; then
    jq -r "$path" "$file" 2>/dev/null
  else
    # Convert jq path to python — supports .key, ."key with spaces", .key.sub, .arr[0].key
    python3 - "$file" "$path" <<'PYEOF'
import json, sys, re
fp, path = sys.argv[1], sys.argv[2]
with open(fp) as f:
    data = json.load(f)
# Tokenize: split on . but respect [N] and "..."
tokens = []
i = 0
path = path.lstrip('.')
buf = ''
in_quote = False
while i < len(path):
    c = path[i]
    if c == '"' and not in_quote:
        in_quote = True
    elif c == '"' and in_quote:
        in_quote = False
    elif c == '.' and not in_quote:
        if buf: tokens.append(buf); buf = ''
    elif c == '[' and not in_quote:
        if buf: tokens.append(buf); buf = ''
        end = path.index(']', i)
        tokens.append(int(path[i+1:end]))
        i = end
    else:
        buf += c
    i += 1
if buf: tokens.append(buf)
cur = data
for t in tokens:
    if isinstance(t, int):
        try: cur = cur[t]
        except (IndexError, TypeError): cur = ''; break
    else:
        t_clean = t.strip('"')
        if isinstance(cur, dict):
            cur = cur.get(t_clean, '')
        else:
            cur = ''; break
if cur is None: cur = ''
if isinstance(cur, (dict, list)) and len(cur) == 0: cur = ''
print(cur if not isinstance(cur, (dict, list)) else json.dumps(cur))
PYEOF
  fi
}

for key in name description version author license homepage repository keywords category; do
  val=$(read_json ".${key}" "$PLUGIN_JSON" 2>/dev/null || echo "")
  if [[ -n "$val" && "$val" != "null" && "$val" != "{}" && "$val" != "[]" ]]; then
    ok "plugin.json has '$key'"
  else
    bad "plugin.json missing or empty '$key'"
  fi
done

# 3. marketplace.json exists + parses
if [[ ! -f "$MARKETPLACE_JSON" ]]; then
  bad "$MARKETPLACE_JSON missing"
  exit 1
fi

if command -v jq >/dev/null 2>&1; then
  if jq -e . "$MARKETPLACE_JSON" >/dev/null 2>&1; then
    ok "$MARKETPLACE_JSON parses"
  else
    bad "$MARKETPLACE_JSON malformed JSON"
    exit 1
  fi
else
  python3 -c "import json; json.load(open('$MARKETPLACE_JSON'))" 2>/dev/null && \
    ok "$MARKETPLACE_JSON parses (python fallback)" || { bad "$MARKETPLACE_JSON malformed"; exit 1; }
fi

# 4. marketplace.json required fields
for key in '$schema' name description owner metadata plugins; do
  val=$(read_json ".\"$key\"" "$MARKETPLACE_JSON" 2>/dev/null || echo "")
  if [[ -n "$val" && "$val" != "null" && "$val" != "{}" && "$val" != "[]" ]]; then
    ok "marketplace.json has '$key'"
  else
    bad "marketplace.json missing or empty '$key'"
  fi
done

# 5. Cross-consistency — plugin.json vs marketplace.json[plugins[0]]
plugin_name=$(read_json ".name" "$PLUGIN_JSON")
mp_plugin_name=$(read_json ".plugins[0].name" "$MARKETPLACE_JSON" 2>/dev/null || echo "")

if [[ "$plugin_name" == "$mp_plugin_name" && -n "$plugin_name" ]]; then
  ok "plugin.json name matches marketplace.json[plugins[0]].name ($plugin_name)"
else
  bad "name mismatch: plugin.json='$plugin_name', marketplace.json[plugins[0]].name='$mp_plugin_name'"
fi

# 6. Schema reference
schema_ref=$(read_json '."$schema"' "$MARKETPLACE_JSON" 2>/dev/null || echo "")
if [[ "$schema_ref" == *"marketplace.schema.json"* ]]; then
  ok "marketplace.json declares marketplace.schema.json"
else
  bad "marketplace.json missing or wrong \$schema reference: '$schema_ref'"
fi

# 7. plugin.json version matches marketplace.metadata.version (best practice)
plugin_version=$(read_json ".version" "$PLUGIN_JSON")
mp_version=$(read_json ".metadata.version" "$MARKETPLACE_JSON" 2>/dev/null || echo "")
if [[ "$plugin_version" == "$mp_version" ]]; then
  ok "plugin.json version matches marketplace metadata version ($plugin_version)"
else
  bad "version mismatch: plugin.json='$plugin_version', marketplace.json metadata='$mp_version'"
fi

echo "==============================="
if [[ $FAIL -eq 0 ]]; then
  echo "Marketplace metadata verification PASSED. Plugin is publish-ready."
  exit 0
else
  echo "Marketplace metadata verification FAILED ($FAIL check(s))." >&2
  exit 1
fi
