# Development / 开发

[English](#english) · [中文](#中文)

## English

Player guides: [project](README.md#english), [Bartender's Note](bartenders-note-mod/README.md#english), [Auto Checkout](auto-checkout-mod/README.md#english). Implementation and test checklists: [Bartender's Note](bartenders-note-mod/DEVELOPMENT.md#english) · [Auto Checkout](auto-checkout-mod/DEVELOPMENT.md#english). See [languages](docs/localization.md#english), [validation](releases/validation.md#english) and [release management](releases/README.md#english) for their respective scope.

### Repository layout and boundaries

| Path | Purpose | Tracked |
| --- | --- | --- |
| `<feature>-mod/` | Independent original Mod source, build entry point and documentation | Yes |
| `docs/` | Original design, compatibility and documentation index | Yes |
| `tools/` | Original build, packaging and repository checks | Yes |
| `releases/` | Version, authorization and validation records | Yes |
| `work/` | All game references, extracted material, analysis, logs, tools and research scripts | No |
| `outputs/` | Local ZIPs, checksums and CI packages | No |

Read [AGENTS.md](AGENTS.md) before making changes. Local reference locations are documented in `work/reference/README.md`; a Git clone does not include them. Game installations are read-only during development. Builds never install a Mod, edit a save, or start or close the game.

All reverse-engineering material belongs in ignored `work/`, including game files, assets, mappings, blueprints, native analysis, SDK/header exports, memory snapshots, logs, third-party tools, extraction scripts and research notes. Do not copy it into tracked directories or force-add ignored files, even in this private repository. Packages contain original Mod files and necessary notices only.

### Build and checks

The offline build uses Python and uv, with `lupa==2.6` providing Lua 5.4 for behavior tests. CI pins Python 3.12 and uv 0.10.7. It does not need the game, UE4SS or local references.

Smart Delivery also builds an original Windows x64 helper with MSVC C++/MASM and the Windows SDK, and executes a native dispatch test harness. It uses an explicit generated-DLL allowlist; no binaries are tracked. CI records the compiled helper's hash in commit-bound build evidence for package and release verification.

Run from the repository root:

```powershell
python tools/check_repository.py
python tools/check_syntax.py
python -m unittest discover -s tools/tests -v
python tools/ci.py build
git diff --check
```

`tools/ci.py build` runs all registered Mods' tests, creates packages through their independent `build.py` entry points, and verifies their file lists, source bytes and SHA-256 checksums. Each Mod can also be tested and built separately as its development guide describes. Keep `outputs/ci/` empty or limited to the current versions before a combined build; move older output aside after a version change.

These checks establish offline behavior and package integrity, not rendering, real engine bridging or in-game acceptance. The confirmed game baseline is recorded separately from reported player test environments in the [validation record](releases/validation.md#english).

### Adding or changing a Mod

Create an independent `<feature>-mod/` only when there is an actual feature to implement. Maintain a bilingual `README.md` for players, bilingual `DEVELOPMENT.md` for implementation and validation, and `CHANGELOG.md` with pending changes under `Unreleased`. Add meaningful tests for behavior that can be verified offline. Keep package allowlists explicit and update version/diagnostic checks together when a version advances.

Read the game language at runtime and reuse native text before adding original translations; see [localization](docs/localization.md#english). Keep each Mod self-contained. The folder convention follows Old Market Simulator Mods, but its Unity/C# interfaces, loaders and SDK are not applicable to this Unreal game. Verify engine types and calls against local references; do not invent signatures or describe extracted assets as recovered original C++ source.

### Commits, CI and branch protection

Use the current working directory without creating temporary worktrees. Work on `development` or a feature branch and merge to protected `main` through a PR. A PR from `development` targets `main`. Do not bypass branch protection. Commit and push task-related changes at the end of each task unless explicitly told not to; preserve unrelated user changes.

Selectively stage intended files, run `python tools/check_repository.py`, review `git diff --staged`, and check `git diff --check` and `git status --short` before committing. The repository checker examines tracked and staged paths, so stage new intended files before the final check. A clean worktree does not require deleting ignored `work/` or `outputs/`.

The `.github/workflows/mods.yml` workflow runs on pushes to `main`, `dev` and `development`, PRs targeting `main`, and manual dispatch:

- **Script, data and workflow syntax:** repository boundaries, Python/JSON syntax, whitespace and actionlint. The actionlint download uses a pinned version and SHA-256.
- **Lua tests and packages:** version and CHANGELOG checks, diagnostic version and package allowlists, packaging tests, all Mod behavior tests, ZIP contents and checksums, followed by a read-only release preflight.
- The **mod-packages** artifact contains the registered Mods' current ZIPs, their checksum files and commit-tagged `build-info.json`, retained for 14 days. Actions are pinned to commit SHAs and default to read-only repository access.
- A successful **main push** can run the release job for explicitly authorized new numbered versions. Only that job receives `contents: write`; development versions do not become releases automatically. See [release management](releases/README.md#english).

`.github/main-ruleset.json` describes the intended GitHub ruleset: PR required, branch up to date with `main`, both required checks passing, no force-push/delete or bypass, and zero required approving reviewers. Editing the JSON does not apply remote settings. Maintainers must explicitly apply and read back repository rules through the API; CI has no repository administration credentials. The repository remains private.

## 中文

玩家说明：[项目](README.md#中文)、[Bartender's Note](bartenders-note-mod/README.md#中文)、[Auto Checkout](auto-checkout-mod/README.md#中文)。实现与验收清单：[Bartender's Note](bartenders-note-mod/DEVELOPMENT.md#中文) · [Auto Checkout](auto-checkout-mod/DEVELOPMENT.md#中文)。另有[多语言适配](docs/localization.md#中文)、[验收记录](releases/validation.md#中文)和[版本管理](releases/README.md#中文)。

### 目录与内容边界

| 路径 | 用途 | Git 跟踪 |
| --- | --- | --- |
| `<feature>-mod/` | 独立原创 Mod 源码、构建入口和文档 | 是 |
| `docs/` | 原创设计、兼容性与文档索引 | 是 |
| `tools/` | 原创构建、打包与仓库检查脚本 | 是 |
| `releases/` | 版本、授权与验收记录 | 是 |
| `work/` | 全部游戏参考、提取资料、分析、日志、工具及研究脚本 | 否 |
| `outputs/` | 本地 ZIP、校验文件与 CI 产物 | 否 |

改动前阅读 [AGENTS.md](AGENTS.md)。本机参考入口是 `work/reference/README.md`，不会随 Git 克隆同步。开发期间游戏安装目录只读；构建不安装 Mod、不改存档，也不启动或关闭游戏。

所有反编译相关内容均放在被忽略的 `work/`，包括游戏文件、资产、映射、蓝图、原生分析、SDK/头文件导出、内存快照、日志、第三方工具、提取脚本和研究笔记。即使仓库私密，也不得复制到跟踪目录或强制加入 Git。安装包只含原创 Mod 文件和必要声明。

### 构建与检查

离线构建使用 Python 和 uv，`lupa==2.6` 提供 Lua 5.4 行为测试环境。CI 固定 Python 3.12 和 uv 0.10.7，不需要游戏、UE4SS 或本机参考资料。

Smart Delivery 还使用 MSVC C++/MASM 和 Windows SDK 构建原创 Windows x64 辅助模块，并执行原生分派测试。生成的 DLL 使用固定白名单，不跟踪二进制文件。CI 在绑定提交的构建证据中记录辅助模块哈希，用于安装包及发布校验。

在仓库根目录执行：

```powershell
python tools/check_repository.py
python tools/check_syntax.py
python -m unittest discover -s tools/tests -v
python tools/ci.py build
git diff --check
```

`tools/ci.py build` 运行所有已登记 Mod 的测试，调用各自独立的 `build.py` 打包，再检查文件清单、源码字节和 SHA-256。各 Mod 也可按自己的开发说明单独测试和构建。组合构建前，`outputs/ci/` 应为空或只含当前版本；升级版本后先移走旧产物。

这些检查验证离线行为与包完整性，不代表渲染、真实引擎桥接或实机验收通过。[验收记录](releases/validation.md#中文)区分本机开发参考基线与用户实际反馈的测试环境。

### 新增与维护 Mod

有实际功能要实现时才创建独立 `<feature>-mod/`。维护面向玩家的双语 `README.md`、面向实现与验收的双语 `DEVELOPMENT.md`，以及将待发布内容放在 `Unreleased` 的 `CHANGELOG.md`。仅为适合离线验证的行为添加有意义的测试。打包使用固定白名单；推进版本时同步更新版本与诊断检查。

运行时读取游戏语言，优先复用原生文案，再补充原创翻译，详见[多语言适配](docs/localization.md#中文)。各 Mod 保持独立。目录组织参考菜市场模拟器，但该项目的 Unity/C# 接口、加载器及 SDK 不适用于本 Unreal 游戏。类型和调用须经本机参考核对，不编造签名，也不把资源提取称为恢复原始 C++ 源码。

### 提交、CI 与分支保护

直接使用当前工作目录，不创建临时工作树。在 `development` 或功能分支开发，通过 PR 合入受保护的 `main`；从 `development` 开 PR 时，目标为 `main`。不得绕过保护。每次任务结束提交并推送任务相关改动，除非用户明确要求不推送；保留无关用户改动。

选择性暂存目标文件，执行 `python tools/check_repository.py`，审查 `git diff --staged`，并在提交前检查 `git diff --check` 和 `git status --short`。仓库检查器审查已跟踪及暂存路径，因此新增目标文件应先暂存再做最终检查。干净的 Git 工作区不代表删除被忽略的 `work/` 或 `outputs/`。

`.github/workflows/mods.yml` 在 `main`、`dev`、`development` 推送，目标为 `main` 的 PR，以及手动运行时执行：

- **Script, data and workflow syntax：**检查仓库边界、Python/JSON 语法、空白和 actionlint。actionlint 下载固定版本并校验 SHA-256。
- **Lua tests and packages：**核对版本与 CHANGELOG、诊断版本与打包白名单，运行包检查器测试、全部 Mod 行为测试及 ZIP 内容和哈希检查，然后只读预检发布条件。
- **mod-packages** artifact 包含已登记 Mod 的当前 ZIP、各自校验文件，以及记录提交号的 `build-info.json`，保留 14 天。Actions 固定提交 SHA，默认只读仓库。
- **main 推送**通过检查后，可以为已明确授权的新编号版本运行发布任务。仅该任务拥有 `contents: write`；开发版不会自动转为正式版。详见[版本管理](releases/README.md#中文)。

`.github/main-ruleset.json` 记录 GitHub 规则集目标：必须经 PR、分支包含最新 `main`、两个必需检查均通过；禁止强推和删除、无绕过者，要求审批人数为零。修改 JSON 不会自动应用到远端。维护者须通过 API 显式应用并回读核对；CI 不持有仓库管理凭据。仓库持续保持私密。
