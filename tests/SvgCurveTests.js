// Executed by tests/core_tests.cpp inside QJSEngine.
var SvgCurveTestResults = (function () {
    "use strict";

    var passed = 0;
    var failures = [];

    function check(condition, message) {
        if (!condition) throw new Error(message);
        passed++;
    }

    function throwsCode(callback, code) {
        try { callback(); }
        catch (error) { check(error && error.code === code, "Expected " + code + ", received " + (error && error.code)); return; }
        throw new Error("Expected " + code);
    }

    function transforms(svg) {
        var expression = /transform="translate\(([-0-9.]+) ([-0-9.]+)\)/g;
        var values = [];
        var match;
        while ((match = expression.exec(svg)) !== null)
            values.push({ x: Number(match[1]), y: Number(match[2]) });
        return values;
    }

    function options(alignment) {
        return {
            fontSize: 48,
            lineSpacing: 1.5,
            alignment: alignment,
            bounds: { width: 600, height: 300, padding: 20 },
            fill: "#171717",
            precision: 3
        };
    }

    function curveOnly(svg) {
        check(/^<\?xml version="1\.0" encoding="UTF-8"\?>\n<svg /.test(svg), "SVG header is missing");
        check(/<path /.test(svg), "SVG paths are missing");
        check(!/<(?:text|tspan|image|foreignObject)\b/i.test(svg), "SVG contains a non-path content node");
        check(!/(?:font-family|@font-face|data:font|\bhref\s*=)/i.test(svg), "SVG embeds or references a font");
    }

    function ottoWithCff(cff) {
        var bytes = new Uint8Array(28 + cff.length);
        bytes[0] = 79; bytes[1] = 84; bytes[2] = 84; bytes[3] = 79;
        bytes[5] = 1;
        bytes[12] = 67; bytes[13] = 70; bytes[14] = 70; bytes[15] = 32;
        bytes[23] = 28;
        bytes[27] = cff.length;
        for (var index = 0; index < cff.length; index++) bytes[28 + index] = cff[index];
        return bytes;
    }

    function malformedCffFonts() {
        var header = [1, 0, 4, 1];
        var indexes = [[0, 1, 1, 1, 2, 65], [0, 1, 1, 1, 2, 139], [0, 0], [0, 0]];
        var malformed = [
            [0, 1, 1, 0, 1, 65],
            [0, 1, 1, 2, 1, 65],
            [0, 1, 4, 0, 0, 0, 1],
            [0, 1, 1, 1, 32, 65],
            [0, 1, 4, 0, 0, 0, 1, 255, 255, 255, 255]
        ];
        var fonts = [ottoWithCff([])];
        for (var required = 0; required < 2; required++) {
            var emptyRequired = header.slice();
            for (var requiredItem = 0; requiredItem < indexes.length; requiredItem++)
                emptyRequired = emptyRequired.concat(requiredItem === required ? [0, 0] : indexes[requiredItem]);
            fonts.push(ottoWithCff(emptyRequired));
        }
        for (var position = 0; position < indexes.length; position++) {
            for (var variant = 0; variant < malformed.length; variant++) {
                var cff = header.slice();
                for (var item = 0; item < indexes.length; item++)
                    cff = cff.concat(item === position ? malformed[variant] : indexes[item]);
                fonts.push(ottoWithCff(cff));
            }
        }
        return fonts;
    }

    try {
        var text = "پارسی نگار ریال ۱۲۳\nمتن دوم";
        var left = SvgCurveExporter.exportSvg(text, TestFontBytes, options("left"), Typr, ResourceLimits, SafeTypr);
        var center = SvgCurveExporter.exportSvg(text, TestFontBytes, options("center"), Typr, ResourceLimits, SafeTypr);
        var right = SvgCurveExporter.exportSvg(text, TestFontBytes, options("right"), Typr, ResourceLimits, SafeTypr);
        curveOnly(left);
        curveOnly(center);
        curveOnly(right);
        check(left === SvgCurveExporter.exportSvg(text, TestFontBytes, options("left"), Typr, ResourceLimits, SafeTypr), "Output is not deterministic");
        check((left.match(/<path /g) || []).length === 2, "Multiline output must contain one path per non-empty line");

        var leftPositions = transforms(left);
        var centerPositions = transforms(center);
        var rightPositions = transforms(right);
        check(leftPositions.length === 2, "Expected two positioned lines");
        check(leftPositions[1].y - leftPositions[0].y === 72, "Line spacing did not control the baseline distance");
        for (var index = 0; index < leftPositions.length; index++) {
            check(leftPositions[index].x < centerPositions[index].x, "Center alignment is not after left alignment");
            check(centerPositions[index].x < rightPositions[index].x, "Right alignment is not after center alignment");
        }

        var inspection = SvgCurveExporter.inspect(text, TestFontBytes, {}, Typr, ResourceLimits, SafeTypr);
        check(inspection.font.family === "Vazirmatn", "Bundled font identity was not inspected");
        check(inspection.font.style === "Regular", "Variable font did not select its default instance");
        check(inspection.missingGlyphs.length === 0, "Bundled font unexpectedly lacks Persian glyphs");
        var explicitDefault = options("left");
        explicitDefault.fontIndex = 3;
        var explicitThin = options("left");
        explicitThin.fontIndex = 0;
        check(left === SvgCurveExporter.exportSvg(text, TestFontBytes, explicitDefault, Typr, ResourceLimits, SafeTypr), "Default instance differs from Regular");
        check(left !== SvgCurveExporter.exportSvg(text, TestFontBytes, explicitThin, Typr, ResourceLimits, SafeTypr), "Variable instances produced identical paths");

        var missing = SvgCurveExporter.inspect(text + "🧬", TestFontBytes, {}, Typr, ResourceLimits, SafeTypr).missingGlyphs;
        check(missing.length === 1 && missing[0].label === "U+1F9EC", "Missing glyph inspection is incorrect");
        throwsCode(function () { SvgCurveExporter.exportSvg(text, TestFontBytes, { bounds: { width: 10, height: 10 } }, Typr, ResourceLimits, SafeTypr); }, "BOUNDS_TOO_SMALL");
        throwsCode(function () { SvgCurveExporter.exportSvg(text, TestFontBytes, { fontSize: ResourceLimits.values.maxFontSize + 1 }, Typr, ResourceLimits, SafeTypr); }, "INVALID_OPTION");
        throwsCode(function () { SvgCurveExporter.exportSvg(text, TestFontBytes, { lineSpacing: ResourceLimits.values.maxLineSpacing + 1 }, Typr, ResourceLimits, SafeTypr); }, "INVALID_OPTION");
        throwsCode(function () { SvgCurveExporter.exportSvg(text, TestFontBytes, { bounds: { width: ResourceLimits.values.maxDimension + 1 } }, Typr, ResourceLimits, SafeTypr); }, "INVALID_OPTION");
        throwsCode(function () { SvgCurveExporter.exportSvg(text, TestFontBytes, { bounds: { padding: ResourceLimits.values.maxPadding + 1 } }, Typr, ResourceLimits, SafeTypr); }, "INVALID_OPTION");
        throwsCode(function () { SvgCurveExporter.inspect(new Array(ResourceLimits.values.maxSvgTextLength + 2).join("پ"), TestFontBytes, {}, Typr, ResourceLimits, SafeTypr); }, "EXPORT_TEXT_TOO_LARGE");
        throwsCode(function () { SvgCurveExporter.inspect("پ", new Uint8Array([0, 1, 2, 3]), {}, Typr, ResourceLimits, SafeTypr); }, "INVALID_FONT");
        var malformedFonts = malformedCffFonts();
        for (var malformedIndex = 0; malformedIndex < malformedFonts.length; malformedIndex++) {
            (function (font) {
                throwsCode(function () { SvgCurveExporter.inspect("پ", font, {}, Typr, ResourceLimits, SafeTypr); }, "INVALID_FONT");
                throwsCode(function () { SvgCurveExporter.exportSvg("پ", font, {}, Typr, ResourceLimits, SafeTypr); }, "INVALID_FONT");
            }(malformedFonts[malformedIndex]));
        }

        if (typeof TestOtfBytes !== "undefined" && TestOtfBytes !== null) {
            check(SvgCurveExporter.inspect("A", TestOtfBytes, {}, Typr, ResourceLimits, SafeTypr).missingGlyphs.length === 0,
                "OpenType/CFF inspection failed");
            curveOnly(SvgCurveExporter.exportSvg("A", TestOtfBytes, options("left"), Typr, ResourceLimits, SafeTypr));
        }

        var originalShapeToPath = Typr.U.shapeToPath;
        try {
            Typr.U.shapeToPath = function () { return { cmds: ["X"], crds: [] }; };
            throwsCode(function () { SvgCurveExporter.exportSvg("پ", TestFontBytes, {}, Typr, ResourceLimits, SafeTypr); }, "UNSUPPORTED_GLYPH");
        } finally {
            Typr.U.shapeToPath = originalShapeToPath;
        }
        throwsCode(function () { SvgCurveExporter.inspect("پ", TestFontBytes, {}, Typr, ResourceLimits); }, "MISSING_ENGINE");

        if (typeof MaryamFontBytes !== "undefined" && MaryamFontBytes !== null) {
            var compatibilityText = ParsiNegar.convert("پارسی نگار ریال ۱۲۳", "compatibility", {
                reverseWords: true,
                reshaperOptions: { ligatures: { "RIAL SIGN": true } }
            }, JsBidi, JsParsiReshaper);
            check(SvgCurveExporter.inspect(compatibilityText, MaryamFontBytes, {}, Typr, ResourceLimits, SafeTypr).missingGlyphs.length === 0,
                "The optional Maryam fixture is missing compatibility glyphs");
            curveOnly(SvgCurveExporter.exportSvg(compatibilityText, MaryamFontBytes, options("right"), Typr, ResourceLimits, SafeTypr));
        }
    } catch (error) {
        failures.push(String(error && error.stack || error));
    }

    return { passed: passed, failures: failures, sampleSvg: typeof left === "string" ? left : "" };
}());
