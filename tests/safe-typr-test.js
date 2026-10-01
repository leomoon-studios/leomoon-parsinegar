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
