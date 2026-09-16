# ParsiNegar Desktop

ParsiNegar Desktop is a standalone Qt 6 application for preparing Persian, Arabic, Kurdish, Urdu, and Hebrew text for applications with incomplete right-to-left shaping or bidirectional-text support. It converts text in Unicode or Maryam/LMN compatibility mode, copies the result to the clipboard, and can export font-specific SVG curves.

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

Run the application with `./build/ParsiNegar` on Linux, `open build/ParsiNegar.app` on macOS, or `.\build\ParsiNegar.exe` on Windows. If CMake cannot find Qt, set `CMAKE_PREFIX_PATH` to the installed Qt directory. On Windows, configure from a Developer PowerShell matching the Qt compiler kit.

## Packaging

Release packaging is platform-specific. Linux provides AppImage and Debian components, Windows provides an Inno Setup installer, and macOS provides an unsigned DMG and component PKG. Windows and macOS installers include checked-by-default options for installing the bundled compatibility fonts system-wide and creating a desktop shortcut. See the CMake packaging files and release workflow for platform prerequisites and signing options.

The bundled compatibility fonts are in `assets/fonts/system/`. Vazirmatn and Material Symbols are embedded for the application interface.

## Settings and privacy

Language, editor size, shaping choices, text-tool settings, conversion preferences, selected fonts, and SVG export options persist between launches. Draft text, converted output, clipboard contents, status messages, and undo history are never written to the settings file.

Settings are stored below the platform's generic configuration directory in `leomoon-studios.parsinegar-desktop/settings.json`. On Linux this is `~/.config/leomoon-studios.parsinegar-desktop/settings.json`.

## Remove

Delete the application using the normal uninstall method for the package you installed. To remove saved preferences as well, delete the `leomoon-studios.parsinegar-desktop` directory from the platform's generic configuration directory. On Linux:

```sh
rm -rf ~/.config/leomoon-studios.parsinegar-desktop
```

## Licensing

Original ParsiNegar Desktop code is available under the [MIT license](LICENSE). Vendored components retain their own licenses and notices. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) and [SOURCES.md](SOURCES.md).
