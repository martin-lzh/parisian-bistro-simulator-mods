"""Detect Steam public build changes without downloading or launching the game."""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import time

from release import GitHub

BASELINE = Path(__file__).with_name("game-build-baseline.json")
MARKER = "<!-- steam-build-monitor:v1 "
BOT = "github-actions[bot]"
TOKEN = re.compile(r'\s+|//[^\n]*|"(?:\\.|[^"\\])*"|[{}]')


def positive_id(value):
    if not isinstance(value, str) or not re.fullmatch(r"[1-9][0-9]{0,19}", value):
        raise ValueError("Expected a positive decimal Steam identifier")
    return value


def validate_snapshot(snapshot):
    if not isinstance(snapshot, dict) or set(snapshot) != {"buildid", "timeupdated"}:
        raise ValueError("Invalid Steam build snapshot")
    positive_id(snapshot["buildid"])
    positive_id(snapshot["timeupdated"])
    utc(snapshot["timeupdated"])
    return snapshot


def utc(timestamp):
    return datetime.fromtimestamp(int(timestamp), timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")


def load_baseline(path):
    config = json.loads(path.read_text(encoding="utf-8"))
    if (config["schema"] != 1 or config["appid"] != "3058360" or config["branch"] != "public"
            or config["name"] != "Parisian Bistro Simulator"
            or config["repository"] != "martin-lzh/parisian-bistro-simulator-mods"):
        raise ValueError("Expected Parisian Bistro Simulator's public branch baseline")
    validate_snapshot(config["initialBuild"])
    return config


def parse_app_info(output, appid):
    """Read the exact app's KeyValues object, ignoring SteamCMD's surrounding log."""
    match = re.search(r'^\s*"' + re.escape(appid) + r'"\s*(?=\{)', output, re.MULTILINE)
    if not match:
        raise ValueError("SteamCMD did not return the requested app metadata")
    position = match.end()

    def token():
        nonlocal position
        while position < len(output):
            found = TOKEN.match(output, position)
            if not found:
                raise ValueError("Malformed Steam KeyValues data")
            position = found.end()
            value = found.group()
            if value.isspace() or value.startswith("//"):
                continue
            return value
        raise ValueError("Truncated Steam KeyValues data")

    def string(value):
        if not value.startswith('"'):
            raise ValueError("Expected a quoted Steam KeyValues string")
        return re.sub(r'\\([\\"])', r'\1', value[1:-1])

    def block(depth=0):
        if depth > 64:
            raise ValueError("Steam KeyValues nesting limit exceeded")
        result = {}
        while (key := token()) != "}":
            key = string(key)
            if key in result:
                raise ValueError("Duplicate Steam KeyValues key")
            value = token()
            result[key] = block(depth + 1) if value == "{" else string(value)
        return result

    if token() != "{":
        raise ValueError("Missing Steam KeyValues object")
    return block()


def extract_snapshot(output, config):
    app = parse_app_info(output, config["appid"])
    if app.get("common", {}).get("name") != config["name"]:
        raise ValueError("Steam returned an unexpected game name")
    branch = app.get("depots", {}).get("branches", {}).get(config["branch"], {})
    return validate_snapshot({key: branch.get(key) for key in ("buildid", "timeupdated")})


def query_steam(steamcmd, config):
    executable = steamcmd.resolve(strict=True)
    command = [str(executable), "+login", "anonymous", "+app_info_update", "1",
               "+app_info_print", config["appid"], "+quit"]
    for attempt in range(2):
        try:
            result = subprocess.run(command, cwd=executable.parent, capture_output=True,
                                    timeout=180, check=True)
            output = result.stdout.decode("utf-8", errors="replace")
            if not re.search(r"Connecting anonymously to Steam Public\.\.\.\s*OK\b", output):
                raise ValueError("SteamCMD did not confirm an anonymous connection; cached data is insufficient")
            return extract_snapshot(output, config)
        except (subprocess.SubprocessError, ValueError) as error:
            if attempt:
                raise RuntimeError("SteamCMD query failed; no monitoring state was advanced") from error
            time.sleep(5)
    raise AssertionError("Unreachable")


def previous_build(github, config):
    """The newest bot-created event is the durable state, even after closing it."""
    for page in range(1, 101):
        batch = github.request(f"/issues?state=all&sort=created&direction=desc&per_page=100&page={page}")
        if not isinstance(batch, list):
            raise ValueError("Cannot read monitor history; refusing to reset the baseline")
        for issue in batch:
            if "pull_request" in issue or issue.get("user", {}).get("login") != BOT:
                continue
            body = issue.get("body") or ""
            if MARKER not in body:
                continue
            match = re.search(re.escape(MARKER) + r'([^\n]+) -->', body)
            if not match:
                raise ValueError("Malformed build monitor state in an existing issue")
            state = json.loads(match[1])
            if state["appid"] == config["appid"] and state["branch"] == config["branch"]:
                return validate_snapshot(state["current"])
        if len(batch) < 100:
            return config["initialBuild"]
    raise ValueError("Issue pagination limit exceeded; refusing to reset the baseline")


def issue_payload(previous, current, config):
    state = dict(appid=config["appid"], branch=config["branch"], current=current)
    title = f'Steam public build changed: {previous["buildid"]} → {current["buildid"]}'
    body = f"""SteamCMD anonymously observed a change to Parisian Bistro Simulator's public build.
SteamCMD 匿名查询发现 Parisian Bistro Simulator 正式分支构建发生变化。

| Field / 字段 | Previous / 上次 | Current / 当前 |
| --- | --- | --- |
| Build ID | `{previous['buildid']}` | `{current['buildid']}` |
| Branch update / 分支更新时间 | {utc(previous['timeupdated'])} | {utc(current['timeupdated'])} |

App ID: `{config['appid']}` · Branch / 分支: `{config['branch']}`

Build IDs identify Steam builds, not the game's displayed version. A change can also be a rollback.
Build ID 不是游戏显示的版本号；构建切换也可能是回滚。

- [ ] Record the installed game version, executable hash and UE4SS build. / 记录实际游戏版本、可执行文件哈希与 UE4SS 构建。
- [ ] Review affected Unreal types, Lua hooks, native helpers and multiplayer behavior. / 检查受影响的 Unreal 类型、Lua 钩子、原生辅助模块与联机行为。
- [ ] Run the applicable builds, contracts and in-game checks before declaring compatibility. / 声明兼容前完成相关构建、契约及实机检查。

[Official announcements / 官方公告](https://store.steampowered.com/news/app/{config['appid']})
· [Development and compatibility / 开发与兼容性](https://github.com/{config['repository']}/blob/main/DEVELOPMENT.md)

This observation does not change game files, Mod versions or release authorization.
此检测记录不变更游戏文件、Mod 版本或发布授权。

Keep the metadata below when editing or closing this issue; it prevents duplicate alerts.
编辑或关闭此 Issue 时请保留下方元数据，以避免重复提醒。
{MARKER}{json.dumps(state, separators=(',', ':'))} -->
"""
    return dict(title=title, body=body)


def check_build(current, config, github=None, notify=False):
    validate_snapshot(current)
    if notify and github is None:
        raise ValueError("Notifications require a GitHub repository")
    previous = previous_build(github, config) if github else config["initialBuild"]
    changed = previous["buildid"] != current["buildid"]
    report = dict(appid=config["appid"], branch=config["branch"], previous=previous,
                  current=current, changed=changed, notified=False)
    if changed and notify:
        issue = github.request("/issues", method="POST", payload=issue_payload(previous, current, config))
        report.update(notified=True, issue=issue["html_url"])
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--steamcmd", required=True, type=Path, help="Path to an initialized SteamCMD executable")
    parser.add_argument("--repository", help="Read prior GitHub issues (requires GH_TOKEN)")
    parser.add_argument("--notify", action="store_true", help="Create an issue when the public Build ID changes")
    args = parser.parse_args()
    if args.notify and not args.repository:
        parser.error("--notify requires --repository")
    config = load_baseline(BASELINE)
    if args.repository and args.repository != config["repository"]:
        parser.error("Repository does not match the reviewed monitor configuration")
    if args.notify and (os.environ.get("GITHUB_ACTIONS") != "true"
                        or os.environ.get("GITHUB_REF") != "refs/heads/main"
                        or os.environ.get("GITHUB_REPOSITORY") != config["repository"]):
        parser.error("Notifications must run in this repository's main-branch GitHub Actions workflow")
    github = GitHub(args.repository) if args.repository else None
    current = query_steam(args.steamcmd, config)
    report = check_build(current, config, github, args.notify)
    print(json.dumps(report, ensure_ascii=False, indent=2))
    if summary := os.environ.get("GITHUB_STEP_SUMMARY"):
        status = "changed" if report["changed"] else "unchanged"
        with open(summary, "a", encoding="utf-8") as stream:
            stream.write(f"Steam public build: **{current['buildid']}** ({status}).\n\n")
            if report["notified"]:
                stream.write(f"[Compatibility check issue]({report['issue']})\n")
            elif report["changed"]:
                stream.write("Read-only check; no issue created.\n")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, RuntimeError, OverflowError) as error:
        print(f"Build monitor failed: {error}", file=sys.stderr)
        sys.exit(1)
