#!/usr/bin/env bash
set -euo pipefail

if (( $# != 4 )); then
    echo "Usage: $0 APP_BUNDLE PKG DMG VERSION" >&2
    exit 2
fi

app=$1
pkg=$2
dmg=$3
version=$4
executable="$app/Contents/MacOS/LeoMoon ParsiNegar"

require_file() {
    if [[ ! -s "$1" ]]; then
        echo "Required macOS package file is missing or empty: $1" >&2
        exit 1
    fi
}

require_file "$executable"
require_file "$app/Contents/Info.plist"
require_file "$app/Contents/Frameworks/QtCore.framework/Versions/A/QtCore"
require_file "$app/Contents/Frameworks/QtGui.framework/Versions/A/QtGui"
require_file "$app/Contents/Frameworks/QtQml.framework/Versions/A/QtQml"
require_file "$app/Contents/Frameworks/QtQuick.framework/Versions/A/QtQuick"
require_file "$app/Contents/PlugIns/platforms/libqcocoa.dylib"
require_file "$app/Contents/Resources/licenses/LICENSE"
require_file "$app/Contents/Resources/licenses/THIRD_PARTY_NOTICES.md"
require_file "$app/Contents/Resources/licenses/SOURCES.md"
require_file "$app/Contents/Resources/licenses/Qt-LGPL-NOTICE.md"
require_file "$app/Contents/Resources/licenses/Qt-LGPL-3.0-only.txt"
require_file "$pkg"
require_file "$dmg"

if [[ -n "${PARSINEGAR_CODESIGN_IDENTITY:-}" ]]; then
    codesign --verify --deep --strict --verbose=2 "$app"
fi
if [[ -n "${PARSINEGAR_INSTALLER_IDENTITY:-}" ]]; then
    pkgutil --check-signature "$pkg"
fi

bundle_version="$(plutil -extract CFBundleShortVersionString raw "$app/Contents/Info.plist")"
bundle_identifier="$(plutil -extract CFBundleIdentifier raw "$app/Contents/Info.plist")"
minimum_macos="$(plutil -extract LSMinimumSystemVersion raw "$app/Contents/Info.plist")"
if [[ "$bundle_version" != "$version" ]]; then
    echo "macOS bundle version $bundle_version does not match $version" >&2
    exit 1
fi
if [[ "$bundle_identifier" != "com.leomoon.ParsiNegar" ]]; then
    echo "Unexpected macOS bundle identifier: $bundle_identifier" >&2
    exit 1
fi
if [[ "$minimum_macos" != "12.0" ]]; then
    echo "Unexpected minimum macOS version: $minimum_macos" >&2
    exit 1
fi

architectures="$(lipo -archs "$executable")"
for architecture in x86_64 arm64; do
    if [[ " $architectures " != *" $architecture "* ]]; then
        echo "macOS bundle is missing the $architecture architecture" >&2
        exit 1
    fi
done

while IFS= read -r -d '' candidate; do
    if ! file "$candidate" | grep -q 'Mach-O'; then
        continue
    fi
    dependencies="$(otool -L "$candidate" | sed -n '/^[[:space:]]/p')"
    if grep -Eq '/Users/|/opt/homebrew/|/usr/local/|/Qt/[0-9]' <<<"$dependencies"; then
        echo "Mach-O file references a build-machine dependency: $candidate" >&2
        echo "$dependencies" >&2
        exit 1
    fi
done < <(find "$app/Contents" -type f -print0)

unexpected_runtime="$(find "$app/Contents" -type f \( -name python -o -name python3 -o -name node -o -name npm -o -name omarchy -o -name quickshell \) -print -quit)"
if [[ -n "$unexpected_runtime" ]]; then
    echo "macOS bundle contains an unexpected external runtime: $unexpected_runtime" >&2
    exit 1
fi

package_work_dir="$(mktemp -d)"
expanded_pkg="$package_work_dir/expanded"
cleanup() {
    rm -rf "$package_work_dir"
}
trap cleanup EXIT

pkgutil --expand "$pkg" "$expanded_pkg"
for component in leomoon-parsinegar-app.pkg leomoon-parsinegar-fonts.pkg leomoon-parsinegar-shortcut.pkg; do
    if [[ ! -e "$expanded_pkg/$component" ]]; then
        echo "Required macOS installer component is missing: $component" >&2
        exit 1
    fi
done
require_file "$expanded_pkg/Distribution"

source_font_count="$(find "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/assets/fonts/system" -type f \( -name '*.ttf' -o -name '*.otf' -o -name '*.ttc' \) | wc -l | tr -d ' ')"
font_component="$expanded_pkg/leomoon-parsinegar-fonts.pkg"
if [[ -d "$font_component" ]]; then
    require_file "$font_component/Bom"
    packaged_font_count="$(lsbom -s "$font_component/Bom" | grep -Ec '\.(ttf|otf|ttc)$' || true)"
else
    packaged_font_count="$(pkgutil --payload-files "$font_component" | grep -Ec '\.(ttf|otf|ttc)$' || true)"
fi
if [[ "$packaged_font_count" != "$source_font_count" ]]; then
    echo "macOS installer contains $packaged_font_count fonts, expected $source_font_count" >&2
    exit 1
fi

hdiutil imageinfo "$dmg" >/dev/null

env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin TMPDIR="${TMPDIR:-/tmp}" \
    QT_QUICK_BACKEND=software "$executable" --smoke-test

echo "Verified self-contained universal macOS bundle, installer, and disk image"
