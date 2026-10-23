'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs/promises');
const os = require('node:os');
const path = require('node:path');
const test = require('node:test');
const { getGameVersion } = require('../game-version');

async function fixture(t, fields) {
    const temporary = await fs.mkdtemp(path.join(os.tmpdir(), 'pbs-version-'));
    t.after(() => fs.rm(temporary, { recursive: true, force: true }));
    const steamapps = path.join(temporary, 'steamapps');
    const game = path.join(steamapps, 'common', 'Parisian Brasserie Simulator');
    await fs.mkdir(game, { recursive: true });
    if (fields !== null) {
        await fs.writeFile(path.join(steamapps, 'appmanifest_3058360.acf'),
            `"AppState"\n{\n${fields}\n}\n`);
    }
    return game;
}

const installed = '"appid" "3058360"\n"installdir" "Parisian Brasserie Simulator"';

test('uses the installed Steam build, not an engine version or pending update', async t => {
    for (const build of ['25759268', '25822788']) {
        const game = await fixture(t, `${installed}\n"buildid" "${build}"\n"TargetBuildID" "99999999"`);
        assert.equal(await getGameVersion(game), '1.0.2.44eb');
    }
});

test('identifies an unmapped build without claiming the previous game version', async t => {
    const game = await fixture(t, `${installed}\n"buildid" "99999999"`);
    assert.equal(await getGameVersion(game), 'Steam Build 99999999');
});

test('does not borrow version information from another game or install folder', async t => {
    for (const fields of [
        '"appid" "123"\n"installdir" "Parisian Brasserie Simulator"',
        '"appid" "3058360"\n"installdir" "Different Game"',
    ]) {
        const game = await fixture(t, `${fields}\n"buildid" "25822788"`);
        assert.equal(await getGameVersion(game), 'Unknown');
    }
});

test('missing or ambiguous metadata cannot become a false supported version', async t => {
    for (const fields of [null, installed,
        `${installed}\n"buildid" "bad"`,
        `${installed}\n"buildid" "25822788"\n"buildid" "99999999"`,
    ]) {
        const game = await fixture(t, fields);
        assert.equal(await getGameVersion(game), 'Unknown');
    }
});

test('a manually selected non-Steam folder does not use an unrelated manifest', async t => {
    const game = await fixture(t, `${installed}\n"buildid" "25822788"`);
    assert.equal(await getGameVersion(path.join(game, 'copied-game')), 'Unknown');
});
