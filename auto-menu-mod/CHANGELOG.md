# Changelog / 版本变化

## Unreleased

- Auto Menu 0.2.0-dev replaces tag scoring with the game's native estimated selection rate as the sole optimization objective.
- Search complete combinations, including optional empty courses; compare unrounded rates and stop only after exhaustive coverage or reaching the native ceiling.
- Add batched search, progress and cancellation. Restore every trial before returning; save the final winner once, preserving the active state and other service.
- Cancel when native prediction inputs or the UI context change. Add objective, rollback, changed-input and asynchronous lifecycle tests; update all 14 languages. In-game acceptance remains pending.
- Auto Menu 0.2.0-dev 移除标签评分，以游戏原生预计选择率作为唯一优化目标。
- 比较完整组合及可选类别留空，使用未取整数值，遍历完成或达到原生上限才结束。
- 新增分批搜索、进度和取消；每次试算恢复原菜单，最终方案只保存一次，保留启用状态与另一餐段。
- 原生预测输入或界面条件变化时取消，新增目标、恢复、条件变化及异步生命周期测试，并更新 14 种语言。实机验收待完成。
