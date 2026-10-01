// Run directly: node test/safe-typr-test.js
const assert = require('assert').strict;
const fs = require('fs');
const path = require('path');
const vm = require('vm');

const root = path.resolve(__dirname, '..');
const safePath = fs.existsSync(path.join(root, 'SafeTypr.js'))
    ? 'SafeTypr.js' : 'qml/core/SafeTypr.js';
const context = vm.createContext({ TextDecoder, TextEncoder });
for (const file of ['vendor/typr.js', safePath])
    vm.runInContext(fs.readFileSync(path.join(root, file), 'utf8'), context, { filename: file });

const safe = context.SafeTypr;
const typr = context.Typr;
const invalid = action => assert.throws(action, error => error && error.code === 'INVALID_FONT');

function otto(cff) {
    const result = Buffer.alloc(28 + cff.length);
    result.write('OTTO', 0, 'ascii');
    result.writeUInt16BE(1, 4);
    result.write('CFF ', 12, 'ascii');
    result.writeUInt32BE(28, 20);
    result.writeUInt32BE(cff.length, 24);
    cff.copy(result, 28);
    return result;
}

function format12Font(groups, subtableLength = 16, tableLength = 28) {
    const font = Buffer.alloc(28 + tableLength);
    font.writeUInt32BE(0x00010000, 0);
    font.writeUInt16BE(1, 4);
    font.write('cmap', 12, 'ascii');
    font.writeUInt32BE(28, 20);
    font.writeUInt32BE(tableLength, 24);
    font.writeUInt16BE(1, 30);
    font.writeUInt16BE(3, 32);
    font.writeUInt16BE(10, 34);
    font.writeUInt32BE(12, 36);
    font.writeUInt16BE(12, 40);
    font.writeUInt32BE(subtableLength, 44);
    font.writeUInt32BE(groups, 52);
    return font;
}

function svgFont(ranges) {
    const document = Buffer.from('<svg/>');
    const table = Buffer.alloc(12 + ranges.length * 12 + document.length);
    table.writeUInt32BE(10, 2);
    table.writeUInt16BE(ranges.length, 10);
    for (let item = 0; item < ranges.length; item++) {
        const entry = 12 + item * 12;
        table.writeUInt16BE(ranges[item][0], entry);
        table.writeUInt16BE(ranges[item][1], entry + 2);
        table.writeUInt32BE(2 + ranges.length * 12, entry + 4);
        table.writeUInt32BE(document.length, entry + 8);
    }
    document.copy(table, 12 + ranges.length * 12);
    const font = Buffer.alloc(28 + table.length);
    font.writeUInt32BE(0x00010000, 0);
    font.writeUInt16BE(1, 4);
    font.write('SVG ', 12, 'ascii');
    font.writeUInt32BE(28, 20);
    font.writeUInt32BE(table.length, 24);
    table.copy(font, 28);
    return font;
}

const header = Buffer.from([1, 0, 4, 1]);
const name = Buffer.from([0, 1, 1, 1, 2, 65]);
const topDict = Buffer.from([0, 1, 1, 1, 2, 139]);
const emptyIndex = Buffer.from([0, 0]);
const validCff = Buffer.concat([header, name, topDict, emptyIndex, emptyIndex]);
assert.ok(safe.validate(otto(validCff)).length > 0);
assert.ok(safe.parse(typr, otto(validCff)).length > 0);

const hugeName = Buffer.from([0, 1, 4, 0, 0, 0, 1, 255, 255, 255, 255]);
const malicious = otto(Buffer.concat([header, hugeName, topDict, emptyIndex, emptyIndex]));
assert.ok(malicious.length < 100);
invalid(() => safe.validate(malicious));
let parserCalls = 0;
invalid(() => safe.parse({ parse() { parserCalls++; } }, malicious));
assert.equal(parserCalls, 0, 'malformed CFF must be rejected before calling Typr');
for (const cff of [
    Buffer.concat([header, name, hugeName, emptyIndex, emptyIndex]),
    Buffer.concat([header, name, topDict, hugeName, emptyIndex]),
    Buffer.concat([header, name, topDict, emptyIndex, hugeName])
]) invalid(() => safe.validate(otto(cff)));

for (const badName of [
    Buffer.from([0, 1, 0, 1, 2, 65]),
    Buffer.from([0, 1, 1, 0, 2, 65]),
    Buffer.from([0, 1, 1, 2, 1, 65]),
    Buffer.from([0, 1, 4, 0, 0, 0, 1]),
    Buffer.from([0, 1, 1, 1, 32, 65])
]) invalid(() => safe.validate(otto(Buffer.concat([header, badName, topDict, emptyIndex, emptyIndex]))));

const outOfRangeTable = otto(validCff);
outOfRangeTable.writeUInt32BE(0xffffffff, 20);
invalid(() => safe.validate(outOfRangeTable));
const duplicateTable = Buffer.alloc(44 + validCff.length);
duplicateTable.write('OTTO', 0, 'ascii');
duplicateTable.writeUInt16BE(2, 4);
for (const entry of [12, 28]) {
    duplicateTable.write('CFF ', entry, 'ascii');
    duplicateTable.writeUInt32BE(44, entry + 8);
    duplicateTable.writeUInt32BE(validCff.length, entry + 12);
}
validCff.copy(duplicateTable, 44);
invalid(() => safe.validate(duplicateTable));

const validFormat12 = format12Font(1, 28, 40);
validFormat12.writeUInt32BE(65, 56);
validFormat12.writeUInt32BE(65, 60);
validFormat12.writeUInt32BE(1, 64);
assert.ok(safe.validate(validFormat12).length > 0);
const hugeGroups = format12Font(0x04000000);
assert.ok(hugeGroups.length < 100);
invalid(() => safe.validate(hugeGroups));
parserCalls = 0;
invalid(() => safe.parse({ parse() { parserCalls++; } }, hugeGroups));
assert.equal(parserCalls, 0, 'malformed cmap must be rejected before calling Typr');
invalid(() => safe.validate(format12Font(1)));
invalid(() => safe.validate(format12Font(0, 0xffffffff)));
const invalidSubtableOffset = format12Font(0);
invalidSubtableOffset.writeUInt32BE(0xffffffff, 36);
invalid(() => safe.validate(invalidSubtableOffset));
const truncatedEncodingRecords = format12Font(0);
truncatedEncodingRecords.writeUInt16BE(4, 30);
invalid(() => safe.validate(truncatedEncodingRecords));

const validSvg = svgFont([[0, 1], [3, 4]]);
assert.ok(safe.validate(validSvg).length > 0);
assert.ok(safe.parse(typr, validSvg).length > 0);
const overlappingSvg = svgFont([[0, 65535], [0, 65535]]);
assert.ok(overlappingSvg.length < 100);
invalid(() => safe.validate(overlappingSvg));
parserCalls = 0;
invalid(() => safe.parse({ parse() { parserCalls++; } }, overlappingSvg));
assert.equal(parserCalls, 0, 'repeated SVG glyph ranges must be rejected before calling Typr');
invalid(() => safe.validate(svgFont([[5, 4]])));
invalid(() => safe.validate(svgFont([[3, 4], [1, 2]])));
const truncatedSvgIndex = svgFont([[0, 1]]);
truncatedSvgIndex.writeUInt16BE(2, 38);
invalid(() => safe.validate(truncatedSvgIndex));
const invalidSvgIndexOffset = svgFont([[0, 1]]);
invalidSvgIndexOffset.writeUInt32BE(0xffffffff, 30);
invalid(() => safe.validate(invalidSvgIndexOffset));

safe.installGuards(typr);
safe.installGuards(typr);
invalid(() => typr.B.readASCII(new Uint8Array([65]), 0, 0xffffffff));
invalid(() => typr.B.readBytes(new Uint8Array([65]), 0, 0xffffffff));
invalid(() => typr.B.readUnicode(new Uint8Array([0, 65]), 0, 2));
assert.equal(typr.B.readASCII(new Uint8Array([65]), 0, 1), 'A');
const offsets = [];
assert.equal(typr.T.CFF.readIndex(new Uint8Array([0, 0]), 0, offsets), 1);
assert.deepEqual(Array.from(offsets), [1], 'empty CFF INDEX consumes only its count field');
invalid(() => typr.T.CFF.readIndex(new Uint8Array(hugeName), 0, []));
invalid(() => typr.T.CFF.readDict(new Uint8Array([30, 0]), 0, 2));
invalid(() => typr.T.CFF.readDict(new Uint8Array([28, 0]), 0, 2));

const vazirmatn = fs.readFileSync(path.join(root, 'assets/fonts/Vazirmatn[wght].ttf'));
assert.ok(safe.parse(typr, vazirmatn).length > 0);
const otfFixture = process.env.SAFE_TYPR_OTF_FIXTURE || '/usr/share/fonts/gsfonts/NimbusSans-Regular.otf';
if (fs.existsSync(otfFixture))
    assert.ok(safe.parse(typr, fs.readFileSync(otfFixture)).length > 0);
else
    console.log('Real CFF font fixture skipped; set SAFE_TYPR_OTF_FIXTURE to an OTF font');

console.log('SafeTypr checks passed');
