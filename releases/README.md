# Releases

Each Mod is versioned and released on its own, with tags named `<mod>-v<version>` (for example `scan-to-order-v0.1.2`). Pull requests into `main` exist to ship new versions: merging one is the maintainer's approval, and CI then publishes automatically. The same flow and the same release code run in the sibling repositories [old-market-simulator-mods](https://github.com/martin-lzh/old-market-simulator-mods) and farming-simulator-25-mods.

## How a version ships

1. **Work on `dev`.** Changes are recorded under `Unreleased` in the Mod's `CHANGELOG.md`; version numbers stay as they are. Versions ending in `-dev` are never released.
2. **Test in game.** Before any release, beta included, the maintainer tests the build in game. Test builds are identified by commit and SHA256.
3. **Prepare the version** (only on the maintainer's instruction). Update `VERSION` in `build.py`, the diagnostic version, the Mod README and the root README; move `Unreleased` into `## X.Y.Z - YYYY-MM-DD`; set `prerelease` in `release.json`.
4. **Open a PR from `dev` to `main`.** CI checks repository boundaries and syntax, runs the Vortex extension and Lua tests, builds every package, checks its contents and shows a **Release plan** table in the build job summary.
5. **The maintainer merges.** The release job publishes every new version and promotes betas, using the packages built and verified in the same run.

## Betas and stable releases

`"prerelease": true` in a Mod's `release.json` publishes the version as a GitHub pre-release: a closed beta for a few early testers. When it's ready for everyone, set `"prerelease": false` without changing the version and merge again; CI turns the existing release into a stable one without re-uploading anything. A stable release is never turned back into a beta.

## The release plan

| Result | Meaning |
| --- | --- |
| publish | New numbered version: it is released when the PR is merged. |
| promote | Existing beta whose `release.json` now says stable. |
| current | Already released; nothing to do. |
| waiting | Already released; its `Unreleased` changes ship with the next version. |
| skip | Development (`-dev`) version, never released. |
| error | Something must be fixed before merging. CI fails. |

Errors include: a version not newer than the latest release; a new version while `Unreleased` still has entries; no CHANGELOG entry for the version; a status note in the version heading; a tag without a release; `release.json` asking for a beta when the release is already stable.

## What the release job guarantees

- It publishes from the packages of the same CI run, after checking the file list, every file's content and the build evidence against the merged commit.
- It creates a draft, uploads the ZIP and `SHA256SUMS.txt`, downloads them again to compare the bytes, then publishes and checks that the tag points at the merged commit.
- Published files and tags are never replaced or moved. A broken release is fixed with a new patch version. Documentation-only changes wait for the next version; published ZIPs are no longer refreshed in place.
- One Mod's problem doesn't stop the others; the job fails at the end with every error listed.
- After an interrupted run, rerun the failed jobs. A leftover draft is only reused when it belongs to the same commit and notes.

Release titles use the Mod's `displayName` from `release.json`. The release text names the ZIP to download, links to the Mod README and adds the CHANGELOG entry.

## Package contents

Each package is `<Name>-<version>.zip` with a `<Name>/` folder holding the Lua scripts, `README.md`, `DEVELOPMENT.md`, `CHANGELOG.md`, `LICENSE` and an empty `enabled.txt`. Smart Delivery and Auto Menu also include their helper DLL, built in CI from tracked source. UE4SS, game files and reference material are never packaged.

## Commands

```powershell
python tools/ci.py validate
python tools/ci.py build
$env:GH_TOKEN = gh auth token; python tools/ci.py release-plan --repository martin-lzh/parisian-bistro-simulator-mods
```

`release-plan` only reads from GitHub. Publishing runs only in CI on `main`.

## Shared release code

[`tools/modrelease.py`](../tools/modrelease.py) and its tests are identical in all three Mod repositories. Change them in all three together. This repository's `tools/release.py` checks the CI packages and describes the Mods to the shared code.

## History

- [`validation.md`](validation.md): in-game testing records, including the 2026-09-26 acceptance of all seven Mods and later game-build support.
- `documentation-refresh-*.md`: three earlier occasions when published ZIPs had their documentation replaced in place. This is no longer done.
- [`approvals/`](approvals/README.md): source-bound approval records used before merging became the approval. Kept for history only.
