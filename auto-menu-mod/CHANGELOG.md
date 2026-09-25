# Changelog / 版本变化

## Unreleased

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
