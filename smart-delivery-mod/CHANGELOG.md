# Changelog

## Unreleased

- Supports game 1.0.2.44eb (Steam Build 25822788).
- 支持游戏 1.0.2.44eb（Steam Build 25822788）。

- Documentation: added the cover image to the README and removed outdated download instructions.
- 文档：README 加入宣传封面，删除过时的下载说明。

- Documentation: rewrote the player guide in plainer language, focused on what the Mod does and how to use it.
- 文档：用更简洁的语言重写玩家说明，只保留功能介绍和操作方法。

- The Mod is now licensed under the PolyForm Noncommercial License 1.0.0: free to use, share and modify for non-commercial purposes; commercial use is not allowed. Versions released before this stay under MIT.
- 本 Mod 改用 PolyForm Noncommercial 1.0.0 许可：可免费用于非商业用途的使用、分享和修改，不允许商用。此前已发布的版本仍为 MIT 许可。

## 0.1.5 - 2026-09-26

### English

- First stable release.
- Choose Free service, Budget delivery or Premium delivery for automatic smart orders. Your choice is saved and kept after restarts.
- Falls back to English if the game language can't be read; supports script reload without restarting the game.
- Delivery selector restyled: dark background, white text and green highlight for the selected and focused option.
- Supports game 1.0.2.44eb (Steam Build 25759268).
- Documentation: English/Chinese install, usage and update guide with in-game screenshots, plus the MIT license.

### 中文

- 首个正式版。
- 为自动智能订购选择免费服务、经济型配送或高级配送；选择会保存，重启后保留。
- 读取不到游戏语言时显示英语；支持不重启游戏重新加载脚本。
- 配送选择框改用深色底、白色文字，选中项和焦点项以绿色突出显示。
- 支持游戏 1.0.2.44eb（Steam Build 25759268）。
- 文档：中英文安装、使用和更新说明，附实机截图和 MIT 许可。

## 0.1.5-dev

- Restyled the delivery selector: charcoal background, soft white text and muted green selection, including hover, pressed, disabled and keyboard-focus states, without the default blue highlight.
- 配送选择框改用炭灰底色、柔白文字和低饱和绿色选中项，统一悬停、按下、禁用及键盘焦点状态，去掉默认亮蓝高亮。

- Documentation: added in-game screenshots of the settings window and delivery selector, and an assets folder for images.
- 文档：加入设置窗口和配送选择框的实机截图，新增图片目录。

## 0.1.4-dev

- Chinese name is now **配送随心**.
- 中文名称定为 **配送随心**。

- Rewrote the install, usage, update and removal guide, and fixed links that broke inside the extracted package.
- 重写安装、使用、更新及卸载说明，修复解压后文档中失效的链接。

- The MIT license is now included in the Mod ZIP.
- Mod ZIP 现附带 MIT 许可全文。

- If the game language can't be read, the selector shows English and keeps working, without losing an unsaved choice. Translated text returns once the language can be read again.
- 读取不到游戏语言时，选择框显示英语并继续工作，不丢失未保存的选择；恢复读取后重新显示对应语言。

- Added script reload without restarting the game: the old selector is removed and the saved choice is restored. Updating the DLL still requires a game restart.
- 新增不重启游戏重新加载脚本：清除旧选择框并恢复已保存的选择。更新 DLL 仍需重启游戏。

## 0.1.3-dev

- The delivery list's selected value and options now use white text.
- 配送下拉框的当前选项和展开列表改用白色文字。

## 0.1.2-dev

- No longer tied to one exact game build: the Mod now finds the automatic delivery code itself, so it keeps working after game updates that don't change it. Checked against Steam Build 25532071.
- 不再限定单一游戏版本：Mod 会自行定位自动配送代码，游戏更新未改动这部分时可继续使用。已对照 Steam Build 25532071 核对。

- Stops safely if the game code has changed or another Mod changes the same code.
- 游戏代码发生变化，或其他 Mod 修改了同一处代码时，安全停用。

## 0.1.1-dev

- Fixed the 0.1.0-dev startup failure `Invalid compatibility range`.
- 修复 0.1.0-dev 启动失败（`Invalid compatibility range`）。

- Updating the helper DLL requires a game restart.
- 更新辅助 DLL 需要重启游戏。

## 0.1.0-dev

- Added Free service, Budget delivery and Premium delivery to the automatic smart-order settings. The choice follows the game's Save/Cancel and is kept after restarts for the whole installation.
- Order conditions, costs, night fees and unloading staff follow the game's rules; manual orders keep their own delivery choice.
- Delivery names use the game's translations, and the new field label is translated into all 14 game languages.
- Includes a Windows helper DLL.

- 在自动智能订购设置中加入免费服务、经济型配送和高级配送，跟随游戏的保存/取消，重启后保留，同一安装共用。
- 下单条件、费用、夜间附加费和卸货人数按游戏规则；手动订单保留各自的配送选项。
- 配送名称沿用游戏译文，新增字段标题覆盖全部 14 种游戏语言。
- 附带 Windows 辅助 DLL。
