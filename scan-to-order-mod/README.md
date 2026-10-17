# Scan to Order / 扫码点餐

[![Scan to Order / 扫码点餐 — AI-generated cover / AI 宣传封面](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/scan-to-order-mod/assets/cover.png?raw=1)](https://www.nexusmods.com/mods/7?game_id=10352)

[English](#english) · [中文](#中文)

## English

Automatically places seated customers' food and drink orders, so neither you nor a waiter has to take them. There is no QR code or phone to use.

**Version: 0.1.2.** Works in single player or for the multiplayer host. Only the host needs to install it.

### How to use

1. Enter your restaurant in single player or as the multiplayer host. The Mod starts on its own once you control your character; there is no menu, key or toggle.
2. Seat customers and let them choose food and drinks as usual. You don't need to walk to each table or assign a waiter to take the order.
3. When a seated customer is ready to order, the Mod places the order for them, checking about once per second. Food and drink orders go into the game's normal preparation queues and show the normal order notifications.
4. Prepare and serve the orders as usual. The Mod only places orders; cooking, making drinks, serving and payment stay with you and your staff.
5. Later courses and drinks for the same customer are ordered the same way. Each order is placed only once, and every table is covered automatically.

There is no separate progress screen. Follow orders through the game's order notifications and preparation queues, as in the screenshot below.

### When an order waits

- Customers keep their own choices. The Mod never changes the menu or picks a substitute.
- **Missing ingredients:** that item waits while the customer's other items can go ahead. Restock as usual; the Mod checks again and orders only what is still outstanding. Supplies are never bought automatically.
- **Staff and equipment:** the game's normal chef, bartender, equipment and speciality requirements still apply, and food needs at least one chef. Once the requirement is met, the item is ordered on a later check.
- **Tables you or a waiter handle:** tables marked for player service are left to you, and a table a waiter is currently taking an order from also waits. If you took over a table, finish its order through the normal interaction.
- **Pause:** no new orders while the game is paused; ordering continues when you unpause.
- **Customers who moved on:** only customers still seated at their table and waiting for that item get an order. Customers who left, items already served and groups ready to pay are skipped.
- **Patience:** if patience is on and a customer's order wait has run out, that order isn't placed. Waiting for supplies or staff doesn't pause the customer's patience.

In multiplayer, install the Mod on the host. It does nothing on a guest's game, so installing it only on a guest won't automate the restaurant.

To stop automatic ordering, close the game and remove the Mod; there is no in-game switch. Orders already placed stay in the queues and can be prepared and served.

### In-game screenshot

Food and drink order icons beside seated customers display green check marks.

![In-game food and drink order icons showing green check marks beside seated customers](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/scan-to-order-mod/assets/automatic-orders-gameplay.png?raw=1)

### Requirements

- Windows version of Parisian Bistro Simulator, up to game version 1.0.2.44eb (Steam Build 25822788).
- [UE4SS experimental](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental) `v3.0.1-1140-gf58e8f84`, installed separately (see **Install**). The older stable UE4SS 3.0.1 does not work.
- Single player or multiplayer host.

### Download

Pick either source; both have the same file. Use version 0.1.2 or newer on the current game.

- **GitHub (no account needed):** open [Scan to Order 0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/scan-to-order-v0.1.2) and download **ScanToOrder-0.1.2.zip** under **Assets**. Don't pick **Source code**.
- **Nexus:** open the [Mod page](https://www.nexusmods.com/parisianbistrosimulator/mods/7), go to **Files → Main files → Manual download**, then choose **Slow download** if you have a free account.

### Install

Manual installation is free and needs neither Vortex nor Nexus Premium.

UE4SS is the mod loader that runs Mods when the game starts. Install it once, then put Mods in its `Mods` folder. If UE4SS is already installed, start at step 6.

1. **Close the game.** In Steam, open **Library**, right-click **Parisian Bistro Simulator** → **Manage → Browse local files**. This opens the game folder (it may be named **Parisian Brasserie Simulator**).
2. **Open BrasserieSimulator → Binaries → Win64.** You should see **BrasserieSimulator-Win64-Shipping.exe** (Windows may hide the `.exe`). Keep this window open; the loader goes here.
3. **Download UE4SS:** [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip). If the link doesn't open, find that exact file under **Assets** on the [UE4SS experimental release page](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental). Don't use `zDEV`, `Source code` or the old stable `UE4SS_v3.0.1.zip`.
4. **Copy the loader into Win64.** Right-click the ZIP → **Extract All… → Extract**. From the extracted folder, copy **dwmapi.dll** and the **ue4ss** folder and paste both into **Win64**. If you are replacing an existing UE4SS, back up its folder first.
5. **Check the loader:** `dwmapi.dll` sits next to `BrasserieSimulator-Win64-Shipping.exe`, and the **ue4ss** folder contains **UE4SS.dll**, **UE4SS-settings.ini** and **Mods**.
6. **Extract the Mod ZIP** and open it until you see the **ScanToOrder** folder, which contains **Scripts** and **enabled.txt**.
7. **Copy the whole ScanToOrder folder** into **Win64 → ue4ss → Mods**.
8. **Check the Mod:** `Mods/ScanToOrder/Scripts/main.lua` and `Mods/ScanToOrder/enabled.txt` should exist (not `ScanToOrder/ScanToOrder`). Keep `enabled.txt` even if it is empty.
9. **Start the game through Steam** and follow **How to use** above.

If the Mod doesn't work, close the game, recheck steps 5 and 8, then see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english).

**Using Vortex instead:** set up Vortex, the game extension and UE4SS with the [Vortex guide](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#english), then import the Mod ZIP, enable it and deploy. Install each Mod either with Vortex or manually, not both. One-click install of the [collection](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz) requires Nexus Premium.

### Update or remove

**Update:** close the game, extract the new Mod ZIP and copy its whole `ScanToOrder` folder into the same `Mods` folder, replacing the existing files. Then start the game.

**Remove:** close the game and delete only `Mods/ScanToOrder`; leave UE4SS and other Mods in place. Orders already placed stay and can be served normally.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload). Normal installs and updates don't need this.

### Languages and help

The Mod adds no text of its own. Dish names and order notifications appear in the game's language: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese or Brazilian Portuguese.

**An order isn't placed:** check that you are the host and the game isn't paused, then check ingredients, staff, equipment, the customer's patience, and whether you or a waiter is handling the table. Missing stock and other normal game limits are rechecked automatically, so you don't need to reinstall or restart. Other items at the same table may already have been ordered.

**Automatic ordering stopped:** after an unexpected error, the Mod stops ordering in the current restaurant so no order is placed twice. Check the game's queues before taking the waiting order yourself. Leave and re-enter the restaurant to resume; reloading scripts isn't enough. If it keeps stopping, restart the game and include the `[ScanToOrder]` lines from `Win64/ue4ss/UE4SS.log` in your report.

**The log shows `Missing Scan to Order API`:** close the game completely, update the Mod, then start the game again. Pressing Ctrl+R or re-entering the restaurant doesn't clear this.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/scan-to-order-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) · [MIT License](LICENSE)

## 中文

自动为已入座的顾客提交食物和饮料订单，不用玩家或服务员去点餐，也不需要扫二维码或用手机。

**版本：0.1.2。** 适用于单人游戏或联机房主，只需房主安装。

### 怎么使用

1. 以单人玩家或联机房主身份进入餐厅。能控制角色后 Mod 自动运行，没有菜单、按键或开关。
2. 按平常流程安排顾客入座，让顾客自己选食物和饮料。不需要逐桌去点餐，也不用专门安排服务员。
3. 已入座顾客可以点餐时，Mod 会替顾客下单，大约每秒检查一次。食物和饮料订单进入游戏原有的制作队列，并照常弹出订单提醒。
4. 照常制作并上餐。Mod 只负责下单，做菜、调饮、上菜和收款仍由你和员工完成。
5. 同一位顾客后续的菜品和饮料也会这样自动下单。每份订单只提交一次，所有餐桌自动生效。

没有单独的进度界面，可通过游戏的订单提醒和制作队列查看订单，效果见下方截图。

### 哪些情况会等待

- 顾客点什么就下什么。Mod 不改菜单，也不替顾客换菜。
- **缺原料：**缺货的那一项先等待，同一位顾客的其他餐品可以先下单。照常补货后，Mod 会再次检查，只提交还没下单的部分；不会自动采购。
- **员工和设备：**仍须满足游戏原有的厨师、调酒师、设备和专长要求，点食物至少需要一名厨师。条件满足后，下一次检查就会下单。
- **玩家或服务员负责的餐桌：**标记为玩家负责的餐桌留给你处理，服务员正在点餐的餐桌也会等待。你接手的餐桌，请通过原有交互完成点餐。
- **暂停：**游戏暂停时不下新订单，取消暂停后继续。
- **顾客状态变化：**只为仍坐在餐桌旁、正在等这项餐品的顾客下单。已离开的顾客、已上过的餐品，以及准备结账的整桌客人都会跳过。
- **耐心：**开启耐心且顾客的点餐等待时间已耗尽时，不再提交该订单。等原料或等员工期间，顾客的耐心照样消耗。

联机时把 Mod 装在房主的电脑上。客机安装不起作用，只装在客机上无法让餐厅自动点餐。

游戏内没有开关。要停止自动点餐，关闭游戏并卸载 Mod 即可；已经提交的订单仍在队列中，可正常制作和上菜。

### 实机截图

已入座顾客旁的餐品与饮料订单图标显示绿色勾选标记。

![实机画面：已入座顾客旁的餐品与饮料订单图标显示绿色勾选标记](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/scan-to-order-mod/assets/automatic-orders-gameplay.png?raw=1)

### 使用要求

- Windows 版 Parisian Bistro Simulator，支持至游戏版本 1.0.2.44eb（Steam Build 25822788）。
- [UE4SS experimental](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental) `v3.0.1-1140-gf58e8f84`，需单独安装（见“安装”）。旧稳定版 UE4SS 3.0.1 无法使用。
- 单人游戏或联机房主。

### 下载

以下两个来源任选其一，文件相同。当前游戏版本请使用 0.1.2 或更新版本。

- **GitHub（无需账号）：**打开 [扫码点餐 0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/scan-to-order-v0.1.2)，在 **Assets（附件）** 下载 **ScanToOrder-0.1.2.zip**。不要选 **Source code（源码）**。
- **Nexus：**打开 [Mod 页面](https://www.nexusmods.com/parisianbistrosimulator/mods/7)，进入 **Files（文件）→ Main files（主要文件）→ Manual download（手动下载）**；免费账号选择 **Slow download（慢速下载）**。

### 安装

手动安装免费，不需要 Vortex，也不需要 Nexus Premium。

UE4SS 是 Mod 加载器，负责在游戏启动时运行 Mod。只需安装一次，之后把 Mod 放进它的 `Mods` 文件夹。已经装好 UE4SS 的，从第 6 步开始。

1. **退出游戏。** 在 Steam **库**中右键 **Parisian Bistro Simulator（法式小馆儿模拟器）→ 管理 → 浏览本地文件**，打开游戏目录（文件夹名可能是 **Parisian Brasserie Simulator**）。
2. **依次打开 BrasserieSimulator → Binaries → Win64**，能看到 **BrasserieSimulator-Win64-Shipping.exe**（Windows 可能隐藏 `.exe` 后缀）。保持这个窗口打开，加载器就装在这里。
3. **下载 UE4SS：**[UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip)。链接打不开时，到 [UE4SS experimental 发布页](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental)的 **Assets** 中找同名文件。不要下载 `zDEV`、`Source code` 或旧稳定版 `UE4SS_v3.0.1.zip`。
4. **把加载器放进 Win64。** 右键 ZIP → **全部解压缩 → 提取**，从解压出的文件夹中复制 **dwmapi.dll** 和 **ue4ss** 文件夹，粘贴到 **Win64**。替换已有的 UE4SS 前，先备份原文件夹。
5. **检查加载器：**`dwmapi.dll` 与 `BrasserieSimulator-Win64-Shipping.exe` 在同一层；**ue4ss** 文件夹里有 **UE4SS.dll**、**UE4SS-settings.ini** 和 **Mods**。
6. **解压 Mod ZIP**，打开到能看到 **ScanToOrder** 文件夹，里面有 **Scripts** 和 **enabled.txt**。
7. **把整个 ScanToOrder 文件夹**复制到 **Win64 → ue4ss → Mods**。
8. **检查 Mod：**应有 `Mods/ScanToOrder/Scripts/main.lua` 和 `Mods/ScanToOrder/enabled.txt`（不要多套一层 `ScanToOrder/ScanToOrder`）。`enabled.txt` 即使是空文件也要保留。
9. **从 Steam 启动游戏**，按上方“怎么使用”操作。

不生效时，先退出游戏，核对第 5、8 步，再查看[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

**改用 Vortex：**先按 [Vortex 安装说明](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#中文)装好 Vortex、游戏扩展和 UE4SS，再导入 Mod ZIP，启用并部署。同一个 Mod 只用 Vortex 或手动其中一种方式安装。通过 [Nexus 合集](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz)一键安装需要 Nexus Premium。

### 更新与卸载

**更新：**关闭游戏，解压新版 Mod ZIP，把整个 `ScanToOrder` 文件夹复制到原来的 `Mods` 文件夹并覆盖原文件，再启动游戏。

**卸载：**关闭游戏，只删除 `Mods/ScanToOrder`，保留 UE4SS 和其他 Mod。已经提交的订单仍会保留，可正常上菜。

可选操作：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。正常安装和更新不需要。

### 语言与帮助

Mod 不新增文字。菜名和订单提醒沿用游戏当前语言：英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语或巴西葡萄牙语。

**订单没有提交：**先确认自己是房主、游戏没有暂停，再检查原料、员工、设备、顾客耐心，以及餐桌是否由你或服务员负责。缺货等正常限制会自动复查，无需重装或重启。同桌其他餐品可能已经下单。

**自动点餐停止：**出现意外错误时，Mod 会停止处理当前餐厅，避免重复下单。自己接手前，先看一下游戏的制作队列。退出餐厅再重新进入即可恢复，仅重新加载脚本不行。仍然停止时，请重启游戏，并在反馈中附上 `Win64/ue4ss/UE4SS.log` 中的 `[ScanToOrder]` 日志。

**日志出现 `Missing Scan to Order API`：**完全退出游戏，更新 Mod 后再启动。按 Ctrl+R 或重新进入餐厅都无法解除。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/scan-to-order-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文) · [MIT 许可证](LICENSE)
