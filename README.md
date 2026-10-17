# Parisian Bistro Simulator Mods

![LZH's MODS — Parisian Bistro Simulator; AI-generated cover / AI 宣传封面](assets/cover.png)

<p align="center">
  <strong>Drink notes, service automation and restaurant planning.<br>调饮手记、出餐收银与餐厅经营。</strong>
</p>

<p align="center">
  <strong>Windows</strong> · <strong>7 Mods</strong> · <a href="LICENSE">MIT License</a>
</p>

<p align="center">
  <a href="#english">English</a> · <a href="#中文">中文</a> ·
  <a href="https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases">GitHub Releases</a> ·
  <a href="https://www.nexusmods.com/profile/LZHSimulators">Nexus author / 作者页</a> ·
  <a href="SUPPORT.md">Help / 帮助</a>
</p>

## English

**LZH’s MODS** are seven independent quality-of-life Mods for **Parisian Bistro Simulator** on Windows. Keep track of drinks, serve orders in sequence and automate routine restaurant tasks. Pick the ones you want; each has its own guide.

All seven support the game up to **1.0.2.44eb (Steam Build 25822788)**.

### Choose a Mod

| Mod | What it does | GitHub download | Nexus |
| --- | --- | --- | --- |
| [Bartender's Note](bartenders-note-mod/README.md#english) | Shows your claimed, unfinished drinks below the restaurant name | [0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/bartenders-note-v0.1.2) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/1) |
| [Auto Checkout](auto-checkout-mod/README.md#english) | Accepts cash or cards and completes checkout automatically | [0.1.4](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-checkout-v0.1.4) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/2) |
| [Fresh to Serve](fresh-to-serve-mod/README.md#english) | Clears spoiled meals and drinks and requests replacements when the customer can still wait | [0.1.3](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/fresh-to-serve-v0.1.3) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/3) |
| [First to Serve](first-to-serve-mod/README.md#english) | Hold at a kitchen pass or drink output area to collect the oldest ready items with a tray or food trolley | [0.1.7](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/first-to-serve-v0.1.7) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/6) |
| [Smart Delivery](smart-delivery-mod/README.md#english) | Choose free, budget or premium delivery for automatic smart orders | [0.1.5](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/smart-delivery-v0.1.5) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/4) |
| [Auto Menu](auto-menu-mod/README.md#english) | Choose a lunch or dinner menu with the highest estimated selection rate | [0.5.0](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-menu-v0.5.0) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/5) |
| [Scan to Order](scan-to-order-mod/README.md#english) | Takes customer orders automatically, waits for missing stock and continues after replenishment | [0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/scan-to-order-v0.1.2) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/7) |

Some Mods only need to be installed by the multiplayer host, others by each player who wants the feature — see each guide.

**Want all seven at once?** Install the [Nexus collection](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz) with Vortex (one-click install requires Nexus Premium). Set up the [Vortex game extension](https://www.nexusmods.com/site/mods/2421) and UE4SS first, following the [Vortex guide](vortex-extension/README.md#english). Without Premium, download the Mods individually and install them as below.

### Manual download and installation

Manual installation is free and needs neither Vortex nor Nexus Premium — a browser and File Explorer are enough.

UE4SS is the **mod loader** that runs Mods when the game starts. Install it once, then add any of the seven Mods to its `Mods` folder.

#### Install the loader once

1. **Close the game.** In Steam, open **Library**, right-click **Parisian Bistro Simulator** → **Manage → Browse local files**. This opens the game folder (it may be named **Parisian Brasserie Simulator**).
2. **Open BrasserieSimulator → Binaries → Win64.** You should see **BrasserieSimulator-Win64-Shipping.exe** (Windows may hide the `.exe`). Keep this window open; the loader goes here.
3. **Download UE4SS:** [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip). If the link doesn't open, find that exact file under **Assets** on the [UE4SS experimental release page](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental). Don't use `zDEV`, `Source code` or the old stable `UE4SS_v3.0.1.zip`.
4. **Copy the loader into Win64.** Right-click the ZIP → **Extract All… → Extract**. From the extracted folder, copy **dwmapi.dll** and the **ue4ss** folder and paste both into **Win64**. If you are replacing an existing UE4SS, back up its folder first.
5. **Check the loader:** `dwmapi.dll` sits next to `BrasserieSimulator-Win64-Shipping.exe`, and the **ue4ss** folder contains **UE4SS.dll**, **UE4SS-settings.ini** and **Mods**.

#### Add the Mods you want

1. **Download** a Mod from the table above. **GitHub** (no account): open its version link and download the ZIP named after the Mod under **Assets** — not **Source code**. **Nexus**: open **Files → Main files → Manual download**, then choose **Slow download** if you have a free account.
2. **Extract the Mod ZIP** (right-click → **Extract All… → Extract**) and open it until you see the Mod's folder from the table below. It contains `Scripts` and `enabled.txt`.
3. **Copy that whole folder** into **Win64 → ue4ss → Mods**. Keep every file in it, including the DLLs in Auto Menu and Smart Delivery, and `enabled.txt` even if it is empty.
4. **Start the game through Steam** and follow each Mod's **How to use** guide.

| Mod | Folder to copy into `Mods` |
| --- | --- |
| Bartender's Note | `BartendersNote` |
| Auto Checkout | `AutoCheckout` |
| Fresh to Serve | `FreshToServe` |
| First to Serve | `FirstToServe` |
| Smart Delivery | `SmartDelivery` |
| Auto Menu | `AutoMenu` |
| Scan to Order | `ScanToOrder` |

For example, Bartender's Note should end up as `Win64/ue4ss/Mods/BartendersNote/Scripts/main.lua` with `enabled.txt` next to `Scripts`. A doubled folder such as `Mods/BartendersNote/BartendersNote` won't load.

**Update:** close the game and copy the new Mod folder over the old one. Smart Delivery has a delivery-preference file to keep — see its guide.

**Remove:** close the game and delete that Mod's folder from `Mods`. Keep UE4SS and your other Mods. For Mods managed by Vortex, disable them in Vortex and deploy.

**If nothing happens:** recheck the loader and Mod folders above, then see [Help](SUPPORT.md#english).

### Install with Vortex

Vortex is an optional **mod manager** that copies and removes Mod files for you. It still needs UE4SS. You'll install three things: **Vortex**, the **Parisian Bistro Simulator game extension** and **UE4SS**. The [Vortex setup guide](vortex-extension/README.md#english) walks through each step.

One-click install of the [collection](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz) requires Nexus Premium. The Mods themselves are free: with a free account, download individual ZIPs and install them manually or import them into Vortex.

### Languages and help

Mod text follows the game's language: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese.

Having trouble? See [help and feedback](SUPPORT.md#english). When reporting a problem, include the Mod version, game and loader versions, your language, and whether you are the host or a guest.

### More from LZH

Running a market too? Try [Old Market Simulator Mods](https://github.com/martin-lzh/old-market-simulator-mods) and its [Nexus collection](https://www.nexusmods.com/games/oldmarketsimulator/collections/d8iufz) for maps, pricing, stacking and shop tools.

### About the project

Mod code and documentation by **Zhaohan Liu**, released under the [MIT License](LICENSE). Each Mod ZIP includes the license. This is a fan project, not affiliated with the game's developers.

[Contributing](CONTRIBUTING.md#english) · [Development](DEVELOPMENT.md#english) · [Security](SECURITY.md#english) · [Community guidelines](CODE_OF_CONDUCT.md#english)

## 中文

**LZH’s MODS** 是为 Windows 版 **Parisian Bistro Simulator（法式小馆儿模拟器）** 制作的七款独立便利 Mod：记住待调饮料、有序出餐，并自动处理日常经营事务。按需挑选，每款 Mod 都有独立说明。

七款 Mod 均支持至游戏版本 **1.0.2.44eb（Steam Build 25822788）**。

### 选择 Mod

| Mod | 功能 | GitHub 下载 | Nexus |
| --- | --- | --- | --- |
| [Bartender's Note（调饮手记）](bartenders-note-mod/README.md#中文) | 在餐厅名称下显示自己认领且尚未做完的饮料 | [0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/bartenders-note-v0.1.2) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/1) |
| [Auto Checkout（收银管家）](auto-checkout-mod/README.md#中文) | 自动接收现金或银行卡并完成结账 | [0.1.4](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-checkout-v0.1.4) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/2) |
| [Fresh to Serve（焕鲜上桌）](fresh-to-serve-mod/README.md#中文) | 清理低劣食物和饮料；顾客还等得及时请求重做 | [0.1.3](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/fresh-to-serve-v0.1.3) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/3) |
| [First to Serve（出餐有序）](first-to-serve-mod/README.md#中文) | 持托盘或推餐车，对准出餐口或饮料出品台长按，优先拿取最早做好的成品 | [0.1.7](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/first-to-serve-v0.1.7) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/6) |
| [Smart Delivery（配送随心）](smart-delivery-mod/README.md#中文) | 为自动智能订购选择免费服务、经济型配送或高级配送 | [0.1.5](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/smart-delivery-v0.1.5) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/4) |
| [Auto Menu（菜单巧配）](auto-menu-mod/README.md#中文) | 为午餐或晚餐选择预计选择率最高的菜单 | [0.5.0](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-menu-v0.5.0) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/5) |
| [Scan to Order（扫码点餐）](scan-to-order-mod/README.md#中文) | 自动提交顾客订单，缺货时等待、补货后继续 | [0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/scan-to-order-v0.1.2) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/7) |

联机时，有的 Mod 只需房主安装，有的需要想用该功能的玩家各自安装，详见各 Mod 说明。

**想一次装齐七款？** 用 Vortex 安装 [Nexus 合集](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz)（一键安装需要 Nexus Premium）。请先按 [Vortex 安装说明](vortex-extension/README.md#中文)装好 [Vortex 游戏扩展](https://www.nexusmods.com/site/mods/2421)和 UE4SS。没有 Premium 时，逐个下载 Mod，按下方步骤手动安装。

### 手动下载与安装

手动安装免费，不需要 Vortex，也不需要 Nexus Premium，用浏览器和文件资源管理器即可完成。

UE4SS 是 **Mod 加载器**，负责在游戏启动时运行 Mod。只需安装一次，之后把想用的 Mod 放进它的 `Mods` 文件夹。

#### 先安装一次加载器

1. **退出游戏。** 在 Steam **库**中右键 **Parisian Bistro Simulator（法式小馆儿模拟器）→ 管理 → 浏览本地文件**，打开游戏目录（文件夹名可能是 **Parisian Brasserie Simulator**）。
2. **依次打开 BrasserieSimulator → Binaries → Win64**，能看到 **BrasserieSimulator-Win64-Shipping.exe**（Windows 可能隐藏 `.exe` 后缀）。保持这个窗口打开，加载器就装在这里。
3. **下载 UE4SS：**[UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip)。链接打不开时，到 [UE4SS experimental 发布页](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental)的 **Assets** 中找同名文件。不要下载 `zDEV`、`Source code` 或旧稳定版 `UE4SS_v3.0.1.zip`。
4. **把加载器放进 Win64。** 右键 ZIP → **全部解压缩 → 提取**，从解压出的文件夹中复制 **dwmapi.dll** 和 **ue4ss** 文件夹，粘贴到 **Win64**。替换已有的 UE4SS 前，先备份原文件夹。
5. **检查加载器：**`dwmapi.dll` 与 `BrasserieSimulator-Win64-Shipping.exe` 在同一层；**ue4ss** 文件夹里有 **UE4SS.dll**、**UE4SS-settings.ini** 和 **Mods**。

#### 加入想使用的 Mod

1. **下载**上表中的 Mod。**GitHub**（无需账号）：点版本链接，在 **Assets（附件）** 下载以 Mod 命名的 ZIP，不要选 **Source code**。**Nexus**：进入 **Files（文件）→ Main files（主要文件）→ Manual download（手动下载）**，免费账号选择 **Slow download（慢速下载）**。
2. **解压 Mod ZIP**（右键 → **全部解压缩 → 提取**），打开到能看到下表中的 Mod 文件夹，里面有 `Scripts` 和 `enabled.txt`。
3. **把整个文件夹**复制到 **Win64 → ue4ss → Mods**。保留其中所有文件，包括菜单巧配和配送随心的 DLL；`enabled.txt` 即使是空文件也要保留。
4. **从 Steam 启动游戏**，按各 Mod 的“怎么使用”操作。

| Mod | 复制到 `Mods` 内的文件夹 |
| --- | --- |
| Bartender's Note（调饮手记） | `BartendersNote` |
| Auto Checkout（收银管家） | `AutoCheckout` |
| Fresh to Serve（焕鲜上桌） | `FreshToServe` |
| First to Serve（出餐有序） | `FirstToServe` |
| Smart Delivery（配送随心） | `SmartDelivery` |
| Auto Menu（菜单巧配） | `AutoMenu` |
| Scan to Order（扫码点餐） | `ScanToOrder` |

以调饮手记为例，装好后应是 `Win64/ue4ss/Mods/BartendersNote/Scripts/main.lua`，`enabled.txt` 与 `Scripts` 并排。多套一层（如 `Mods/BartendersNote/BartendersNote`）无法加载。

**更新：**退出游戏，用新版 Mod 文件夹覆盖旧文件夹。配送随心有需要保留的配送偏好文件，见其说明。

**卸载：**退出游戏，从 `Mods` 删除对应的 Mod 文件夹，保留 UE4SS 和其他 Mod。由 Vortex 管理的 Mod 则在 Vortex 中禁用并部署。

**没有生效时：**核对上面的加载器和 Mod 文件夹，再查看[帮助](SUPPORT.md#中文)。

### 使用 Vortex 安装

Vortex 是可选的 **Mod 管理器**，帮你复制和移除 Mod 文件，但仍然需要 UE4SS。需要准备三样：**Vortex**、**Parisian Bistro Simulator 游戏扩展**和 **UE4SS**，逐步操作见 [Vortex 安装说明](vortex-extension/README.md#中文)。

一键安装 [Nexus 合集](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz)需要 Nexus Premium。Mod 本身免费：免费账号可逐个下载 ZIP，手动安装或导入 Vortex。

### 语言与帮助

Mod 文案跟随游戏语言，支持英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语及巴西葡萄牙语。

遇到问题请看[帮助与反馈](SUPPORT.md#中文)。反馈时请写明 Mod 版本、游戏及加载器版本、游戏语言，以及你是房主还是客机。

### LZH 的其他 Mod

也在经营菜市场？看看 [Old Market Simulator Mods](https://github.com/martin-lzh/old-market-simulator-mods) 及其 [Nexus 合集](https://www.nexusmods.com/games/oldmarketsimulator/collections/d8iufz)，包含地图、定价、堆叠与商店经营工具。

### 关于项目

Mod 代码及文档由 **Zhaohan Liu** 编写，以 [MIT 许可证](LICENSE)发布，每份 Mod ZIP 均附许可全文。本项目为玩家自制，与游戏开发商无关。

[参与贡献](CONTRIBUTING.md#中文) · [开发说明](DEVELOPMENT.md#中文) · [安全反馈](SECURITY.md#中文) · [社区规范](CODE_OF_CONDUCT.md#中文)
