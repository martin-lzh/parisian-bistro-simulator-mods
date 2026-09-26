# Auto Menu Development / 每日菜单组合开发

[English](#english) · [中文](#中文)

## English

**0.3.0-dev, pending in-game acceptance.** Auto Menu is an independent Lua Mod without a native helper DLL or other Mod dependency. The native contract was checked against Steam Build 25532071 / ProjectVersion 1.0.1.44eb; original implementation is distributed, local analysis remains in ignored `work/`.

### Search and engine access

- `game.lua` copies selector primitives, intersects candidates with `AvailableDishes`, and excludes disabled, employee-disabled and selector-disabled entries. `UnlockedDailyDishes` alone does not make an item available. Ineligible entries need no stock or price queries. Live `StorageManager:HasEnoughIngredients` uses the silent policy; the page's cached missing-stock list is not used for pruning. No whole dish return value or soft asset reference is converted.
- The adapter builds sufficient native-equivalence signatures from course, ordered recommendation tags, live ingredient availability and native price-response class. Tag order is preserved for float accumulation. Food price response is classified using the native single-precision ratio and boundaries; aperitif/end-drink prices do not enter that score. These signatures do not assign preference weights or approximate adoption. Stock differences remain distinct, and no out-of-stock item is simply replaced by an empty course. This optimization depends on the checked native contract and must be revalidated after game changes.
- `planner.lua` keeps a representative for each equivalent choice and includes an empty choice per course, excluding an entirely empty menu. Representatives prefer the existing selection, then stocked choices, then stable identifiers. It evaluates an eligible existing menu first and retains it on ties. On larger searches, two coordinate sweeps find an incumbent; they do not certify a local optimum. Completion requires the native ceiling or coverage of every representative combination. Only warm-start queries are memoized; memory does not grow with the full Cartesian product. Rates are never rounded or compared with an epsilon.
- All objective values still come from `GetDailyMenuProjection(period).EstimatedAdoptionRate`. A synchronous batch protects the original menu and current influence/half-life/satisfaction, supplies the click-time sample, checks native menu binding, and evaluates several candidates. It never yields, saves, broadcasts or sends RPCs. Cleanup restores and verifies every property, including after partial writes or an exception in a later query. A menu-field fallback handles a failed reflected table restoration. Only primitives leave the batch.
- `main.lua` runs slices every 16 ms, with at most 128 planner operations or a 4 ms clock budget. A native call cannot be preempted; capture/cleanup and UI work are additional overhead. This is not a frame-time guarantee. Discovery and progress refresh run every 500 ms. SEARCH/COMPOSED logs record eligible/representative counts, original/reduced combination counts, query count and elapsed time.
- Before a slice and before applying, guards compare authority, world/manager/storage, service, original menu, native forecast/context, ceiling/bonus, tier/difficulty, eligibility arrays, candidates, tags, prices, costs and live ingredient availability. Real changes cancel without saving. Normal influence/satisfaction drift and semantic list reordering do not cancel. The winner is rechecked with the original sample, then projected alongside the current menu with live values. A better existing menu is retained; otherwise one native save/readback/page refresh applies the winner. The certified maximum is for sampled conditions, not an arbitrary later time.
- `ui.lua` and `reload.lua` retain one localized button, progress/cancellation, host-only use and reload cleanup. Searches are discarded on reload. Opening a page, changing days and reloading never compose automatically. The active flag and other service are preserved; no pricing, purchasing or printing is performed.

Equivalence compresses the search without removing distinct native outcomes. With no equivalent candidates and no ceiling hit, worst-case work is still exponential. No heuristic ranking, time limit or candidate-count cap is reported as a global optimum.

### Offline checks

```powershell
uv run --with lupa==2.6 python auto-menu-mod/tests/run.py
python auto-menu-mod/build.py
python tools/check_repository.py
python tools/check_syntax.py
python -m unittest discover -s tools/tests -v
git diff --check
```

Six suites cover brute-force agreement on non-additive objectives, optional courses, sub-display improvements, existing-menu ties, eligibility, equivalence boundaries, stock/tag-order isolation, ceiling warm start, time budgets, batch cleanup, partial writes, genuine context changes, normal drift, live ranking reversal, native refusal, one-save completion, UI/reload lifecycle and 14 languages.

The synthetic performance workload has eight active dishes per course with two equivalence classes: 59,048 full combinations become 242 native predictions (244× fewer). The reduced and full searches find the same maximum; five batches replace per-query sample setup in that test. Restricting availability to three dishes in three courses yields seven combinations despite the larger selector catalogue. These are deterministic synthetic work counts, not measured game speed or validation of real engine bridging.

`build.py` produces `outputs/auto-menu/AutoMenu-0.3.0-dev.zip` and its SHA-256. The fixed allowlist contains six Lua modules, README, DEVELOPMENT, CHANGELOG and the activation marker. No tests, tools, references, game content or loader are packaged. There is no release authorization.

### In-game checklist

1. Check one working button, 14 languages, focus, progress and cancellation; repeat hot reload during a search.
2. With few active dishes, compare every native combination to the result. Test different forecasts/weather/events, price boundaries, low stock, missing ingredients, optional courses and promotion influence.
3. Check that locked, disabled and unstaffed dishes never appear. Compare SEARCH counts with the active selection, and re-enable a dish to ensure it returns.
4. Compare equivalent replacements under native predictions, including price-band boundaries, tag order and different live stock. Revalidate the equivalence contract after game updates.
5. Confirm original menu and live properties are restored between slices and after cancellation/errors. Check one final save, unchanged active state/other service, and host/guest replication.
6. Change prices, availability, service, page or authority during a search; no stale result may apply. Normal time/satisfaction changes should not cancel. Measure completion and frame impact with both many equivalent choices and many distinct choices below the ceiling.

## 中文

**0.3.0-dev，待游戏内验收。** 独立 Lua Mod，无原生辅助 DLL 或其他 Mod 依赖。原生契约根据 Steam Build 25532071 / ProjectVersion 1.0.1.44eb 核对；只分发原创实现，分析资料留在忽略的 `work/`。

### 搜索与引擎访问

- 从原生选择器复制基础数据，与 `AvailableDishes` 取交集，再剔除停用、员工条件不满足及选择器禁用项目。仅存在于 `UnlockedDailyDishes` 不等于已可用。无效候选不查询价格或库存。库存使用 `StorageManager:HasEnoughIngredients` 的实时静默检查，不依赖页面缺料缓存；不转换包含软资源引用的完整菜品返回值。
- 按类别、有序推荐标签、实时食材可用性及原生价格响应类别建立等价分组。保留标签顺序，避免改变浮点累加结果；食物价格分类采用原生单精度比例与边界，开胃酒和餐后饮品价格不参与该评分。分组不设置偏好权重、不近似选择率。缺料状态不同的菜品不合并，也不直接将缺料菜品替换为空类别。分组规则依赖已核对的原生契约，游戏更新后需要重新验证。
- 每组保留一个代表，优先现有选择、食材齐全、固定编号；各类别仍可留空，排除全空菜单。符合条件的当前菜单先计算，同值保留。较大搜索先做两轮逐类别改进，只用于尽早找到较好的方案；达到原生上限或覆盖所有代表组合才算完成。仅缓存预搜索记录，不为整个笛卡尔积建立缓存；比较不取整、不设误差容限。
- 所有目标值仍来自 `GetDailyMenuProjection(period).EstimatedAdoptionRate`。每个同步批次保护原菜单和实时影响力／半衰期／满意度，使用点击时采样值，验证原生菜单绑定后连续试算。批次内不让出执行、不保存、不广播、不发送 RPC；返回前恢复并检查所有属性。中途失败、部分写入、后续试算异常也走清理路径，菜单整表恢复失败时逐字段恢复；只保留基础数值，不持有临时结构数组。
- 每 16 毫秒运行一批，最多 128 次规划操作或 4 毫秒时钟预算。单次原生调用不能抢占，条件采集、清理和 UI 还有额外开销，因此不保证帧耗时。每 500 毫秒发现界面和刷新进度。日志记录有效候选、代表候选、压缩前后组合数、试算次数及耗时。
- 每批和保存前比较权限、世界／管理器／库存管理器、餐段、原菜单、预测条件、上限和加成、等级／难度、资格列表、候选、标签、价格、成本及实时食材状态。真实变化取消，正常影响力／满意度变化和等价列表重排不取消。最终方案按采样条件复核后，再与现有菜单比较实时选择率；现有菜单更好则保留，否则原生保存一次、读回并刷新。全局最优针对采样条件，不承诺任意后续时刻。
- 保留原有单按钮、14 种语言、进度／取消、房主限制和热重载清理。重载丢弃未完成搜索；打开界面、切换日期或重载不会自动组合。保留启用状态和另一餐段，不调价、不采购、不打印。

等价压缩保留所有不同的原生选择率结果。若没有等价候选且未达上限，最坏情况仍是指数级搜索；不会将启发式结果、超时或候选数量截断冒充全局最优。

### 离线验证

执行英文部分命令。六组测试覆盖非加性目标与完整枚举对照、类别留空、微小提升、同值保留、资格过滤、价格边界、库存及标签顺序隔离、预搜索达到上限、分批预算、批次异常恢复、部分写入、真实变化与正常数值变化、实时排名反转、原生拒绝、单次保存、生命周期及多语言。

合成性能场景每类 8 道启用菜、2 组等价候选：完整 59,048 个组合压缩为 242 次原生试算，调用次数减少约 244 倍，最优值与完整枚举一致；该测试分为 5 批，只在批次内设置采样属性。将实际可用范围限制为三个类别各一道菜时，即使选择器目录很大，也只有 7 个组合。以上是可重复的合成工作量，不代表实际游戏速度或真实引擎桥接验收。

构建生成 `outputs/auto-menu/AutoMenu-0.3.0-dev.zip` 和 SHA-256，只含六个 Lua 模块、README、DEVELOPMENT、CHANGELOG 及启用标记，无游戏内容或参考资料。此开发版无发布授权。

### 实机待验收

1. 检查单按钮、14 种语言、焦点、进度、取消以及搜索中反复热重载。
2. 用少量启用菜手动比较全部原生组合；覆盖客流、天气、活动、价格边界、缺料、类别留空和推广影响力。
3. 确认未解锁、停用和员工条件不满足的菜品不参与；核对日志候选数量，重新启用后应重新纳入。
4. 比较等价替换的原生预测，包括价格边界、标签顺序、不同实时库存；游戏更新后重新核对分组契约。
5. 确认每批返回及取消／异常后原菜单和实时属性恢复，最终只保存一次，保留启用状态和另一餐段，检查联机同步。
6. 搜索中改变价格、资格、餐段、页面或权限不得应用旧结果；正常时间／满意度变化不取消。分别实测大量等价候选及大量不同候选且低于上限时的耗时与帧影响。
