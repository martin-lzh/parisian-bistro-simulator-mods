# Development

## Game version detection

Vortex's `getGameVersion(gamePath, executable)` extension hook supplies the version
used by game details and collection exports. Without it, the game executable's
Unreal version (`5.4.4.0`) is used instead of the game's player-facing version.

`game-version.js` reads the selected installation's Steam app manifest, checks the
App ID and installation folder, and maps installed Build IDs 25759268 and 25822788
to `1.0.2.44eb`, as recorded in `releases/validation.md`. It reads `buildid`, not
`TargetBuildID`, so a pending download does not change the installed version.
Unmapped builds show their Steam Build ID. Missing or ambiguous metadata, or a
non-Steam layout, returns `Unknown` instead of the engine version. No game files
are written and the game is never started.

For native Vortex checks, use an isolated `steamapps/common/<installdir>` fixture
under ignored `work/`, with an app manifest containing only the App ID, install
folder and installed Build ID. Do not point deployment at the actual game.

Run `node --test vortex-extension/tests/*.test.js` and
`python vortex-extension/build.py`. This change retains extension version 0.1.1;
identify local builds by commit and package SHA256 until a release is requested.
