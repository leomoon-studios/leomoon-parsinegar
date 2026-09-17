#!/usr/bin/env bash
set -euo pipefail

if (( $# != 2 )); then
    echo "Usage: $0 APPIMAGE VERSION" >&2
    exit 2
fi

appimage="$(realpath "$1")"
version="$2"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

if [[ "$(basename "$appimage")" != "ParsiNegar-$version-"*.AppImage ]]; then
    echo "AppImage filename does not contain version $version" >&2
    exit 1
fi

(
    cd "$work_dir"
    "$appimage" --appimage-extract >/dev/null
)
app_dir="$work_dir/squashfs-root"

required_paths=(
    "usr/bin/ParsiNegar"
    "usr/share/applications/com.leomoon.ParsiNegarDesktop.desktop"
    "usr/share/icons/hicolor/scalable/apps/com.leomoon.ParsiNegarDesktop.svg"
    "usr/share/metainfo/com.leomoon.ParsiNegarDesktop.appdata.xml"
    "usr/share/doc/parsinegar-desktop/LICENSE"
    "usr/share/doc/parsinegar-desktop/THIRD_PARTY_NOTICES.md"
    "usr/share/doc/parsinegar-desktop/SOURCES.md"
    "usr/share/doc/parsinegar-desktop/Qt-LGPL-NOTICE.md"
    "usr/share/doc/parsinegar-desktop/Qt-LGPL-3.0-only.txt"
)
for relative_path in "${required_paths[@]}"; do
    if [[ ! -s "$app_dir/$relative_path" ]]; then
        echo "AppImage is missing required file: $relative_path" >&2
        exit 1
    fi
done

for library in Core Gui Qml Quick QuickControls2 Concurrent; do
    if [[ -z "$(find "$app_dir/usr" \( -type f -o -type l \) -name "libQt6${library}.so*" -print -quit)" ]]; then
        echo "AppImage is missing bundled Qt library: Qt6$library" >&2
        exit 1
    fi
done

if ! find "$app_dir/usr" -path '*/platforms/libqxcb.so' -print -quit | grep -q .; then
    echo "AppImage is missing the Qt X11 platform plugin" >&2
    exit 1
fi
if ! find "$app_dir/usr" -path '*/platforms/libqwayland*.so' -print -quit | grep -q .; then
    echo "AppImage is missing the Qt Wayland platform plugin" >&2
    exit 1
fi

if find "$app_dir/usr/bin" -maxdepth 1 -type f -printf '%f\n' | grep -Eiq '^(python|python3|node|npm|omarchy|quickshell)$'; then
    echo "AppImage contains an unexpected external runtime" >&2
    exit 1
fi

version_output="$(APPIMAGE_EXTRACT_AND_RUN=1 "$appimage" --version)"
if [[ "$version_output" != "ParsiNegar Desktop $version" ]]; then
    echo "AppImage version mismatch: $version_output" >&2
    exit 1
fi

echo "Verified self-contained AppImage $appimage"
