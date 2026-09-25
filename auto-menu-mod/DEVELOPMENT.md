# Development and validation / 开发与验收

[English](#english) · [中文](#中文)

## English

**0.1.0-dev; in-game acceptance pending.** Auto Menu is a self-contained Lua Mod with no native helper or cross-Mod dependency.

### Implementation

- `game.lua` refreshes the native page, copies its persistent forecast list items and dish-selector options to plain Lua data, and reads the day's temperature/event and saved menu from the bound manager. It uses the displayed main-service forecast, rather than the unfiltered customer distribution. Reflected struct-array return wrappers are not retained.
- `planner.lua` scores each course independently. The expected share of matching profile tags contributes 60%, intention tags 40%; each distribution is normalized. Relevant weather tags add 0.15 each; hot/filling tags subtract 0.15 each in very hot weather. Mild and warm weather add no direct adjustment. The best dish per course maximizes this additive recommendation score. Stock, existing selection and ID break ties. These are original recommendation weights, not extracted engine constants or an adoption percentage.
- `ui.lua` constructs the native button at runtime beside Print menu. Its slot fills the remaining width and its text wraps. Text and tooltip follow the live language.
- `main.lua` polls UI lifecycle every 500 ms and filters native click dispatch by the injected button's exact identity. A click builds a complete plan before one native save. Refreshing, changing tabs, days or language never saves. Authority, world, selected service, day context and current menu are checked before applying. Reading back the saved fields detects native refusal; there are no partial per-course saves or automatic retries.
- `reload.lua` shares only widget identity strings across reloads. Unload stops callbacks without touching engine objects; the next state removes matching buttons on the game thread before adding one. Failed cleanup is retried.

Native saving preserves the active flag. Auto Menu does not enable, disable, print, price or purchase. Empty categories remain empty; the native model supports a nonempty partial menu. Eligibility comes from native selectors. Missing/malformed forecasts fail before saving. Diagnostics use `[AutoMenu]`; player-facing text supports all 14 game cultures.

### Offline validation

From the repository root:

```powershell
uv run --with lupa==2.6 python auto-menu-mod/tests/run.py
python auto-menu-mod/build.py
python tools/check_repository.py
python tools/check_syntax.py
python -m unittest discover -s tools/tests -v
git diff --check
```

Tests cover forecast and event-driven changes, hot/cool weather, normalization, disabled dishes, missing categories, ties, malformed inputs, independent menu periods, one-save behavior, native refusal, changed worlds/authority, unrelated and reentrant clicks, languages and reload cleanup. Fixtures use invented dishes and synthetic engine objects. This verifies original logic, not actual UE4SS bridging, rendering or game acceptance.

`build.py` writes `outputs/auto-menu/AutoMenu-0.1.0-dev.zip` and SHA-256. The fixed allowlist includes six Lua modules, README, DEVELOPMENT, CHANGELOG and the activation marker. Tests, references, tools, game content and loader files are excluded. The Mod is registered in common CI package checks; this development version has no release authorization.

### In-game checklist

1. Check one button beside Print menu at 1920×1080, 2560×1600 and ultrawide, all 14 languages, tooltips and native input behavior.
2. Compose lunch and dinner separately. Check available courses, unchanged enabled state and other service, manual edits and printing.
3. Compare different forecasts, weather and events. Inspect native compatibility and stock; the heuristic need not maximize native adoption.
4. Test missing ingredients, no unlocked dishes, optional courses, rebuilt UI, different saves and host/guest replication.
5. Reload repeatedly with the page open: one working button, no composition on reload, no old callbacks or sustained errors. Mouse click dispatch is implemented; actual keyboard/controller focus and activation remain to be verified.

## 中文

**0.1.0-dev，待游戏内验收。** Auto Menu 为独立 Lua Mod，无原生辅助 DLL 或其他 Mod 依赖。

### 实现

- `game.lua` 刷新原生页面，将其持有的预测列表项、选择器候选转为普通 Lua 数据，读取绑定管理器中的温度、活动及菜单。使用页面显示的正餐预测，不使用未过滤的全部顾客分布；不保留反射调用返回的临时结构数组包装。
- `planner.lua` 分类别评分：顾客类型标签的预期匹配比例占 60%，用餐意向占 40%，两组概率分别归一化。天气对应标签各加 0.15，酷热时热食、饱腹标签各减 0.15；温和及温暖天气不直接调分。逐类别选最高分即可最大化这一可加评分；同分按食材、现有选择、编号排序。这些是原创推荐权重，不是提取的引擎常数，也不是采用率百分比。
- `ui.lua` 在运行时创建原生按钮，放在打印按钮旁，填充剩余宽度并允许换行；标题和提示随语言更新。
- `main.lua` 每 500 毫秒核对界面生命周期，按新增按钮完整身份过滤点击。先生成完整方案，再调用一次原生保存。刷新、切换餐段、日期或语言不会自行保存。保存前复核权限、世界、餐段、当天条件及菜单；保存后读回字段发现原生拒绝，不逐道菜分批保存，也不自动重试。
- `reload.lua` 跨重载仅传递按钮身份字符串。旧状态卸载时停止回调、不访问引擎对象；新状态在游戏线程先移除对应按钮再创建，清理失败则重试。

原生保存保留启用标记；Mod 不代为启停、打印、定价或采购。缺少候选的类别留空，支持原生允许的非空部分菜单。菜品资格来自原生选择器；预测缺失或异常时在保存前停止。日志前缀为 `[AutoMenu]`，按钮及状态文案覆盖游戏 14 种语言。

### 离线验证

在仓库根目录运行英文部分所列命令。测试覆盖顾客及用餐意向、活动引起的预测变化、冷暖天气、归一化、禁用菜品、空类别、稳定排序、异常数据、餐段独立、单次保存、原生拒绝、权限及世界变化、其他按钮、重入点击、语言及热重载清理。

测试使用虚构菜品及引擎替身，只验证原创逻辑，不代表真实 UE4SS 桥接、渲染或实机验收。构建生成 `outputs/auto-menu/AutoMenu-0.1.0-dev.zip` 及 SHA-256。固定白名单含六个 Lua 模块、README、DEVELOPMENT、CHANGELOG 和启用标记，不含测试、参考、工具、游戏内容及加载器。已登记统一 CI 包校验；此开发版没有发布授权。

### 实机待验收

1. 在 1920×1080、2560×1600 和超宽屏检查打印按钮旁只有一个新按钮，验证 14 种语言、提示和原有操作。
2. 分别组合午餐和晚餐，检查菜品、启用状态、另一餐段、手动换菜和打印。
3. 比较不同预测、天气和活动下的结果及原生匹配和库存；原创规则不保证最大化原生采用率。
4. 检查缺料、无解锁菜、可选类别、界面重建、不同存档及联机同步。
5. 页面打开时反复重载，确认只有一个可用按钮、重载不配餐、无旧回调或持续错误。已接入鼠标点击分派；键盘和手柄焦点、激活仍需实机确认。
