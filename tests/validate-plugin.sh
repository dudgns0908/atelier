#!/usr/bin/env bash
# Thin wrapper around bin/atelier-validate for CI use.
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
exec "$HERE/../plugins/atelier/bin/atelier-validate"
