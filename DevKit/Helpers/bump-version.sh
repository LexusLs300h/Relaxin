#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
VERSION_CONFIG="$ROOT_DIR/Configuration/Version.xcconfig"
TMP_FILE="$VERSION_CONFIG.tmp"

marketing="$(
    awk -F= '/^[[:space:]]*MARKETING_VERSION[[:space:]]*=/ {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
        print $2
        exit
    }' "$VERSION_CONFIG"
)"
build="$(
    awk -F= '/^[[:space:]]*CURRENT_PROJECT_VERSION[[:space:]]*=/ {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
        print $2
        exit
    }' "$VERSION_CONFIG"
)"

IFS=. read -r major minor patch <<< "$marketing"
major="${major:-0}"
minor="${minor:-0}"
patch="${patch:-0}"
build="${build:-0}"

# Build sequence:
#   0.0.0-1 ... 0.0.0-9
#   0.0.1-1 ... 0.0.1-9
#   ...
# Every tenth build carries into the next version component.
if (( build < 9 )); then
    build=$((build + 1))
else
    build=1
    patch=$((patch + 1))

    if (( patch > 9 )); then
        patch=0
        minor=$((minor + 1))
    fi

    if (( minor > 9 )); then
        minor=0
        major=$((major + 1))
    fi
fi

new_marketing="$major.$minor.$patch"

awk -v marketing="$new_marketing" -v build="$build" '
/^[[:space:]]*MARKETING_VERSION[[:space:]]*=/ {
    print "MARKETING_VERSION = " marketing
    next
}
/^[[:space:]]*CURRENT_PROJECT_VERSION[[:space:]]*=/ {
    print "CURRENT_PROJECT_VERSION = " build
    next
}
{ print }
' "$VERSION_CONFIG" > "$TMP_FILE"

mv "$TMP_FILE" "$VERSION_CONFIG"

echo "Relaxin version: $new_marketing-$build"
