# Fresh to Serve / 焕鲜上桌

[![Fresh to Serve / 焕鲜上桌 — AI-generated cover / AI 宣传封面](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/fresh-to-serve-mod/assets/cover.png?raw=1)](https://www.nexusmods.com/mods/3?game_id=10352)

[English](#english) · [中文](#中文)

## English

Clear spoiled cooked meals and finished drinks from kitchen passes, drink output areas and elevator serving slots. If the original customer is still waiting and has enough patience, request a replacement for the game's staff to prepare and serve.

**Version: 0.1.2.** Single player or multiplayer host only. Only the host needs to install it; guests do not remove items or place replacement orders.

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

1. Open [Fresh to Serve 0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/fresh-to-serve-v0.1.2).
2. Under **Assets**, download **`FreshToServe-0.1.2.zip`** and `SHA256SUMS.txt`. Extract the Mod ZIP; GitHub's **Source code** archive is not an installable Mod.

If the package is missing or you cannot access it, see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english).

### Install

1. Close the game. In Steam, right-click **Parisian Bistro Simulator** → **Manage** → **Browse local files**. This opens the `<game>` folder used below.
2. Install the basic experimental UE4SS package using the [UE4SS installation guide](https://docs.ue4ss.com/dev/installation-guide.html), keeping that package's folder structure.
3. Copy the extracted **`FreshToServe`** folder, with all its contents, into `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/`. If your loader uses another location, use its existing `Mods` folder instead.
4. Confirm these files exist, with no extra `FreshToServe/FreshToServe` folder:

   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/FreshToServe/Scripts/main.lua`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/FreshToServe/enabled.txt`

5. Start the game and enter your restaurant in single player or as the multiplayer host.

The included `enabled.txt` enables the Mod. Keep the whole Mod folder together; do not replace the loader's `mods.txt` or other Mods.

If you used the earlier **Fresh Service** package, remove its old `Mods/FreshService` folder with the game closed before installing this Mod. Do not run both copies.

### Update or remove

**Update:** close the game, download and extract the new Mod ZIP, then copy its complete `FreshToServe` folder into the same `Mods` folder and replace matching files. Start the game again.

**Remove:** close the game and delete only `Mods/FreshToServe`. Leave UE4SS and other Mods in place. Removing the Mod does not restore discarded items or cancel orders already accepted by the game.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload). This is not required for normal installation or updates.

### Languages and help

Adds no in-game text. Dish names, drink names and order messages remain in the game's selected language; no language pack is needed. Technical logs remain English.

Game languages: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese.

If cleanup does not occur, check the host role, quality level, output location and player-service assignment first. If an item disappears without a remake, check customer patience, existing supply, stock, staff, equipment and unfinished player claims. After an error stops automation, leave and re-enter the restaurant. Include relevant `[FreshToServe]` lines from `UE4SS.log` with a problem report: `DISCARDED` means removed, `REQUEUED` means a replacement order was accepted, and `SKIPPED`/`DEFERRED` explain canceled or waiting attempts. `REQUEUED` does not mean the item has been served.

In-game and multiplayer testing passed as reported by the maintainer on 2026-09-26; the [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/fresh-to-serve-v0.1.2/releases/validation.md#english) describes its scope.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/fresh-to-serve-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) · [MIT License](LICENSE)

## 中文

自动清理厨房出餐台、饮料出品区及升降机出餐位上的低劣熟食和成品饮料；原顾客仍在等待且耐心足够时补单，由游戏原有员工制作并送达。

**版本：0.1.2。** 仅单人或联机房主运行，只需房主安装，客机不执行清理或补单。

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

1. 打开 [焕鲜上桌 0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/fresh-to-serve-v0.1.2)。
2. 在 **Assets** 中下载 **`FreshToServe-0.1.2.zip`** 和 `SHA256SUMS.txt`。解压 Mod ZIP；GitHub 的 **Source code** 是源码，不能当作安装包。

找不到文件或无法访问时，见[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

### 安装

1. 关闭游戏。在 Steam 中右键 **Parisian Bistro Simulator** → **管理** → **浏览本地文件**，打开的就是下方所说的 `<game>` 游戏目录。
2. 按 [UE4SS 安装说明](https://docs.ue4ss.com/dev/installation-guide.html)安装 experimental 的基础包，保留该发行包自己的目录结构。
3. 将解压出的 **`FreshToServe`** 文件夹连同全部内容复制到 `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/`。若加载器实际装在其他位置，请使用它已有的 `Mods` 文件夹。
4. 确认存在以下文件，不要多套一层 `FreshToServe/FreshToServe` 文件夹：

   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/FreshToServe/Scripts/main.lua`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/FreshToServe/enabled.txt`

5. 启动游戏，以单人玩家或联机房主身份进入餐厅。

包内的 `enabled.txt` 会启用 Mod。请完整保留 Mod 文件夹，不要替换加载器的整个 `mods.txt` 或其他 Mod。

若安装过旧名 **Fresh Service** 的开发包，请先关闭游戏并删除旧的 `Mods/FreshService` 文件夹，避免同时运行两份。

### 更新与卸载

**更新：** 关闭游戏，下载并解压新版 Mod ZIP，把完整的 `FreshToServe` 文件夹复制到原来的 `Mods` 目录并覆盖同名文件，再启动游戏。

**卸载：** 关闭游戏，只删除 `Mods/FreshToServe`，保留 UE4SS 和其他 Mod。卸载不会恢复已丢弃的物品，也不会取消游戏已经接受的补单。

可选操作：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。正常安装和更新不需要此操作。

### 语言与帮助

不新增游戏内文字，菜名、饮料名和订单提示沿用游戏当前语言，无需语言包。技术日志保持英文。

游戏语言包括英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。

没有清理时，先检查房主身份、品质等级、出品位置和餐桌是否交给玩家服务。餐品被清理却没有重做时，检查顾客耐心、已有供给、库存、员工、设备及玩家未完成的认领。异常导致自动流程停止后，可退出餐厅并重新进入。反馈时附上 `UE4SS.log` 中相关的 `[FreshToServe]` 日志：`DISCARDED` 表示已清理，`REQUEUED` 表示补单已被接受，`SKIPPED`／`DEFERRED` 说明取消或等待原因；`REQUEUED` 不代表已经上桌。

维护者于 2026-09-26 确认实机及联机测试全部通过并授权正式发布，具体范围见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/fresh-to-serve-v0.1.2/releases/validation.md#中文)。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/fresh-to-serve-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文) · [MIT 许可证](LICENSE)
