# Release records / 版本记录

[English](#english) · [中文](#中文)

## English

### Accepted versions and current source

| Mod | Latest accepted stable version | In-game confirmation | Stable package name | Current source |
| --- | --- | --- | --- | --- |
| Bartender's Note | 0.1.0 | 2026-09-24 | `BartendersNote-0.1.0.zip` | 0.1.1-dev |
| Auto Checkout | 0.1.2 | 2026-09-24 | `AutoCheckout-0.1.2.zip` | 0.1.3-dev |

The user confirmed the tested development packages and requested their conversion to stable versions. Auto Checkout 0.1.2 was confirmed with three cash and two card transactions, all completed on the first attempt, including checkout beyond the original interaction range. The [validation record](validation.md#english) defines the actual scope. The current development versions add localization and still require in-game verification; they do not replace those historical acceptance records.

Stable version numbering and GitHub Release publication are separate steps. [CI artifacts](https://github.com/martin-lzh/parisian-bistro-simulator-mods/actions/workflows/mods.yml) and local builds use the versions in the checked-out source, currently the development versions above. To obtain a historical stable package, build its corresponding source revision or use a published attachment for that version when available; building current source does not reproduce a historical stable package.

Each Mod maintains its own version and CHANGELOG. Before a release, specify the target version, compatible game version, validation results and package contents. Packages contain only original Mod files and required notices. Automatic publication requires a [source-bound authorization record](approvals/README.md#english); the repository remains private. Build output stays in the ignored root `outputs/` directory; this directory tracks release records only.

CI runs both independent build entry points and all Lua offline tests, then checks package allowlists, every file's source content and SHA-256. The `mod-packages` artifact contains the two current ZIPs, their `.zip.sha256` files and `build-info.json` with the source commit, versions and attachment hashes. Artifacts are retained for 14 days. GitHub source downloads are not installable Mod packages.

Keep development changes under `Unreleased`; update numbered versions, diagnostic identifiers and documentation when requested by the maintainer. CI success is not in-game acceptance. Versions advance independently for each Mod.

### GitHub Release workflow

The `Publish new CHANGELOG versions` job in `.github/workflows/mods.yml` runs only for a push to `main`, after syntax checks and Lua tests/package checks pass. PRs, `dev`, `development` and manual runs only check, build and preflight; they do not publish. No personal access token is required. Only the publishing job grants `GITHUB_TOKEN` the `contents: write` permission.

| Mod | Independent tag |
| --- | --- |
| Bartender's Note | `bartenders-note-v<version>` |
| Auto Checkout | `auto-checkout-v<version>` |

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

| Mod | 最新已验收正式版 | 实机确认日期 | 正式包名称 | 当前源码 |
| --- | --- | --- | --- | --- |
| Bartender's Note | 0.1.0 | 2026-09-24 | `BartendersNote-0.1.0.zip` | 0.1.1-dev |
| Auto Checkout | 0.1.2 | 2026-09-24 | `AutoCheckout-0.1.2.zip` | 0.1.3-dev |

用户已确认相应开发包实机测试成功，并要求转为正式版。Auto Checkout 0.1.2 的反馈为三笔现金和两笔刷卡全部首次尝试完成，包含超过原交互范围的结账；实际确认范围见[验收记录](validation.md#中文)。当前开发版本新增多语言适配，仍待游戏内验证，不替代这些历史验收记录。

正式版本号与 GitHub Release 发布是独立步骤。[CI artifacts](https://github.com/martin-lzh/parisian-bistro-simulator-mods/actions/workflows/mods.yml) 和本地构建均使用所检出源码的版本，目前为上表中的开发版。获取历史正式包应检出对应源码修订后构建；若该版本已有 Release 附件，也可直接下载。构建当前源码不会生成历史正式包。

每个 Mod 独立维护版本和 CHANGELOG。发布前明确目标版本、兼容的游戏版本、验证结果和包文件清单。包内只包含原创 Mod 文件和必要声明。自动发布必须具有[绑定源码的授权记录](approvals/README.md#中文)，仓库保持私密。构建包保存在被忽略的根目录 `outputs/`；本目录只跟踪文字发布记录。

CI 使用两个 Mod 的独立构建入口，运行全部 Lua 离线测试，并核对包白名单、逐文件源码内容与 SHA-256。`mod-packages` artifact 包含当前两个 ZIP、对应的 `.zip.sha256` 及 `build-info.json`（源码提交、版本和附件哈希），保留 14 天。GitHub 源码下载不等于可安装 Mod 包。

开发期间将改动记录在 `Unreleased`，按维护者要求更新编号、诊断标识和说明。不能把 CI 成功当作游戏内验收；两个 Mod 独立推进版本。

### GitHub Release 工作流

`.github/workflows/mods.yml` 的 `Publish new CHANGELOG versions` 任务只在 `main` push 且语法检查、Lua 测试与打包检查成功后执行。PR、`dev`、`development` 和手动运行只检查、打包与预检，不发布。无需个人访问令牌；只有发布任务授予 `GITHUB_TOKEN` 的 `contents: write` 权限。

| Mod | 独立标签 |
| --- | --- |
| Bartender's Note | `bartenders-note-v<版本>` |
| Auto Checkout | `auto-checkout-v<版本>` |

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
