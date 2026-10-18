# Auto Menu / 菜单巧配

[![Auto Menu / 菜单巧配 — AI-generated cover / AI 宣传封面](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/auto-menu-mod/assets/cover.png?raw=1)](https://www.nexusmods.com/mods/5?game_id=10352)

[English](#english) · [中文](#中文)

## English

Adds an **Auto-compose** button beside **Print menu** on the computer's daily-menu page. One click picks the lunch or dinner menu with the highest estimated selection rate.

**Version: 0.5.0.** Single player or multiplayer host. Only the host installs it; guests don't get the button.

### How to use

1. In single player, or as the multiplayer host, open the restaurant computer's **Menu** app and select **Daily menu** in the sidebar.
2. Select **Lunch** or **Dinner** at the top. Only the selected service changes. Check the day's customer forecast, weather and event, and make any dish availability or price changes first.
3. Click **Auto-compose** beside **Print menu** and wait for the page to refresh. The Mod compares the possible menus and saves the best one straight away.
4. Check the chosen dishes, then scroll to **Menu forecast**: **Estimated adoption**, compatibility by customer profile, **Menus available from current stock** and menu bonuses. These are the game's own forecast for the new menu.
5. Adjust single courses with the game's **Select a dish** and **Clear dish** if you like. Use the game's **Enabled / Disabled** control to turn the menu on when you want to serve it, and click **Print menu** yourself when you want a printed copy.
6. For the other service, switch to it and click **Auto-compose** again. Click again whenever the day's conditions or your available dishes change.

**The result is saved as soon as you click.** There is no confirm step and no undo. To change it, edit the menu with the game's controls, or change the available dishes and compose again.

- A menu with at least one dish keeps its current Enabled / Disabled state.
- An empty result is disabled by the game.
- The other service is left as it was.

### What the button picks

- Up to one item in each of five courses: **aperitif, starter, main course, dessert and after-dinner drink**.
- Only dishes that are available, enabled, have the staff they need and belong to that course. It doesn't unlock dishes, enable disabled ones or hire staff.
- Any course can stay empty, including the main course. If no dish qualifies, the menu is empty and the game disables it.
- If your current menu already scores as high as the best option, it is kept.

The goal is the game's **estimated selection rate**, based on its current forecast, prices, weather, events and its own menu rules. Profit, preparation time and stock are not part of the goal, so check the forecast and stock before serving.

### When it runs

- Only when you click **Auto-compose**. It doesn't plan tomorrow's menu, run every day, buy ingredients, change prices or print menus.
- No settings file or hotkey.
- **With many dishes to choose from, the game may pause until the search finishes.** There is no progress bar or cancel button, so wait before doing anything else. In multiplayer the whole session may pause briefly.

### Multiplayer

- Only the host needs the Mod. Guests don't get the button, even if they install it.
- The button works only on the **Daily menu** page with **Lunch** or **Dinner** selected. Breakfast and other menu categories are not changed.

### In-game screenshots

The **Auto-compose** button sits beside **Print menu** on the daily-menu page, shown here with its tooltip.

![Daily-menu page with the Auto-compose button beside Print menu and its tooltip visible](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-menu-v0.5.0/auto-menu-mod/assets/auto-compose-gameplay.png?raw=1)

The forecast for this menu shows **86% estimated adoption**, compatibility by customer profile and **68 menus available** from current stock.

![Menu forecast showing 86 percent estimated adoption, customer-profile compatibility and 68 menus available](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-menu-v0.5.0/auto-menu-mod/assets/menu-forecast-gameplay.png?raw=1)

### Requirements

- Windows version of Parisian Bistro Simulator, up to game version 1.0.2.44eb (Steam Build 25822788).
- [UE4SS experimental](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental) `v3.0.1-1140-gf58e8f84`, installed separately (see **Install**). The older stable UE4SS 3.0.1 does not work.
- Single player or multiplayer host. The Mod ZIP already includes its helper file `Scripts/auto_menu_bridge.dll`.

### Download

Pick either source; both have the same file.

- **GitHub (no account needed):** open [Auto Menu 0.5.0](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-menu-v0.5.0) and download **AutoMenu-0.5.0.zip** under **Assets**. Don't pick **Source code**.
- **Nexus:** open the [Mod page](https://www.nexusmods.com/parisianbistrosimulator/mods/5), go to **Files → Main files → Manual download**, then choose **Slow download** if you have a free account.

### Install

Manual installation is free and needs neither Vortex nor Nexus Premium.

UE4SS is the mod loader that runs Mods when the game starts. Install it once, then put Mods in its `Mods` folder. If UE4SS is already installed, start at step 6.

1. **Close the game.** In Steam, open **Library**, right-click **Parisian Bistro Simulator** → **Manage → Browse local files**. This opens the game folder (it may be named **Parisian Brasserie Simulator**).
2. **Open BrasserieSimulator → Binaries → Win64.** You should see **BrasserieSimulator-Win64-Shipping.exe** (Windows may hide the `.exe`). Keep this window open; the loader goes here.
3. **Download UE4SS:** [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip). If the link doesn't open, find that exact file under **Assets** on the [UE4SS experimental release page](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental). Don't use `zDEV`, `Source code` or the old stable `UE4SS_v3.0.1.zip`.
4. **Copy the loader into Win64.** Right-click the ZIP → **Extract All… → Extract**. From the extracted folder, copy **dwmapi.dll** and the **ue4ss** folder and paste both into **Win64**. If you are replacing an existing UE4SS, back up its folder first.
5. **Check the loader:** `dwmapi.dll` sits next to `BrasserieSimulator-Win64-Shipping.exe`, and the **ue4ss** folder contains **UE4SS.dll**, **UE4SS-settings.ini** and **Mods**.
6. **Extract the Mod ZIP** and open it until you see the **AutoMenu** folder, which contains **Scripts** and **enabled.txt**.
7. **Copy the whole AutoMenu folder** into **Win64 → ue4ss → Mods**.
8. **Check the Mod:** `Mods/AutoMenu/Scripts/main.lua`, `Mods/AutoMenu/Scripts/auto_menu_bridge.dll` and `Mods/AutoMenu/enabled.txt` should exist (not `AutoMenu/AutoMenu`). Keep `enabled.txt` even if it is empty, and keep `auto_menu_bridge.dll` in **Scripts**.
9. **Start the game through Steam** and follow **How to use** above.

If the Mod doesn't work, close the game, recheck steps 5 and 8, then see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english).

**Using Vortex instead:** set up Vortex, the game extension and UE4SS with the [Vortex guide](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#english), then import the Mod ZIP, enable it and deploy. Install each Mod either with Vortex or manually, not both. One-click install of the [collection](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz) requires Nexus Premium.

### Update or remove

**Update:** close the game, extract the new Mod ZIP, copy its whole `AutoMenu` folder into the same `Mods` folder and replace the existing files. Then start the game.

**Remove:** close the game and delete only `Mods/AutoMenu`, leaving UE4SS and other Mods in place. Menus you already composed stay saved, and you can still edit them with the game's controls.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload). This is not required for normal installation or updates.

### Languages and help

The button follows the game language: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese. Dish names and forecasts are the game's own text.

- **The button is missing or can't be clicked:** make sure you are the host, the **Daily menu** page is open with **Lunch** or **Dinner** selected, and you copied the whole `AutoMenu` folder, including `Scripts/auto_menu_bridge.dll`.
- **Nothing changes after a click:** if the search fails, your previous menu is kept. Check the menu on screen.
- **Reporting a problem:** describe what you clicked and include the `[AutoMenu]` lines from `Win64/ue4ss/UE4SS.log`.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/auto-menu-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) · [PolyForm Noncommercial License 1.0.0](LICENSE)

## 中文

在电脑每日菜单页面的“打印菜单”旁增加 **自动组合** 按钮，一键为午餐或晚餐选出预计选择率最高的菜单。

**版本：0.5.0。** 适用于单人游戏或联机房主。只需房主安装；客机不显示该按钮。

### 怎么使用

1. 在单人游戏中，或以联机房主身份打开餐厅电脑的 **菜单（Menu）** 应用，在侧栏选择 **每日菜单（Daily menu）**。
2. 在页面顶部选择 **午餐（Lunch）** 或 **晚餐（Dinner）**，只有选中的餐段会被修改。先看好当天的客流预测、天气和活动；要调整菜品可用状态或价格，先调完再组合。
3. 点击 **打印菜单（Print menu）** 旁的 **自动组合（Auto-compose）**，等待页面刷新。Mod 会比较各种可行的菜单组合，并立即保存最好的一份。
4. 查看选出的菜品，向下滚动到 **菜单预测（Menu forecast）**，核对 **预计选择率（Estimated adoption）**、各类顾客适配度、**当前库存可提供的菜单份数（Menus available from current stock）** 和菜单加成。这些是游戏对新菜单的预测。
5. 想单独换某道菜，用原版的 **选择菜品（Select a dish）** 和 **清除菜品（Clear dish）**。需要供应时，用原版 **启用／停用（Enabled / Disabled）** 按钮启用菜单；需要纸质菜单时自行点击 **打印菜单**。
6. 另一个餐段需要切换过去再点一次 **自动组合**。当天条件或可用菜品变化后，随时可以再点一次重新计算。

**点击后结果立即保存。** 没有确认步骤，也不能撤销。想改的话，用原版控件编辑菜单，或调整可用菜品后重新组合。

- 至少有一道菜的菜单保持原来的启用／停用状态。
- 全空的结果由游戏自动停用。
- 另一个餐段保持不变。

### 自动组合怎么选

- 从 **开胃酒、前菜、主菜、甜点、餐后饮品** 五类中，每类最多选一项。
- 只选当前可用、已启用、员工条件满足且属于该类别的菜品；不会解锁菜品、启用被停用的菜品或替你雇人。
- 每类都可以留空，主菜也一样。没有任何合格菜品时，菜单为空，由游戏停用。
- 当前菜单的选择率已经和最优结果一样高时，保留当前菜单。

选菜依据是游戏的 **预计选择率**，沿用当前客流预测、价格、天气、活动和游戏自身的菜单规则。利润、备餐时间和库存不在考虑范围内，供应前请自行查看预测和库存。

### 什么时候运行

- 只在点击 **自动组合** 时运行；不会安排明天的菜单、每天自动运行、采购食材、改价格或打印菜单。
- 没有配置文件，也没有快捷键。
- **可选菜品很多时，游戏可能停顿到计算结束。** 没有进度条或取消按钮，请等计算完成再操作；联机时整个会话可能短暂停顿。

### 联机

- 只需房主安装。客机即使安装了也不会出现按钮。
- 按钮只在 **每日菜单** 页面选中 **午餐** 或 **晚餐** 时可用，不会修改早餐或其他菜单分类。

### 实机截图

每日菜单页面的 **Print menu（打印菜单）** 旁显示 **Auto-compose（自动组合）** 按钮，图中同时显示了按钮的悬浮说明。

![实机画面：每日菜单页面中的自动组合按钮位于打印菜单旁，并显示悬浮说明](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-menu-v0.5.0/auto-menu-mod/assets/auto-compose-gameplay.png?raw=1)

这份菜单的预测显示 **86% 的预计选择率**、各类顾客的适配度，以及现有库存可提供的 **68 份菜单**。

![实机画面：菜单预测显示86%的预计选择率、顾客适配度及现有库存可提供的68份菜单](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-menu-v0.5.0/auto-menu-mod/assets/menu-forecast-gameplay.png?raw=1)

### 使用要求

- Windows 版 Parisian Bistro Simulator，支持至游戏版本 1.0.2.44eb（Steam Build 25822788）。
- [UE4SS experimental](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental) `v3.0.1-1140-gf58e8f84`，需单独安装（见“安装”）。旧稳定版 UE4SS 3.0.1 无法使用。
- 单人游戏或联机房主。Mod ZIP 已自带辅助文件 `Scripts/auto_menu_bridge.dll`。

### 下载

以下两个来源任选其一，文件相同。

- **GitHub（无需账号）：**打开 [菜单巧配 0.5.0](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-menu-v0.5.0)，在 **Assets（附件）** 下载 **AutoMenu-0.5.0.zip**。不要选 **Source code（源码）**。
- **Nexus：**打开 [Mod 页面](https://www.nexusmods.com/parisianbistrosimulator/mods/5)，进入 **Files（文件）→ Main files（主要文件）→ Manual download（手动下载）**；免费账号选择 **Slow download（慢速下载）**。

### 安装

手动安装免费，不需要 Vortex，也不需要 Nexus Premium。

UE4SS 是 Mod 加载器，负责在游戏启动时运行 Mod。只需安装一次，之后把 Mod 放进它的 `Mods` 文件夹。已经装好 UE4SS 的，从第 6 步开始。

1. **退出游戏。** 在 Steam **库**中右键 **Parisian Bistro Simulator（法式小馆儿模拟器）→ 管理 → 浏览本地文件**，打开游戏目录（文件夹名可能是 **Parisian Brasserie Simulator**）。
2. **依次打开 BrasserieSimulator → Binaries → Win64**，能看到 **BrasserieSimulator-Win64-Shipping.exe**（Windows 可能隐藏 `.exe` 后缀）。保持这个窗口打开，加载器就装在这里。
3. **下载 UE4SS：**[UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip)。链接打不开时，到 [UE4SS experimental 发布页](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental)的 **Assets** 中找同名文件。不要下载 `zDEV`、`Source code` 或旧稳定版 `UE4SS_v3.0.1.zip`。
4. **把加载器放进 Win64。** 右键 ZIP → **全部解压缩 → 提取**，从解压出的文件夹中复制 **dwmapi.dll** 和 **ue4ss** 文件夹，粘贴到 **Win64**。替换已有的 UE4SS 前，先备份原文件夹。
5. **检查加载器：**`dwmapi.dll` 与 `BrasserieSimulator-Win64-Shipping.exe` 在同一层；**ue4ss** 文件夹里有 **UE4SS.dll**、**UE4SS-settings.ini** 和 **Mods**。
6. **解压 Mod ZIP**，打开到能看到 **AutoMenu** 文件夹，里面有 **Scripts** 和 **enabled.txt**。
7. **把整个 AutoMenu 文件夹**复制到 **Win64 → ue4ss → Mods**。
8. **检查 Mod：**应有 `Mods/AutoMenu/Scripts/main.lua`、`Mods/AutoMenu/Scripts/auto_menu_bridge.dll` 和 `Mods/AutoMenu/enabled.txt`（不要多套一层 `AutoMenu/AutoMenu`）。`enabled.txt` 即使是空文件也要保留，`auto_menu_bridge.dll` 也要留在 **Scripts** 中。
9. **从 Steam 启动游戏**，按上方“怎么使用”操作。

不生效时，先退出游戏，核对第 5、8 步，再查看[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

**改用 Vortex：**先按 [Vortex 安装说明](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#中文)装好 Vortex、游戏扩展和 UE4SS，再导入 Mod ZIP，启用并部署。同一个 Mod 只用 Vortex 或手动其中一种方式安装。通过 [Nexus 合集](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz)一键安装需要 Nexus Premium。

### 更新与卸载

**更新：** 关闭游戏，解压新版 Mod ZIP，把完整的 `AutoMenu` 文件夹复制到原来的 `Mods` 目录并覆盖已有文件，再启动游戏。

**卸载：** 关闭游戏，只删除 `Mods/AutoMenu`，保留 UE4SS 和其他 Mod。已经组合好的菜单仍会保留，可继续用原版控件编辑。

可选操作：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。正常安装和更新不需要此操作。

### 语言与帮助

按钮跟随游戏语言：英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。菜名和预测内容沿用游戏原文。

- **按钮没有出现或无法点击：**确认自己是房主，已打开 **每日菜单** 并选中 **午餐** 或 **晚餐**，并且复制了完整的 `AutoMenu` 文件夹，包括 `Scripts/auto_menu_bridge.dll`。
- **点击后菜单没变：**计算失败时会保留原来的菜单，请查看页面上的菜单。
- **反馈问题：**说明点击过程，并附上 `Win64/ue4ss/UE4SS.log` 中的 `[AutoMenu]` 日志。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/auto-menu-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文) · [PolyForm Noncommercial 1.0.0 许可](LICENSE)
