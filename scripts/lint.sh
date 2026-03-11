#!/usr/bin/env bash
set -euo pipefail

echo "==> Linting..."
swiftlint lint --strict Sources Tests
