# Parisian Bistro Simulator — Vortex Support

[English](#english) · [中文](#中文)

## English

**Version 0.1.1.** Adds Parisian Bistro Simulator to Vortex, so Vortex can find the game (Steam App ID `3058360`) and install UE4SS Lua Mods with their folders intact. This is a Vortex extension, separate from the seven gameplay Mods.

### Install

**Vortex is optional** — you can also [install the Mods manually](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/README.md#manual-download-and-installation) for free. One-click install of the [Nexus collection](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz) requires Nexus Premium; with a free account, download the Mod ZIPs individually and import them into Vortex one by one.

You need three things:

- **Vortex** — the program that manages Mod files.
- **This game extension** — tells Vortex where this game's files go.
- **UE4SS** — the loader that runs the Mods in the game.

Set up all three before adding the collection.

#### 1. Install Vortex and sign in

1. Close the game. Download the Windows installer from the [official Vortex page](https://www.nexusmods.com/about/vortex/) (sign in or register a free Nexus account if asked; free accounts use **Slow download**).
2. Run the installer, then open **Vortex** from the Start menu.
3. Click **Log In / Log In On Website**, sign in to your Nexus account in the browser and authorise Vortex. Your username should appear in Vortex. For the collection, use the account that has Premium.

#### 2. Add this game extension

1. Open [Parisian Bistro Simulator — Vortex Support on Nexus](https://www.nexusmods.com/site/mods/2421) and under **Files** choose **Manual download** for version **0.1.1**. Keep the ZIP as it is.
2. In **Vortex → Home → Extensions**, click **Drop File(s)** and pick the ZIP, or drag the ZIP onto that area.
3. Restart Vortex when prompted. (The extension goes in **Extensions**, not the **Mods** page.)

#### 3. Install the UE4SS loader

Vortex and the collection don't install UE4SS, so do this yourself. If UE4SS is already installed as below, skip this part.

1. **Close the game.** In Steam, open **Library**, right-click **Parisian Bistro Simulator** → **Manage → Browse local files**. This opens the game folder (it may be named **Parisian Brasserie Simulator**).
2. **Open BrasserieSimulator → Binaries → Win64.** You should see **BrasserieSimulator-Win64-Shipping.exe** (Windows may hide the `.exe`). Keep this window open; the loader goes here.
3. **Download UE4SS:** [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip). If the link doesn't open, find that exact file under **Assets** on the [UE4SS experimental release page](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental). Don't use `zDEV`, `Source code` or the old stable `UE4SS_v3.0.1.zip`.
4. **Copy the loader into Win64.** Right-click the ZIP → **Extract All… → Extract**. From the extracted folder, copy **dwmapi.dll** and the **ue4ss** folder and paste both into **Win64**. If you are replacing an existing UE4SS, back up its folder first.
5. **Check the loader:** `dwmapi.dll` sits next to `BrasserieSimulator-Win64-Shipping.exe`, and the **ue4ss** folder contains **UE4SS.dll**, **UE4SS-settings.ini** and **Mods**.

#### 4. Point Vortex at the game

1. In Vortex, open **Games**, search **Parisian Bistro Simulator** and click **Manage**. If it isn't listed, check that the extension is enabled under **Extensions** and restart Vortex.
2. If Vortex can't find the game, select the game's root folder — the one Steam's **Browse local files** opens, containing **BrasserieSimulator.exe** and the **BrasserieSimulator** folder (not `Win64`, `ue4ss` or `Mods`).
3. If Vortex says **Install UE4SS experimental first**, redo part 3: `BrasserieSimulator/Binaries/Win64/ue4ss/UE4SS.dll` and `ue4ss/Mods` must exist under that folder.
4. If Vortex asks for a **Mod Staging Folder**, pick an empty folder on the same drive as the game, such as `D:\Vortex Mods\Parisian Bistro Simulator` — not the game's `Mods` folder. Accept the suggested deployment method if asked.

#### 5. Add, enable and deploy Mods

**Collection (Premium):** while signed in with Premium, open the [collection](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz), choose the Vortex install option and let the browser open Vortex. Follow the prompts until everything is installed, make sure the Mods are enabled, then click **Deploy Mods** if it's offered.

**Individual ZIPs (free):** download each Mod from its Nexus page (**Files → Manual download → Slow download**) or from the [GitHub links](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/README.md#choose-a-mod). In Vortex, with Parisian Bistro Simulator selected, open **Mods → Install From File**, pick a Mod ZIP, install it and set it to **Enabled**. Repeat for each Mod, then click **Deploy Mods**. Only gameplay Mod ZIPs go here — not the UE4SS or extension ZIP.

**Deploying** is what puts the files into the game. Afterwards, open **BrasserieSimulator → Binaries → Win64 → ue4ss → Mods** and check that each Mod's folder contains **Scripts/main.lua** and **enabled.txt** — for example `Mods/BartendersNote/Scripts/main.lua`. Auto Menu and Smart Delivery also have a DLL in their `Scripts` folder.

Then start the game through Steam and follow each Mod's guide.

#### Update, remove or switch from a manual install

Close the game first.

- **Update:** install the new package in Vortex, accept the replacement prompt, enable it and deploy.
- **Remove:** disable the Mod in Vortex and deploy. (Deleting the downloaded ZIP alone doesn't uninstall it.)
- **Switching from a manual install:** back up the Mod's existing folder, delete it from `ue4ss/Mods`, then let Vortex deploy its copy. Keep only one copy of each Mod.
- **Smart Delivery:** back up `SmartDelivery/Scripts/delivery-preference.txt` before updating or switching, and put it back after deploying.

If deployment fails, read Vortex's notification and check the staging folder. If a deployed Mod does nothing in game, check the loader location, the Mod's folder and its host/guest requirements, then see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english).

### Build

From the repository root:

```powershell
node --test vortex-extension/tests/*.test.js
python vortex-extension/build.py
```

The ZIP and its SHA-256 file are written to the ignored `outputs/vortex-extension/`. The package contains the extension files and the license text (PolyForm Noncommercial License 1.0.0). `gameart.svg` is the vector source of the bundled 640 × 360 PNG (a serving cloche).

The tests cover complete Mod folders, multiple Mods, bundled DLLs, Windows paths, duplicate destinations and incomplete or unsafe packages. On 2026-10-05, Vortex 2.6.3 loaded the extension, detected the Steam install and deployed all seven published LZH packages to a test directory; all 76 files matched the original ZIPs byte for byte.

[Source and support](https://github.com/martin-lzh/parisian-bistro-simulator-mods) · [Vortex extension documentation](https://github.com/Nexus-Mods/Vortex/wiki/LEGACY-General-Creating-a-game-extension)

## 中文

**版本 0.1.1。** 为 Vortex 添加《法式小馆儿模拟器》支持：通过 Steam App ID `3058360` 找到游戏，并按完整文件夹安装 UE4SS Lua Mod。这是 Vortex 游戏扩展，独立于七款游戏功能 Mod。

### 安装

**Vortex 是可选的**，也可以按[手动安装指南](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/README.md#手动下载与安装)免费安装 Mod。一键安装 [Nexus 合集](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz)需要 Nexus Premium；免费账号可以逐个下载 Mod ZIP，再逐个导入 Vortex。

需要准备三样：

- **Vortex**：管理 Mod 文件的软件。
- **本游戏扩展**：告诉 Vortex 本游戏的文件放在哪里。
- **UE4SS**：在游戏中运行 Mod 的加载器。

添加合集前，三样都要装好。

#### 1. 安装 Vortex 并登录

1. 退出游戏。从 [Vortex 官方页面](https://www.nexusmods.com/about/vortex/)下载 Windows 安装程序（如要求登录，登录或注册免费 Nexus 账号；免费账号选择 **Slow download（慢速下载）**）。
2. 运行安装程序，完成后从开始菜单打开 **Vortex**。
3. 点击 **Log In / Log In On Website（登录／在网站登录）**，在浏览器中登录 Nexus 账号并授权 Vortex，回到 Vortex 应能看到用户名。安装合集时请使用有 Premium 的账号。

#### 2. 添加本游戏扩展

1. 打开 [Parisian Bistro Simulator — Vortex Support 扩展页面](https://www.nexusmods.com/site/mods/2421)，在 **Files（文件）** 中手动下载 **0.1.1** 版本。保留 ZIP，不要解压。
2. 在 **Vortex → Home（主页）→ Extensions（扩展）** 点击 **Drop File(s)** 选择该 ZIP，或直接把 ZIP 拖进这个区域。
3. 按提示重启 Vortex。（扩展装在 **Extensions**，不是 **Mods** 页面。）

#### 3. 安装 UE4SS 加载器

Vortex 和合集都不会安装 UE4SS，需要自己装。已按下列结构装好 UE4SS 的可以跳过。

1. **退出游戏。** 在 Steam **库**中右键 **Parisian Bistro Simulator（法式小馆儿模拟器）→ 管理 → 浏览本地文件**，打开游戏目录（文件夹名可能是 **Parisian Brasserie Simulator**）。
2. **依次打开 BrasserieSimulator → Binaries → Win64**，能看到 **BrasserieSimulator-Win64-Shipping.exe**（Windows 可能隐藏 `.exe` 后缀）。保持这个窗口打开，加载器就装在这里。
3. **下载 UE4SS：**[UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip)。链接打不开时，到 [UE4SS experimental 发布页](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental)的 **Assets** 中找同名文件。不要下载 `zDEV`、`Source code` 或旧稳定版 `UE4SS_v3.0.1.zip`。
4. **把加载器放进 Win64。** 右键 ZIP → **全部解压缩 → 提取**，从解压出的文件夹中复制 **dwmapi.dll** 和 **ue4ss** 文件夹，粘贴到 **Win64**。替换已有的 UE4SS 前，先备份原文件夹。
5. **检查加载器：**`dwmapi.dll` 与 `BrasserieSimulator-Win64-Shipping.exe` 在同一层；**ue4ss** 文件夹里有 **UE4SS.dll**、**UE4SS-settings.ini** 和 **Mods**。

#### 4. 让 Vortex 找到游戏

1. 在 Vortex 打开 **Games（游戏）**，搜索 **Parisian Bistro Simulator**，点击 **Manage（管理）**。搜不到时，到 **Extensions** 确认扩展已启用，再重启 Vortex。
2. 自动查找失败时，选择游戏根目录，也就是 Steam“浏览本地文件”打开的那个文件夹，里面有 **BrasserieSimulator.exe** 和 **BrasserieSimulator** 文件夹（不是 `Win64`、`ue4ss` 或 `Mods`）。
3. 提示 **Install UE4SS experimental first** 时，回到第 3 部分重新检查：该目录下必须有 `BrasserieSimulator/Binaries/Win64/ue4ss/UE4SS.dll` 和 `ue4ss/Mods`。
4. 要求设置 **Mod Staging Folder（Mod 暂存文件夹）** 时，在游戏所在磁盘选一个空文件夹，例如 `D:\Vortex Mods\Parisian Bistro Simulator`，不要选游戏里的 `Mods` 文件夹。提示选择部署方式时，使用 Vortex 的建议。

#### 5. 添加、启用并部署 Mod

**合集（Premium）：**用 Premium 账号打开[合集](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz)，选择 Vortex 安装，允许浏览器打开 Vortex。按提示完成安装，确认 Mod 已启用；出现 **Deploy Mods（部署 Mod）** 时点击部署。

**逐个 ZIP（免费）：**在各 Mod 的 Nexus 页面通过 **Files → Manual download → Slow download** 下载，或使用 [GitHub 链接](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/README.md#选择-mod)。在 Vortex 选中本游戏，打开 **Mods → Install From File（从文件安装）**，选择 Mod ZIP，安装后设为 **Enabled（已启用）**。每个 Mod 操作一次，最后点击 **Deploy Mods（部署 Mod）**。这里只导入游戏功能 Mod，不要导入 UE4SS 或扩展的 ZIP。

**部署**才会把文件放进游戏。部署后打开 **BrasserieSimulator → Binaries → Win64 → ue4ss → Mods**，检查每个 Mod 的文件夹里有 **Scripts/main.lua** 和 **enabled.txt**，例如 `Mods/BartendersNote/Scripts/main.lua`。菜单巧配和配送随心的 `Scripts` 里还有各自的 DLL。

之后从 Steam 启动游戏，按各 Mod 的说明使用。

#### 更新、卸载或从手动安装切换

先退出游戏。

- **更新：**在 Vortex 导入新版，按提示替换，启用后部署。
- **卸载：**在 Vortex 中禁用该 Mod 并部署。（只删除下载的 ZIP 不会卸载。）
- **从手动安装切换：**先备份原 Mod 文件夹，再从 `ue4ss/Mods` 删除，然后由 Vortex 部署。每个 Mod 只保留一份。
- **配送随心：**更新或切换前备份 `SmartDelivery/Scripts/delivery-preference.txt`，部署后放回。

部署失败时查看 Vortex 通知并检查暂存文件夹；部署成功但游戏内没有效果时，核对加载器位置、Mod 文件夹和房主／客机要求，再查看[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

### 构建

在仓库根目录执行上方两条命令，运行安装器测试并生成扩展 ZIP。ZIP 及 SHA-256 文件写入被忽略的 `outputs/vortex-extension/`，包内为扩展文件和许可文本（PolyForm Noncommercial 1.0.0 许可）。`gameart.svg` 是随包 640 × 360 PNG 图标（餐盘罩）的矢量源文件。

测试覆盖完整 Mod 文件夹、多个 Mod、随包 DLL、Windows 路径、重复目标以及不完整或不安全的压缩包。2026-10-05 在 Vortex 2.6.3 中加载扩展、识别 Steam 安装，并把七个已发布的 LZH 安装包部署到测试目录，全部 76 个文件与原 ZIP 逐字节一致。
