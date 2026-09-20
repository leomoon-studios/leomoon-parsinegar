# LeoMoon ParsiNegar

LeoMoon ParsiNegar is a standalone Qt 6 application for preparing Persian, Arabic, Kurdish, Urdu, and Hebrew text for applications with incomplete right-to-left shaping or bidirectional-text support. It converts text in Unicode or Maryam/LMN compatibility mode, copies the result to the clipboard, and can export font-specific SVG curves.

The application includes Persian and Arabic, Kurdish and Urdu, and Hebrew shaping profiles, bidi visual ordering, VideoStudio output, text tools, source-text undo and redo, and a bilingual English and Persian interface. It works offline and does not require Python, Node.js, npm, Omarchy, or Quickshell.

## Use

Type or paste text, choose a shaping profile and conversion mode, then click **Convert**. The converted result is copied to the clipboard. Use **Text Tools** to clean or transform the source before conversion, and **Export SVG** to create editable curves using the selected font.

Unicode mode is for applications that accept Unicode text. Compatibility mode uses legacy Maryam/LMN character codes for older applications that cannot display Unicode text and requires a matching compatibility font in the destination application. The Hebrew profile is Unicode-only.

## Keyboard shortcuts

- `Ctrl+Enter`: Convert
- `Ctrl+,`: Toggle Settings
- `Ctrl+T`: Toggle Text Tools
- `Ctrl+E`: Toggle Export
- `Ctrl+H`: Toggle Help
- `Ctrl+wheel`: Change editor text size (`Command+wheel` on macOS)

The Document menu also provides `Ctrl+N` (New), `Ctrl+O` (Open), `Ctrl+S` (Save), and `Ctrl+Shift+S` (Save As).

## Build

Requirements:

- CMake 3.21 or newer
- Qt 6.5 or newer with Core, Gui, Qml, Quick, Quick Controls 2, Quick Test, and Test development components
- A C++17 compiler supported by the selected Qt release
- Ninja is recommended but not required

From the repository root:

```sh
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build
ctest --test-dir build --output-on-failure
cmake --build build --target parsinegar_ui_qmllint
```

Run the application with `./build/leomoon-parsinegar` on Linux, `open build/leomoon-parsinegar.app` on macOS, or `.\build\leomoon-parsinegar.exe` on Windows. If CMake cannot find Qt, set `CMAKE_PREFIX_PATH` to the installed Qt directory. On Windows, configure from a Developer PowerShell matching the Qt compiler kit.

## Packaging

Release packaging is platform-specific. Linux provides x86_64 and ARM64 AppImages and Ubuntu packages, Windows provides x64 and ARM64 Inno Setup installers, and macOS provides universal Intel and Apple Silicon DMG and PKG packages. Windows and macOS installers include checked-by-default options for installing the bundled compatibility fonts system-wide and creating a desktop shortcut. See the CMake packaging files and release workflow for platform prerequisites and signing options.

The bundled compatibility fonts are in `assets/fonts/system/`. Vazirmatn and Material Symbols are embedded for the application interface.

Pushing a tag in the exact `vX.Y.Z` form starts the release workflow. The workflow derives `metadata/VERSION` from the tag, writes the current UTC date to `metadata/RELEASE_DATE`, and then starts the separate Linux, Windows, and macOS builds. It publishes one GitHub Release only after every build and clean-install test succeeds. The release page includes a commit list, GitHub source archives, each native package as an individual download, and one combined `SHA256SUMS` file.

```sh
git tag v3.0.0
git push origin v3.0.0
```

### Manual test builds

The release workflow can also be started manually to build and test packages without creating a tag or publishing a GitHub Release. Specify the test version, target platform, and architecture with the GitHub CLI:

```sh
gh workflow run release.yml --ref master \
  -f version=3.0.0 \
  -f target=all \
  -f arch=all
```

The `target` input accepts `all`, `linux`, `windows`, or `macos`. The `arch` input accepts `all`, `x64`, or `arm64`; Linux maps `x64` to `amd64`, while macOS always produces a universal Intel and Apple Silicon build and ignores the architecture selection.

For example, build and test only the Windows ARM64 installer:

```sh
gh workflow run release.yml --ref master \
  -f version=3.0.0 \
  -f target=windows \
  -f arch=arm64
```

Monitor the latest run from the terminal with `gh run watch --exit-status`, or open the run under the repository's **Actions** tab. Successful packages can be downloaded from the run's **Artifacts** section. Manual runs never execute the publishing job.

Ordinary branch pushes do not build release packages. The Linux workflow builds native x86_64 and ARM64 packages with Qt 6.8.3, runs the complete test and QML lint suites, produces self-contained AppImages plus separate application and architecture-independent optional-font Ubuntu packages, and verifies X11 and Wayland startup without a Qt SDK.

The Windows workflow builds native x64 and ARM64 installers with Qt 6.8.3 and MSVC, runs the same tests and QML linting, and deploys the Qt runtime with `windeployqt`. Fresh Windows jobs test the default font and desktop-shortcut selections, both opt-out choices, application launch, and uninstall for each architecture. Tagged builds support optional Authenticode signing through protected repository secrets as described in [Windows release signing](docs/WINDOWS_SIGNING.md).

The macOS workflow creates a universal Intel and Apple Silicon bundle with Qt 6.8.3, deploys its private Qt frameworks and QML modules with `macdeployqt`, and produces versioned DMG and component-PKG artifacts. A fresh macOS job tests the disk image, default font and desktop-shortcut selections, both opt-out choices, application launch, and cleanup. Tagged builds support optional Developer ID signing and notarization through protected repository secrets as described in [macOS release signing and notarization](docs/MACOS_SIGNING.md).

## Settings and privacy

Language, editor size, shaping choices, text-tool settings, conversion preferences, selected fonts, and SVG export options persist between launches. Draft text, converted output, clipboard contents, status messages, and undo history are never written to the settings file.

Settings are stored below the platform's generic configuration directory in `leomoon-parsinegar/settings.json`. On Linux this is `~/.config/leomoon-parsinegar/settings.json`.

## Remove

Delete the application using the normal uninstall method for the package you installed. To remove saved preferences as well, delete the `leomoon-parsinegar` directory from the platform's generic configuration directory. On Linux:

```sh
rm -rf ~/.config/leomoon-parsinegar
```

## Licensing

Original LeoMoon ParsiNegar code is available under the [MIT license](LICENSE). Vendored components retain their own licenses and notices. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) and [SOURCES.md](SOURCES.md).
