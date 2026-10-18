# Changelog / 版本变化

## Unreleased

## 0.5.1 - 2026-10-18

- Supports game 1.0.2.44eb (Steam Build 25822788).
- 支持游戏 1.0.2.44eb（Steam Build 25822788）。

- Documentation: added the cover image to the README and removed outdated download instructions.
- 文档：README 加入宣传封面，删除过时的下载说明。

- Documentation: rewrote the player guide in plainer language, focused on what the Mod does and how to use it.
- 文档：用更简洁的语言重写玩家说明，只保留功能介绍和操作方法。

- The Mod is now licensed under the PolyForm Noncommercial License 1.0.0: free to use, share and modify for non-commercial purposes; commercial use is not allowed. Versions released before this stay under MIT.
- 本 Mod 改用 PolyForm Noncommercial 1.0.0 许可：可免费用于非商业用途的使用、分享和修改，不允许商用。此前已发布的版本仍为 MIT 许可。

## 0.5.0 - 2026-09-26

### Compatibility documentation / 兼容性说明 — 2026-10-07

- Supports game 1.0.2.44eb (Steam Build 25759268).
- 支持游戏 1.0.2.44eb（Steam Build 25759268）。

### Documentation update / 文档更新 — 2026-09-26

- Documentation: expanded the guide on controls, behaviour, multiplayer and what happens while a search runs.
- 文档：补充操作方法、功能行为、联机要求以及计算期间的情况。

### English

- First stable release (from 0.5.0-dev).
- Composes the lunch or dinner menu with the highest estimated selection rate. The search runs in the helper file and reuses dish scores within one click. The Auto-compose button stays on one line, and the chosen menu is saved once.
- Adds screenshots of the Auto-compose button and the menu forecast.
- Includes English/Chinese install, usage and update guides and the MIT license. Images are not part of the Mod ZIP.

### 中文

- 首个正式版（由 0.5.0-dev 转正）。
- 为午餐或晚餐组合预计选择率最高的菜单。计算在辅助文件中进行，同一次点击内复用菜品评分。自动组合按钮文字保持单行，选中的菜单只保存一次。
- 附上自动组合按钮和菜单预测的实机截图。
- 附中英文安装、使用、更新说明及 MIT 许可；图片不放进 Mod ZIP。

## 0.5.0-dev

- Documentation: added screenshots of the Auto-compose button and menu forecast, plus an image folder.
- 文档：加入自动组合按钮和菜单预测的实机截图，并新增图片目录。

- The Auto-compose label stays on one line and the button fits its translated text.
- 自动组合按钮文字保持单行，按钮宽度随译文自动调整。

- The Chinese name is now **菜单巧配**.
- 中文名称统一为 **菜单巧配**。

- Documentation: rewrote the install, usage, update and removal guides and fixed links inside the downloaded package.
- 文档：重写安装、使用、更新和卸载说明，修复安装包内的文档链接。

- The download now includes the MIT license.
- 下载包附带 MIT 许可全文。

- New helper file `Scripts/auto_menu_bridge.dll` runs the menu search and reuses each dish's score during one click. Every menu is still rated by the game's full forecast, including empty courses and ties.
- Results are double-checked against a calculation without reused scores. Your original menu is restored before the single save, also when something fails.
- Logs now include search and score-reuse statistics. Updating the DLL requires restarting the game.
- 新增辅助文件 `Scripts/auto_menu_bridge.dll`，负责菜单计算，并在一次点击内复用每道菜的评分。每份菜单仍按游戏完整预测评分，留空类别和同分处理不变。
- 结果会与不复用评分的计算再核对一遍。无论成功还是失败，都会先恢复原菜单，再只保存一次。
- 日志新增计算和评分复用统计。更新 DLL 需要重启游戏。

## 0.4.1-dev

- Each search writes timing details to `UE4SS.log`: number of choices, combinations checked and time spent in each step. Menu choice is unchanged.
- 每次计算在 `UE4SS.log` 中记录耗时：候选数量、已比较的组合数以及各步骤用时。选菜结果不变。

## 0.4.0-dev

- Simpler search: every combination is rated with the game's forecast, then the best menu is applied once.
- Removed the progress and cancel controls.
- Every course can be empty, and so can the whole menu; an empty result is disabled by the game. On a tie, your current menu is kept.
- If a trial fails, the original menu is restored. Host-only use, 14 languages and script reload are kept. With many combinations, the game may pause during the search.
- 改为更直接的计算：用游戏预测逐个评估全部组合，最后一次性应用最好的菜单。
- 移除进度和取消按钮。
- 每类都可以留空，整份菜单也可以为空；全空结果由游戏停用。同分时保留当前菜单。
- 试算出错时恢复原菜单。保留房主限制、14 种语言和脚本重载。组合很多时，计算期间游戏可能停顿。

## 0.3.0-dev

- Only available, enabled and staffed dishes are considered; locked or disabled dishes no longer slip in.
- Dishes that score the same are grouped to shorten the search, while every distinct combination is still checked.
- Uses live stock checks. Logs the number of choices, combinations and search time.
- 只考虑实际可用、已启用且员工条件满足的菜品，锁定或停用的菜品不会再混进来。
- 评分相同的菜品合并计算以缩短时间，仍会检查所有不同的组合。
- 改用实时库存检查。日志记录候选数量、组合数和计算用时。

## 0.2.1-dev

- Fixes searches being cancelled by normal in-game changes such as influence decay and satisfaction updates.
- A reordered list no longer cancels the search; a real cancellation logs what changed.
- Rates are checked again before saving; if your current menu has become better, it is kept.
- 修复影响力自然衰减、满意度更新等正常变化导致计算被误取消的问题。
- 列表顺序变化不再取消计算；真正取消时会记录变化的内容。
- 保存前重新核对选择率；当前菜单变得更好时予以保留。

## 0.2.0-dev

- The game's estimated selection rate is now the only goal, replacing tag-based scoring.
- Compares complete menus, including empty courses, and finishes only after checking all of them or reaching the highest possible rate.
- Searches in steps with progress and cancel. Saves the winner once, keeping the menu's Enabled state and the other service.
- Cancels when the forecast inputs or the page change. Updated all 14 languages.
- 以游戏的预计选择率作为唯一目标，取代按标签打分。
- 比较完整菜单（含留空类别），全部比较完或达到最高可能选择率才结束。
- 分步计算，带进度和取消。最终结果只保存一次，保留菜单启用状态和另一个餐段。
- 预测条件或页面变化时取消。更新全部 14 种语言。
