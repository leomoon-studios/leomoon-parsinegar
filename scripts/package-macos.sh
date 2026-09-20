#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build_dir="${1:-$repo_dir/build-macos}"
dist_dir="${2:-$build_dir/dist}"
release_tag=""
if [[ "${GITHUB_REF_TYPE:-}" == "tag" ]]; then
    release_tag="${GITHUB_REF_NAME:-}"
fi
version="$($repo_dir/scripts/check-release-version.sh "$release_tag")"
release_date="$(tr -d '[:space:]' < "$repo_dir/metadata/RELEASE_DATE")"

case "$dist_dir" in
    ""|/|"$repo_dir")
        echo "Refusing to replace unsafe artifact directory: $dist_dir" >&2
        exit 1
        ;;
esac

rm -rf "$dist_dir"
mkdir -p "$dist_dir"

cmake --build "$build_dir" --target package_macos --parallel 2

app="$build_dir/leomoon-parsinegar.app"
package_dir="$build_dir/package/macos"
pkg="$package_dir/leomoon-parsinegar-$version-macos-universal.pkg"
dmg="$package_dir/leomoon-parsinegar-$version-macos-universal.dmg"

"$repo_dir/scripts/verify-macos-package.sh" "$app" "$pkg" "$dmg" "$version"

cp "$pkg" "$dmg" "$dist_dir/"
architectures="$(lipo -archs "$app/Contents/MacOS/leomoon-parsinegar")"
commit="${GITHUB_SHA:-unknown}"
printf '{\n  "application": "LeoMoon ParsiNegar",\n  "version": "%s",\n  "releaseDate": "%s",\n  "commit": "%s",\n  "platform": "macos",\n  "architectures": "%s",\n  "formats": ["dmg", "pkg"],\n  "signed": %s\n}\n' \
    "$version" "$release_date" "$commit" "$architectures" \
    "$([ -n "${PARSINEGAR_CODESIGN_IDENTITY:-}" ] && printf true || printf false)" \
    > "$dist_dir/release-manifest.json"

(
    cd "$dist_dir"
    shasum -a 256 ./* > SHA256SUMS
)

echo "macOS release artifacts are ready in $dist_dir"
