# Fresh to Serve development / 开发说明

[English](#english) · [中文](#中文)

## English

The adapter uses locally checked reflected game/engine APIs. No executable patches, native addresses, custom memory layouts or game assets are distributed. Research stays in ignored `work/`; implementation, fixtures and documentation are original.

`game.lua` scans current-world authoritative kitchen pickup queues and registered elevator serving slots. After rechecking quality and pickup/consumption state, native pickup bookkeeping releases the slot and wakes chefs. The adapter verifies and removes only the temporary taken-out entry this call added, preserving existing reservations, then destroys the spoiled actor. Fixed pass indices and capacity are retained. Normal preparation FastArray entries are never edited directly. Cleanup removes the plate too, without reproducing trash animation, bin filling or dirty-plate recovery.

`drinks.lua` scans drink output areas and dedicated elevator drink slots. Full, finished drinks/cocktails share quality and authority guards; glasses at dispensers and active fills/pours are excluded. Destruction uses the drink's native lifecycle to remove its exact prepared order and notify the queue. Output areas natively reuse destroyed glasses' slots; the adapter checks available space and clears an elevator's matching reference. Neither drink FastArray is edited directly. Cleanup also removes the glass. Unexpected destruction or queue cleanup stops automation before any remake.

`remake.lua` keeps replacement tickets containing only strings/numbers: food/drink kind, producer, table, customer, group, original order GUID and item key. Creation time rejects leftovers older than the current order round. Drink tickets also require an exact match between the physical drink and notification GUID. No session actor wrappers are stored between ticks. Pending records are cleared on session changes and are not persisted. Separate customer orders and food/drink families remain separate even when their keys or GUIDs match.

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

CI validates the independent package allowlist, source bytes and SHA-256. Synthetic tests cover customer departure/table reuse, patience boundaries and unavailable timing, backlog, identical dishes/drinks, existing replacements, equipment and bartender availability, manual claims, partial glasses/cocktail pours, prepared-order cleanup, food/drink coexistence, authority, pickup, elevators, rejected/ambiguous requests, bounded retries, pause, world changes and scheduling. They cannot verify real Unreal bridging, replication or AI delivery.

### In-game acceptance — pending

1. Let a cooked meal, dispenser drink, bottled drink and finished cocktail become poor. Confirm removal and a freed pickup position, exactly one new order, normal ingredient consumption, and delivery to its original customer.
2. Repeat on all floors/elevators and full food/drink output areas. Check queue/slot cleanup, reuse after several rounds, and the deliberate loss of the discarded plate/glass.
3. Test identical meals/drinks for multiple customers, partially served tables, another customer's unplaced order, an existing/manual replacement, and simultaneous spoiled food/drinks. Check quantities and updated order notifications.
4. Test departures, eviction, table reuse, course changes, backlog, disabled patience and patience at/above/below the budget. The timer must never reset.
5. Test missing ingredients/devices, absent chefs/bartenders, staff on another floor or with preparation excluded, manual claims/pickup, active filling/pouring, carried trolleys, consumed items, player-service tables, pause and world/menu transitions.
6. Verify host cleanup/queue replication on a client, client-only installation doing nothing, and coexistence with Bartender's Note, First to Serve and other Mods that inspect production queues.

Builds never install, change saves or start/stop the game. A numbered release requires explicit authorization. Offline checks are not in-game acceptance.

## 中文

适配器使用本机核对过的游戏及引擎反射接口，不分发可执行补丁、原生地址、自定义内存布局或游戏资产。研究仅放在被忽略的 `work/`；实现、合成夹具及文档为原创。

`game.lua` 扫描当前房主世界的厨房取餐队列及登记的升降机出餐位，移除前复查质量与拿取/食用状态，通过原生取餐记账释放位置并通知厨师继续工作。确认后只撤销本次调用临时新增的已取出记录，保留已有记录，再移除低劣菜品。出餐台位置编号及容量保持不变，不直接改原生制作队列 FastArray。餐盘随低劣食物一起移除，不复现垃圾动画、垃圾量增加或脏盘回收。

`drinks.lua` 扫描饮料出品区与升降机专用饮料位，满杯成品及鸡尾酒沿用质量和权限保护；设备上的杯子及正在灌装/倒入配料的饮料不处理。销毁通过饮料原生生命周期移除对应已制作订单并通知队列；出品区原生复用已销毁杯子的空位，适配器检查空间已释放，并清除升降机对应引用。不直接改两个饮料 FastArray。杯子随饮料一起移除；销毁或队列清理异常时，在补单前停止自动化。

`remake.lua` 的凭据只含字符串和数字：食物/饮料类别、制作管理器、桌子、顾客、顾客组、原订单 GUID 和品类编号；制作时间检查排除上一轮点餐遗留成品。饮料还必须将实体订单 GUID 与原通知精确匹配。不跨检查轮次持有会话中的角色对象，凭据随会话变化清空、不持久化。同款不同顾客、食物与饮料的凭据分别处理，即使编号或 GUID 相同也不混淆。

每次请求重新定位未送达顾客与原通知，核对桌子成员、已有实体成品/制作队列，并复查会话与耗时。已制作饮料队列记录不单独计入库存；实体饮料与未完成订单按 GUID 去重。只有新增队列 GUID 才确认接受，并将其绑定回原顾客已下单通知；若原生流程误分配给另一位尚未下单的同款顾客，先恢复那条通知。void 调用返回不算接受。引擎异常会停止自动化，不重试结果不明的写操作。

耐心使用原生活跃等待标志、等待时长和已等待时间。计时未启用或不可读，不视为重新获得完整耐心。预算为基础制作时间 + 队列完整耗时 + 每份前序菜 5 秒 + 调度/送餐 30 秒，不扣已耗制作时间，不假设并行或加速。关闭耐心时仍检查顾客及未满足需求；后续员工或寻路变化仍可能使估算失效。

饮料配方制作时间为零不代表瞬间完成。读取目标楼层兼容设备中最长耗时：配方时间 + 灌装时间（饮料机/瓶装设备）+ Smart Object 交互时间 + 10 秒取杯/取料余量；鸡尾酒读取调酒台交互时间。设备缺失或耗时未知则不补单。全部未完成饮料订单计入完整积压耗时；手动认领的完成时间不可知，因此延后重做请求。目标楼层须有正在工作且允许对应制作任务的调酒师；原生下单仍检查原料和制作要求。

### 离线检查

仓库根目录执行上方命令。CI 核对独立包白名单、源码字节与 SHA-256。合成测试覆盖离开/换客、耐心边界及不可读计时、积压、同款多人、已有替代成品、设备与调酒师可用性、手动认领、未满杯/倒入配料、已制作订单清理、食物饮料共存、权限、拿取、升降机、拒绝/不明结果、有限重试、暂停、换世界和调度；无法替代真实 Unreal 桥接、同步及 AI 送达验收。

### 游戏内验收——待完成

1. 熟食、饮料机饮料、瓶装饮料及成品鸡尾酒变低劣后，确认旧成品移除并释放位置、恰好补一份、正常扣原料、送给原顾客。
2. 各楼层、升降机及食物/饮料满出品位测试，检查队列和位置清理、多轮复用，并确认丢弃会损失餐盘/杯子的行为。
3. 同款多人、部分已送达、同桌另一位尚未下单、已有手动/自动补单，以及食物饮料同时变差，检查数量和通知。
4. 离开、驱逐、换客、换菜序、积压、关闭耐心，以及耐心等于/高于/低于预算；计时器不得被重置。
5. 缺原料/设备、无厨师/调酒师、员工楼层不符或排除制作任务、手动认领/拿取、正在灌装/倒入配料、搬运中的餐车、食用中、玩家服务桌、暂停及换世界/菜单。
6. 联机房主清理与订单同步、仅客户端安装无操作，并检查与 Bartender's Note、First to Serve 及其他读取制作队列的 Mod 共存。

构建不安装、不改存档、不启停游戏。编号发布须明确授权，离线通过不等于实机验收。
