# Changelog / 更新记录

## Unreleased

- Supports game 1.0.2.44eb (Steam Build 25822788).
- 支持游戏 1.0.2.44eb（Steam Build 25822788）。

- Documentation: rewrote the player guide in plainer language, focused on what the Mod does and how to use it.
- 文档：用更简洁的语言重写玩家说明，只保留功能介绍和操作方法。

## 0.1.2 - 2026-10-07

- Supports game 1.0.2.44eb (Steam Build 25759268).
- Fixed table detection for the game's renamed table type, so orders are placed again on the new game version; the older name still works. If the game's tables or the functions the Mod needs can't be found, automatic ordering stops instead of guessing.
- 支持游戏 1.0.2.44eb（Steam Build 25759268）。
- 修复新版游戏中餐桌类型改名后无法识别餐桌的问题，自动点餐恢复正常，旧名称仍兼容。找不到餐桌或所需游戏功能时，自动点餐会停止，不会盲目下单。
- Documentation: added the Nexus cover to the README and removed outdated download notes.
- 文档：README 加入 Nexus 宣传封面，删除过时的下载说明。

## 0.1.1 - 2026-09-26

### Documentation update / 文档更新 — 2026-09-26

- Documentation: expanded the player guide with controls, behaviour, multiplayer requirements and what to do when an order waits or ordering stops.
- 文档：补充玩家说明中的操作方式、功能行为、联机要求，以及订单等待或自动点餐停止时的处理方法。

### English

- First stable release of the 0.1.1 changes.
- Places customers' food and drink orders on the host, waits for missing stock and continues after restocking, using the game's own order data.
- Added the screenshot of food and drink order icons.
- Added English and Chinese install, usage and update guides, plus the MIT license. Images are not part of the download.

### 中文

- 0.1.1 的改动转为正式版。
- 房主端自动提交顾客的食物和饮料订单，缺货时等待、补货后继续，下单沿用游戏自身的订单数据。
- 附上餐品与饮料订单图标的实机截图。
- 附上中英文安装、使用、更新说明及 MIT 许可；图片不包含在下载包中。

## 0.1.1-dev

- Added the gameplay screenshot of food and drink order icons to both README languages.
- 中英文 README 加入餐品与饮料订单图标的实机截图。

- Added an assets folder for screenshots and artwork.
- 新增 assets 文件夹，用于存放实机截图和宣传图。

- Rewrote the install, usage, update and removal guides, and fixed links that are opened from the extracted package.
- 重写安装、使用、更新和卸载说明，并修复从解压包中打开的说明链接。

- The MIT license is now included in the download.
- 下载包中附上 MIT 许可全文。

- 0.1.1-dev: more reliable order placement — the game now copies the full order itself, and dish icons are no longer read.
- The silent stock check handles dishes with several ingredients correctly, including after restocking.
- 0.1.1-dev：下单更稳定，完整订单数据交由游戏自行复制，不再读取菜品图标。
- 静默库存检查可正确处理多种食材的菜品，补货后同样有效。

## 0.1.0-dev

- First Scan to Order release: places the food and drink orders customers have already chosen, in single player or on the host, without a waiter or player taking them.
- Waits for missing stock and continues after restocking; the game's preparation rules and customer patience still apply.
- Checks the game's order state so nothing is ordered twice, and stays stopped across script reloads when an order's result is unclear.
- 扫码点餐首个版本：单人或房主端自动提交顾客已经选好的食物和饮料，无需服务员或玩家点餐。
- 缺货时等待，补货后继续；游戏原有的制作规则和顾客耐心照常生效。
- 核对游戏订单状态，避免重复下单；订单结果不明时，重新加载脚本后仍保持停止。
