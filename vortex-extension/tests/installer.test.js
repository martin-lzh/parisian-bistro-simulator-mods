'use strict';

const assert = require('node:assert/strict');
const test = require('node:test');
const { install, testSupported } = require('../installer');

const mod = name => [`${name}/Scripts/main.lua`, `${name}/enabled.txt`, `${name}/LICENSE`];

test('keeps separate mod roots and native helpers without file collisions', () => {
    const files = [...mod('AutoMenu'), 'AutoMenu/Scripts/auto_menu_bridge.dll', ...mod('SmartDelivery'),
        'SmartDelivery/Scripts/delivery_bridge.dll'];
    assert.equal(testSupported(files), true);
    const { instructions } = install(files);
    assert.deepEqual(instructions.map(i => i.destination), files.map(f => f.replaceAll('/', '\\')));
    assert.deepEqual(instructions.map(i => i.source), files);
});

test('unwraps an outer download folder without flattening the mod', () => {
    const files = ['release\\', ...mod('BartendersNote').map(f => `release\\${f.replaceAll('/', '\\')}`)];
    assert.deepEqual(install(files).instructions.map(i => i.destination),
        mod('BartendersNote').map(f => f.replaceAll('/', '\\')));
});

test('rejects incomplete mods, loader packages and ambiguous layouts', () => {
    assert.throws(() => install(['AutoMenu/Scripts/main.lua']), /Missing/);
    assert.throws(() => install([...mod('AutoMenu'), 'UE4SS.dll']), /outside/);
    assert.throws(() => install([...mod('AutoMenu'), ...mod('release/AutoMenu')]), /Conflicting/);
    assert.throws(() => install([...mod('A'), ...mod('A/B')]), /outside/);
    assert.throws(() => install([...mod('AutoMenu'), 'automenu/LICENSE']), /outside|Conflicting/);
    assert.equal(testSupported(['dwmapi.dll', 'UE4SS.dll']), false);
});

test('rejects paths that could escape or alias Windows destinations', () => {
    for (const bad of ['../escape', '/absolute', 'C:\\escape', 'A/file:stream',
        'A/../escape', 'A/CON.txt', 'A/trailing. /file', 'A/NUL', 'A/evil\u0000file']) {
        assert.throws(() => install([...mod('A'), bad]), /Unsafe/);
    }
});
