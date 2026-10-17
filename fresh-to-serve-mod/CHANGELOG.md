# Changelog

## Unreleased

- Supports game 1.0.2.44eb (Steam Build 25822788).
- 支持游戏 1.0.2.44eb（Steam Build 25822788）。

- Documentation: rewrote the player guide in plainer language, focused on what the Mod does and how to use it.
- 文档：用更简洁的语言重写玩家说明，只保留功能介绍和操作方法。

## 0.1.3 - 2026-10-07

- Fixes the Mod stopping at startup on Steam Build 25759268 / 1.0.2.44eb. Earlier game builds keep working.
- 修复 Mod 在 Steam Build 25759268 / 1.0.2.44eb 上启动即停止的问题，旧版游戏照常可用。
- Documentation: added the cover image and removed outdated download instructions.
- 文档：加入宣传封面，移除过时的下载说明。

## 0.1.2 - 2026-09-26

### Documentation update / 文档更新 — 2026-09-26

- Documentation: expanded the guide to controls, behaviour, multiplayer and when replacements wait or stop.
- 文档：补充操作方式、功能行为、联机要求以及补单等待和停止的情况。

### English

- First stable release.
- Clears spoiled meals and drinks and orders replacements while the original customer has enough patience. No duplicate orders, and pending replacements survive a script reload.
- Includes English and Chinese install, usage and update guides and the MIT license.

### 中文

- 首个正式版。
- 清理变质的食物和饮料，原顾客耐心足够时自动补单。不会重复下单，待处理的补单在脚本重载后继续保留。
- 附带中英文安装、使用和更新说明及 MIT 许可证。

## 0.1.2-dev

- Documentation: added an assets folder for screenshots and artwork.
- 文档：新增 assets 文件夹，存放截图和宣传图。

- Chinese name is now **焕鲜上桌**.
- 中文名称统一为 **焕鲜上桌**。

- Documentation: rewrote the install, usage, update and removal guides.
- 文档：重写安装、使用、更新及卸载说明。

- The MIT license is now included in the download.
- 安装包中附带 MIT 许可证。

- Pending food and drink replacements now survive a manual script reload (Ctrl+R), keeping their timers and retry counts.
- If the Mod stops after an error, it stays stopped after a reload until you start a new session. The first update from an older version must be installed with the game closed.
- 手动重载脚本（Ctrl+R）后，待处理的食物和饮料补单继续保留，计时和重试次数不变。出错停止后，重载仍保持停止，直到开始新的游戏会话。从更早版本首次升级须关闭游戏安装。

- 0.1.1-dev: cleanup and replacements now also cover finished drinks and cocktails at drink output areas and elevator slots.
- Drink replacements go to the original customer without disturbing other customers' orders.
- Drink timing includes equipment fill and use time. Replacements need a working bartender on the floor, wait while you have claimed drinks, and recheck the customer and patience before each order.
- 0.1.1-dev：清理和补单扩展到饮料出品区和升降机上的成品饮料及鸡尾酒。饮料补单送给原顾客，不影响其他顾客的订单。耗时计入设备灌装和操作时间；需要该楼层有在岗调酒师，你认领饮料时会等待，每次下单前重新检查顾客和耐心。

- Renamed Fresh Service to Fresh to Serve (焕新上桌), including the Mod folder and log prefix. Gameplay is unchanged.
- Fresh Service 更名为 Fresh to Serve（焕新上桌），Mod 文件夹和日志前缀同步更改，玩法不变。

- 0.1.0-dev: first version. Clears spoiled cooked meals from kitchen passes and elevators and orders replacements through the normal kitchen.
- Replacements need the original customer and order to still be active and enough patience to cover cooking, the queue and serving. Patience is never reset.
- Counts meals already made or queued, keeps each order tied to its customer, limits retries and runs on the host only.
- Includes English and Chinese guides.
- 0.1.0-dev：首个版本。清理厨房出餐口和升降机上变质的熟食，核对原顾客、订单和耐心后补单，由服务员上菜。计入已做好或已排队的餐品，限制重试次数，仅在房主端运行；附带中英文说明。
