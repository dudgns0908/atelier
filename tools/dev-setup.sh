#!/usr/bin/env bash
# atelier — one-time dev environment setup.
# Run once after cloning: bash tools/dev-setup.sh

set -e

echo "atelier dev setup"
echo "================="

# 1. Install pre-push hook
git config core.hooksPath tools/git-hooks
echo "  [OK] git core.hooksPath set to tools/git-hooks"

# 2. Required tools
need_install=()
for tool in jq shellcheck; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "  [OK] $tool installed"
  else
    echo "  [MISSING] $tool"
    need_install+=("$tool")
  fi
done

if [[ ${#need_install[@]} -gt 0 ]]; then
  echo ""
  echo "Missing tools: ${need_install[*]}"
  echo "Install with:"
  echo "  apt-get install -y ${need_install[*]}    # Debian/Ubuntu"
  echo "  brew install ${need_install[*]}           # macOS"
  echo ""
  echo "Or, if shellcheck is intentionally not installed (e.g., minimal CI runner),"
  echo "export ATELIER_SHELLCHECK_OPTIONAL=1 in your shell profile to allow pre-push to skip it."
  exit 1
fi

# 3. Smoke run validate
if bash bin/atelier-validate >/dev/null 2>&1; then
  echo "  [OK] bin/atelier-validate passes"
else
  echo "  [FAIL] bin/atelier-validate failed — check output:"
  bash bin/atelier-validate
  exit 1
fi

echo ""
echo "Done. Pre-push hook is active. Try a dry push or just commit and push as normal."
