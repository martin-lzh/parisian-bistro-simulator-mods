# Release records / 版本记录

[English](#english) · [中文](#中文)

## English

### Accepted versions and current source

On 2026-09-26, the maintainer confirmed that all seven current Mods passed in-game and multiplayer testing and explicitly authorized removing the development suffix and publishing stable Releases. The [validation record](validation.md#english) ties this acceptance to source `4c51f21a1fd9acb05e6b4a9da6ffa9ddea8706a1`. Current source and approved stable package versions are:

| Mod | Stable version | In-game and multiplayer confirmation | Package |
| --- | --- | --- | --- |
| Bartender's Note | 0.1.2 | 2026-09-26 | [`BartendersNote-0.1.2.zip`](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/bartenders-note-v0.1.2) |
| Auto Checkout | 0.1.4 | 2026-09-26 | [`AutoCheckout-0.1.4.zip`](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-checkout-v0.1.4) |
| Fresh to Serve | 0.1.2 | 2026-09-26 | [`FreshToServe-0.1.2.zip`](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/fresh-to-serve-v0.1.2) |
| First to Serve | 0.1.7 | 2026-09-26 | [`FirstToServe-0.1.7.zip`](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/first-to-serve-v0.1.7) |
| Smart Delivery | 0.1.5 | 2026-09-26 | [`SmartDelivery-0.1.5.zip`](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/smart-delivery-v0.1.5) |
| Auto Menu | 0.5.0 | 2026-09-26 | [`AutoMenu-0.5.0.zip`](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-menu-v0.5.0) |
| Scan to Order | 0.1.1 | 2026-09-26 | [`ScanToOrder-0.1.1.zip`](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/scan-to-order-v0.1.1) |

The historical Bartender's Note 0.1.0 and Auto Checkout 0.1.1/0.1.2 acceptance records remain in the validation history. Current builds use the stable versions above; building current source does not reproduce those historical packages.

The maintainer separately authorized a [gameplay-guide update](documentation-refresh-2026-09-26.md#english) for these seven existing Releases. That update replaces only the ZIP documentation and associated checksums/build records; runtime files, versions and tag targets remain unchanged. The normal workflow below still skips published versions.

Each Mod maintains its own version and CHANGELOG. Before a release, specify the target version, compatible game version, validation results and package contents. Packages contain only original Mod files and required notices. Automatic publication requires a [source-bound authorization record](approvals/README.md#english); the repository remains private. Build output stays in the ignored root `outputs/` directory; this directory tracks release records only.

CI runs all seven independent build entry points and all Lua offline tests, then checks package allowlists, every file's source content and SHA-256. The `mod-packages` artifact contains the seven current ZIPs, their `.zip.sha256` files and `build-info.json` with the source commit, versions and attachment hashes. Artifacts are retained for 14 days. GitHub source downloads are not installable Mod packages.

Keep development changes under `Unreleased`; update numbered versions, diagnostic identifiers and documentation when requested by the maintainer. CI success is not in-game acceptance. Versions advance independently for each Mod.

### GitHub Release workflow

The `Publish new CHANGELOG versions` job in `.github/workflows/mods.yml` runs only for a push to `main`, after syntax checks and Lua tests/package checks pass. PRs, `dev`, `development` and manual runs only check, build and preflight; they do not publish. No personal access token is required. Only the publishing job grants `GITHUB_TOKEN` the `contents: write` permission.

| Mod | Independent tag |
| --- | --- |
| Bartender's Note | `bartenders-note-v<version>` |
| Auto Checkout | `auto-checkout-v<version>` |
| Fresh to Serve | `fresh-to-serve-v<version>` |
| First to Serve | `first-to-serve-v<version>` |
| Smart Delivery | `smart-delivery-v<version>` |
| Auto Menu | `auto-menu-v<version>` |
| Scan to Order | `scan-to-order-v<version>` |

Following the Old Market Simulator project:

1. Read-only preflight checks the current version against existing GitHub Releases. It skips `-dev`, versions without authorization records and already published versions; an invalid existing authorization record fails the check. The version must be the first numbered stable CHANGELOG entry, include release notes, and leave `Unreleased` empty.
2. Compare the highest published numbered version's tag with the current commit for that Mod. Skip when its directory has no net changes and reject version regressions. A first release must contain tracked Mod files. Build and release checks fetch full Git history and tags.
3. Download `mod-packages` from the same workflow run. Verify its source commit, versions, complete file list, hashes and every ZIP file against the source. Do not rebuild or replace the verified ZIP.
4. Create a draft at the exact current commit with the numbered CHANGELOG notes and installation link. Upload that Mod's ZIP, `SHA256SUMS.txt` and `build-info.json` containing the commit, version, source digest and ZIP hash. Download each attachment from GitHub and compare the original bytes, then publish and verify the tag target.
5. Published Releases and tags remain unchanged. After an interrupted upload, rerun the original main-push workflow. A draft resumes only if its source commit, body, prerelease status and existing attachment bytes all match. Conflicts or corruption preserve the draft and fail; nothing is automatically deleted or overwritten.

Adding the workflow does not backfill historical Releases or promote development packages. Record authorization only from an actual maintainer instruction to release the specified version; the workflow can then publish after merging into `main`.

Read-only check:

```powershell
python tools/release.py check --repository martin-lzh/parisian-bistro-simulator-mods
```

This command reads the private repository using `GH_TOKEN` and requires a committed working tree. Offline tests simulate GitHub creation, resumption, skipping, corruption and conflicts; these are not acceptance tests of a real Release publication.

## 中文

### 已验收版本与当前源码

2026-09-26，维护者确认全部 7 个当前 Mod 实机及联机测试通过，明确要求去掉开发版后缀并发布正式 Release。[验收记录](validation.md#中文)将本次确认关联源码 `4c51f21a1fd9acb05e6b4a9da6ffa9ddea8706a1`。当前源码与获准正式包版本如下：

| Mod | 正式版本 | 实机与联机确认日期 | 安装包 |
| --- | --- | --- | --- |
| Bartender's Note（调饮手记） | 0.1.2 | 2026-09-26 | [`BartendersNote-0.1.2.zip`](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/bartenders-note-v0.1.2) |
| Auto Checkout（收银管家） | 0.1.4 | 2026-09-26 | [`AutoCheckout-0.1.4.zip`](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-checkout-v0.1.4) |
| Fresh to Serve（焕鲜上桌） | 0.1.2 | 2026-09-26 | [`FreshToServe-0.1.2.zip`](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/fresh-to-serve-v0.1.2) |
| First to Serve（出餐有序） | 0.1.7 | 2026-09-26 | [`FirstToServe-0.1.7.zip`](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/first-to-serve-v0.1.7) |
| Smart Delivery（配送随心） | 0.1.5 | 2026-09-26 | [`SmartDelivery-0.1.5.zip`](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/smart-delivery-v0.1.5) |
| Auto Menu（菜单巧配） | 0.5.0 | 2026-09-26 | [`AutoMenu-0.5.0.zip`](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-menu-v0.5.0) |
| Scan to Order（扫码点餐） | 0.1.1 | 2026-09-26 | [`ScanToOrder-0.1.1.zip`](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/scan-to-order-v0.1.1) |

调饮手记 0.1.0、收银管家 0.1.1／0.1.2 的历史验收仍保留在验收记录中。当前构建使用上表正式版本，不会重新生成历史版本安装包。

维护者另行授权对这 7 个现有 Release 进行[游戏操作说明更新](documentation-refresh-2026-09-26.md#中文)，仅替换 ZIP 内文档及对应校验／构建记录；运行文件、版本及标签指向不变。下述常规工作流仍跳过已发布版本。

每个 Mod 独立维护版本和 CHANGELOG。发布前明确目标版本、兼容的游戏版本、验证结果和包文件清单。包内只包含原创 Mod 文件和必要声明。自动发布必须具有[绑定源码的授权记录](approvals/README.md#中文)，仓库保持私密。构建包保存在被忽略的根目录 `outputs/`；本目录只跟踪文字发布记录。

CI 使用全部 7 个 Mod 的独立构建入口，运行全部 Lua 离线测试，并核对包白名单、逐文件源码内容与 SHA-256。`mod-packages` artifact 包含当前 7 个 ZIP、对应的 `.zip.sha256` 及 `build-info.json`（源码提交、版本和附件哈希），保留 14 天。GitHub 源码下载不等于可安装 Mod 包。

开发期间将改动记录在 `Unreleased`，按维护者要求更新编号、诊断标识和说明。不能把 CI 成功当作游戏内验收；每个 Mod 独立推进版本。

### GitHub Release 工作流

`.github/workflows/mods.yml` 的 `Publish new CHANGELOG versions` 任务只在 `main` push 且语法检查、Lua 测试与打包检查成功后执行。PR、`dev`、`development` 和手动运行只检查、打包与预检，不发布。无需个人访问令牌；只有发布任务授予 `GITHUB_TOKEN` 的 `contents: write` 权限。

| Mod | 独立标签 |
| --- | --- |
| Bartender's Note（调饮手记） | `bartenders-note-v<版本>` |
| Auto Checkout（收银管家） | `auto-checkout-v<版本>` |
| Fresh to Serve（焕鲜上桌） | `fresh-to-serve-v<版本>` |
| First to Serve（出餐有序） | `first-to-serve-v<版本>` |
| Smart Delivery（配送随心） | `smart-delivery-v<版本>` |
| Auto Menu（菜单巧配） | `auto-menu-v<版本>` |
| Scan to Order（扫码点餐） | `scan-to-order-v<版本>` |

发布流程沿用菜市场模拟器项目：

1. 只读预检结合 GitHub 已有 Release 筛选当前版本。跳过 `-dev`、缺少授权记录和已发布版本；已有记录失效则报错。当前编号必须为 CHANGELOG 的首个正式编号条目且有说明，`Unreleased` 内容为空。
2. 对比该 Mod 最高已发布编号版本的标签与当前提交。Mod 目录没有净变化时跳过，拒绝版本倒退；首次发布必须有已跟踪的 Mod 文件。所有构建和发布检查获取完整 Git 历史及标签。
3. 下载同一次工作流的 `mod-packages`，核对来源提交、版本、完整文件清单、哈希及 ZIP 中每个文件的源码内容；不重新构建或替换已验证的 ZIP。
4. 在当前准确提交创建草稿，附上编号 CHANGELOG 及安装说明链接。上传该 Mod 的 ZIP、`SHA256SUMS.txt` 和 `build-info.json`（提交、版本、源码摘要和 ZIP 哈希）。逐个从 GitHub 下载附件并比较原始字节，再完成发布并核对标签指向。
5. 已发布的 Release 和标签保持不变。上传中断可重跑原 main-push 工作流；只有来源提交、说明、预发布状态和已有附件字节都一致的草稿才可续传。冲突或损坏会保留草稿并失败，不自动删除或覆盖。

新增工作流本身不补建历史 Release，也不将开发包自动升级为正式版。只有维护者实际要求发布指定版本后才记录授权，工作流随后可在合入 `main` 后发布。

只读检查命令：

```powershell
python tools/release.py check --repository martin-lzh/parisian-bistro-simulator-mods
```

命令通过 `GH_TOKEN` 读取私密仓库，工作区须已提交。离线测试模拟 GitHub 的创建、续传、跳过、损坏和冲突，不代表真实 Release 发布验收。
