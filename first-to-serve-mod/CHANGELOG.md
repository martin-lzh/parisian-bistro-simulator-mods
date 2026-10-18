# Changelog

## Unreleased

## 0.1.8 - 2026-10-18

- Supports game 1.0.2.44eb (Steam Build 25822788).
- 支持游戏 1.0.2.44eb（Steam Build 25822788）。

- Documentation: added the cover image to the README and removed outdated download instructions.
- 文档：README 加入宣传封面，删除过时的下载说明。

- Documentation: rewrote the player guide in plainer language, focused on what the Mod does and how to use it.
- 文档：用更简洁的语言重写玩家说明，只保留功能介绍和操作方法。

- The Mod is now licensed under the PolyForm Noncommercial License 1.0.0: free to use, share and modify for non-commercial purposes; commercial use is not allowed. Versions released before this stay under MIT.
- 本 Mod 改用 PolyForm Noncommercial 1.0.0 许可：可免费用于非商业用途的使用、分享和修改，不允许商用。此前已发布的版本仍为 MIT 许可。

## 0.1.7 - 2026-09-26

### Compatibility / 兼容性 — 2026-10-07

- Supports game 1.0.2.44eb (Steam Build 25759268).
- 支持游戏 1.0.2.44eb（Steam Build 25759268）。

### Documentation / 文档 — 2026-09-26

- Documentation: expanded the player guide with controls, pickup rules, multiplayer notes and when to release and hold again.
- 文档：补全玩家说明中的操作、拿取规则、联机说明，以及何时需要松键重新长按。

### English

- First stable release.
- Hold at a kitchen pass or drink output area with a tray or food trolley to collect the oldest ready items first. Short presses keep the normal action. The hold hint follows the game language and falls back to English if the language can't be read.
- Added kitchen pass and drink output screenshots and a gameplay GIF to the guide.
- Includes English/Chinese install, usage and update guides and the MIT license.

### 中文

- 首个正式版。
- 持托盘或餐车在出餐口、饮料出品台长按，按做好的先后拿取成品；短按保持原版操作。长按提示跟随游戏语言，读取不到语言时显示英文。
- 说明中加入出餐口、饮料出品台截图和实机动图。
- 附中英文安装、使用、更新说明及 MIT 许可。

## 0.1.7-dev

- Documentation: added screenshots, a gameplay GIF and an images folder; adopted the Chinese name **出餐有序**; rewrote the install, usage, update and removal guides.
- 文档：加入实机截图、实机动图和图片目录；中文名称统一为 **出餐有序**；重写安装、使用、更新及卸载说明。

- The Mod package now includes the MIT license.
- 安装包附上 MIT 许可全文。

- If the game language can't be read, the hint shows English and pickup keeps working; your language returns once it can be read again.
- 读取不到游戏语言时提示显示英文，取餐照常工作；之后读取成功即恢复所选语言。

- 0.1.7-dev: aim at the drink output surface to start pickup without aiming at a cup. Sweeping across the same surface keeps going, only full drinks are taken, and a short press still puts drinks down as normal.
- 0.1.7-dev：可直接对准饮料出品台面开始长按，无需瞄准某一杯；准星在同一台面内移动时继续拿取，只拿满杯饮料，短按仍按原版放下饮料。

- 0.1.6-dev: push a trolley to use the same hold at the kitchen pass, on ready dishes and on drinks. Normal and stack slots, drink-only slots and the tower-burger top slot are respected. Letting go of or switching the trolley stops pickup.
- 0.1.6-dev：推着送餐餐车时，可在出餐口、已做好的菜品和饮料处使用同样的长按拿取；遵守普通位、堆叠位、饮料专用位及高层汉堡的顶层限制。放开或更换餐车会停止拿取。

- 0.1.5-dev: added manual script reload with Ctrl+R. After a reload, release the key before holding again.
- 0.1.5-dev：支持 Ctrl+R 手动重载脚本；重载后须松键再重新长按。

- 0.1.4-dev: aim at the kitchen pass's pickup area to start pickup without aiming at a specific dish. Aiming directly at dishes and drinks, and short presses, still work. An empty pass doesn't start pickup; the hold hint shows below the normal pickup hint while dishes remain.
- 0.1.4-dev：可直接对准厨房出餐口的拿取区域长按，无需瞄准某一盘菜；直接瞄准菜品或饮料以及短按照常可用。空出餐口不会开始拿取；有可拿菜品时，长按提示显示在原版拿取提示下方。

- 0.1.3-dev: a hold now stays on the same source when the aimed item is taken or leaves an empty spot. Looking away, walking away, releasing or switching source still stops it.
- 0.1.3-dev：长按期间锁定同一来源，瞄准的餐品被拿走或留下空位时不再中断；转开视线、走开、松键或换到其他来源仍会停止。

- Fixed leftover hold hints after a script reload, including an old sidebar hint.
- 修复重载脚本后长按提示残留的问题，包括旧版侧边栏提示。

- The hold hint now appears only below the normal pickup hint and hides together with it or the HUD.
- 长按提示只显示在原版拿取提示下方，并随拿取提示或 HUD 一起隐藏。

- 0.1.2-dev: faster consecutive pickup; the request interval drops from 300 ms to 50 ms.
- 0.1.2-dev：连续拿取更快，请求间隔从 300 毫秒缩短到 50 毫秒。

- 0.1.1-dev: pickup starts only when aiming at a ready dish or finished drink; empty surfaces and pickup spots no longer start it.
- The hold hint sits directly below the click-to-pick-up hint.
- 0.1.1-dev：仅在瞄准可拿取的菜品或成品饮料时开始拿取，空台面和拿取点不再触发。
- 长按提示紧接在点击拿取提示下方。

- Renamed Oldest First to **First to Serve（先做好先端）**, including the install folder (`Mods/FirstToServe`) and log prefix. Pickup is unchanged.
- 将 Oldest First 更名为 **First to Serve（先做好先端）**，安装目录（`Mods/FirstToServe`）和日志前缀同步更改；拿取方式不变。

- 0.1.0-dev, first version: hold at the kitchen pass or drink output area to collect items in the order they were made.
- The hold hint uses the game's own key icons and is translated into all 14 game languages. Short presses are unchanged.
- 0.1.0-dev 首个版本：在出餐口或饮料出品台长按，按制作先后拿取餐品。
- 长按提示使用游戏原生按键图标，支持全部 14 种游戏语言；短按保持不变。
