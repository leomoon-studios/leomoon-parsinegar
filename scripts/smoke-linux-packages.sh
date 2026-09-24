#!/usr/bin/env bash
set -euo pipefail

if (( $# != 2 )); then
    echo "Usage: $0 ARTIFACT_DIRECTORY EXPECT_FONT_PACKAGES" >&2
    exit 2
fi

artifact_dir="$(realpath "$1")"
expect_font_packages="$2"
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="$($repo_dir/scripts/check-release-version.sh)"
if [[ "$expect_font_packages" != true && "$expect_font_packages" != false ]]; then
    echo "EXPECT_FONT_PACKAGES must be true or false" >&2
    exit 2
fi

(
    cd "$artifact_dir"
    sha256sum --check SHA256SUMS
)

mapfile -t appimages < <(find "$artifact_dir" -maxdepth 1 -type f -name "leomoon-parsinegar-$version-linux-*.AppImage" -print)
mapfile -t application_debs < <(find "$artifact_dir" -maxdepth 1 -type f -name "leomoon-parsinegar-$version-ubuntu-*.deb" -print)
if (( ${#appimages[@]} != 1 || ${#application_debs[@]} != 0 )); then
    echo "Expected one AppImage and no application Debian package" >&2
    exit 1
fi

fonts_deb="$artifact_dir/leomoon-parsinegar-fonts-$version-ubuntu-all.deb"
fonts_zip="$artifact_dir/leomoon-parsinegar-fonts-$version-linux-all.zip"
if [[ "$expect_font_packages" == true ]]; then
    if [[ ! -f "$fonts_deb" || ! -f "$fonts_zip" ]]; then
        echo "Linux font packages are missing" >&2
        exit 1
    fi
    if [[ "$(dpkg-deb --field "$fonts_deb" Package)" != leomoon-parsinegar-fonts \
        || "$(dpkg-deb --field "$fonts_deb" Architecture)" != all ]]; then
        echo "Ubuntu font package metadata is incorrect" >&2
        exit 1
    fi
    unzip -tqq "$fonts_zip"
    deb_font_count="$(dpkg-deb --contents "$fonts_deb" | grep -Ec '\.(ttf|otf|ttc)$')"
    zip_font_count="$(unzip -Z -1 "$fonts_zip" | grep -Ec '^leomoon-parsinegar-fonts/.*\.(ttf|otf|ttc)$')"
    source_font_count="$(find "$repo_dir/assets/fonts/system" -maxdepth 1 -type f \
        \( -name '*.ttf' -o -name '*.otf' -o -name '*.ttc' \) | wc -l)"
    if (( source_font_count < 1 || deb_font_count != source_font_count || zip_font_count != source_font_count )); then
        echo "Ubuntu and ZIP font packages must include every bundled font" >&2
        exit 1
    fi
    unzip -Z -1 "$fonts_zip" | grep -Fx 'leomoon-parsinegar-fonts/README.txt' >/dev/null
elif [[ -e "$fonts_deb" || -e "$fonts_zip" ]]; then
    echo "Architecture-independent font packages must be uploaded only once" >&2
    exit 1
fi

appimage="${appimages[0]}"
chmod +x "$appimage"
"$repo_dir/scripts/verify-linux-appimage.sh" "$appimage" "$version"

xvfb-run -a env QT_QPA_PLATFORM=xcb QT_QPA_PLATFORMTHEME= QT_QUICK_BACKEND=software APPIMAGE_EXTRACT_AND_RUN=1 "$appimage" --smoke-test

runtime_dir="$(mktemp -d)"
chmod 700 "$runtime_dir"
weston_log="$runtime_dir/weston.log"
XDG_RUNTIME_DIR="$runtime_dir" weston --backend=headless-backend.so --socket=wayland-ci --idle-time=0 --log="$weston_log" &
weston_pid=$!
cleanup() {
    kill "$weston_pid" 2>/dev/null || true
    wait "$weston_pid" 2>/dev/null || true
}
trap cleanup EXIT

for _ in {1..100}; do
    [[ -S "$runtime_dir/wayland-ci" ]] && break
    sleep 0.1
done
if [[ ! -S "$runtime_dir/wayland-ci" ]]; then
    cat "$weston_log" >&2
    echo "Headless Wayland compositor did not start" >&2
    exit 1
fi

XDG_RUNTIME_DIR="$runtime_dir" WAYLAND_DISPLAY=wayland-ci QT_QPA_PLATFORM=wayland QT_QPA_PLATFORMTHEME= QT_QUICK_BACKEND=software APPIMAGE_EXTRACT_AND_RUN=1 "$appimage" --smoke-test
cleanup
trap - EXIT
rm -rf "$runtime_dir"

if [[ "$expect_font_packages" == true ]]; then
    mapfile -d '' -t packaged_font_files < <(find "$repo_dir/assets/fonts/system" -maxdepth 1 -type f \
        \( -name '*.ttf' -o -name '*.otf' -o -name '*.ttc' \) -print0)
    dpkg --install "$fonts_deb"
    for font_file in "${packaged_font_files[@]}"; do
        test -f "/usr/share/fonts/truetype/parsinegar/$(basename "$font_file")"
    done
    dpkg --remove leomoon-parsinegar-fonts
    for font_file in "${packaged_font_files[@]}"; do
        test ! -e "/usr/share/fonts/truetype/parsinegar/$(basename "$font_file")"
    done
fi

echo "Linux AppImage and optional font package smoke checks passed"
