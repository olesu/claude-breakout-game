#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cat > "$REPO_ROOT/Package.swift" << 'EOF'
// swift-tools-version: 5.9
// AUTO-GENERATED — do not edit directly. Run scripts/generate.sh to regenerate.
import PackageDescription

let package = Package(
    name: "BreakoutGame",
    platforms: [.iOS(.v16), .macOS(.v13)],
    targets: [
        .target(
            name: "BreakoutGame",
            path: "Sources",
            exclude: ["AppDelegateMac.swift"]
        ),
        .testTarget(
            name: "BreakoutGameTests",
            dependencies: ["BreakoutGame"],
            path: "Tests"
        ),
    ]
)
EOF

echo "    Package.swift written."
