# Changelog / 更新记录

## Unreleased

- 0.1.1-dev avoids converting complete dish return values through Lua. Read catalog row references and let the engine copy complete order data, without accessing dish icons.
- Copy ingredient identifiers and quantities into plain Lua records for the silent stock check. Add regression coverage for asset conversion, invalid catalog rows and multi-ingredient replenishment. Gameplay verification remains pending.
- 0.1.1-dev 避免通过 Lua 展开完整菜品返回值：读取菜品表记录引用，由引擎复制完整下单数据，不访问菜品图标。
- 静默库存检查使用独立的食材编号及数量记录。增加资源字段转换、无效菜品表及多食材补货的回归验证，仍待实机验收。

## 0.1.0-dev

- Add Scan to Order 0.1.0-dev: automatically place the game's existing customer food and drink choices on the host or in single player, without waiter/player order-taking.
- Wait for missing stock and resume outstanding items after replenishment; preserve native production rules and customer patience.
- Recheck native order state to prevent duplicates; suspend uncertain requests across Lua reloads. Add offline behavior tests and source-only packaging. In-game acceptance remains pending.
- 新增扫码点餐 0.1.0-dev：仅房主或单人自动提交游戏 AI 已选的食物和饮料，无需服务员／玩家点餐。
- 缺货时等待，补货后继续未完成项，保留原生制作条件和顾客耐心。
- 重查原生订单防止重复；结果不明时跨 Lua 热重载保持停止。加入离线行为测试与原创源码打包，待实机验收。
