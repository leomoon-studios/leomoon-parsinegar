#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build_dir="${1:-$repo_dir/build-release}"
dist_dir="${2:-$build_dir/dist}"
include_fonts="${3:-true}"
release_tag=""
if [[ "${GITHUB_REF_TYPE:-}" == "tag" ]]; then
    release_tag="${GITHUB_REF_NAME:-}"
fi
version="$($repo_dir/scripts/check-release-version.sh "$release_tag")"
release_date="$(tr -d '[:space:]' < "$repo_dir/metadata/RELEASE_DATE")"

if [[ "$include_fonts" != true && "$include_fonts" != false ]]; then
    echo "INCLUDE_FONTS must be true or false" >&2
    exit 2
fi

case "$dist_dir" in
    ""|/|"$repo_dir")
        echo "Refusing to replace unsafe artifact directory: $dist_dir" >&2
        exit 1
        ;;
esac

rm -rf "$dist_dir"
mkdir -p "$dist_dir"

cmake --build "$build_dir" --target package_appimage --parallel

mapfile -t appimages < <(find "$build_dir/package/linux" -maxdepth 1 -type f -name "leomoon-parsinegar-$version-linux-*.AppImage" -print)

if (( ${#appimages[@]} != 1 )); then
    echo "Expected one versioned AppImage, found ${#appimages[@]}" >&2
    exit 1
fi

cp "${appimages[0]}" "$dist_dir/"
chmod +x "$dist_dir/$(basename "${appimages[0]}")"

if [[ "$include_fonts" == true ]]; then
    "$repo_dir/scripts/package-linux-fonts.sh" "$build_dir" "$dist_dir" "$version"
fi

"$repo_dir/scripts/verify-linux-appimage.sh" "$dist_dir/$(basename "${appimages[0]}")" "$version"

commit="${GITHUB_SHA:-unknown}"
release_arch="$(dpkg --print-architecture)"
font_formats='[]'
if [[ "$include_fonts" == true ]]; then
    font_formats='["deb", "zip"]'
fi
printf '{\n  "application": "LeoMoon ParsiNegar",\n  "version": "%s",\n  "releaseDate": "%s",\n  "commit": "%s",\n  "platform": "linux",\n  "architecture": "%s",\n  "formats": ["AppImage"],\n  "optionalFontFormats": %s\n}\n' "$version" "$release_date" "$commit" "$release_arch" "$font_formats" > "$dist_dir/release-manifest.json"

(
    cd "$dist_dir"
    sha256sum ./* > SHA256SUMS
)

echo "Linux release artifacts are ready in $dist_dir"
