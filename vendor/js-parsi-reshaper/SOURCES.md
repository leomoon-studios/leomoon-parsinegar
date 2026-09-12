# Source and behavior pins

JsParsiReshaper is derived from [python-arabic-reshaper](https://github.com/mpcabd/python-arabic-reshaper), package metadata version **3.0.1**, commit `ed35ce471e78db680e3354ec4a5b5cc5ead092a2`.

The copied `pyproject.toml` says 3.0.1, while `arabic_reshaper/__version__.py` still says 3.0.0 in this same commit. The commit is the authoritative translation pin; 3.0.1 here refers to package metadata, not a claim that these two files agree.

[manifest.json](reference/manifest.json) records each source path, commit-pinned upstream URL, and SHA-256 checksum calculated from the local clean upstream checkout. The files under `reference/upstream/` and the root `LICENSE` are byte-for-byte copies. Generators verify all hashes before reading literal records. They never execute the Python files. No network, sibling checkout, Python interpreter, or package installation is needed to reproduce the JS tables and fixtures.

## Included references

- `letters.py`: UNSHAPED=255, ISOLATED=0, INITIAL=1, MEDIAL=2, FINAL=3, TATWEEL, ZWJ, and all Arabic (78), ArabicV2 (80), and Kurdish (80) table entries.
- `ligatures.py`: all 286 definitions, names, four-form records, regex patterns, and sentence/word/letter ordering. Legacy aliases with duplicate patterns remain.
- `reshaper_config.py`: all 294 default entries, including language, six boolean settings, 286 defined ligature flags, and one orphan flag.
- `arabic_reshaper.py`: read-only reference for the engine's HARAKAT_RE, joining/ligature mechanics, mark handling, and output assembly.
- `tests/test_001_initialization.py`: default-configuration test reference.
- `tests/test_002_reshaping.py` and `tests/test_003_reshaping.py`: all 69 active input/output pairs, including harakat, ZWJ, ligatures, and Kurdish-text examples.
- `pyproject.toml`, `__version__.py`, and root `LICENSE`: version and license evidence.

Official Arabic letter/glyph names and source constants remain unchanged in the snapshots and applicable JS identifiers/ligature keys. The public library name is JsParsiReshaper. Its tables describe the pinned source's behavior, not full coverage of a newer Unicode Character Database. In particular, ArabicV2 and Kurdish retain font-specific and private-use forms.

## Options and exclusions

The JS contract uses `language`, `deleteHarakat`, `shiftHarakatPosition`, `deleteTatweel`, `supportZWJ`, `useUnshapedInsteadOfIsolated`, `supportLigatures`, and a nested `ligatures` boolean map. Defaults match the source. Partial overrides are copied, never merged into global state. The master ligature switch gates effective matching without destroying individual flags.

Intentional API differences:

- Only primitive strings and strict boolean options are accepted. The source's falsy-input shortcut and ConfigParser boolean coercions are not part of this API.
- Languages are exact `Arabic`, `ArabicV2`, or `Kurdish`; unknown languages are rejected instead of silently falling back to Arabic.
- Ligature keys are exact and case-sensitive, placed inside `options.ligatures`. Python ConfigParser case-folding and permissive unknown settings are excluded.
- The orphan default `ARABIC LIGATURE SHADDA WITH SUPERSCRIPT ALEF ISOLATED FORM` has no entry in LIGATURES. It is preserved in the raw/generated DEFAULT_CONFIG but rejected as a public override. Use the defined `ARABIC LIGATURE SHADDA WITH SUPERSCRIPT ALEF` key instead; no alias is invented.
- File paths, INI configuration, environment variables, Python class construction, `config_for_true_type_font`, fontTools, font scanning, and its ENABLE_* selection bitmasks are excluded from the standard JavaScript API. Applications can pass explicit options based on their own font knowledge.

Contextual shaping retains logical character order. Bidirectional display ordering is a separate operation that applications can perform after shaping. Empty strings return empty strings; invalid text or options are rejected before any shaping begins.

## Engine compatibility and deliberate fixes

`src/engine.js` exposes named internal stages for collecting/joining characters, selecting ligature forms, applying substitutions, and assembling output. Each output slot carries its original-or-replacement letter, form, mark array, and compacted index. Matching text has a separate code-point-to-slot map, plus a UTF-16-boundary map for JavaScript RegExp offsets. These are internal structures, not new public APIs. All runtime logic is ordinary JavaScript.

The pinned source's cleaned ligature text removes harakat and optionally tatweel, but retains ZWJ. Its output list removes ZWJ, yet `output[a]` and `output[b-1]` use offsets from that cleaned text directly. Therefore a ZWJ before a match can misalign or exceed output indices. The port deliberately fixes this using explicit slot references. For example, a leading supported ZWJ followed by LAM-ALEF safely selects the final ligature U+FEFC, and supplementary characters before a match do not shift its output target.

The source also stores harakat under integer output positions before popping ZWJ entries. Marks on those entries can be lost or displaced. The port anchors marks to slots and transfers marks from a removed ZWJ to the preceding surviving slot, or to the prefix when none exists. For example, BEH + ZWJ + FATHA with marks kept produces U+FE91 U+064E. These are targeted correctness fixes, not claims of exact parity with source bugs. All 69 transcribed upstream examples remain unchanged and pass; explicit hand-derived regression tests cover the fixes.

Preserved source conventions and limitations:

- All nine HARAKAT_RE ranges are preserved by their exact union, including U+08E2 in the overlapping U+08D4–U+08FF region. This is not a current Unicode property lookup or a complete grapheme-cluster engine.
- Harakat are transparent to joining. Retained mark order is reversed within an anchor when shifting is enabled. Leading shifted marks at position -2 are omitted, as in the source; ordinary leading retained marks use the prefix.
- ZWJ influences joining only when enabled and is always removed from output. It remains a barrier in the ligature-matching text under both settings. ZWNJ is unsupported text: it is preserved and breaks joining.
- Ligature matching strips harakat regardless of whether they will be retained in output. Consequently mark-bearing ligature definitions stay available as data but cannot match in this pipeline. No new mark-ligature behavior is invented.
- Enabled alternatives retain sentence/word/letter source order, including alias patterns, and matches are non-overlapping. No extra sorting by string length is performed. A match without the needed form is skipped without retrying another alternative at that same position.
- Replacement padding retains output slots and their marks through every match; assembly skips empty letters but still emits marks attached to them.
- With zero enabled ligatures, the port skips regex matching entirely instead of constructing the source's empty pattern. Unsupported characters, valid supplementary pairs, lone surrogates, and line breaks are preserved.

## Fixture transcription

`test/fixtures/reshaper.json` contains 69 upstream and 8 labeled hand-derived cases. Inputs and expected outputs are literal strings with numeric code-point arrays. The source-transcription tool only copies literal pairs, resolves the fixed BEH/ALEF/HAMZA/ZWJ test constants, and translates option names. It does not compute expected output using a reshaping implementation.

The upstream ligature test's `ARABIC LIGATURE ALLAH ` key has a trailing space. Its JS fixture uses the canonical name and records this adaptation; ALLAH is already enabled by default. The three Kurdish-text examples in test_003 use the source's default Arabic configuration, not the Kurdish table; this distinction is retained. Supplemental cases independently cover the Kurdish selector, ArabicV2, Persian PEH, unshaped isolated forms, tatweel deletion, disabled ZWJ, empty input, and supplementary characters.

Tests verify fixture integrity and compare actual engine output against all 77 fixtures with exact code-point equality. Additional tests exercise every letter pair, the full form-selection matrix, real ligatures in all four contexts, ZWJ/mark corrections, tatweel deletion, Unicode-safe offsets, unsupported text, and large inputs. No expected fixture was changed to accommodate the engine. Do not regenerate expected outputs from the implementation to make a failing conversion test pass.

## Attribution

Original code, tables, and tests: Copyright (c) 2019 Abdullah Diab, MIT. The complete original license is retained at root `LICENSE`. JavaScript translation, strict API boundary, contributor tooling, and added tests: Copyright (c) 2026 LeoMoon Studios, MIT. Source files support reproducible regeneration of the distributed tables and fixtures.
