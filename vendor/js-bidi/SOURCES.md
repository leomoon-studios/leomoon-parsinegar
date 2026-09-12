# Source and behavior pins

## Translation source

JsBidi is derived from python-bidi 0.6.11.

Repository: https://github.com/MeirKriheli/python-bidi

Commit: `3ed1dc9e7f60179d4215d0513d6bbfe0bc5c5c94`

Algorithm: [bidi/algorithm.py](https://github.com/MeirKriheli/python-bidi/blob/3ed1dc9e7f60179d4215d0513d6bbfe0bc5c5c94/bidi/algorithm.py)

Mirroring baseline: [bidi/mirror.py](https://github.com/MeirKriheli/python-bidi/blob/3ed1dc9e7f60179d4215d0513d6bbfe0bc5c5c94/bidi/mirror.py)

Fixture source: [tests/test_python_bidi.py](https://github.com/MeirKriheli/python-bidi/blob/3ed1dc9e7f60179d4215d0513d6bbfe0bc5c5c94/tests/test_python_bidi.py)

The translation uses the pure algorithm. The original source imports Unicode properties from its host Python interpreter, so python-bidi 0.6.11 does not itself pin a Unicode database.

## Unicode data target

The JS tables use **Unicode 16.0.0** for reproducible behavior. The [Unicode 16.0.0 UCD ReadMe](https://www.unicode.org/Public/16.0.0/ucd/ReadMe.txt) identifies the final versioned data. The unchanged upstream inputs and their locally calculated SHA-256 checksums are recorded in [the input manifest](reference/ucd/manifest.json), together with the [Unicode license notice](UNICODE-LICENSE.txt).

Reference files include `extracted/DerivedBidiClass.txt`, `BidiMirroring.txt`, `UnicodeData.txt`, and `DerivedCoreProperties.txt` (the Uppercase property is needed to match the Unicode-aware upstream `isupper()` behavior). The data layer uses these pinned inputs rather than host-engine Unicode properties.

Intentional data differences from upstream Python behavior:

- Unassigned code points follow `DerivedBidiClass.txt`'s ordered `@missing` defaults and explicit overrides. Python's `unicodedata.bidirectional` can return an empty class for unassigned points; the port always returns a defined UCD class.
- Character substitutions follow all 428 directed mappings in Unicode 16.0.0 `BidiMirroring.txt`, rather than freezing the hand-maintained upstream `bidi/mirror.py` dictionary. Bidi_Mirrored is separately generated from `UnicodeData.txt`, because not every mirrored glyph has a substitute code point.
- Uppercase follows the pinned `Uppercase` property, including supplementary characters, rather than whichever Unicode database a Python installation provides.

These choices are deliberate and do not claim identical output to every Python/Unicode version. The translated algorithm passes all 30 scoped static upstream fixtures.

## Implemented behavior and limits

The port follows base-level detection, embedding/override handling with the source limit of 62 (explicit levels below 62, implicit levels may reach 62), weak/neutral resolution, implicit levels, line reordering, and mirroring. It preserves full supplementary code points, the selected source's whole-input base scan, and its B-class hard-line handling. Uppercase-as-RTL is a transformation option; the debug logger itself is excluded.

Modern isolate controls LRI/RLI/FSI/PDI and the modern paired-bracket rule N0 are outside the selected algorithm. Both public methods reject isolates throughout the input with `ERR_BIDI_UNSUPPORTED_ISOLATE`, even after the first strong character or under an override. The error includes the numeric `codePoint` and zero-based code-point `index`. This is a deliberate fail-fast extension, instead of the source's later assertion failure or unsupported base scan. No claim of full Unicode 16 bidi conformance is made. Arabic joining and glyph shaping are outside JsBidi.

The source has no separate grapheme-preserving L3 stage: combining marks participate in its code-point reordering. The port retains that behavior, as well as X9 removal of BN characters (including ZWJ and ZWNJ). Applications that need contextual shaping should perform it before bidi ordering. Lone UTF-16 surrogate code units are preserved; valid pairs are combined into a single stored code point. B-class separators remain in place during per-line L2 reversal; segment separators receive L1 resets but do not establish extra line boundaries. No soft-line layout is performed.

Named stages in `src/algorithm.js` operate on plain storage with `baseLevel`, `baseDir`, `chars`, and `runs`. Each character has `cp`, `level`, `type`, and `orig`. The `JsBidiAlgorithm` namespace exists for internal composition/testing, not as a stable public API. JavaScript arrays replace Python deques and slices, and in-place swaps perform range reversal without splitting surrogate pairs or using argument-count-limited spread calls.

## Fixture provenance and exclusions

`test/fixtures/bidi.json` holds literal strings and numeric code-point arrays. The upstream cases include all active string-output examples from the pinned test file. CapRTL markers in explicit-control examples are decoded into actual Unicode controls. The encoding test is adapted to its decoded Hebrew string; the byte/CP1255 API is excluded. The source's commented known-failing example is excluded and is not counted as a passing case. The internal-storage test is represented by the surrogate output case and assertions on its stored code points, original classes, and resolved levels.

Additional fixtures are hand-derived expectations for simple strings and controls; they are not claimed to be Python-generated. Each fixture declares its origin and either the upstream test name or a rationale. Optional base-level expectations target the documented JsBidi contract, including the deliberate baseDir override extension.

The fixtures include a two-line Persian excerpt from Saadi's public-domain Bani Adam poem, with hand-derived line-wise expected output and exact code-point arrays. It tests ordering without claiming shaped glyph output. Additional stage tests use labeled synthetic bidi types to isolate X, W, N, I, and L rules; their expectations are derived from the pinned algorithm, not from executing Python.

## Attribution and modifications

python-bidi and its tests are LGPL-3.0-or-later, Copyright (C) 2008–2010 Yaacov Zamir and subsequent Meir Kriheli contributions. The original `COPYING.LESSER` text is reproduced unchanged as root `LICENSE`, with the accompanying GPLv3 text in root `COPYING`.

JavaScript translation and modifications by LeoMoon Studios, 2026-09-07: camelCase options, strict argument validation, early isolate rejection, pinned Unicode tables, Unicode-safe character storage, and additional regression tests.

The offline JavaScript generator verifies pinned Unicode inputs and produces static tables. Raw UCD files retain their upstream headers; generated data retains attribution and the associated Unicode license. Tests verify every code-point lookup and all conversion fixtures without executing Python.

Readable classic, ESM, and CommonJS distributions are generated from the same platform-independent JavaScript source files.
