# Changelog / 版本变化

## Unreleased

- Add an assets directory for in-game test screenshots and promotional artwork, with README links and embedding examples.
- 新增 assets 目录存放实机测试图与宣传图，并提供 README 入口和图片引用示例。

- Keep the Auto-compose button label on one line and size the button to its localized text.
- 自动组合按钮文字固定单行，按钮宽度随本地化文字自动调整。

- Adopt **菜单巧配** as the Chinese display name in player guides and shared documentation.
- 中文名称统一为 **菜单巧配**，同步玩家说明及公共文档。

- Rewrite player installation, usage, update and removal guides; move implementation and reload details into developer documentation and repair links used from extracted packages.
- 重写面向玩家的安装、使用、更新及卸载说明，将实现与重载细节移入开发文档，并修复解压后使用的文档链接。

- Include the MIT license in source and installable packages, with packaging checks for missing or changed license text.
- 为源码及安装包附上 MIT 许可全文，增加许可缺失或内容改变时的打包校验。

- Auto Menu 0.5.0-dev adds an original Windows x64 helper that enumerates menus and caches original single-dish scores for one synchronous search. Every combination still uses the full native projection; empty courses, exact rates, stable ties and the native ceiling are preserved.
- Remove per-candidate Lua property writes and projection-table conversion. Compare every candidate in domains of at most 243 combinations with caching disabled; larger domains compare the first 32, and every search checks its winner. Restore the original menu before the existing one-save path, including failures.
- Add native search/cache metrics, native calling-convention discovery and ownership tests, and a generated-DLL package allowlist. DLL updates require restarting the game. In-game speed and native integration acceptance remain pending.
- Auto Menu 0.5.0-dev 新增原创 Windows x64 辅助模块，在一次同步搜索内枚举菜单并缓存原生单菜评分。每个组合仍调用完整原生预测，保留留空选项、精确选择率、固定同值顺序和原生上限。
- 去掉逐组合 Lua 属性写入及预测表转换。最多 243 个组合时逐个关闭缓存对照；更大搜索对照前 32 个，每次都复核最终菜单。成功或失败均恢复原菜单，之后沿用原生单次保存。
- 新增原生搜索／缓存统计、调用布局发现与内存归属测试，以及生成 DLL 的安装包白名单。DLL 更新需要重启游戏；实机速度和原生接入仍待验收。

## 0.4.1-dev

- Auto Menu 0.4.1-dev adds per-search timing logs: eligible option counts including empty choices, total combinations, actual evaluations, changed field writes, native projection average and stopping reason.
- Report milliseconds and percentages for setup, trial writes, native projection dispatch/return, rate extraction, restore, save, save verification, refresh and remaining Lua/timing overhead. Aggregate in memory; never log individual trials. The existing `os.clock` timer has limited resolution, so short phase shares are approximate. Search and selection behavior are unchanged.
- Auto Menu 0.4.1-dev 新增每次搜索的计时日志：包含留空的各类候选数、全部组合数、实际试算数、变化字段写入数、原生预测平均耗时和结束原因。
- 分别记录准备、试算字段写入、原生预测调用及返回、选择率读取、恢复、保存、保存核对、刷新，以及其余 Lua／计时开销的毫秒数和占比。内存累计，不逐组合写日志；沿用的 `os.clock` 精度有限，短阶段占比为近似值。搜索与选优行为不变。

## 0.4.0-dev

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
