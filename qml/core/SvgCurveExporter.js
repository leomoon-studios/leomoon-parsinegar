// Copyright (c) 2026 LeoMoon Studios
// Dependency-free SVG curve exporter. Pass Typr explicitly so loading stays lazy.
var SvgCurveExporter = (function () {
    "use strict";

    var OUTLINE_COMMANDS = { M: true, L: true, Q: true, C: true, Z: true };

    function fail(code, message, details) {
        var error = new Error(message);
        error.code = code;
        if (details) error.details = details;
        throw error;
    }

    function finiteNumber(value, fallback, name, allowZero, maximum) {
        if (value === undefined) return fallback;
        if (typeof value !== "number") fail("INVALID_OPTION", name + " must be a number");
        var number = value;
        if (!isFinite(number) || (allowZero ? number < 0 : number <= 0) || number > maximum)
            fail("INVALID_OPTION", name + " must be a " + (allowZero ? "non-negative" : "positive") + " number no greater than " + maximum);
        return number;
    }

    function requireLimits(limits) {
        if (!limits || !limits.values || typeof limits.assertTextLength !== "function" ||
            typeof limits.assertFontBytes !== "function" || typeof limits.assertSvgSize !== "function")
            fail("MISSING_LIMITS", "Resource limits are required");
        return limits;
    }

    function plainObject(value, name) {
        if (value === null || typeof value !== "object" || Array.isArray(value) ||
            Object.prototype.toString.call(value) !== "[object Object]")
            fail("INVALID_OPTION", name + " must be a plain object");
        return value;
    }

    function knownProperties(value, names, owner) {
        if (Object.getOwnPropertySymbols(value).length) fail("INVALID_OPTION", owner + " contains an unknown symbol property");
        Object.getOwnPropertyNames(value).forEach(function (name) {
            if (names.indexOf(name) === -1) fail("INVALID_OPTION", "Unknown " + owner + " property: " + name);
        });
    }

    function fontBuffer(bytes) {
        if (typeof ArrayBuffer !== "undefined" && bytes instanceof ArrayBuffer) return bytes;
        if (typeof ArrayBuffer !== "undefined" && ArrayBuffer.isView && ArrayBuffer.isView(bytes))
            return bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);
        if (bytes && bytes.buffer instanceof ArrayBuffer) {
            var offset = bytes.byteOffset || 0;
            var length = bytes.byteLength === undefined ? bytes.buffer.byteLength : bytes.byteLength;
            return bytes.buffer.slice(offset, offset + length);
        }
        fail("INVALID_FONT", "Font data must be an ArrayBuffer or typed-array view");
    }

    function defaultFontIndex(fonts) {
        var bestIndex = 0;
        var bestDistance = Infinity;
        for (var index = 0; index < fonts.length; index++) {
            var font = fonts[index];
            if (!font.fvar || !font.fvar[0] || !font.fvar[1] || !font.fvar[1][font._vindex]) continue;
            var axes = font.fvar[0];
            var coordinates = font.fvar[1][font._vindex][2];
            var distance = 0;
            for (var axisIndex = 0; axisIndex < axes.length; axisIndex++) {
                var range = axes[axisIndex][3] - axes[axisIndex][1];
                distance += Math.abs(coordinates[axisIndex] - axes[axisIndex][2]) / (range || 1);
            }
            if (distance < bestDistance) {
                bestDistance = distance;
                bestIndex = index;
            }
        }
        return bestIndex;
    }

    function parseFont(bytes, fontIndex, typr) {
        if (!typr || typeof typr.parse !== "function" || !typr.U)
            fail("MISSING_ENGINE", "A loaded Typr.js API is required");
        var fonts;
        try { fonts = typr.parse(fontBuffer(bytes)); }
        catch (error) { fail("INVALID_FONT", "The selected font could not be read: " + error); }
        var selectedIndex = fontIndex === null ? defaultFontIndex(fonts || []) : fontIndex;
        if (!fonts || !fonts.length || !fonts[selectedIndex])
            fail("INVALID_FONT_INDEX", "The selected font does not contain font index " + selectedIndex);
        var font = fonts[selectedIndex];
        if (!font.head || !font.hhea || !isFinite(font.head.unitsPerEm) || font.head.unitsPerEm <= 0 ||
            !isFinite(font.hhea.ascender) || !isFinite(font.hhea.descender))
            fail("INVALID_FONT", "The selected font has invalid metrics");
        return font;
    }

    function codePointLabel(code) {
        var hex = code.toString(16).toUpperCase();
        while (hex.length < 4) hex = "0" + hex;
        return "U+" + hex;
    }

    function missingGlyphs(font, text, typr) {
        var missing = [];
        var seen = {};
        for (var i = 0; i < text.length;) {
            var code = text.codePointAt(i);
            var character = String.fromCodePoint(code);
            i += character.length;
            if (code === 10 || code === 13) continue;
            if (typr.U.codeToGlyph(font, code) === 0 && !seen[code]) {
                seen[code] = true;
                missing.push({ character: character, codePoint: code, label: codePointLabel(code) });
            }
        }
        return missing;
    }

    function outlineBounds(path) {
        var coordinates = path.crds || [];
        var bounds = { minX: 0, minY: 0, maxX: 0, maxY: 0, empty: coordinates.length === 0 };
        for (var i = 0; i < coordinates.length; i += 2) {
            var x = Number(coordinates[i]);
            var y = Number(coordinates[i + 1]);
            if (!isFinite(x) || !isFinite(y)) fail("INVALID_OUTLINE", "The font returned invalid outline coordinates");
            if (bounds.empty || i === 0) {
                bounds.minX = bounds.maxX = x;
                bounds.minY = bounds.maxY = y;
                bounds.empty = false;
            } else {
                bounds.minX = Math.min(bounds.minX, x);
                bounds.maxX = Math.max(bounds.maxX, x);
                bounds.minY = Math.min(bounds.minY, y);
                bounds.maxY = Math.max(bounds.maxY, y);
            }
        }
        return bounds;
    }

    function outlineLine(font, text, typr, axes) {
        var shape = typr.U.shape(font, text, { ltr: true, axs: axes });
        var advance = 0;
        for (var i = 0; i < shape.length; i++) advance += shape[i].ax;
        var path = typr.U.shapeToPath(font, shape, { axs: axes });
        for (var commandIndex = 0; commandIndex < path.cmds.length; commandIndex++) {
            if (!OUTLINE_COMMANDS[path.cmds[commandIndex]])
                fail("UNSUPPORTED_GLYPH", "The selected font uses a color, bitmap, or non-outline glyph that cannot be exported as curves");
        }
        return { advance: advance, path: path, bounds: outlineBounds(path) };
    }

    function rounded(number, precision) {
        var power = Math.pow(10, precision);
        var value = Math.round(number * power) / power;
        return String(Object.is(value, -0) ? 0 : value);
    }

    function escapeAttribute(value) {
        return String(value).replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
    }

    function normalizedOptions(options, limits) {
        if (options === undefined) options = {};
        plainObject(options, "options");
        knownProperties(options, ["fontSize", "lineSpacing", "alignment", "bounds", "fill", "precision", "fontIndex", "axes"], "options");
        var bounds = options.bounds === undefined ? {} : plainObject(options.bounds, "bounds");
        knownProperties(bounds, ["width", "height", "padding"], "bounds");
        var alignment = options.alignment === undefined ? "left" : options.alignment;
        if (alignment !== "left" && alignment !== "center" && alignment !== "right")
            fail("INVALID_OPTION", "alignment must be left, center, or right");
        var precision = options.precision === undefined ? 3 : options.precision;
        if (typeof precision !== "number") fail("INVALID_OPTION", "precision must be a number");
        if (!isFinite(precision) || precision < 0 || precision > 8 || Math.floor(precision) !== precision)
            fail("INVALID_OPTION", "precision must be an integer from 0 to 8");
        if (options.fill !== undefined && typeof options.fill !== "string") fail("INVALID_OPTION", "fill must be a string");
        if (options.fontIndex !== undefined && (typeof options.fontIndex !== "number" || !isFinite(options.fontIndex) ||
            options.fontIndex < 0 || Math.floor(options.fontIndex) !== options.fontIndex))
            fail("INVALID_OPTION", "fontIndex must be a non-negative integer");
        var axes = options.axes;
        if (axes !== undefined) {
            if (!Array.isArray(axes) || axes.length === 0 || axes.length > 32)
                fail("INVALID_OPTION", "axes must be a non-empty array of at most 32 numbers");
            axes = axes.map(function (value) {
                if (typeof value !== "number" || !isFinite(value) || Math.abs(value) > limits.values.maxDimension)
                    fail("INVALID_OPTION", "Every axis value must be a finite number within the supported range");
                return value;
            });
        }
        return {
            fontSize: finiteNumber(options.fontSize, 48, "fontSize", false, limits.values.maxFontSize),
            lineSpacing: finiteNumber(options.lineSpacing, 1.2, "lineSpacing", false, limits.values.maxLineSpacing),
            alignment: alignment,
            width: bounds.width === undefined ? null : finiteNumber(bounds.width, null, "bounds.width", false, limits.values.maxDimension),
            height: bounds.height === undefined ? null : finiteNumber(bounds.height, null, "bounds.height", false, limits.values.maxDimension),
            padding: finiteNumber(bounds.padding, 0, "bounds.padding", true, limits.values.maxPadding),
            fill: options.fill === undefined ? "#000000" : options.fill,
            precision: precision,
            fontIndex: options.fontIndex === undefined ? null : options.fontIndex,
            axes: axes
        };
    }

    function validateAxes(font, axes) {
        if (axes === undefined) return;
        if (!font.fvar || !font.fvar[0] || axes.length !== font.fvar[0].length)
            fail("INVALID_OPTION", "axes must match the selected variable font");
        for (var index = 0; index < axes.length; index++) {
            var definition = font.fvar[0][index];
            if (axes[index] < definition[1] || axes[index] > definition[3])
                fail("INVALID_OPTION", "Axis value " + index + " is outside the font's supported range");
        }
    }

    function fontIdentity(font) {
        var names = font.name || {};
        return {
            family: names.fontFamily || names.fullName || "",
            fullName: names.fullName || names.fontFamily || "",
            style: names.fontSubfamily || names.typoSubfamilyName || "",
            unitsPerEm: font.head.unitsPerEm
        };
    }

    function inspect(text, bytes, options, typr, limits) {
        limits = requireLimits(limits);
        limits.assertTextLength(text, limits.values.maxSvgTextLength, "EXPORT_TEXT_TOO_LARGE");
        limits.assertFontBytes(bytes);
        var normalized = normalizedOptions(options, limits);
        try {
            var font = parseFont(bytes, normalized.fontIndex, typr);
            validateAxes(font, normalized.axes);
            return { font: fontIdentity(font), missingGlyphs: missingGlyphs(font, text, typr) };
        } catch (error) {
            if (error && error.code) throw error;
            fail("INVALID_FONT", "The selected font could not be read: " + error);
        }
    }

    function exportSvg(text, bytes, options, typr, limits) {
        limits = requireLimits(limits);
        limits.assertTextLength(text, limits.values.maxSvgTextLength, "EXPORT_TEXT_TOO_LARGE");
        limits.assertFontBytes(bytes);
        var normalized = normalizedOptions(options, limits);
        try {
            return exportWithFont(text, bytes, normalized, typr, limits);
        } catch (error) {
            if (error && error.code) throw error;
            fail("INVALID_FONT", "The selected font could not be read: " + error);
        }
    }

    function exportWithFont(text, bytes, normalized, typr, limits) {
        var font = parseFont(bytes, normalized.fontIndex, typr);
        validateAxes(font, normalized.axes);

        var lines = text.replace(/\r\n?/g, "\n").split("\n");
        var outlined = [];
        var maxAdvance = 0;
        var minOutlineX = 0;
        var maxOutlineBeyondAdvance = 0;
        var maxOutlineY = font.hhea.ascender;
        var minOutlineY = font.hhea.descender;
        for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
            var line = outlineLine(font, lines[lineIndex], typr, normalized.axes);
            outlined.push(line);
            maxAdvance = Math.max(maxAdvance, line.advance);
            if (!line.bounds.empty) {
                minOutlineX = Math.min(minOutlineX, line.bounds.minX);
                maxOutlineBeyondAdvance = Math.max(maxOutlineBeyondAdvance, line.bounds.maxX - line.advance);
                maxOutlineY = Math.max(maxOutlineY, line.bounds.maxY);
                minOutlineY = Math.min(minOutlineY, line.bounds.minY);
            }
        }

        var scale = normalized.fontSize / font.head.unitsPerEm;
        var leftOverhang = Math.max(0, -minOutlineX * scale);
        var rightOverhang = Math.max(0, maxOutlineBeyondAdvance * scale);
        var topOverhang = Math.max(0, (maxOutlineY - font.hhea.ascender) * scale);
        var bottomOverhang = Math.max(0, (font.hhea.descender - minOutlineY) * scale);
        var lineHeight = normalized.fontSize * normalized.lineSpacing;
        var naturalWidth = normalized.padding * 2 + leftOverhang + maxAdvance * scale + rightOverhang;
        var naturalHeight = normalized.padding * 2 + topOverhang + (font.hhea.ascender - font.hhea.descender) * scale + bottomOverhang + (lines.length - 1) * lineHeight;
        if (!isFinite(scale) || !isFinite(naturalWidth) || !isFinite(naturalHeight) ||
            naturalWidth > limits.values.maxDimension || naturalHeight > limits.values.maxDimension)
            fail("INVALID_DIMENSIONS", "The outlined text exceeds the supported SVG dimensions");
        var width = normalized.width === null ? Math.max(1, naturalWidth) : normalized.width;
        var height = normalized.height === null ? Math.max(1, naturalHeight) : normalized.height;
        if (!isFinite(width) || !isFinite(height) || width > limits.values.maxDimension || height > limits.values.maxDimension)
            fail("INVALID_DIMENSIONS", "The SVG dimensions are invalid or too large");
        if (width + 0.000001 < naturalWidth || height + 0.000001 < naturalHeight)
            fail("BOUNDS_TOO_SMALL", "The requested bounds are smaller than the outlined text");

        var contentWidth = width - normalized.padding * 2 - leftOverhang - rightOverhang;
        var baseline = normalized.padding + topOverhang + font.hhea.ascender * scale;
        var paths = [];
        var pathCharacters = 0;
        for (var pathIndex = 0; pathIndex < outlined.length; pathIndex++) {
            var item = outlined[pathIndex];
            if (!item.path.cmds.length) continue;
            var remaining = contentWidth - item.advance * scale;
            var alignedOffset = normalized.alignment === "right" ? remaining : normalized.alignment === "center" ? remaining / 2 : 0;
            var x = normalized.padding + leftOverhang + alignedOffset;
            var y = baseline + pathIndex * lineHeight;
            if (!isFinite(x) || !isFinite(y)) fail("INVALID_DIMENSIONS", "The SVG transform is not finite");
            var transformPrecision = Math.max(6, normalized.precision);
            var pathMarkup = '  <path fill="' + escapeAttribute(normalized.fill) + '" transform="translate(' + rounded(x, transformPrecision) + ' ' + rounded(y, transformPrecision) + ') scale(' + rounded(scale, transformPrecision) + ' -' + rounded(scale, transformPrecision) + ')" d="' + escapeAttribute(typr.U.pathToSVG(item.path, normalized.precision)) + '"/>';
            pathCharacters += pathMarkup.length;
            if (pathCharacters > limits.values.maxSvgBytes) fail("SVG_TOO_LARGE", "Generated SVG exceeds the supported size");
            paths.push(pathMarkup);
        }

        var svg = '<?xml version="1.0" encoding="UTF-8"?>\n' +
            '<svg xmlns="http://www.w3.org/2000/svg" width="' + rounded(width, normalized.precision) + '" height="' + rounded(height, normalized.precision) + '" viewBox="0 0 ' + rounded(width, normalized.precision) + ' ' + rounded(height, normalized.precision) + '">\n' +
            paths.join("\n") + (paths.length ? "\n" : "") + '</svg>\n';
        return limits.assertSvgSize(svg);
    }

    return { exportSvg: exportSvg, inspect: inspect };
})();
