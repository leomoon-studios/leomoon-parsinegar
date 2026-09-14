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

    try {
        var text = "پارسی نگار ریال ۱۲۳\nمتن دوم";
        var left = SvgCurveExporter.exportSvg(text, TestFontBytes, options("left"), Typr, ResourceLimits);
        var center = SvgCurveExporter.exportSvg(text, TestFontBytes, options("center"), Typr, ResourceLimits);
        var right = SvgCurveExporter.exportSvg(text, TestFontBytes, options("right"), Typr, ResourceLimits);
        curveOnly(left);
        curveOnly(center);
        curveOnly(right);
        check(left === SvgCurveExporter.exportSvg(text, TestFontBytes, options("left"), Typr, ResourceLimits), "Output is not deterministic");
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

        var inspection = SvgCurveExporter.inspect(text, TestFontBytes, {}, Typr, ResourceLimits);
        check(inspection.font.family === "Vazirmatn", "Bundled font identity was not inspected");
        check(inspection.font.style === "Regular", "Variable font did not select its default instance");
        check(inspection.missingGlyphs.length === 0, "Bundled font unexpectedly lacks Persian glyphs");
        var explicitDefault = options("left");
        explicitDefault.fontIndex = 3;
        var explicitThin = options("left");
        explicitThin.fontIndex = 0;
        check(left === SvgCurveExporter.exportSvg(text, TestFontBytes, explicitDefault, Typr, ResourceLimits), "Default instance differs from Regular");
        check(left !== SvgCurveExporter.exportSvg(text, TestFontBytes, explicitThin, Typr, ResourceLimits), "Variable instances produced identical paths");

        var missing = SvgCurveExporter.inspect(text + "🧬", TestFontBytes, {}, Typr, ResourceLimits).missingGlyphs;
        check(missing.length === 1 && missing[0].label === "U+1F9EC", "Missing glyph inspection is incorrect");
        throwsCode(function () { SvgCurveExporter.exportSvg(text, TestFontBytes, { bounds: { width: 10, height: 10 } }, Typr, ResourceLimits); }, "BOUNDS_TOO_SMALL");
        throwsCode(function () { SvgCurveExporter.exportSvg(text, TestFontBytes, { fontSize: ResourceLimits.values.maxFontSize + 1 }, Typr, ResourceLimits); }, "INVALID_OPTION");
        throwsCode(function () { SvgCurveExporter.exportSvg(text, TestFontBytes, { lineSpacing: ResourceLimits.values.maxLineSpacing + 1 }, Typr, ResourceLimits); }, "INVALID_OPTION");
        throwsCode(function () { SvgCurveExporter.exportSvg(text, TestFontBytes, { bounds: { width: ResourceLimits.values.maxDimension + 1 } }, Typr, ResourceLimits); }, "INVALID_OPTION");
        throwsCode(function () { SvgCurveExporter.exportSvg(text, TestFontBytes, { bounds: { padding: ResourceLimits.values.maxPadding + 1 } }, Typr, ResourceLimits); }, "INVALID_OPTION");
        throwsCode(function () { SvgCurveExporter.inspect(new Array(ResourceLimits.values.maxSvgTextLength + 2).join("پ"), TestFontBytes, {}, Typr, ResourceLimits); }, "EXPORT_TEXT_TOO_LARGE");
        throwsCode(function () { SvgCurveExporter.inspect("پ", new Uint8Array([0, 1, 2, 3]), {}, Typr, ResourceLimits); }, "INVALID_FONT");

        var unsupportedTypr = {
            parse: function () { return [{ head: { unitsPerEm: 1000 }, hhea: { ascender: 800, descender: -200 }, name: {} }]; },
            U: {
                codeToGlyph: function () { return 1; },
                shape: function () { return [{ ax: 500 }]; },
                shapeToPath: function () { return { cmds: ["X"], crds: [] }; },
                pathToSVG: function () { return ""; }
            }
        };
        throwsCode(function () { SvgCurveExporter.exportSvg("پ", new Uint8Array([0]), {}, unsupportedTypr, ResourceLimits); }, "UNSUPPORTED_GLYPH");

        if (typeof MaryamFontBytes !== "undefined" && MaryamFontBytes !== null) {
            var compatibilityText = ParsiNegar.convert("پارسی نگار ریال ۱۲۳", "compatibility", {
                reverseWords: true,
                reshaperOptions: { ligatures: { "RIAL SIGN": true } }
            }, JsBidi, JsParsiReshaper);
            check(SvgCurveExporter.inspect(compatibilityText, MaryamFontBytes, {}, Typr, ResourceLimits).missingGlyphs.length === 0,
                "The optional Maryam fixture is missing compatibility glyphs");
            curveOnly(SvgCurveExporter.exportSvg(compatibilityText, MaryamFontBytes, options("right"), Typr, ResourceLimits));
        }
    } catch (error) {
        failures.push(String(error && error.stack || error));
    }

    return { passed: passed, failures: failures, sampleSvg: typeof left === "string" ? left : "" };
}());
