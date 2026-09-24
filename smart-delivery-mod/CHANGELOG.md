# Changelog

## Unreleased

- Fix the 0.1.0-dev `Invalid compatibility range` startup failure by validating zero-filled runtime data against mapped PE sections. Keep full executable hashing and evaluator code checks.
- Add PE range regression tests and a UI attachment diagnostic. Updating the native helper requires a game restart. Package version: 0.1.1-dev; in-game retesting is pending.

- 修复 0.1.0-dev 的 `Invalid compatibility range` 启动失败，改为按 PE 映射节区核验零填充运行时数据，保留完整可执行文件哈希及执行代码校验。
- 新增 PE 范围回归测试及界面注入日志。更新辅助模块需重启游戏。安装包版本为 0.1.1-dev，待实机复测。

## 0.1.0-dev

- Add Free service, Budget delivery and Premium delivery to automatic smart-order settings, with native Save/Cancel behavior and a persistent installation-wide preference.
- Keep native order eligibility, costs, night fees and staffing, while leaving manual orders independent.
- Reuse translated game delivery names and localize the new field label for all 14 game languages.
- Add a Windows helper restricted to the verified game build, native dispatch tests, Lua tests and package verification. In-game acceptance is pending.

- 在自动智能订购设置中增加免费服务、经济型配送和高级配送，支持保存/取消及跨重启保留偏好。
- 保留原生采购条件、扣款、夜间附加费和配送人数，手动订单保持独立。
- 沿用游戏配送名称翻译，新增字段标题覆盖 14 种语言。
- 加入限定游戏构建的 Windows 辅助模块、原生分派测试、Lua 测试和安装包校验，待实机验收。
