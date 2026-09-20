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

case "$output_dir" in
    ""|/|"$linux_dir"|"$windows_dir"|"$macos_dir")
        echo "Refusing to replace unsafe release directory: $output_dir" >&2
        exit 1
        ;;
esac

mapfile -t appimages < <(find "$linux_dir" -maxdepth 1 -type f -name '*.AppImage' -print | sort)
mapfile -t debs < <(find "$linux_dir" -maxdepth 1 -type f -name '*.deb' -print | sort)
mapfile -t installers < <(find "$windows_dir" -maxdepth 1 -type f -name '*.exe' -print | sort)
mapfile -t dmgs < <(find "$macos_dir" -maxdepth 1 -type f -name '*.dmg' -print | sort)
mapfile -t pkgs < <(find "$macos_dir" -maxdepth 1 -type f -name '*.pkg' -print | sort)

if (( ${#appimages[@]} != 1 || ${#debs[@]} < 2 || ${#installers[@]} != 1 || ${#dmgs[@]} != 1 || ${#pkgs[@]} != 1 )); then
    echo "Release artifacts are incomplete or ambiguous" >&2
    exit 1
fi

rm -rf "$output_dir"
mkdir -p "$output_dir"
for artifact in "${appimages[@]}" "${debs[@]}" "${installers[@]}" "${dmgs[@]}" "${pkgs[@]}"; do
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
