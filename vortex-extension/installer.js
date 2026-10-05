'use strict';

const path = require('path').win32;

function normalize(file) {
    const name = file.replace(/\\/g, '/');
    if (name.startsWith('/') || /[\x00-\x1f:]/.test(name)
        || name.split('/').some(part => part === '.' || part === '..'
            || /[. ]$/.test(part) || /^(con|prn|aux|nul|com[1-9]|lpt[1-9])(\.|$)/i.test(part))) {
        throw new Error(`Unsafe archive path: ${file}`);
    }
    return name;
}

function testSupported(files) {
    return files.some(file => /(^|[\\/])[^\\/]+[\\/]Scripts[\\/]main\.lua$/i.test(file));
}

function install(files) {
    const entries = files.map(source => ({ source, name: normalize(source) }))
        .filter(entry => entry.name && !entry.name.endsWith('/'));
    const roots = entries.filter(entry => /\/Scripts\/main\.lua$/i.test(entry.name))
        .map(entry => entry.name.slice(0, -'/Scripts/main.lua'.length));
    if (!roots.length) throw new Error('Expected a UE4SS mod folder containing Scripts/main.lua.');

    const destinations = new Set();
    const instructions = entries.map(entry => {
        const owners = roots.filter(root => entry.name.startsWith(`${root}/`));
        if (owners.length !== 1) {
            throw new Error(`File is outside a single UE4SS mod folder: ${entry.source}. Install the loader separately.`);
        }
        const root = owners[0];
        const modName = root.split('/').pop();
        const destination = path.join(modName, entry.name.slice(root.length + 1));
        const key = destination.toLowerCase();
        if (destinations.has(key)) throw new Error(`Conflicting archive destination: ${destination}`);
        destinations.add(key);
        return { type: 'copy', source: entry.source, destination };
    });
    for (const root of roots) {
        const modName = root.split('/').pop();
        if (!destinations.has(`${modName}\\enabled.txt`.toLowerCase())) {
            throw new Error(`Missing ${modName}/enabled.txt. Use the complete mod release package.`);
        }
    }
    return { instructions };
}

module.exports = { install, testSupported };
