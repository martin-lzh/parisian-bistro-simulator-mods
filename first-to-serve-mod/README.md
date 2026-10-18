# First to Serve / 出餐有序

[![First to Serve / 出餐有序 — AI-generated cover / AI 宣传封面](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/first-to-serve-mod/assets/cover.png?raw=1)](https://www.nexusmods.com/mods/6?game_id=10352)

[English](#english) · [中文](#中文)

## English

Hold the interaction key at a kitchen pass or drink output area to collect the oldest ready items onto your tray or food trolley.

**Version: 0.1.8.** Works in single player and for multiplayer hosts and guests. Only players who want the hold action need to install it.

### How to use

1. Equip a tray, or grab a **food trolley** and push it. Leave at least one free slot for the kind of item you want.
2. Stand within normal pickup range and aim at the kitchen pass's pickup area, the drink output surface, or a ready dish or full drink there. Nearby furniture and cups still at the preparation equipment don't start pickup.
3. Hold the interaction key: left mouse button by default, or whatever you have bound on keyboard or controller. When pickup is possible, **Hold: take oldest first** appears with the normal pickup hint, in the game's language.
4. Keep holding to collect items one at a time. The oldest item at that source comes first, even if you are aiming at a newer one.
5. Release when you have enough, then carry and serve as usual. The Mod only handles pickup; unloading, putting down the tray or trolley and serving customers work as normal.

A short press does the normal game action. There are no settings and no extra hotkeys. With a tray or food trolley at a supported source, a long hold collects items instead of opening the interaction wheel.

### Which items are collected

Items are taken in the order they were made, oldest first. Customer order time, counter position and food quality don't change the order. Normal capacity and pickup range apply, and the game picks the slot each item goes into.

| Situation | What happens |
| --- | --- |
| Kitchen pass, or a ready dish there | Collects ready dishes on your floor and within reach. |
| Drink output surface, or a full drink there | Collects full drinks from that drink area. Each hold takes from one drink area only. |
| Dirty, served, being eaten, being picked up or already carried items; unfinished drinks | Skipped. Items on other floors or out of reach are skipped too. |
| Tray or food trolley with only a drink-only slot free | Drinks can go there; food needs a normal free slot. |
| Food trolley with a stack of dirty plates | Gaps in the stack don't count as space. The stack slot must be completely empty before food or drinks can go there. |
| Tower burger on a food trolley | Needs a free top slot. If an older burger doesn't fit, a newer dish may be taken first. |
| Parked food trolley, storage cart, or no tray equipped | The hold does nothing. You must be holding the tray or pushing the food trolley yourself. |

### Stop and start another pickup

You can sweep the crosshair across the same output area without aiming at each item. After the aimed item is taken, small camera or player movement is fine, so pickup keeps going over its empty spot. Looking away, walking away or aiming at a different source stops the hold.

Pickup also stops when you release the key, change or put down the tray or trolley, open a menu, the interaction wheel or multiplayer chat, enter placement mode, or pause. Items you already collected stay on the tray or trolley.

Pickup stops when all suitable slots are full. After making room, going back to the source or switching carriers, **release and hold again**; keeping the key held won't restart it. An empty output area can't start a hold. If an item isn't picked up within two seconds, the hold stops; release, check your free slots and aim, then try again.

### Multiplayer

Host and guests use the same controls. Each player who wants the hold action installs the Mod on their own computer; the host doesn't need it for a guest to use it. Each copy only controls its own player's tray or trolley. If another player takes an item first, or the connection lags, the sequence may stop early.

### In-game screenshots

Tray pickup at the kitchen pass.

![Gameplay animation of tray pickup at the kitchen pass](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/first-to-serve-mod/assets/kitchen-pass-gameplay.gif?raw=1)

[Open animation (GIF, 5.13 MiB)](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/first-to-serve-mod/assets/kitchen-pass-gameplay.gif?raw=1)

With a tray at the kitchen pass, the hold hint appears above **Take the dish**.

![Tray at the kitchen pass showing Hold: take oldest first and Take the dish](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/first-to-serve-mod/assets/kitchen-pass-gameplay.png?raw=1)

With a tray at the drink output area, the same hint appears above **Take drinks**.

![Tray at the drink output area showing Hold: take oldest first and Take drinks](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/first-to-serve-mod/assets/drink-output-gameplay.png?raw=1)

### Requirements

- Windows version of Parisian Bistro Simulator, up to game version 1.0.2.44eb (Steam Build 25822788).
- [UE4SS experimental](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental) `v3.0.1-1140-gf58e8f84`, installed separately (see **Install**). The older stable UE4SS 3.0.1 does not work.

### Download

Pick either source; both have the same file.

- **GitHub (no account needed):** open [First to Serve 0.1.8](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/first-to-serve-v0.1.8) and download **FirstToServe-0.1.8.zip** under **Assets**. Don't pick **Source code**.
- **Nexus:** open the [Mod page](https://www.nexusmods.com/parisianbistrosimulator/mods/6), go to **Files → Main files → Manual download**, then choose **Slow download** if you have a free account.

### Install

Manual installation is free and needs neither Vortex nor Nexus Premium.

UE4SS is the mod loader that runs Mods when the game starts. Install it once, then put Mods in its `Mods` folder. If UE4SS is already installed, start at step 6.

1. **Close the game.** In Steam, open **Library**, right-click **Parisian Bistro Simulator** → **Manage → Browse local files**. This opens the game folder (it may be named **Parisian Brasserie Simulator**).
2. **Open BrasserieSimulator → Binaries → Win64.** You should see **BrasserieSimulator-Win64-Shipping.exe** (Windows may hide the `.exe`). Keep this window open; the loader goes here.
3. **Download UE4SS:** [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip). If the link doesn't open, find that exact file under **Assets** on the [UE4SS experimental release page](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental). Don't use `zDEV`, `Source code` or the old stable `UE4SS_v3.0.1.zip`.
4. **Copy the loader into Win64.** Right-click the ZIP → **Extract All… → Extract**. From the extracted folder, copy **dwmapi.dll** and the **ue4ss** folder and paste both into **Win64**. If you are replacing an existing UE4SS, back up its folder first.
5. **Check the loader:** `dwmapi.dll` sits next to `BrasserieSimulator-Win64-Shipping.exe`, and the **ue4ss** folder contains **UE4SS.dll**, **UE4SS-settings.ini** and **Mods**.
6. **Extract the Mod ZIP** and open it until you see the **FirstToServe** folder, which contains **Scripts** and **enabled.txt**.
7. **Copy the whole FirstToServe folder** into **Win64 → ue4ss → Mods**.
8. **Check the Mod:** `Mods/FirstToServe/Scripts/main.lua` and `Mods/FirstToServe/enabled.txt` should exist (not `FirstToServe/FirstToServe`). Keep `enabled.txt` even if it is empty.
9. **Start the game through Steam** and follow **How to use** above.

If the Mod doesn't work, close the game, recheck steps 5 and 8, then see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english).

**Using Vortex instead:** set up Vortex, the game extension and UE4SS with the [Vortex guide](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#english), then import the Mod ZIP, enable it and deploy. Install each Mod either with Vortex or manually, not both. One-click install of the [collection](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz) requires Nexus Premium.

If you used the earlier **Oldest First** package, close the game and delete its `Mods/OldestFirst` folder before installing, so only one copy runs.

### Update or remove

**Update:** close the game, extract the new Mod ZIP, copy its whole `FirstToServe` folder into the same `Mods` folder and replace matching files, then start the game.

**Remove:** close the game and delete only `Mods/FirstToServe`. Leave UE4SS and other Mods in place.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload).

### Languages and help

The hold hint follows the game language and shows the button for your current keyboard or controller. Game languages: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese.

If pickup doesn't start:

- Check that you are holding the tray or pushing the food trolley, and that a suitable slot is free.
- Check that the item is ready, on your floor and within reach. Try aiming straight at it.
- A drink surface accepts the hold even when it shows no normal pickup hint.

If pickup stops while there is still room, release and hold again.

When reporting a problem, include the `[FirstToServe]` lines from `Win64/ue4ss/UE4SS.log`, your controls (mouse and keyboard or controller) and whether you were host or guest.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/first-to-serve-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) · [PolyForm Noncommercial License 1.0.0](LICENSE)

## 中文

拿着托盘或推着送餐餐车，对准厨房出餐口或饮料出品台长按交互键，按做好的先后依次拿取成品。

**版本：0.1.8。** 单人、联机房主和客机均可使用。只有想用长按拿取的玩家需要安装。

### 怎么使用

1. 装备托盘，或握住**送餐餐车**推行。为要拿的餐品留出至少一个空位。
2. 在正常拿取距离内，对准厨房出餐口的拿取区域、饮料出品台面，或台上已做好的菜品、满杯饮料。附近家具和还放在制作设备上的杯子不会触发。
3. 长按交互键：鼠标默认左键，键盘和手柄跟随你的改键设置。可以拿取时，原版拿取提示旁会按游戏语言显示 **长按：优先拿取最早制作的餐品**（英文为 **Hold: take oldest first**）。
4. 持续按住，逐份拿取。即使准星对着较新的成品，也会先拿该来源中最早做好的那份。
5. 拿够后松键，照常搬运上菜。本 Mod 只负责取餐；卸下餐品、放下托盘或餐车、给顾客上菜都按原版操作。

短按仍是原版操作；没有设置项，也没有新增快捷键。持托盘或餐车对准支持的来源时，长按会连续拿取，代替打开交互轮盘。

### 会拿取哪些餐品

按成品做好的时间从早到晚拿取，与顾客下单时间、台面位置和餐品品质无关。容量和拿取距离沿用游戏规则，放入哪个槽位由游戏决定。

| 场景 | 拿取规则 |
| --- | --- |
| 厨房出餐口，或那里已做好的菜品 | 拿取当前楼层、拿取距离内已做好的菜品。 |
| 饮料出品台面，或台上的满杯饮料 | 拿取该饮料台的满杯饮料；一次长按只从一处饮料台拿取。 |
| 脏餐具、已上桌、正在食用、正被拿取或已被搬走的餐品，以及未完成的饮料 | 跳过。其他楼层或超出拿取距离的餐品也会跳过。 |
| 托盘或餐车只剩饮料专用空位 | 可以放饮料；食物需要普通空位。 |
| 餐车上有脏盘堆叠 | 堆叠中的空隙不算空位，整个堆叠位完全空出后才能放食物或饮料。 |
| 用餐车拿高层汉堡 | 需要顶层空位；较早的汉堡放不下时，可能先拿较新的其他菜品。 |
| 停放的送餐餐车、搬货推车，或没装备托盘 | 长按无效。必须自己拿着托盘或推着送餐餐车。 |

### 停止与再次拿取

准星可以在同一出品区域内移动，不必逐份瞄准。拿走准星下的餐品后，视角或位置稍有移动也没关系，准星停在原来的空位上仍会继续拿取。转开视线、走开或瞄准另一处来源会停止本次长按。

松开交互键、更换或放下托盘／餐车、打开菜单／交互轮盘／联机聊天、进入摆放模式或暂停，也会结束拿取。已拿到的餐品留在托盘或餐车上。

适用空位全部装满后会停止。腾出空位、回到出品区或换了托盘／餐车后，须**松键再重新长按**；一直按住不会重新开始。空的出品区无法开始长按。某一份两秒内没有拿到时，本次长按也会停止；松键，检查空位和瞄准位置后再试。

### 联机使用

房主和客机操作相同。想用长按功能的玩家在自己电脑上安装即可，客机使用时房主不必安装。每份安装只控制该玩家自己的托盘或餐车。其他玩家先拿走餐品或网络延迟时，连续拿取可能提前停止。

### 实机截图

持托盘在厨房出餐口取餐。

![实机动图：持托盘在厨房出餐口取餐](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/first-to-serve-mod/assets/kitchen-pass-gameplay.gif?raw=1)

[打开动图（GIF，5.13 MiB）](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/first-to-serve-mod/assets/kitchen-pass-gameplay.gif?raw=1)

持托盘对准厨房出餐口，**Take the dish（拿取菜品）** 上方显示长按提示。

![实机画面：持托盘对准出餐口，显示长按优先拿取最早成品及拿取菜品提示](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/first-to-serve-mod/assets/kitchen-pass-gameplay.png?raw=1)

持托盘对准饮料出品台，**Take drinks（拿取饮料）** 上方显示同样的长按提示。

![实机画面：持托盘对准饮料出品台，显示长按优先拿取最早成品及拿取饮料提示](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/first-to-serve-mod/assets/drink-output-gameplay.png?raw=1)

### 使用要求

- Windows 版 Parisian Bistro Simulator，支持至游戏版本 1.0.2.44eb（Steam Build 25822788）。
- [UE4SS experimental](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental) `v3.0.1-1140-gf58e8f84`，需单独安装（见“安装”）。旧稳定版 UE4SS 3.0.1 无法使用。

### 下载

以下两个来源任选其一，文件相同。

- **GitHub（无需账号）：**打开 [出餐有序 0.1.8](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/first-to-serve-v0.1.8)，在 **Assets（附件）** 下载 **FirstToServe-0.1.8.zip**。不要选 **Source code（源码）**。
- **Nexus：**打开 [Mod 页面](https://www.nexusmods.com/parisianbistrosimulator/mods/6)，进入 **Files（文件）→ Main files（主要文件）→ Manual download（手动下载）**；免费账号选择 **Slow download（慢速下载）**。

### 安装

手动安装免费，不需要 Vortex，也不需要 Nexus Premium。

UE4SS 是 Mod 加载器，负责在游戏启动时运行 Mod。只需安装一次，之后把 Mod 放进它的 `Mods` 文件夹。已经装好 UE4SS 的，从第 6 步开始。

1. **退出游戏。** 在 Steam **库**中右键 **Parisian Bistro Simulator（法式小馆儿模拟器）→ 管理 → 浏览本地文件**，打开游戏目录（文件夹名可能是 **Parisian Brasserie Simulator**）。
2. **依次打开 BrasserieSimulator → Binaries → Win64**，能看到 **BrasserieSimulator-Win64-Shipping.exe**（Windows 可能隐藏 `.exe` 后缀）。保持这个窗口打开，加载器就装在这里。
3. **下载 UE4SS：**[UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip)。链接打不开时，到 [UE4SS experimental 发布页](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental)的 **Assets** 中找同名文件。不要下载 `zDEV`、`Source code` 或旧稳定版 `UE4SS_v3.0.1.zip`。
4. **把加载器放进 Win64。** 右键 ZIP → **全部解压缩 → 提取**，从解压出的文件夹中复制 **dwmapi.dll** 和 **ue4ss** 文件夹，粘贴到 **Win64**。替换已有的 UE4SS 前，先备份原文件夹。
5. **检查加载器：**`dwmapi.dll` 与 `BrasserieSimulator-Win64-Shipping.exe` 在同一层；**ue4ss** 文件夹里有 **UE4SS.dll**、**UE4SS-settings.ini** 和 **Mods**。
6. **解压 Mod ZIP**，打开到能看到 **FirstToServe** 文件夹，里面有 **Scripts** 和 **enabled.txt**。
7. **把整个 FirstToServe 文件夹**复制到 **Win64 → ue4ss → Mods**。
8. **检查 Mod：**应有 `Mods/FirstToServe/Scripts/main.lua` 和 `Mods/FirstToServe/enabled.txt`（不要多套一层 `FirstToServe/FirstToServe`）。`enabled.txt` 即使是空文件也要保留。
9. **从 Steam 启动游戏**，按上方“怎么使用”操作。

不生效时，先退出游戏，核对第 5、8 步，再查看[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

**改用 Vortex：**先按 [Vortex 安装说明](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#中文)装好 Vortex、游戏扩展和 UE4SS，再导入 Mod ZIP，启用并部署。同一个 Mod 只用 Vortex 或手动其中一种方式安装。通过 [Nexus 合集](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz)一键安装需要 Nexus Premium。

安装过旧名 **Oldest First** 的版本时，先关闭游戏，删除旧的 `Mods/OldestFirst` 文件夹再安装，避免同时运行两份。

### 更新与卸载

**更新：**关闭游戏，解压新版 Mod ZIP，把完整的 `FirstToServe` 文件夹复制到原来的 `Mods` 目录并覆盖同名文件，再启动游戏。

**卸载：**关闭游戏，只删除 `Mods/FirstToServe`，保留 UE4SS 和其他 Mod。

可选：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。

### 语言与帮助

长按提示跟随游戏语言，并显示当前键鼠或手柄对应的按键。游戏语言包括英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。

没有开始拿取时：

- 确认正拿着托盘或推着送餐餐车，并且有适用空位。
- 确认餐品已做好、在当前楼层且在拿取距离内；可以直接瞄准餐品再试。
- 饮料台面没有原版拿取提示时，也可以长按。

仍有空位却停止时，松键后重新长按。

反馈问题时，请附上 `Win64/ue4ss/UE4SS.log` 中的 `[FirstToServe]` 日志、所用操作设备（键鼠或手柄），以及你是房主还是客机。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/first-to-serve-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文) · [PolyForm Noncommercial 1.0.0 许可](LICENSE)
