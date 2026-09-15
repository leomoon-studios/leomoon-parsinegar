# Source provenance

ParsiNegar Desktop begins from the tested host-independent components bundled with Omarchy ParsiNegar Express. The desktop project copies pinned artifacts rather than making the plugin a build or runtime dependency.

## Vendored artifact inventory

| Artifact | Pinned source | SHA-256 |
| --- | --- | --- |
| `vendor/js-bidi.js` | JsBidi v0.1.0, commit `f5e88b19cce608404d87d58c3cf23afadbd4b9c6` | `511c15b029312ce244e93bbf8595303416e261fe2c09131e15bdfc1f4f6da0fc` |
| `vendor/js-parsi-reshaper.js` | JsParsiReshaper v0.1.0, commit `9f7a6b36f639ccd569598ba386f2576e5e33dbe3` | `1834aeb06c640950836a63581e36f4233a6c858acab9fc40f41ae6ec448cf1e0` |
| `vendor/typr.js` | Typr.js commit `02c121057750d8ab607873c1b369e717e858a643` with the documented QML compatibility changes | `35ce7c53430510efdd18475fae79719985bc98e99c96fafe852e89dbd2a2dee1` |
| `assets/fonts/Vazirmatn[wght].ttf` | Vazirmatn v33.003, commit `83629f877e8f084cc07b47030b5d3a0ff06c76ec` | `696249a2c74b39ffdef55de4df2809c5b639d3ff80d618d8160a095d2fd49dca` |
| `assets/fonts/MaterialSymbolsRounded.ttf` | Material Symbols Rounded commit `40a7a292a79d9394157e1ea24f83d52d5e17c556`, subset to thirteen documented glyphs | `33ab18dce4e2ab9cceeadc1c062009ee9d21e15fcec496ae82a77eb858aaf5fc` |

The complete supplied notices and library documentation are retained below `vendor/js-bidi/`, `vendor/js-parsi-reshaper/`, `vendor/typr/`, and `assets/fonts/`. The Material Symbols subset contains U+E15A, U+E166, U+E247, U+E248, U+E2C4, U+E518, U+E51C, U+E5C4, U+E5C8, U+E873, U+E8B8, U+E8FD, and U+F10B; its unchanged full-font input had SHA-256 `f1472f172c0fc4a922be22972e4752ccc54fe795ed82564ab6f6b097782f2dbc`. The `tests/CheckLicenses.cmake` inventory prevents a known artifact or required notice from being omitted accidentally.

## Application behavior reference

The conversion core is pinned to LeoMoon Studios' ParsiNegar commit `09745df108c4f809575c6788d899bf867cd32c31`. `qml/core/ParsiNegar.js`, `TextTools.js`, and `ResourceLimits.js` remain byte-for-byte copies of the tested host-independent files from Omarchy ParsiNegar Express. `ReshaperSettings.js` adds desktop-only persisted options, and `InterfaceStrings.js` adds desktop shell and settings-status labels while retaining the plugin's shared conversion, text-tool, and settings labels. `tests/fixtures/ParsiNegarFixtures.js` preserves the plugin's 213 ordered Maryam pairs, 42 hand-derived conversion cases, rule-stage fixtures, and original 69-line editor corpus.

The native `tests/core_tests.cpp` harness loads the embedded production scripts, the unchanged JsBidi and JsParsiReshaper builds, and the fixture oracle through `QJSEngine`. `tests/CoreTests.js` contains the runtime-neutral assertions ported from the plugin's Node.js conversion, settings, and resource-limit suites.

## Update procedure

Dependency updates are deliberate source changes. Record the upstream version and commit, replace the artifact and its supplied notices together, document local modifications, update the SHA-256 table, rerun the license inventory and resource smoke tests, and then rerun all dependency-specific behavior tests added in later steps.
