# Changelog / 变更记录

## Unreleased

- Supports game 1.0.2.44eb (Steam Build 25822788).
- 支持游戏 1.0.2.44eb（Steam Build 25822788）。

- Documentation: added the cover image to the README and removed outdated download instructions.
- 文档：README 加入宣传封面，删除过时的下载说明。

- Documentation: rewrote the player guide in plainer language, focused on what the Mod does and how to use it.
- 文档：用更简洁的语言重写玩家说明，只保留功能介绍和操作方法。

- The Mod is now licensed under the PolyForm Noncommercial License 1.0.0: free to use, share and modify for non-commercial purposes; commercial use is not allowed. Versions released before this stay under MIT.
- 本 Mod 改用 PolyForm Noncommercial 1.0.0 许可：可免费用于非商业用途的使用、分享和修改，不允许商用。此前已发布的版本仍为 MIT 许可。

## 0.1.2 - 2026-09-26

### English

- Supports game 1.0.2.44eb (Steam Build 25759268).
- First stable 0.1.2 release, with the same gameplay as 0.1.2-dev.
- Shows your claimed, unfinished drinks below the restaurant name in the game language, wrapping onto a second line and fading at the edges.
- Scripts can be reloaded in game without leaving duplicate notes.
- Documentation: expanded English/Chinese install, usage and update guides, and added a gameplay GIF.

### 中文

- 支持游戏 1.0.2.44eb（Steam Build 25759268）。
- 0.1.2 正式版，玩法与 0.1.2-dev 相同。
- 在餐厅名称下方按游戏语言显示自己认领但未做完的饮料，可换到第二行，两端淡出。
- 游戏内重新加载脚本后不会留下重复的手记。
- 文档：补全中英文安装、使用和更新说明，加入实机动图。

## 0.1.2-dev

- Scripts can be reloaded in game: the old note is removed before the new one appears.
- 支持游戏内重新加载脚本：先移除旧手记，再显示新手记。

- Chinese name is now **调饮手记**.
- 中文名称统一为 **调饮手记**。

- The MIT license is included in the download.
- 下载包附带 MIT 许可证。

- Documentation: rewrote install, usage, update and removal guides; added an images folder, a gameplay GIF and fixed links inside the download.
- 文档：重写安装、使用、更新和卸载说明；新增图片目录和实机动图，修复下载包内的文档链接。

## 0.1.1-dev

### English

- Follows all 14 game languages, using the game's own drink names. Changing language re-arranges the note and keeps the counts.
- Wider text margins at both ends of the bar, so text stays clear of the faded edges.
- Fits complete drink entries onto at most two lines without shrinking the font. Extra types show as `... + N more`, counting hidden drink types.
- Re-arranges after window, language or font changes, and returns to one line when fewer drink types remain.

### 中文

- 跟随游戏全部 14 种语言，使用游戏自带的饮料名。切换语言后自动重新排版，数量保持不变。
- 加大显示栏两端的文字留白，避开背景淡出区域。
- 完整饮料条目最多排成两行，不缩小字号；放不下的显示为“另有 N 种”，按隐藏种类计数。
- 窗口大小、语言或字体变化后重新排版；种类减少时恢复为一行。

## 0.1.0 - 2026-09-24

### English

- First release: shows the drinks you have claimed but not yet made, grouped by type, below the restaurant name.
- Matches the game's own background and font, follows the game language, hides when the list is empty and fits long lists on one line.
- The note refreshes when orders change and stays in sync with the order queue.
- Download includes the Mod files and a SHA-256 checksum file.

### 中文

- 首个版本：在餐厅名称下方按种类汇总自己认领但还没做的饮料。
- 沿用游戏原有的背景和字体，跟随游戏语言，清单为空时隐藏，长清单缩放到一行。
- 订单变化时自动刷新，并与订单队列保持一致。
- 下载包包含 Mod 文件和 SHA-256 校验文件。
