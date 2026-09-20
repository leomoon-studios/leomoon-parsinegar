#!/usr/bin/env bash
set -euo pipefail

if (( $# < 1 || $# > 2 )); then
    echo "Usage: $0 vX.Y.Z [YYYY-MM-DD]" >&2
    exit 2
fi

tag="$1"
if [[ ! "$tag" =~ ^v([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
    echo "Release tag must use the exact vX.Y.Z format" >&2
    exit 1
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="${BASH_REMATCH[1]}"
release_date="${2:-$(date -u +%F)}"
if [[ ! "$release_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Release date must use YYYY-MM-DD format" >&2
    exit 1
fi

printf '%s\n' "$version" > "$repo_dir/metadata/VERSION"
printf '%s\n' "$release_date" > "$repo_dir/metadata/RELEASE_DATE"
"$repo_dir/scripts/check-release-version.sh" "$tag" >/dev/null

echo "Prepared LeoMoon ParsiNegar $version for $release_date"
