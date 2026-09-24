# Fresh Service development / 开发说明

[English](#english) · [中文](#中文)

## English

The adapter uses locally checked reflected game/engine APIs. No executable patches, native addresses, custom memory layouts or game assets are distributed. Research stays in ignored `work/`; implementation, fixtures and documentation are original.

`game.lua` scans current-world authoritative kitchen pickup queues and registered elevator serving slots. After rechecking quality and pickup/consumption state, native pickup bookkeeping releases the slot and wakes chefs. The adapter verifies and removes only the temporary taken-out entry this call added, preserving existing reservations, then destroys the spoiled actor. Fixed pass indices and capacity are retained. Normal preparation FastArray entries are never edited directly. Cleanup removes the plate too, without reproducing trash animation, bin filling or dirty-plate recovery.

`remake.lua` keeps replacement tickets containing only strings/numbers: kitchen, table, customer, group, original order GUID and dish key. Creation time rejects leftovers older than the current order round. No session actor wrappers are stored between ticks. Pending records are cleared on session changes and are not persisted. Separate customer orders remain separate even when their dish types match.

Before each request the adapter reacquires the unserved customer and original notification, checks table membership, compares demand with queued/physical dishes, and rechecks session and timing. Only a new queue GUID confirms acceptance. It is rebound to the original customer's already-ordered notification. A void call returning is insufficient evidence of acceptance; an engine exception stops automation rather than retrying an uncertain mutation.

Patience uses the native active-wait flag, wait duration and elapsed-wait functions. Inactive or unavailable timing is not interpreted as a fresh allowance. The budget is full base preparation time + full queued work + 5 seconds per queued dish + 30 seconds for dispatch/service. Already elapsed preparation is not subtracted, and neither parallelism nor preparation bonuses reduce the estimate. Disabled patience still requires a current customer and unmet demand. Later staff or navigation changes may invalidate the estimate.

### Offline checks

Run from the repository root:

```powershell
uv run --with lupa==2.6 python fresh-service-mod/tests/run.py
python fresh-service-mod/build.py
python tools/check_repository.py
python tools/check_syntax.py
python -m unittest discover -s tools/tests -v
python tools/ci.py build
git diff --check
```

CI validates the independent package allowlist, source bytes and SHA-256. Synthetic tests cover customer departure/table reuse, patience boundaries and unavailable timing, backlog, identical dishes, existing replacements, authority, pickup, elevators, rejected/ambiguous requests, bounded retries, pause, world changes and scheduling. They cannot verify real Unreal bridging, replication or AI delivery.

### In-game acceptance — pending

1. Let a cooked meal become poor. Confirm removal and a freed pickup position, exactly one new order, normal ingredient consumption, and delivery to its original customer.
2. Repeat on all floors/elevators and a full pass. Check array cleanup and the deliberate loss of the discarded plate.
3. Test identical dishes for multiple customers, partially served tables and an existing/manual replacement. Check quantities and updated order notifications.
4. Test departures, eviction, table reuse, course changes, backlog, disabled patience and patience at/above/below the budget. The timer must never reset.
5. Test missing ingredients, absent chefs, manual pickup, carried trolleys, consumed meals, player-service tables, pause and world/menu transitions.
6. Verify host cleanup/queue replication on a client, client-only installation doing nothing, and coexistence with other Mods that inspect kitchen queues.

Builds never install, change saves or start/stop the game. A numbered release requires explicit authorization. Offline checks are not in-game acceptance.

## 中文

适配器使用本机核对过的游戏及引擎反射接口，不分发可执行补丁、原生地址、自定义内存布局或游戏资产。研究仅放在被忽略的 `work/`；实现、合成夹具及文档为原创。

`game.lua` 扫描当前房主世界的厨房取餐队列及登记的升降机出餐位，移除前复查质量与拿取/食用状态，通过原生取餐记账释放位置并通知厨师继续工作。确认后只撤销本次调用临时新增的已取出记录，保留已有记录，再移除低劣菜品。出餐台位置编号及容量保持不变，不直接改原生制作队列 FastArray。餐盘随低劣食物一起移除，不复现垃圾动画、垃圾量增加或脏盘回收。

`remake.lua` 的凭据只含字符串和数字：厨房、桌子、顾客、顾客组、原订单 GUID 和菜品编号；制作时间检查排除上一轮点餐遗留食物。不跨检查轮次持有会话中的角色对象，凭据随会话变化清空、不持久化。同菜不同顾客仍分别处理。

每次请求重新定位未上菜顾客与原通知，核对桌子成员、已有实体菜品/厨房队列，并复查会话与耗时。只有新增队列 GUID 才确认接受，并将其绑定回原顾客已下单通知；void 调用返回不算接受。引擎异常会停止自动化，不重试结果不明的写操作。

耐心使用原生活跃等待标志、等待时长和已等待时间。计时未启用或不可读，不视为重新获得完整耐心。预算为基础制作时间 + 队列完整耗时 + 每份前序菜 5 秒 + 调度/送餐 30 秒，不扣已耗制作时间，不假设并行或加速。关闭耐心时仍检查顾客及未满足需求；后续员工或寻路变化仍可能使估算失效。

### 离线检查

仓库根目录执行上方命令。CI 核对独立包白名单、源码字节与 SHA-256。合成测试覆盖离开/换客、耐心边界及不可读计时、积压、同菜多人、已有替代菜、权限、拿取、升降机、拒绝/不明结果、有限重试、暂停、换世界和调度；无法替代真实 Unreal 桥接、同步及 AI 上菜验收。

### 游戏内验收——待完成

1. 熟食变低劣后，确认旧菜移除并释放位置、恰好补一份、正常扣原料、送给原顾客。
2. 各楼层、升降机及满出餐台测试，检查引用清理，并确认丢弃会损失餐盘的行为。
3. 同菜多人、部分已上菜、已有手动/自动补单，检查数量和通知。
4. 离开、驱逐、换客、换菜序、积压、关闭耐心，以及耐心等于/高于/低于预算；计时器不得被重置。
5. 缺原料、无厨师、手动拿取、搬运中的餐车、食用中、玩家服务桌、暂停及换世界/菜单。
6. 联机房主清理与订单同步、仅客户端安装无操作，并检查与其他读取厨房队列的 Mod 共存。

构建不安装、不改存档、不启停游戏。编号发布须明确授权，离线通过不等于实机验收。
