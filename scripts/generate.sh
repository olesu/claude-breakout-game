#!/usr/bin/env bash
set -euo pipefail

echo "==> Generating Xcode project..."
xcodegen generate

echo "==> Generating Package.swift..."
"$(dirname "${BASH_SOURCE[0]}")/generate-package.sh"
