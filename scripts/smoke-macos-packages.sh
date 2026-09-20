#!/usr/bin/env bash
set -euo pipefail

if (( $# != 1 )); then
    echo "Usage: $0 ARTIFACT_DIRECTORY" >&2
    exit 2
fi

artifact_dir="$(cd "$1" && pwd)"
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="$($repo_dir/scripts/check-release-version.sh)"
pkg="$artifact_dir/leomoon-parsinegar-$version.pkg"
dmg="$artifact_dir/leomoon-parsinegar-$version.dmg"
application=/Applications/leomoon-parsinegar.app
shortcut="$HOME/Desktop/LeoMoon ParsiNegar.app"
receipt_ids=(
    com.leomoon.ParsiNegar.app
    com.leomoon.ParsiNegar.fonts
    com.leomoon.ParsiNegar.shortcut
)

(
    cd "$artifact_dir"
    shasum -a 256 -c SHA256SUMS
)

bundled_fonts=()
while IFS= read -r font; do
    bundled_fonts+=("$font")
done < <(find "$repo_dir/assets/fonts/system" -type f \( -name '*.ttf' -o -name '*.otf' -o -name '*.ttc' \) | sort)
if (( ${#bundled_fonts[@]} == 0 )); then
    echo "No bundled system fonts were found" >&2
    exit 1
fi

cleanup_installation() {
    sudo rm -rf "$application"
    rm -f "$shortcut"
    for font in "${bundled_fonts[@]}"; do
        sudo rm -f "/Library/Fonts/$(basename "$font")"
    done
    for receipt in "${receipt_ids[@]}"; do
        sudo pkgutil --forget "$receipt" >/dev/null 2>&1 || true
    done
}

assert_fonts_installed() {
    for font in "${bundled_fonts[@]}"; do
        [[ -s "/Library/Fonts/$(basename "$font")" ]] || {
            echo "System-wide font is missing: $(basename "$font")" >&2
            exit 1
        }
    done
}

assert_fonts_absent() {
    for font in "${bundled_fonts[@]}"; do
        [[ ! -e "/Library/Fonts/$(basename "$font")" ]] || {
            echo "System-wide font exists after opt-out or cleanup: $(basename "$font")" >&2
            exit 1
        }
    done
}

mount_point="$(mktemp -d)"
mounted=false
cleanup() {
    if $mounted; then
        hdiutil detach "$mount_point" -quiet || true
    fi
    cleanup_installation
    rm -rf "$mount_point"
}
trap cleanup EXIT

hdiutil attach "$dmg" -nobrowse -readonly -mountpoint "$mount_point" -quiet
mounted=true
"$repo_dir/scripts/verify-macos-package.sh" "$mount_point/leomoon-parsinegar.app" "$pkg" "$dmg" "$version"
"$mount_point/leomoon-parsinegar.app/Contents/MacOS/leomoon-parsinegar" --smoke-test
hdiutil detach "$mount_point" -quiet
mounted=false

cleanup_installation
assert_fonts_absent

echo "Installing the default application, system-font, and desktop-shortcut choices"
sudo installer -pkg "$pkg" -target /
[[ -x "$application/Contents/MacOS/leomoon-parsinegar" ]]
"$application/Contents/MacOS/leomoon-parsinegar" --smoke-test
assert_fonts_installed
[[ -L "$shortcut" ]]

cleanup_installation
[[ ! -e "$application" ]]
assert_fonts_absent
[[ ! -e "$shortcut" ]]

choices_file="$(mktemp)"
cat > "$choices_file" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
    <dict>
        <key>choiceIdentifier</key><string>systemfonts</string>
        <key>choiceAttribute</key><string>selected</string>
        <key>attributeSetting</key><integer>0</integer>
    </dict>
    <dict>
        <key>choiceIdentifier</key><string>desktopshortcut</string>
        <key>choiceAttribute</key><string>selected</string>
        <key>attributeSetting</key><integer>0</integer>
    </dict>
</array>
</plist>
EOF

echo "Installing with system-font and desktop-shortcut choices disabled"
effective_choices_file="${RUNNER_TEMP:-/tmp}/leomoon-parsinegar-effective-choices.xml"
installer -showChoicesAfterApplyingChangesXML "$choices_file" -pkg "$pkg" -target / > "$effective_choices_file"
cat "$effective_choices_file"
sudo installer -dumplog -applyChoiceChangesXML "$choices_file" -pkg "$pkg" -target /
rm -f "$choices_file"
[[ -x "$application/Contents/MacOS/leomoon-parsinegar" ]]
"$application/Contents/MacOS/leomoon-parsinegar" --smoke-test
assert_fonts_absent
[[ ! -e "$shortcut" ]]

cleanup_installation
trap - EXIT
rm -rf "$mount_point"

echo "macOS DMG and installer default and opt-out smoke checks passed"
