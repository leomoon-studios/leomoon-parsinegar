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
cpack --config "$build_dir/CPackConfig.cmake" -G DEB -B "$build_dir/packages"

mapfile -t appimages < <(find "$build_dir/package/linux" -maxdepth 1 -type f -name "leomoon-parsinegar-$version-linux-*.AppImage" -print)
mapfile -t debs < <(find "$build_dir/packages" -maxdepth 1 -type f -name '*.deb' -print | sort)

if (( ${#appimages[@]} != 1 )); then
    echo "Expected one versioned AppImage, found ${#appimages[@]}" >&2
    exit 1
fi
if (( ${#debs[@]} < 2 )); then
    echo "Expected application and optional system-font Debian packages" >&2
    exit 1
fi

cp "${appimages[0]}" "$dist_dir/"
chmod +x "$dist_dir/$(basename "${appimages[0]}")"

application_deb=""
fonts_deb=""
for deb in "${debs[@]}"; do
    package_name="$(dpkg-deb --field "$deb" Package)"
    case "$package_name" in
        leomoon-parsinegar) application_deb="$deb" ;;
        leomoon-parsinegar-fonts) fonts_deb="$deb" ;;
    esac
done
if [[ -z "$application_deb" || -z "$fonts_deb" ]]; then
    echo "Could not identify application and optional font packages" >&2
    exit 1
fi

deb_arch="$(dpkg-deb --field "$application_deb" Architecture)"
cp "$application_deb" "$dist_dir/leomoon-parsinegar-$version-ubuntu-$deb_arch.deb"
if [[ "$include_fonts" == true ]]; then
    cp "$fonts_deb" "$dist_dir/leomoon-parsinegar-fonts-$version-ubuntu-all.deb"
fi

"$repo_dir/scripts/verify-linux-appimage.sh" "$dist_dir/$(basename "${appimages[0]}")" "$version"

commit="${GITHUB_SHA:-unknown}"
printf '{\n  "application": "LeoMoon ParsiNegar",\n  "version": "%s",\n  "releaseDate": "%s",\n  "commit": "%s",\n  "platform": "linux",\n  "architecture": "%s",\n  "formats": ["AppImage", "deb"]\n}\n' "$version" "$release_date" "$commit" "$deb_arch" > "$dist_dir/release-manifest.json"

(
    cd "$dist_dir"
    sha256sum ./* > SHA256SUMS
)

echo "Linux release artifacts are ready in $dist_dir"
