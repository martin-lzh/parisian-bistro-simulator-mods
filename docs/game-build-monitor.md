# Steam game build monitoring

The [Steam game build monitor](../.github/workflows/game-build-monitor.yml) checks **Parisian Bistro Simulator**, Steam App ID **3058360**, using Valve's anonymous SteamCMD metadata service. It reads `depots.branches.public.buildid` without downloading, updating or launching the game.

## Schedule and notifications

Checks run on the default `main` branch every six hours: **00:41, 06:41, 12:41 and 18:41 UTC**. You can also run the workflow from [GitHub Actions](https://github.com/martin-lzh/parisian-bistro-simulator-mods/actions/workflows/game-build-monitor.yml). Relevant pushes to `dev` or `development` perform a live read-only check; only this repository's `main` workflow can create notifications.

A changed Build ID creates a bilingual compatibility-check Issue containing the previous and current builds, branch-update timestamps, the official Steam news link and a checklist for Unreal types, Lua hooks, native helpers and multiplayer behavior. A rollback also counts as a change. Unchanged builds and timestamp-only changes produce no Issue.

The latest monitor Issue created by `github-actions[bot]` is the persistent record, including closed Issues. Preserve its hidden metadata when editing or closing it. This avoids repeat alerts and does not require repository write access or an expiring Actions cache. Deleting monitor Issues removes detection history. An interrupted Issue creation is recovered from that history on the next successful run.

One concurrency group serializes scheduled, manual and branch runs. Invalid Steam data, failed anonymous login, query timeouts and failed GitHub history reads fail the workflow without advancing the recorded build. Issue creation is not blindly retried after an uncertain response. A run can observe only the build available at query time; it cannot reconstruct brief changes between checks.

## Initial baseline

The committed [baseline](../tools/game-build-baseline.json) was queried directly from Valve on **2026-09-26**:

| Field | Value |
| --- | --- |
| Game | Parisian Bistro Simulator |
| Steam App ID | `3058360` |
| Branch | `public` |
| Build ID | `25532071` |
| Branch updated | `2026-09-25 15:46:15 UTC` |

With no monitor history, the workflow compares against this baseline rather than accepting whichever build exists on the first run. Build IDs are not the game's displayed version or proof of Mod compatibility. Follow [Development](../DEVELOPMENT.md) and the [validation record](../releases/validation.md) before claiming compatibility with a new build. The monitor does not change Mod versions, packages, game files or release authorization.

## Permissions and local checks

No Steam account, Steam API key or additional GitHub secret is needed. The workflow uses the automatically provided `GITHUB_TOKEN` with `contents: read` and `issues: write`. SteamCMD comes from Valve's HTTPS installer endpoint, and its Valve Authenticode signature is checked before bootstrap execution. Raw metadata, logs and third-party tools belong only in ignored `work/`.

After installing and initializing SteamCMD in `work/`, a local read-only query is:

```powershell
python tools/game_build_monitor.py --steamcmd work/steamcmd-monitor/steamcmd.exe
python -m unittest discover -s tools/tests -p test_game_build_monitor.py -v
```

Without `--repository`, the command compares with the committed baseline only. Supplying `--repository martin-lzh/parisian-bistro-simulator-mods` and the `GH_TOKEN` environment variable also reads the bot's Issue history. `--notify` is restricted to this repository's `main` GitHub Actions environment. Never put a token in command arguments or tracked files.

GitHub notifications depend on your repository watch settings and Actions notification preferences. Scheduled runs may be delayed, and GitHub automatically disables schedules in public repositories after 60 days without activity; re-enable the workflow in Actions if needed.

## Sources

- [Parisian Bistro Simulator on Steam](https://store.steampowered.com/app/3058360/Parisian_Bistro_Simulator/)
- [Valve SteamCMD documentation](https://developer.valvesoftware.com/wiki/SteamCMD)
- [GitHub scheduled workflow rules](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule)
- [Old Market Simulator's original monitor](https://github.com/martin-lzh/old-market-simulator-mods/blob/main/tools/game_build_monitor.py), adapted for this game's metadata and Unreal/UE4SS compatibility checks.
