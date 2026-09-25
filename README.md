# Parisian Bistro Simulator Mods

[English](#english) · [中文](#中文)

## English

Unofficial Mods for running your Parisian Bistro Simulator restaurant. Choose the features you want; each Mod has its own installation guide, source and version history.

### Choose a Mod

| Mod | What it does | Current source | Last accepted version |
| --- | --- | --- | --- |
| [Bartender's Note](bartenders-note-mod/README.md#english) | Shows your claimed, unfinished drinks below the restaurant name | 0.1.2-dev | 0.1.0 |
| [Auto Checkout](auto-checkout-mod/README.md#english) | Accepts cash or cards at the counter and completes the register interaction | 0.1.4-dev | 0.1.2 |
| [Fresh to Serve](fresh-to-serve-mod/README.md#english) | Clears spoiled meals and drinks, requesting replacements while the original customer still has enough patience | 0.1.2-dev | Pending |
| [First to Serve](first-to-serve-mod/README.md#english) | Hold at the kitchen or drink output area to take the oldest ready items first with a tray or food trolley | 0.1.7-dev | Pending |
| [Smart Delivery](smart-delivery-mod/README.md#english) | Choose free, budget or premium delivery for automatic smart orders | 0.1.4-dev | Pending |
| [Scan to Order](scan-to-order-mod/README.md#english) | Automatically place customer food and drink orders on the host; wait for missing stock and resume after replenishment | 0.1.0-dev | Pending |

Smart Delivery 0.1.2-dev adds native code discovery checked against Steam Build 25532071, without a mandatory executable version or hash allowlist. Version 0.1.3-dev adds white dropdown text. In-game acceptance remains pending.

The current development packages add support for the game's 14 languages. Bartender's Note also has a new two-line layout. These changes still need in-game acceptance; earlier confirmations apply only to the versions recorded in the [validation record](releases/validation.md#english).

### Getting started

The development baseline is **Parisian Bistro Simulator on Windows, Steam Build 25393699 / ProjectVersion 1.0.0.44eb, Unreal Engine 5.4**. These Mods require **UE4SS experimental**. The locally checked API is `v3.0.1-1140-gf58e8f84`; the old stable UE4SS 3.0.1 is not the target loader.

1. Open the Mod's guide above and check its requirements and multiplayer notes.
2. Obtain the Mod ZIP and its checksum from the matching [CI run](https://github.com/martin-lzh/parisian-bistro-simulator-mods/actions/workflows/mods.yml), or build it from source. GitHub's **Source code** archive is not an installable Mod package.
3. Close the game, install the required loader, and place the Mod folder in the loader's `Mods` directory as its guide describes.
4. Start the game and enter your restaurant. Bartender's Note appears after you claim drink orders; Auto Checkout runs automatically in a host session.

Loaders and game files are not included. Builds only create packages; they do not install Mods, change saves, or start or close the game. This repository remains private. Numbered versions and GitHub Release publication are separate; see [release management](releases/README.md#english) for publication conditions.

The current development versions support **Ctrl+R** Lua hot reload after an initial closed-game upgrade and loader configuration. See the [hot reload guide](docs/hot-reload.md#english); DLL updates still require restarting the game.

### Languages and help

Localized Mod wording follows the game's language without a separate language pack. The supported languages are English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese.

Existing game text stays native: drink names come from the game's translation lookup, and checkout keeps the game's payment prompts, notifications and transaction behavior. Only Mod-specific wording needs its own translations. Auto Checkout adds translated explanations to its log while preserving diagnostic identifiers. See the [language guide](docs/localization.md#english).

For a problem report, include the Mod version, full UE4SS version, game build, selected language, host/client role and the relevant log excerpt. Bartender's Note logs use `[Bartender's Note]`; Auto Checkout logs use `[AutoCheckout]`. Review logs before sharing them, and keep game files, extracted data and full saves out of the repository.

### Development

Start with the [documentation index](docs/README.md#english) or [development guide](DEVELOPMENT.md#english). Each `<feature>-mod/` is independent. The structure follows Old Market Simulator Mods; this game's Unreal/UE4SS implementation uses its own verified interfaces.

This project is not affiliated with the game's creators. Game assets and reverse-engineered material stay in the ignored local `work/` directory and are never distributed with the Mods.

## 中文

为法式小馆儿模拟器提供便利的非官方 Mod。可以按需选择，也可以同时使用；每个 Mod 都有独立的安装说明、源码和版本记录。

### 选择 Mod

| Mod | 功能 | 当前源码 | 最近已验收版本 |
| --- | --- | --- | --- |
| [Bartender's Note](bartenders-note-mod/README.md#中文) | 在餐厅名称下显示自己认领且尚未做完的饮料 | 0.1.2-dev | 0.1.0 |
| [Auto Checkout](auto-checkout-mod/README.md#中文) | 自动接收柜台顾客的现金或银行卡，并完成收银机交互 | 0.1.4-dev | 0.1.2 |
| [Fresh to Serve（焕新上桌）](fresh-to-serve-mod/README.md#中文) | 清理低劣食物和饮料；原顾客仍在等待且耐心足够时，请求重做并重新上桌 | 0.1.2-dev | 待验收 |
| [First to Serve（先做好先端）](first-to-serve-mod/README.md#中文) | 持托盘或推餐车，对准出餐口或饮料出品台长按，优先拿取最早制作的成品 | 0.1.7-dev | 待验收 |
| [Smart Delivery（智选配送）](smart-delivery-mod/README.md#中文) | 为自动智能订购选择免费服务、经济型配送或高级配送 | 0.1.4-dev | 待验收 |
| [Scan to Order（扫码点餐）](scan-to-order-mod/README.md#中文) | 仅房主或单人自动提交顾客食物和饮料订单，缺货时等待、补货后继续，无需服务员／玩家点餐 | 0.1.0-dev | 待验收 |

Smart Delivery 0.1.2-dev 已在 Steam Build 25532071 上核对原生代码定位结果，不再使用强制版本或 EXE 哈希白名单；0.1.3-dev 将下拉框文字改为白色，仍待实机验收。

当前开发包新增游戏 14 种语言的适配；Bartender's Note 还包含新的两行布局。这些改动仍待实机验收，之前的确认仅适用于[验收记录](releases/validation.md#中文)中的对应版本。

### 开始使用

开发参考基线为 **Windows 版 Parisian Bistro Simulator，Steam Build 25393699 / ProjectVersion 1.0.0.44eb，Unreal Engine 5.4**。这些 Mod 均需要 **UE4SS experimental**。本机核对的 API 为 `v3.0.1-1140-gf58e8f84`；旧稳定版 UE4SS 3.0.1 不是目标加载器。

1. 打开上方 Mod 说明，查看依赖和联机使用范围。
2. 从对应的 [CI 运行](https://github.com/martin-lzh/parisian-bistro-simulator-mods/actions/workflows/mods.yml)取得 Mod ZIP 和校验文件，或自行构建。GitHub 的 **Source code** 压缩包不是可安装 Mod。
3. 关闭游戏，安装所需加载器，再按各 Mod 说明把文件夹放入加载器的 `Mods` 目录。
4. 启动游戏并进入餐厅。认领饮料订单后可看到 Bartender's Note；Auto Checkout 在房主会话自动运行。

安装包不含加载器或游戏文件。构建只生成安装包，不自动安装、不修改存档，也不启动或关闭游戏。仓库保持私密。编号版本与 GitHub Release 发布是不同步骤，发布条件见[版本管理](releases/README.md#中文)。

当前开发版支持 **Ctrl+R** 热重载 Lua；首次需关闭游戏升级 Mod 并配置加载器。操作见[热重载说明](docs/hot-reload.md#中文)，DLL 更新仍须重启游戏。

### 语言与反馈

Mod 本地化文案跟随游戏语言，无需额外语言包。适配英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。

游戏已有文案优先沿用原生值：饮料名通过游戏翻译接口读取，自动结账保留原生付款提示、通知和交易行为；仅 Mod 新增文案自行翻译。Auto Checkout 在日志中增加本地化说明，并保留诊断标识。详见[语言说明](docs/localization.md#中文)。

反馈问题时请提供 Mod 版本、UE4SS 完整版本号、游戏构建、所选语言、房主或客户端身份及相关日志片段。Bartender's Note 使用 `[Bartender's Note]` 日志前缀，Auto Checkout 使用 `[AutoCheckout]`。分享前检查日志内容，不要将游戏文件、提取数据或完整存档提交到仓库。

### 参与开发

从[文档索引](docs/README.md#中文)或[开发说明](DEVELOPMENT.md#中文)开始。每个 `<feature>-mod/` 独立维护；目录组织参考菜市场模拟器项目，实际实现使用本游戏经核对的 Unreal / UE4SS 接口。

本项目与游戏制作方无隶属关系。游戏资产及反编译资料仅保存在本地被忽略的 `work/` 中，不随 Mod 分发。
