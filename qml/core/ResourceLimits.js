// Copyright (c) 2026 LeoMoon Studios
// One source of truth for synchronous conversion and SVG export limits.
var ResourceLimits = (function () {
    "use strict";

    var values = Object.freeze({
        maxConversionTextLength: 250000,
        maxSvgTextLength: 50000,
        maxFontBytes: 50 * 1024 * 1024,
        maxSvgBytes: 16 * 1024 * 1024,
        maxSettingsBytes: 1024 * 1024,
        maxFontSize: 4096,
        maxLineSpacing: 10,
        maxDimension: 1000000,
        maxPadding: 100000
    });

    function fail(code, message) {
        var error = new Error(message);
        error.code = code;
        throw error;
    }

    function assertTextLength(text, maximum, code) {
        if (typeof text !== "string") fail("INVALID_TEXT", "Text must be a string");
        if (text.length > maximum) fail(code, "Text exceeds the supported length");
        return text;
    }

    function byteLength(bytes) {
        if (typeof ArrayBuffer !== "undefined" && bytes instanceof ArrayBuffer) return bytes.byteLength;
        if (typeof ArrayBuffer !== "undefined" && ArrayBuffer.isView && ArrayBuffer.isView(bytes)) return bytes.byteLength;
        if (bytes && typeof bytes.byteLength === "number") return bytes.byteLength;
        return -1;
    }

    function assertFontBytes(bytes) {
        var length = byteLength(bytes);
        if (length < 0) fail("INVALID_FONT", "Font data must be an ArrayBuffer or typed-array view");
        if (length > values.maxFontBytes) fail("FONT_TOO_LARGE", "Font exceeds the supported size");
        return bytes;
    }

    function utf8ByteLength(value) {
        var text = String(value);
        var length = 0;
        for (var index = 0; index < text.length; index++) {
            var code = text.charCodeAt(index);
            if (code < 0x80) length++;
            else if (code < 0x800) length += 2;
            else if (code >= 0xD800 && code <= 0xDBFF && index + 1 < text.length &&
                     text.charCodeAt(index + 1) >= 0xDC00 && text.charCodeAt(index + 1) <= 0xDFFF) {
                length += 4;
                index++;
            } else length += 3;
        }
        return length;
    }

    function assertSvgSize(svg) {
        if (String(svg).length > values.maxSvgBytes || utf8ByteLength(svg) > values.maxSvgBytes)
            fail("SVG_TOO_LARGE", "Generated SVG exceeds the supported size");
        return svg;
    }

    function assertSettingsSize(raw) {
        if (typeof raw !== "string") fail("INVALID_SETTINGS", "Settings data must be a string");
        if (raw.length > values.maxSettingsBytes || utf8ByteLength(raw) > values.maxSettingsBytes)
            fail("SETTINGS_TOO_LARGE", "Settings exceed the supported size");
        return raw;
    }

    return Object.freeze({
        values: values,
        assertTextLength: assertTextLength,
        assertFontBytes: assertFontBytes,
        assertSvgSize: assertSvgSize,
        assertSettingsSize: assertSettingsSize,
        utf8ByteLength: utf8ByteLength
    });
}());
