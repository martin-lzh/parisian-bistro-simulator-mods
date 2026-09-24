# Changelog / 变更记录

## Unreleased

### English

- Follow all 14 game languages. Prefer native drink names and the native drinks category; translate only the overflow marker and final numbered fallback. Language changes reflow the HUD, and unavailable translations preserve quantities.
- 0.1.1-dev: increase the text margins at both ends of the banner, scaling with its width to avoid the background's fading edges.
- Arrange complete drink entries across at most two lines using the current font's measured width, preserving the font size. Show overflow as `... + N more`, counting hidden drink types.
- Reflow after window, language or font changes; return the panel to one line when fewer drink types remain.

### 中文

- 跟随游戏的全部 14 种语言；饮料名和缺失名称时的饮料类别优先读取原生翻译，仅为溢出提示和最终数字名称兜底编写翻译。切换语言后自动重新排版，翻译暂不可用时保留数量。
- 0.1.1-dev：加大显示栏两端的文字留白，随栏宽缩放并避开背景渐隐区。
- 根据当前字体的实际宽度按完整饮料条目排列最多两行，保持字号；超出部分显示 `... + N more`，按隐藏种类计数。
- 窗口大小、语言和字体变化后重新排版；种类减少时面板恢复一行。

## 0.1.0 - 2026-09-24

### English

- Add Bartender's Note to summarize the local player's claimed, unfinished drinks by type below the restaurant name.
- Use the native runtime background and font, follow the game language, hide empty lists and scale long lists onto one line.
- Add event-driven refreshes, queue reconciliation, HUD lifecycle handling and offline tests.
- Promote the development package to a stable release after the user confirmed successful in-game testing; retain the tested runtime logic.
- Provide a ZIP containing only original Mod files and a SHA-256 checksum file.

### 中文

- 新增 Bartender's Note：在餐厅名称下方按类型汇总本地玩家认领的待做饮料。
- 使用原生运行时背景与字体，支持游戏语言、空清单隐藏和长清单单行缩放。
- 加入事件刷新、队列核对、HUD 生命周期处理与离线测试。
- 用户确认开发包实机测试成功，转为正式版；运行逻辑保持已测试版本。
- 提供仅包含原创 Mod 文件的 ZIP 和 SHA-256 校验文件。
