// Font structure and read guards for the unchanged bundled Typr.js build.
var SafeTypr = (function () {
    "use strict";

    var MAX_FONT_BYTES = 5 * 1024 * 1024;
    var guarded = [];

    function invalid(message) {
        var error = new Error(message);
        error.code = "INVALID_FONT";
        throw error;
    }

    function integer(value) {
        return typeof value === "number" && isFinite(value) && value >= 0 &&
            Math.floor(value) === value;
    }

    function bytesOf(input) {
        if (Object.prototype.toString.call(input) === "[object ArrayBuffer]")
            return new Uint8Array(input);
        if (typeof ArrayBuffer !== "undefined" && ArrayBuffer.isView && ArrayBuffer.isView(input))
            return new Uint8Array(input.buffer, input.byteOffset, input.byteLength);
        invalid("Font data must be an ArrayBuffer or typed-array view");
    }

    function range(data, offset, length) {
        if (!data || !integer(data.length) || !integer(offset) || !integer(length) ||
            offset > data.length || length > data.length - offset)
            invalid("Font data contains an out-of-range read");
    }

    function ushort(data, offset) {
        range(data, offset, 2);
        return data[offset] * 256 + data[offset + 1];
    }

    function uint(data, offset) {
        range(data, offset, 4);
        return data[offset] * 16777216 + data[offset + 1] * 65536 +
            data[offset + 2] * 256 + data[offset + 3];
    }

    function tag(data, offset) {
        range(data, offset, 4);
        return String.fromCharCode(data[offset], data[offset + 1], data[offset + 2], data[offset + 3]);
    }

    function index(data, offset, end) {
        if (!integer(end) || end > data.length || !integer(offset) || offset > end || end - offset < 2)
            invalid("Truncated CFF INDEX header");
        var count = ushort(data, offset);
        if (count === 0) return { count: 0, dataStart: offset + 2, end: offset + 2 };
        var sizeAt = offset + 2;
        if (end - sizeAt < 1) invalid("Truncated CFF INDEX offset size");
        var offSize = data[sizeAt];
        if (offSize < 1 || offSize > 4) invalid("Invalid CFF INDEX offset size");
        var offsetsAt = sizeAt + 1;
        if (count + 1 > Math.floor((end - offsetsAt) / offSize))
            invalid("Truncated CFF INDEX offset array");
        var dataStart = offsetsAt + (count + 1) * offSize;
        var previous = 0;
        for (var item = 0; item <= count; item++) {
            var value = 0;
            for (var byteIndex = 0; byteIndex < offSize; byteIndex++)
                value = value * 256 + data[offsetsAt + item * offSize + byteIndex];
            if (item === 0 && value !== 1) invalid("CFF INDEX must start at offset 1");
            if (value < previous || value === 0 || value - 1 > end - dataStart)
                invalid("CFF INDEX offset is outside the table");
            previous = value;
        }
        return { count: count, dataStart: dataStart, end: dataStart + previous - 1 };
    }

    function validateCff(data) {
        range(data, 0, 4);
        var headerSize = data[2];
        if (data[0] !== 1 || headerSize < 4 || headerSize > data.length ||
            data[3] < 1 || data[3] > 4)
            invalid("Invalid CFF header");
        var name = index(data, headerSize, data.length);
        if (name.count !== 1) invalid("OpenType CFF requires one Name INDEX entry");
        var topDict = index(data, name.end, data.length);
        if (topDict.count !== 1) invalid("OpenType CFF requires one Top DICT entry");
        var strings = index(data, topDict.end, data.length);
        index(data, strings.end, data.length);
    }

    function validate(input) {
        var data = bytesOf(input);
        if (data.length > MAX_FONT_BYTES) invalid("Font exceeds the 5 MiB limit");
        range(data, 0, 12);
        var signature = tag(data, 0);
        if (signature !== "OTTO" && !(data[0] === 0 && data[1] === 1 &&
            data[2] === 0 && data[3] === 0)) invalid("Unsupported font signature");
        var count = ushort(data, 4);
        if (count === 0 || count > Math.floor((data.length - 12) / 16))
            invalid("Invalid SFNT table directory");

        var seen = Object.create(null);
        var spans = [];
        var cff = null;
        for (var item = 0; item < count; item++) {
            var entry = 12 + item * 16;
            var name = tag(data, entry);
            if (seen[name]) invalid("Duplicate SFNT table");
            seen[name] = true;
            var start = uint(data, entry + 8);
            var length = uint(data, entry + 12);
            range(data, start, length);
            if (length > 0) spans.push({ start: start, end: start + length });
            if (name === "CFF ") cff = { start: start, length: length };
        }
        spans.sort(function (left, right) { return left.start - right.start; });
        for (var span = 1; span < spans.length; span++) {
            if (spans[span].start < spans[span - 1].end)
                invalid("Overlapping SFNT tables");
        }
        if (signature === "OTTO") {
            if (!cff || cff.length < 4) invalid("OpenType font is missing a CFF table");
            validateCff(data.subarray(cff.start, cff.start + cff.length));
        }
        return data;
    }

    function wrapRead(bin, name, unit, fixedLength) {
        var original = bin[name];
        if (typeof original !== "function") invalid("Incompatible Typr byte reader: " + name);
        bin[name] = function (data, offset, count) {
            var length = fixedLength === null ? count * unit : fixedLength;
            range(data, offset, length);
            return original.apply(this, arguments);
        };
    }

    function validateDict(data, start, end) {
        range(data, start, end - start);
        for (var offset = start; offset < end;) {
            var first = data[offset];
            var width = 1;
            if (first === 30) {
                var terminated = false;
                while (offset + width < end) {
                    if ((data[offset + width++] & 15) === 15) {
                        terminated = true;
                        break;
                    }
                }
                if (!terminated) invalid("Unterminated CFF dictionary number");
            } else if (first === 12 || (first >= 247 && first <= 254)) width = 2;
            else if (first === 28) width = 3;
            else if (first === 29 || first === 255) width = 5;
            if (width > end - offset) invalid("Truncated CFF dictionary value");
            offset += width;
        }
    }

    function installGuards(typr) {
        if (!typr || !typr.B || !typr.T || !typr.T.CFF ||
            typeof typr.T.CFF.readIndex !== "function" || typeof typr.parse !== "function")
            invalid("Incompatible Typr parser");
        if (guarded.indexOf(typr) !== -1) return;
        var bin = typr.B;
        var fixed = [
            ["readInt8", 1], ["readShort", 2], ["readUshort", 2],
            ["readF2dot14", 2], ["readInt", 4], ["readUint", 4],
            ["readFixed", 4], ["readUint64", 8]
        ];
        for (var item = 0; item < fixed.length; item++)
            wrapRead(bin, fixed[item][0], 1, fixed[item][1]);
        var counted = [
            ["readASCII", 1], ["readUTF8", 1], ["readBytes", 1],
            ["readASCIIArray", 1], ["readUnicode", 2], ["readUshorts", 2]
        ];
        for (item = 0; item < counted.length; item++)
            wrapRead(bin, counted[item][0], counted[item][1], null);

        var cff = typr.T.CFF;
        var originalIndex = cff.readIndex;
        cff.readIndex = function (data, offset, offsets) {
            if (!Array.isArray(offsets) || offsets.length !== 0)
                invalid("Invalid CFF INDEX destination");
            var checked = index(data, offset, data.length);
            if (checked.count === 0) {
                offsets.push(1);
                return offset + 1;
            }
            var result = originalIndex.apply(this, arguments);
            if (result !== checked.dataStart - 1 || offsets.length !== checked.count + 1)
                invalid("Inconsistent CFF INDEX parse");
            return result;
        };
        var originalDict = cff.readDict;
        if (typeof originalDict !== "function") invalid("Incompatible Typr CFF dictionary reader");
        cff.readDict = function (data, start, end) {
            if (!integer(end) || !integer(start) || end < start)
                invalid("Invalid CFF dictionary range");
            validateDict(data, start, end);
            return originalDict.apply(this, arguments);
        };
        guarded.push(typr);
    }

    function parse(typr, input) {
        var data = validate(input);
        installGuards(typr);
        var buffer = data.buffer.slice(data.byteOffset, data.byteOffset + data.byteLength);
        try { return typr.parse(buffer); }
        catch (error) {
            if (error && error.code === "INVALID_FONT") throw error;
            invalid("The selected font contains invalid internal data");
        }
    }

    return Object.freeze({ validate: validate, installGuards: installGuards, parse: parse });
}());
