// Runs inside QJSEngine. It intentionally has no Node.js or filesystem dependency.
var CoreTestResults;

(function () {
    "use strict";

    var passed = 0;
    var total = 0;
    var failures = [];

    function fail(message) {
        throw new Error(message);
    }

    function assert(value, message) {
        if (!value) fail(message || "Expected a truthy value");
    }

    function equal(actual, expected, message) {
        if (actual !== expected) {
            fail((message ? message + ": " : "") + "expected " + JSON.stringify(expected) + ", received " + JSON.stringify(actual));
        }
    }

    function jsonEqual(actual, expected, message) {
        equal(JSON.stringify(actual), JSON.stringify(expected), message);
    }

    function expectThrows(callback, expected) {
        try {
            callback();
        } catch (error) {
            if (expected && expected.code !== undefined) equal(error.code, expected.code, "exception code");
            if (expected && expected.name !== undefined) equal(error.name, expected.name, "exception name");
            return error;
        }
        fail("Expected callback to throw");
    }

    function test(name, callback) {
        total++;
        try {
            callback();
            passed++;
        } catch (error) {
            failures.push(name + ": " + String(error && error.stack || error));
        }
    }

    function copy(value) {
        return JSON.parse(JSON.stringify(value));
    }

    var core = ParsiNegar;
    var bidi = JsBidi;
    var reshaper = JsParsiReshaper;
    var fixtureData = ParsiNegarFixtures;
    var fixtures = fixtureData.conversion;
    var maryam = fixtureData.maryam;
    var settings = ReshaperSettings;
    var textTools = TextTools;
    var textToolFixtures = TextToolsFixtures;
    var sourceHistory = SourceHistory;
    var metadata = settings.metadata;
    var strings = InterfaceStrings;
    var limits = ResourceLimits;

    test("text tools expose the complete shared operation set", function () {
        equal(textTools.operations.length, 15);
        assert(Object.isFrozen(textTools));
        equal(textTools.applyOne("يى ك", "arabicYehToPersian"), "یی ك");
        equal(textTools.applyOne("ك", "arabicKafToPersian"), "ک");
    });

    test("text-tool reverse pairs are mutually exclusive", function () {
        var state = textTools.withToggled({}, "persianDigits");
        state = textTools.withToggled(state, "englishDigits");
        equal(state.persianDigits, false);
        equal(state.englishDigits, true);
        state = textTools.copyState({ persianQuotes: true, englishQuotes: true });
        equal(state.persianQuotes, true);
        equal(state.englishQuotes, false);
    });

    test("text tools preserve newlines and use verb-aware ZWNJ repair", function () {
        var result = textTools.applyEnabled("می روم\n\nنمیخواستند میدان 12%", {
            repairZwnj: true,
            persianDigits: true
        });
        equal(result.text, "می‌روم\n\nنمی‌خواستند میدان ۱۲٪");
        jsonEqual(copy(result.applied), ["persianDigits", "repairZwnj"]);
    });

    test("text-tool fixtures are versioned and hand-reviewed", function () {
        equal(textToolFixtures.schemaVersion, 1);
        equal(textToolFixtures.source.kind, "hand-reviewed");
        equal(textToolFixtures.cases.length, textTools.operations.length);
        var seen = {};
        textToolFixtures.cases.forEach(function (fixture) {
            assert(fixture.rationale.length > 20, fixture.id + " rationale");
            assert(!seen[fixture.operation], "duplicate fixture for " + fixture.operation);
            seen[fixture.operation] = true;
        });
        textTools.operations.forEach(function (operation) {
            assert(seen[operation.id], "missing fixture for " + operation.id);
            ["en", "fa", "ar"].forEach(function (language) {
                assert(strings.text(language, operation.labelKey) !== operation.labelKey, language + " label " + operation.id);
                assert(strings.text(language, operation.descriptionKey) !== operation.descriptionKey, language + " description " + operation.id);
            });
        });
    });

    textToolFixtures.cases.forEach(function (fixture) {
        test("text-tool fixture " + fixture.id, function () {
            var actual = textTools.applyOne(fixture.input, fixture.operation);
            equal(actual, fixture.expected);
            equal(textTools.applyOne(actual, fixture.operation), actual, "operation must be idempotent");
        });
    });

    test("enabled text tools use the documented operation order", function () {
        var fixture = textToolFixtures.orderedEnabled;
        var result = textTools.applyEnabled(fixture.input, fixture.enabled);
        equal(result.text, fixture.expected);
        jsonEqual(copy(result.applied), copy(fixture.applied));
    });

    test("source history is bounded and walks backward deterministically", function () {
        var history = sourceHistory.create({ text: "a", cursor: 1, anchor: 1 }, 2);
        history = sourceHistory.record(history, { text: "ab", cursor: 2, anchor: 2 });
        history = sourceHistory.record(history, { text: "abc", cursor: 3, anchor: 3 });
        history = sourceHistory.record(history, { text: "abcd", cursor: 4, anchor: 4 });
        equal(history.undo.length, 2);
        var first = sourceHistory.undo(history);
        equal(first.state.text, "abc");
        var second = sourceHistory.undo(first.history);
        equal(second.state.text, "ab");
        equal(sourceHistory.undo(second.history).changed, false);
    });

    test("source history restores cursor and selection through undo and redo", function () {
        var history = sourceHistory.create({ text: "alpha", cursor: 2, anchor: 0 }, 100);
        history = sourceHistory.record(history, { text: "alphabet", cursor: 8, anchor: 8 });
        var undone = sourceHistory.undo(history);
        jsonEqual(copy(undone.state), { text: "alpha", cursor: 2, anchor: 0 });
        var redone = sourceHistory.redo(undone.history);
        jsonEqual(copy(redone.state), { text: "alphabet", cursor: 8, anchor: 8 });
    });

    test("a divergent source edit clears redo history", function () {
        var history = sourceHistory.create({ text: "a", cursor: 1, anchor: 1 }, 100);
        history = sourceHistory.record(history, { text: "ab", cursor: 2, anchor: 2 });
        history = sourceHistory.record(history, { text: "abc", cursor: 3, anchor: 3 });
        history = sourceHistory.undo(history).history;
        assert(sourceHistory.canRedo(history));
        history = sourceHistory.record(history, { text: "abX", cursor: 3, anchor: 3 });
        assert(!sourceHistory.canRedo(history));
    });

    test("selection updates do not create source history entries", function () {
        var history = sourceHistory.create({ text: "alpha", cursor: 5, anchor: 5 }, 100);
        history = sourceHistory.updateSelection(history, 2, 0);
        equal(history.undo.length, 0);
        equal(history.current.cursor, 2);
        equal(history.current.anchor, 0);
    });

    test("core namespaces and APIs are immutable", function () {
        assert(Object.isFrozen(core), "ParsiNegar must be frozen");
        assert(Object.isFrozen(settings), "ReshaperSettings must be frozen");
        assert(Object.isFrozen(limits), "ResourceLimits must be frozen");
        ["convert", "normalize", "applyCustomLigatures", "normalizeCompatibility", "mapMaryam"].forEach(function (name) {
            equal(typeof core[name], "function", name);
        });
    });

    test("pipeline order and explicit shaping flags", function () {
        var calls = [];
        var shaper = {
            reshape: function (text, options) {
                calls.push("reshape");
                equal(text, "ی اً\nپ");
                jsonEqual(copy(options), {
                    language: "Arabic",
                    deleteHarakat: false,
                    shiftHarakatPosition: false,
                    deleteTatweel: false,
                    supportZWJ: true,
                    useUnshapedInsteadOfIsolated: false,
                    supportLigatures: true
                });
                assert(Object.isFrozen(options));
                return "\ufeea\u0654\n\u064e\u0651";
            }
        };
        var ordering = {
            getDisplay: function (text) {
                calls.push("bidi");
                equal(text, "\ufba5\n\ufc60");
                return "\ufc60\n\ufba5";
            }
        };
        equal(core.convert("ى ا\"\nپ", "compatibility", undefined, ordering, shaper), "\u00da\n\u00e1\u00be");
        jsonEqual(calls, ["reshape", "bidi"]);
    });

    test("disabled bidi skips only ordering", function () {
        var calls = 0;
        var shaper = { reshape: function (text) { calls++; equal(text, "ی"); return "\ufeea\u0654"; } };
        equal(core.convert("ى", "unicode", { reverseWords: false }, null, shaper), "\ufba5");
        equal(calls, 1);
    });

    test("desktop paragraph direction preserves LTR lines during visual ordering", function () {
        var options = { reverseWords: true, autoParagraphDirection: true };
        var source = "سلام.\nsalam.\nچطوری؟";
        var output = core.convert(source, "unicode", options, bidi, reshaper);
        var lines = output.split("\n");
        equal(lines.length, 3);
        equal(lines[0], core.convert("سلام.", "unicode", undefined, bidi, reshaper));
        equal(lines[1], "salam.");
        equal(lines[2], core.convert("چطوری؟", "unicode", undefined, bidi, reshaper));
    });

    test("automatic paragraph ordering preserves hard separators", function () {
        var calls = [];
        var ordering = {
            getDisplay: function (text) {
                calls.push(text);
                return "[" + text + "]";
            }
        };
        var shaper = { reshape: function (text) { return text; } };
        equal(
            core.convert("one\r\ntwo\rthree\u2029four", "unicode", {
                reverseWords: true,
                autoParagraphDirection: true
            }, ordering, shaper),
            "[one]\r\n[two]\r[three]\u2029[four]");
        jsonEqual(calls, ["one", "two", "three", "four"]);
    });

    test("automatic paragraph ordering skips empty paragraphs", function () {
        var calls = [];
        var ordering = {
            getDisplay: function (text) {
                calls.push(text);
                return "[" + text + "]";
            }
        };
        var shaper = { reshape: function (text) { return text; } };
        equal(
            core.convert("one\n\nthree\n", "unicode", {
                reverseWords: true,
                autoParagraphDirection: true
            }, ordering, shaper),
            "[one]\n\n[three]\n");
        jsonEqual(calls, ["one", "three"]);
    });

    test("frozen conversion options remain unchanged", function () {
        var ligatures = Object.freeze({ "RIAL SIGN": true, "ARABIC LIGATURE ALLAH": false });
        var reshaperOptions = Object.freeze({
            language: "Kurdish",
            deleteHarakat: true,
            shiftHarakatPosition: true,
            deleteTatweel: true,
            supportZWJ: false,
            useUnshapedInsteadOfIsolated: true,
            supportLigatures: true,
            ligatures: ligatures
        });
        var options = Object.freeze({ reverseWords: false, shapingProfile: "kurdishUrdu", reshaperOptions: reshaperOptions });
        var before = JSON.stringify(options);
        var shaper = { reshape: function (text, actual) {
            assert(actual !== reshaperOptions);
            assert(actual.ligatures !== ligatures);
            assert(Object.isFrozen(actual));
            assert(Object.isFrozen(actual.ligatures));
            return text;
        } };
        core.convert("ریال", "unicode", options, null, shaper);
        equal(JSON.stringify(options), before);
    });

    test("Rial follows the named ligature setting", function () {
        var options = { reverseWords: false, reshaperOptions: { ligatures: { "RIAL SIGN": false } } };
        assert(core.convert("ریال", "unicode", options, null, reshaper) !== "﷼");
        options.reshaperOptions.ligatures["RIAL SIGN"] = true;
        equal(core.convert("ریال", "unicode", options, null, reshaper), "﷼");
    });

    test("shaping profiles select only their intended reshaper table", function () {
        var languages = [];
        var shaper = { reshape: function (text, options) { languages.push(options.language); return text; } };
        core.convert("پ", "unicode", { reverseWords: false, shapingProfile: "standardPersianArabic", reshaperOptions: { language: "Kurdish" } }, null, shaper);
        core.convert("پ", "unicode", { reverseWords: false, shapingProfile: "kurdishUrdu", reshaperOptions: { language: "Arabic" } }, null, shaper);
        jsonEqual(languages, ["Arabic", "Kurdish"]);
    });

    test("Hebrew bypasses Arabic shaping", function () {
        var shaper = { reshape: function () { fail("Hebrew entered the reshaper"); } };
        equal(core.convert("שלום 123", "unicode", { shapingProfile: "hebrew" }, bidi, shaper), "123 םולש");
        equal(core.convert("שלום ى ا\"", "unicode", { shapingProfile: "hebrew", reverseWords: false }, null, shaper), "שלום ى ا\"");
    });

    test("Hebrew rejects Compatibility mode", function () {
        expectThrows(function () {
            core.convert("שלום", "compatibility", { shapingProfile: "hebrew", reverseWords: false }, null, null);
        }, { code: "HEBREW_COMPATIBILITY_UNSUPPORTED", name: "RangeError" });
    });

    test("VideoStudio affects Compatibility output only", function () {
        var identity = { reshape: function (text) { return text; }, getDisplay: function (text) { return text; } };
        equal(core.convert("\u0153", "unicode", { videoStudioPro: true }, identity, identity), "\u0153");
        equal(core.convert("\ufed2", "compatibility", { videoStudioPro: true }, identity, identity), "\u00fe");
    });

    test("strict text, mode, and option validation", function () {
        var identity = { reshape: function (text) { return text; }, getDisplay: function (text) { return text; } };
        [null, undefined, 1, true, [], {}].forEach(function (text) {
            expectThrows(function () { core.convert(text, "unicode", undefined, identity, identity); }, { name: "TypeError" });
        });
        [undefined, null, "Unicode", "Maryam", "", 0].forEach(function (mode) {
            expectThrows(function () { core.convert("", mode, {}, identity, identity); }, { name: "RangeError" });
        });
        [null, [], true, 1, "", { unknown: true }, { reverseWords: 1 }].forEach(function (options) {
            expectThrows(function () { core.convert("", "unicode", options, identity, identity); }, { name: "TypeError" });
        });
        ["unknown", null, false, 1].forEach(function (profile) {
            expectThrows(function () { core.convert("", "unicode", { shapingProfile: profile }, identity, identity); }, { name: "RangeError" });
        });
    });

    fixtures.cases.forEach(function (fixture) {
        ["unicode", "compatibility"].forEach(function (mode) {
            [false, true].forEach(function (reverseWords) {
                [false, true].forEach(function (videoStudioPro) {
                    test("fixture " + fixture.id + " " + mode + " reverse=" + reverseWords + " video=" + videoStudioPro, function () {
                        var expectedName = (reverseWords ? "visual" : "logical") + (mode === "compatibility" && videoStudioPro ? "VideoStudio" : "");
                        var actual = core.convert(fixture.input, mode, { reverseWords: reverseWords, videoStudioPro: videoStudioPro }, bidi, reshaper);
                        equal(actual, fixture.expected[mode][expectedName], "exact converted string");
                    });
                });
            });
        });
    });

    test("fixture catalog is complete and hand-derived", function () {
        equal(fixtures.cases.length, 42);
        var ids = {};
        fixtures.cases.forEach(function (fixture) {
            assert(!ids[fixture.id], "duplicate fixture id " + fixture.id);
            ids[fixture.id] = true;
            equal(fixture.source.kind, "hand-derived");
            assert(fixture.source.rationale.length > 10);
            equal(Object.keys(fixture.expected.unicode).length, 2);
            equal(Object.keys(fixture.expected.compatibility).length, 4);
        });
    });

    test("original editor corpus completes in every configuration", function () {
        var input = fixtureData["editor-corpus"].text;
        equal(input.split("\n").length, 69);
        ["unicode", "compatibility"].forEach(function (mode) {
            [false, true].forEach(function (reverseWords) {
                [false, true].forEach(function (videoStudioPro) {
                    var output = core.convert(input, mode, { reverseWords: reverseWords, videoStudioPro: videoStudioPro }, bidi, reshaper);
                    assert(output.length > 0);
                    equal(output.split("\n").length, input.split("\n").length);
                    assert(output.indexOf("\ufffd") === -1);
                });
            });
        });
    });

    test("unsupported isolates depend on bidi ordering", function () {
        expectThrows(function () { core.convert("\u2066x\u2069", "unicode", undefined, bidi, reshaper); }, { code: "ERR_BIDI_UNSUPPORTED_ISOLATE" });
        equal(core.convert("\u2066x\u2069", "unicode", { reverseWords: false }, null, reshaper), "\u2066x\u2069");
    });

    maryam.pairs.forEach(function (pair, index) {
        test("ordered Maryam mapping " + index, function () {
            var expected = null;
            for (var candidateIndex = 0; candidateIndex < maryam.pairs.length; candidateIndex++) {
                if (maryam.pairs[candidateIndex][0] === pair[0]) {
                    expected = maryam.pairs[candidateIndex][1];
                    break;
                }
            }
            equal(core.mapMaryam(pair[0]), expected);
            equal(core.mapMaryam(pair[0], true), expected.replace(/\u0153/g, "\u00fe"));
        });
    });

    test("Maryam catalog retains all ordered entries", function () {
        equal(maryam.pairs.length, 213);
    });

    Object.keys(fixtures.stages).forEach(function (stage) {
        var method = {
            normalize: "normalize",
            customLigatures: "applyCustomLigatures",
            compatibilityNormalization: "normalizeCompatibility"
        }[stage];
        fixtures.stages[stage].forEach(function (fixture, index) {
            test(stage + " rule " + index, function () {
                equal(core[method](fixture.input), fixture.expected);
            });
        });
    });

    test("Maryam whitespace and line endings match the pinned behavior", function () {
        equal(core.mapMaryam("\n\n \n\ufe8f\n\n \n"), " \nJ\n\n ");
        equal(core.mapMaryam("\t\r😀abc\u0000"), "");
        equal(core.mapMaryam("\ufe8f\r\n\ufe8f"), "J\nJ");
        equal(core.mapMaryam(" \n "), " \n ");
    });

    test("settings metadata and translations are complete", function () {
        jsonEqual(copy(metadata.languages), ["Arabic", "Kurdish"]);
        jsonEqual(copy(metadata.shapingProfiles), [
            { id: "standardPersianArabic", language: "Arabic" },
            { id: "kurdishUrdu", language: "Kurdish" },
            { id: "hebrew", language: null }
        ]);
        equal(metadata.ligatureGroups[0].ligatures.length + metadata.ligatureGroups[1].ligatures.length + metadata.ligatureGroups[2].ligatures.length, 286);
        jsonEqual(Array.prototype.slice.call(strings.languages), ["en", "fa", "ar"]);
        equal(strings.text("en", "settings.title"), "Settings");
        equal(strings.text("fa", "settings.title"), "تنظیمات");
        equal(strings.text("ar", "settings.title"), "الإعدادات");
        equal(strings.text("en", "settings.profileLabel.hebrew"), "Hebrew");
        equal(strings.text("fa", "toggle.reverse"), "اعمال ترتیب نمایشی دوجهته");
        equal(strings.text("ar", "toggle.reverse"), "تطبيق الترتيب المرئي ثنائي الاتجاه");
        equal(strings.normalize("unknown"), "en");
    });

    test("settings defaults and named ligature overrides are pinned", function () {
        var defaults = settings.defaults(metadata);
        equal(defaults.language, "Arabic");
        equal(defaults.deleteHarakat, false);
        equal(defaults.deleteTatweel, false);
        equal(defaults.supportZWJ, true);
        equal(defaults.supportLigatures, true);
        equal(settings.flags.length, 6);
        settings.flags.forEach(function (flag) {
            var selected = {};
            selected[flag] = !defaults[flag];
            equal(settings.sanitize(metadata, selected)[flag], !defaults[flag], flag);
        });
        equal(metadata.defaults.ligatures["RIAL SIGN"], false);
        equal(defaults.ligatures["RIAL SIGN"], true);
        equal(defaults.ligatures["ARABIC LIGATURE ALLAH"], true);
        equal(Object.keys(defaults.ligatures).length, 286);
    });

    test("every named ligature row maps exactly once to persisted settings", function () {
        var seen = {};
        var rowCount = 0;
        metadata.ligatureGroups.forEach(function (group) {
            group.ligatures.forEach(function (ligature) {
                assert(!seen[ligature.name], "duplicate ligature row " + ligature.name);
                seen[ligature.name] = true;
                rowCount++;
                assert(Object.prototype.hasOwnProperty.call(metadata.defaults.ligatures, ligature.name), ligature.name);
                equal(metadata.defaults.ligatures[ligature.name], ligature.enabled, ligature.name);
            });
        });
        equal(rowCount, 286);
        equal(Object.keys(seen).length, Object.keys(metadata.defaults.ligatures).length);
    });

    test("settings sanitize, serialize, and restore without draft text", function () {
        var custom = settings.sanitize(metadata, {
            language: "Kurdish",
            deleteHarakat: true,
            unknown: true,
            ligatures: { "RIAL SIGN": true, UNKNOWN: true }
        });
        equal(custom.language, "Kurdish");
        equal(custom.deleteHarakat, true);
        equal(custom.ligatures.UNKNOWN, undefined);
        equal(Object.keys(custom.ligatures).length, 286);
        var desktop = {
            conversionMode: "compatibility",
            reverseWords: false,
            videoStudioPro: true,
            keyboardDrawerOpen: true,
            fontPaths: { unicode: "/fonts/unicode.ttf", compatibility: "/fonts/maryam.otf" },
            draftText: "must not persist",
            unknown: true
        };
        var toolState = { repairZwnj: true, persianDigits: true, invalid: "true" };
        var serialized = settings.serialize(metadata, custom, "fa", "kurdishUrdu", desktop, toolState);
        assert(serialized.indexOf("draftText") === -1);
        assert(serialized.indexOf("must not persist") === -1);
        equal(JSON.parse(serialized).settings.language, undefined);
        var restored = settings.parse(metadata, serialized);
        equal(restored.recovered, false);
        equal(restored.uiLanguage, "fa");
        equal(settings.parse(metadata, settings.serialize(metadata, custom, "ar")).uiLanguage, "ar");
        equal(restored.shapingProfile, "kurdishUrdu");
        jsonEqual(copy(restored.textTools), { repairZwnj: true, persianDigits: true });
        jsonEqual(copy(restored.settings), copy(custom));
        jsonEqual(copy(restored.desktop), {
            conversionMode: "compatibility",
            reverseWords: false,
            videoStudioPro: true,
            editorFontSize: 14,
            keyboardDrawerOpen: true,
            fontPaths: { unicode: "/fonts/unicode.ttf", compatibility: "/fonts/maryam.otf" },
            exportSettings: settings.desktopDefaults().exportSettings
        });
    });

    test("invalid and legacy settings recover predictably", function () {
        ["", "{", "null", "[]", "{\"schemaVersion\":2,\"settings\":{}}"].forEach(function (raw) {
            var recovered = settings.parse(metadata, raw);
            equal(recovered.recovered, true);
            equal(recovered.shapingProfile, "standardPersianArabic");
        });
        var legacy = settings.parse(metadata, "{\"schemaVersion\":1,\"settings\":{\"language\":\"Kurdish\"}}");
        equal(legacy.shapingProfile, "kurdishUrdu");
        equal(legacy.settings.language, "Kurdish");
        var hebrew = settings.parse(metadata, "{\"schemaVersion\":1,\"shapingProfile\":\"hebrew\",\"settings\":{\"language\":\"Kurdish\"}}");
        equal(hebrew.shapingProfile, "hebrew");
        equal(hebrew.settings.language, "Kurdish");
        jsonEqual(copy(legacy.desktop), settings.desktopDefaults());
        jsonEqual(settings.sanitizeDesktop({ conversionMode: "invalid", fontPaths: { unicode: 1 } }), settings.desktopDefaults());
        equal(settings.sanitizeDesktop({ editorFontSize: 9 }).editorFontSize, 14);
        equal(settings.sanitizeDesktop({ editorFontSize: 49 }).editorFontSize, 14);
        equal(settings.sanitizeDesktop({ keyboardDrawerOpen: true }).keyboardDrawerOpen, true);
        equal(settings.sanitizeDesktop({ keyboardDrawerOpen: "true" }).keyboardDrawerOpen, false);
    });

    test("resource limits accept boundaries and reject oversized values", function () {
        var conversionMaximum = new Array(limits.values.maxConversionTextLength + 1).join("پ");
        equal(limits.assertTextLength(conversionMaximum, limits.values.maxConversionTextLength, "CONVERSION_TEXT_TOO_LARGE").length, limits.values.maxConversionTextLength);
        expectThrows(function () {
            limits.assertTextLength(conversionMaximum + "پ", limits.values.maxConversionTextLength, "CONVERSION_TEXT_TOO_LARGE");
        }, { code: "CONVERSION_TEXT_TOO_LARGE" });
        expectThrows(function () { limits.assertFontBytes({ byteLength: limits.values.maxFontBytes + 1 }); }, { code: "FONT_TOO_LARGE" });
        expectThrows(function () {
            limits.assertSettingsSize(new Array(limits.values.maxSettingsBytes + 2).join("x"));
        }, { code: "SETTINGS_TOO_LARGE" });
        expectThrows(function () { limits.assertTextLength(1, 10, "TOO_LARGE"); }, { code: "INVALID_TEXT" });
        equal(limits.utf8ByteLength("ASCII پارسی 🧬"), 21);
    });

    if (failures.length) {
        throw new Error(failures.slice(0, 20).join("\n\n") + (failures.length > 20 ? "\n\nAdditional failures: " + (failures.length - 20) : ""));
    }

    CoreTestResults = Object.freeze({ passed: passed, total: total });
}());
