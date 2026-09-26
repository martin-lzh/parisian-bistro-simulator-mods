# Changelog

## Unreleased

- Add the Nexus promotional cover to the bilingual README and remove obsolete private-repository download instructions. Runtime files and the Mod version are unchanged.
- 在中英 README 中加入 Nexus 宣传封面，移除私密仓库下载限制的旧说明；运行文件与 Mod 版本保持不变。

## 0.1.5 - 2026-09-26

### Documentation update / 文档更新 — 2026-09-26

- Expand the English/Chinese player guide after a source-based subagent audit of in-game controls, feature behavior, multiplayer requirements and waiting/recovery conditions. Refresh the existing Release package documentation; the version and runtime files are unchanged.
- 经 subagent 对照源码审计，补全中英文游戏内操作、功能行为、联机要求及等待／恢复条件。更新现有 Release 包内文档，版本与运行文件保持不变。

### English

- Promote 0.1.5-dev to 0.1.5 after the maintainer confirmed that all current Mods passed in-game and multiplayer testing and explicitly authorized stable publication on 2026-09-26. Retain the tested gameplay logic; update version identifiers, package names and release documentation.
- Choose free, budget or premium automatic-order delivery, with saved preferences, native discovery checks, language fallback and Lua reload support. Use dark selector surfaces, white text and green selection/focus styling.
- Include smart-order settings and delivery-selector gameplay screenshots.
- Include English/Chinese installation, usage and update guides, the MIT license, and verified package contents. Documentation images remain outside the installable ZIP.

### 中文

- 维护者于 2026-09-26 确认全部当前 Mod 实机及联机测试通过，并明确授权发布正式版，据此将 0.1.5-dev 转为 0.1.5；保留已测试的玩法逻辑，更新版本标识、包名和发布说明。
- 为自动智能订购选择免费、经济或高级配送，支持偏好保存、原生定位检查、语言回退及 Lua 重载；选择框采用深色底、白色文字与绿色选中及焦点样式。
- 附上智能订购设置及配送选择框实机截图。
- 附上中英文安装、使用、更新说明及 MIT 许可，并校验包内容；文档图片不进入安装 ZIP。

## 0.1.5-dev

- Add maintainer-provided screenshots of the smart-order settings and expanded delivery selector to both README languages, with image provenance and scene notes.
- 将维护者提供的智能订购设置与展开配送选项实机图加入中英文 README，并记录图片来源及可见场景。

- Add an assets directory for in-game test screenshots and promotional artwork, with README links and embedding examples.
- 新增 assets 目录存放实机测试图与宣传图，并提供 README 入口和图片引用示例。

- Restyle the delivery selector in 0.1.5-dev with charcoal backgrounds, soft white text and muted green selection. Set popup row text colors separately; style hover, pressed, disabled and keyboard-focus states without the default blue highlight. Only Lua changes; in-game visual verification is pending.
- 0.1.5-dev 调整配送选择框配色：炭灰底色、柔白文字、低饱和绿色选中项；单独设置展开列表文字颜色，统一悬停、按下、禁用及键盘焦点状态，去除默认亮蓝高亮。本次仅修改 Lua，待实机确认显示效果。

## 0.1.4-dev

- Adopt **配送随心** as the Chinese display name in player guides and shared documentation.
- 中文名称统一为 **配送随心**，同步玩家说明及公共文档。

- Rewrite player installation, usage, update and removal guides; move implementation and reload details into developer documentation and repair links used from extracted packages.
- 重写面向玩家的安装、使用、更新及卸载说明，将实现与重载细节移入开发文档，并修复解压后使用的文档链接。

- Include the MIT license in source and installable packages, with packaging checks for missing or changed license text.
- 为源码及安装包附上 MIT 许可全文，增加许可缺失或内容改变时的打包校验。

- Fall back to English when language lookup fails without stopping delivery selection or losing an unsaved choice. Resume localized text when reading recovers; add UI and runtime regressions. This change has not been tested in-game.
- 语言读取失败时回退英语，不停止配送选择，也不丢失未保存选项；读取恢复后重新显示本地化文案，增加界面与主流程回归测试。本次改动尚未实机测试。

- Add Lua reload support in 0.1.4-dev: stop old callbacks, remove old selector rows on the next game-thread startup, and restore the saved preference. The native helper atomically suspends custom delivery during unload and reuses its pinned patch after checking for conflicts. A DLL update still requires a game restart. In-game acceptance is pending.
- 0.1.4-dev 新增 Lua 热重载：停止旧回调，新状态在游戏线程清理旧选择框并恢复保存偏好；原生辅助模块在卸载回调中原子暂停自定义配送，重新初始化时检查冲突并复用驻留补丁。更新 DLL 仍需重启游戏，热重载待实机验收。

## 0.1.3-dev

- Update to 0.1.3-dev: use white text for the delivery dropdown's selected value and options instead of inheriting the amount input's foreground color.
- 更新至 0.1.3-dev：配送下拉框当前选项和展开列表使用白色文字，不再继承金额输入框的前景色。

## 0.1.2-dev

- Remove mandatory game-version, executable-size and SHA-256 allowlists. Discover the automatic delivery branch and fee data through native registration names and instruction operands instead of fixed addresses.
- Check native discovery against Steam Build 25532071. Preserve code-conflict checks and the original quantity threshold when disabled. Add relocated-image, ambiguous-target, changed-structure and conflict regression tests. Package version: 0.1.2-dev; in-game testing is pending.

- 取消游戏版本、可执行文件大小及 SHA-256 白名单限制，通过原生注册名称与指令操作数定位自动配送分支和费用数据，不再使用固定地址。
- 已在 Steam Build 25532071 文件上核对定位结果；保留代码冲突检查，停用偏好时沿用原生数量阈值。新增地址移动、目标重复、结构变化及冲突回归测试。安装包版本为 0.1.2-dev，待实机测试。

## 0.1.1-dev

- Fix the 0.1.0-dev `Invalid compatibility range` startup failure by validating zero-filled runtime data against mapped PE sections. Keep full executable hashing and evaluator code checks.
- Add PE range regression tests and a UI attachment diagnostic. Updating the native helper requires a game restart. Package version: 0.1.1-dev; in-game retesting is pending.

- 修复 0.1.0-dev 的 `Invalid compatibility range` 启动失败，改为按 PE 映射节区核验零填充运行时数据，保留完整可执行文件哈希及执行代码校验。
- 新增 PE 范围回归测试及界面注入日志。更新辅助模块需重启游戏。安装包版本为 0.1.1-dev，待实机复测。

## 0.1.0-dev

- Add Free service, Budget delivery and Premium delivery to automatic smart-order settings, with native Save/Cancel behavior and a persistent installation-wide preference.
- Keep native order eligibility, costs, night fees and staffing, while leaving manual orders independent.
- Reuse translated game delivery names and localize the new field label for all 14 game languages.
- Add a Windows helper restricted to the verified game build, native dispatch tests, Lua tests and package verification. In-game acceptance is pending.

- 在自动智能订购设置中增加免费服务、经济型配送和高级配送，支持保存/取消及跨重启保留偏好。
- 保留原生采购条件、扣款、夜间附加费和配送人数，手动订单保持独立。
- 沿用游戏配送名称翻译，新增字段标题覆盖 14 种语言。
- 加入限定游戏构建的 Windows 辅助模块、原生分派测试、Lua 测试和安装包校验，待实机验收。
