# JsParsiReshaper

A standalone, dependency-free vanilla JavaScript library for contextual reshaping of Persian (Parsi), Arabic, and other supported Arabic-script languages, including Kurdish and Urdu. Maintained by LeoMoon Studios.

## Download and use

Download the files from [release v0.1.0](https://github.com/leomoon-studios/js-parsi-reshaper/releases/tag/v0.1.0), or find them in `dist/` in this repository. No build command, npm installation, Python, or framework is needed to use the standalone library. Each format is self-contained and includes the full license notices.

| File | Use |
| --- | --- |
| `js-parsi-reshaper.js` | Classic browser script; exposes only `JsParsiReshaper` |
| `js-parsi-reshaper.mjs` | ES module with default and named exports |
| `js-parsi-reshaper.cjs` | CommonJS module |
| `SHA256SUMS` | SHA-256 checksums for all three builds |

### Browser script

Place the downloaded file next to your HTML page:

```html
<script src="js-parsi-reshaper.js"></script>
<script>
  var shapedText = JsParsiReshaper.reshape("سلام");
</script>
```

### ES module

```js
import JsParsiReshaper, { reshape } from "./js-parsi-reshaper.mjs";

const shapedText = reshape("سلام");
```

### CommonJS

```js
const JsParsiReshaper = require("./js-parsi-reshaper.cjs");

const shapedText = JsParsiReshaper.reshape("سلام");
```

The ESM and CommonJS formats expose the same API as the classic script. Package-name imports also work when installed from a locally packed tarball. This release is distributed through GitHub; it has not been published to the npm registry.

Verify downloaded files with `sha256sum --check SHA256SUMS` in their directory. For source code, use GitHub's release source archives or clone the repository.

## API contract

`JsParsiReshaper.reshape(text, options?)` returns contextually shaped text in logical order. Bidi display ordering is a separate operation, provided by JsBidi. Persian (Parsi) uses the default table, whose API identifier is `"Arabic"`. Hebrew does not require this contextual shaping stage.

| Option | Default | Meaning |
| --- | --- | --- |
| `language` | `"Arabic"` | Exact table selector: `"Arabic"`, `"ArabicV2"`, or `"Kurdish"` |
| `deleteHarakat` | `true` | Remove vowel/diacritic marks |
| `shiftHarakatPosition` | `false` | Shift retained marks for subsequent bidi reversal |
| `deleteTatweel` | `false` | Remove U+0640 |
| `supportZWJ` | `true` | Honor U+200D joining influence before removing it |
| `useUnshapedInsteadOfIsolated` | `false` | Use the original letter instead of its isolated form |
| `supportLigatures` | `true` | Master ligature switch; false disables every substitution |
| `ligatures` | Upstream defaults | Partial object of exact ligature names to booleans |

Five ligatures are enabled by default: ALLAH and the four LAM WITH ALEF variants (plain, HAMZA ABOVE, HAMZA BELOW, MADDA ABOVE). All other defined ligatures are disabled. Preserve the full official keys such as `"ARABIC LIGATURE ALLAH"` and `"RIAL SIGN"`; these are not renamed to match the library's product name.

Text must be a primitive string. Non-string input, invalid option objects, non-boolean flags, unknown options, symbol keys, and unknown ligature names throw `TypeError`; unsupported language values throw `RangeError`. Names are case-sensitive. Omitted options and top-level `undefined` values use defaults; explicit null is invalid. Individual ligature values must be booleans, even if the master switch is disabled. Options use own properties only; merging copies the nested ligature map and does not mutate supplied objects or defaults. Python-style string booleans, snake_case options, top-level ligature flags, INI files, environment configuration, and font inspection are outside the JS contract.

## Shaping behavior

The engine selects isolated, initial, medial, and final forms; handles harakat, tatweel, and ZWJ options; then applies enabled ligatures in the pinned source order. Ligatures without the required contextual form are left unsubstituted. Disabling all individual ligatures safely performs ordinary shaping. Unsupported characters, including Hebrew, emoji, and line breaks, pass through and interrupt joining. Valid surrogate pairs stay intact; lone UTF-16 surrogates are preserved. No normalization, bidi reordering, or font inspection is performed.

Retained marks keep their position even when a ligature consumes several letters: empty replacement slots preserve mark anchors. There are two documented fixes relative to the pinned source: explicit text-to-output mappings prevent ligature offset errors after removed ZWJs, and marks attached to removed ZWJs move to the preceding surviving character (or the prefix) rather than being lost/displaced.

Other source conventions remain unchanged: ZWJ inside a ligature spelling is a matching barrier even when its joining influence is disabled; harakat are stripped from matching text, so mark-bearing ligature patterns cannot fire; shifted harakat before any output character fall at source position -2 and are omitted. The mark ranges are the pinned source's ranges, not a promise to recognize every Unicode combining mark.

## Data and source boundaries

The tables contain 78 `Arabic`, 80 `ArabicV2`, and 80 `Kurdish` letter entries and 286 ordered ligatures (3 sentence, 9 word, 274 letter entries). Four forms are always ordered isolated, initial, medial, final; empty forms mean unsupported forms. Duplicate patterns with different legacy names are retained, as is sentence → word → letter precedence. All tables are deeply immutable.

ArabicV2 and Kurdish tables contain font-specific choices, including private-use characters. They are not promises of support in every font. These are the source's hand-maintained tables, not a newly generated complete Unicode shaping database.

## Contributing and security

Contributor tools use Node.js 22 or newer; this is not a runtime dependency. No dependency installation is needed.

```sh
node --test
node scripts/check-no-python.cjs
node scripts/build.cjs --check
node scripts/check-package.cjs
node scripts/check-browser.cjs
```

Checks cover all 77 exact-output fixtures in source, classic, ESM, CommonJS, and a real browser, plus data integrity, API validation, and offline package use. The browser check needs Chrome/Chromium and runs with Node/npm unavailable on its PATH. Raw references stay in the Git repository for contributor verification and are excluded from consumer packages.

See [CONTRIBUTING.md](CONTRIBUTING.md) for development and release instructions, [CHANGELOG.md](CHANGELOG.md) for changes, and [SECURITY.md](SECURITY.md) for private vulnerability reporting. General questions and bug reports go to [Issues](https://github.com/leomoon-studios/js-parsi-reshaper/issues).

## Layout

```text
src/                   Vanilla JS data, configuration, shaping engine, and public API
test/fixtures/         Static inputs, expected outputs, code points, and provenance
test/                  Contributor-only Node tests
reference/upstream/    Unmodified source snapshots, never executed
reference/manifest.json Source URLs and locally calculated SHA-256 checksums
scripts/               Offline contributor-only generation and checks
dist/                  Self-contained classic, ESM, CommonJS builds and checksums
LICENSE                MIT license text
```

## License

MIT. Original source and tests: Copyright (c) 2019 Abdullah Diab. JavaScript translation, tooling, and additional tests: Copyright (c) 2026 LeoMoon Studios. Retain [the MIT license](LICENSE) with source or substantial copies, including generated data and release bundles.
