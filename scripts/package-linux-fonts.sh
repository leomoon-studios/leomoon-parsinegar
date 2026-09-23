#!/usr/bin/env bash
set -euo pipefail

if (( $# != 3 )); then
    echo "Usage: $0 BUILD_DIRECTORY ARTIFACT_DIRECTORY VERSION" >&2
    exit 2
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build_dir="$(realpath "$1")"
dist_dir="$(realpath -m "$2")"
version="$3"

mkdir -p "$build_dir/package/linux" "$dist_dir"
work_dir="$(mktemp -d "$build_dir/package/linux/font-package-XXXXXX")"
trap 'rm -rf "$work_dir"' EXIT

cpack --config "$build_dir/CPackConfig.cmake" -G DEB -B "$work_dir/deb"
fonts_deb="$work_dir/deb/leomoon-parsinegar-fonts_${version}_all.deb"
mapfile -t debs < <(find "$work_dir/deb" -maxdepth 1 -type f -name '*.deb' -print)
if (( ${#debs[@]} != 1 )) || [[ "${debs[0]:-}" != "$fonts_deb" ]]; then
    echo "Expected only the optional system-font Debian package: $fonts_deb" >&2
    exit 1
fi
cp "$fonts_deb" "$dist_dir/leomoon-parsinegar-fonts-$version-ubuntu-all.deb"

font_root="$work_dir/zip/leomoon-parsinegar-fonts"
mkdir -p "$font_root"
mapfile -d '' -t font_files < <(find "$repo_dir/assets/fonts/system" -maxdepth 1 -type f \
    \( -name '*.ttf' -o -name '*.otf' -o -name '*.ttc' \) -print0)
if (( ${#font_files[@]} == 0 )); then
    echo "No system fonts are available for the Linux ZIP" >&2
    exit 1
fi
cp -- "${font_files[@]}" "$font_root/"
cp "$repo_dir/packaging/linux/FONTS-README.txt" "$font_root/README.txt"
(
    cd "$work_dir/zip"
    cmake -E tar cf "$dist_dir/leomoon-parsinegar-fonts-$version-linux-all.zip" \
        --format=zip leomoon-parsinegar-fonts
)

echo "Linux font packages are ready in $dist_dir"
