'use strict';

const path = require('path');
const { fs, util } = require('vortex-api');
const { install, testSupported } = require('./installer');

const GAME_ID = 'parisianbistrosimulator';
const STEAM_ID = '3058360';
const BINARIES = path.join('BrasserieSimulator', 'Binaries', 'Win64');
const MODS = path.join(BINARIES, 'ue4ss', 'Mods');

async function prepare(discovery) {
    // The loader owns this layout. Discovery must never install or replace it.
    try {
        const loader = await fs.statAsync(path.join(discovery.path, BINARIES, 'ue4ss', 'UE4SS.dll'));
        const mods = await fs.statAsync(path.join(discovery.path, MODS));
        if (!loader.isFile() || !mods.isDirectory()) throw new Error('Missing loader');
    } catch (error) {
        throw new Error('Install UE4SS experimental first, keeping its ue4ss/UE4SS.dll and ue4ss/Mods layout. See https://docs.ue4ss.com/dev/installation-guide.html');
    }
}

function main(context) {
    context.registerGame({
        id: GAME_ID,
        name: 'Parisian Bistro Simulator',
        mergeMods: true,
        queryPath: () => util.GameStoreHelper.findByAppId([STEAM_ID]).then(game => game.gamePath),
        queryModPath: () => MODS,
        executable: () => 'BrasserieSimulator.exe',
        requiredFiles: [
            'BrasserieSimulator.exe',
            path.join(BINARIES, 'BrasserieSimulator-Win64-Shipping.exe'),
        ],
        logo: 'gameart.png',
        setup: prepare,
        environment: { SteamAPPId: STEAM_ID },
        details: { steamAppId: STEAM_ID },
    });
    context.registerInstaller('parisianbistrosimulator-ue4ss', 25,
        (files, gameId) => Promise.resolve({
            supported: gameId === GAME_ID && testSupported(files),
            requiredFiles: [],
        }),
        files => Promise.resolve(install(files)));
    return true;
}

module.exports = { default: main };
