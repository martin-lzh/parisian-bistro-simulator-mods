# Fresh to Serve development / 焕鲜上桌开发

[English](#english) · [中文](#中文)

## English

Current source version: **0.1.3**, an unpublished compatibility update for **Steam Build 25759268 / 1.0.2.44eb**. `python fresh-to-serve-mod/build.py` writes `outputs/fresh-to-serve/FreshToServe-0.1.3.zip` and its SHA-256 file. Successful PR/CI builds include the package in `mod-packages`; no release publication or new-build gameplay acceptance is implied.

The adapter uses locally checked reflected game/engine APIs. No executable patches, native addresses, custom memory layouts or game assets are distributed. Research stays in ignored `work/`; implementation, fixtures and documentation are original.

`game.lua` scans current-world authoritative kitchen pickup queues and registered elevator serving slots. After rechecking quality and pickup/consumption state, native pickup bookkeeping releases the slot and wakes chefs. The adapter verifies and removes only the temporary taken-out entry this call added, preserving existing reservations, then destroys the spoiled actor. Fixed pass indices and capacity are retained. Normal preparation FastArray entries are never edited directly. Cleanup removes the plate too, without reproducing trash animation, bin filling or dirty-plate recovery.

`drinks.lua` scans drink output areas and dedicated elevator drink slots. Full, finished drinks/cocktails share quality and authority guards; glasses at dispensers and active fills/pours are excluded. Destruction uses the drink's native lifecycle to remove its exact prepared order and notify the queue. Output areas natively reuse destroyed glasses' slots; the adapter checks available space and clears an elevator's matching reference. Neither drink FastArray is edited directly. Cleanup also removes the glass. Unexpected destruction or queue cleanup stops automation before any remake.

`remake.lua` keeps replacement tickets containing only strings/numbers: food/drink kind, producer, table, customer, group, original order GUID and item key. Creation time rejects leftovers older than the current order round. Drink tickets also require an exact match between the physical drink and notification GUID. No session actor wrappers are stored between ticks. Pending records survive script reload within the same session and clear when a different session is observed. A temporarily unavailable local pawn does not erase pending work. Separate customer orders and food/drink families remain separate even when their keys or GUIDs match.

`reload.lua` uses one fixed UE4SS shared-variable key containing a versioned, length-prefixed string. Its fixed ticket schema retains session identity, pending records, creation/retry times, attempt counts and the safety-stop flag. Parsing validates types, counts, lengths and complete framing; it never evaluates Lua source. No UObject, closure or table is stored in the loader's shared variables. The string is bounded to 4 MiB and 4,096 tickets, with no per-world or per-ticket shared keys. This is process memory only, not save persistence.

Before each active tick, `main.lua` checkpoints a stop marker; after successful completion it checkpoints the resulting state without that marker. An exception or failed final write therefore cannot silently enable uncertain work after reload. A stopped runtime only resolves the live session on the game thread; a different session clears the old stop and tickets. Malformed state fails closed, binding its stop to the first observed session. `OnUnload` invalidates old closures, optionally cancels the owned delayed-action handle, and serializes scalars without accessing game objects or scheduling new callbacks. Queued callbacks recheck the unloaded flag. Both the modern timer and the async fallback are covered by synthetic tests. The first upgrade from pre-0.1.2 code requires a closed-game installation because that code cannot save its pending work.

Before each request the adapter reacquires the unserved customer and original notification, checks table membership, compares demand with queued/physical items, and rechecks session and timing. Prepared drink queue rows do not independently count as supply; physical drinks and unfinished orders are deduplicated by GUID. Only a new queue GUID confirms acceptance. It is rebound to the original customer's already-ordered notification; any incidental native assignment to another customer's previously unplaced same-item order is restored first. A void call returning is insufficient evidence of acceptance; an engine exception stops automation rather than retrying an uncertain mutation.

Patience uses the native active-wait flag, wait duration and elapsed-wait functions. Inactive or unavailable timing is not interpreted as a fresh allowance. The budget is full base preparation time + full queued work + 5 seconds per queued dish + 30 seconds for dispatch/service. Already elapsed preparation is not subtracted, and neither parallelism nor preparation bonuses reduce the estimate. Disabled patience still requires a current customer and unmet demand. Later staff or navigation changes may invalidate the estimate.

For drinks, zero recipe preparation time is not treated as instant production. The adapter uses the longest compatible equipment duration on the assigned floor: recipe time + fill duration (dispensers/bottles) + Smart Object interaction duration + 10 seconds for glass/ingredient handling. Cocktails use their station's interaction duration. Missing equipment or unknown timing prevents a request. Full durations for all unfinished drink orders contribute to the backlog; manual claims defer remakes because their completion time is unknown. A working bartender on the floor must allow the appropriate preparation task. Native ordering still checks ingredients and preparation requirements.

### Offline checks

Run from the repository root:

```powershell
uv run --with lupa==2.6 python fresh-to-serve-mod/tests/run.py
python fresh-to-serve-mod/build.py
python tools/check_repository.py
python tools/check_syntax.py
python -m unittest discover -s tools/tests -v
python tools/ci.py build
git diff --check
```

CI validates the independent package allowlist, source bytes and SHA-256. Synthetic tests cover customer departure/table reuse, patience boundaries and unavailable timing, backlog, identical dishes/drinks, existing replacements, equipment and bartender availability, manual claims, partial glasses/cocktail pours, prepared-order cleanup, food/drink coexistence, authority, pickup, elevators, rejected/ambiguous requests, bounded retries, pause, world changes and scheduling. Reload tests exercise the real adapters and remake logic, preserving destroyed-item tickets, food/drink identities, retry limits, expiration and live patience checks; they also verify persistent safety stops, failed checkpoint writes, off-thread unload and stale queued callbacks. They cannot verify real Unreal bridging, replication or AI delivery.

### In-game regression checklist

The maintainer confirmed in-game and multiplayer testing passed and authorized 0.1.2 on 2026-09-26; see the [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/fresh-to-serve-v0.1.2/releases/validation.md#english). These scenarios remain regression references; individual results were not reported separately.

1. Let a cooked meal, dispenser drink, bottled drink and finished cocktail become poor. Confirm removal and a freed pickup position, exactly one new order, normal ingredient consumption, and delivery to its original customer.
2. Repeat on all floors/elevators and full food/drink output areas. Check queue/slot cleanup, reuse after several rounds, and the deliberate loss of the discarded plate/glass.
3. Test identical meals/drinks for multiple customers, partially served tables, another customer's unplaced order, an existing/manual replacement, and simultaneous spoiled food/drinks. Check quantities and updated order notifications.
4. Test departures, eviction, table reuse, course changes, backlog, disabled patience and patience at/above/below the budget. The timer must never reset.
5. Test missing ingredients/devices, absent chefs/bartenders, staff on another floor or with preparation excluded, manual claims/pickup, active filling/pouring, carried trolleys, consumed items, player-service tables, pause and world/menu transitions.
6. Verify host cleanup/queue replication on a client, client-only installation doing nothing, and coexistence with Bartender's Note, First to Serve and other Mods that inspect production queues.
7. After installing 0.1.2 with the game closed, reload with Ctrl+R after a spoiled item is discarded but its remake is waiting, after a rejected order, and after acceptance. Confirm one eventual replacement, unchanged cooldown/attempt/expiration limits, live patience checks and no duplicate loop. Reload during pause or temporarily missing possession. Verify an uncertain-operation stop persists across reload, and a different session clears old records before resuming.

Builds never install, change saves or start/stop the game. A numbered release requires explicit authorization. Offline checks are not in-game acceptance.

### Runtime compatibility and diagnostics

The local reference baseline is Windows, Steam Build 25393699 / ProjectVersion 1.0.0.44eb, Unreal Engine 5.4, with UE4SS experimental API `v3.0.1-1140-gf58e8f84`. Old stable UE4SS 3.0.1 is not supported. Authoritative cleanup polls once per second. Rejected replacement requests have at most three attempts, separated by at least 10 seconds; pending tickets expire after 120 seconds. Customer and patience checks run again before each request.

The 0.1.3 adapter also handles the table-class spelling observed in Steam Build 25759268 / 1.0.2.44eb while retaining the earlier spelling. It resolves both known paths as UClasses, deduplicates aliases by address, and uses the selected class's actual name for method checks and instance scans. Missing classes/methods, unexpected class identity or distinct candidates stop initialization. Reacquired tables must pass `IsA` before actor access. Synthetic tests exercise both spellings through food/drink cleanup, rejected remakes and fresh-wrapper notification rebinding; they do not establish new-build gameplay acceptance.

No player-facing text is authored by this Mod. Diagnostics use `[FreshToServe]`: `DISCARDED`, `REQUEUED`, `SKIPPED`, `DEFERRED` and `ERROR`. `REQUEUED` confirms a new kitchen/bar queue entry, not completed delivery. Include game/loader versions and host/client role when interpreting a report.

### Manual script reload

The first upgrade from pre-0.1.2 code requires a closed-game installation. In `UE4SS-settings.ini`, configure `[General]` with `EnableHotReloadSystem = 1`, `HotReloadKey = R` and `EnableAutoReloadingLuaMods = 0`; see the [shared reload guide](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/fresh-to-serve-v0.1.2/docs/hot-reload.md#english). Restart once after configuring. Copy every updated script before pressing **Ctrl+R**, which reloads all enabled Lua Mods.

The checkpoint implementation above defines preserved pending work and safety stops; verify those invariants with the reload regression scenarios.

If the old adapter stopped at startup because a table API was missing, install the compatible scripts with the game closed and restart the game. Ctrl+R preserves the shared safety-stop marker and does not clear that earlier failure.

## 中文

当前源码版本为 **0.1.3**，是针对 **Steam Build 25759268 / 1.0.2.44eb** 的未发布兼容更新。`python fresh-to-serve-mod/build.py` 输出 `outputs/fresh-to-serve/FreshToServe-0.1.3.zip` 及 SHA-256 文件。成功的 PR/CI 构建在 `mod-packages` 附件中提供安装包；这不代表已正式发布或通过新版游戏实机验收。

适配器使用本机核对过的游戏及引擎反射接口，不分发可执行补丁、原生地址、自定义内存布局或游戏资产。研究仅放在被忽略的 `work/`；实现、合成夹具及文档为原创。

`game.lua` 扫描当前房主世界的厨房取餐队列及登记的升降机出餐位，移除前复查质量与拿取/食用状态，通过原生取餐记账释放位置并通知厨师继续工作。确认后只撤销本次调用临时新增的已取出记录，保留已有记录，再移除低劣菜品。出餐台位置编号及容量保持不变，不直接改原生制作队列 FastArray。餐盘随低劣食物一起移除，不复现垃圾动画、垃圾量增加或脏盘回收。

`drinks.lua` 扫描饮料出品区与升降机专用饮料位，满杯成品及鸡尾酒沿用质量和权限保护；设备上的杯子及正在灌装/倒入配料的饮料不处理。销毁通过饮料原生生命周期移除对应已制作订单并通知队列；出品区原生复用已销毁杯子的空位，适配器检查空间已释放，并清除升降机对应引用。不直接改两个饮料 FastArray。杯子随饮料一起移除；销毁或队列清理异常时，在补单前停止自动化。

`remake.lua` 的凭据只含字符串和数字：食物/饮料类别、制作管理器、桌子、顾客、顾客组、原订单 GUID 和品类编号；制作时间检查排除上一轮点餐遗留成品。饮料还必须将实体订单 GUID 与原通知精确匹配。不跨检查轮次持有会话中的角色对象。待补单记录在同一会话内跨脚本重载保留，观察到不同会话时才清空；本地玩家暂时不可用不会抹掉待处理工作。同款不同顾客、食物与饮料的凭据分别处理，即使编号或 GUID 相同也不混淆。

`reload.lua` 只使用一个固定 UE4SS 共享变量键，内容为带版本和字段长度前缀的字符串。固定凭据结构保存会话身份、待补单、生成/重试时间、尝试次数和安全停止标志。解析核对类型、数量、长度和完整字段边界，不执行 Lua 字符串。共享变量不保存 UObject、函数闭包或表；限制为 4 MiB 和 4,096 个凭据，不随世界或订单创建新的共享键。内容只在进程内存中存在，不写入存档。

`main.lua` 在每次实际处理前先写停止标记，成功完成后再保存新状态并解除标记。因此，即使引擎异常或最终状态写入失败，重载也不会默默重复结果不明的操作。停止后只在游戏线程重新识别当前会话，不同会话才清除旧停止状态及凭据。损坏的共享记录会保持停止，并绑定到第一个观察到的会话。`OnUnload` 使旧闭包失效、可选取消所拥有的延时句柄并保存标量；不访问游戏对象、不排入新回调。已排队回调会再次检查卸载标志。现代定时器和异步回退路径均有合成验证。从 0.1.2 之前的代码首次升级须关闭游戏安装，因为旧代码无法保存自己的待补单。

每次请求重新定位未送达顾客与原通知，核对桌子成员、已有实体成品/制作队列，并复查会话与耗时。已制作饮料队列记录不单独计入库存；实体饮料与未完成订单按 GUID 去重。只有新增队列 GUID 才确认接受，并将其绑定回原顾客已下单通知；若原生流程误分配给另一位尚未下单的同款顾客，先恢复那条通知。void 调用返回不算接受。引擎异常会停止自动化，不重试结果不明的写操作。

耐心使用原生活跃等待标志、等待时长和已等待时间。计时未启用或不可读，不视为重新获得完整耐心。预算为基础制作时间 + 队列完整耗时 + 每份前序菜 5 秒 + 调度/送餐 30 秒，不扣已耗制作时间，不假设并行或加速。关闭耐心时仍检查顾客及未满足需求；后续员工或寻路变化仍可能使估算失效。

饮料配方制作时间为零不代表瞬间完成。读取目标楼层兼容设备中最长耗时：配方时间 + 灌装时间（饮料机/瓶装设备）+ Smart Object 交互时间 + 10 秒取杯/取料余量；鸡尾酒读取调酒台交互时间。设备缺失或耗时未知则不补单。全部未完成饮料订单计入完整积压耗时；手动认领的完成时间不可知，因此延后重做请求。目标楼层须有正在工作且允许对应制作任务的调酒师；原生下单仍检查原料和制作要求。

### 离线检查

仓库根目录执行上方命令。CI 核对独立包白名单、源码字节与 SHA-256。合成测试覆盖离开/换客、耐心边界及不可读计时、积压、同款多人、已有替代成品、设备与调酒师可用性、手动认领、未满杯/倒入配料、已制作订单清理、食物饮料共存、权限、拿取、升降机、拒绝/不明结果、有限重试、暂停、换世界和调度。重载测试联动真实适配层与补单逻辑，验证已销毁餐品的凭据、食物饮料身份、尝试限制、到期时间及实时耐心检查的保留，并覆盖跨重载安全停止、状态写入失败、非游戏线程卸载和旧排队回调；无法替代真实 Unreal 桥接、同步及 AI 送达验收。

### 游戏内回归清单

维护者于 2026-09-26 确认实机及联机测试全部通过并授权正式发布，正式版本为 0.1.2，见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/fresh-to-serve-v0.1.2/releases/validation.md#中文)。以下场景保留作为回归参考，未单独反馈逐项结果。

1. 熟食、饮料机饮料、瓶装饮料及成品鸡尾酒变低劣后，确认旧成品移除并释放位置、恰好补一份、正常扣原料、送给原顾客。
2. 各楼层、升降机及食物/饮料满出品位测试，检查队列和位置清理、多轮复用，并确认丢弃会损失餐盘/杯子的行为。
3. 同款多人、部分已送达、同桌另一位尚未下单、已有手动/自动补单，以及食物饮料同时变差，检查数量和通知。
4. 离开、驱逐、换客、换菜序、积压、关闭耐心，以及耐心等于/高于/低于预算；计时器不得被重置。
5. 缺原料/设备、无厨师/调酒师、员工楼层不符或排除制作任务、手动认领/拿取、正在灌装/倒入配料、搬运中的餐车、食用中、玩家服务桌、暂停及换世界/菜单。
6. 联机房主清理与订单同步、仅客户端安装无操作，并检查与 Bartender's Note、First to Serve 及其他读取制作队列的 Mod 共存。
7. 关闭游戏安装 0.1.2 后，在低劣成品已清理但补单仍等待、请求被拒绝以及补单已接受时分别 Ctrl+R 重载；确认最终恰好一份替代品，冷却/次数/到期限制保持、耐心读取当前值且没有重复循环。覆盖暂停和暂时无本地玩家；结果不明后的停止应跨重载保留，不同会话清除旧记录后恢复。

构建不安装、不改存档、不启停游戏。编号发布须明确授权，离线通过不等于实机验收。

### 运行兼容性与诊断

本机参考基线为 Windows、Steam Build 25393699 / ProjectVersion 1.0.0.44eb、Unreal Engine 5.4，以及 UE4SS experimental API `v3.0.1-1140-gf58e8f84`；不支持旧稳定版 UE4SS 3.0.1。房主每秒检查清理一次。被拒绝的补单最多尝试 3 次、至少间隔 10 秒，待处理凭据 120 秒后到期；每次请求重新核对顾客与耐心。

0.1.3 适配同时支持 Steam Build 25759268 / 1.0.2.44eb 中观察到的餐桌类拼写及此前拼写。查询两种已知路径并确认 UClass，按地址合并别名，以实际类名统一检查方法和枚举实例。类／方法缺失、类身份不符或出现不同候选类时停止初始化；重查餐桌先通过 `IsA` 再访问 Actor 接口。合成测试对两种拼写执行食物／饮料清理、拒绝补单及新对象包装下的通知重新绑定，不代表新版本实机验收通过。

本 Mod 不自行添加玩家界面文案。诊断前缀为 `[FreshToServe]`：`DISCARDED`（已清理）、`REQUEUED`（已入队）、`SKIPPED`（跳过）、`DEFERRED`（延后）及 `ERROR`。`REQUEUED` 仅确认新增厨房/吧台订单，不代表送达；分析反馈时需同时记录游戏/加载器版本及房主/客机身份。

### 手动脚本重载

从 0.1.2 之前的代码首次升级须关闭游戏。在 `UE4SS-settings.ini` 的 `[General]` 设置 `EnableHotReloadSystem = 1`、`HotReloadKey = R`、`EnableAutoReloadingLuaMods = 0`，参见[统一重载说明](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/fresh-to-serve-v0.1.2/docs/hot-reload.md#中文)，设置后重启一次。复制完全部更新脚本后再按 **Ctrl+R**；该操作会重载所有已启用 Lua Mod。

上方检查点实现定义待处理工作与安全停止的保留规则，需按重载回归场景核对这些约束。

若旧适配器因餐桌接口缺失在启动时停止，请关闭游戏后安装兼容脚本并完整重启游戏。Ctrl+R 会保留共享的安全停止标记，无法清除此前的启动失败。
