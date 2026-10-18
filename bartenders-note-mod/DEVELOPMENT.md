# Bartender's Note development / 调饮手记开发

[English](#english) · [中文](#中文)

## English

Player instructions: [README](README.md#english). **Current source: 0.1.3.**

### Implementation

| Module | Responsibility |
| --- | --- |
| `Scripts/game.lua` | Finds the local HUD and its world, reads the queue into plain Lua data, and resolves native drink names and current language |
| `Scripts/summary.lua` | Filters owner and preparation state, deduplicates order IDs, groups by drink type and preserves a stable order |
| `Scripts/layout.lua` | Fits complete drink entries into at most two measured lines and reserves room for a localized hidden-type count |
| `Scripts/hud.lua` | Creates native UMG widgets, reuses the name bar's appearance and measures text in its current font |
| `Scripts/localization.lua` | Resolves supported cultures and formats original overflow/final-fallback wording |
| `Scripts/main.lua` | Handles events, 750 ms reconciliation, HUD rebuilds and clearing after failures |
| `Scripts/reload.lua` | Stops old callbacks and hands off widget identities as shared strings for cleanup on the next game-thread refresh |

#### Data and threading

- All Unreal object access happens on the game thread.
- The Mod never executes order actions. Each update rebuilds the list from the current queue, so it keeps no save state.
- Finished drinks leave the list immediately, without waiting for delivery.
- The HUD captures no input and leaves the original name bar unchanged.

#### Reload handoff

- `ModRef.OnUnload` may run outside the game thread. It only marks the old lifetime stopped: it touches no UObjects and schedules no callbacks into the state being destroyed. UE4SS removes that state's hooks, timers and object notifications.
- Shared variables hold only full-name/address identity strings for the banner and measurement widget. No transient UObject or callback is shared between states.
- The next state resolves those identities on the game thread and removes matching widgets before creating new ones. Failed cleanup is retried; normal destruction removes the records.

#### Widgets and measurement

- New widgets copy the name bar's anchors, alignment, size and transform.
- Each side reserves 18% of the bar width, at least 56 HUD-scaled layout units; the body container clips text inside the faded ends.
- A hidden text widget on the same canvas measures the native font. It takes part in layout but neither draws nor receives input.
- Available width comes from viewport size and DPI scaling. Measurements are recalculated on every refresh, so language, font and window changes are picked up.
- Measurement caches last one refresh, and unchanged body text is not rewritten.
- Panel height follows the final measured multiline height and shrinks when content returns to one line. Removing the HUD also removes the measurement widget.

#### Layout rules

- Layout keeps the longest complete prefix of the stable drink order.
- A name that is too wide is not truncated: it and every later type go into the overflow count instead. The count is drink types, not quantities.
- If even the localized overflow indicator cannot fit, the panel hides until there is enough width again.

### Localization

- The language is read with `KismetInternationalizationLibrary:GetCurrentLanguage()` during game-thread refreshes.
- Drink names come from `LocaleGameInstanceSubsystem:GetDishTranslation`. If a name is missing, `GetUITranslation('Drinks')` supplies a native category label plus `#ID`; only if both fail is the Mod's own translated generic label used. Missing localization services never discard valid order counts.
- Supported cultures: `en`, `fr`, `zh-Hans`, `it`, `es`, `de`, `ru`, `ja`, `ko`, `zh-Hant`, `tr`, `pl`, `pt` and `pt-BR`. Resolution tolerates case, underscores and regional variants; explicit Chinese scripts take precedence over region aliases, and Brazilian Portuguese stays distinct. Unsupported or unreadable languages fall back to English for Mod-owned wording.
- Language events and periodic reconciliation both reflow the current list.
- The Mod authors only the overflow and final-fallback text. The overflow indicator is measured in the current native font with the same width budget as drink entries. Loader and error diagnostics are English.

Extracted translation catalogs, native text tables and research notes stay in the ignored `work/` folder.

### Offline checks and packaging

From the source repository root:

```powershell
uv run --with lupa==2.6 python bartenders-note-mod/tests/run.py
python bartenders-note-mod/build.py
python tools/check_repository.py
git diff --check
```

The tests run on Lua 5.4 without the game or UE4SS, using substitute engine objects. They cover:

- ownership/state filtering, deduplication and unavailable sources;
- HUD lifecycle, margins, measured wrapping, hidden-type counts, height recovery and reflow after window/font changes;
- the 14 cultures, region aliases, native-name/category/final fallback precedence, missing services and language changes with an unchanged order list;
- reload: stopped delayed callbacks, primitive-only handoff, exact identity cleanup, repeated cleanup and retry after removal errors.

The package contains only the original Lua, README, DEVELOPMENT, CHANGELOG, LICENSE and `enabled.txt`. The build writes `outputs/bartenders-note/BartendersNote-0.1.3.zip` and a SHA-256 file; it includes no loader, tools, tests or game files.

### In-game regression checklist

1. Enter a single-player restaurant. Confirm no list before claiming orders; claim ten of one drink and another type and check totals and one-line layout when space permits.
2. Cancel a claim, cancel an order, start preparation and finish preparation. Preparing drinks still count; finished drinks disappear, and the panel hides after the final drink.
3. Open/close the tablet, pause and fullscreen interfaces, and activities that hide the name bar. Check for stale floating widgets and unchanged input behavior.
4. Return to the menu, load another save and rejoin. Confirm no duplicate widgets or stale player/order data.
5. Switch through all 14 languages with orders present, including both Chinese scripts and both Portuguese cultures. Check native drink names, localized overflow and fallback, fonts and live reflow. Test long names at 1920×1080, 2560×1600 and 3440×1440; check faded margins, two lines, hidden-type count and recovery to one line without shrinking the font.
6. Have host and client claim different orders. Each should see only their own list, with remote cancellation/completion and reconnects updating correctly.
7. Check UE4SS logs and extended play for sustained errors or refresh stalls. Record actual game and full loader versions, language, resolution and results.
8. Reload repeatedly with claimed drinks visible and with a delayed refresh pending. Confirm one banner and one measurement widget, fresh counts, no duplicate hooks or timers, and correct recovery after traveling or changing language.

### Runtime compatibility

- Current version: **0.1.3**, supporting **Steam Build 25822788 / 1.0.2.44eb**.
- **0.1.3 test status:** compared with 0.1.2, 0.1.3 changes only the license (PolyForm Noncommercial 1.0.0), the documentation and the version number; gameplay code is unchanged. In-game testing of 0.1.3 was waived by the maintainer on 2026-10-19 because gameplay code is unchanged.
- Development reference: Windows, Steam Build 25393699 / ProjectVersion 1.0.0.44eb, Unreal Engine 5.4.
- UE4SS: experimental `v3.0.1-1140-gf58e8f84`. `LoopInGameThreadWithDelay` and `ExecuteInGameThreadWithDelay` are required; if either is missing, the Mod stops and writes a `[Bartender's Note]` log entry. Stable UE4SS 3.0.1 is not supported.

### Manual script reload

1. Install or upgrade to 0.1.2 once with the game closed, which clears widgets left by earlier versions.
2. For later Lua-only updates, set up the [shared reload configuration](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/bartenders-note-v0.1.2/docs/hot-reload.md#english), copy every updated script, then press **Ctrl+R**.

A normal update with the game closed needs no reload.

## 中文

玩家说明见 [README](README.md#中文)。**当前源码为 0.1.3。**

### 实现

| 模块 | 职责 |
| --- | --- |
| `Scripts/game.lua` | 定位本地 HUD 与所属世界，将队列转换为普通 Lua 数据，读取原生饮料名和当前语言 |
| `Scripts/summary.lua` | 按认领者和制作状态过滤，以订单 ID 去重、按饮料类型合并并保持稳定顺序 |
| `Scripts/layout.lua` | 按测量宽度排列完整条目，最多两行，为本地化隐藏种类计数预留空间 |
| `Scripts/hud.lua` | 创建原生 UMG 控件，复用名称条外观并以当前字体测量文字 |
| `Scripts/localization.lua` | 解析支持语言，格式化原创溢出提示与最终后备文案 |
| `Scripts/main.lua` | 事件通知、750 毫秒核对、HUD 重建及异常清空 |
| `Scripts/reload.lua` | 停止旧回调，以共享字符串传递控件身份，由新状态在游戏线程清理 |

#### 数据与线程

- 所有 Unreal 对象访问都在游戏线程执行。
- Mod 不操作订单。每次都从当前队列重新生成清单，不保存额外存档状态。
- 饮料做完立即移出清单，不等待送达。
- HUD 不截获输入，不改动原名称条。

#### 重载交接

- `ModRef.OnUnload` 可能不在游戏线程运行，只标记旧生命周期停止：不访问 UObject，也不向将销毁的状态安排回调。UE4SS 负责清理该状态的 Hook、定时器和对象通知。
- 跨重载只保存显示栏和测量控件的完整名称/地址字符串，不共享临时 UObject 或回调。
- 新状态在游戏线程重新解析这些身份，移除对应控件后才创建新控件；清理失败时重试，正常销毁时删除身份记录。

#### 控件与测量

- 新增控件沿用名称条的锚点、对齐、尺寸和变换。
- 左右各预留 18% 栏宽，至少 56 个随 HUD 缩放的布局单位；正文裁剪在渐隐区内侧。
- 同画布上的隐藏文字控件用于测量原生字体，参与布局但不绘制、不接收输入。
- 可用宽度依据视口尺寸和 DPI 缩放计算。每次刷新都重新测量，以响应语言、字体和窗口变化。
- 测量缓存只保留一次刷新，正文未变时不重写文字。
- 面板高度取最终多行文字的实测高度，恢复一行时同步缩回。销毁 HUD 时一并移除测量控件。

#### 布局规则

- 布局保留稳定顺序中能完整显示的最长前缀。
- 单个名称过宽时不截断，而是把它和后续种类都计入溢出数；计数代表饮料种类而非杯数。
- 窗口窄到连本地化溢出提示都放不下时隐藏面板，宽度恢复后重新显示。

### 多语言适配

- 游戏线程刷新时通过 `KismetInternationalizationLibrary:GetCurrentLanguage()` 读取语言。
- 饮料名称来自 `LocaleGameInstanceSubsystem:GetDishTranslation`；某个名称缺失时，用 `GetUITranslation('Drinks')` 的原生分类名称加 `#编号`，两者都失败才使用 Mod 自带的本地化通用标签。翻译服务不可用时不会丢弃有效订单数量。
- 支持 `en`、`fr`、`zh-Hans`、`it`、`es`、`de`、`ru`、`ja`、`ko`、`zh-Hant`、`tr`、`pl`、`pt` 和 `pt-BR`。解析兼容大小写、下划线和地区变体；显式中文书写系统优先于地区别名，巴西葡萄牙语单独处理。语言不支持或无法读取时，Mod 自有文案回退英语。
- 语言事件和定时核对都会重新排版当前清单。
- Mod 只自行翻译溢出提示和最终后备文案。溢出提示用当前原生字体测量，与饮料条目共用宽度。加载器和异常诊断使用英文。

提取的游戏翻译目录、原生文案表和研究笔记放在被忽略的 `work/` 文件夹。

### 离线检查与打包

从源码仓库根目录执行：

```powershell
uv run --with lupa==2.6 python bartenders-note-mod/tests/run.py
python bartenders-note-mod/build.py
python tools/check_repository.py
git diff --check
```

测试在 Lua 5.4 上运行，使用替代引擎对象，不需要游戏或 UE4SS。覆盖：

- 认领者与状态过滤、去重、数据源不可用；
- HUD 生命周期、留白、实测换行、隐藏种类计数、面板高度恢复，以及窗口和字体变化后的重排；
- 14 种语言、地区别名、原生名称/分类/最终后备的优先级、服务缺失，以及订单不变时切换语言；
- 重载：延迟回调停止、仅传递基本类型、身份精确清理、重复清理及移除出错后的重试。

安装包只包含原创 Lua、README、DEVELOPMENT、CHANGELOG、LICENSE 和 `enabled.txt`。构建生成 `outputs/bartenders-note/BartendersNote-0.1.3.zip` 及 SHA-256 文件，不含加载器、工具、测试或游戏文件。

### 实机回归清单

1. 单人进入餐厅，未认领时不显示；认领同类 10 杯和另一种饮料，检查计数与宽度足够时的单行布局。
2. 取消认领、取消订单、开始制作、完成制作，检查数量；制作中仍计入，做完后移除，最后一杯完成后隐藏。
3. 开关平板、暂停和全屏界面，以及会隐藏名称条的操作，检查悬浮残留和输入行为。
4. 返回菜单、加载另一存档并重新加入，检查重复控件、旧订单和旧玩家数据。
5. 有订单时切换全部 14 种语言，包含简繁中文和两种葡萄牙语，检查原生名称、本地化提示与后备值、字体及即时重排。在 1920×1080、2560×1600 和 3440×1440 下测试长名称，检查渐隐留白、两行布局、隐藏种类计数及不缩小字体的单行恢复。
6. 房主与客户端分别认领订单，确认各自只显示自己的清单，远端取消、制作完成及重连能正确更新。
7. 检查 UE4SS 日志与长时间运行，确认无持续异常或刷新卡顿，记录实际游戏和加载器完整版本、语言、分辨率与结果。
8. 显示认领饮料时、以及有延迟刷新待执行时反复重载，确认只有一个显示栏和一个测量控件、数量为最新、Hook 和定时器不重复，切换场景或语言后能正确恢复。

### 运行兼容性

- 当前版本：**0.1.3**，支持至 **Steam Build 25822788 / 1.0.2.44eb**。
- **0.1.3 测试状态：**与 0.1.2 相比，0.1.3 只更改许可（PolyForm Noncommercial 1.0.0）、文档和版本号，玩法代码不变。维护者于 2026-10-19 以玩法代码未改为由免除 0.1.3 的实机测试。
- 开发参考：Windows、Steam Build 25393699 / ProjectVersion 1.0.0.44eb、Unreal Engine 5.4。
- UE4SS：experimental `v3.0.1-1140-gf58e8f84`。需要 `LoopInGameThreadWithDelay` 和 `ExecuteInGameThreadWithDelay`；缺少任一接口时停止 Mod 并记录 `[Bartender's Note]` 日志。不支持旧稳定版 UE4SS 3.0.1。

### 手动脚本重载

1. 首次安装或升级到 0.1.2 时先关闭游戏，以清除旧版本遗留的控件。
2. 之后只更新 Lua 文件时，按[统一重载配置](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/bartenders-note-v0.1.2/docs/hot-reload.md#中文)设置加载器，复制所有更新的脚本，再按 **Ctrl+R**。

关闭游戏后正常更新不需要重载。
