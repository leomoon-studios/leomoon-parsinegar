# JsBidi

A dependency-free vanilla JavaScript library for Unicode bidirectional display ordering and mirroring. Maintained by LeoMoon Studios.

## Download and use

Download the files from [release v0.1.0](https://github.com/leomoon-studios/js-bidi/releases/tag/v0.1.0), or find them in `dist/` in this repository. No build command, npm installation, Python, or framework is needed to use the standalone library. Each format is self-contained and includes the full license notices.

| File | Use |
| --- | --- |
| `js-bidi.js` | Classic browser script; exposes only `JsBidi` |
| `js-bidi.mjs` | ES module with default and named exports |
| `js-bidi.cjs` | CommonJS module |
| `SHA256SUMS` | SHA-256 checksums for all three builds |

### Browser script

Place the downloaded file next to your HTML page:

```html
<script src="js-bidi.js"></script>
<script>
  var visualText = JsBidi.getDisplay("پارسی ۱۲۳");
</script>
```

### ES module

```js
import JsBidi, { getDisplay } from "./js-bidi.mjs";

const visualText = getDisplay("پارسی ۱۲۳");
```

### CommonJS

```js
const JsBidi = require("./js-bidi.cjs");

const visualText = JsBidi.getDisplay("پارسی ۱۲۳");
```

The ESM and CommonJS formats expose the same API as the classic script. Package-name imports also work when installed from a locally packed tarball. This release is distributed through GitHub; it has not been published to the npm registry.

Verify downloaded files with `sha256sum --check SHA256SUMS` in their directory. For source code, use GitHub's release source archives or clone the repository.

## API contract

| Function | Result |
| --- | --- |
| `getBaseLevel(text, options?)` | `0` for LTR or `1` for RTL |
| `getDisplay(text, options?)` | A string in visual display order |

Both functions accept the same options object:

| Option | Default | Meaning |
| --- | --- | --- |
| `baseDir` | `null` | `"L"` or `"R"` forces the base level; `null` detects the first strong character, falling back to LTR |
| `upperIsRtl` | `false` | Treat Unicode uppercase characters as strong RTL characters, following the upstream test convention |

The base-direction override on `getBaseLevel` is a deliberate API extension to the original helper. Auto detection follows the selected source algorithm's whole-input scan; independent paragraph detection is not promised.

Inputs must be primitive strings. Invalid text or option types and unknown option names throw `TypeError`; an invalid `baseDir` throws `RangeError`. Omitted or `undefined` options use defaults; an explicitly null options object is invalid. Calls must not mutate options.

The algorithm performs bidi ordering and mirroring. Contextual reshaping for Persian (Parsi), Arabic, and other supported Arabic-script languages belongs to the separate JsParsiReshaper library. Byte decoding, file access, and application-specific remapping are outside this API.

The legacy algorithm does not implement modern bidi isolates or the modern paired-bracket rule N0. Both public methods reject LRI/RLI/FSI/PDI anywhere in the input, including with a forced base direction, with error code `ERR_BIDI_UNSUPPORTED_ISOLATE`. The error also carries `codePoint` and a zero-based code-point `index` (not a UTF-16 offset).

Hard-line reordering uses B-class paragraph separators, including CR, LF, and U+2029; it does not calculate soft wrapping. X9 removes embedding/override controls, PDF, and BN characters, including ZWJ/ZWNJ. Combining marks participate in code-point reordering; this is not a grapheme-cluster-preserving transform. Contextual shaping and any mark-placement options belong to the separate reshaper, before bidi ordering. A pinned Unicode database does not imply full conformance to that Unicode version's bidi algorithm.

## Contributing and security

Contributor tools use Node.js 22 or newer; this is not a runtime dependency. No dependency installation is needed.

```sh
node --test
node scripts/check-no-python.cjs
node scripts/build.cjs --check
node scripts/check-package.cjs
node scripts/check-browser.cjs
```

Checks cover all 46 exact-output fixtures in source, classic, ESM, CommonJS, and a real browser, plus data integrity, API validation, and offline package use. The browser check needs Chrome/Chromium and runs with Node/npm unavailable on its PATH. Raw references stay in the Git repository for contributor verification and are excluded from consumer packages.

See [CONTRIBUTING.md](CONTRIBUTING.md) for development and release instructions, [CHANGELOG.md](CHANGELOG.md) for changes, and [SECURITY.md](SECURITY.md) for private vulnerability reporting. General questions and bug reports go to [Issues](https://github.com/leomoon-studios/js-bidi/issues).

## Unicode data layer

The generated table contains 1,239 bidi ranges, 428 directed mirror mappings, 114 Bidi_Mirrored ranges, and 656 Uppercase ranges (about 60 KB of plain JS). Pinned inputs, original notices, download URLs, and SHA-256 checksums are included in the repository's contributor reference directory.

For internal development, load `src/unicode-data.js` followed by `src/unicode.js`. They expose the internal namespaces `JsBidiUnicodeData` and `JsBidiUnicode`, not additional public JsBidi APIs. The latter provides `getBidiClass(cp)`, `mirrorCodePoint(cp)`, `isMirrored(cp)`, `isUppercase(cp)`, and `toCodePoints(text)`. Lookup arguments are integer code points from 0 to 0x10FFFF, including surrogate code points. Non-numbers throw TypeError; invalid numbers throw RangeError. `toCodePoints` accepts only primitive strings, combines valid UTF-16 pairs, and preserves lone surrogate code units without normalization or replacement.

Bidi lookup applies the UCD's specialized unassigned defaults, not just LTR. Mirror lookup returns the input unchanged when no substitution exists, even if the character has a mirrored glyph. Uppercase uses the Unicode property rather than ASCII-only or host-dependent casing. Isolate classes are represented in the data but are explicitly rejected by the legacy conversion algorithm.

## Layout

```text
src/js-bidi.js          Public vanilla JS API and argument validation
src/algorithm.js        Internal named stages of the pure legacy bidi algorithm
src/unicode-data.js     Generated, immutable Unicode 16.0.0 tables
src/unicode.js          Host-independent internal lookup/UTF-16 helpers
test/                  Node contributor tests
test/fixtures/         Static input and expected-output corpus
reference/             Pinned contributor reference data
reference/ucd/         Unmodified UCD inputs and checksum manifest
scripts/               Contributor-only generation, packaging, and verification
dist/                  Self-contained classic, ESM, CommonJS builds and checksums
LICENSE                LGPLv3 license text
COPYING                Accompanying GPLv3 license text
UNICODE-LICENSE.txt     Unicode data license text
```

## License

LGPL-3.0-or-later. See [LICENSE](LICENSE) and the accompanying [COPYING](COPYING). Upstream test cases retain attribution to Yaacov Zamir and Meir Kriheli. The JavaScript API and additional tests are Copyright (c) 2026 LeoMoon Studios.

Unicode inputs and generated Unicode tables are covered by [Unicode License V3](UNICODE-LICENSE.txt); retain that notice with copies of the tables.
