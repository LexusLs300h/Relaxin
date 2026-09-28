#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUTPUT_DIRECTORY="$ROOT_DIR/build/Relaxin054Resources"
ARCHIVE="$OUTPUT_DIRECTORY/Relaxin-v0.5.4.tipa"
URL="https://github.com/OwnGoalStudio/Relaxin/releases/download/v0.5.4/Relaxin-v0.5.4.tipa"
EXPECTED_SHA256="002f597fa62f1ef00566abfb7dbdcd76879d6364615e40ab558c6de3bda3062f"

mkdir -p "$OUTPUT_DIRECTORY"
if [[ ! -f "$ARCHIVE" ]] || [[ "$(shasum -a 256 "$ARCHIVE" | awk '{print $1}')" != "$EXPECTED_SHA256" ]]; then
    curl --fail --location --retry 3 --retry-delay 2 --output "$ARCHIVE.tmp" "$URL"
    actual="$(shasum -a 256 "$ARCHIVE.tmp" | awk '{print $1}')"
    [[ "$actual" == "$EXPECTED_SHA256" ]] || {
        echo "error: Relaxin v0.5.4 TIPA SHA-256 mismatch" >&2
        echo "expected: $EXPECTED_SHA256" >&2
        echo "actual:   $actual" >&2
        exit 65
    }
    mv -f "$ARCHIVE.tmp" "$ARCHIVE"
fi

EXTRACT_DIRECTORY="$OUTPUT_DIRECTORY/extracted"
rm -rf "$EXTRACT_DIRECTORY"
mkdir -p "$EXTRACT_DIRECTORY"
unzip -q "$ARCHIVE" -d "$EXTRACT_DIRECTORY"
APP="$EXTRACT_DIRECTORY/Payload/Relaxin.app"

for path in basebin.tar basebin.tc bootstrap_1900.tar.zst libchoma.dylib libjailbreak.dylib libxpf.dylib libroot.deb basebin-link.deb KernelOffsets.plist umbra.deb irisin.deb irisin-default-list-managed.plist; do
    [[ -f "$APP/$path" ]] || { echo "error: missing v0.5.4 resource: $path" >&2; exit 66; }
done

cp -f "$APP/basebin.tar" "$OUTPUT_DIRECTORY/basebin.tar"
cp -f "$APP/basebin.tc" "$OUTPUT_DIRECTORY/basebin.tc"
cp -f "$APP/bootstrap_1900.tar.zst" "$OUTPUT_DIRECTORY/bootstrap_1900.tar.zst"
cp -f "$APP/libchoma.dylib" "$OUTPUT_DIRECTORY/libchoma.dylib"
cp -f "$APP/libjailbreak.dylib" "$OUTPUT_DIRECTORY/libjailbreak.dylib"
cp -f "$APP/libxpf.dylib" "$OUTPUT_DIRECTORY/libxpf.dylib"
cp -f "$APP/libroot.deb" "$OUTPUT_DIRECTORY/libroot.deb"
cp -f "$APP/libkrw-relaxin.deb" "$OUTPUT_DIRECTORY/libkrw-dopamine.deb"
cp -f "$APP/basebin-link.deb" "$OUTPUT_DIRECTORY/basebin-link.deb"
cp -f "$APP/KernelOffsets.plist" "$OUTPUT_DIRECTORY/KernelOffsets.plist"
cp -f "$APP/umbra.deb" "$OUTPUT_DIRECTORY/umbra.deb"
cp -f "$APP/irisin.deb" "$OUTPUT_DIRECTORY/irisin.deb"
cp -f "$APP/irisin-default-list-managed.plist" "$OUTPUT_DIRECTORY/irisin-default-list-managed.plist"

echo "staged Relaxin v0.5.4 runtime resources in $OUTPUT_DIRECTORY"
