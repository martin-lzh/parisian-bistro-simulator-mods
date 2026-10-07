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

**LZH’s MODS** brings seven independent quality-of-life Mods to **Parisian Bistro Simulator** on Windows. Keep track of drinks, serve orders in sequence and automate routine restaurant tasks. Choose the features that fit your restaurant; each Mod has its own installation and gameplay guide.

### Choose a Mod

> **One-click collection installation currently requires an active Nexus Premium membership.** Free users can download each Mod individually from Nexus or GitHub and follow the manual steps below. Install all seven through the [Nexus collection](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz). First install the [Vortex game extension](https://www.nexusmods.com/site/mods/2421) and UE4SS experimental separately; follow the [extension guide](vortex-extension/README.md#english). Individual Nexus and GitHub downloads remain available.

| Mod | What it does | GitHub download | Nexus |
| --- | --- | --- | --- |
| [Bartender's Note](bartenders-note-mod/README.md#english) | Shows your claimed, unfinished drinks below the restaurant name | [0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/bartenders-note-v0.1.2) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/1) |
| [Auto Checkout](auto-checkout-mod/README.md#english) | Accepts cash or cards and completes checkout automatically | [0.1.4](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-checkout-v0.1.4) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/2) |
| [Fresh to Serve](fresh-to-serve-mod/README.md#english) | Clears spoiled meals and drinks and requests replacements when the customer can still wait | [0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/fresh-to-serve-v0.1.2) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/3) |
| [First to Serve](first-to-serve-mod/README.md#english) | Hold at a kitchen pass or drink output area to collect the oldest ready items with a tray or food trolley | [0.1.7](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/first-to-serve-v0.1.7) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/6) |
| [Smart Delivery](smart-delivery-mod/README.md#english) | Choose free, budget or premium delivery for automatic smart orders | [0.1.5](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/smart-delivery-v0.1.5) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/4) |
| [Auto Menu](auto-menu-mod/README.md#english) | Choose a lunch or dinner menu with the highest estimated selection rate | [0.5.0](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-menu-v0.5.0) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/5) |
| [Scan to Order](scan-to-order-mod/README.md#english) | Take customer orders automatically, waiting for missing stock and continuing after replenishment | [0.1.1](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/scan-to-order-v0.1.1) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/7) |

These stable versions follow the maintainer's confirmation that all seven Mods passed in-game and multiplayer testing on 2026-09-26. Check each guide for host/guest requirements and gameplay limits; see the [validation record](releases/validation.md#english).

For game **1.0.2.44eb / Steam Build 25759268**, current source advances **Fresh to Serve to 0.1.3** and **Scan to Order to 0.1.2** to fix table lookup failures. These patches are pending publication and updated-game acceptance; the download links above still point to the earlier published packages without this fix.

### Manual download and installation

These instructions start with only the Windows game installed. **Manual installation is free and does not require Vortex or a Nexus Premium subscription.** A web browser and Windows File Explorer are enough; Windows can extract ZIP files without WinRAR or 7-Zip. You do not need Git, Python, Visual Studio or Unreal Engine.

UE4SS is the **mod loader**: it starts the Mod when the game starts. Install it once for this game, then add any of the seven Mods to its `Mods` folder. Vortex is an optional **mod manager**, which copies and removes Mod files for you; it does not replace UE4SS.

#### Install the loader once

1. **Exit the game completely.** In Steam, open **Library**, right-click **Parisian Bistro Simulator**, then choose **Manage → Browse local files**. The File Explorer window that opens is your game folder. Its name may be **Parisian Brasserie Simulator**. Do not use Documents or the save folder.
2. **Open the installation destination.** In that window, double-click **BrasserieSimulator**, then **Binaries**, then **Win64**. You should see **BrasserieSimulator-Win64-Shipping.exe** (Windows may hide `.exe`). Keep this window open. This is where the loader goes; do not put the loader beside the top-level `BrasserieSimulator.exe`.
3. **Download the loader.** Use [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip), the basic experimental build used as this project's reference. If the direct link fails, open [UE4SS experimental releases](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental), expand **Assets / Show all assets** and find that exact filename. Do not choose `zDEV`, `Source code` or the old stable `UE4SS_v3.0.1.zip`. Other experimental builds have not been verified for these Mods.
4. **Extract the loader ZIP.** In File Explorer's **Downloads** folder, right-click the downloaded ZIP → **Extract All… → Extract**. Open the extracted folder. Inside it, select **dwmapi.dll** and the entire **ue4ss** folder, right-click → **Copy**; return to the game's **Win64** window, right-click empty space → **Paste**. Copy both items themselves, not the outer folder named after the ZIP. There is no UE4SS installer to run. If you already have UE4SS installed, back up its folder and settings before replacing anything; keep your existing Mods.
5. **Check the loader location.** In **Win64**, `dwmapi.dll` must sit beside `BrasserieSimulator-Win64-Shipping.exe`. Open **ue4ss**: it must contain **UE4SS.dll**, **UE4SS-settings.ini** and **Mods**. If these are missing, repeat the extraction/copy step; an empty folder named `Mods` alone does not install the loader.

#### Add the Mods you want

1. Choose a Mod from the table above. **GitHub:** open its version link, scroll to **Assets** and click the ZIP named after that Mod; `Source code` is for developers. **Nexus:** sign in with a free account, open **Files → Main files → Manual download**, continue through any requirements notice and choose **Slow download**. GitHub needs no account. `SHA256SUMS.txt` is an optional checksum, not an installer.
2. Find the downloaded Mod ZIP in File Explorer's **Downloads**, right-click → **Extract All… → Extract**. Open the extracted result until you see the Mod's own folder listed in the table below. Inside it are `Scripts` and `enabled.txt`.
3. Copy that **whole Mod folder** into the game's **BrasserieSimulator → Binaries → Win64 → ue4ss → Mods**. Repeat for each Mod you want. Do not copy the ZIP, just `main.lua`, or an extra outer folder. Keep all supplied files, including DLLs in Auto Menu and Smart Delivery. `enabled.txt` may be empty; keep it. Windows may hide `.txt`, `.lua` or `.dll` extensions.
4. Check the folder names below, then launch through Steam and follow each Mod's **How to use** guide. Background Mods may have no startup message. In multiplayer, read each guide's host/guest requirements; installing on the host does not automatically install files on guests' computers.

| Mod | Folder to copy into `Mods` |
| --- | --- |
| Bartender's Note | `BartendersNote` |
| Auto Checkout | `AutoCheckout` |
| Fresh to Serve | `FreshToServe` |
| First to Serve | `FirstToServe` |
| Smart Delivery | `SmartDelivery` |
| Auto Menu | `AutoMenu` |
| Scan to Order | `ScanToOrder` |

For example, open **Mods → BartendersNote → Scripts** and check for **main.lua**; return once to **BartendersNote** and check **enabled.txt** beside **Scripts**. The full path is `BrasserieSimulator/Binaries/Win64/ue4ss/Mods/BartendersNote/Scripts/main.lua`. `Mods/BartendersNote/BartendersNote` is an extra folder layer and will not work.

**Update or remove:** exit the game first. For an update, use the new Mod ZIP and follow that Mod's guide; Smart Delivery has a delivery-preference file to preserve. To remove a manually installed Mod, delete only its named folder from `Mods`. Keep UE4SS and other Mods. For Vortex-managed Mods, disable and deploy in Vortex instead. Removing a Mod does not undo actions already saved by the game.

**If nothing changes:** check both the loader and Mod locations, then consult [Help](SUPPORT.md#english). `Win64/ue4ss/UE4SS.log` can be opened with Notepad after running the game. A missing log suggests the loader did not start; a fresh log alone does not prove every Mod works.

### Install with Vortex

Vortex needs three separate preparations: install **Vortex itself**, add the **Parisian Bistro Simulator game extension**, and install **UE4SS** as above. Follow the [Vortex setup guide](vortex-extension/README.md#english) for each click and the final deployment check.

**An active Nexus Premium membership is currently required for one-click installation of the [collection](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz).** A free Nexus account is not Premium. The seven Mods themselves are free: free users can download individual ZIPs and install them manually or import them into Vortex. The collection does not automatically install the game extension or UE4SS; even Premium users must finish those preparations first.

### Languages and help

Mod text follows the game's language. English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese are supported. No extra language pack is needed. Mods without their own interface keep the game's original text.

For installation problems or a feature that is not working, start with [help and feedback](SUPPORT.md#english). Include the Mod version, game and loader versions, language, and whether you are the host or a guest.

### More from LZH

Running a market too? Explore [Old Market Simulator Mods](https://github.com/martin-lzh/old-market-simulator-mods) and its [Nexus collection](https://www.nexusmods.com/games/oldmarketsimulator/collections/d8iufz) for maps, pricing, stacking and shop tools.

### About the project

Original Mod code and documentation are by **Zhaohan Liu**, under the [MIT License](LICENSE). Each Mod ZIP includes its license. Game files and the loader are distributed separately under their own terms. This project is not affiliated with the game's creators.

[Contributing](CONTRIBUTING.md#english) · [Development](DEVELOPMENT.md#english) · [Security](SECURITY.md#english) · [Community guidelines](CODE_OF_CONDUCT.md#english)

## 中文

**LZH’s MODS** 为 Windows 版 **Parisian Bistro Simulator（法式小馆儿模拟器）** 提供七款独立便利 Mod，帮你记住待调饮料、有序出餐，并自动处理日常经营事务。按餐厅需要选择功能，每款 Mod 都有独立安装与操作指南。

### 选择 Mod

> **目前 Vortex 合集一键安装仅限有效的 Nexus Premium 会员。** 免费用户可从 Nexus 或 GitHub 逐个下载 Mod，按下方步骤手动安装。可通过 [Nexus 合集](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz)安装全部七款 Mod。请先单独安装 [Vortex 游戏扩展](https://www.nexusmods.com/site/mods/2421)和 UE4SS experimental，步骤见[扩展说明](vortex-extension/README.md#中文)。也可继续使用各 Mod 的 Nexus 或 GitHub 独立下载。

| Mod | 功能 | GitHub 下载 | Nexus |
| --- | --- | --- | --- |
| [Bartender's Note（调饮手记）](bartenders-note-mod/README.md#中文) | 在餐厅名称下显示自己认领且尚未做完的饮料 | [0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/bartenders-note-v0.1.2) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/1) |
| [Auto Checkout（收银管家）](auto-checkout-mod/README.md#中文) | 自动接收现金或银行卡并完成结账 | [0.1.4](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-checkout-v0.1.4) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/2) |
| [Fresh to Serve（焕鲜上桌）](fresh-to-serve-mod/README.md#中文) | 清理低劣食物和饮料；顾客仍有足够耐心时请求重做 | [0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/fresh-to-serve-v0.1.2) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/3) |
| [First to Serve（出餐有序）](first-to-serve-mod/README.md#中文) | 持托盘或推餐车，对准出餐口或饮料出品台长按，优先拿取最早做好的成品 | [0.1.7](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/first-to-serve-v0.1.7) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/6) |
| [Smart Delivery（配送随心）](smart-delivery-mod/README.md#中文) | 为自动智能订购选择免费服务、经济型配送或高级配送 | [0.1.5](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/smart-delivery-v0.1.5) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/4) |
| [Auto Menu（菜单巧配）](auto-menu-mod/README.md#中文) | 为午餐或晚餐选择预计选择率最高的菜单 | [0.5.0](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-menu-v0.5.0) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/5) |
| [Scan to Order（扫码点餐）](scan-to-order-mod/README.md#中文) | 自动提交顾客订单，缺货时等待、补货后继续 | [0.1.1](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/scan-to-order-v0.1.1) | [Nexus](https://www.nexusmods.com/parisianbistrosimulator/mods/7) |

维护者于 2026-09-26 确认全部 7 个 Mod 实机及联机测试通过，当前提供对应正式版。房主／客机要求及玩法限制见各 Mod 说明，测试反馈见[验收记录](releases/validation.md#中文)。

为适配游戏 **1.0.2.44eb／Steam Build 25759268**，当前源码将**焕鲜上桌升级为 0.1.3**、**扫码点餐升级为 0.1.2**，修复餐桌查询失败。这两个补丁尚待发布和新版实机验收；上表下载链接仍指向不含此次修复的旧版正式包。

### 手动下载与安装

以下步骤从电脑上只安装了 Windows 版游戏开始。**手动安装免费，不需要 Vortex，也不需要 Nexus Premium 会员。** 用浏览器和 Windows 文件资源管理器即可操作；Windows 自带 ZIP 解压功能，无需安装 WinRAR 或 7-Zip，也不需要 Git、Python、Visual Studio 或虚幻引擎。

UE4SS 是**加载器**，作用是在启动游戏时运行 Mod。每个游戏安装目录只需装一次，之后把所需 Mod 加入它的 `Mods` 文件夹即可。Vortex 是可选的 **Mod 管理器**，负责复制和移除 Mod 文件，不能代替 UE4SS。

#### 先安装一次加载器

1. **完全退出游戏。** 在 Steam 打开**库**，右键 **Parisian Bistro Simulator（法式小馆儿模拟器）→ 管理 → 浏览本地文件**。弹出的文件资源管理器窗口就是游戏目录，文件夹名可能是 **Parisian Brasserie Simulator**。不是“文档”或存档文件夹。
2. **打开安装位置。** 在该窗口依次双击 **BrasserieSimulator → Binaries → Win64**，应该能看到 **BrasserieSimulator-Win64-Shipping.exe**（Windows 可能隐藏 `.exe` 后缀）。保留此窗口，加载器就放在这里；不要放在最外层 `BrasserieSimulator.exe` 旁边。
3. **下载加载器。** 点击 [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip)，这是本项目核对过的 experimental 基础包。若直链失效，打开 [UE4SS experimental 发布页](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental)，展开 **Assets / Show all assets（附件／显示全部附件）**，找到这个完整文件名。不要下载 `zDEV`、`Source code`，也不要使用旧稳定版 `UE4SS_v3.0.1.zip`。其他 experimental 构建尚未核验。
4. **解压并放入加载器。** 在文件资源管理器的**下载**文件夹里，右键刚下载的 ZIP → **全部解压缩 → 提取**。打开解压后的文件夹，选中里面的 **dwmapi.dll** 和整个 **ue4ss** 文件夹，右键**复制**；回到游戏的 **Win64** 窗口，在空白处右键**粘贴**。复制这两个项目本身，不要把以压缩包命名的外层文件夹一起套进去。UE4SS 没有需要双击运行的安装程序。已经安装过加载器时，替换前备份其文件夹和设置，并保留现有 Mod。
5. **检查加载器位置。** **Win64** 中的 `dwmapi.dll` 应与 `BrasserieSimulator-Win64-Shipping.exe` 并排。打开 **ue4ss**，里面应有 **UE4SS.dll**、**UE4SS-settings.ini** 和 **Mods**。缺少这些内容时回到上一步重新解压、复制；只新建一个空的 `Mods` 文件夹不能装好加载器。

#### 加入想使用的 Mod

1. 在上方表格选择 Mod。**GitHub：**点击版本链接，向下找到 **Assets（附件）**，下载以 Mod 命名的 ZIP；不要选开发者使用的 `Source code`。**Nexus：**登录免费账号，进入 **Files（文件）→ Main files（主要文件）→ Manual download（手动下载）**，按提示经过前置要求页面后选 **Slow download（慢速下载）**。GitHub 无需账号。`SHA256SUMS.txt` 是可选校验文件，不是安装程序。
2. 在文件资源管理器的**下载**文件夹找到 Mod ZIP，右键 → **全部解压缩 → 提取**。打开解压结果，直到看到下表对应的 Mod 文件夹，里面应有 `Scripts` 和 `enabled.txt`。
3. 将这个 **Mod 文件夹整体**复制到游戏的 **BrasserieSimulator → Binaries → Win64 → ue4ss → Mods**。每个想安装的 Mod 各操作一次。不要复制 ZIP 本身，不要只复制 `main.lua`，不要多带一层外部文件夹。保留包内所有文件，包括菜单巧配和配送随心的 DLL；`enabled.txt` 可能是空文件，也要保留。Windows 可能隐藏 `.txt`、`.lua` 或 `.dll` 后缀。
4. 按下表核对文件夹名称，再从 Steam 启动游戏，按各 Mod 的“怎么使用”操作。后台 Mod 可能没有启动提示。联机时按各 Mod 的房主／客机要求安装；房主电脑装好并不等于客机电脑也会自动装好。

| Mod | 复制到 `Mods` 内的文件夹 |
| --- | --- |
| Bartender's Note（调饮手记） | `BartendersNote` |
| Auto Checkout（收银管家） | `AutoCheckout` |
| Fresh to Serve（焕鲜上桌） | `FreshToServe` |
| First to Serve（出餐有序） | `FirstToServe` |
| Smart Delivery（配送随心） | `SmartDelivery` |
| Auto Menu（菜单巧配） | `AutoMenu` |
| Scan to Order（扫码点餐） | `ScanToOrder` |

以调饮手记为例，打开 **Mods → BartendersNote → Scripts** 应能看到 **main.lua**；返回一层到 **BartendersNote**，应能看到与 **Scripts** 并排的 **enabled.txt**。完整路径是 `BrasserieSimulator/Binaries/Win64/ue4ss/Mods/BartendersNote/Scripts/main.lua`。不要多套成 `Mods/BartendersNote/BartendersNote`。

**更新或卸载：**先退出游戏。更新时下载新版 ZIP，按该 Mod 的说明替换；配送随心有需要保留的配送偏好文件。手动安装的 Mod，只删除 `Mods` 里对应名称的文件夹即可卸载，保留 UE4SS 和其他 Mod。由 Vortex 管理的 Mod 则在 Vortex 中禁用并部署。卸载不会撤销已经写入游戏存档的操作。

**没有生效时：**核对加载器和 Mod 两处位置，再看[帮助](SUPPORT.md#中文)。运行过游戏后，可用记事本打开 `Win64/ue4ss/UE4SS.log`；没有日志通常表示加载器未启动，有新日志也不等于所有 Mod 都正常工作。

### 使用 Vortex 安装

Vortex 路线需要分别准备 **Vortex 软件**、**Parisian Bistro Simulator 游戏扩展**和上面所说的 **UE4SS 加载器**。每一步点击位置及部署后的检查方法见 [Vortex 安装说明](vortex-extension/README.md#中文)。

**目前通过 Vortex 一键安装 [Nexus 合集](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz)仅限有效的 Nexus Premium 会员，普通免费注册账号不属于 Premium。** 七款 Mod 本身免费；免费用户可以逐个下载 ZIP，手动安装或逐个导入 Vortex。合集不会自动装好游戏扩展或 UE4SS，Premium 用户也必须先完成这些准备。

### 语言与帮助

Mod 文案跟随游戏语言，支持英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语及巴西葡萄牙语，无需额外语言包。不新增界面的 Mod 继续使用游戏原有文案。

安装遇到问题或功能没有生效时，先查看[帮助与反馈](SUPPORT.md#中文)。反馈时请提供 Mod、游戏及加载器版本、所选语言，以及自己是房主还是客机。

### LZH 的其他 Mod

也在经营菜市场？看看 [Old Market Simulator Mods](https://github.com/martin-lzh/old-market-simulator-mods) 及其 [Nexus 合集](https://www.nexusmods.com/games/oldmarketsimulator/collections/d8iufz)，包含地图、定价、堆叠与商店经营工具。

### 关于项目

原创 Mod 代码及文档由 **Zhaohan Liu** 编写，使用 [MIT 许可证](LICENSE)，每份 Mod ZIP 均附许可全文。游戏文件及加载器另行分发，遵循各自条款。本项目与游戏制作方无隶属关系。

[参与贡献](CONTRIBUTING.md#中文) · [开发说明](DEVELOPMENT.md#中文) · [安全反馈](SECURITY.md#中文) · [社区规范](CODE_OF_CONDUCT.md#中文)
