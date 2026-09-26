# Scan to Order development / 扫码点餐开发

[English](#english) · [中文](#中文)

## English

The maintainer confirmed in-game and multiplayer testing passed and authorized 0.1.1 on 2026-09-26; see the [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/releases/validation.md#english). The checklist remains a regression reference; individual results were not reported separately.

The independent Lua Mod polls on the game thread once per second. It requires an authoritative local controller and possessed player in one world. Table, customer, producer and service objects must belong to that world. A client, paused game or missing possession never dispatches an order.

Candidates contain scalar table/customer identities, group, item and route. Each dispatch rechecks the session, seating, current wanted item, existing order state, player ownership, waiter activity and enabled patience. The first pending same-item customer must be eligible because native ordering assigns that row. No customer selection, order flags, GUIDs, inventories or worker evaluators are written by Lua.

Stock is checked silently immediately before each request; availability is not cached for the next customer. Food and drinks use the existing native AI order route with no player argument, preserving native requirements, stock consumption, queue and notification assignment. A request counts as accepted only when a new matching queue GUID is bound to the expected customer. A normal refusal can be retried on a later poll. An inconsistent result or exception stops automation for that world.

Catalog rows are read as references, with their schema, validity, mapping and unique item key checked on each request. Only item keys and ingredient quantities are accessed in Lua. The stock check takes independent scalar records; the native order takes the complete original struct reference. Whole-struct returns and dish asset fields are never materialized through Lua. Missing catalog data waits; malformed data stops the world. No row references survive the synchronous request.

Only a scalar stop marker is shared across reload. It is persisted before dispatch and cleared after success, preventing an interrupted or uncertain request from replaying after Ctrl+R. Unload cancels the timer when supported and makes old callbacks inert without accessing game objects. Temporary loss of possession does not clear a stop; a different world does. There is no persistent save modification or native DLL.

Local API and native AI routing checks used Steam Build 25532071 / 1.0.1.44eb and the locally available UE4SS experimental source. All analysis and reference material remains under ignored `work/`. That evidence and the offline tests do not establish real engine bridging or gameplay acceptance.

### Offline checks

From the repository root:

```powershell
uv run --with lupa==2.6 python scan-to-order-mod/tests/run.py
python scan-to-order-mod/build.py
python tools/check_repository.py
python tools/check_syntax.py
python -m unittest discover -s tools/tests -v
python tools/ci.py build
git diff --check
```

Behavior tests reject full dish conversion, unrelated asset access and reconstructed order payloads; check catalog schema, invalid/unmapped/duplicate rows and scalar ingredient copies; and cover partial stock, replenishment, multiple customers sharing the last unit, repeated polls, later courses, normal native refusal, stale tickets, clients, world mismatch, pause, departed/served customers, native queue/notification disagreement, reload stops and queued callbacks. The package has a fixed source allowlist and deterministic ZIP metadata; CI verifies source bytes and checksums. Builds never install or control the game.

### In-game acceptance checklist

- Single player and host: ordinary meals, drinks, cocktails, multiple customers, courses and floors; no waiter required for ordering.
- Missing food/drink stock: no unavailable order enters a queue; another available item proceeds; restock completes only outstanding orders without repeating accepted ones.
- Last unit shared by several customers: stock is consumed once and the remaining customer waits. Check prepared cocktail ingredients, plates and glasses through the native stock rules.
- Missing chefs, bartenders, specialties or equipment: preserve native restrictions and verify recovery when requirements are restored.
- Waiter/player overlap and a player-owned table: no duplicates or stolen interactions. Leaving customers, expired patience and reused tables do not receive stale orders.
- Client installation: no orders sent; host orders and notifications replicate normally.
- Ctrl+R while waiting for stock, after acceptance, during pause and after returning to the menu: no duplicate callbacks or orders; inspect the log for errors.
- Coexistence with Fresh to Serve, Auto Checkout and Bartender's Note; no replacement of their responsibilities.

Keep the game installation read-only during development. Gameplay acceptance must be reported separately with game/loader versions and host/client role.

### Loader, output and diagnostics

The checked loader API is UE4SS experimental `v3.0.1-1140-gf58e8f84`, for the Windows / Unreal Engine 5.4 baseline above. Old stable UE4SS 3.0.1 is not the target. Build output is `outputs/scan-to-order/ScanToOrder-0.1.1.zip` and its SHA-256 file.

No in-game wording is added; native order text remains localized by the game. Technical log prefix `[ScanToOrder]` includes `START`, confirmed `ORDER` and `ERROR`. An order event is logged only after native queue binding confirms acceptance.

### Manual script reload

After a closed-game initial installation, follow the [shared reload configuration](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/docs/hot-reload.md#english). Copy both `Scripts/main.lua` and `Scripts/game.lua` completely before pressing **Ctrl+R**.

Confirmed orders remain in game state and outstanding orders are reread. The stop-marker lifecycle above prevents uncertain calls from replaying; script reload does not clear a current-world stop. Re-enter the session to reset that state. Removal requires closing the game.

## 中文

维护者于 2026-09-26 确认实机及联机测试全部通过并授权正式发布，正式版本为 0.1.1，见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/releases/validation.md#中文)。清单保留作为回归参考，未单独反馈逐项结果。

独立 Lua Mod 每秒在游戏线程检查一次。仅本地控制器及其玩家均有服务器权限、且属于同一世界时运行；餐桌、顾客、制作管理器和服务对象也必须属于该世界。客机、暂停或尚未控制玩家时，不发送订单。

候选仅保存餐桌／顾客标识、组别、餐品和类型等标量。每次提交重新检查会话、入座关系、顾客当前需求、已有订单、玩家负责标记、服务员点餐状态及启用的耐心。同餐品的第一条待下单记录必须符合条件，避免原生绑定落到失效顾客。Lua 不改顾客选菜、下单标记、订单 GUID、库存或员工任务表。

每个请求前静默检查库存，不把上一位顾客的可用结果用于下一位。食物和饮料通过不传玩家的原生 AI 下单路径处理，保留制作要求、库存扣除、队列及订单提醒绑定。只有新增的匹配队列 GUID 绑定到预期顾客，才记录成功。原生正常拒绝可在后续轮询重试；状态矛盾或异常会停止当前世界的自动化。

每次请求重新读取菜品表记录引用，核对结构类型、有效性、数据映射及餐品编号唯一性。Lua 仅访问餐品编号及食材数量，库存检查传独立标量记录，下单传完整原始结构引用。不在 Lua 中展开完整菜品返回值或资源字段。菜品表暂不可用时等待，数据异常时停止当前世界；记录引用不跨同步请求保存。

热重载仅交接标量停止标记：请求前持久化、成功后清除，避免中断或结果不明的订单被 Ctrl+R 重放。卸载时按加载器能力取消计时器，使旧回调失效，不访问游戏对象。暂时失去玩家控制不会解除停止，进入不同世界才重置。不写入存档额外数据，不需要原生 DLL。

本地 API 和原生 AI 路径核对基于 Steam Build 25532071 / 1.0.1.44eb，以及本机 UE4SS experimental 源码。所有分析和参考资料保留在被忽略的 `work/` 中。源码核对和离线测试不等同于真实引擎桥接及实机验收。

### 离线验证

命令见上方英文段。行为测试禁止完整菜品转换、无关资源访问和重新拼装下单数据，核对菜品表类型、无效／未映射／重复记录及独立食材记录，并覆盖部分缺货、补货、多人争用最后一份库存、重复轮询、后续菜序、原生正常拒绝、过期候选、客机、跨世界、暂停、离席／已上餐顾客、队列与提醒不一致、热重载停止和排队回调。包使用固定白名单和确定性 ZIP 元数据，CI 校验源码内容及哈希；构建不安装或控制游戏。

### 实机验收清单

- 单人及房主：普通菜品、饮料、鸡尾酒、多人同桌、多道菜和多楼层，无服务员也能点餐。
- 食物／饮料缺货：缺货餐品不进入队列，有货项可先下；补货仅提交未完成订单，已完成订单不重复。
- 多人争用最后一份库存：只扣一次，另一位继续等待；检查鸡尾酒预制材料、盘子和杯子的原生库存规则。
- 缺厨师、调酒师、专长或设备：保留原生限制，条件恢复后能继续。
- 服务员／玩家同时操作、玩家负责餐桌：无重复或抢占；离席、耐心耗尽、换桌客人不收到旧订单。
- 客机安装：不发送订单；房主订单和提醒正常同步。
- 缺货等待、已下单、暂停及返回菜单后按 Ctrl+R：无重复回调或订单，检查日志异常。
- 与焕鲜上桌、收银管家、调饮手记同时启用，功能互不替代。

开发期间游戏安装只读。实机验收需单独反馈游戏／加载器版本和房主／客机身份。

### 加载器、产物与诊断

核对的加载器 API 为 UE4SS experimental `v3.0.1-1140-gf58e8f84`，适用于上文 Windows / Unreal Engine 5.4 参考基线；不以旧稳定版 UE4SS 3.0.1 为目标。构建产物为 `outputs/scan-to-order/ScanToOrder-0.1.1.zip` 及 SHA-256 文件。

不新增游戏内文案，订单文字沿用游戏本地化。技术日志前缀 `[ScanToOrder]` 包含 `START`、已确认的 `ORDER` 和 `ERROR`；只有原生队列绑定确认接受后才记录成功订单。

### 手动脚本重载

首次关闭游戏安装后，可按[统一重载配置](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/docs/hot-reload.md#中文)设置加载器。完整复制 `Scripts/main.lua` 和 `Scripts/game.lua` 后，再按 **Ctrl+R**。

已确认订单保留在游戏状态中，未完成订单重新读取。上方停止标记机制防止结果不明的请求被重放；脚本重载不会清除当前世界的停止状态，重新进入会话后才重置。卸载须关闭游戏。
