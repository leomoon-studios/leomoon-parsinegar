# Third-party notices

ParsiNegar Desktop embeds independently replaceable JavaScript libraries, a UI font, and an icon font. It performs no runtime downloads. The root [MIT license](LICENSE) covers original LeoMoon Studios desktop code, while the components below retain their own terms.

## JsBidi

[JsBidi v0.1.0](https://github.com/leomoon-studios/js-bidi/releases/tag/v0.1.0) provides Unicode bidirectional display ordering and is distributed under LGPL-3.0-or-later. The unchanged classic build is `vendor/js-bidi.js`. Its LGPL text, accompanying GPL text, Unicode notice, README, source/modification notes, and embedded copyright notices are retained under `vendor/js-bidi/`. Exact source is available at commit `f5e88b19cce608404d87d58c3cf23afadbd4b9c6`.

## JsParsiReshaper

[JsParsiReshaper v0.1.0](https://github.com/leomoon-studios/js-parsi-reshaper/releases/tag/v0.1.0) provides contextual reshaping for Persian, Arabic, Kurdish, Urdu, and other supported Arabic-script languages. The unchanged classic build is `vendor/js-parsi-reshaper.js` and is distributed under the MIT license retained with its README and source/modification notes under `vendor/js-parsi-reshaper/`. Exact source is available at commit `9f7a6b36f639ccd569598ba386f2576e5e33dbe3`.

## Typr.js

[Typr.js](https://github.com/photopea/Typr.js) supplies the font parser and outline reader used by SVG curve export. `vendor/typr.js` combines upstream `src/Typr.js` and `src/Typr.U.js` from commit `02c121057750d8ab607873c1b369e717e858a643`. It is distributed under the MIT license retained with its README under `vendor/typr/`.

The vendored Typr.js file is copied from Omarchy ParsiNegar Express and retains that integration's compatibility changes: parser debug output is removed, one `String.replaceAll` call uses an equivalent `split` and `join`, and optional `TextDecoder`, `TextEncoder`, and `UPNG` globals are accessed without assuming a browser `window`. Optional HarfBuzz, bitmap, color-font, canvas, and network paths are not used.

## Vazirmatn

The application bundles the unchanged variable font from [Vazirmatn v33.003](https://github.com/rastikerdar/vazirmatn/releases/tag/v33.003), source commit `83629f877e8f084cc07b47030b5d3a0ff06c76ec`. Copyright 2015 The Vazirmatn Project Authors. The complete SIL Open Font License 1.1 is retained at `assets/fonts/OFL.txt`.

Bundled file: `assets/fonts/Vazirmatn[wght].ttf`. The font supports regular, medium, and semibold UI weights from one resource and does not need to be installed on the user's system.

## Material Symbols

The application bundles a subset of [Material Symbols Rounded](https://github.com/google/material-design-icons) from commit `40a7a292a79d9394157e1ea24f83d52d5e17c556`. Copyright Google LLC. Material Symbols is distributed under the Apache License 2.0 retained at `assets/fonts/MaterialSymbols-LICENSE.txt`.

Bundled file: `assets/fonts/MaterialSymbolsRounded.ttf`. It was generated from the unchanged upstream variable font with fonttools `pyftsubset` and contains only settings, light mode, dark mode, export, text tools, undo, redo, back, forward, left-to-right text direction, and right-to-left text direction glyphs. No outlines were modified.

## Replacement and redistribution

Keep every artifact paired with the license and notices named in `tests/CheckLicenses.cmake`. Any replacement must preserve applicable notices, update the pinned source and checksum record in `SOURCES.md`, and pass the license inventory plus the relevant behavior tests. Qt itself is not copied into the source tree; deployment and LGPL compliance for dynamically linked Qt will be addressed with platform packaging.
