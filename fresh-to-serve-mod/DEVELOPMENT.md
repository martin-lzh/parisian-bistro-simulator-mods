# Fresh to Serve development / 焕鲜上桌开发

[English](#english) · [中文](#中文)

## English

### Version and compatibility

- Current version: **0.1.3**.
- Supported game: up to **1.0.2.44eb (Steam Build 25822788)**.
- Development reference: Windows, Steam Build 25393699 / ProjectVersion 1.0.0.44eb, Unreal Engine 5.4.
- Loader: UE4SS experimental `v3.0.1-1140-gf58e8f84`. Old stable UE4SS 3.0.1 is not supported.

`python fresh-to-serve-mod/build.py` writes `outputs/fresh-to-serve/FreshToServe-0.1.3.zip` and its SHA-256 file. Successful PR/CI builds include the package in `mod-packages`.

The Mod uses reflected game and engine APIs checked against the local reference. It ships no executable patches, native addresses, custom memory layouts or game assets. Research material stays in ignored `work/`; implementation, fixtures and documentation are original.

### How it works

#### Food cleanup (`game.lua`)

- Scans current-world authoritative kitchen pickup queues and registered elevator serving slots.
- Rechecks quality and pickup/consumption state before removing anything.
- Native pickup bookkeeping releases the slot and wakes chefs. The adapter then verifies and removes only the temporary taken-out entry this call added, keeping existing reservations, and destroys the spoiled actor.
- Fixed pass indices and capacity are kept. Preparation FastArray entries are never edited directly.
- The plate is removed too; trash animation, bin filling and dirty-plate recovery are not reproduced.

#### Drink cleanup (`drinks.lua`)

- Scans drink output areas and dedicated elevator drink slots. Full, finished drinks and cocktails use the same quality and authority guards as food.
- Glasses at dispensers and drinks being filled or poured are excluded.
- Destruction goes through the drink's native lifecycle, which removes its exact prepared order and notifies the queue.
- Output areas natively reuse a destroyed glass's slot; the adapter checks that space is available and clears the elevator's matching reference. Neither drink FastArray is edited directly.
- The glass is removed too. Unexpected destruction or queue-cleanup results stop automation before any remake.

#### Replacement tickets (`remake.lua`)

- A ticket holds only strings and numbers: food/drink kind, producer, table, customer, group, original order GUID and item key.
- Creation time rejects leftovers older than the current order round. Drink tickets also require the physical drink's GUID to match the notification GUID exactly.
- No session actor wrappers are kept between ticks.
- Pending tickets survive script reload within the same session and are cleared when a different session is observed. A temporarily missing local pawn does not erase them.
- Different customers' orders, and food versus drink, stay separate even when keys or GUIDs match.

#### Reload state (`reload.lua`)

- Uses one fixed UE4SS shared-variable key holding a versioned, length-prefixed string.
- The fixed ticket schema stores session identity, pending tickets, creation/retry times, attempt counts and the safety-stop flag.
- Parsing validates types, counts, lengths and complete framing; it never evaluates Lua source.
- No UObject, closure or table is stored in shared variables. The string is capped at 4 MiB and 4,096 tickets, with no per-world or per-ticket keys.
- This lives in process memory only and is not written to saves.

#### Checkpoints and unload (`main.lua`)

- Before each active tick, a stop marker is checkpointed. After the tick succeeds, the resulting state is saved without the marker. An exception or failed final write therefore can't silently re-enable uncertain work after reload.
- A stopped runtime only resolves the live session on the game thread. A different session clears the old stop and tickets.
- Malformed state fails closed, binding its stop to the first observed session.
- `OnUnload` invalidates old closures, cancels the owned delayed-action handle when available and serializes scalars without touching game objects or scheduling callbacks. Queued callbacks recheck the unloaded flag.
- Both the modern timer and the async fallback are covered by synthetic tests.
- Upgrading from pre-0.1.2 code requires installing with the game closed, because that code can't save its pending work.

#### Placing a replacement order

- Before each request, the adapter reacquires the unserved customer and original notification, checks table membership, compares demand with queued and physical items, and rechecks session and timing.
- Prepared drink queue rows don't count as supply on their own; physical drinks and unfinished orders are deduplicated by GUID.
- Only a new queue GUID confirms acceptance. It is rebound to the original customer's already-ordered notification. If the native call assigned it to another customer's unplaced order for the same item, that notification is restored first.
- A void call returning is not treated as acceptance. An engine exception stops automation instead of retrying an uncertain mutation.

#### Patience budget

- Uses the native active-wait flag, wait duration and elapsed-wait functions. Inactive or unreadable timing is never treated as a fresh allowance.
- Budget = full base preparation time + full queued work + 5 s per queued dish + 30 s for dispatch and service.
- Elapsed preparation is not subtracted, and parallel staff or preparation bonuses don't reduce the estimate.
- With patience disabled, a current customer and unmet demand are still required.

#### Drink timing

- Zero recipe preparation time is not treated as instant.
- Uses the longest compatible equipment duration on the assigned floor: recipe time + fill duration (dispensers/bottles) + Smart Object interaction duration + 10 s for glass and ingredient handling. Cocktails use their station's interaction duration.
- Missing equipment or unknown timing blocks the request.
- All unfinished drink orders count toward the backlog at full duration. Manual claims defer remakes because their completion time is unknown.
- A working bartender on the floor must allow the matching preparation task. Native ordering still checks ingredients and preparation requirements.

#### Table class lookup (0.1.3)

- Handles the table-class spelling seen in Steam Build 25759268 / 1.0.2.44eb as well as the earlier spelling.
- Resolves both known paths as UClasses, deduplicates aliases by address and uses the selected class's actual name for method checks and instance scans.
- Missing classes or methods, unexpected class identity or two distinct candidates stop initialization.
- Reacquired tables must pass `IsA` before actor access.
- Synthetic tests run both spellings through food/drink cleanup, rejected remakes and fresh-wrapper notification rebinding.

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

CI validates the package file list, source bytes and SHA-256.

Synthetic tests cover customer departure and table reuse, patience boundaries and unreadable timing, backlog, identical dishes and drinks, existing replacements, equipment and bartender availability, manual claims, partial glasses and cocktail pours, prepared-order cleanup, food/drink coexistence, authority, pickup, elevators, rejected and ambiguous requests, bounded retries, pause, world changes and scheduling.

Reload tests run the real adapters and remake logic. They check that destroyed-item tickets, food/drink identities, retry limits, expiration and live patience checks are kept, and cover persistent safety stops, failed checkpoint writes, off-thread unload and stale queued callbacks.

Unreal bridging, replication and AI delivery need the in-game checklist below.

### In-game regression checklist

0.1.2 in-game and multiplayer results are in the [0.1.2 validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/fresh-to-serve-v0.1.2/releases/validation.md#english).

1. Let a cooked meal, dispenser drink, bottled drink and finished cocktail become poor. Confirm removal and a freed pickup position, exactly one new order, normal ingredient use, and delivery to the original customer.
2. Repeat on all floors and elevators and with full food/drink output areas. Check queue and slot cleanup, reuse after several rounds, and that the discarded plate or glass is lost.
3. Test identical meals/drinks for several customers, partly served tables, another customer's unplaced order, an existing or manual replacement, and food and drinks spoiling at once. Check quantities and updated order notifications.
4. Test departures, eviction, table reuse, course changes, backlog, disabled patience and patience at, above and below the budget. The timer must never reset.
5. Test missing ingredients or equipment, absent chefs or bartenders, staff on another floor or with preparation excluded, manual claims and pickup, active filling or pouring, carried trolleys, items being eaten, player-service tables, pause and world/menu transitions.
6. Check that host cleanup and queue changes replicate to a client, that a client-only install does nothing, and that the Mod coexists with Bartender's Note, First to Serve and other Mods that read production queues.
7. With 0.1.2 or later installed with the game closed, press Ctrl+R after a spoiled item is discarded but its remake is waiting, after a rejected order, and after acceptance. Confirm exactly one replacement, unchanged cooldown/attempt/expiration limits, live patience checks and no duplicate loop. Also reload while paused and while possession is briefly missing. An uncertain-operation stop must persist across reload, and a different session must clear old records before resuming.

Builds never install the Mod, change saves or start or stop the game. A numbered release needs explicit authorization.

### Timing and diagnostics

- Authoritative cleanup polls once per second.
- A rejected replacement request is tried at most three times, at least 10 seconds apart. Pending tickets expire after 120 seconds.
- Customer and patience checks run again before every request.

The Mod adds no player-facing text. Log lines use the `[FreshToServe]` prefix with `DISCARDED`, `REQUEUED`, `SKIPPED`, `DEFERRED` or `ERROR`. `REQUEUED` confirms a new kitchen or bar queue entry, not delivery. When reading a report, note the game and loader versions and whether the player was host or client.

### Manual script reload

1. The first upgrade from pre-0.1.2 code must be installed with the game closed.
2. In `UE4SS-settings.ini`, under `[General]`, set `EnableHotReloadSystem = 1`, `HotReloadKey = R` and `EnableAutoReloadingLuaMods = 0` (see the [shared reload guide](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/fresh-to-serve-v0.1.2/docs/hot-reload.md#english)). Restart the game once.
3. Copy every updated script, then press **Ctrl+R**. This reloads all enabled Lua Mods.

Pending work and safety stops are kept as described under **Checkpoints and unload** above; use regression scenario 7 to check them.

If an older version stopped at startup because a table API was missing, install the new scripts with the game closed and restart the game. Ctrl+R keeps the shared safety-stop marker, so it won't clear that failure.

## 中文

### 版本与兼容性

- 当前版本：**0.1.3**。
- 支持游戏：至 **1.0.2.44eb（Steam Build 25822788）**。
- 开发参考：Windows、Steam Build 25393699 / ProjectVersion 1.0.0.44eb、Unreal Engine 5.4。
- 加载器：UE4SS experimental `v3.0.1-1140-gf58e8f84`，不支持旧稳定版 UE4SS 3.0.1。

`python fresh-to-serve-mod/build.py` 输出 `outputs/fresh-to-serve/FreshToServe-0.1.3.zip` 及 SHA-256 文件。成功的 PR/CI 构建在 `mod-packages` 附件中提供安装包。

本 Mod 使用按本机参考核对过的游戏及引擎反射接口，不分发可执行补丁、原生地址、自定义内存布局或游戏资产。研究资料只放在被忽略的 `work/`；实现、合成夹具及文档均为原创。

### 实现方式

#### 食物清理（`game.lua`）

- 扫描当前房主世界的厨房取餐队列及登记的升降机出餐位。
- 移除前复查品质与拿取／食用状态。
- 通过原生取餐记账释放位置并通知厨师继续工作；随后只撤销本次调用临时新增的已取出记录，保留已有记录，再销毁低劣菜品。
- 出餐台位置编号及容量保持不变，不直接修改原生制作队列 FastArray。
- 餐盘随菜品一起移除，不复现垃圾动画、垃圾量增加或脏盘回收。

#### 饮料清理（`drinks.lua`）

- 扫描饮料出品区与升降机专用饮料位；满杯成品及鸡尾酒沿用与食物相同的品质和权限保护。
- 设备上的杯子及正在灌装／倒入配料的饮料不处理。
- 销毁走饮料的原生生命周期，移除对应的已制作订单并通知队列。
- 出品区原生复用已销毁杯子的空位；适配器检查空间已释放，并清除升降机中对应的引用。不直接修改两个饮料 FastArray。
- 杯子随饮料一起移除。销毁或队列清理结果异常时，在补单前停止自动化。

#### 补单凭据（`remake.lua`）

- 凭据只含字符串和数字：食物／饮料类别、制作管理器、桌子、顾客、顾客组、原订单 GUID 和品类编号。
- 按制作时间排除上一轮点餐遗留的成品；饮料还要求实体饮料 GUID 与原通知 GUID 精确匹配。
- 不跨检查轮次持有会话中的 Actor 包装对象。
- 待补单在同一会话内跨脚本重载保留，观察到不同会话时清空；本地玩家暂时不可用不会抹掉待处理工作。
- 不同顾客的订单、食物与饮料分别处理，即使编号或 GUID 相同也不混淆。

#### 重载状态（`reload.lua`）

- 只使用一个固定的 UE4SS 共享变量键，内容为带版本号和字段长度前缀的字符串。
- 固定凭据结构保存会话身份、待补单、生成／重试时间、尝试次数和安全停止标志。
- 解析时核对类型、数量、长度和完整字段边界，不执行 Lua 代码。
- 共享变量不保存 UObject、闭包或表；上限为 4 MiB 和 4,096 个凭据，不按世界或订单新建共享键。
- 内容只存在于进程内存，不写入存档。

#### 检查点与卸载（`main.lua`）

- 每次实际处理前先写入停止标记，成功完成后再保存新状态并去掉标记。因此引擎异常或最终写入失败后，重载也不会默默重复结果不明的操作。
- 停止后只在游戏线程识别当前会话；不同会话才清除旧的停止状态和凭据。
- 损坏的共享记录保持停止，并绑定到第一个观察到的会话。
- `OnUnload` 使旧闭包失效，可用时取消所持有的延时句柄，并保存标量；不访问游戏对象，也不排入新回调。已排队的回调会再次检查卸载标志。
- 现代定时器和异步回退路径均有合成测试覆盖。
- 从 0.1.2 之前的代码首次升级须关闭游戏安装，因为旧代码无法保存自己的待补单。

#### 发起补单

- 每次请求前重新定位未上菜的顾客与原通知，核对桌子成员，比较需求与排队中及实体的餐品，并复查会话和耗时。
- 已制作的饮料队列记录不单独计入供给；实体饮料与未完成订单按 GUID 去重。
- 只有出现新的队列 GUID 才确认接受，并将其绑定回原顾客已下单的通知；若原生流程把它分配给了另一位尚未下单的同款顾客，先恢复那条通知。
- void 调用返回不算接受。引擎异常会停止自动化，不重试结果不明的写操作。

#### 耐心预算

- 使用原生的活跃等待标志、等待时长和已等待时间。计时未启用或不可读时，不视为重新获得完整耐心。
- 预算 = 基础制作时间 + 队列完整耗时 + 每份前序菜 5 秒 + 调度／送餐 30 秒。
- 不扣除已耗制作时间，也不因员工并行或制作加成而缩短估算。
- 关闭耐心时，仍要求顾客在场且需求未满足。

#### 饮料耗时

- 配方制作时间为零不视为瞬间完成。
- 取目标楼层兼容设备中最长的耗时：配方时间 + 灌装时间（饮料机／瓶装设备）+ Smart Object 交互时间 + 10 秒取杯取料；鸡尾酒使用调酒台的交互时间。
- 设备缺失或耗时未知时不补单。
- 全部未完成的饮料订单按完整耗时计入积压；手动认领的完成时间未知，因此延后重做。
- 目标楼层须有正在工作、且允许对应制作任务的调酒师；原生下单仍会检查原料和制作要求。

#### 餐桌类查询（0.1.3）

- 同时支持 Steam Build 25759268 / 1.0.2.44eb 中的餐桌类拼写和此前的拼写。
- 将两种已知路径解析为 UClass，按地址合并别名，并以实际类名检查方法和枚举实例。
- 类或方法缺失、类身份不符或出现两个不同的候选类时，停止初始化。
- 重新获取的餐桌须先通过 `IsA` 才访问 Actor 接口。
- 合成测试对两种拼写执行食物／饮料清理、补单被拒以及新包装对象下的通知重新绑定。

### 离线检查

在仓库根目录执行：

```powershell
uv run --with lupa==2.6 python fresh-to-serve-mod/tests/run.py
python fresh-to-serve-mod/build.py
python tools/check_repository.py
python tools/check_syntax.py
python -m unittest discover -s tools/tests -v
python tools/ci.py build
git diff --check
```

CI 核对安装包文件清单、源码字节与 SHA-256。

合成测试覆盖顾客离开与换客、耐心边界及不可读计时、积压、同款多人、已有替代成品、设备与调酒师可用性、手动认领、未满杯／倒入配料、已制作订单清理、食物饮料共存、权限、拿取、升降机、请求被拒／结果不明、有限重试、暂停、换世界和调度。

重载测试联动真实适配层与补单逻辑，确认已销毁餐品的凭据、食物饮料身份、尝试次数限制、到期时间及实时耐心检查得以保留，并覆盖跨重载的安全停止、状态写入失败、非游戏线程卸载和旧的排队回调。

Unreal 桥接、联机同步和 AI 送餐需按下方游戏内清单检查。

### 游戏内回归清单

0.1.2 的实机及联机结果见 [0.1.2 验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/fresh-to-serve-v0.1.2/releases/validation.md#中文)。

1. 让熟食、饮料机饮料、瓶装饮料和调好的鸡尾酒变质。确认旧成品被移除、位置释放、恰好补一份、正常扣原料，并送给原顾客。
2. 在各楼层、升降机以及食物／饮料出品位已满时重复测试，检查队列和位置清理、多轮复用，并确认被丢弃的餐盘／杯子确实损失。
3. 测试同款多人、部分已上菜、另一位顾客尚未下单、已有手动／自动补单，以及食物饮料同时变质，检查数量和订单通知。
4. 测试顾客离开、驱逐、换客、换菜序、积压、关闭耐心，以及耐心等于／高于／低于预算；计时器不得被重置。
5. 测试缺原料／设备、没有厨师／调酒师、员工在其他楼层或排除了制作任务、手动认领／拿取、正在灌装／倒入配料、搬运中的餐车、食用中、玩家服务桌、暂停以及切换世界／菜单。
6. 检查房主的清理与订单变化同步到客机、仅客机安装时无操作，以及与 Bartender's Note、First to Serve 和其他读取制作队列的 Mod 共存。
7. 关闭游戏安装 0.1.2 或更新版本后，分别在变质成品已清理但补单仍在等待、请求被拒、补单已接受时按 Ctrl+R。确认最终恰好一份替代品，冷却／次数／到期限制不变，耐心读取当前值，且没有重复循环。另在暂停和暂时没有本地玩家时重载。结果不明后的停止须跨重载保留，不同会话须先清除旧记录再恢复。

构建不会安装 Mod、修改存档或启动／关闭游戏。编号版本发布须明确授权。

### 计时与诊断

- 房主端每秒检查一次清理。
- 被拒绝的补单最多尝试 3 次，至少间隔 10 秒；待处理凭据 120 秒后到期。
- 每次请求前重新核对顾客与耐心。

本 Mod 不添加玩家界面文字。日志前缀为 `[FreshToServe]`，类型有 `DISCARDED`（已清理）、`REQUEUED`（已入队）、`SKIPPED`（跳过）、`DEFERRED`（延后）和 `ERROR`。`REQUEUED` 只确认厨房／吧台新增了订单，不代表已送达。分析反馈时记下游戏和加载器版本，以及玩家是房主还是客机。

### 手动脚本重载

1. 从 0.1.2 之前的代码首次升级，须关闭游戏安装。
2. 在 `UE4SS-settings.ini` 的 `[General]` 中设置 `EnableHotReloadSystem = 1`、`HotReloadKey = R`、`EnableAutoReloadingLuaMods = 0`（参见[统一重载说明](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/fresh-to-serve-v0.1.2/docs/hot-reload.md#中文)），然后重启一次游戏。
3. 复制完全部更新的脚本后再按 **Ctrl+R**，这会重载所有已启用的 Lua Mod。

待处理工作与安全停止的保留规则见上方“检查点与卸载”，可用回归场景 7 核对。

若旧版本因缺少餐桌接口在启动时停止，请关闭游戏后安装新脚本并重启游戏。Ctrl+R 会保留共享的安全停止标记，无法清除这次失败。
