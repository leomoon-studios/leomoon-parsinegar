#!/usr/bin/env bash
set -euo pipefail

if (( $# != 1 )); then
    echo "Usage: $0 ARTIFACT_DIRECTORY" >&2
    exit 2
fi

artifact_dir="$(realpath "$1")"
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="$($repo_dir/scripts/check-release-version.sh)"

(
    cd "$artifact_dir"
    sha256sum --check SHA256SUMS
)

mapfile -t appimages < <(find "$artifact_dir" -maxdepth 1 -type f -name "leomoon-parsinegar-$version-linux-*.AppImage" -print)
mapfile -t debs < <(find "$artifact_dir" -maxdepth 1 -type f -name '*.deb' -print | sort)
if (( ${#appimages[@]} != 1 || ${#debs[@]} < 1 )); then
    echo "Linux release set is incomplete" >&2
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

application_deb=""
fonts_deb=""
for deb in "${debs[@]}"; do
    package_name="$(dpkg-deb --field "$deb" Package)"
    case "$package_name" in
        leomoon-parsinegar) application_deb="$deb" ;;
        leomoon-parsinegar-fonts) fonts_deb="$deb" ;;
    esac
done
if [[ -z "$application_deb" ]]; then
    echo "Could not identify the application package" >&2
    exit 1
fi

if dpkg-deb --contents "$application_deb" | grep -q '/fonts/truetype/parsinegar/'; then
    echo "Application package unexpectedly contains optional system fonts" >&2
    exit 1
fi
if [[ -n "$fonts_deb" ]]; then
    font_count="$(dpkg-deb --contents "$fonts_deb" | grep -Ec '\.(ttf|otf|ttc)$')"
    if (( font_count < 1 )); then
        echo "Optional font package does not contain fonts" >&2
        exit 1
    fi
fi

dpkg --force-depends --install "$application_deb"
test -x /usr/bin/leomoon-parsinegar
test -s /usr/share/applications/com.leomoon.ParsiNegar.desktop
test -s /usr/share/icons/hicolor/scalable/apps/com.leomoon.ParsiNegar.svg
if [[ -n "$fonts_deb" ]]; then
    dpkg --force-depends --install "$fonts_deb"
    test -d /usr/share/fonts/truetype/parsinegar
    dpkg --remove leomoon-parsinegar-fonts
fi
dpkg --remove leomoon-parsinegar
test ! -e /usr/bin/leomoon-parsinegar

echo "Linux AppImage and Debian package smoke checks passed"
