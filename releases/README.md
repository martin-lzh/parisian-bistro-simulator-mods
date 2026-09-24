# 版本记录

## 正式版本

| Mod | 版本 | 实机确认日期 | ZIP |
| --- | --- | --- | --- |
| Bartender's Note | 0.1.0 | 2026-09-24 | `BartendersNote-0.1.0.zip` |
| Auto Checkout | 0.1.1 | 2026-09-24 | `AutoCheckout-0.1.1.zip` |

用户已确认两个开发包实机测试成功，并要求转为正式版。确认范围见[验收记录](validation.md)。正式版本号与 GitHub Release 发布是独立步骤；目前安装包可由本地构建或 [CI artifacts](https://github.com/martin-lzh/parisian-bistro-simulator-mods/actions/workflows/mods.yml)取得。

每个 Mod 独立维护版本和 CHANGELOG。发布前明确目标版本、兼容的游戏版本、验证结果和包文件清单；发布包只包含原创 Mod 文件和必要声明。自动工作流只发布具有[源码绑定授权记录](approvals/README.md)的新版本，仓库可见性保持私密。

构建包保存在被忽略的根目录 `outputs/`，此目录只跟踪文字发布记录。

CI 使用两个 Mod 的独立构建入口，运行全部 Lua 离线测试，并核对安装包的固定白名单、逐文件内容与 SHA-256。`mod-packages` artifact 只包含当前两个 ZIP、对应的 `.zip.sha256` 及 `build-info.json`（源码提交、版本和附件哈希），保留 14 天。GitHub 的源码下载不等于可安装 Mod 包。

后续版本在开发期间保留 `Unreleased`，只有维护者要求升级时才更新编号、诊断标识和说明；不能把 CI 成功当作新版本实机验收。两个 Mod 独立推进版本，仓库持续保持私密。

## GitHub Release 工作流

工作流 `.github/workflows/mods.yml` 包含 `Publish new CHANGELOG versions` 任务。只有 `main` 的 push，且语法检查与 Lua 测试打包均成功后才执行。PR、`dev`、`development` 和手动运行只检查、打包与预检，不发布；无需个人访问令牌，只有发布任务授予 `GITHUB_TOKEN` 的 `contents: write`。

| Mod | 独立标签 |
| --- | --- |
| Bartender's Note | `bartenders-note-v<版本>` |
| Auto Checkout | `auto-checkout-v<版本>` |

发布流程与菜市场项目一致：

1. 只读预检结合 GitHub 已有 Release 筛选当前版本。跳过 `-dev`、缺少授权记录和已发布的版本；有记录但已失效则报错。要求当前编号为 CHANGELOG 的首个正式编号条目且有说明，Unreleased 内容为空。
2. 对比该 Mod 最高已发布编号版本的标签与当前提交。Mod 目录没有净变化时跳过，拒绝新版本倒退；首次发布必须有已跟踪的 Mod 文件。所有构建/发布检查取得完整 Git 历史及标签。
3. 下载同一次工作流的 `mod-packages`，核对来源提交、版本、完整文件清单、哈希及 ZIP 中每个文件的源码内容；不重新构建替换已验证的 ZIP。
4. 在当前准确提交创建草稿，附上编号 CHANGELOG 与安装说明链接。上传该 Mod 的 ZIP、`SHA256SUMS.txt` 和 `build-info.json`（提交、版本、源码摘要和 ZIP 哈希）。逐个从 GitHub 下载附件并比较原始字节，再完成发布并核对标签指向。
5. 已发布的 Release 和标签不变。上传中断可重跑原 main-push 工作流；只有来源提交、说明、预发布状态和已有附件字节都一致的草稿才可续传。冲突或损坏会保留草稿并失败，不自动删除或覆盖。

新增工作流本身不补建历史版本的 Release，也不把开发包自动升级为正式版。后续按维护者已给出的版本发布指令记录授权，流程即会在合入 `main` 后执行。

只读检查命令：

```powershell
python tools/release.py check --repository martin-lzh/parisian-bistro-simulator-mods
```

该命令使用环境变量 `GH_TOKEN` 读取私密仓库，工作区须已提交。模拟 GitHub 的离线回归测试覆盖创建、续传、跳过、损坏和冲突，不将这些测试称为真实 Release 发布验收。
