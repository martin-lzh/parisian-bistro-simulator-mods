# Bartender's Note / 调饮手记

[![Bartender's Note / 调饮手记 — AI-generated cover / AI 宣传封面](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/bartenders-note-mod/assets/cover.png?raw=1)](https://www.nexusmods.com/mods/1?game_id=10352)

[English](#english) · [中文](#中文)

## English

See your claimed, unfinished drinks below the restaurant name. Repeated orders are grouped, such as `Espresso x 10 · Lemonade x 3`.

**Version: 0.1.2.** Single player, multiplayer host or guest. Install it on each player's computer that wants the display; each sees only their own claimed orders.

### How to use

1. Enter your restaurant and open the game's tablet using its on-screen prompt or your configured control.
2. Open the drink order list and use the game's existing claim action on the drinks you intend to make. Orders must be claimed by **you**; unclaimed orders and another player's claims do not appear in your note.
3. Close the tablet. The note appears automatically below the restaurant name when you have at least one unfinished claimed drink. It adds no button, shortcut or settings menu.
4. Prepare those drinks using the game's normal equipment and interactions. Both waiting and currently preparing drinks count. A drink leaves the note when preparation finishes, even if it is still on the counter waiting to be collected or served.
5. To change what you are working on, return to the tablet's order list and use the existing claim or unclaim controls. The note also updates when the game cancels an order; it hides after the last matching drink is finished, unclaimed or canceled.

### Reading the note

- Repeated drinks share one count: `Espresso x 10` means ten unfinished claimed orders of that drink. It is not an ingredient or prepared-stock count.
- The note uses at most two lines. “... + N more” counts hidden **drink types**, not cups; a name that is too long to fit may also be included. Reopen the tablet to inspect the full order list.
- The note follows the visibility of the restaurant name bar. If a tablet or other full-screen interface hides that bar, close the interface to see the note again. Language and window-size changes update the layout automatically.
- The note is a display only: it does not claim orders, make drinks, collect them or deliver them. Its text does not take mouse, keyboard or controller input. Use the game's normal controls for those actions.

In multiplayer, each installed copy reads that player's own claims. The host does not need the Mod for a guest to use their own display, and installing it only on the host does not give guests a note. To stop using the display, remove the Mod with the game closed as described below; there is no in-game toggle.

### Requirements

Windows x64 Parisian Bistro Simulator and **UE4SS experimental**. The checked loader build is `v3.0.1-1140-gf58e8f84`; stable UE4SS 3.0.1 is not supported. Other loader builds have not been verified. UE4SS is installed separately.

### Download

Choose **one** download source; both provide the same Mod:

- **GitHub (no account needed):** open [Bartender's Note 0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/bartenders-note-v0.1.2), scroll to **Assets**, expand it if needed and click **BartendersNote-0.1.2.zip**. `SHA256SUMS.txt` is an optional checksum file, not something to install. Do not choose **Source code**.
- **Nexus:** open the [Mod page](https://www.nexusmods.com/parisianbistrosimulator/mods/1), sign in or register a free account, select **Files → Main files → Manual download** for version **0.1.2**. Continue through the requirements notice if shown, select **Slow download** for a free account and wait for the ZIP. Keep the ZIP in your **Downloads** folder until the extraction step below.

### Install

These instructions start with only the Windows game installed. **Manual installation is free and does not require Vortex or a Nexus Premium subscription.** A web browser and Windows File Explorer are enough; Windows can extract ZIP files without WinRAR or 7-Zip. You do not need Git, Python, Visual Studio or Unreal Engine.

UE4SS is the **mod loader**: it starts the Mod when the game starts. Install it once for this game, then add any of the seven Mods to its `Mods` folder. Vortex is an optional **mod manager**, which copies and removes Mod files for you; it does not replace UE4SS.

1. **Exit the game completely.** In Steam, open **Library**, right-click **Parisian Bistro Simulator**, then choose **Manage → Browse local files**. The File Explorer window that opens is your game folder. Its name may be **Parisian Brasserie Simulator**. Do not use Documents or the save folder.
2. **Open the installation destination.** In that window, double-click **BrasserieSimulator**, then **Binaries**, then **Win64**. You should see **BrasserieSimulator-Win64-Shipping.exe** (Windows may hide `.exe`). Keep this window open. This is where the loader goes; do not put the loader beside the top-level `BrasserieSimulator.exe`.
3. **Download the loader.** Use [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip), the basic experimental build used as this project's reference. If the direct link fails, open [UE4SS experimental releases](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental), expand **Assets / Show all assets** and find that exact filename. Do not choose `zDEV`, `Source code` or the old stable `UE4SS_v3.0.1.zip`. Other experimental builds have not been verified for these Mods.
4. **Extract the loader ZIP.** In File Explorer's **Downloads** folder, right-click the downloaded ZIP → **Extract All… → Extract**. Open the extracted folder. Inside it, select **dwmapi.dll** and the entire **ue4ss** folder, right-click → **Copy**; return to the game's **Win64** window, right-click empty space → **Paste**. Copy both items themselves, not the outer folder named after the ZIP. There is no UE4SS installer to run. If you already have UE4SS installed, back up its folder and settings before replacing anything; keep your existing Mods.
5. **Check the loader location.** In **Win64**, `dwmapi.dll` must sit beside `BrasserieSimulator-Win64-Shipping.exe`. Open **ue4ss**: it must contain **UE4SS.dll**, **UE4SS-settings.ini** and **Mods**. If these are missing, repeat the extraction/copy step; an empty folder named `Mods` alone does not install the loader.
6. **Extract the Mod ZIP** downloaded above: right-click it → **Extract All… → Extract**. Open the extracted folder until you can see **BartendersNote**, the folder that contains **Scripts** and **enabled.txt**. Windows may show `enabled` without `.txt`; that is normal.
7. **Copy the whole BartendersNote folder.** Right-click it → **Copy**. In the game window, open **Win64 → ue4ss → Mods**, right-click empty space → **Paste**. Do not copy only `main.lua`, and do not place the ZIP itself in `Mods`.
8. **Check the result.** Open **Mods → BartendersNote → Scripts**: **main.lua** must be there. Go back once to **BartendersNote**: **enabled.txt** must be there beside **Scripts**. An extra `BartendersNote/BartendersNote` layer is incorrect. Leave `enabled.txt` as supplied, even if it is empty; it enables the Mod. Do not replace the loader's `mods.txt`.
9. **Start the game normally through Steam** and follow **How to use** above. Some Mods run in the background and have no startup message. Check the single-player/host/guest requirement at the top of this guide; the host is the player who opens the multiplayer restaurant for others to join.

The final entry point is `BrasserieSimulator/Binaries/Win64/ue4ss/Mods/BartendersNote/Scripts/main.lua`, starting from the Steam game folder. If the feature does not work, close the game, recheck the two folder layouts above, then open `Win64/ue4ss/UE4SS.log` with Notepad and look for a recent timestamp or an error. See [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) before reinstalling.

**Using Vortex instead:** follow the [Vortex setup guide](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#english) to install Vortex, this game's extension and UE4SS first. Then import the original Mod ZIP, install, enable and deploy it. Use one installation method for this Mod. **The [collection](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz) currently requires an active Nexus Premium membership for one-click installation.** A free Nexus account or GitHub download can still be used for individual Mods; GitHub downloads need no account.

### Update or remove

**Update:** close the game, download and extract the new Mod ZIP, then copy its complete `BartendersNote` folder into the same `Mods` folder and replace matching files. Start the game again.

**Remove:** close the game and delete only `Mods/BartendersNote`. Leave UE4SS and other Mods in place. Removing the Mod removes only the display; your orders and save need no cleanup.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload). This is not required for normal installation or updates.

### Languages and help

Follows the game language automatically, with no separate setting or language pack. Drink names use the game's translations. Missing names use a translated drink label and item number; unsupported languages fall back to English. Technical logs remain English.

Game languages: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese.

If the note is missing, confirm the drink is still waiting or preparing and is claimed by your own player, then close any screen that hides the restaurant name bar. Allow a short refresh after changing an order; a completed drink is correctly absent even before delivery. Widen an unusually narrow game window. During loading or a temporarily unavailable order list, the note hides old counts and returns when current data is available. If it stays missing, use the help link below and include relevant `[Bartender's Note]` lines from `UE4SS.log`.

In-game and multiplayer testing passed as reported by the maintainer on 2026-09-26; the [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/bartenders-note-v0.1.2/releases/validation.md#english) describes its scope.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/bartenders-note-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) · [MIT License](LICENSE)

## 中文

在餐厅名称下显示自己认领且尚未做完的饮料，同类订单合并计数，例如“浓缩咖啡 x 10 · 柠檬水 x 3”。

**版本：0.1.2。** 单人、联机房主和客机均可使用。想看到清单的玩家在自己的电脑安装，各自只显示自己的认领订单。

### 怎么使用

1. 进入餐厅，按游戏屏幕上的提示或自己设置的操作键打开平板。
2. 进入饮料订单列表，使用游戏原有的认领操作，认领准备制作的饮料。必须是**自己认领**的订单；未认领的订单和其他玩家认领的订单不会出现在自己的手记中。
3. 关闭平板。只要有尚未做完的认领饮料，手记就会自动出现在餐厅名称下，无需额外按钮、快捷键或设置。
4. 按游戏原有操作使用设备制作饮料。等待制作和正在制作的饮料都会计入；制作完成后便从手记中移除，即使成品仍在台面上、尚未拿取或送给顾客。
5. 需要调整负责的饮料时，回到平板订单列表使用原有的认领或取消认领操作。订单被游戏取消时，手记也会自动更新；最后一份符合条件的饮料完成、取消认领或被取消后，清单自动隐藏。

### 怎么看手记

- 同种饮料合并数量：“浓缩咖啡 x 10”表示自己认领且尚未做完的十份浓缩咖啡订单，不是原料库存或已做好的成品数量。
- 最多显示两行。“另有 N 种”表示隐藏的**饮料种类**，不是杯数；名称过长而无法放入的饮料也可能计入。需要查看完整订单时重新打开平板。
- 手记跟随餐厅名称条显示。平板或其他全屏界面隐藏名称条时，关闭对应界面即可再次查看；切换游戏语言或窗口尺寸后会自动调整布局。
- 手记只负责显示，不会自动认领、制作、拿取或配送饮料。文字区域不接收鼠标、键盘或手柄输入，实际操作继续使用游戏原有控件。

联机时，每位安装玩家只读取自己的认领清单。客机使用自己的手记不要求房主安装；只在房主安装也不会让客机看到手记。没有游戏内开关，需要停用时按下方说明关闭游戏并卸载。

### 使用要求

Windows x64 版 Parisian Bistro Simulator，以及 **UE4SS experimental**。已核对的加载器版本为 `v3.0.1-1140-gf58e8f84`，不支持旧稳定版 UE4SS 3.0.1；其他加载器版本尚未验证。UE4SS 需单独安装。

### 下载

以下来源**二选一**即可，提供的是同一个 Mod：

- **GitHub（无需账号）：**打开 [调饮手记 0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/bartenders-note-v0.1.2)，向下找到并展开 **Assets（附件）**，点击 **BartendersNote-0.1.2.zip**。`SHA256SUMS.txt` 是可选的校验文件，无需安装；不要下载 **Source code（源码）**。
- **Nexus：**打开 [Mod 页面](https://www.nexusmods.com/parisianbistrosimulator/mods/1)，登录或注册免费账号，在 **Files（文件）→ Main files（主要文件）** 找到 **0.1.2**，点击 **Manual download（手动下载）**。如出现前置要求提示，继续到下载页；免费账号选择 **Slow download（慢速下载）**，等待 ZIP 下载完成。先把 ZIP 保存在**下载**文件夹，下面再解压。

### 安装

以下步骤从电脑上只安装了 Windows 版游戏开始。**手动安装免费，不需要 Vortex，也不需要 Nexus Premium 会员。** 用浏览器和 Windows 文件资源管理器即可操作；Windows 自带 ZIP 解压功能，无需安装 WinRAR 或 7-Zip，也不需要 Git、Python、Visual Studio 或虚幻引擎。

UE4SS 是**加载器**，作用是在启动游戏时运行 Mod。每个游戏安装目录只需装一次，之后把所需 Mod 加入它的 `Mods` 文件夹即可。Vortex 是可选的 **Mod 管理器**，负责复制和移除 Mod 文件，不能代替 UE4SS。

1. **完全退出游戏。** 在 Steam 打开**库**，右键 **Parisian Bistro Simulator（法式小馆儿模拟器）→ 管理 → 浏览本地文件**。弹出的文件资源管理器窗口就是游戏目录，文件夹名可能是 **Parisian Brasserie Simulator**。不是“文档”或存档文件夹。
2. **打开安装位置。** 在该窗口依次双击 **BrasserieSimulator → Binaries → Win64**，应该能看到 **BrasserieSimulator-Win64-Shipping.exe**（Windows 可能隐藏 `.exe` 后缀）。保留此窗口，加载器就放在这里；不要放在最外层 `BrasserieSimulator.exe` 旁边。
3. **下载加载器。** 点击 [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip)，这是本项目核对过的 experimental 基础包。若直链失效，打开 [UE4SS experimental 发布页](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental)，展开 **Assets / Show all assets（附件／显示全部附件）**，找到这个完整文件名。不要下载 `zDEV`、`Source code`，也不要使用旧稳定版 `UE4SS_v3.0.1.zip`。其他 experimental 构建尚未核验。
4. **解压并放入加载器。** 在文件资源管理器的**下载**文件夹里，右键刚下载的 ZIP → **全部解压缩 → 提取**。打开解压后的文件夹，选中里面的 **dwmapi.dll** 和整个 **ue4ss** 文件夹，右键**复制**；回到游戏的 **Win64** 窗口，在空白处右键**粘贴**。复制这两个项目本身，不要把以压缩包命名的外层文件夹一起套进去。UE4SS 没有需要双击运行的安装程序。已经安装过加载器时，替换前备份其文件夹和设置，并保留现有 Mod。
5. **检查加载器位置。** **Win64** 中的 `dwmapi.dll` 应与 `BrasserieSimulator-Win64-Shipping.exe` 并排。打开 **ue4ss**，里面应有 **UE4SS.dll**、**UE4SS-settings.ini** 和 **Mods**。缺少这些内容时回到上一步重新解压、复制；只新建一个空的 `Mods` 文件夹不能装好加载器。
6. **解压上面下载的 Mod ZIP。** 右键 ZIP → **全部解压缩 → 提取**。打开解压后的文件夹，找到 **BartendersNote** 文件夹；它里面应有 **Scripts** 和 **enabled.txt**。Windows 可能只显示 `enabled` 而隐藏 `.txt`，属于正常情况。
7. **复制整个 BartendersNote 文件夹。** 右键它 → **复制**。在游戏窗口打开 **Win64 → ue4ss → Mods**，在空白处右键**粘贴**。不要只复制 `main.lua`，也不要把 ZIP 本身放进去。
8. **检查安装结果。** 依次打开 **Mods → BartendersNote → Scripts**，应能看到 **main.lua**；返回一层到 **BartendersNote**，应能看到与 **Scripts** 并排的 **enabled.txt**。不要多套成 `BartendersNote/BartendersNote`。即使 `enabled.txt` 是空文件也应原样保留，它用于启用 Mod；不要替换加载器的 `mods.txt`。
9. **从 Steam 正常启动游戏**，按上方“怎么使用”操作。有的 Mod 在后台工作，没有启动提示。先核对本说明开头的单人／房主／客机要求；房主指开启联机餐厅、让其他人加入的玩家。

从 Steam 打开的游戏目录算起，最终脚本位置是 `BrasserieSimulator/Binaries/Win64/ue4ss/Mods/BartendersNote/Scripts/main.lua`。功能未生效时，先退出游戏、核对上述加载器和 Mod 两处目录，再用记事本打开 `Win64/ue4ss/UE4SS.log`，查看有没有本次运行的时间或错误。重装前可查看[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

**如果选择 Vortex：** 先按 [Vortex 安装说明](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#中文)装好 Vortex、本游戏扩展和 UE4SS，再导入原始 Mod ZIP，安装、启用并部署。同一个 Mod 只使用一种安装方式。**目前通过 [Nexus 合集](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz)一键安装需要有效的 Nexus Premium 会员。** 免费 Nexus 账号仍可逐个下载 Mod；GitHub 下载无需账号。

### 更新与卸载

**更新：** 关闭游戏，下载并解压新版 Mod ZIP，把完整的 `BartendersNote` 文件夹复制到原来的 `Mods` 目录并覆盖同名文件，再启动游戏。

**卸载：** 关闭游戏，只删除 `Mods/BartendersNote`，保留 UE4SS 和其他 Mod。卸载仅移除显示，不需要清理订单或存档。

可选操作：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。正常安装和更新不需要此操作。

### 语言与帮助

自动跟随游戏语言，无需设置或安装语言包。饮料名沿用游戏译文；名称不可用时显示本地化饮料标签和编号，不支持的语言回退英语。技术日志保持英文。

游戏语言包括英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。

手记未出现时，先确认饮料仍在等待或制作中，且由自己的角色认领，再关闭会隐藏餐厅名称条的界面。改变订单后等待短暂刷新；饮料已经做完时，即使还没送出，也应从手记移除。游戏窗口过窄时请加宽。加载中或订单数据暂时不可用时会隐藏旧数量，数据恢复后自动重新显示。仍未恢复时，按下方反馈说明提供 `UE4SS.log` 中相关的 `[Bartender's Note]` 日志。

维护者于 2026-09-26 确认实机及联机测试全部通过并授权正式发布，具体范围见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/bartenders-note-v0.1.2/releases/validation.md#中文)。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/bartenders-note-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文) · [MIT 许可证](LICENSE)
