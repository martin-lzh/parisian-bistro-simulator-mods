# Scan to Order development / 扫码点餐开发

[English](#english) · [中文](#中文)

## English

Player instructions: [README](README.md#english). **Current source: 0.1.3.**

### Implementation

#### Polling and session

- Independent Lua Mod that polls on the game thread once per second.
- Runs only with an authoritative local controller and a possessed player in one world. Table, customer, producer and service objects must belong to that world.
- A client, a paused game or missing possession never dispatches an order.
- No save data is written and no native DLL is used.

#### Candidates and dispatch checks

- Candidates hold only scalar table/customer identities, group, item and route.
- Each dispatch rechecks the session, seating, the customer's current wanted item, existing order state, player ownership, waiter activity and enabled patience.
- The first pending customer for the same item must be eligible, because native ordering assigns that row.
- Lua never writes customer selection, order flags, GUIDs, inventories or worker evaluators.

#### Stock and ordering

- Stock is checked silently immediately before each request; availability is not cached for the next customer.
- Food and drinks use the existing native AI order route with no player argument. This keeps native requirements, stock consumption, queue and notification assignment.
- A request counts as accepted only when a new matching queue GUID is bound to the expected customer.
- A normal refusal is retried on a later poll. An inconsistent result or an exception stops automation for that world.

#### Catalog data

- Catalog rows are read as references. Their schema, validity, mapping and unique item key are checked on every request.
- Lua accesses only item keys and ingredient quantities. The stock check takes independent scalar records; the native order takes the complete original struct reference.
- Whole-struct returns and dish asset fields are never materialized through Lua, and no row reference survives the synchronous request.
- Missing catalog data waits; malformed data stops the world.

#### Table class (Build 25759268 follow-up)

- Initialization resolves the actual game UClass from the `Table` and `table` paths. Aliases are merged only when their addresses match, and the class type and full name are validated.
- Required methods and short-name enumeration use that class's reflected name. Candidate discovery and dispatch reacquisition also check `IsA` against the resolved class.
- Missing, invalid or ambiguous classes and missing methods stop automation.

#### Reload and stop state

- Only a scalar stop marker is shared across reload. It is persisted before dispatch and cleared after success, so an interrupted or uncertain request cannot replay after Ctrl+R.
- Unload cancels the timer when supported and makes old callbacks inert without accessing game objects.
- Temporary loss of possession does not clear a stop; entering a different world does.

### Offline checks and packaging

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

Behavior tests:

- Reject full dish conversion, unrelated asset access and reconstructed order payloads.
- Check catalog schema, invalid/unmapped/duplicate rows and scalar ingredient copies.
- Cover partial stock, replenishment, several customers sharing the last unit, repeated polls, later courses, normal native refusal, stale tickets, clients, world mismatch, pause, departed/served customers, native queue/notification disagreement, reload stops and queued callbacks.
- Cover both table-class spellings, alias resolution, rejected lookups, stock-aware dispatch and reload stops.

The package uses a fixed source allowlist and deterministic ZIP metadata; CI verifies source bytes and checksums. Build output is `outputs/scan-to-order/ScanToOrder-0.1.3.zip` plus its SHA-256 file. Builds never install or control the game.

### In-game regression checklist

- Single player and host: ordinary meals, drinks, cocktails, multiple customers, courses and floors; no waiter required for ordering.
- Missing food/drink stock: no unavailable order enters a queue; another available item proceeds; restocking completes only outstanding orders without repeating accepted ones.
- Last unit shared by several customers: stock is consumed once and the remaining customer waits. Check prepared cocktail ingredients, plates and glasses through the native stock rules.
- Missing chefs, bartenders, specialties or equipment: native restrictions hold, and ordering recovers when requirements are restored.
- Waiter/player overlap and a player-owned table: no duplicates or stolen interactions. Leaving customers, expired patience and reused tables get no stale orders.
- Client installation: no orders sent; host orders and notifications replicate normally.
- Ctrl+R while waiting for stock, after acceptance, during pause and after returning to the menu: no duplicate callbacks or orders; check the log for errors.
- Coexistence with Fresh to Serve, Auto Checkout and Bartender's Note, each keeping its own responsibilities.

Keep the game installation read-only during development. Report in-game results with game/loader versions and host/client role.

### Logging

- No in-game wording is added; order text stays localized by the game.
- Log prefix `[ScanToOrder]` with `START`, confirmed `ORDER` and `ERROR` entries. `ORDER` is logged only after native queue binding confirms acceptance.

### Runtime compatibility

- Current version: **0.1.3**, supporting **Steam Build 25822788 / 1.0.2.44eb**.
- **0.1.3 test status:** compared with 0.1.2, 0.1.3 changes only the license (PolyForm Noncommercial 1.0.0), the documentation and the version number; gameplay code is unchanged. In-game testing of 0.1.3 by the maintainer is still pending.
- Development reference: Windows, Steam Build 25532071 / 1.0.1.44eb, Unreal Engine 5.4, with the table-class follow-up checked against Build 25759268 / 1.0.2.44eb.
- UE4SS: experimental `v3.0.1-1140-gf58e8f84`. Stable UE4SS 3.0.1 is not supported.
- Analysis and reference material stays in the ignored `work/` folder.

### Manual script reload

1. Install once with the game closed.
2. Set up the [shared reload configuration](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/docs/hot-reload.md#english), copy both `Scripts/main.lua` and `Scripts/game.lua` completely, then press **Ctrl+R**.

After a reload:

- Confirmed orders stay in game state, and outstanding orders are read again.
- The stop marker keeps uncertain calls from replaying. A reload does not clear a stop in the current world; re-enter the session to reset it.
- A startup failure such as a missing API leaves a stop marker that applies to every later world. After updating the scripts, fully restart the game; Ctrl+R or re-entering the restaurant does not clear it.
- Removing the Mod requires closing the game.

## 中文

玩家说明：[README](README.md#中文)。**当前源码版本：0.1.3。**

### 实现

#### 轮询与会话

- 独立 Lua Mod，每秒在游戏线程检查一次。
- 仅当本地控制器有服务器权限、已控制玩家且两者属于同一世界时运行；餐桌、顾客、制作管理器和服务对象也必须属于该世界。
- 客机、游戏暂停或尚未控制玩家时，不发送订单。
- 不写入存档数据，不使用原生 DLL。

#### 候选与提交前检查

- 候选仅保存餐桌／顾客标识、组别、餐品和类型等标量。
- 每次提交都重新检查会话、入座关系、顾客当前需求、已有订单、玩家负责标记、服务员点餐状态及启用的耐心。
- 同一餐品的第一条待下单记录必须符合条件，因为原生下单会绑定到这一条。
- Lua 不改顾客选菜、下单标记、订单 GUID、库存或员工任务表。

#### 库存与下单

- 每个请求前静默检查库存，不把上一位顾客的可用结果用于下一位。
- 食物和饮料走不传玩家的原生 AI 下单路径，保留制作要求、库存扣除、队列及订单提醒绑定。
- 只有新增的匹配队列 GUID 绑定到预期顾客，才算下单成功。
- 原生正常拒绝会在后续轮询重试；状态矛盾或异常会停止当前世界的自动化。

#### 菜品表数据

- 以引用方式读取菜品表记录，每次请求都核对结构类型、有效性、数据映射及餐品编号唯一性。
- Lua 仅访问餐品编号和食材数量。库存检查传独立标量记录，下单传完整原始结构引用。
- 不在 Lua 中展开完整菜品返回值或资源字段，记录引用不跨同步请求保存。
- 菜品表暂不可用时等待，数据异常时停止当前世界。

#### 餐桌类（Build 25759268 兼容修复）

- 初始化从 `Table` 和 `table` 两个路径解析真实游戏 UClass；仅地址相同时才视为同一类的别名，并校验类型和完整名称。
- 所需方法和短名枚举使用该类的真实反射名称；候选发现及提交前重新查找还会用 `IsA` 核对对象类型。
- 类缺失、无效、冲突或方法缺失时停止自动化。

#### 重载与停止标记

- 热重载只交接一个标量停止标记：请求前写入、成功后清除，避免中断或结果不明的订单在 Ctrl+R 后重放。
- 卸载时按加载器能力取消计时器，让旧回调失效，不访问游戏对象。
- 暂时失去玩家控制不会解除停止，进入不同世界才会重置。

### 离线检查与打包

从仓库根目录执行：

```powershell
uv run --with lupa==2.6 python scan-to-order-mod/tests/run.py
python scan-to-order-mod/build.py
python tools/check_repository.py
python tools/check_syntax.py
python -m unittest discover -s tools/tests -v
python tools/ci.py build
git diff --check
```

行为测试：

- 禁止完整菜品转换、无关资源访问和重新拼装下单数据。
- 核对菜品表类型、无效／未映射／重复记录及独立食材记录。
- 覆盖部分缺货、补货、多人争用最后一份库存、重复轮询、后续菜序、原生正常拒绝、过期候选、客机、跨世界、暂停、离席／已上餐顾客、队列与提醒不一致、热重载停止和排队回调。
- 覆盖餐桌类的两种拼写、别名解析、查询拒绝、库存感知下单及重载停止。

包使用固定的源码白名单和确定性 ZIP 元数据，CI 校验源码内容及哈希。构建产物为 `outputs/scan-to-order/ScanToOrder-0.1.3.zip` 及 SHA-256 文件。构建不安装、不控制游戏。

### 实机回归清单

- 单人及房主：普通菜品、饮料、鸡尾酒、多位顾客、多道菜和多楼层，无服务员也能点餐。
- 食物／饮料缺货：缺货餐品不进入队列，有货项可先下；补货后只提交未完成订单，已接受的订单不重复。
- 多人争用最后一份库存：只扣一次，另一位继续等待；检查鸡尾酒预制材料、盘子和杯子的原生库存规则。
- 缺厨师、调酒师、专长或设备：保留原生限制，条件恢复后能继续下单。
- 服务员／玩家同时操作、玩家负责的餐桌：无重复或抢占；离席、耐心耗尽、换桌的顾客不收到旧订单。
- 客机安装：不发送订单；房主的订单和提醒正常同步。
- 等待库存、已下单、暂停时及返回菜单后按 Ctrl+R：无重复回调或订单，检查日志错误。
- 与焕鲜上桌、收银管家、调饮手记同时启用，各自职责互不替代。

开发期间游戏安装目录只读。反馈实机结果时注明游戏／加载器版本和房主／客机身份。

### 日志

- 不新增游戏内文字，订单文字沿用游戏本地化。
- 日志前缀 `[ScanToOrder]`，包含 `START`、已确认的 `ORDER` 和 `ERROR`。只有原生队列绑定确认接受后才记录 `ORDER`。

### 运行兼容性

- 当前版本：**0.1.3**，支持至 **Steam Build 25822788 / 1.0.2.44eb**。
- **0.1.3 测试状态：**与 0.1.2 相比，0.1.3 只更改许可（PolyForm Noncommercial 1.0.0）、文档和版本号，玩法代码不变。维护者对 0.1.3 的实机测试尚待进行。
- 开发参考：Windows、Steam Build 25532071 / 1.0.1.44eb、Unreal Engine 5.4；餐桌类兼容修复针对 Build 25759268 / 1.0.2.44eb 核对。
- UE4SS：experimental `v3.0.1-1140-gf58e8f84`。不支持旧稳定版 UE4SS 3.0.1。
- 分析和参考资料保留在被忽略的 `work/` 文件夹。

### 手动脚本重载

1. 先在关闭游戏时完成一次安装。
2. 按[统一重载配置](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/docs/hot-reload.md#中文)设置加载器，完整复制 `Scripts/main.lua` 和 `Scripts/game.lua`，再按 **Ctrl+R**。

重载后：

- 已确认的订单保留在游戏状态中，未完成订单重新读取。
- 停止标记防止结果不明的请求被重放。重载不会清除当前世界的停止状态，重新进入会话后才会重置。
- 缺失 API 等启动失败会留下对之后所有世界生效的停止标记。更新脚本后需完整重启游戏；Ctrl+R 或重新进入餐厅都无法清除。
- 卸载 Mod 须先关闭游戏。
