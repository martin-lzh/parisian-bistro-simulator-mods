# 版本记录

当前 Auto Checkout 开发包为 `AutoCheckout-0.1.2-dev.zip`，修复自动交互的玩家距离限制，尚待实机验证。下表保留既有正式版记录，CI 产物按当前源码版本构建。

## 正式版本

| Mod | 版本 | 实机确认日期 | ZIP |
| --- | --- | --- | --- |
| Bartender's Note | 0.1.0 | 2026-09-24 | `BartendersNote-0.1.0.zip` |
| Auto Checkout | 0.1.1 | 2026-09-24 | `AutoCheckout-0.1.1.zip` |

用户已确认两个开发包实机测试成功，并要求转为正式版。确认范围见[验收记录](validation.md)。正式版本号与 GitHub Release 发布是独立步骤；目前安装包可由本地构建或 [CI artifacts](https://github.com/martin-lzh/parisian-bistro-simulator-mods/actions/workflows/mods.yml)取得。

每个 Mod 独立维护版本和 CHANGELOG。发布前明确目标版本、兼容的游戏版本、验证结果和包文件清单；发布包只包含原创 Mod 文件和必要声明。不要自动发布版本或改变仓库可见性。

构建包保存在被忽略的根目录 `outputs/`，此目录只跟踪文字发布记录。

CI 使用两个 Mod 的独立构建入口，运行全部 Lua 离线测试，并核对安装包的固定白名单、逐文件内容与 SHA-256。`mod-packages` artifact 只包含当前两个 ZIP、对应的 `.zip.sha256` 及 `build-info.json`（源码提交、版本和附件哈希），保留 14 天。GitHub 的源码下载不等于可安装 Mod 包。

后续版本在开发期间保留 `Unreleased`，只有维护者要求升级时才更新编号、诊断标识和说明；不能把 CI 成功当作新版本实机验收。两个 Mod 独立推进版本，仓库持续保持私密。
