# Changelog / 变更记录

## Unreleased

- Store the maintainer-provided gameplay GIF in assets using Git LFS, preserving the original file.
- 将维护者提供的实机 GIF 通过 Git LFS 存入 assets，保留原文件。

- Add an assets directory for in-game test screenshots and promotional artwork, with README links and embedding examples.
- 新增 assets 目录存放实机测试图与宣传图，并提供 README 入口和图片引用示例。

- Adopt **调饮手记** as the Chinese display name in player guides and shared documentation.
- 中文名称统一为 **调饮手记**，同步玩家说明及公共文档。

- Rewrite player installation, usage, update and removal guides; move implementation and reload details into developer documentation and repair links used from extracted packages.
- 重写面向玩家的安装、使用、更新及卸载说明，将实现与重载细节移入开发文档，并修复解压后使用的文档链接。

- Include the MIT license in source and installable packages, with packaging checks for missing or changed license text.
- 为源码及安装包附上 MIT 许可全文，增加许可缺失或内容改变时的打包校验。

- Add safe Lua reload lifecycle handling in 0.1.2-dev. Stop old callbacks and let the new state remove its previous banner and measurement widget on the game thread, using shared identity strings only. Reload behavior is pending in-game acceptance.
- 0.1.2-dev 新增 Lua 重载生命周期：停止旧回调，新状态在游戏线程清理旧显示栏和测量控件；跨状态仅传递身份字符串。热重载仍待实机验收。

## 0.1.1-dev

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
