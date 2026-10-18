# Releases

Each Mod is versioned and released on its own, with tags named `<mod>-v<version>` (for example `scan-to-order-v0.1.2`). Pull requests into `main` exist to ship new versions: merging one is the maintainer's approval, and CI then publishes automatically. The same flow and the same release code run in the sibling repositories [old-market-simulator-mods](https://github.com/martin-lzh/old-market-simulator-mods) and farming-simulator-25-mods.

## How a version ships

1. **Work on `dev`.** Changes are recorded under `Unreleased` in the Mod's `CHANGELOG.md`; version numbers stay as they are. Versions ending in `-dev` are never released.
2. **Test in game.** Before any release, beta included, the maintainer tests the build in game. Test builds are identified by commit and SHA256.
3. **Prepare the version** (only on the maintainer's instruction). Update `VERSION` in `build.py`, the diagnostic version, the Mod README and the root README; move `Unreleased` into `## X.Y.Z - YYYY-MM-DD`; set `prerelease` in `release.json`.
4. **Open a PR from `dev` to `main`.** CI checks repository boundaries and syntax, runs the Vortex extension and Lua tests, builds every package, checks its contents and shows a **Release plan** table in the summary of the **Changes and release plan** job.
5. **The maintainer merges.** The release job publishes every new version and promotes betas, using the packages built and verified in the same run.

## When CI runs

The workflow runs on pull requests into `main`, on pushes to `main` (merges) and when started by hand. Pushes to `dev` alone don't start it, so an open `dev` → `main` PR is checked once per push. To check `dev` without a PR, run `gh workflow run mods.yml --repo martin-lzh/parisian-bistro-simulator-mods --ref dev`.

| Job | Runner | When |
| --- | --- | --- |
| Changes and release plan | Linux | Always. Lists the changed files and shows the release plan; a release-plan error fails it. |
| Script, data and workflow syntax | Linux | Always. Runs actionlint only when files under `.github/` changed or on a manual run. |
| Build and test | Windows | When core files changed, a Mod would be published or promoted, the run was started by hand, or the first job failed. Otherwise skipped. |
| Publish new versions and promote betas | Linux | On pushes to `main` whose release plan publishes or promotes something. |
| CI result | Linux | Always. Passes when every job passed or was skipped on purpose. |

Only these files are non-core, so a change touching nothing else skips Build and test (`NON_CORE` in `tools/ci.py`): the root `README.md`, `AGENTS.md`, `DEVELOPMENT.md`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md` and `SUPPORT.md`, `docs/`, the root `assets/`, `releases/` and each Mod's `assets/` (packages hold only `Scripts/*.lua` and the Mod documents). Everything else is core, including each Mod's `README.md`, `DEVELOPMENT.md`, `CHANGELOG.md` and `LICENSE` (they are packaged), `release.json`, `vortex-extension/`, `tools/`, tests and `.github/`. For a pull request the changes are compared with its base; for a push with the previous commit of `main`; a manual run, or a push whose previous commit is unknown, counts as a core change. A skipped Build and test still counts as passed for the required checks on `main`.

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

[`tools/modrelease.py`](../tools/modrelease.py) and its tests are identical in all three Mod repositories. Change them in all three together; the same goes for [`tools/changes.py`](../tools/changes.py), which decides which CI jobs a change needs. This repository's `tools/release.py` checks the CI packages and describes the Mods to the shared code.

## History

- [`validation.md`](validation.md): in-game testing records, including the 2026-09-26 acceptance of all seven Mods and later game-build support.
- `documentation-refresh-*.md`: three earlier occasions when published ZIPs had their documentation replaced in place. This is no longer done.
- [`approvals/`](approvals/README.md): source-bound approval records used before merging became the approval. Kept for history only.
