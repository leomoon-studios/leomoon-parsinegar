#!/usr/bin/env bash
set -euo pipefail

if (( $# != 4 )); then
    echo "Usage: $0 LINUX_DIRECTORY WINDOWS_DIRECTORY MACOS_DIRECTORY OUTPUT_DIRECTORY" >&2
    exit 2
fi

linux_dir="$(realpath "$1")"
windows_dir="$(realpath "$2")"
macos_dir="$(realpath "$3")"
output_dir="$4"
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="$($repo_dir/scripts/check-release-version.sh)"

case "$output_dir" in
    ""|/|"$linux_dir"|"$windows_dir"|"$macos_dir")
        echo "Refusing to replace unsafe release directory: $output_dir" >&2
        exit 1
        ;;
esac

expected_assets=(
    "leomoon-parsinegar-$version-linux-x86_64.AppImage"
    "leomoon-parsinegar-$version-linux-aarch64.AppImage"
    "leomoon-parsinegar-fonts-$version-ubuntu-all.deb"
    "leomoon-parsinegar-fonts-$version-linux-all.zip"
    "leomoon-parsinegar-$version-windows-x64-setup.exe"
    "leomoon-parsinegar-$version-windows-arm64-setup.exe"
    "leomoon-parsinegar-$version-macos-universal.dmg"
    "leomoon-parsinegar-$version-macos-universal.pkg"
)

artifacts=()
for asset_name in "${expected_assets[@]}"; do
    mapfile -t matches < <(find "$linux_dir" "$windows_dir" "$macos_dir" -type f -name "$asset_name" -print)
    if (( ${#matches[@]} != 1 )); then
        echo "Expected exactly one release asset named $asset_name, found ${#matches[@]}" >&2
        exit 1
    fi
    artifacts+=("${matches[0]}")
done

rm -rf "$output_dir"
mkdir -p "$output_dir"
for artifact in "${artifacts[@]}"; do
    destination="$output_dir/$(basename "$artifact")"
    if [[ -e "$destination" ]]; then
        echo "Duplicate release asset name: $(basename "$artifact")" >&2
        exit 1
    fi
    cp "$artifact" "$destination"
done

(
    cd "$output_dir"
    sha256sum ./* > SHA256SUMS
)

echo "Collected $(find "$output_dir" -maxdepth 1 -type f | wc -l) individual release assets"
