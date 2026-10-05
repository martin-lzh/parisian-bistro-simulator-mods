'use strict';

const assert = require('node:assert/strict');
const test = require('node:test');
const vm = require('node:vm');
const fs = require('node:fs');
const path = require('node:path');
const installer = require('../installer');

function load(statAsync) {
    const registered = {};
    const module = { exports: {} };
    vm.runInNewContext(fs.readFileSync(path.join(__dirname, '..', 'index.js'), 'utf8'), {
        module,
        require: name => {
            if (name === 'path') return path.win32;
            if (name === './installer') return installer;
            if (name === 'vortex-api') return {
                fs: { statAsync },
                util: { GameStoreHelper: { findByAppId: async ids => {
                    assert.deepEqual(Array.from(ids), ['3058360']);
                    return { gamePath: 'X:\\Steam\\Bistro' };
                } } },
            };
            throw new Error(`Unexpected dependency: ${name}`);
        },
    });
    module.exports.default({
        registerGame: game => { registered.game = game; },
        registerInstaller: (id, priority, supports, install) => {
            registered.installer = { id, priority, supports, install };
        },
    });
    return registered;
}

test('registers the actual Steam game and relative UE4SS destination', async () => {
    const { game, installer: api } = load(async () => ({ isFile: () => true, isDirectory: () => true }));
    assert.equal(game.id, 'parisianbistrosimulator');
    assert.equal(await game.queryPath(), 'X:\\Steam\\Bistro');
    assert.equal(game.queryModPath(), 'BrasserieSimulator\\Binaries\\Win64\\ue4ss\\Mods');
    assert.equal(game.executable(), 'BrasserieSimulator.exe');
    assert.equal((await api.supports(['A/Scripts/main.lua'], 'oldmarketsimulator')).supported, false);
    assert.equal((await api.supports(['A/Scripts/main.lua'], game.id)).supported, true);
});

test('setup only reads the loader layout and refuses a missing loader', async () => {
    const reads = [];
    const { game } = load(async name => {
        reads.push(name);
        return { isFile: () => true, isDirectory: () => true };
    });
    await game.setup({ path: 'X:\\Game' });
    assert.deepEqual(reads, [
        'X:\\Game\\BrasserieSimulator\\Binaries\\Win64\\ue4ss\\UE4SS.dll',
        'X:\\Game\\BrasserieSimulator\\Binaries\\Win64\\ue4ss\\Mods',
    ]);
    const missing = load(async () => { throw new Error('ENOENT'); });
    await assert.rejects(missing.game.setup({ path: 'X:\\Game' }), /Install UE4SS experimental first/);
});
