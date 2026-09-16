# ParsiNegar Desktop

ParsiNegar Desktop is a standalone Qt 6 application for preparing Persian and other supported right-to-left text for software with incomplete shaping or bidirectional-text support. It is a separate product from the Omarchy ParsiNegar Express plugin and will not require Python, Node.js, npm, Omarchy, or Quickshell on an end user's computer.

The application now opens a branded, resizable conversion editor with independent LTR and RTL alignment, Persian/Arabic, Kurdish/Urdu, and Hebrew shaping profiles, Unicode and Compatibility modes, bidi ordering, and VideoStudio output. Conversion runs in a bounded background worker, successful output is copied through the native clipboard bridge, and the source remains visible in the editor. Holding `Ctrl` while scrolling over the editor changes its text size from 10 to 48 pixels; macOS uses `Command`, and the chosen size persists between launches. The Text tools page provides the same 15 source transformations as ParsiNegar Express, including verb-aware Persian ZWNJ repair, digit and quotation conversion, character normalization, and writing cleanup. Each tool is independently enabled, conflicting reverse transformations disable one another, and enabled tools update the source before conversion as one history transaction. Bounded source-text Undo and Redo actions restore text, selection, cursor position, and paragraph breaks across ordinary edits and Text Tools changes. The Document menu provides New, Open, Save, and Save As actions with standard keyboard shortcuts, exact UTF-8 line-ending preservation, atomic writes, dirty-state window titles, and Save, Discard, or Cancel protection before destructive actions and application exit. A bilingual English and Persian settings page provides all six reshaper options and all 286 named ligatures. Language, editor font size, profile, text-tool toggles, conversion preferences, reshaper choices, valid selected font paths, and every SVG export option persist between launches, while editor drafts, converted output, clipboard contents, status messages, and undo history never enter the settings file. On Linux, settings are stored at `~/.config/leomoon-studios.parsinegar-desktop/settings.json`. The desktop also includes application-owned light and dark palettes, Vazirmatn-aware typography, visible keyboard focus, reusable controls, pinned JavaScript dependencies, and narrow C++ services for clipboard, platform settings, exact font-byte reads, bounded UTF-8 document I/O, atomic text saves, and atomic SVG writes.

## Keyboard shortcuts

- `Ctrl+Enter`: Convert
- `Ctrl+,`: Toggle Settings
- `Ctrl+T`: Toggle Text Tools
- `Ctrl+E`: Toggle Export
- `Ctrl+H`: Toggle Help
- `Ctrl+wheel`: Change editor text size (`Command+wheel` on macOS)

## Development requirements

- CMake 3.21 or newer
- Qt 6.5 or newer with Core, Gui, Qml, Quick, Quick Controls 2, Quick Test, and Test development components
- A C++17 compiler supported by the selected Qt release: GCC or Clang on Linux, Apple Clang on macOS, or MSVC on Windows
- Ninja is recommended but not required

Node.js, npm, Python, Omarchy, and Quickshell are not build or runtime dependencies.

## Linux

Configure, build, test, lint, and run from the repository root:

```sh
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build
ctest --test-dir build --output-on-failure
cmake --build build --target parsinegar_ui_qmllint
./build/ParsiNegar
```

If Ninja is unavailable, omit `-G Ninja` and use the default CMake generator.

## macOS

Configure with the Qt installation prefix when CMake cannot discover Qt automatically:

```sh
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_PREFIX_PATH="$HOME/Qt/6.8.0/macos"
cmake --build build
ctest --test-dir build --output-on-failure
cmake --build build --target parsinegar_ui_qmllint
open build/ParsiNegar.app
```

Replace the example prefix with the installed Qt version and location.

## Windows

Run these commands in a Developer PowerShell whose architecture matches the installed Qt build:

```powershell
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_PREFIX_PATH=C:\Qt\6.8.0\msvc2022_64
cmake --build build
ctest --test-dir build --output-on-failure
cmake --build build --target parsinegar_ui_qmllint
.\build\ParsiNegar.exe
```

Replace the example prefix with the installed Qt version and compiler kit. For a multi-configuration generator, omit `CMAKE_BUILD_TYPE` and pass `--config Debug` to build and test commands.

## Packaging

All installers treat the application and its required runtime as mandatory. Windows and macOS installers expose two independent optional choices, both selected by default: install the bundled ParsiNegar compatibility fonts system-wide and create a desktop shortcut. AppImage does not modify the host font collection or desktop, while the CPack Debian build emits the fonts as a separate package so a graphical package frontend can offer it alongside the required application package.

The bundled ParsiNegar compatibility fonts belong under `assets/fonts/system/` and are never embedded into the QML resources. The application package continues to embed only Vazirmatn and Material Symbols for its own interface.

On Linux, configure a release build and create the component `.deb` or `.tar.gz` packages with:

```sh
cmake -S . -B build-release -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build-release
cpack --config build-release/CPackConfig.cmake -G DEB -B build-release/packages
```

Install `linuxdeploy` and its Qt plugin before configuration to expose the `package_appimage` target. That target stages only the mandatory application component, runs Qt deployment, and writes the AppImage below `build-release/package/linux/`.

On Windows, install Inno Setup in addition to the matching Qt and compiler toolchain. A native configuration discovers `windeployqt` and exposes `deploy_windows`; when `ISCC` is also available it exposes `package_windows`, which creates the installer below the build directory's `package/windows/` folder. The Inno Setup task page keeps the system-font and desktop-shortcut choices checked unless the user opts out.

On macOS, a native configuration discovers `macdeployqt` and exposes `deploy_macos` and `package_macos`. The package target creates an unsigned `.dmg` and a component `.pkg` with a mandatory application choice plus checked-by-default system-font and desktop-shortcut choices. Set `PARSINEGAR_CODESIGN_IDENTITY` and `PARSINEGAR_INSTALLER_IDENTITY` only when producing signed release artifacts; set `PARSINEGAR_NOTARY_PROFILE` to an existing `notarytool` keychain profile when the signed package and disk image should also be submitted and stapled. Local unsigned packages do not require credentials.

Every deployed artifact includes the MIT license, third-party notices, source provenance, and the Qt dynamic-linking notice. The applicable LGPL text from the exact Qt SDK must also be copied into the final release and the release record must name the precise Qt version used.

## Smoke check

The `resource_smoke` CTest starts the real application with an offscreen Qt platform, verifies the embedded resources, waits for the bundled Vazirmatn font to load, and exits. The `license_inventory` CTest requires every vendored artifact and its associated notices. The `conversion_core` CTest loads the embedded production scripts in `QJSEngine` and verifies conversions, profiles, settings, all ligature metadata, mappings, and resource limits without Node.js. The `native_services` CTest exercises platform paths, atomic persistence, exact font reads, local-URL boundaries, failure signals, clipboard round trips, and size limits. The `desktop_shell` Qt Quick Test checks responsive window geometry, visible keyboard focus, control behavior, font fallback, palette contrast, editor interactions, exact clipboard conversion output, profile invariants, settings restarts and recovery, language mirroring, request races, error handling, and responsiveness at the conversion limit. The `qml_import_boundaries` test prevents desktop QML from acquiring Omarchy or Quickshell imports. The `packaging_metadata` test verifies required platform files, mandatory application metadata, checked-by-default optional choices, and the presence of the bundled system-font payload.

## Repository boundaries

Reusable text conversion, source-text transformation, and SVG logic belongs in host-independent JavaScript. The desktop and plugin carry byte-identical copies of `TextTools.js` so all 15 transformations behave consistently in both products. QML owns presentation, while the small C++ service layer provides only clipboard, settings, exact font-file access, bounded text-document I/O, and safe atomic writes. Its public contract is documented in [docs/native-services.md](docs/native-services.md). The Omarchy plugin remains a separate repository with its own host adapters and release process.

## Licensing

Original ParsiNegar Desktop code is available under the root [MIT license](LICENSE). Vendored components retain their own licenses and notices; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) and [SOURCES.md](SOURCES.md).
