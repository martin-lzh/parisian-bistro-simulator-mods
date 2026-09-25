# Development and validation / 开发与验收

[English](#english) · [中文](#中文)

## English

**0.2.1-dev; in-game acceptance pending.** Auto Menu is an independent Lua Mod without a native helper or another Mod dependency.

### Implementation

- `game.lua` gets eligible candidates from the native page's persistent selectors. Its objective is exclusively `GetDailyMenuProjection(period).EstimatedAdoptionRate`, the unrounded value behind the game's estimated selection rate. No adoption formula or preference weights are reproduced.
- The native projection accepts a service period. For each query, the adapter temporarily assigns the candidate definition to that service's manager property, checks the native menu binding, reads the pure projection, and restores the original menu and sampled properties in protected cleanup. Search trials use click-time native influence and satisfaction: the native influence getter is supplied the sampled value with its no-decay half-life setting during the call, and all three live scalar properties are restored afterward. Game time and the influence timestamp are never changed. This synchronous transaction stays on the game thread and never saves, broadcasts, sends an RPC or yields. Projection errors and partial assignment errors run the same restoration path. Only the scalar rate is retained; no temporary struct-array wrappers survive the call.
- `planner.lua` enumerates the Cartesian product of enabled native options plus an empty choice per course, excluding the wholly empty menu. This compares complete combinations, including interactions between courses. It finishes after visiting every combination or reaching `GetDailyMenuMaximumPromotedAdoptionChance()`, the native projection's upper bound. Rates are compared without rounding or an epsilon. An eligible existing menu is evaluated first and retained on a tie; subsequent order prefers stocked options and then stable identifiers. There is no search-size truncation or local-optimum completion.
- `main.lua` runs search slices on the game thread every 16 ms, at most 128 evaluations or a 4 ms clock budget per view per slice. A native call cannot be preempted; this is a scheduling budget, not a frame-time guarantee. UI discovery and progress refresh run every 500 ms. The button remains clickable to cancel, with reentrant callbacks blocked during a slice/save.
- Before each slice and before applying, guards compare authority, world/manager identity, service, original menu, daily forecast/context, native ceiling/bonus, tier/difficulty, dish eligibility arrays, selector candidates, prices and ingredient availability. Actual changes cancel without saving and log the changed field. Native arrays are sorted before comparison so order changes alone do not cancel. Normal influence decay and satisfaction updates do not invalidate the search: every trial uses the same sampled native context. The winner is rechecked under that sample, then both it and the current menu are projected with live values. A better existing menu is retained without saving; otherwise one normal native save, readback check and page refresh apply the winner. The exhaustive optimum is for the sampled influence/satisfaction, not a guarantee of the optimum at a later time.
- `ui.lua` creates the native button at runtime beside Print menu. Text wraps and follows all 14 game languages, including progress, cancellation and changed-condition states. `reload.lua` transfers only widget identity strings; unload stops callbacks without engine access, and the next state removes old buttons on the game thread. Pending searches are discarded.

The active flag and the other service are preserved. There is no automatic run on opening, changing days or reloading. No pricing, purchasing or printing is performed. Native calls and Lua property conversion were checked against the local game/loader references. All local analysis stays in ignored `work/`; the package contains original Mod code only.

### Offline validation

From the repository root:

```powershell
uv run --with lupa==2.6 python auto-menu-mod/tests/run.py
python auto-menu-mod/build.py
python tools/check_repository.py
python tools/check_syntax.py
python -m unittest discover -s tools/tests -v
git diff --check
```

Tests use invented dishes and synthetic native predictions. They cover exhaustive combination coverage, a joint optimum with empty courses, improvements smaller than display precision, native upper-bound termination, time/evaluation budgets, ties, disabled dishes, non-finite results, restoration after failed queries/partial writes, changed inputs, native refusal, one-save completion, cancellation, other/reentrant buttons, service isolation, ordinary influence/satisfaction drift, semantically identical reordered arrays, live ranking reversal, sampled-property cleanup failures, languages and reload cleanup. These tests do not validate real UE4SS bridging, native performance, rendering or multiplayer behavior.

`build.py` writes `outputs/auto-menu/AutoMenu-0.2.1-dev.zip` and its SHA-256. The fixed allowlist includes six Lua modules, README, DEVELOPMENT, CHANGELOG and the activation marker. Tests, references, tools, game content and loader files are excluded. Common CI checks verify source bytes and archive contents. This development version has no release authorization.

### In-game checklist

1. Check one button beside Print menu across screen sizes and all 14 languages. Verify mouse, keyboard/controller focus and activation, progress and cancellation.
2. For a small unlocked menu, manually compare all combinations using the native displayed prediction. Verify the winning selection rate, optional courses, unchanged active state and other service. The UI rounds its percentage; logs record a more precise rate.
3. Confirm that trials leave the saved menu unchanged between ticks and on cancellation/errors. Verify one final native save and host/guest replication, without intermediate notifications or saves.
4. Test different forecasts, weather/events, prices, missing ingredients and promotion influence. Change conditions during a search, switch service, close/rebuild the page and lose host authority: no stale result should apply.
5. Measure actual search cost with many unlocked dishes and a rate below the native ceiling. Confirm responsive cancellation and completion despite ordinary influence decay/satisfaction updates. Check live menu/influence/half-life/satisfaction restoration after each slice, including errors, and retention of a better existing menu if live rankings reverse.
6. Reload repeatedly with a search in progress: one working button, no old search completion, no automatic composition and no sustained errors.

## 中文

**0.2.1-dev，待游戏内验收。** Auto Menu 是独立 Lua Mod，无原生辅助 DLL 或其他 Mod 依赖。

### 实现

- `game.lua` 从原生页面持有的选择器读取候选，唯一优化目标是 `GetDailyMenuProjection(period).EstimatedAdoptionRate`，即页面预计选择率背后的未取整数值。不复刻采用率公式或顾客偏好权重。
- 原生预测接口只接受餐段。每次试算暂时将候选写入管理器对应餐段字段，验证原生菜单绑定，读取纯预测接口，然后在受保护的清理路径中恢复原菜单及试算属性。搜索使用点击时原生影响力和满意度；单次调用期间给原生影响力读取器提供采样值及其不衰减的半衰期设置，随后恢复三个实时标量属性，不更改游戏时间或影响力时间戳。全过程在游戏线程同步完成，不保存、不广播、不发送 RPC，也不中途让出执行。预测异常和部分写入异常同样恢复；仅保留选择率标量，不保留临时结构数组包装。
- `planner.lua` 枚举各类别启用候选与留空选项的笛卡尔积，排除全空菜单，因此比较的是完整组合及类别间相互影响。遍历全部组合，或达到原生 `GetDailyMenuMaximumPromotedAdoptionChance()` 上限后结束。比较不取整、不设误差容限。优先试算符合条件的当前菜单，同值保留；其余候选按食材齐全、固定编号排序。不截断组合数量，不把局部最优视为搜索完成。
- `main.lua` 每 16 毫秒在游戏线程运行一个搜索批次，每个界面每批最多 128 次试算或 4 毫秒时钟预算。无法抢占单次原生调用，因此这是调度预算，不是帧耗时保证。每 500 毫秒扫描界面并刷新进度，搜索时按钮仍可点击取消；试算和保存期间阻止重入。
- 每批及最终保存前比较权限、世界与管理器身份、餐段、原菜单、当天预测与条件、原生上限及加成、餐厅等级与难度、菜品资格数组、候选、价格和食材可用性。真实变化时取消且不保存，日志记录变化字段。原生数组比较前按标识排序，避免仅排列变化误触发。正常影响力衰减及满意度更新不取消，各候选统一使用同一组原生采样条件。最终方案先按采样条件复核，再用实时原生数值比较候选与现有菜单。现有菜单更好时保留且不保存，否则原生保存一次、读回并刷新。完整搜索的最优范围是采样时的影响力与满意度，不承诺后续时刻仍为全局最优。
- `ui.lua` 在打印按钮旁运行时创建原生按钮，文字换行并支持游戏 14 种语言，包括搜索进度、取消和条件变化。`reload.lua` 跨状态只传递按钮身份字符串；卸载时停止回调且不访问引擎，新状态在游戏线程清除旧按钮，未完成搜索直接丢弃。

保留启用状态及另一餐段；打开页面、切换日期、重载不自动配餐。不改价、不采购、不打印。原生调用与 Lua 属性转换已根据本机游戏及加载器参考核对；分析资料全部留在忽略的 `work/`，安装包只包含原创 Mod 代码。

### 离线验证

在仓库根目录执行英文部分命令。虚构菜品和原生预测替身覆盖完整组合、包含留空类别的联合最优、低于显示精度的提升、原生上限提前结束、分批预算、同值处理、禁用菜、非有限数值、试算和部分写入失败后的恢复、输入变化、原生拒绝、单次保存、取消、其他按钮及重入、餐段隔离、影响力与满意度正常变化、等价数组重排、实时排名反转、采样属性失败恢复、语言和热重载。

这些测试不等于真实 UE4SS 桥接、性能、渲染或联机验证。构建输出 `outputs/auto-menu/AutoMenu-0.2.1-dev.zip` 及 SHA-256；白名单包含六个 Lua 模块、README、DEVELOPMENT、CHANGELOG 和启用标记，不包含测试、参考、工具、游戏内容或加载器。统一 CI 校验源码字节及包内容；此开发版没有发布授权。

### 实机待验收

1. 检查不同分辨率、14 种语言下只有一个按钮，验证鼠标及键盘/手柄焦点、进度、取消。
2. 用少量解锁菜品手动对比各组合的原生预计选择率，检查最终结果、可选类别、启用状态和另一餐段。页面百分比会取整，日志记录更精确的值。
3. 验证试算之间及取消、异常后原菜单恢复；只有最终方案保存并同步给访客，不产生中间通知或保存。
4. 检查不同客流、天气、活动、价格、缺料和推广影响力；搜索中改变条件、切换餐段、关闭或重建页面、失去房主权限，均不得应用过期方案。
5. 大量解锁菜品且未达原生上限时实测耗时、取消响应，确认影响力衰减和满意度更新不会中断。检查每批及异常后菜单、影响力、半衰期、满意度均恢复；实时排名反转时保留更好的现有菜单。
6. 搜索中反复热重载，确认只有一个可用按钮，旧搜索不会完成，不自动配餐，无持续错误。
