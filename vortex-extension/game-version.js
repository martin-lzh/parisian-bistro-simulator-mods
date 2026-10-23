'use strict';

const fs = require('node:fs/promises');
const path = require('node:path');

// Game versions confirmed in releases/validation.md. The EXE reports Unreal's version.
const GAME_VERSIONS = new Map([
    ['25759268', '1.0.2.44eb'],
    ['25822788', '1.0.2.44eb'],
]);

function field(manifest, name) {
    const matches = [...manifest.matchAll(new RegExp(`"${name}"\\s+"([^"\\r\\n]*)"`, 'g'))];
    return matches.length === 1 ? matches[0][1] : undefined;
}

async function getGameVersion(gamePath) {
    const root = path.resolve(gamePath);
    const common = path.dirname(root);
    const steamapps = path.dirname(common);
    if (path.basename(common).toLowerCase() !== 'common'
        || path.basename(steamapps).toLowerCase() !== 'steamapps') return 'Unknown';

    let manifest;
    try {
        manifest = await fs.readFile(path.join(steamapps, 'appmanifest_3058360.acf'), 'utf8');
    } catch {
        return 'Unknown';
    }
    const installDir = field(manifest, 'installdir');
    const buildId = field(manifest, 'buildid');
    if (field(manifest, 'appid') !== '3058360' || !installDir
        || path.resolve(common, installDir).toLowerCase() !== root.toLowerCase()
        || !/^\d+$/.test(buildId ?? '')) return 'Unknown';

    return GAME_VERSIONS.get(buildId) ?? `Steam Build ${buildId}`;
}

module.exports = { getGameVersion };
