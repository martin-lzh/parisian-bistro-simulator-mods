# Development / 开发

[English](#english) · [中文](#中文)

## English

Start with [Contributing](CONTRIBUTING.md#english) for the change process and the [documentation index](docs/README.md#english) for player guides, implementation notes and test records. Installation and gameplay help belong in [Support](SUPPORT.md#english).

The [Steam build monitor](docs/game-build-monitor.md) checks the public game build every six hours and creates a compatibility Issue when it changes.

### Development environment

- Install Git, Python 3.12 and uv; make `git`, `python` and `uv` available in PowerShell. CI uses Python 3.12 and uv 0.10.7. Check `python --version` and `uv --version` before running the commands below.
- Building all seven Mods requires Windows x64 with Visual Studio or Build Tools, the C++ x64 tools and a Windows SDK. Smart Delivery also uses the x64 MASM assembler (`ml64`) for its native test harness. Auto Menu uses the C++ compiler for its helper and native tests.
- The native build scripts locate the C++ installation with `vswhere` and initialize `VsDevCmd.bat` themselves; use an ordinary PowerShell terminal at the repository root. The Lua-only Mods do not need the native compiler.
- Offline tests and packaging need no game installation, UE4SS, extracted SDK or local game references. The Lua test command uses uv to obtain the pinned `lupa==2.6` dependency; the first run may download it. Actual gameplay checks require the game and the loader described in the Mod's player guide.

For a first checkout, clone the public repository:

```powershell
git clone --branch dev https://github.com/martin-lzh/parisian-bistro-simulator-mods.git
cd parisian-bistro-simulator-mods
```

If a checkout already exists, use that directory and inspect `git status --short` before editing. Do not create another clone or a temporary worktree for the task. Read [AGENTS.md](AGENTS.md), then run the checks below. No generated files from another machine are required.

### Mod development guides

| Mod | Implementation and validation |
| --- | --- |
| Bartender's Note | [Development guide](bartenders-note-mod/DEVELOPMENT.md#english) |
| Auto Checkout | [Development guide](auto-checkout-mod/DEVELOPMENT.md#english) |
| Fresh to Serve | [Development guide](fresh-to-serve-mod/DEVELOPMENT.md#english) |
| First to Serve | [Development guide](first-to-serve-mod/DEVELOPMENT.md#english) |
| Smart Delivery | [Development guide](smart-delivery-mod/DEVELOPMENT.md#english) |
| Auto Menu | [Development guide](auto-menu-mod/DEVELOPMENT.md#english) |
| Scan to Order | [Development guide](scan-to-order-mod/DEVELOPMENT.md#english) |

See [languages](docs/localization.md#english), [validation](releases/validation.md#english) and [release management](releases/README.md#english) for shared requirements and recorded testing.

### Repository layout and boundaries

| Path | Purpose | Tracked |
| --- | --- | --- |
| `<feature>-mod/` | Independent original Mod source, build entry point and documentation | Yes |
| `docs/` | Original design, compatibility and documentation index | Yes |
| `tools/` | Original build, packaging and repository checks | Yes |
| `releases/` | Version, authorization and validation records | Yes |
| `LICENSE` | MIT license for original code and documentation | Yes |
| `work/` | All game references, extracted material, analysis, logs, tools and research scripts | No |
| `outputs/` | Local ZIPs, checksums and CI packages | No |

Read [AGENTS.md](AGENTS.md) before making changes. Local reference locations are documented in `work/reference/README.md`; a Git clone does not include them. Game installations are read-only during development. Builds never install a Mod, edit a save, or start or close the game.

All reverse-engineering material belongs in ignored `work/`, including game files, assets, mappings, blueprints, native analysis, SDK/header exports, memory snapshots, logs, third-party tools, extraction scripts and research notes. Do not copy it into tracked directories or force-add ignored files. Packages contain original Mod files and necessary notices only.

Each Mod owns its runtime and build inputs:

| Mod path | Purpose |
| --- | --- |
| `Scripts/` | Lua entry point and runtime modules |
| `tests/run.py` and `tests/` | Lua behavior tests and their runner |
| `build.py` | Version, explicit package allowlist and ZIP/checksum generation |
| `Native/` and `native_build.py` | Original helper source and native tests, for Smart Delivery and Auto Menu only |
| `README.md` | Player installation and usage guide |
| `assets/` | In-game test screenshots and promotional artwork for documentation; excluded from Mod ZIPs |
| `DEVELOPMENT.md` | Implementation details and test checklist |
| `CHANGELOG.md` | Pending changes and version history |
| `LICENSE` | Complete MIT text, identical to the root license |

### Mod images

Each Mod has an `assets/README.md` with naming and embedding examples. Following Old Market Simulator Mods, use `assets/cover.png` for the cover, `assets/<scene>-gameplay.png` for actual in-game captures, and `assets/<scene>-promo.png` for other promotional artwork. Keep test context with the images and distinguish artwork from gameplay evidence. Add embeds only after the images exist; the directory guide itself keeps the folder in Git until then.

Repository-only documents can use relative image paths. Player READMEs also ship in Mod ZIPs, which exclude `assets/`, so use a full GitHub image URL with `?raw=1` when embedding images there. Use a branch or tag that contains the image; public images do not require repository access. For example, after adding the actual file:

```markdown
![Bartender's Note cover artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/bartenders-note-mod/assets/cover.png?raw=1)
```

Keep social-platform exports, drafts and archives in ignored `outputs/<mod>/promo/`; extracted assets and reverse-engineering material remain in `work/`.

### Build and checks

The offline build uses Python and uv, with `lupa==2.6` providing Lua 5.4 for behavior tests. CI pins Python 3.12 and uv 0.10.7. It does not need the game, UE4SS or local references.

Smart Delivery and Auto Menu also build original Windows x64 helpers with MSVC and the Windows SDK, and execute native test harnesses. Smart Delivery's tests additionally use MASM. The build uses an explicit generated-DLL allowlist; no binaries are tracked. CI records each compiled helper's hash in commit-bound build evidence for package and release verification.

Run from the repository root:

```powershell
python tools/check_repository.py
python tools/check_syntax.py
python -m unittest discover -s tools/tests -v
python tools/ci.py build
git diff --check
```

`tools/ci.py build` runs all registered Mods' tests, creates packages through their independent `build.py` entry points, and verifies their file lists, source bytes and SHA-256 checksums. Every ZIP includes its complete `LICENSE`; configuration validation requires each Mod's license to match the root MIT license. Stage new intended package inputs before validation because the allowlist accepts only Git-tracked files. Each Mod can also be tested and built separately as its development guide describes. Keep `outputs/ci/` empty or limited to the current versions before a combined build; move older output aside after a version change.

These checks establish offline behavior and package integrity, not rendering, real engine bridging or in-game acceptance. The confirmed game baseline is recorded separately from reported player test environments in the [validation record](releases/validation.md#english).

### Adding or changing a Mod

Create an independent `<feature>-mod/` only when there is an actual feature to implement. Keep every README in English and Chinese, including player guides, image-directory guides and documentation indexes. Use `DEVELOPMENT.md` for implementation and validation and `CHANGELOG.md` for pending changes under `Unreleased`; documents other than READMEs may be English-only. Add meaningful tests for behavior that can be verified offline. Keep package allowlists explicit and update version/diagnostic checks together when a version advances.

Keep a copy of the root `LICENSE` in each Mod and include it in `build.py`'s allowlist. Bundled documentation may use relative links to files in the same Mod, such as `CHANGELOG.md` or `LICENSE`. For root documentation, shared guides or another Mod, use a full GitHub URL for the matching branch or tag, such as [the development branch's support guide](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md). A `../docs/` or `../SUPPORT.md` link does not resolve inside an extracted individual ZIP.

Read the game language at runtime and reuse native text before adding original translations; see [localization](docs/localization.md#english). Keep each Mod self-contained. The folder convention follows Old Market Simulator Mods, but its Unity/C# interfaces, loaders and SDK are not applicable to this Unreal game. Verify engine types and calls against local references; do not invent signatures or describe extracted assets as recovered original C++ source.

Follow [.editorconfig](.editorconfig) for encoding, indentation and line endings, and [.gitattributes](.gitattributes) for Git's text normalization.

### Commits, CI and branch protection

Use the current working directory without creating temporary worktrees. The current development branch is `dev`; use it, an existing `development` branch, or a feature branch, and merge to protected `main` through a PR. A PR from `development` targets `main`. Do not bypass branch protection. Commit and push task-related changes at the end of each task unless explicitly told not to; preserve unrelated user changes.

Selectively stage intended files, run `python tools/check_repository.py`, review `git diff --staged`, and check `git diff --check` and `git status --short` before committing. The repository checker examines tracked and staged paths, so stage new intended files before the final check. A clean worktree does not require deleting ignored `work/` or `outputs/`.

The `.github/workflows/mods.yml` workflow runs on pushes to `main`, `dev` and `development`, PRs targeting `main`, and manual dispatch:

- **Script, data and workflow syntax:** repository boundaries, Python/JSON syntax, whitespace and actionlint. The actionlint download uses a pinned version and SHA-256.
- **Lua tests and packages:** version and CHANGELOG checks, diagnostic version and package allowlists, packaging tests, all Mod behavior tests, ZIP contents and checksums, followed by a read-only release preflight.
- The **mod-packages** artifact contains the registered Mods' current ZIPs, their checksum files and commit-tagged `build-info.json`, retained for 14 days. Actions are pinned to commit SHAs and default to read-only repository access.
- A successful **main push** can run the release job for explicitly authorized new numbered versions. Only that job receives `contents: write`; development versions do not become releases automatically. See [release management](releases/README.md#english).

`.github/main-ruleset.json` describes the intended GitHub ruleset: PR required, branch up to date with `main`, both required checks passing, no force-push/delete or bypass, and zero required approving reviewers. Editing the JSON does not apply remote settings. Maintainers must explicitly apply and read back repository rules through the API; CI has no repository administration credentials. The repository is public.

## 中文

先阅读[参与贡献](CONTRIBUTING.md#中文)了解改动流程，再通过[文档索引](docs/README.md#中文)查找玩家说明、实现说明与测试记录。安装和玩法问题请查看[帮助](SUPPORT.md#中文)。

### 开发环境

- 安装 Git、Python 3.12 和 uv，确保 PowerShell 能调用 `git`、`python` 和 `uv`。CI 使用 Python 3.12 和 uv 0.10.7；执行下方命令前先核对 `python --version` 与 `uv --version`。
- 全量构建 7 个 Mod 需要 Windows x64，以及 Visual Studio 或 Build Tools 中的 C++ x64 工具和 Windows SDK。Smart Delivery 的原生测试还使用 x64 MASM 汇编器（`ml64`）；Auto Menu 的辅助模块和原生测试使用 C++ 编译器。
- 原生构建脚本通过 `vswhere` 查找 C++ 工具，再自行初始化 `VsDevCmd.bat` 环境，可在仓库根目录使用普通 PowerShell 执行。纯 Lua Mod 不需要原生编译器。
- 离线测试与打包不需要安装游戏、UE4SS、提取 SDK 或准备本机游戏参考。Lua 测试通过 uv 获取固定的 `lupa==2.6` 依赖，首次运行可能需要下载。实际游戏测试才需要各 Mod 玩家说明中指定的游戏与加载器。

首次获取仓库时，克隆公开仓库：

```powershell
git clone --branch dev https://github.com/martin-lzh/parisian-bistro-simulator-mods.git
cd parisian-bistro-simulator-mods
```

已有本地仓库时，直接使用该目录，修改前先检查 `git status --short`。不要为本次任务另行克隆或创建临时工作树。阅读 [AGENTS.md](AGENTS.md) 后执行下方检查，不需要从其他电脑复制生成产物。

### 各 Mod 开发说明

| Mod | 实现与验证 |
| --- | --- |
| Bartender's Note（调饮手记） | [开发说明](bartenders-note-mod/DEVELOPMENT.md#中文) |
| Auto Checkout（收银管家） | [开发说明](auto-checkout-mod/DEVELOPMENT.md#中文) |
| Fresh to Serve（焕鲜上桌） | [开发说明](fresh-to-serve-mod/DEVELOPMENT.md#中文) |
| First to Serve（出餐有序） | [开发说明](first-to-serve-mod/DEVELOPMENT.md#中文) |
| Smart Delivery（配送随心） | [开发说明](smart-delivery-mod/DEVELOPMENT.md#中文) |
| Auto Menu（菜单巧配） | [开发说明](auto-menu-mod/DEVELOPMENT.md#中文) |
| Scan to Order（扫码点餐） | [开发说明](scan-to-order-mod/DEVELOPMENT.md#中文) |

通用要求及既有测试另见[多语言适配](docs/localization.md#中文)、[验收记录](releases/validation.md#中文)和[版本管理](releases/README.md#中文)。

### 目录与内容边界

| 路径 | 用途 | Git 跟踪 |
| --- | --- | --- |
| `<feature>-mod/` | 独立原创 Mod 源码、构建入口和文档 | 是 |
| `docs/` | 原创设计、兼容性与文档索引 | 是 |
| `tools/` | 原创构建、打包与仓库检查脚本 | 是 |
| `releases/` | 版本、授权与验收记录 | 是 |
| `LICENSE` | 原创代码和文档的 MIT 许可证 | 是 |
| `work/` | 全部游戏参考、提取资料、分析、日志、工具及研究脚本 | 否 |
| `outputs/` | 本地 ZIP、校验文件与 CI 产物 | 否 |

改动前阅读 [AGENTS.md](AGENTS.md)。本机参考入口是 `work/reference/README.md`，不会随 Git 克隆同步。开发期间游戏安装目录只读；构建不安装 Mod、不改存档，也不启动或关闭游戏。

所有反编译相关内容均放在被忽略的 `work/`，包括游戏文件、资产、映射、蓝图、原生分析、SDK/头文件导出、内存快照、日志、第三方工具、提取脚本和研究笔记。不得复制到跟踪目录或强制加入 Git。安装包只含原创 Mod 文件和必要声明。

各 Mod 独立维护运行时和构建输入：

| Mod 内路径 | 用途 |
| --- | --- |
| `Scripts/` | Lua 入口及运行时模块 |
| `tests/run.py` 与 `tests/` | Lua 行为测试及运行入口 |
| `build.py` | 版本、固定包白名单及 ZIP／校验文件生成 |
| `Native/` 与 `native_build.py` | 原创辅助模块源码及原生测试，仅 Smart Delivery 和 Auto Menu 使用 |
| `README.md` | 面向玩家的安装与使用说明 |
| `assets/` | 文档用实机测试图与宣传图，不进入 Mod ZIP |
| `DEVELOPMENT.md` | 实现细节及验收清单 |
| `CHANGELOG.md` | 待发布改动及版本历史 |
| `LICENSE` | 与根目录一致的完整 MIT 许可 |

### Mod 图片

每个 Mod 的 `assets/README.md` 提供命名与引用示例。沿用菜市场模拟器 Mods 的约定：`assets/cover.png` 存放封面，`assets/<scene>-gameplay.png` 存放真实实机图，`assets/<scene>-promo.png` 存放其他宣传图。测试图附上测试环境与结果，宣传图与实机证据明确区分。实际加入图片后再启用引用；在此之前，目录说明文件使图片目录也能随 Git 同步。

仅供仓库阅读的文档可以使用相对路径。玩家 README 同时进入 Mod ZIP，而 `assets/` 不打包，因此其中展示图片时使用带 `?raw=1` 的完整 GitHub 图片地址。使用包含该图片的分支或标签，公开图片无需仓库访问权限。实际添加图片后，可按以下示例引用：

```markdown
![调饮手记宣传封面](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/bartenders-note-mod/assets/cover.png?raw=1)
```

社交平台专用导出、草稿及打包文件存放在被忽略的 `outputs/<mod>/promo/`；提取资源和反编译资料继续留在 `work/`。

### 构建与检查

离线构建使用 Python 和 uv，`lupa==2.6` 提供 Lua 5.4 行为测试环境。CI 固定 Python 3.12 和 uv 0.10.7，不需要游戏、UE4SS 或本机参考资料。

Smart Delivery 和 Auto Menu 还使用 MSVC 和 Windows SDK 构建原创 Windows x64 辅助模块，并执行原生测试；Smart Delivery 的测试还使用 MASM。生成的 DLL 使用固定白名单，不跟踪二进制文件。CI 在绑定提交的构建证据中记录各辅助模块哈希，用于安装包及发布校验。

在仓库根目录执行：

```powershell
python tools/check_repository.py
python tools/check_syntax.py
python -m unittest discover -s tools/tests -v
python tools/ci.py build
git diff --check
```

`tools/ci.py build` 运行所有已登记 Mod 的测试，调用各自独立的 `build.py` 打包，再检查文件清单、源码字节和 SHA-256。每个 ZIP 均包含完整 `LICENSE`，配置验证要求各 Mod 许可与根 MIT 许可一致。新增且准备入包的文件须先暂存再验证，白名单仅接受 Git 已跟踪文件。各 Mod 也可按自己的开发说明单独测试和构建。组合构建前，`outputs/ci/` 应为空或只含当前版本；升级版本后先移走旧产物。

这些检查验证离线行为与包完整性，不代表渲染、真实引擎桥接或实机验收通过。[验收记录](releases/validation.md#中文)区分本机开发参考基线与用户实际反馈的测试环境。

### 新增与维护 Mod

有实际功能要实现时才创建独立 `<feature>-mod/`。所有 README 均须中英双语，包括玩家说明、图片目录说明和文档索引。`DEVELOPMENT.md` 记录实现与验收，`CHANGELOG.md` 将待发布内容放在 `Unreleased`；README 以外的文档可以仅使用英语。仅为适合离线验证的行为添加有意义的测试。打包使用固定白名单；推进版本时同步更新版本与诊断检查。

每个 Mod 保存根 `LICENSE` 的副本，并纳入 `build.py` 白名单。随包文档链接同一 Mod 内文件时，可以使用 `CHANGELOG.md`、`LICENSE` 等相对路径；链接根文档、公共说明或其他 Mod 时，应使用对应分支或标签的完整 GitHub URL，例如[开发分支帮助说明](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md)。单个 ZIP 解压后，`../docs/` 或 `../SUPPORT.md` 之类链接无法找到仓库内目标。

运行时读取游戏语言，优先复用原生文案，再补充原创翻译，详见[多语言适配](docs/localization.md#中文)。各 Mod 保持独立。目录组织参考菜市场模拟器，但该项目的 Unity/C# 接口、加载器及 SDK 不适用于本 Unreal 游戏。类型和调用须经本机参考核对，不编造签名，也不把资源提取称为恢复原始 C++ 源码。

编码、缩进和换行遵循 [.editorconfig](.editorconfig)，Git 文本归一化遵循 [.gitattributes](.gitattributes)。

### 提交、CI 与分支保护

直接使用当前工作目录，不创建临时工作树。当前开发分支为 `dev`，可使用该分支、已有的 `development` 分支或功能分支，通过 PR 合入受保护的 `main`；从 `development` 开 PR 时，目标为 `main`。不得绕过保护。每次任务结束提交并推送任务相关改动，除非用户明确要求不推送；保留无关用户改动。

选择性暂存目标文件，执行 `python tools/check_repository.py`，审查 `git diff --staged`，并在提交前检查 `git diff --check` 和 `git status --short`。仓库检查器审查已跟踪及暂存路径，因此新增目标文件应先暂存再做最终检查。干净的 Git 工作区不代表删除被忽略的 `work/` 或 `outputs/`。

`.github/workflows/mods.yml` 在 `main`、`dev`、`development` 推送，目标为 `main` 的 PR，以及手动运行时执行：

- **Script, data and workflow syntax：**检查仓库边界、Python/JSON 语法、空白和 actionlint。actionlint 下载固定版本并校验 SHA-256。
- **Lua tests and packages：**核对版本与 CHANGELOG、诊断版本与打包白名单，运行包检查器测试、全部 Mod 行为测试及 ZIP 内容和哈希检查，然后只读预检发布条件。
- **mod-packages** artifact 包含已登记 Mod 的当前 ZIP、各自校验文件，以及记录提交号的 `build-info.json`，保留 14 天。Actions 固定提交 SHA，默认只读仓库。
- **main 推送**通过检查后，可以为已明确授权的新编号版本运行发布任务。仅该任务拥有 `contents: write`；开发版不会自动转为正式版。详见[版本管理](releases/README.md#中文)。

`.github/main-ruleset.json` 记录 GitHub 规则集目标：必须经 PR、分支包含最新 `main`、两个必需检查均通过；禁止强推和删除、无绕过者，要求审批人数为零。修改 JSON 不会自动应用到远端。维护者须通过 API 显式应用并回读核对；CI 不持有仓库管理凭据。仓库已公开。
