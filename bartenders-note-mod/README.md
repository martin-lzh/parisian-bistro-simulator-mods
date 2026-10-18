# Bartender's Note / 调饮手记

[![Bartender's Note / 调饮手记 — AI-generated cover / AI 宣传封面](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/bartenders-note-mod/assets/cover.png?raw=1)](https://www.nexusmods.com/mods/1?game_id=10352)

[English](#english) · [中文](#中文)

## English

See the drinks you have claimed but not yet made, right below the restaurant name. Repeated orders are grouped, such as `Espresso x 10 · Lemonade x 3`.

**Version: 0.1.2.** Works in single player and for both the multiplayer host and guests. Each player who wants the note installs it on their own computer and sees only their own claimed orders.

### How to use

1. Enter your restaurant and open the game's tablet.
2. Open the drink order list and claim the drinks you plan to make, using the game's usual claim action. Only drinks claimed by **you** appear in your note.
3. Close the tablet. The note appears below the restaurant name whenever you have at least one claimed drink left to make. There is no button, shortcut or settings menu.
4. Make the drinks as usual. Drinks that are waiting and drinks being prepared both count. A drink leaves the note as soon as it is finished, even if it is still on the counter waiting to be served.
5. To change what you are working on, claim or unclaim orders in the tablet's order list. The note also updates when the game cancels an order, and hides once your last claimed drink is finished, unclaimed or canceled.

### Reading the note

- `Espresso x 10` means ten claimed espresso orders still to make. It is an order count, not stock.
- The note uses at most two lines. `... + N more` counts hidden **drink types**, not cups; a name too long to fit is also counted there. Open the tablet to see the full list.
- The note appears and hides together with the restaurant name bar. If the tablet or another full-screen menu covers the bar, close it to see the note again. The layout adjusts automatically when you change language or window size.
- The note only displays orders. Claim, make and serve drinks with the game's normal controls; the note doesn't react to mouse, keyboard or controller input.

In multiplayer, each player's note shows their own claims. Guests can use the note even if the host doesn't have it; installing it only on the host doesn't give guests a note. There is no in-game toggle; to turn the note off, remove the Mod (see **Update or remove**).

### Requirements

- Windows version of Parisian Bistro Simulator, up to game version 1.0.2.44eb (Steam Build 25822788).
- [UE4SS experimental](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental) `v3.0.1-1140-gf58e8f84`, installed separately (see **Install**). The older stable UE4SS 3.0.1 does not work.

### Download

Pick either source; both have the same file.

- **GitHub (no account needed):** open [Bartender's Note 0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/bartenders-note-v0.1.2) and download **BartendersNote-0.1.2.zip** under **Assets**. Don't pick **Source code**.
- **Nexus:** open the [Mod page](https://www.nexusmods.com/parisianbistrosimulator/mods/1), go to **Files → Main files → Manual download**, then choose **Slow download** if you have a free account.

### Install

Manual installation is free and needs neither Vortex nor Nexus Premium.

UE4SS is the mod loader that runs Mods when the game starts. Install it once, then put Mods in its `Mods` folder. If UE4SS is already installed, start at step 6.

1. **Close the game.** In Steam, open **Library**, right-click **Parisian Bistro Simulator** → **Manage → Browse local files**. This opens the game folder (it may be named **Parisian Brasserie Simulator**).
2. **Open BrasserieSimulator → Binaries → Win64.** You should see **BrasserieSimulator-Win64-Shipping.exe** (Windows may hide the `.exe`). Keep this window open; the loader goes here.
3. **Download UE4SS:** [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip). If the link doesn't open, find that exact file under **Assets** on the [UE4SS experimental release page](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental). Don't use `zDEV`, `Source code` or the old stable `UE4SS_v3.0.1.zip`.
4. **Copy the loader into Win64.** Right-click the ZIP → **Extract All… → Extract**. From the extracted folder, copy **dwmapi.dll** and the **ue4ss** folder and paste both into **Win64**. If you are replacing an existing UE4SS, back up its folder first.
5. **Check the loader:** `dwmapi.dll` sits next to `BrasserieSimulator-Win64-Shipping.exe`, and the **ue4ss** folder contains **UE4SS.dll**, **UE4SS-settings.ini** and **Mods**.
6. **Extract the Mod ZIP** and open it until you see the **BartendersNote** folder, which contains **Scripts** and **enabled.txt**.
7. **Copy the whole BartendersNote folder** into **Win64 → ue4ss → Mods**.
8. **Check the Mod:** `Mods/BartendersNote/Scripts/main.lua` and `Mods/BartendersNote/enabled.txt` should exist (not `BartendersNote/BartendersNote`). Keep `enabled.txt` even if it is empty.
9. **Start the game through Steam** and follow **How to use** above.

If the Mod doesn't work, close the game, recheck steps 5 and 8, then see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english).

**Using Vortex instead:** set up Vortex, the game extension and UE4SS with the [Vortex guide](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#english), then import the Mod ZIP, enable it and deploy. Install each Mod either with Vortex or manually, not both. One-click install of the [collection](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz) requires Nexus Premium.

### Update or remove

**Update:** close the game, extract the new Mod ZIP and copy its whole `BartendersNote` folder into the same `Mods` folder, replacing existing files.

**Remove:** close the game and delete only `Mods/BartendersNote`. Leave UE4SS and other Mods in place. Your orders and save need no cleanup.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload).

### Languages and help

The note follows the game language automatically: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese. Drink names use the game's own translations; if a name is missing, the note shows a drink label with its item number.

If the note is missing:

- Check that the drink is still waiting or being prepared and is claimed by you.
- Close any menu that hides the restaurant name bar.
- Wait a moment after changing an order.
- Widen the game window if it is very narrow.
- While a game is loading, the note hides and comes back once the orders are available again.

If it still doesn't appear, ask for [help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) and include the `[Bartender's Note]` lines from `Win64/ue4ss/UE4SS.log`.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/bartenders-note-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) · [PolyForm Noncommercial License 1.0.0](LICENSE)

## 中文

在餐厅名称下方显示自己认领但还没做的饮料，同类订单合并计数，例如“浓缩咖啡 x 10 · 柠檬水 x 3”。

**版本：0.1.2。** 单人、联机房主和客机均可使用。想看手记的玩家在自己电脑上安装，各自只显示自己认领的订单。

### 怎么使用

1. 进入餐厅，打开游戏里的平板。
2. 进入饮料订单列表，用游戏原有的认领操作认领准备制作的饮料。只有**自己认领**的饮料会出现在手记里。
3. 关闭平板。只要还有没做完的认领饮料，手记就会自动出现在餐厅名称下方，不需要按钮、快捷键或设置。
4. 照常制作饮料。等待制作和正在制作的都会计入；一做完就从手记中移除，即使成品还在台面上没送出。
5. 想调整负责的饮料，回到平板订单列表认领或取消认领即可。游戏取消订单时手记也会更新；最后一份认领饮料做完、取消认领或被取消后，手记自动隐藏。

### 怎么看手记

- “浓缩咖啡 x 10”表示还有十份认领的浓缩咖啡订单没做，是订单数，不是库存。
- 最多显示两行。“另有 N 种”指隐藏的**饮料种类**，不是杯数；名称太长放不下的饮料也算在里面。想看完整订单就打开平板。
- 手记随餐厅名称条一起显示和隐藏。平板或其他全屏界面挡住名称条时，关掉界面就能再看到。切换语言或调整窗口大小后，排版自动调整。
- 手记只负责显示。认领、制作和上餐都用游戏原有操作；手记不响应鼠标、键盘或手柄。

联机时，每位玩家的手记只显示自己的认领。房主没装也不影响客机使用；只有房主安装时，客机看不到手记。游戏内没有开关，不想用时按“更新与卸载”移除 Mod。

### 使用要求

- Windows 版 Parisian Bistro Simulator，支持至游戏版本 1.0.2.44eb（Steam Build 25822788）。
- [UE4SS experimental](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental) `v3.0.1-1140-gf58e8f84`，需单独安装（见“安装”）。旧稳定版 UE4SS 3.0.1 无法使用。

### 下载

以下两个来源任选其一，文件相同。

- **GitHub（无需账号）：**打开 [调饮手记 0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/bartenders-note-v0.1.2)，在 **Assets（附件）** 下载 **BartendersNote-0.1.2.zip**。不要选 **Source code（源码）**。
- **Nexus：**打开 [Mod 页面](https://www.nexusmods.com/parisianbistrosimulator/mods/1)，进入 **Files（文件）→ Main files（主要文件）→ Manual download（手动下载）**；免费账号选择 **Slow download（慢速下载）**。

### 安装

手动安装免费，不需要 Vortex，也不需要 Nexus Premium。

UE4SS 是 Mod 加载器，负责在游戏启动时运行 Mod。只需安装一次，之后把 Mod 放进它的 `Mods` 文件夹。已经装好 UE4SS 的，从第 6 步开始。

1. **退出游戏。** 在 Steam **库**中右键 **Parisian Bistro Simulator（法式小馆儿模拟器）→ 管理 → 浏览本地文件**，打开游戏目录（文件夹名可能是 **Parisian Brasserie Simulator**）。
2. **依次打开 BrasserieSimulator → Binaries → Win64**，能看到 **BrasserieSimulator-Win64-Shipping.exe**（Windows 可能隐藏 `.exe` 后缀）。保持这个窗口打开，加载器就装在这里。
3. **下载 UE4SS：**[UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip)。链接打不开时，到 [UE4SS experimental 发布页](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental)的 **Assets** 中找同名文件。不要下载 `zDEV`、`Source code` 或旧稳定版 `UE4SS_v3.0.1.zip`。
4. **把加载器放进 Win64。** 右键 ZIP → **全部解压缩 → 提取**，从解压出的文件夹中复制 **dwmapi.dll** 和 **ue4ss** 文件夹，粘贴到 **Win64**。替换已有的 UE4SS 前，先备份原文件夹。
5. **检查加载器：**`dwmapi.dll` 与 `BrasserieSimulator-Win64-Shipping.exe` 在同一层；**ue4ss** 文件夹里有 **UE4SS.dll**、**UE4SS-settings.ini** 和 **Mods**。
6. **解压 Mod ZIP**，打开到能看到 **BartendersNote** 文件夹，里面有 **Scripts** 和 **enabled.txt**。
7. **把整个 BartendersNote 文件夹**复制到 **Win64 → ue4ss → Mods**。
8. **检查 Mod：**应有 `Mods/BartendersNote/Scripts/main.lua` 和 `Mods/BartendersNote/enabled.txt`（不要多套一层 `BartendersNote/BartendersNote`）。`enabled.txt` 即使是空文件也要保留。
9. **从 Steam 启动游戏**，按上方“怎么使用”操作。

不生效时，先退出游戏，核对第 5、8 步，再查看[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

**改用 Vortex：**先按 [Vortex 安装说明](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#中文)装好 Vortex、游戏扩展和 UE4SS，再导入 Mod ZIP，启用并部署。同一个 Mod 只用 Vortex 或手动其中一种方式安装。通过 [Nexus 合集](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz)一键安装需要 Nexus Premium。

### 更新与卸载

**更新：**关闭游戏，解压新版 Mod ZIP，把完整的 `BartendersNote` 文件夹复制到原来的 `Mods` 文件夹并覆盖同名文件。

**卸载：**关闭游戏，只删除 `Mods/BartendersNote`，保留 UE4SS 和其他 Mod。订单和存档无需清理。

可选：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。

### 语言与帮助

手记自动跟随游戏语言：英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。饮料名使用游戏自带译名；缺少译名时显示饮料标签加编号。

手记没出现时：

- 确认饮料仍在等待或制作中，并且是自己认领的。
- 关闭挡住餐厅名称条的界面。
- 改动订单后稍等片刻。
- 游戏窗口太窄时把它拉宽。
- 游戏加载期间手记会暂时隐藏，订单恢复后自动重新显示。

仍然不显示时，查看[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)，并附上 `Win64/ue4ss/UE4SS.log` 中带 `[Bartender's Note]` 的日志行。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/bartenders-note-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文) · [PolyForm Noncommercial 1.0.0 许可](LICENSE)
