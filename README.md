# ParsiNegar Desktop

ParsiNegar Desktop is a standalone Qt 6 application for preparing Persian and other supported right-to-left text for software with incomplete shaping or bidirectional-text support. It is a separate product from the Omarchy ParsiNegar Express plugin and will not require Python, Node.js, npm, Omarchy, or Quickshell on an end user's computer.

The current scaffold opens a minimal resizable window, embeds the pinned JavaScript dependencies, and loads the bundled Vazirmatn font. Conversion and the full desktop interface are added in later implementation steps.

## Development requirements

- CMake 3.21 or newer
- Qt 6.5 or newer with Core, Gui, Qml, Quick, Quick Controls 2, and Test development components
- A C++17 compiler supported by the selected Qt release: GCC or Clang on Linux, Apple Clang on macOS, or MSVC on Windows
- Ninja is recommended but not required

Node.js, npm, Python, Omarchy, and Quickshell are not build or runtime dependencies.

## Linux

Configure, build, test, lint, and run from the repository root:

```sh
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build
ctest --test-dir build --output-on-failure
cmake --build build --target parsinegar_desktop_qmllint
./build/ParsiNegar
```

If Ninja is unavailable, omit `-G Ninja` and use the default CMake generator.

## macOS

Configure with the Qt installation prefix when CMake cannot discover Qt automatically:

```sh
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_PREFIX_PATH="$HOME/Qt/6.8.0/macos"
cmake --build build
ctest --test-dir build --output-on-failure
cmake --build build --target parsinegar_desktop_qmllint
open build/ParsiNegar.app
```

Replace the example prefix with the installed Qt version and location.

## Windows

Run these commands in a Developer PowerShell whose architecture matches the installed Qt build:

```powershell
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_PREFIX_PATH=C:\Qt\6.8.0\msvc2022_64
cmake --build build
ctest --test-dir build --output-on-failure
cmake --build build --target parsinegar_desktop_qmllint
.\build\ParsiNegar.exe
```

Replace the example prefix with the installed Qt version and compiler kit. For a multi-configuration generator, omit `CMAKE_BUILD_TYPE` and pass `--config Debug` to build and test commands.

## Smoke check

The `resource_smoke` CTest starts the real application with an offscreen Qt platform, verifies the embedded JavaScript files exist, waits for the bundled Vazirmatn font to load, and exits. The `license_inventory` CTest requires every vendored artifact and its associated notices.

## Repository boundaries

Reusable text conversion and SVG logic belongs in host-independent JavaScript. QML owns presentation, while a small C++ layer will provide only services that JavaScript and QML cannot safely or portably provide, such as clipboard, settings, and exact font-file access. The Omarchy plugin remains a separate repository with its own host adapters and release process.

## Licensing

Original ParsiNegar Desktop code is available under the root [MIT license](LICENSE). Vendored components retain their own licenses and notices; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) and [SOURCES.md](SOURCES.md).
