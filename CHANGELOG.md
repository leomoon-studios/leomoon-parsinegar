# Changelog

## 3.0.1 (2026-09-22)

- Added persistent accent-color presets in Settings, including a neutral option.
- Kept the source editor focused during on-screen keyboard and mouse interactions.
- Fixed the extra cursor that appeared in mixed right-to-left and left-to-right text.
- Adjusted paired on-screen keyboard punctuation for the current paragraph direction while keeping ornate bracket keys in a consistent order.
- Matched the SVG export Fill Color and Variable Axes fields to the application theme.
- Made the Linux AppImage use the desktop portal file picker when available.
- Fixed pasting copied text over the same selected text so the selection clears and subsequent pastes insert another copy.
- Added permanent status bars to the editor and SVG export pages, with a neutral Ready state when idle.

## 3.0.0 (2026-09-20)

- Rebuilt ParsiNegar as an open-source, standalone Qt 6 desktop application using C++, QML, and JavaScript for Linux, Windows, and macOS.
- Ported the Unicode and Maryam/LMN compatibility conversion algorithms, with shaping profiles for Persian and Arabic, Kurdish and Urdu, and Unicode-only Hebrew.
- Added automatic paragraph direction, optional bidi visual ordering, and the special VideoStudio Pro conversion option.
- Added a desktop editor with plain-text document opening and saving, undo and redo, font-size adjustment, keyboard shortcuts, and an on-screen keyboard.
- Added text tools for cleaning and transforming source text before conversion.
- Added exact-font SVG curve export with a searchable installed-font selector, font previews, and missing-glyph feedback.
- Added English, Persian, and Arabic interface translations and persistent preferences without saving draft text or clipboard contents.
- Bundled compatibility fonts and added native packaging for Linux x86_64 and ARM64, Windows x64 and ARM64, and universal Intel and Apple Silicon macOS.
- Added system-wide font installation and desktop-shortcut options to the Windows and macOS installers, plus a separate optional font package for Ubuntu.
- Added automated builds, tests, package smoke tests, checksums, and GitHub releases triggered by version tags.
- Improved the layout on smaller screens.

## 2.1.9 (2022-12-17)

- Added an option to skip fonts when installing ParsiNegar on Windows.
- Added the Options menu.
- Added Reverse Words (Recommended for Most Graphical Suites) under Options.
- Moved Special Convert for VideoStudio to Options.
- Added Reset Options to Defaults under Options, with the `Ctrl+R` shortcut.
- Added automatic saving and loading of the last-used font type and size.
- Improved Help.

## 2.1.8 (2022-08-01)

- Fixed «ﻔ» not displaying correctly.
- Fixed «ﷲ» ligature not displaying correctly.
- Fixed other font display issues.
- Changed all font styles from Normal to Regular.
- Improved display of multiple diacritics.
- Added a Persian interface with the `Ctrl+L` shortcut.
- Added the «LMN Avvali.ttf» font.
- Added the «ﮥ» ligature for both algorithms.
- Added `Alt+H` to show all toolbars.
- Added `Ctrl+H` to hide all toolbars.
- Added `Ctrl+Alt+N` to replace digits with English digits.
- Added `Ctrl+Shift+N` to replace digits with Persian digits.

## 2.1.7 (2021-10-05)

- Added cross-platform automatic dark mode.
- Added Dark Mode under View, with the `Ctrl+M` shortcut.
- Updated all dependencies.

## 2.1.6 (2020-12-19)

- Fixed compatibility with macOS Big Sur.
- Changed the minimum supported macOS version to 10.14 Mojave.
- Fixed the Windows setup uninstall icon.
- Updated all dependencies.

## 2.1.5 (2020-11-16)

- Fixed text display when using the on-screen keyboard on macOS.
- Made ParsiNegar fonts embeddable.
- Improved the conversion algorithms.
- Improved the export modules.
- Added EPS export.

## 2.1.4 (2020-05-20)

- Fixed a crash on Windows 10 update 1909.
- Updated all dependencies.

## 2.1.3

- Updated the core to the latest version.
- Updated all dependencies.
- Embedded the main font in the application.
- Improved on-screen keyboard text on macOS.
- Fixed intermittent DPI scaling issues.
- Changed the minimum supported macOS version to 10.13.

## 2.1.2

- Made minor changes.
- Digitally signed the Windows binary.

## 2.1.1

- Optimized the text rendering engine.
- Added more tools under the Tools menu:
  - Convert «ی» to «ي».
  - Convert «ک» to «ك».
  - Convert «هٔ» to «ه‌ی».
  - Convert numbers to English.
  - Convert to English quotation marks.
  - Remove all Harekats (diacritics).
  - Remove all Keshide characters (Tatweel).

## 2.1.0

- Rewrote the text-to-path module:
  - Added PDF text-to-path export.
  - Added PS text-to-path export.
  - Added SVG text-to-path export.
- Added Special Convert for VideoStudio Pro under Tools.
- Added saving of the last-used folder.
- Added saving of the last-used style.
- Added saving of view options.
- Added an About window.
- Improved Help documentation.
- Improved the Unicode conversion algorithm.

## 2.0.1

- Made minor UI changes.
- Fixed minor bugs.

## 2.0.0

- Rewrote ParsiNegar from scratch to support macOS.
- Made both algorithms three times faster.
- Added six styles and alignment tools.
- Simplified the UI.

## 1.50

- Added a Persian menu when the program is displayed in Persian.
- Added a «ه‌ی» to «هٔ» converter under Tools.
- Added a «&#34;ا» to «اً» converter under Tools.
- Added Edit/Fix ZWNJ Problems under Tools.
- Added «%» to «٪» conversion to the numbers-to-Persian-numbers converter.
- Added elevated privileges to ParsiNegar Editor.
- Fixed Windows 8+ settings problems.
- Fixed the gap between characters when exporting to vector formats.
- Fixed a `.lpn` save problem when exiting the program.
- Fixed a `.lpn` save problem on Windows 8+.
- Fixed the “ParsiNegar cannot write at its root folder” error on Windows 8+.
