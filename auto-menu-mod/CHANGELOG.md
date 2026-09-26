# Changelog / 版本变化

## Unreleased

- Auto Menu 0.4.0-dev uses a direct synchronous search: collect eligible dish IDs, call the native prediction for each combination, then apply the highest-rate menu once.
- Remove search timers, progress/cancellation UI, forecast snapshots, repeated price/stock checks, equivalence grouping and warm-start state. Reuse one trial table and write only changed dish fields.
- Include empty choices in every course and the completely empty menu. An empty winning menu follows native saving behavior and is deactivated by the game. Ties retain the eligible current menu; reaching the native ceiling can still end search early.
- Restore the original menu if a trial fails. Keep host-only use, 14 languages and Lua hot reload. Synchronous enumeration may pause gameplay when many combinations exist; real game timing remains unverified.
- Auto Menu 0.4.0-dev 改为直接同步搜索：取得可用菜品编号，逐个组合调用原生预测，最后应用预计选择率最高的菜单一次。
- 移除搜索定时器、进度／取消界面、预测条件快照、重复价格与库存检查、等价分组和预搜索状态；复用试算表，只写入变化的菜品字段。
- 每类都可留空，全空菜单也参与比较；全空结果按原生保存行为自动停用。同值保留符合条件的当前菜单，达到原生上限仍可提前完成。
- 试算失败恢复原菜单，保留房主限制、14 种语言和 Lua 热重载。大量组合的同步枚举可能暂停游戏响应，实际游戏耗时待验证。

## 0.3.0-dev

- Auto Menu 0.3.0-dev explicitly filters available, enabled and staffed dishes before building the search space. Locked or disabled selector entries cannot re-enter it.
- Collapse native-equivalent dishes into representative choices, preserving the native objective and optional courses. A short warm start can reach the proven ceiling early; otherwise every remaining representative combination is covered, without a local-optimum shortcut.
- Protect and restore simulation state once per synchronous batch; use live silent ingredient checks instead of the page's stock cache. Log candidate counts, reduced combinations, evaluations and elapsed time.
- Add brute-force comparisons, price-boundary and stock-isolation cases, batch rollback and a synthetic performance workload. In-game performance and bridge acceptance remain pending.
- Auto Menu 0.3.0-dev 在生成组合前过滤实际可用、启用且满足员工条件的菜品，排除选择器残留的锁定或停用项目。
- 将原生选择率等价的菜品合并为代表候选，保留原生目标与类别留空。先快速找候选，达到原生上限即可结束；否则覆盖全部代表组合，不把局部最优当成完成。
- 每个同步批次统一保护和恢复状态，使用实时静默库存检查，新增候选数量、压缩前后组合数、试算次数及耗时日志。
- 新增完整枚举对照、价格边界、库存差异、批次异常恢复和合成性能测试；实际游戏性能与桥接仍待验收。

## 0.2.1-dev

- Auto Menu 0.2.1-dev fixes false cancellation during ordinary native influence decay and satisfaction updates. Search samples these values once, uses native projection for every candidate and restores live properties after each query.
- Compare canonical native list contents instead of their order. Log the changed field for genuine cancellations.
- Recheck live native rates before saving; retain a better existing menu if rankings changed. Add regression coverage for drift, reordering and sampled-state restoration failures.
- Auto Menu 0.2.1-dev 修复原生影响力正常衰减、满意度更新导致的误取消，统一采样后继续调用原生预测，每次试算恢复实时属性。
- 原生列表按内容比较，避免排列变化误取消；真实取消记录具体变化字段。
- 保存前复核实时原生选择率，排名变化时保留更好的现有菜单，补充数值变化、列表重排、采样状态恢复异常的回归测试。

## 0.2.0-dev

- Auto Menu 0.2.0-dev replaces tag scoring with the game's native estimated selection rate as the sole optimization objective.
- Search complete combinations, including optional empty courses; compare unrounded rates and stop only after exhaustive coverage or reaching the native ceiling.
- Add batched search, progress and cancellation. Restore every trial before returning; save the final winner once, preserving the active state and other service.
- Cancel when native prediction inputs or the UI context change. Add objective, rollback, changed-input and asynchronous lifecycle tests; update all 14 languages. In-game acceptance remains pending.
- Auto Menu 0.2.0-dev 移除标签评分，以游戏原生预计选择率作为唯一优化目标。
- 比较完整组合及可选类别留空，使用未取整数值，遍历完成或达到原生上限才结束。
- 新增分批搜索、进度和取消；每次试算恢复原菜单，最终方案只保存一次，保留启用状态与另一餐段。
- 原生预测输入或界面条件变化时取消，新增目标、恢复、条件变化及异步生命周期测试，并更新 14 种语言。实机验收待完成。
