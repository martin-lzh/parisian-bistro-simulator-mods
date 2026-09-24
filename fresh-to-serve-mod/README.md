# Fresh to Serve / 焕新上桌

[English](#english) · [中文](#中文)

## English

Fresh to Serve removes poor-quality cooked meals and finished drinks from kitchen passes, drink output areas and elevator serving slots. When the original customer is still waiting and has enough patience, it requests a replacement from the kitchen or bar. The game's waiters collect and serve it normally. Finished cocktails are included.

Current version: **0.1.1-dev — awaiting in-game acceptance**.

### Behavior

- Checks once per second in a single-player or host session. Multiplayer clients do not clean up or place orders.
- Uses the game's two negative quality categories. Healthy items, dirty plates/glasses, served items, items being consumed or picked up, and items attached to another actor are excluded. Partial glasses, active filling/pouring and tables marked for player service are excluded.
- Confirms the original customer, table, group and order; counts existing items and queued replacements to prevent duplicate orders, including several customers ordering the same meal or drink. Drink order IDs identify the original customer's order.
- Requires remaining patience to exceed the relevant kitchen/bar backlog, replacement preparation time and a 30-second dispatch/service allowance. Each earlier queued item adds its full preparation time plus 5 seconds. Parallel staff and preparation bonuses do not shorten this estimate. With patience disabled, only this time limit is omitted.
- Drinks use the assigned floor's live equipment fill/interaction durations, recipe preparation time and 10 seconds for glass/ingredient handling. Unknown timing prevents a remake. A working bartender assigned to that floor must allow the relevant preparation task. Unfinished player-claimed drink orders defer automatic remakes without changing those claims.
- If the customer has left, the order changed, patience is insufficient or timing cannot be established, the spoiled item is removed without a replacement. Patience is never reset or extended.
- Orders use the normal kitchen/bar paths, retaining ingredients and preparation requirements. Rejected requests receive at most three attempts, at least 10 seconds apart; pending work expires after 120 seconds. Each attempt checks customer and patience again.

Cleanup removes the entire spoiled item and frees its pickup position. It does not add a walking-to-trash animation, return a dirty plate or glass to the sink, refund ingredients, or increase bin contents. Carried trolleys, served items, glasses still at dispensers and bakery trays are outside this version's cleanup scope. Staffing, ingredients, navigation and production capacity still affect delivery. The time budget is an estimate, not a guarantee against later delays.

### Installation

Baseline: Windows / Steam Build **25393699**, game **1.0.0.44eb**, Unreal **5.4**. Requires **UE4SS experimental**, with the locally checked API `v3.0.1-1140-gf58e8f84`; old stable UE4SS 3.0.1 is not supported.

1. Close the game yourself and install the required loader if needed.
2. Obtain `FreshToServe-0.1.1-dev.zip` and its `.sha256` from the matching CI artifact, or run `python fresh-to-serve-mod/build.py` from the repository root.
3. Extract `FreshToServe/` into the loader's `Mods/`. Confirm `enabled.txt` and `Scripts/main.lua` are present.
4. Start the game and host your restaurant. No hotkey or configuration is needed.

If you installed the earlier Fresh Service package, close the game and remove its `Mods/FreshService/` folder before enabling `FreshToServe/`. Running both copies would duplicate the automation.

To disable, close the game and remove `FreshToServe/enabled.txt` or the Mod folder. This does not undo discarded items or accepted orders. Builds never install the Mod, change saves or start/close the game. No game files or loader are bundled.

No player-facing text is added; names and order UI stay in the game's language. Technical logs use `[FreshToServe]`: `DISCARDED`, `REQUEUED`, `SKIPPED`, `DEFERRED`, `ERROR`. `REQUEUED` confirms a new kitchen/bar queue entry, not delivery. Engine errors stop automation until reload to avoid repeating an uncertain request. Report relevant logs, game/loader versions and host/client role.

See [development and acceptance checklist](DEVELOPMENT.md#english) and [changes](CHANGELOG.md).

## 中文

Fresh to Serve（焕新上桌）自动清理厨房出餐台、饮料出品区和升降机出餐位上的低劣熟食及成品饮料，包含鸡尾酒；原顾客仍在等待且剩余耐心足够时，向厨房或吧台补单，再由游戏原有服务员正常取餐、送达。

当前版本：**0.1.1-dev，待游戏内验收**。

### 工作流程

- 单人或联机房主每秒检查一次；客户端不执行清理或下单。
- 沿用游戏的两档负面质量判定。正常成品、脏盘/脏杯、已上桌、正在食用、正在拿取或附着于其他角色的物品不处理；未满杯、正在灌装或倒入配料的饮料，以及标记为玩家服务的桌子也不处理。
- 补单前核对原顾客、桌子、顾客组和订单，并统计已有成品及制作订单，同菜或同饮料多人也不会因此重复补单。饮料使用订单编号定位原顾客。
- 剩余耐心必须大于：对应厨房/吧台积压耗时 + 重做耗时 + 30 秒调度和送餐余量。每份前序订单按完整制作时间另加 5 秒估算，不假设员工并行或加速加成。餐厅关闭耐心时，仅略过时间限制。
- 饮料按目标楼层设备的实际灌装/交互时长、配方制作时间及额外 10 秒取杯/取料余量估算；耗时未知则不补单。该楼层须有正在工作且允许对应制作任务的调酒师；存在未完成的玩家认领饮料订单时延后补单，不改变认领状态。
- 顾客离开、订单改变、耐心不足或时间无法确认时，只清理、不补单。不重置、不延长耐心。
- 补单走原生厨房或吧台流程，继续消耗原料、检查制作要求。被拒绝的请求最多尝试三次，间隔至少 10 秒；待补单记录 120 秒后结束，每次重试重新检查顾客和耐心。

当前清理会移除整份低劣成品并释放取餐位置，不新增走向垃圾桶的动画，不向水槽返还脏盘或脏杯、不退原料，也不增加垃圾桶容量。搬运中的餐车、已上桌成品、仍在饮料设备上的杯子及烘焙托盘不在本版清理范围内。送达仍依赖员工、原料、寻路和制作容量；时间为估算，不能保证之后不会出现延迟。

### 安装与卸载

参考基线：Windows / Steam Build **25393699**、游戏 **1.0.0.44eb**、Unreal **5.4**；依赖 **UE4SS experimental**，本机核对 API 为 `v3.0.1-1140-gf58e8f84`，不支持旧稳定版 UE4SS 3.0.1。

1. 自行关闭游戏，安装所需加载器。
2. 从对应 CI artifact 取得 `FreshToServe-0.1.1-dev.zip` 及 `.sha256`，或在仓库根目录运行 `python fresh-to-serve-mod/build.py`。
3. 把包内 `FreshToServe/` 解压到加载器的 `Mods/`，确认有 `enabled.txt` 和 `Scripts/main.lua`。
4. 启动游戏，以房主身份进入餐厅即可；无需快捷键或配置。

如果已安装此前的 Fresh Service 包，请关闭游戏，移除旧的 `Mods/FreshService/` 文件夹，再启用 `FreshToServe/`，避免同时运行两份自动化。

停用时关闭游戏，移除 `FreshToServe/enabled.txt` 或 Mod 文件夹。卸载不会撤销已丢弃成品和已接受订单。构建不安装、不改存档、不启停游戏，包内不含加载器或游戏内容。

本 Mod 不新增玩家界面文字，菜名及订单沿用游戏语言。技术日志前缀为 `[FreshToServe]`：`DISCARDED`（已清理）、`REQUEUED`（已入队）、`SKIPPED`（跳过）、`DEFERRED`（延后）、`ERROR`。`REQUEUED` 仅确认新增厨房/吧台订单，不代表送达。引擎异常时停止自动化，避免反复发送结果不明的请求。反馈请附相关日志、游戏及加载器版本、房主或客户端身份。

参见[开发及验收清单](DEVELOPMENT.md#中文)与[版本变化](CHANGELOG.md)。
