# Auto Menu / 菜单巧配

[![Auto Menu / 菜单巧配 — AI-generated cover / AI 宣传封面](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/auto-menu-mod/assets/cover.png?raw=1)](https://www.nexusmods.com/mods/5?game_id=10352)

[English](#english) · [中文](#中文)

## English

Add an **Auto-compose** button beside **Print menu** on the computer's daily-menu page to find a menu with the highest estimated selection rate.

**Version: 0.5.0.** Single player or multiplayer host only. Only the host needs to install it; guests do not get the button.

### How to use

1. In single player, or as the multiplayer host, open the restaurant computer's **Menu** app and select **Daily menu** in the sidebar.
2. Select **Lunch** or **Dinner** at the top. The selected service is the only menu that this click will change. Review the day's customer forecast, weather and event, and make any desired dish availability or price changes before composing.
3. Click **Auto-compose**, beside **Print menu**. Wait for the page to refresh. The Mod compares eligible menu combinations using the game's estimated selection rate and saves the winning menu immediately.
4. Inspect the chosen dishes and scroll to **Menu forecast**. Check **Estimated adoption**, customer-profile compatibility, **Menus available from current stock** and the displayed menu bonuses. These are the game's forecast for the selected result, not guaranteed sales.
5. If needed, use the original **Select a dish** and **Clear dish** controls to adjust individual courses. Check the service's **Enabled / Disabled** status and use the game's status control to activate the menu when you want to serve it. Use **Print menu** yourself when you want a printed menu.
6. Switch to the other service and click **Auto-compose** separately if you also want to compose that menu. Click again after changing the day's conditions or your available dishes whenever you want a new calculation.

**Auto-compose saves the result immediately.** There is no additional Save/Cancel confirmation and no Mod undo button. To replace an unwanted result, edit the menu with the game's normal controls or compose again after changing the available choices. A nonempty result keeps the menu's existing active/inactive state; the game deactivates a completely empty result. The other service is unchanged.

### What the button chooses

The Mod chooses up to one item in each of five categories: **aperitif, starter, main course, dessert and after-dinner drink**. It considers the game's currently available, enabled choices that meet staffing requirements and belong to the appropriate course. It does not unlock dishes, enable disabled dishes or hire staff to make more choices available.

Every category can be left empty, including the main course, and a completely empty menu is a valid candidate. If no eligible dishes remain, the result is empty and the game disables that service's menu. The Mod does not force a full five-course meal. If your current eligible menu ties for the highest rate, it is retained.

The target is the game's **estimated selection rate**, using its current forecast, prices, weather, events and other native menu calculations. The Mod compares whole menu combinations. It does not optimize profit, preparation time or the number of portions in stock as separate targets, and it does not guarantee 100% adoption or 100% compatibility for every customer profile. Check the forecast and stock before serving the result.

### When it runs and multiplayer behavior

Composition runs only when you click **Auto-compose**. It does not schedule tomorrow's menu, automatically run every day, buy ingredients, change prices or print menus. No separate configuration file or gameplay hotkey is needed. The game saves the chosen menu normally; removing the Mod does not restore the previous choices.

**A large dish selection can pause gameplay while the search finishes.** There is no progress display or cancel control during the search. Wait for it to finish before another action; in multiplayer, the host's search can also interrupt the session's normal flow.

Only the host needs to install the Mod. Guests do not receive the button, and installing it on a guest does not grant permission to compose the shared restaurant's menu. The button is available only on the **Daily menu** page with **Lunch** or **Dinner** selected; it does not compose breakfast or edit other menu categories.

### In-game screenshots

The **Auto-compose** button sits beside **Print menu** on the daily-menu page, with its tooltip visible here.

![Daily-menu page with the Auto-compose button beside Print menu and its tooltip visible](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-menu-v0.5.0/auto-menu-mod/assets/auto-compose-gameplay.png?raw=1)

The captured menu forecast shows **86% estimated adoption**, compatibility by customer profile and **68 menus available** from current stock.

![Menu forecast showing 86 percent estimated adoption, customer-profile compatibility and 68 menus available](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-menu-v0.5.0/auto-menu-mod/assets/menu-forecast-gameplay.png?raw=1)

### Requirements

Windows x64 Parisian Bistro Simulator and **UE4SS experimental**. The checked loader build is `v3.0.1-1140-gf58e8f84`; stable UE4SS 3.0.1 is not supported. Other loader builds have not been verified. UE4SS is installed separately. The ready-to-use Mod ZIP includes its helper; no compiling is needed.

### Download

1. Open [Auto Menu 0.5.0](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-menu-v0.5.0).
2. Under **Assets**, download **`AutoMenu-0.5.0.zip`** and `SHA256SUMS.txt`. Extract the Mod ZIP; GitHub's **Source code** archive is not an installable Mod.

If the package is missing or you cannot access it, see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english).

### Install

1. Close the game. In Steam, right-click **Parisian Bistro Simulator** → **Manage** → **Browse local files**. This opens the `<game>` folder used below.
2. Install the basic experimental UE4SS package using the [UE4SS installation guide](https://docs.ue4ss.com/dev/installation-guide.html), keeping that package's folder structure.
3. Copy the extracted **`AutoMenu`** folder, with all its contents, into `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/`. If your loader uses another location, use its existing `Mods` folder instead.
4. Confirm these files exist, with no extra `AutoMenu/AutoMenu` folder:

   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/AutoMenu/Scripts/main.lua`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/AutoMenu/Scripts/auto_menu_bridge.dll`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/AutoMenu/enabled.txt`

5. Start the game as host and open the daily-menu page on the restaurant computer.

The included `enabled.txt` enables the Mod. Keep the whole Mod folder together; do not replace the loader's `mods.txt` or other Mods. Keep `auto_menu_bridge.dll` inside this Mod's `Scripts` folder.

### Update or remove

**Update:** close the game, download and extract the new Mod ZIP, then copy its complete `AutoMenu` folder into the same `Mods` folder and replace matching files. Start the game again.

**Remove:** close the game and delete only `Mods/AutoMenu`. Leave UE4SS and other Mods in place. Removing the Mod removes its button but does not undo a menu already saved by the game. You can edit that menu with the normal controls.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload). This is not required for normal installation or updates.

### Languages and help

The button follows the game's selected language, with no separate setting or language pack. Menu names and forecasts remain the game's own text. Technical logs remain English.

Game languages: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese.

If the button is missing or disabled, confirm you are the host, the **Daily menu** page is open with **Lunch** or **Dinner** selected, and the complete Mod folder, including its helper, is installed. A failed search restores the previous selection without submitting its trial menus. If no result appears or saving is refused, check the displayed menu and report relevant `[AutoMenu]` lines from `UE4SS.log` with what you clicked. The Mod has no in-game error popup or progress indicator.

In-game and multiplayer testing passed as reported by the maintainer on 2026-09-26; the [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-menu-v0.5.0/releases/validation.md#english) describes its scope.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/auto-menu-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) · [MIT License](LICENSE)

## 中文

在电脑每日菜单页面的“打印菜单”旁增加 **自动组合** 按钮，按游戏的预计选择率选择菜单组合。

**版本：0.5.0。** 仅单人或联机房主可用，只需房主安装，客机不显示该按钮。

### 怎么使用

1. 在单人游戏中，或以联机房主身份打开餐厅电脑的 **菜单（Menu）** 应用，在侧栏选择 **每日菜单（Daily menu）**。
2. 在页面顶部选择 **午餐（Lunch）** 或 **晚餐（Dinner）**。本次点击只会修改选中的餐段。先查看当天客流预测、天气和活动；需要调整菜品可用状态或价格时，先完成调整。
3. 点击 **打印菜单（Print menu）** 旁的 **自动组合（Auto-compose）**，等待页面刷新。Mod 按游戏的预计选择率比较符合条件的菜单组合，并立即保存最优结果。
4. 查看选中的菜品，向下滚动到 **菜单预测（Menu forecast）**，核对 **预计选择率（Estimated adoption）**、各类顾客适配度、**当前库存可提供的菜单份数（Menus available from current stock）** 及菜单加成。这些是游戏对当前结果的预测，不是实际销量保证。
5. 如需调整某一类菜品，使用原版 **选择菜品（Select a dish）** 与 **清除菜品（Clear dish）**。查看该餐段的 **启用／停用（Enabled / Disabled）** 状态，需要供应时再用原版状态按钮启用；需要纸质菜单时自行点击 **打印菜单**。
6. 如需组合另一个餐段，切换餐段后单独点击 **自动组合**。当天条件或可用菜品改变后，可再次点击重新计算。

**点击自动组合后会直接保存。** 没有额外的保存／取消确认，也没有 Mod 撤销按钮。不满意时，可用原版控件改回需要的菜品，或调整可用选项后重新组合。非空结果保留此前的启用／停用状态；全空结果由游戏自动停用。另一个餐段不受影响。

### 自动组合会选择什么

Mod 在 **开胃酒、前菜、主菜、甜点、餐后饮品** 五类中各选择最多一项。候选须为游戏当前可用、已启用、满足员工条件且属于对应分类的菜品；不会解锁菜品、启用被禁用的菜品或替你雇佣员工。

每类都可以留空，主菜也不例外；全空菜单同样会参与比较。如果没有任何合格菜品，结果为空，由游戏停用该餐段菜单。Mod 不会强制凑齐五道菜。当前菜单仍符合条件且与最优结果选择率相同时，会保留当前菜单。

优化目标是游戏的 **预计选择率**，沿用当前客流预测、价格、天气、活动及其他原版菜单计算，比较的是整份菜单组合。利润、备餐速度或现有库存可供应的份数并不是独立优化目标；不保证选择率或所有顾客类型的适配度达到 100%。供应前仍应查看预测与库存。

### 触发时机与联机行为

只有点击 **自动组合** 才会运行；不会排定明日菜单、每天自动组合、采购食材、修改价格或打印菜单。无需单独配置文件或游戏操作快捷键。结果由游戏正常保存，卸载 Mod 不会恢复此前的菜品选择。

**可选菜品很多时，游戏可能会停顿，直到搜索结束。** 搜索期间没有进度显示或取消按钮，请等计算结束再进行其他操作；联机时房主的搜索也可能让会话暂时停顿。

联机只需房主安装。客机不会获得按钮，安装 Mod 也不能取得修改共享餐厅菜单的权限。按钮仅在 **每日菜单** 页面选中 **午餐** 或 **晚餐** 时可用，不会组合早餐或编辑其他菜单分类。

### 实机截图

每日菜单页面的 **Print menu（打印菜单）** 旁显示 **Auto-compose（自动组合）** 按钮，图中同时展示了按钮的悬浮说明。

![实机画面：每日菜单页面中的自动组合按钮位于打印菜单旁，并显示悬浮说明](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-menu-v0.5.0/auto-menu-mod/assets/auto-compose-gameplay.png?raw=1)

图中菜单预测显示 **86% 的预计选择率**、各类顾客的适配度，以及现有库存可提供的 **68 份菜单**。

![实机画面：菜单预测显示86%的预计选择率、顾客适配度及现有库存可提供的68份菜单](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-menu-v0.5.0/auto-menu-mod/assets/menu-forecast-gameplay.png?raw=1)

### 使用要求

Windows x64 版 Parisian Bistro Simulator，以及 **UE4SS experimental**。已核对的加载器版本为 `v3.0.1-1140-gf58e8f84`，不支持旧稳定版 UE4SS 3.0.1；其他加载器版本尚未验证。UE4SS 需单独安装。Mod ZIP 已含可直接使用的辅助文件，无需自行编译。

### 下载

1. 打开 [菜单巧配 0.5.0](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-menu-v0.5.0)。
2. 在 **Assets** 中下载 **`AutoMenu-0.5.0.zip`** 和 `SHA256SUMS.txt`。解压 Mod ZIP；GitHub 的 **Source code** 是源码，不能当作安装包。

找不到文件或无法访问时，见[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

### 安装

1. 关闭游戏。在 Steam 中右键 **Parisian Bistro Simulator** → **管理** → **浏览本地文件**，打开的就是下方所说的 `<game>` 游戏目录。
2. 按 [UE4SS 安装说明](https://docs.ue4ss.com/dev/installation-guide.html)安装 experimental 的基础包，保留该发行包自己的目录结构。
3. 将解压出的 **`AutoMenu`** 文件夹连同全部内容复制到 `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/`。若加载器实际装在其他位置，请使用它已有的 `Mods` 文件夹。
4. 确认存在以下文件，不要多套一层 `AutoMenu/AutoMenu` 文件夹：

   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/AutoMenu/Scripts/main.lua`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/AutoMenu/Scripts/auto_menu_bridge.dll`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/AutoMenu/enabled.txt`

5. 启动游戏，以房主身份打开餐厅电脑的每日菜单页面。

包内的 `enabled.txt` 会启用 Mod。请完整保留 Mod 文件夹，不要替换加载器的整个 `mods.txt` 或其他 Mod。`auto_menu_bridge.dll` 应留在本 Mod 的 `Scripts` 内。

### 更新与卸载

**更新：** 关闭游戏，下载并解压新版 Mod ZIP，把完整的 `AutoMenu` 文件夹复制到原来的 `Mods` 目录并覆盖同名文件，再启动游戏。

**卸载：** 关闭游戏，只删除 `Mods/AutoMenu`，保留 UE4SS 和其他 Mod。卸载会移除按钮，但不会撤销已由游戏保存的菜单；仍可使用原版按钮继续编辑。

可选操作：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。正常安装和更新不需要此操作。

### 语言与帮助

按钮跟随游戏当前语言，无需独立设置或语言包。菜名及预测结果沿用游戏原有文案，技术日志保持英文。

游戏语言包括英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。

按钮未出现或不可点击时，先确认自己是房主，已打开 **每日菜单** 并选中 **午餐** 或 **晚餐**，且安装了包含辅助文件的完整 Mod 文件夹。试算失败会恢复此前的选择，不提交试算中的菜单。没有出现结果或保存被拒绝时，请核对页面上的菜单，再反馈点击过程及 `UE4SS.log` 中相关的 `[AutoMenu]` 日志。Mod 没有游戏内错误弹窗或进度提示。

维护者于 2026-09-26 确认实机及联机测试全部通过并授权正式发布，具体范围见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-menu-v0.5.0/releases/validation.md#中文)。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/auto-menu-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文) · [MIT 许可证](LICENSE)
