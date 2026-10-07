# Parisian Bistro Simulator — Vortex Support

[English](#english) · [中文](#中文)

## English

**Version 0.1.0.** Adds Parisian Bistro Simulator to Vortex and installs complete UE4SS Lua mod folders without flattening their contents. Steam detection uses App ID `3058360`. This is a Vortex extension, separate from the seven gameplay mods.

### Install

**Vortex is optional.** You can use the seven Mods for free with the [manual installation guide](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/README.md#manual-download-and-installation). **One-click installation of the [Nexus collection](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz) currently requires an active Nexus Premium membership.** A free registered account is not Premium. Free users can download individual Mod ZIPs from Nexus or GitHub and install them manually, or import those ZIPs into Vortex one at a time. The Mods themselves are free.

Vortex is a program for managing Mod files. This **game extension** teaches it where this game's files belong. **UE4SS** is a separate loader that runs the Mods inside the game. Install all three before adding the collection; Premium does not remove these prerequisites. No programming tools are required.

#### 1. Install Vortex and sign in

1. Exit the game. Open the [official Vortex download page](https://www.nexusmods.com/about/vortex/), use its download link and get the Windows installer. If Nexus asks, sign in or register a free account. Free downloads use **Slow download**.
2. Open the installer from your browser's Downloads list and follow the setup prompts. Open **Vortex** from the Windows Start menu when installation finishes.
3. In Vortex, choose **Log In / Log In On Website**. In the browser, sign in to the same Nexus account you plan to use for downloads and authorise Vortex. Return to Vortex and check that your username appears. A Premium user must use the account with the active membership.

#### 2. Add support for this game

1. Open [Parisian Bistro Simulator — Vortex Support on Nexus](https://www.nexusmods.com/site/mods/2421). In **Files**, choose **Manual download** for version **0.1.0** and save the extension ZIP. Keep it as a ZIP; do not extract it into the game.
2. In **Vortex → Home → Extensions**, click **Drop File(s)** and choose the downloaded extension ZIP, or drag that ZIP from File Explorer's Downloads folder onto the drop area.
3. Finish the extension installation and restart Vortex when prompted. This ZIP belongs in **Extensions**, not the gameplay **Mods** page. Removing the extension later does not remove deployed gameplay Mods.

#### 3. Install the UE4SS loader

The extension and collection do not download or install UE4SS. Follow these steps even if you have Premium; if UE4SS is already installed in the layout below, keep that installation and check its version.

1. **Exit the game completely.** In Steam, open **Library**, right-click **Parisian Bistro Simulator**, then choose **Manage → Browse local files**. The File Explorer window that opens is your game folder. Its name may be **Parisian Brasserie Simulator**. Do not use Documents or the save folder.
2. **Open the installation destination.** In that window, double-click **BrasserieSimulator**, then **Binaries**, then **Win64**. You should see **BrasserieSimulator-Win64-Shipping.exe** (Windows may hide `.exe`). Keep this window open. This is where the loader goes; do not put the loader beside the top-level `BrasserieSimulator.exe`.
3. **Download the loader.** Use [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip), the basic experimental build used as this project's reference. If the direct link fails, open [UE4SS experimental releases](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental), expand **Assets / Show all assets** and find that exact filename. Do not choose `zDEV`, `Source code` or the old stable `UE4SS_v3.0.1.zip`. Other experimental builds have not been verified for these Mods.
4. **Extract the loader ZIP.** In File Explorer's **Downloads** folder, right-click the downloaded ZIP → **Extract All… → Extract**. Open the extracted folder. Inside it, select **dwmapi.dll** and the entire **ue4ss** folder, right-click → **Copy**; return to the game's **Win64** window, right-click empty space → **Paste**. Copy both items themselves, not the outer folder named after the ZIP. There is no UE4SS installer to run. If you already have UE4SS installed, back up its folder and settings before replacing anything; keep your existing Mods.
5. **Check the loader location.** In **Win64**, `dwmapi.dll` must sit beside `BrasserieSimulator-Win64-Shipping.exe`. Open **ue4ss**: it must contain **UE4SS.dll**, **UE4SS-settings.ini** and **Mods**. If these are missing, repeat the extraction/copy step; an empty folder named `Mods` alone does not install the loader.

#### 4. Tell Vortex where the game is

1. Open **Games** in Vortex, search **Parisian Bistro Simulator** and click **Manage**. If it is not listed, return to Extensions and check that the game extension is installed and enabled, then restart Vortex.
2. If Vortex cannot find the game, use Steam's **Manage → Browse local files** again and select **that game folder** in Vortex. It contains **BrasserieSimulator.exe** and the **BrasserieSimulator** folder. Here you select the game root, not `Win64`, `ue4ss` or `Mods`.
3. If Vortex says **Install UE4SS experimental first**, recheck step 3: it needs `BrasserieSimulator/Binaries/Win64/ue4ss/UE4SS.dll` and `ue4ss/Mods` beneath the selected game folder.
4. If Vortex asks for a **Mod Staging Folder**, this is where it keeps working copies before deployment. Choose a separate writable folder on the same drive as the game, for example `D:\Vortex Mods\Parisian Bistro Simulator` for a game on D:. Do not use the game's own `Mods` folder. Apply the suggested deployment method if Vortex prompts for one.

#### 5. Download, enable and deploy Mods

**Premium collection route:** open the [collection](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz) while signed into your Premium account, choose its Vortex installation option and allow the browser to open Vortex. Follow Vortex's collection prompts until downloads and installation finish. Check the Mods page, enable the wanted Mods and click **Deploy Mods** if deployment is pending. “One-click” refers to the collection download/install convenience after setup; prerequisite installers and prompts still need your attention.

**Individual ZIP route (free):** open each Mod's Nexus **Files → Manual download → Slow download**, or use the [GitHub release links](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/README.md#choose-a-mod) without an account. Keep the original ZIPs. In Vortex, with Parisian Bistro Simulator selected, open **Mods → Install From File**, select a Mod ZIP, install it, then set it to **Enabled**. Repeat for the desired Mods and click **Deploy Mods**. The UE4SS ZIP and Vortex extension ZIP do not belong in this gameplay Mod installer.

**Deploy** means copying/linking the enabled Mod files into the game. Downloaded or installed alone is not enough. After deployment, browse the game files and open **BrasserieSimulator → Binaries → Win64 → ue4ss → Mods**. For each chosen Mod, check that its own folder contains **Scripts/main.lua** and **enabled.txt**. For example: `Mods/BartendersNote/Scripts/main.lua`. Auto Menu and Smart Delivery must also keep the DLL supplied inside their respective `Scripts` folders.

Start the game normally through Steam and follow each Mod's gameplay guide. The extension does not launch the game, edit saves or change UE4SS settings. It supports these UE4SS Lua Mod packages; it does not install PAK Mods or the loader itself.

#### Update, remove or switch installation methods

Close the game before changing Mods. For a Vortex-managed update, install the newer package, follow Vortex's replacement prompts, enable the intended version and deploy. To stop using a managed Mod, disable it and deploy; merely deleting its downloaded ZIP does not uninstall it.

If you already installed a Mod manually, first copy its existing folder out of the game as a backup. Keep only one active installation of that Mod: remove the manual copy from `ue4ss/Mods` before letting Vortex deploy the managed one. This extension does not import manual installations automatically. Back up `SmartDelivery/Scripts/delivery-preference.txt` before updating or migrating Smart Delivery and restore your saved preference after deployment. Keep UE4SS and unrelated Mods.

For a failed deployment, check Vortex's notification and staging-folder location. For a deployed Mod that does nothing in game, check the loader location, the Mod's folder and its host/guest requirements; then see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english).

### Build and verification

From the repository root:

```powershell
node --test vortex-extension/tests/*.test.js
python vortex-extension/build.py
```

The ZIP and SHA-256 file are written to ignored `outputs/vortex-extension/`. Packaging never installs the extension or mods. The archive includes original extension files and the MIT license only. `gameart.svg` is the original vector source for the bundled 640 × 360 PNG; it depicts a serving cloche and contains no game assets.

Installer tests check complete folders, multiple mods, native helpers, Windows paths, duplicate destinations and incomplete/unsafe packages. On 2026-10-05, Vortex 2.6.3 loaded the extension, detected the Steam installation and deployed all seven published LZH packages into an isolated test directory. All 76 deployed files matched the original ZIP contents byte for byte. This verifies installation, not gameplay; the actual game installation and saves were not modified.

[Source and support](https://github.com/martin-lzh/parisian-bistro-simulator-mods) · [Vortex extension documentation](https://github.com/Nexus-Mods/Vortex/wiki/LEGACY-General-Creating-a-game-extension)

## 中文

**版本 0.1.0。** 为 Vortex 添加《法式小馆儿模拟器》支持，安装 UE4SS Lua Mod 时保留完整的 Mod 文件夹。通过 Steam App ID `3058360` 查找游戏。这是 Vortex 游戏扩展，独立于七款游戏功能 Mod。

### 安装

**Vortex 是可选工具。** 七款 Mod 可按[手动安装指南](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/README.md#手动下载与安装)免费使用。**目前通过 Vortex 一键安装 [Nexus 合集](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz)仅限有效的 Nexus Premium 会员，普通免费注册账号不属于 Premium。** 免费用户可以从 Nexus 或 GitHub 逐个下载 Mod ZIP，手动安装或逐个导入 Vortex。Mod 本身免费。

**Vortex** 是管理 Mod 文件的软件；**游戏扩展**告诉它本游戏的文件应放在哪里；**UE4SS** 则是在游戏内运行 Mod 的加载器。安装合集前，三者都要准备好，Premium 也不能省略这些准备。不需要编程工具。

#### 1. 安装 Vortex 并登录

1. 退出游戏。打开 [Vortex 官方下载页](https://www.nexusmods.com/about/vortex/)，按页面下载入口取得 Windows 安装程序。如 Nexus 要求登录，登录或注册免费账号；免费用户选择 **Slow download（慢速下载）**。
2. 在浏览器下载列表中打开安装程序，按窗口提示完成安装，再从 Windows 开始菜单打开 **Vortex**。
3. 在 Vortex 点击 **Log In / Log In On Website（登录／在网站登录）**，在浏览器里登录准备用于下载的 Nexus 账号，并授权 Vortex。返回 Vortex，确认已经显示自己的用户名。Premium 用户须使用会员有效的那个账号。

#### 2. 添加本游戏扩展

1. 打开 [Parisian Bistro Simulator — Vortex Support 扩展页面](https://www.nexusmods.com/site/mods/2421)，进入 **Files（文件）**，手动下载 **0.1.0** 版本扩展 ZIP。保留 ZIP，不要解压到游戏目录。
2. 在 **Vortex → Home（主页）→ Extensions（扩展）**，点击 **Drop File(s)** 区域并选择刚下载的 ZIP，或从文件资源管理器的“下载”文件夹把 ZIP 拖入该区域。
3. 完成扩展安装，按提示重启 Vortex。此 ZIP 安装在 **Extensions**，不是游戏功能 Mod 的 **Mods** 页面。以后仅移除扩展，也不会移除已部署的游戏 Mod。

#### 3. 安装 UE4SS 加载器

扩展和合集不会自动下载或安装 UE4SS，Premium 用户也要完成以下步骤。若已经按下列结构装好 UE4SS，保留现有安装并核对版本即可。

1. **完全退出游戏。** 在 Steam 打开**库**，右键 **Parisian Bistro Simulator（法式小馆儿模拟器）→ 管理 → 浏览本地文件**。弹出的文件资源管理器窗口就是游戏目录，文件夹名可能是 **Parisian Brasserie Simulator**。不是“文档”或存档文件夹。
2. **打开安装位置。** 在该窗口依次双击 **BrasserieSimulator → Binaries → Win64**，应该能看到 **BrasserieSimulator-Win64-Shipping.exe**（Windows 可能隐藏 `.exe` 后缀）。保留此窗口，加载器就放在这里；不要放在最外层 `BrasserieSimulator.exe` 旁边。
3. **下载加载器。** 点击 [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip)，这是本项目核对过的 experimental 基础包。若直链失效，打开 [UE4SS experimental 发布页](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental)，展开 **Assets / Show all assets（附件／显示全部附件）**，找到这个完整文件名。不要下载 `zDEV`、`Source code`，也不要使用旧稳定版 `UE4SS_v3.0.1.zip`。其他 experimental 构建尚未核验。
4. **解压并放入加载器。** 在文件资源管理器的**下载**文件夹里，右键刚下载的 ZIP → **全部解压缩 → 提取**。打开解压后的文件夹，选中里面的 **dwmapi.dll** 和整个 **ue4ss** 文件夹，右键**复制**；回到游戏的 **Win64** 窗口，在空白处右键**粘贴**。复制这两个项目本身，不要把以压缩包命名的外层文件夹一起套进去。UE4SS 没有需要双击运行的安装程序。已经安装过加载器时，替换前备份其文件夹和设置，并保留现有 Mod。
5. **检查加载器位置。** **Win64** 中的 `dwmapi.dll` 应与 `BrasserieSimulator-Win64-Shipping.exe` 并排。打开 **ue4ss**，里面应有 **UE4SS.dll**、**UE4SS-settings.ini** 和 **Mods**。缺少这些内容时回到上一步重新解压、复制；只新建一个空的 `Mods` 文件夹不能装好加载器。

#### 4. 让 Vortex 找到游戏

1. 在 Vortex 打开 **Games（游戏）**，搜索 **Parisian Bistro Simulator**，点击 **Manage（管理）**。搜不到时回到 Extensions，检查本游戏扩展已安装、已启用，并重启 Vortex。
2. 自动查找失败时，再用 Steam 的**管理 → 浏览本地文件**找到游戏，然后在 Vortex 选择**这个游戏根目录**。它里面有 **BrasserieSimulator.exe** 和 **BrasserieSimulator** 文件夹。这里选择的不是 `Win64`、`ue4ss` 或 `Mods`。
3. 若提示 **Install UE4SS experimental first**，回到第 3 部分核对：所选游戏目录下必须有 `BrasserieSimulator/Binaries/Win64/ue4ss/UE4SS.dll` 和 `ue4ss/Mods`。
4. 若要求设置 **Mod Staging Folder（Mod 暂存文件夹）**，这是 Vortex 部署前保存工作副本的地方。请在游戏所在磁盘上选择另一个可写文件夹，例如游戏在 D 盘时使用 `D:\Vortex Mods\Parisian Bistro Simulator`，不要选择游戏里的 `Mods` 文件夹。如果提示选择部署方式，按 Vortex 建议应用。

#### 5. 下载、启用并部署 Mod

**Premium 合集路线：**用会员账号打开[合集](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz)，选择页面上的 Vortex 安装选项，允许浏览器打开 Vortex。按合集提示完成下载和安装，再在 Mods 页面检查所需 Mod 已启用；有待部署内容时点击 **Deploy Mods（部署 Mod）**。“一键安装”指完成准备后，合集可自动下载、安装；前置软件及过程中出现的提示仍须处理。

**逐个 ZIP 路线（免费）：**在各 Mod 的 Nexus 页面通过 **Files → Manual download → Slow download** 下载，或通过 [GitHub 版本链接](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/README.md#选择-mod)免登录下载。保留原始 ZIP。在 Vortex 选中本游戏，打开 **Mods → Install From File（从文件安装）**，选择一个 Mod ZIP，安装后设为 **Enabled（已启用）**。所需 Mod 分别操作完，再点 **Deploy Mods（部署 Mod）**。不要在这里导入 UE4SS ZIP 或 Vortex 游戏扩展 ZIP。

**部署**就是把启用的 Mod 文件复制／链接到游戏里，只有“已下载”或“已安装”还不够。部署后通过 Steam 打开游戏目录，依次进入 **BrasserieSimulator → Binaries → Win64 → ue4ss → Mods**。所选 Mod 的独立文件夹中应有 **Scripts/main.lua** 和 **enabled.txt**，例如 `Mods/BartendersNote/Scripts/main.lua`。菜单巧配和配送随心的 `Scripts` 内还必须保留各自随包提供的 DLL。

从 Steam 正常启动游戏，按各 Mod 的玩法说明使用。扩展不会启动游戏、修改存档或修改 UE4SS 设置，仅支持这些 UE4SS Lua Mod 安装包，不负责 PAK Mod 或加载器安装。

#### 更新、停用或切换安装方式

先关闭游戏。更新 Vortex 管理的 Mod 时，导入新版包、按 Vortex 提示替换，启用需要的版本后再部署。停用时在 Vortex 中禁用该 Mod 并部署；只删除下载的 ZIP 不等于卸载。

原来手动装过同一个 Mod 时，先把旧 Mod 文件夹复制到游戏目录外备份，再从 `ue4ss/Mods` 移除手动副本，让 Vortex 部署它管理的版本。同一个 Mod 只保留一份启用安装；本扩展不会自动接管手动文件。更新或迁移配送随心前，备份 `SmartDelivery/Scripts/delivery-preference.txt`，部署后恢复自己的偏好文件。保留加载器和其他 Mod。

部署失败时查看 Vortex 通知和暂存文件夹位置；部署成功但游戏内无效果时，核对加载器位置、Mod 目录和房主／客机要求，再看[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

### 构建与验证

在仓库根目录执行上方两条命令，运行 Node 安装器测试并生成扩展 ZIP。产物和 SHA-256 存入忽略的 `outputs/vortex-extension/`。打包不会安装扩展或 Mod，压缩包仅包含原创扩展文件与 MIT 许可。`gameart.svg` 是 640 × 360 PNG 图标的原创矢量源文件，图案为餐盘罩，不包含游戏资产。

离线测试覆盖目录结构、多个 Mod、辅助 DLL、Windows 路径、重复目标及不完整／不安全的压缩包。2026-10-05 已在 Vortex 2.6.3 中加载扩展、确认 Steam 游戏检测，并将七个已发布的 LZH 安装包部署到隔离测试目录；全部 76 个文件与原 ZIP 逐字节一致。此验证仅覆盖安装，不等于实机验收；实际游戏安装目录和存档未被修改。
