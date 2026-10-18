# Agent instructions

Source, build tooling and release automation for the Parisian Bistro Simulator Mods (Unreal Engine 5, UE4SS experimental, Lua; two Mods add original C++ helper DLLs). The sibling repositories `old-market-simulator-mods` and `farming-simulator-25-mods` follow the same rules; when you change a rule here, change it there too.

## Read first

- `README.md` for what players see, `DEVELOPMENT.md` for builds, tests and the supported game build, and `releases/README.md` for how releases work.
- The target Mod's `README.md`, `CHANGELOG.md`, `DEVELOPMENT.md`, `build.py` and `release.json`.
- `CONTRIBUTING.md` describes the workflow for outside contributors. Agents follow this file instead.

## Hard rules

1. **The game install is read-only.** Builds never install Mods, edit saves, or start or stop the game. The maintainer installs builds and does the in-game testing.
2. **No game content in git.** Game files, assets, mappings, blueprints, native-code analysis, SDK/header dumps, memory snapshots, logs, third-party tools, extraction scripts and analysis notes stay in the ignored `work/` folder, even though the repository is public; never `git add -f`. Packages contain only original files, chosen by each Mod's `build.py` allowlist.
3. **Check game APIs against the real game.** Verify Unreal types and calls against local references; never invent signatures, and never describe extracted assets as recovered C++ source. Don't copy Old Market Simulator's Unity/C# APIs, loader or SDK; only its folder layout.
4. **Versions change only when the maintainer says so.** Until then, record every change under `Unreleased` in that Mod's `CHANGELOG.md` and keep all version numbers. Identify test builds by commit and SHA256, not by a made-up version.
5. **Merging into `main` publishes.** Every new numbered CHANGELOG version that reaches `main` is released automatically, so only the maintainer merges. Open a PR to `main` only when the maintainer asks, and never merge it. Changing repository visibility also needs the maintainer.
6. **Commit and push to `dev` at the end of every task.** Run `python tools/check_repository.py`, review `git diff --staged`, and stage only files that belong to the task. Don't create git worktrees: the ignored `work/` references would be missing from them.
7. **Promotional material stays local.** Posters, generated art, copy and exports for Xiaohongshu, Steam or Nexus go in the ignored `outputs/` folder. Tracked Mod assets and README screenshots are not affected.

Use uv for Python dependencies. Add only code that is actually used; no dead code or empty plugins.

## Player-facing text

READMEs, CHANGELOG entries and release notes say what the Mod does and what the player should do. Leave out disclaimers ("not verified", "does not imply") and developer terms (reflection, hooks, hashes, CI artifacts); those belong in `DEVELOPMENT.md` and `releases/validation.md`. Bilingual documents put English first, then 中文, each complete. Links in packaged docs that point outside the Mod's folder use full `https://github.com/.../blob/main/...` URLs.

## Releasing a Mod

Do this only when the maintainer asks for a specific Mod and version:

1. The maintainer confirms in-game testing of the build being released. This applies to betas too.
2. Update `VERSION` in the Mod's `build.py`, the version in `Scripts/diagnostics.lua` or the `main.lua` start log, the Mod README version and download link, and the root README Mod table.
3. Move the `Unreleased` entries into `## X.Y.Z - YYYY-MM-DD`, written for players, English and 中文 lines paired. Leave the heading at version and date.
4. Set `"prerelease": true` in `release.json` for a closed beta for a few testers, or `false` for a stable release. To turn an existing beta into a stable release later, set it to `false` without changing the version.
5. Run the validation commands, commit, push `dev` and, when asked, open the PR. Fill in the PR template's version table.
6. Before the maintainer merges, tell them what the CI "Release plan" table says: which Mods will publish or be promoted, and which are skipped and why.

## Validation

```powershell
python tools/check_repository.py
python tools/check_syntax.py
python tools/ci.py validate
python -m unittest discover -s tools/tests -v
python tools/ci.py build
uv run --with lupa==2.6 python <mod>-mod/tests/run.py
```

Report which of these ran and which didn't. Passing builds and offline tests are not in-game testing.
