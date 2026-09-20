# Native service boundary

The desktop host exposes three narrow QObject singletons under the `LeoMoon.ParsiNegar.Native` QML URI. These objects exist only for operations that vanilla JavaScript and portable QML cannot safely provide. Conversion rules, settings schema validation, text tools, and SVG path generation remain in JavaScript.

## ClipboardBridge

`ClipboardBridge.copyText(text)` writes a string through `QGuiApplication::clipboard()` and verifies that the clipboard retained it. `ClipboardBridge.readText()` returns the current clipboard text. Failures set `lastError` and emit `operationFailed(code, message)`; successful writes emit `copied(text)`.

## SettingsStore

`SettingsStore` stores `settings.json` in a stable application directory named `leomoon-parsinegar` below `QStandardPaths::GenericConfigLocation`, which resolves to `~/.config/leomoon-parsinegar/settings.json` on Linux. Writes use `QSaveFile`. `load()` returns bounded UTF-8 text for `ReshaperSettings.js` to parse and recover, so C++ does not duplicate the JavaScript schema. `save(json)` accepts a valid JSON object without interpreting schema fields, but rejects payloads over 1 MiB and recursively rejects `draftText`, `sourceText`, `convertedText`, and `clipboardText` keys. Missing files are successful reads with `exists: false`.

## FileBridge

`FileBridge.readFont(url)` accepts an absolute local `file:` URL for a TTF, OTF, or TTC file and returns its exact bytes up to 50 MiB. It does not resolve a font family, substitute another font, access network URLs, or parse the font. `FileBridge.readTextDocument(url)` reads strict UTF-8 without normalizing line endings or final newlines, with limits of 250,000 UTF-16 code units and 1 MiB. `FileBridge.writeTextDocument(url, text)` writes the exact UTF-8 encoding through `QSaveFile`. `FileBridge.writeSvg(url, svg)` accepts an absolute local destination, appends `.svg` when needed, enforces a 16 MiB UTF-8 limit, and commits through `QSaveFile` without creating unspecified parent directories.

## Results and errors

File and settings calls return maps with `ok: true` plus operation values, or `ok: false` with stable `code` and user-safe `message` fields. Failures also emit `operationFailed(code, message)` and update `lastError`. Later QML controllers should localize messages by code and may log technical details without including editor text, clipboard contents, or font bytes.
