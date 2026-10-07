# Fresh to Serve / 焕鲜上桌

[![Fresh to Serve / 焕鲜上桌 — AI-generated cover / AI 宣传封面](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/fresh-to-serve-mod/assets/cover.png?raw=1)](https://www.nexusmods.com/mods/3?game_id=10352)

[English](#english) · [中文](#中文)

## English

Clear spoiled cooked meals and finished drinks from kitchen passes, drink output areas and elevator serving slots. If the original customer is still waiting and has enough patience, request a replacement for the game's staff to prepare and serve.

**Source version: 0.1.3 (unpublished).** Single player or multiplayer host only. Only the host needs to install it; guests do not remove items or place replacement orders.

0.1.3 supports the game through **Steam Build 25759268 / 1.0.2.44eb**, fixing the table lookup that stopped automation at startup while retaining support for the earlier table spelling. The maintainer confirmed in-game testing passed on **2026-10-07**; see the [current validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/releases/validation.md#english). Multiplayer retesting on this build was not separately reported.

### How to use

1. Enter your restaurant in single player or as the multiplayer host. The Mod starts automatically and waits while the game is paused. There is no Mod menu, button, hotkey or setting to enable in the restaurant.
2. Take customer orders and run the kitchen/bar normally. Keep the ingredients, preparation equipment and staff needed for those orders available. Tables assigned to player service are excluded from this automation.
3. When the game classifies an eligible finished item as bad or very bad quality, the Mod removes it from its output position, freeing the slot. You do not need to aim at it, hold a tray or interact with a bin.
4. The Mod then checks the original customer, existing supply and remaining patience. If a remake qualifies, it adds a normal order for the kitchen or bar. Staff prepare and serve it through the usual game systems; you can also handle the resulting item normally.

Cleanup and replacement are separate: a spoiled item can disappear even when no replacement can be ordered. The Mod never restores freshness to the old item or resets the customer's patience.

### Cleanup coverage

| Item and location | What happens |
| --- | --- |
| Bad/very bad cooked meal waiting at a kitchen pass or in a registered elevator food-serving slot | Removes the meal and its plate; checks whether the original customer still needs a replacement. |
| Bad/very bad full, finished drink at a drink output area or in an elevator's dedicated drink slot | Removes the drink and its glass. Dispenser drinks, bottled drinks and completed cocktails are included. |
| Normal-quality item, dirty dish, already served or consumed item, or item being picked up/carried | Leaves it alone. This includes items already on a tray or food trolley. |
| Part-filled drink, active filling or cocktail pouring, or glass still at preparation equipment | Leaves it alone until it is a finished item in a supported output position. |
| Item belonging to a player-service table | Leaves it alone so that table remains under player control. |
| Bakery tray | Outside this version's cleanup coverage. |

Cleanup covers eligible output positions in the host's restaurant, including other floors; you do not have to stand next to them. Discarding also consumes the plate or glass: it does not return dirty dishes to the sink, refund ingredients or add trash to a bin. A replacement consumes the normal ingredients again.

### When a replacement is made

- The same customer must still be seated, waiting for that item from the same order round, and not already served or ready to check out. Leftovers from a previous seating or course do not create orders for new customers.
- Existing preparation orders and unserved items already available for that table count toward its demand, including items being carried to it. If enough supply already exists, no extra replacement is added. Different customers ordering the same item are handled separately.
- Food needs an available chef plus the game's normal ingredients and equipment requirements. Drinks need compatible equipment and a **working bartender on the customer's floor** whose task settings allow the required drink or cocktail preparation.
- While the bar queue contains player-claimed unfinished drinks, automatic drink remakes wait. The Mod keeps those claims intact; finish the claimed work so it can reassess the queue.
- The customer must have **more remaining patience than the estimated total time**. The estimate includes the new item's full preparation time, all unfinished work in that kitchen/bar queue, five seconds per queued item, and thirty seconds for dispatch and service. It does not assume multiple staff will work in parallel or subtract time already spent preparing queued items. Drinks also include equipment filling/interaction time and ten seconds for glass/ingredient handling.

For example, a meal taking 20 seconds with queued work of 10 and 30 seconds needs more than **100 seconds** of remaining patience: `20 + 10 + 30 + (2 × 5) + 30`. Exactly 100 seconds is insufficient. When the game's patience setting is disabled, the patience comparison is skipped, but the customer, demand and preparation requirements still apply. Unknown preparation timing or unavailable active patience prevents a replacement.

### When a replacement waits or stops

If staff, stock or equipment are temporarily unavailable, the pending replacement waits and rechecks. Rejected order requests are tried at most three times, at least ten seconds apart; pending replacements expire after 120 seconds of game time. Departure, a changed order, enough existing supply or insufficient patience ends that replacement attempt. Resolving the shortage after the attempt has ended does not recreate it automatically.

These estimates do not guarantee delivery: later staff changes, walking distance and other game delays may still prevent timely service. Accepted orders remain normal game orders even if the Mod is removed.

### Multiplayer

Only the host needs to install the Mod. Its cleanup and replacement orders use the host's restaurant state and are synchronized by the game. Guests can observe and handle the resulting items normally; installing only on a guest does not start cleanup or replacement ordering.

### Requirements

Windows x64 Parisian Bistro Simulator and **UE4SS experimental**. The checked loader build is `v3.0.1-1140-gf58e8f84`; stable UE4SS 3.0.1 is not supported. Other loader builds have not been verified. UE4SS is installed separately.

### Download

The published downloads below are **0.1.2** and **do not contain the new-build compatibility fix**. For 0.1.3, use `FreshToServe-0.1.3.zip` from the `mod-packages` artifact of a successful PR/CI build. 0.1.3 has not been published to GitHub Releases or Nexus.

Choose **one** download source for the published version; both provide the same Mod:

- **GitHub (no account needed):** open [Fresh to Serve 0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/fresh-to-serve-v0.1.2), scroll to **Assets**, expand it if needed and click **FreshToServe-0.1.2.zip**. `SHA256SUMS.txt` is an optional checksum file, not something to install. Do not choose **Source code**.
- **Nexus:** open the [Mod page](https://www.nexusmods.com/parisianbistrosimulator/mods/3), sign in or register a free account, select **Files → Main files → Manual download** for version **0.1.2**. Continue through the requirements notice if shown, select **Slow download** for a free account and wait for the ZIP. Keep the ZIP in your **Downloads** folder until the extraction step below.

### Install

These instructions start with only the Windows game installed. **Manual installation is free and does not require Vortex or a Nexus Premium subscription.** A web browser and Windows File Explorer are enough; Windows can extract ZIP files without WinRAR or 7-Zip. You do not need Git, Python, Visual Studio or Unreal Engine.

UE4SS is the **mod loader**: it starts the Mod when the game starts. Install it once for this game, then add any of the seven Mods to its `Mods` folder. Vortex is an optional **mod manager**, which copies and removes Mod files for you; it does not replace UE4SS.

1. **Exit the game completely.** In Steam, open **Library**, right-click **Parisian Bistro Simulator**, then choose **Manage → Browse local files**. The File Explorer window that opens is your game folder. Its name may be **Parisian Brasserie Simulator**. Do not use Documents or the save folder.
2. **Open the installation destination.** In that window, double-click **BrasserieSimulator**, then **Binaries**, then **Win64**. You should see **BrasserieSimulator-Win64-Shipping.exe** (Windows may hide `.exe`). Keep this window open. This is where the loader goes; do not put the loader beside the top-level `BrasserieSimulator.exe`.
3. **Download the loader.** Use [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip), the basic experimental build used as this project's reference. If the direct link fails, open [UE4SS experimental releases](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental), expand **Assets / Show all assets** and find that exact filename. Do not choose `zDEV`, `Source code` or the old stable `UE4SS_v3.0.1.zip`. Other experimental builds have not been verified for these Mods.
4. **Extract the loader ZIP.** In File Explorer's **Downloads** folder, right-click the downloaded ZIP → **Extract All… → Extract**. Open the extracted folder. Inside it, select **dwmapi.dll** and the entire **ue4ss** folder, right-click → **Copy**; return to the game's **Win64** window, right-click empty space → **Paste**. Copy both items themselves, not the outer folder named after the ZIP. There is no UE4SS installer to run. If you already have UE4SS installed, back up its folder and settings before replacing anything; keep your existing Mods.
5. **Check the loader location.** In **Win64**, `dwmapi.dll` must sit beside `BrasserieSimulator-Win64-Shipping.exe`. Open **ue4ss**: it must contain **UE4SS.dll**, **UE4SS-settings.ini** and **Mods**. If these are missing, repeat the extraction/copy step; an empty folder named `Mods` alone does not install the loader.
6. **Extract the Mod ZIP** downloaded above: right-click it → **Extract All… → Extract**. Open the extracted folder until you can see **FreshToServe**, the folder that contains **Scripts** and **enabled.txt**. Windows may show `enabled` without `.txt`; that is normal.
7. **Copy the whole FreshToServe folder.** Right-click it → **Copy**. In the game window, open **Win64 → ue4ss → Mods**, right-click empty space → **Paste**. Do not copy only `main.lua`, and do not place the ZIP itself in `Mods`.
8. **Check the result.** Open **Mods → FreshToServe → Scripts**: **main.lua** must be there. Go back once to **FreshToServe**: **enabled.txt** must be there beside **Scripts**. An extra `FreshToServe/FreshToServe` layer is incorrect. Leave `enabled.txt` as supplied, even if it is empty; it enables the Mod. Do not replace the loader's `mods.txt`.
9. **Start the game normally through Steam** and follow **How to use** above. Some Mods run in the background and have no startup message. Check the single-player/host/guest requirement at the top of this guide; the host is the player who opens the multiplayer restaurant for others to join.

The final entry point is `BrasserieSimulator/Binaries/Win64/ue4ss/Mods/FreshToServe/Scripts/main.lua`, starting from the Steam game folder. If the feature does not work, close the game, recheck the two folder layouts above, then open `Win64/ue4ss/UE4SS.log` with Notepad and look for a recent timestamp or an error. See [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) before reinstalling.

**Using Vortex instead:** follow the [Vortex setup guide](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#english) to install Vortex, this game's extension and UE4SS first. Then import the original Mod ZIP, install, enable and deploy it. Use one installation method for this Mod. **The [collection](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz) currently requires an active Nexus Premium membership for one-click installation.** A free Nexus account or GitHub download can still be used for individual Mods; GitHub downloads need no account.

If you used the earlier **Fresh Service** package, remove its old `Mods/FreshService` folder with the game closed before installing this Mod. Do not run both copies.

### Update or remove

**Update:** close the game, download and extract the new Mod ZIP, then copy its complete `FreshToServe` folder into the same `Mods` folder and replace matching files. Start the game again.

**Remove:** close the game and delete only `Mods/FreshToServe`. Leave UE4SS and other Mods in place. Removing the Mod does not restore discarded items or cancel orders already accepted by the game.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload). This is not required for normal installation or updates.

### Languages and help

Adds no in-game text. Dish names, drink names and order messages remain in the game's selected language; no language pack is needed. Technical logs remain English.

Game languages: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese.

If cleanup does not occur, check the host role, quality level, output location and player-service assignment first. If an item disappears without a remake, check customer patience, existing supply, stock, staff, equipment and unfinished player claims. After an error stops automation, leave and re-enter the restaurant. Include relevant `[FreshToServe]` lines from `UE4SS.log` with a problem report: `DISCARDED` means removed, `REQUEUED` means a replacement order was accepted, and `SKIPPED`/`DEFERRED` explain canceled or waiting attempts. `REQUEUED` does not mean the item has been served.

Version 0.1.2 passed in-game and multiplayer testing as reported by the maintainer on 2026-09-26; the [historical validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/fresh-to-serve-v0.1.2/releases/validation.md#english) describes that earlier scope.

If startup logs report `Missing Fresh to Serve` followed by `automation-stopped`, install a compatible update with the game closed and restart the game. Ctrl+R preserves the safety stop from that failure.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/fresh-to-serve-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) · [MIT License](LICENSE)

## 中文

自动清理厨房出餐台、饮料出品区及升降机出餐位上的低劣熟食和成品饮料；原顾客仍在等待且耐心足够时补单，由游戏原有员工制作并送达。

**源码版本：0.1.3（尚未发布）。** 仅单人或联机房主运行，只需房主安装，客机不执行清理或补单。

0.1.3 支持至 **Steam Build 25759268 / 1.0.2.44eb**，修复餐桌查询导致自动化在启动时停止的问题，同时保留此前餐桌拼写的支持。维护者于 **2026-10-07** 确认实机测试通过，见[当前验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/releases/validation.md#中文)；未单独反馈此游戏版本的联机复测结果。

### 怎么使用

1. 以单人玩家或联机房主身份进入餐厅。Mod 自动开始运行，游戏暂停期间等待；餐厅内没有需要另外启用的 Mod 菜单、按钮、快捷键或设置。
2. 照常给顾客点单并经营厨房／吧台，准备订单需要的原料、设备与员工。分配为玩家服务的餐桌不参与此自动流程。
3. 适用的成品被游戏判定为差或很差的品质后，Mod 将其从出品位置清理，释放该空位。无需对准餐品、拿托盘或操作垃圾桶。
4. 随后检查原顾客、已有供给及剩余耐心；符合重做条件时，给厨房或吧台追加正常订单。员工按游戏原有流程制作和送餐，玩家也可以照常处理新做出的餐品。

清理和补单是两个步骤：低劣成品即使无法补单也可能被移除。Mod 不会给旧成品恢复新鲜度，也不会重置顾客耐心。

### 清理范围

| 餐品与位置 | 处理方式 |
| --- | --- |
| 厨房出餐口或已登记升降机食物出餐位中的低劣熟食 | 连同餐盘一起移除，再检查原顾客是否仍需重做。 |
| 饮料出品区或升降机专用饮料位中的低劣满杯成品 | 连同杯子一起移除，涵盖饮料机饮料、瓶装饮料和完成的鸡尾酒。 |
| 正常品质成品、脏餐具、已上桌／正在食用或正在被拿取／搬运的餐品 | 不处理，已在托盘或送餐餐车上的餐品也保留。 |
| 未满杯、正在灌装／倒入鸡尾酒配料的饮料，或仍在制作设备上的杯子 | 不处理，须成为支持出品位置中的完整成品后才纳入检查。 |
| 属于玩家服务餐桌的餐品 | 不处理，继续由玩家负责。 |
| 烘焙托盘 | 不在本版清理范围内。 |

清理涵盖房主餐厅内的适用出品位，包括其他楼层，无需玩家站在旁边。餐盘或杯子会随成品一并消失，不返还脏餐具、不退原料，也不增加垃圾桶内的垃圾；重做还会照常再次消耗原料。

### 什么情况下会重做

- 原顾客仍坐在该桌，等待同一轮订单中的对应餐品，尚未收到餐品，也未进入可结账状态。上一批顾客或上一轮点餐遗留的餐品不会给新顾客生成订单。
- 已有制作订单及该桌尚未上桌的成品都计入供给，包括正在被搬运过去的餐品。已有数量足够时不再补单；多位顾客点同款餐品时按各自需求处理。
- 食物需要可用厨师及游戏原本要求的原料、设备。饮料需要适配设备，以及**顾客所在楼层正在工作的调酒师**，其任务设置须允许对应的饮料或鸡尾酒制作。
- 吧台队列中存在玩家已认领、尚未完成的饮料时，自动饮料重做会等待；不会取消玩家认领，完成已认领工作后才会重新评估队列。
- 顾客**剩余耐心须大于预计总耗时**。估算包含新餐品的完整制作时间、该厨房／吧台队列全部未完成工作、每份前序餐品五秒，以及调度和送餐三十秒；不假设多员工并行，也不扣除队列餐品已经制作的时间。饮料另计设备灌装／交互耗时及十秒取杯取料时间。

例如，重做一道菜需要二十秒，前面两份订单分别需要十秒和三十秒，则剩余耐心须**超过一百秒**：`20 + 10 + 30 + (2 × 5) + 30`，恰好一百秒也不补单。游戏中关闭耐心机制时跳过耐心比较，但仍须满足顾客、需求和制作条件；制作耗时不明或启用耐心后无法取得有效等待计时，也不会补单。

### 何时等待或停止补单

员工、库存或设备暂不可用时，待补单会等待并重新检查。游戏拒绝的补单请求最多尝试三次，两次至少间隔十秒；待补单在一百二十秒游戏时间后到期。顾客离开、订单变化、已有供给足够或耐心不足时，会结束该次补单；结束后才解决缺货等问题，不会自动重新创建这次补单。

估算不保证送达：后续员工变化、行走距离及其他游戏延迟仍可能导致来不及上桌。游戏已接受的补单会继续作为正常订单存在，即使随后卸载 Mod。

### 联机使用

只需房主安装。清理及补单依据房主餐厅状态运行，并由游戏同步结果；客机可以照常观察和处理新成品。只有客机安装时，不会执行清理或重做下单。

### 使用要求

Windows x64 版 Parisian Bistro Simulator，以及 **UE4SS experimental**。已核对的加载器版本为 `v3.0.1-1140-gf58e8f84`，不支持旧稳定版 UE4SS 3.0.1；其他加载器版本尚未验证。UE4SS 需单独安装。

### 下载

下方已发布下载均为 **0.1.2**，**不含新版游戏兼容修复**。0.1.3 请使用成功的 PR/CI 构建中 `mod-packages` 附件里的 `FreshToServe-0.1.3.zip`，目前尚未发布到 GitHub Releases 或 Nexus。

下载已发布版本时，以下来源**二选一**即可，提供的是同一个 Mod：

- **GitHub（无需账号）：**打开 [焕鲜上桌 0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/fresh-to-serve-v0.1.2)，向下找到并展开 **Assets（附件）**，点击 **FreshToServe-0.1.2.zip**。`SHA256SUMS.txt` 是可选的校验文件，无需安装；不要下载 **Source code（源码）**。
- **Nexus：**打开 [Mod 页面](https://www.nexusmods.com/parisianbistrosimulator/mods/3)，登录或注册免费账号，在 **Files（文件）→ Main files（主要文件）** 找到 **0.1.2**，点击 **Manual download（手动下载）**。如出现前置要求提示，继续到下载页；免费账号选择 **Slow download（慢速下载）**，等待 ZIP 下载完成。先把 ZIP 保存在**下载**文件夹，下面再解压。

### 安装

以下步骤从电脑上只安装了 Windows 版游戏开始。**手动安装免费，不需要 Vortex，也不需要 Nexus Premium 会员。** 用浏览器和 Windows 文件资源管理器即可操作；Windows 自带 ZIP 解压功能，无需安装 WinRAR 或 7-Zip，也不需要 Git、Python、Visual Studio 或虚幻引擎。

UE4SS 是**加载器**，作用是在启动游戏时运行 Mod。每个游戏安装目录只需装一次，之后把所需 Mod 加入它的 `Mods` 文件夹即可。Vortex 是可选的 **Mod 管理器**，负责复制和移除 Mod 文件，不能代替 UE4SS。

1. **完全退出游戏。** 在 Steam 打开**库**，右键 **Parisian Bistro Simulator（法式小馆儿模拟器）→ 管理 → 浏览本地文件**。弹出的文件资源管理器窗口就是游戏目录，文件夹名可能是 **Parisian Brasserie Simulator**。不是“文档”或存档文件夹。
2. **打开安装位置。** 在该窗口依次双击 **BrasserieSimulator → Binaries → Win64**，应该能看到 **BrasserieSimulator-Win64-Shipping.exe**（Windows 可能隐藏 `.exe` 后缀）。保留此窗口，加载器就放在这里；不要放在最外层 `BrasserieSimulator.exe` 旁边。
3. **下载加载器。** 点击 [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip)，这是本项目核对过的 experimental 基础包。若直链失效，打开 [UE4SS experimental 发布页](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental)，展开 **Assets / Show all assets（附件／显示全部附件）**，找到这个完整文件名。不要下载 `zDEV`、`Source code`，也不要使用旧稳定版 `UE4SS_v3.0.1.zip`。其他 experimental 构建尚未核验。
4. **解压并放入加载器。** 在文件资源管理器的**下载**文件夹里，右键刚下载的 ZIP → **全部解压缩 → 提取**。打开解压后的文件夹，选中里面的 **dwmapi.dll** 和整个 **ue4ss** 文件夹，右键**复制**；回到游戏的 **Win64** 窗口，在空白处右键**粘贴**。复制这两个项目本身，不要把以压缩包命名的外层文件夹一起套进去。UE4SS 没有需要双击运行的安装程序。已经安装过加载器时，替换前备份其文件夹和设置，并保留现有 Mod。
5. **检查加载器位置。** **Win64** 中的 `dwmapi.dll` 应与 `BrasserieSimulator-Win64-Shipping.exe` 并排。打开 **ue4ss**，里面应有 **UE4SS.dll**、**UE4SS-settings.ini** 和 **Mods**。缺少这些内容时回到上一步重新解压、复制；只新建一个空的 `Mods` 文件夹不能装好加载器。
6. **解压上面下载的 Mod ZIP。** 右键 ZIP → **全部解压缩 → 提取**。打开解压后的文件夹，找到 **FreshToServe** 文件夹；它里面应有 **Scripts** 和 **enabled.txt**。Windows 可能只显示 `enabled` 而隐藏 `.txt`，属于正常情况。
7. **复制整个 FreshToServe 文件夹。** 右键它 → **复制**。在游戏窗口打开 **Win64 → ue4ss → Mods**，在空白处右键**粘贴**。不要只复制 `main.lua`，也不要把 ZIP 本身放进去。
8. **检查安装结果。** 依次打开 **Mods → FreshToServe → Scripts**，应能看到 **main.lua**；返回一层到 **FreshToServe**，应能看到与 **Scripts** 并排的 **enabled.txt**。不要多套成 `FreshToServe/FreshToServe`。即使 `enabled.txt` 是空文件也应原样保留，它用于启用 Mod；不要替换加载器的 `mods.txt`。
9. **从 Steam 正常启动游戏**，按上方“怎么使用”操作。有的 Mod 在后台工作，没有启动提示。先核对本说明开头的单人／房主／客机要求；房主指开启联机餐厅、让其他人加入的玩家。

从 Steam 打开的游戏目录算起，最终脚本位置是 `BrasserieSimulator/Binaries/Win64/ue4ss/Mods/FreshToServe/Scripts/main.lua`。功能未生效时，先退出游戏、核对上述加载器和 Mod 两处目录，再用记事本打开 `Win64/ue4ss/UE4SS.log`，查看有没有本次运行的时间或错误。重装前可查看[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

**如果选择 Vortex：** 先按 [Vortex 安装说明](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#中文)装好 Vortex、本游戏扩展和 UE4SS，再导入原始 Mod ZIP，安装、启用并部署。同一个 Mod 只使用一种安装方式。**目前通过 [Nexus 合集](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz)一键安装需要有效的 Nexus Premium 会员。** 免费 Nexus 账号仍可逐个下载 Mod；GitHub 下载无需账号。

若安装过旧名 **Fresh Service** 的开发包，请先关闭游戏并删除旧的 `Mods/FreshService` 文件夹，避免同时运行两份。

### 更新与卸载

**更新：** 关闭游戏，下载并解压新版 Mod ZIP，把完整的 `FreshToServe` 文件夹复制到原来的 `Mods` 目录并覆盖同名文件，再启动游戏。

**卸载：** 关闭游戏，只删除 `Mods/FreshToServe`，保留 UE4SS 和其他 Mod。卸载不会恢复已丢弃的物品，也不会取消游戏已经接受的补单。

可选操作：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。正常安装和更新不需要此操作。

### 语言与帮助

不新增游戏内文字，菜名、饮料名和订单提示沿用游戏当前语言，无需语言包。技术日志保持英文。

游戏语言包括英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。

没有清理时，先检查房主身份、品质等级、出品位置和餐桌是否交给玩家服务。餐品被清理却没有重做时，检查顾客耐心、已有供给、库存、员工、设备及玩家未完成的认领。异常导致自动流程停止后，可退出餐厅并重新进入。反馈时附上 `UE4SS.log` 中相关的 `[FreshToServe]` 日志：`DISCARDED` 表示已清理，`REQUEUED` 表示补单已被接受，`SKIPPED`／`DEFERRED` 说明取消或等待原因；`REQUEUED` 不代表已经上桌。

维护者于 2026-09-26 确认 0.1.2 实机及联机测试全部通过并授权正式发布，该次范围见[历史验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/fresh-to-serve-v0.1.2/releases/validation.md#中文)。

若启动日志出现 `Missing Fresh to Serve`，随后输出 `automation-stopped`，请关闭游戏后安装兼容更新，再完整重启游戏。Ctrl+R 会保留此前失败的安全停止状态。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/fresh-to-serve-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文) · [MIT 许可证](LICENSE)
