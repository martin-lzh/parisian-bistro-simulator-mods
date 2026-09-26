# Auto Menu development / 开发

[English](#english) · [中文](#中文)

## English

**0.4.1-dev, pending in-game acceptance.** Independent Lua Mod, without a native helper DLL. Local interfaces were checked on Steam Build 25532071 / ProjectVersion 1.0.1.44eb. Native analysis and reference material stay in ignored `work/`.

### Implementation

- `game.lua` collects dish IDs from each selector, intersects them with `AvailableDishes`, and excludes `DisabledDishes`, `EmployeeRequirementDisabledDishes`, disabled selector entries and wrong-course entries. Each course also gets ID zero. The current choice comes first when eligible; remaining IDs use a stable order. No tags, ingredient arrays, cost, prices, satisfaction or influence snapshots are read for candidate preparation.
- `planner.lua` recursively visits the Cartesian product with one reusable trial table. It compares the exact native rate and copies only improvements. Empty and completely empty choices are included. Reaching the native maximum can stop enumeration; there are no equivalence signatures, heuristic warm starts, memo tables or independent-course scoring.
- `Game.compose` runs synchronously in the native button callback on the game thread. It reads the original daily-menu definition once, retains the inline reflected menu view during the call and writes only changed dish fields. Every trial calls `GetDailyMenuProjection(period).EstimatedAdoptionRate`. No trial saves, yields, RPCs or sample-property writes are made. The protected trial block restores the original definition on success or failure. Completion calls `SaveDailyMenu` once, checks the selected dish fields and refreshes the page. Native saving deactivates an empty menu; this is accepted rather than treated as a failed active-state check.
- `main.lua` filters clicks by the Mod button identity and prevents reentrant composition. Its only timer discovers/updates widgets every 500 ms; it does not schedule search. Successful logs include the rate, evaluation count and timing breakdown. `ui.lua` keeps a fixed localized button and tooltip without progress, cancellation or status countdowns. `reload.lua` handles button cleanup between Lua states.

All combinations are evaluated in one game-thread callback, so there are no inter-slice condition snapshots or changed-condition cancellation paths. The search remains exponential in the number of active choices. Synchronous completion trades responsiveness on large menus for a smaller implementation and no artificial waits. This version does not claim a measured in-game speedup.

### Timing logs

`SEARCH` records the selected period, eligible option counts including zero, full product and `clock=os.clock`. `COMPOSED` retains the native rate, actual evaluations and elapsed seconds. `TIMING` reports total and search milliseconds, average projection milliseconds, changed dish-field writes and `stop=exhausted` or `native_ceiling` (fewer evaluations than combinations). `TIMING_PARTS` uses milliseconds and percentages of total composition time:

| Field | Measured work |
| --- | --- |
| `setup` | Host check, original menu, eligible IDs, native ceiling and initial log |
| `writes` | Compare the five trial fields and write changed values |
| `projection` | `GetDailyMenuProjection`, including UE4SS dispatch and returned struct conversion |
| `rate_read` | Read `EstimatedAdoptionRate` from the returned struct |
| `restore` | Restore the original menu before the final save |
| `save` | `SaveDailyMenu`, including synchronous native callbacks |
| `verify` | Read back and check the saved dish fields |
| `refresh` | The explicit `RefreshDailyMenus` call |
| `lua_and_timing` | Remaining enumeration, comparisons, copies, bookkeeping and timing overhead |

The nine shares are exclusive and sum to total before display rounding; `search_ms` is an inclusive subtotal, not an extra share. The timer is the existing Lua `os.clock`, not game time, with four clock reads per trial and no extra native scoring calls. Timer resolution makes very short intervals approximate or zero; averages come from accumulated time, not a single high-resolution sample. Clock/instrumentation overhead is distributed across intervals, so these are instrumented measurements, not an overhead-free benchmark. The total ends after refresh and excludes final summary formatting/output and the outer button-hook checks. Failed runs retain `SEARCH` and the existing error log, without claiming complete timing shares. Native internals are not separately timed.

### Verification

```powershell
uv run --with lupa==2.6 python auto-menu-mod/tests/run.py
python auto-menu-mod/build.py
python tools/check_repository.py
python tools/check_syntax.py
python -m unittest discover -s tools/tests -v
git diff --check
```

Seven offline suites cover complete enumeration, joint optima, sub-display rate improvements, current-menu ties, native ceiling termination, eligible choices, empty-menu saving, only changed field writes, native failure restoration, one save, timing attribution and totals with a synthetic clock, bounded logging, zero-duration logs, reentrant callbacks, language fallback and reload cleanup.

Synthetic work counts: two active dishes per course give 243 native evaluations, including the empty menu. Eight per course give 59,049. Restricting the same catalogue to three dishes in three courses gives eight. The tests require no separate pricing, stock or simulation snapshots and no search timer. These are counts on fake objects, not real engine timings or native-bridge acceptance.

The build creates `outputs/auto-menu/AutoMenu-0.4.1-dev.zip` and its SHA-256. The explicit allowlist contains six Lua modules, README, DEVELOPMENT, CHANGELOG and the activation marker. No game content, tools, tests or references are packaged. No release publication is authorized.

### In-game checks

1. Compare every combination in a small active catalogue with native predictions, including partial/empty menus, different forecasts/weather/events, prices and missing ingredients.
2. Verify unavailable, disabled and unstaffed dishes do not enter the result; current tied choices remain; lunch/dinner remain separate.
3. Verify only the final menu is saved, the page refreshes, and an empty result is accepted and deactivated by the native game.
4. Check one button, supported languages, host-only use and repeated Lua hot reload. Compare timing shares and gameplay responsiveness for different active catalogue sizes; retain the four search log lines for diagnosis.

## 中文

**0.4.1-dev，待游戏内验收。** 独立 Lua Mod，不使用原生辅助 DLL。本机接口核对版本为 Steam Build 25532071 / ProjectVersion 1.0.1.44eb。原生分析和参考资料留在忽略的 `work/`。

### 实现

- `game.lua` 从各类别选择器读取菜品编号，与 `AvailableDishes` 取交集，排除 `DisabledDishes`、`EmployeeRequirementDisabledDishes`、选择器禁用项和类别不符项。每类加入零编号表示留空；当前选项符合条件时排在首位，其余按固定编号排序。生成候选不读取标签、食材数组、成本、价格、满意度或影响力快照。
- `planner.lua` 用一个复用的试算表递归遍历全部组合，直接比较原生选择率，只复制更好的结果。包含各类别留空和全空菜单，达到原生最大值可提前结束；无等价签名、预搜索、记忆表或独立菜品评分。
- `Game.compose` 在原生按钮的游戏线程回调内同步执行。只读一次原菜单，当前调用内复用菜单结构引用，仅写变化的菜品字段；每个组合调用 `GetDailyMenuProjection(period).EstimatedAdoptionRate`。试算不保存、不让出执行、不发 RPC，也不改采样属性；受保护的试算段结束或失败后恢复原菜单。完成后调用 `SaveDailyMenu` 一次，核对菜品字段并刷新页面。全空菜单由原生保存自动停用，属于正常结果。
- `main.lua` 按 Mod 按钮身份筛选点击并阻止重入。唯一的定时器每 500 毫秒发现／更新按钮，不调度搜索。成功日志记录选择率、试算次数和耗时分布。`ui.lua` 仅维护本地化按钮文字和提示，无进度、取消或状态倒计时；`reload.lua` 负责 Lua 重载后的按钮清理。

全部组合在一次游戏线程回调中完成，因此没有跨批次条件快照或“条件已变化”取消流程。组合数量仍呈乘积增长；同步执行去掉了人为等待并简化实现，但候选较多时游戏会等待枚举完成。此版本不宣称已经测得实机提速。

### 计时日志

`SEARCH` 记录餐段、含零编号的各类有效选项数、全部组合数和 `clock=os.clock`。`COMPOSED` 保留原生选择率、实际试算数和耗时秒数。`TIMING` 记录总／搜索毫秒数、预测调用平均毫秒数、变化菜品字段写入数，以及 `stop=exhausted`（完整枚举）或 `native_ceiling`（达到上限，试算少于全部组合）。`TIMING_PARTS` 记录各阶段毫秒数及占总耗时百分比：

| 字段 | 测量范围 |
| --- | --- |
| `setup` | 房主检查、原菜单、候选编号、原生上限和开始日志 |
| `writes` | 比较五个试算字段并写入变化项 |
| `projection` | `GetDailyMenuProjection`，包含 UE4SS 分派和返回结构转换 |
| `rate_read` | 从返回结构读取 `EstimatedAdoptionRate` |
| `restore` | 最终保存前恢复原菜单 |
| `save` | `SaveDailyMenu`，包括它触发的同步原生回调 |
| `verify` | 回读并核对保存的菜品字段 |
| `refresh` | 显式调用 `RefreshDailyMenus` |
| `lua_and_timing` | 其余遍历、比较、复制、统计和计时开销 |

九项互不重复，显示取整前相加等于总耗时；`search_ms` 是包含搜索各项的子合计，不再加进占比。沿用 Lua `os.clock`，不使用游戏时间；每个组合读四次时钟，不增加原生预测调用。时钟精度有限，极短阶段可能为零，占比为近似值；平均值由累计时间除以次数得到，不代表单次高精度采样。计时本身的开销分布在各区间内，不能把结果当作零开销基准。总耗时截至刷新完成，不含结束摘要的格式化／输出和外层按钮钩子检查。失败时保留 `SEARCH` 和原有错误日志，不输出完整占比。不会据此声称已经测出原生函数内部各项的耗时。

### 验证

执行英文部分命令。七组离线测试覆盖完整遍历、非加性目标、微小选择率提升、当前菜单同值保留、原生上限提前结束、资格过滤、空菜单保存、变化字段写入、预测异常恢复、单次保存、合成时钟的阶段归属与总和、日志数量、零耗时日志、重入、多语言和热重载。

合成计数：每类两道启用菜为 243 次原生试算，包含全空菜单；每类八道为 59,049 次。将同一目录限制为三个类别各一道启用菜后为八次。测试要求没有额外的价格、库存或模拟状态采集，也没有搜索定时器。以上使用假对象验证工作量，不是实机计时或真实引擎桥接验收。

构建生成 `outputs/auto-menu/AutoMenu-0.4.1-dev.zip` 和 SHA-256。固定白名单只含六个 Lua 模块、README、DEVELOPMENT、CHANGELOG 和启用标记，不含游戏内容、工具、测试或参考资料。此版本未授权公开发布。

### 实机检查

1. 少量启用菜时逐个组合对照原生预测，包含部分／全空菜单、不同客流／天气／活动、价格和缺料情况。
2. 确认不可用、停用和缺少员工的菜品不进入结果，同值保留当前合规选项，午餐／晚餐互不影响。
3. 确认只保存最终菜单并刷新页面，全空结果正常保存并自动停用。
4. 检查单按钮、多语言、房主限制和反复热重载，按不同启用菜品数量对比耗时占比和游戏响应，保留四条搜索日志用于定位。
