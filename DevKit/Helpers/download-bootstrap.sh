#!/bin/zsh
# Derived from Dopamine-lbr77 tooling; see DevKit/Bootstrap/LICENSE.md.

set -euo pipefail

if (( $# != 1 )); then
	print -u2 "usage: $0 <output.tar.zst>"
	exit 64
fi

bootstrap_version="1900"
output_archive="$1"
expected_sha256="420f72d1a62c9f884733cdefc596728469482a48858ec7ceca4d3ab2d3cba56c"
release_url="https://github.com/5hux1n/relaxin/releases/download/v0.5.4/Relaxin-v0.5.4.tipa"
release_sha256="002f597fa62f1ef00566abfb7dbdcd76879d6364615e40ab558c6de3bda3062f"
temporary_archive="$output_archive.tmp.$$"
temporary_tipa="$output_archive.tipa.$$"
temporary_extract="$output_archive.extract.$$"
trap 'rm -f -- "$temporary_archive" "$temporary_tipa"; rm -rf -- "$temporary_extract"' EXIT

if [[ -f "$output_archive" ]]; then
	actual_sha256="$(shasum -a 256 "$output_archive" | awk '{ print $1 }')"
	if [[ "$actual_sha256" == "$expected_sha256" ]]; then
		print "RootHide bootstrap $bootstrap_version source is up to date"
		exit 0
	fi
fi

mkdir -p "${output_archive:h}"
print "downloading RootHide v0.5.4 TIPA to obtain bootstrap $bootstrap_version"
curl \
	--fail \
	--location \
	--retry 3 \
	--retry-delay 2 \
	--output "$temporary_tipa" \
	"$release_url"

actual_tipa_sha256="$(shasum -a 256 "$temporary_tipa" | awk '{ print $1 }')"
if [[ "$actual_tipa_sha256" != "$release_sha256" ]]; then
	print -u2 "Relaxin v0.5.4 TIPA SHA-256 mismatch"
	print -u2 "expected: $release_sha256"
	print -u2 "actual:   $actual_tipa_sha256"
	exit 65
fi

mkdir -p "$temporary_extract"
unzip -q "$temporary_tipa" -d "$temporary_extract"
extracted_archive="$temporary_extract/Payload/Relaxin.app/bootstrap_1900.tar.zst"
if [[ ! -f "$extracted_archive" ]]; then
	print -u2 "bootstrap_$bootstrap_version.tar.zst is missing from the v0.5.4 TIPA"
	exit 66
fi

actual_sha256="$(shasum -a 256 "$extracted_archive" | awk '{ print $1 }')"
if [[ "$actual_sha256" != "$expected_sha256" ]]; then
	print -u2 "bootstrap $bootstrap_version SHA-256 mismatch"
	print -u2 "expected: $expected_sha256"
	print -u2 "actual:   $actual_sha256"
	exit 65
fi

cp -f -- "$extracted_archive" "$temporary_archive"
mv -f -- "$temporary_archive" "$output_archive"
print "downloaded RootHide bootstrap $bootstrap_version: $output_archive"
