#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="$(tr -d '[:space:]' < "$repo_dir/VERSION")"
release_date="$(tr -d '[:space:]' < "$repo_dir/RELEASE_DATE")"
tag="${1:-}"

if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "VERSION must contain a semantic version such as 1.2.3" >&2
    exit 1
fi
if [[ ! "$release_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "RELEASE_DATE must use YYYY-MM-DD format" >&2
    exit 1
fi

if [[ -n "$tag" && "$tag" != "v$version" ]]; then
    echo "Release tag $tag does not match VERSION $version" >&2
    exit 1
fi

echo "$version"
