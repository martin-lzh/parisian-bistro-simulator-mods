# Changelog / 更新记录

## Unreleased

## 0.1.1 - 2026-09-26

### English

- Promote 0.1.1-dev to 0.1.1 after the maintainer confirmed that all current Mods passed in-game and multiplayer testing and explicitly authorized stable publication on 2026-09-26. Retain the tested gameplay logic; update version identifiers, package names and release documentation.
- Submit customer food and drink orders on the host, defer missing-stock items and resume after replenishment; preserve native order data without converting complete dish assets through Lua.
- Include the gameplay screenshot of food and drink order indicators.
- Include English/Chinese installation, usage and update guides, the MIT license, and verified package contents. Documentation images remain outside the installable ZIP.

### 中文

- 维护者于 2026-09-26 确认全部当前 Mod 实机及联机测试通过，并明确授权发布正式版，据此将 0.1.1-dev 转为 0.1.1；保留已测试的玩法逻辑，更新版本标识、包名和发布说明。
- 房主端自动提交顾客食物与饮料订单，缺货时等待并在补货后续单；保留原生订单数据，不通过 Lua 转换完整菜品资源。
- 附上餐品与饮料订单状态实机截图。
- 附上中英文安装、使用、更新说明及 MIT 许可，并校验包内容；文档图片不进入安装 ZIP。

## 0.1.1-dev

- Add the maintainer-provided gameplay screenshot showing food and drink order indicators to both README languages, with image provenance and scene notes.
- 将维护者提供的餐品与饮料订单状态实机图加入中英文 README，并记录图片来源及可见场景。

- Add an assets directory for in-game test screenshots and promotional artwork, with README links and embedding examples.
- 新增 assets 目录存放实机测试图与宣传图，并提供 README 入口和图片引用示例。

- Rewrite player installation, usage, update and removal guides; move implementation and reload details into developer documentation and repair links used from extracted packages.
- 重写面向玩家的安装、使用、更新及卸载说明，将实现与重载细节移入开发文档，并修复解压后使用的文档链接。

- Include the MIT license in source and installable packages, with packaging checks for missing or changed license text.
- 为源码及安装包附上 MIT 许可全文，增加许可缺失或内容改变时的打包校验。

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
