# Fresh to Serve / 焕鲜上桌

[![Fresh to Serve / 焕鲜上桌 — AI-generated cover / AI 宣传封面](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/fresh-to-serve-mod/assets/cover.png?raw=1)](https://www.nexusmods.com/mods/3?game_id=10352)

[English](#english) · [中文](#中文)

## English

Clears spoiled cooked meals and finished drinks from kitchen passes, drink output areas and elevator serving slots. If the original customer is still waiting and has enough patience, it orders a replacement that your staff prepare and serve as usual.

**Version: 0.1.4.** Single player or multiplayer host. Only the host installs it; guests don't need it.

### How to use

1. Enter your restaurant in single player or as the multiplayer host. The Mod starts on its own and pauses while the game is paused. There is no menu, button, hotkey or setting.
2. Take orders and run the kitchen and bar as usual. Keep the ingredients, equipment and staff those orders need. Tables assigned to player service are left to you.
3. When a finished item drops to bad or very bad quality, the Mod removes it and frees its slot. You don't need to pick it up or use a bin.
4. The Mod then checks the original customer, items already on the way and remaining patience. If a remake makes sense, it adds a normal order for the kitchen or bar. Staff prepare and serve it, and you can also handle the new item yourself.

Cleanup and replacement are separate steps: a spoiled item is removed even when no replacement can be ordered. The old item's freshness and the customer's patience are never reset.

### What gets cleared

| Item and location | What happens |
| --- | --- |
| Bad or very bad cooked meal at a kitchen pass or an elevator food slot | Removed with its plate. The Mod then checks whether the customer still needs a replacement. |
| Bad or very bad full, finished drink at a drink output area or an elevator drink slot | Removed with its glass. Covers dispenser drinks, bottled drinks and finished cocktails. |
| Normal-quality items, dirty dishes, served or eaten items, and items being picked up or carried (including on a tray or food trolley) | Left alone. |
| Part-filled drinks, drinks still being filled or poured, and glasses still at the equipment | Left alone until they are finished and placed in an output slot. |
| Items for a player-service table | Left alone. |
| Bakery trays | Not covered in this version. |

Cleanup works on every floor of the host's restaurant; you don't need to stand nearby. The plate or glass is used up along with the item: no dirty dish goes to the sink, no ingredients are refunded and nothing goes into a bin. A replacement uses ingredients again as normal.

### When a replacement is ordered

- The same customer is still seated, still waiting for that item from the same order round, and hasn't been served or asked for the bill. Leftovers from earlier customers or courses never create orders for new customers.
- Orders already being prepared and unserved items for that table, including ones being carried there, count first. If they already cover the order, nothing extra is added. Customers who order the same item are counted separately.
- Food needs a free chef plus the usual ingredients and equipment. Drinks need suitable equipment and a **working bartender on the customer's floor** whose task settings allow that drink or cocktail.
- If you have claimed unfinished drinks in the bar queue, drink remakes wait until you finish them. Your claims are kept.
- The customer needs **more remaining patience than the estimated total time**: the new item's full preparation time, plus all unfinished work in that kitchen or bar queue, plus 5 seconds per queued item, plus 30 seconds to dispatch and serve. Drinks add the equipment fill and use time and 10 seconds to fetch the glass and ingredients. The estimate is cautious: it counts every queued item in full, as if one staff member made them in turn.

Example: a 20-second meal with queued work of 10 and 30 seconds needs more than **100 seconds** of patience: `20 + 10 + 30 + (2 × 5) + 30`. Exactly 100 seconds is not enough.

If customer patience is turned off in the game settings, the patience check is skipped; the other conditions still apply. If the preparation time or the customer's patience can't be read, no replacement is ordered.

### When a replacement waits or stops

- If staff, stock or equipment are briefly unavailable, the replacement waits and checks again.
- If the game rejects the order, the Mod tries up to three times, at least 10 seconds apart.
- A waiting replacement expires after 120 seconds of game time.
- The attempt ends if the customer leaves, the order changes, enough supply already exists or patience runs short. Fixing a shortage afterwards doesn't bring that attempt back.

### Multiplayer

Only the host needs the Mod. Cleanup and replacement orders run on the host's restaurant, and the game syncs the results to guests, who can see and handle the new items as usual. If only a guest installs it, nothing happens.

### Requirements

- Windows version of Parisian Bistro Simulator, up to game version 1.0.2.44eb (Steam Build 25822788).
- [UE4SS experimental](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental) `v3.0.1-1140-gf58e8f84`, installed separately (see **Install**). The older stable UE4SS 3.0.1 does not work.
- Single player, or you are the multiplayer host.

### Download

Pick either source; both have the same file.

- **GitHub (no account needed):** open [Fresh to Serve 0.1.4](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/fresh-to-serve-v0.1.4) and download **FreshToServe-0.1.4.zip** under **Assets**. Don't pick **Source code**.
- **Nexus:** open the [Mod page](https://www.nexusmods.com/parisianbistrosimulator/mods/3), go to **Files → Main files → Manual download**, then choose **Slow download** if you have a free account.

### Install

Manual installation is free and needs neither Vortex nor Nexus Premium.

UE4SS is the mod loader that runs Mods when the game starts. Install it once, then put Mods in its `Mods` folder. If UE4SS is already installed, start at step 6.

1. **Close the game.** In Steam, open **Library**, right-click **Parisian Bistro Simulator** → **Manage → Browse local files**. This opens the game folder (it may be named **Parisian Brasserie Simulator**).
2. **Open BrasserieSimulator → Binaries → Win64.** You should see **BrasserieSimulator-Win64-Shipping.exe** (Windows may hide the `.exe`). Keep this window open; the loader goes here.
3. **Download UE4SS:** [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip). If the link doesn't open, find that exact file under **Assets** on the [UE4SS experimental release page](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental). Don't use `zDEV`, `Source code` or the old stable `UE4SS_v3.0.1.zip`.
4. **Copy the loader into Win64.** Right-click the ZIP → **Extract All… → Extract**. From the extracted folder, copy **dwmapi.dll** and the **ue4ss** folder and paste both into **Win64**. If you are replacing an existing UE4SS, back up its folder first.
5. **Check the loader:** `dwmapi.dll` sits next to `BrasserieSimulator-Win64-Shipping.exe`, and the **ue4ss** folder contains **UE4SS.dll**, **UE4SS-settings.ini** and **Mods**.
6. **Extract the Mod ZIP** and open it until you see the **FreshToServe** folder, which contains **Scripts** and **enabled.txt**.
7. **Copy the whole FreshToServe folder** into **Win64 → ue4ss → Mods**.
8. **Check the Mod:** `Mods/FreshToServe/Scripts/main.lua` and `Mods/FreshToServe/enabled.txt` should exist (not `FreshToServe/FreshToServe`). Keep `enabled.txt` even if it is empty.
9. **Start the game through Steam** and follow **How to use** above.

If you used the earlier **Fresh Service** package, delete its `Mods/FreshService` folder with the game closed. Don't run both.

If the Mod doesn't work, close the game, recheck steps 5 and 8, then see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english).

**Using Vortex instead:** set up Vortex, the game extension and UE4SS with the [Vortex guide](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#english), then import the Mod ZIP, enable it and deploy. Install each Mod either with Vortex or manually, not both. One-click install of the [collection](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz) requires Nexus Premium.

### Update or remove

**Update:** close the game, extract the new Mod ZIP, copy its whole `FreshToServe` folder into the same `Mods` folder and replace the existing files. Start the game again.

**Remove:** close the game and delete only `Mods/FreshToServe`, leaving UE4SS and other Mods in place.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload). This is not required for normal installation or updates.

### Languages and help

The Mod adds no text of its own. Dish names, drink names and order messages follow the game language: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese.

- **Nothing is cleared:** check that you are the host, the item is bad or very bad, it sits in a covered slot, and its table isn't set to player service.
- **An item is cleared but not remade:** check customer patience, items already on the way, stock, staff, equipment and any drinks you have claimed but not finished.
- **The Mod stopped after an error:** leave the restaurant and enter it again.
- **The log shows `Missing Fresh to Serve` followed by `automation-stopped`:** close the game, install the latest version and start the game again. Ctrl+R doesn't clear this.
- **Reporting a problem:** include the `[FreshToServe]` lines from `Win64/ue4ss/UE4SS.log`. `DISCARDED` means an item was removed, `REQUEUED` means a replacement order was accepted (not yet served), and `SKIPPED` or `DEFERRED` give the reason an attempt ended or is waiting.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/fresh-to-serve-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) · [PolyForm Noncommercial License 1.0.0](LICENSE)

## 中文

自动清理厨房出餐口、饮料出品区和升降机出餐位上变质的熟食和成品饮料。原顾客仍在等待且耐心足够时，自动补单，由员工照常制作并送达。

**版本：0.1.4。** 适用于单人游戏或联机房主。只需房主安装，客机无需安装。

### 怎么使用

1. 以单人或联机房主身份进入餐厅。Mod 自动运行，游戏暂停时也随之暂停。没有菜单、按钮、快捷键或设置项。
2. 照常点单、经营厨房和吧台，备好订单所需的原料、设备和员工。分配为玩家服务的餐桌由你自己负责。
3. 成品品质降到差或很差时，Mod 会将其移除并腾出位置，无需手动拿取或使用垃圾桶。
4. 随后检查原顾客、已在途的餐品和剩余耐心。需要重做时，给厨房或吧台追加一张普通订单，员工制作并上桌；你也可以亲自处理新做好的餐品。

清理和补单是两个独立步骤：即使无法补单，变质的成品也会被移除。旧成品的新鲜度和顾客耐心都不会被重置。

### 清理范围

| 餐品与位置 | 处理方式 |
| --- | --- |
| 厨房出餐口或升降机食物位上品质差／很差的熟食 | 连同餐盘一起移除，再检查顾客是否仍需重做。 |
| 饮料出品区或升降机饮料位上品质差／很差的满杯成品 | 连同杯子一起移除，包括饮料机饮料、瓶装饮料和调好的鸡尾酒。 |
| 正常品质的成品、脏餐具、已上桌或正在食用的餐品，以及正在被拿取或搬运的餐品（包括托盘和送餐餐车上的） | 不处理。 |
| 未满杯、正在灌装或调制的饮料，以及仍在设备上的杯子 | 不处理，做好并放到出品位后才会检查。 |
| 玩家服务餐桌的餐品 | 不处理。 |
| 烘焙托盘 | 本版不处理。 |

清理覆盖房主餐厅的所有楼层，无需站在旁边。餐盘或杯子会随成品一起消失：不会产生脏餐具、不退原料，也不会增加垃圾。重做时照常消耗原料。

### 什么情况下会补单

- 原顾客仍在座，仍在等同一轮点单里的这份餐品，尚未上菜，也没有要求结账。上一批顾客或上一道菜遗留的餐品，不会给新顾客生成订单。
- 已在制作的订单和该桌尚未上桌的成品（包括正在送过去的）会先计入。数量已经够了就不再补单。多位顾客点了同款餐品时，按各自需求分别计算。
- 食物需要空闲厨师和平常所需的原料、设备。饮料需要合适的设备，以及**顾客所在楼层正在上班的调酒师**，且其任务设置允许制作该饮料或鸡尾酒。
- 吧台队列里有你认领但未完成的饮料时，饮料重做会等你完成后再进行，你的认领不受影响。
- 顾客**剩余耐心必须大于预计总耗时**：新餐品的完整制作时间，加上该厨房或吧台队列中全部未完成的工作，每份排队餐品再加 5 秒，最后加 30 秒调度和上菜时间。饮料另加设备灌装和操作时间，以及 10 秒取杯取料时间。估算偏保守：队列中每份都按完整耗时计算，相当于由一名员工依次制作。

例如：一道菜需要 20 秒，前面排着 10 秒和 30 秒的两份订单，则剩余耐心须**超过 100 秒**：`20 + 10 + 30 + (2 × 5) + 30`。恰好 100 秒不会补单。

游戏设置中关闭顾客耐心时，跳过耐心比较，其余条件照常检查。读不到制作时间或顾客耐心时，不会补单。

### 何时等待或停止补单

- 员工、库存或设备暂时不可用时，补单会等待并重新检查。
- 游戏拒绝订单时，最多尝试三次，每次至少间隔 10 秒。
- 等待中的补单在 120 秒游戏时间后作废。
- 顾客离开、订单变化、已有足够供给或耐心不足时，本次补单结束。之后再补齐缺货，也不会重新发起这次补单。

### 联机使用

只需房主安装。清理和补单都在房主的餐厅中进行，结果由游戏同步给客机，客机可以照常查看和处理新做好的餐品。只有客机安装时不会生效。

### 使用要求

- Windows 版 Parisian Bistro Simulator，支持至游戏版本 1.0.2.44eb（Steam Build 25822788）。
- [UE4SS experimental](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental) `v3.0.1-1140-gf58e8f84`，需单独安装（见“安装”）。旧稳定版 UE4SS 3.0.1 无法使用。
- 单人游戏，或你是联机房主。

### 下载

以下两个来源任选其一，文件相同。

- **GitHub（无需账号）：**打开 [焕鲜上桌 0.1.4](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/fresh-to-serve-v0.1.4)，在 **Assets（附件）** 下载 **FreshToServe-0.1.4.zip**。不要选 **Source code（源码）**。
- **Nexus：**打开 [Mod 页面](https://www.nexusmods.com/parisianbistrosimulator/mods/3)，进入 **Files（文件）→ Main files（主要文件）→ Manual download（手动下载）**；免费账号选择 **Slow download（慢速下载）**。

### 安装

手动安装免费，不需要 Vortex，也不需要 Nexus Premium。

UE4SS 是 Mod 加载器，负责在游戏启动时运行 Mod。只需安装一次，之后把 Mod 放进它的 `Mods` 文件夹。已经装好 UE4SS 的，从第 6 步开始。

1. **退出游戏。** 在 Steam **库**中右键 **Parisian Bistro Simulator（法式小馆儿模拟器）→ 管理 → 浏览本地文件**，打开游戏目录（文件夹名可能是 **Parisian Brasserie Simulator**）。
2. **依次打开 BrasserieSimulator → Binaries → Win64**，能看到 **BrasserieSimulator-Win64-Shipping.exe**（Windows 可能隐藏 `.exe` 后缀）。保持这个窗口打开，加载器就装在这里。
3. **下载 UE4SS：**[UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip)。链接打不开时，到 [UE4SS experimental 发布页](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental)的 **Assets** 中找同名文件。不要下载 `zDEV`、`Source code` 或旧稳定版 `UE4SS_v3.0.1.zip`。
4. **把加载器放进 Win64。** 右键 ZIP → **全部解压缩 → 提取**，从解压出的文件夹中复制 **dwmapi.dll** 和 **ue4ss** 文件夹，粘贴到 **Win64**。替换已有的 UE4SS 前，先备份原文件夹。
5. **检查加载器：**`dwmapi.dll` 与 `BrasserieSimulator-Win64-Shipping.exe` 在同一层；**ue4ss** 文件夹里有 **UE4SS.dll**、**UE4SS-settings.ini** 和 **Mods**。
6. **解压 Mod ZIP**，打开到能看到 **FreshToServe** 文件夹，里面有 **Scripts** 和 **enabled.txt**。
7. **把整个 FreshToServe 文件夹**复制到 **Win64 → ue4ss → Mods**。
8. **检查 Mod：**应有 `Mods/FreshToServe/Scripts/main.lua` 和 `Mods/FreshToServe/enabled.txt`（不要多套一层 `FreshToServe/FreshToServe`）。`enabled.txt` 即使是空文件也要保留。
9. **从 Steam 启动游戏**，按上方“怎么使用”操作。

装过旧名 **Fresh Service** 的安装包时，先关闭游戏，删除旧的 `Mods/FreshService` 文件夹，不要两份同时运行。

不生效时，先退出游戏，核对第 5、8 步，再查看[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

**改用 Vortex：**先按 [Vortex 安装说明](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#中文)装好 Vortex、游戏扩展和 UE4SS，再导入 Mod ZIP，启用并部署。同一个 Mod 只用 Vortex 或手动其中一种方式安装。通过 [Nexus 合集](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz)一键安装需要 Nexus Premium。

### 更新与卸载

**更新：** 关闭游戏，解压新版 Mod ZIP，把完整的 `FreshToServe` 文件夹复制到原来的 `Mods` 目录并覆盖同名文件，再启动游戏。

**卸载：** 关闭游戏，只删除 `Mods/FreshToServe`，保留 UE4SS 和其他 Mod。

可选操作：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。正常安装和更新不需要此操作。

### 语言与帮助

本 Mod 不添加自己的文字，菜名、饮料名和订单提示跟随游戏语言：英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。

- **没有清理：** 检查你是否为房主、品质是否为差或很差、餐品是否在支持的出品位上，以及该桌是否交给玩家服务。
- **清理了但没有重做：** 检查顾客耐心、已在途的餐品、库存、员工、设备，以及你认领但尚未完成的饮料。
- **出错后 Mod 停止工作：** 退出餐厅再重新进入。
- **日志出现 `Missing Fresh to Serve`，随后是 `automation-stopped`：** 关闭游戏，安装最新版本后重新启动游戏。Ctrl+R 无法解除这种停止。
- **反馈问题：** 附上 `Win64/ue4ss/UE4SS.log` 中的 `[FreshToServe]` 日志。`DISCARDED` 表示已移除餐品，`REQUEUED` 表示补单已被接受（尚未上桌），`SKIPPED`／`DEFERRED` 说明本次补单结束或等待的原因。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/fresh-to-serve-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文) · [PolyForm Noncommercial 1.0.0 许可](LICENSE)
