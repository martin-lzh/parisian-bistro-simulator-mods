# Bartender's Note development / 调饮手记开发

[English](#english) · [中文](#中文)

## English

Player instructions: [README](README.md#english). **Current source: 0.1.2-dev.** The user reported completion of in-game testing on 2026-09-26; see the [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/releases/validation.md#english) for its scope. Individual checklist results were not reported separately. Version 0.1.0's earlier user confirmation is recorded below.

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

All Unreal object access happens on the game thread. The Mod does not execute order actions. Each update builds from the current queue, so no additional save state is needed. Finished drinks leave the list immediately, without waiting for delivery. The HUD does not capture input or change the original name bar.

`ModRef.OnUnload` may run outside the game thread. It only marks the old lifetime stopped: it does not touch UObjects or schedule callbacks into the state being destroyed. UE4SS removes that state's hooks, timers and object notifications. Shared variables contain only full-name/address identity strings for the banner and measurement widget. The next state resolves those identities on the game thread and removes matching widgets before creating new ones. Failed cleanup is retried; normal destruction removes its records. No transient UObject or callback is shared between states.

The new widgets use the name bar's actual anchors, alignment, size and transform. Each side reserves 18% of the bar width, with a minimum of 56 HUD-scaled layout units; the body container clips text inside the faded ends. A hidden text widget on the same canvas measures the native font. It participates in layout without drawing or receiving input. Available width comes from viewport dimensions and DPI scaling, and measurements are recalculated on refresh to reflect language, font and window changes.

Measurement caches last one refresh. Unchanged body text is not rewritten. Panel height follows the final measured multiline height and shrinks when the content returns to one line. Removing the HUD also removes its measurement widget.

Layout retains the longest complete prefix of the stable drink order. If a single name is too wide, it and subsequent types are counted in the overflow indicator instead of truncating the name. The count is drink types, not quantities. If even the localized indicator cannot fit, the panel hides until sufficient width returns.

### Localization

The language is read through `KismetInternationalizationLibrary:GetCurrentLanguage()` during game-thread refreshes. Native names come from `LocaleGameInstanceSubsystem:GetDishTranslation`. If an individual name is missing, `GetUITranslation('Drinks')` supplies a native category label plus `#ID`; only if both fail does the original translated generic label apply. Missing localization services do not discard valid order counts.

The 14 supported cultures are `en`, `fr`, `zh-Hans`, `it`, `es`, `de`, `ru`, `ja`, `ko`, `zh-Hant`, `tr`, `pl`, `pt` and `pt-BR`. Resolution tolerates case, underscores and regional variants; explicit Chinese scripts take precedence over region aliases, and Brazilian Portuguese stays distinct. Unsupported or unreadable languages fall back to English for Mod-owned wording. Language events and periodic reconciliation both reflow the current list.

Only overflow and final-fallback text is authored by the Mod. The overflow indicator is measured in the current native font with the same width budget as drink entries. Technical loader/error diagnostics remain English. Do not commit extracted translation catalogs or native game text tables; all references and research notes stay under ignored `work/`.

### Offline checks and packaging

From the source repository root:

```powershell
uv run --with lupa==2.6 python bartenders-note-mod/tests/run.py
python bartenders-note-mod/build.py
python tools/check_repository.py
git diff --check
```

The tests execute Lua 5.4 without the game or UE4SS. They cover ownership/state filtering, deduplication, unavailable sources, HUD lifecycle, margins, measured wrapping, hidden-type counts, height recovery and reflow when the window/font changes. Localization coverage checks the 14 cultures, region aliases, native-name/category/final fallback precedence, missing services and language changes while the order list stays the same.

The fixed package allowlist includes original Lua, README, DEVELOPMENT, CHANGELOG, LICENSE and `enabled.txt`. The output is `outputs/bartenders-note/BartendersNote-0.1.2-dev.zip` with a SHA-256 file. It contains no loader, tools, tests or game files and writes nothing to the game installation. Substitute engine objects verify Mod logic, not real UE4SS bridging or rendering. Reload tests cover stopped delayed callbacks, primitive-only handoff, exact identity cleanup, repeated cleanup and retry after removal errors.

### In-game validation

On 2026-09-24, the user confirmed 0.1.0-dev worked in-game and requested the 0.1.0 release, retaining the same runtime logic. The feedback did not enumerate full game/loader versions, resolution, multiplayer role or test duration. It does not cover the 0.1.1-dev layout or localization changes.

The following remains a regression checklist, not a list of completed tests:

1. Enter a single-player restaurant. Confirm no list before claiming orders; claim ten of one drink and another type and check totals and one-line layout when space permits.
2. Cancel a claim, cancel an order, start preparation and finish preparation. Preparing drinks still count; finished drinks disappear, and the panel hides after the final drink.
3. Open/close the tablet, pause and fullscreen interfaces, and activities that hide the name bar. Check for stale floating widgets and unchanged input behavior.
4. Return to the menu, load another save and rejoin. Confirm no duplicate widgets or stale player/order data.
5. Switch through all 14 languages with orders present, including both Chinese scripts and both Portuguese cultures. Check native drink names, localized overflow and fallback, fonts and live reflow. Test long names at 1920×1080, 2560×1600 and 3440×1440; check faded margins, two lines, hidden-type count and recovery to one line without shrinking the font.
6. Have host and client claim different orders. Each should see only their own list, with remote cancellation/completion and reconnects updating correctly.
7. Check UE4SS logs and extended play for sustained errors or refresh stalls. Record actual game and full loader versions, language, resolution and results.
8. Reload repeatedly with claimed drinks visible and with a delayed refresh pending. Confirm one banner and one measurement widget, fresh counts, no duplicate hooks or timers, and correct recovery after traveling or changing language.

### Runtime compatibility

The local reference baseline is Windows, Steam Build 25393699 / ProjectVersion 1.0.0.44eb, Unreal Engine 5.4. The checked UE4SS experimental API is `v3.0.1-1140-gf58e8f84`; `LoopInGameThreadWithDelay` and `ExecuteInGameThreadWithDelay` are required. Missing required APIs stop the Mod and produce a `[Bartender's Note]` log entry. Old stable UE4SS 3.0.1 is not the target.

### Manual script reload

Install or upgrade to 0.1.2-dev with the game closed once, clearing widgets left by earlier runtimes. For subsequent Lua-only updates, follow the [shared reload configuration](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/docs/hot-reload.md#english), copy every updated script, then press **Ctrl+R**. No reload is needed for a normal closed-game update.

The implementation and handoff are described above; the 2026-09-26 overall report does not provide a separate result for repeated reload, host/client isolation or live language changes.

## 中文

玩家说明见 [README](README.md#中文)。**当前源码为 0.1.2-dev。** 用户于 2026-09-26 反馈实机测试完成，范围见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/releases/validation.md#中文)；未单独反馈清单各项结果。0.1.0 的历史用户确认见下文。

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

所有 Unreal 对象访问在游戏线程执行，不操作订单。每次从当前队列生成清单，无需维护额外存档状态；完成制作立即移出清单，不等待送达。HUD 不截获输入，不改变原名称条。

`ModRef.OnUnload` 可能不在游戏线程，仅标记旧生命周期停止，不访问 UObject，也不向将销毁的状态安排回调。UE4SS 清理该状态的 Hook、定时器及对象通知。跨重载仅保存显示栏和测量控件的完整名称/地址字符串；新状态在游戏线程重新解析并移除对应控件后才创建新控件，失败时重试。正常销毁时删除身份记录，不共享临时 UObject 或回调。离线测试覆盖旧回调停止、身份匹配、重复清理及错误恢复；实机仍需连续重载、切换餐厅和语言验证。

新增控件依据名称条实际锚点、对齐、尺寸和变换定位。左右各预留 18% 栏宽、至少 56 个随 HUD 缩放的布局单位，正文裁剪在渐隐区内侧。同画布上的隐藏文字控件参与布局测量原生字体，但不绘制、不接收输入。可用宽度依据视口尺寸和 DPI 缩放计算，每次刷新重新测量，响应语言、字体和窗口变化。

测量缓存只保留一次刷新，正文未变时不重写文字。面板高度根据最终多行文字的实测高度决定，恢复一行时同步缩回。销毁 HUD 时同时移除测量控件。

布局保留稳定顺序中能完整显示的最长前缀。单个名称过宽时，将该种类及后续种类纳入溢出计数，不截断名称；计数代表饮料种类而非杯数。极窄窗口连本地化提示也容纳不下时隐藏面板，宽度恢复后重新显示。

### 多语言适配

游戏线程刷新时通过 `KismetInternationalizationLibrary:GetCurrentLanguage()` 读取语言。饮料名称来自 `LocaleGameInstanceSubsystem:GetDishTranslation`；某个名称缺失时，先用 `GetUITranslation('Drinks')` 的原生分类名称加 `#编号`，两者均失败才使用原创本地化通用标签。翻译服务不可用不会丢弃有效订单数量。

覆盖 `en`、`fr`、`zh-Hans`、`it`、`es`、`de`、`ru`、`ja`、`ko`、`zh-Hant`、`tr`、`pl`、`pt` 和 `pt-BR`。解析兼容大小写、下划线和地区变体；显式中文书写系统优先于地区别名，巴西葡萄牙语独立处理。语言不支持或不可读时，自有文案回退英语。语言事件与定时核对都会重新排版当前清单。

Mod 仅自行翻译溢出提示与最终后备文案。溢出提示使用当前原生字体测量，与饮料条目共用可用宽度。加载器及异常等技术诊断保留英文。不提交提取的游戏翻译目录或原生文案表，参考与研究笔记始终放在被忽略的 `work/`。

### 离线检查与打包

从源码仓库根目录执行：

```powershell
uv run --with lupa==2.6 python bartenders-note-mod/tests/run.py
python bartenders-note-mod/build.py
python tools/check_repository.py
git diff --check
```

测试使用 Lua 5.4，无需游戏或 UE4SS。覆盖认领者与状态过滤、去重、数据源不可用、HUD 生命周期、留白、实测换行、隐藏种类计数、面板高度恢复及窗口和字体变化后的重排。多语言检查覆盖 14 种语言、地区别名、原生名称/分类/最终后备优先级、服务缺失和订单不变时切换语言。

固定白名单包含原创 Lua、README、DEVELOPMENT、CHANGELOG、LICENSE 与 `enabled.txt`。生成 `outputs/bartenders-note/BartendersNote-0.1.2-dev.zip` 及 SHA-256 文件，不含加载器、工具、测试或游戏内容，也不写入游戏目录。替代引擎对象只能验证 Mod 逻辑，不能证明真实 UE4SS 桥接或渲染正常。

### 游戏内验收

2026-09-24 用户确认 0.1.0-dev 实机成功，并要求转为 0.1.0 正式版，运行逻辑不变。反馈未逐项提供完整游戏与加载器版本、分辨率、联机角色或测试时长；不覆盖 0.1.1-dev 的布局和多语言改动。

以下仍是回归清单，不代表已逐项完成：

1. 单人进入餐厅，未认领时不显示；认领同类 10 杯和另一种饮料，检查计数与宽度足够时的单行布局。
2. 取消认领、取消订单、开始制作、完成制作，检查数量；制作中仍计入，做完后移除，最后一杯完成后隐藏。
3. 开关平板、暂停和全屏界面，以及会隐藏名称条的操作，检查悬浮残留和输入行为。
4. 返回菜单、加载另一存档并重新加入，检查重复控件、旧订单和旧玩家数据。
5. 有订单时切换全部 14 种语言，包含简繁中文和两种葡萄牙语，检查原生名称、本地化提示与后备值、字体及即时重排。在 1920×1080、2560×1600 和 3440×1440 下测试长名称，检查渐隐留白、两行布局、隐藏种类计数及不缩小字体的单行恢复。
6. 房主与客户端分别认领订单，确认各自只显示自己的清单，远端取消、制作完成及重连能正确更新。
7. 检查 UE4SS 日志与长时间运行，确认无持续异常或刷新卡顿，记录实际游戏和加载器完整版本、语言、分辨率与结果。

### 运行兼容性

本机参考基线为 Windows、Steam Build 25393699 / ProjectVersion 1.0.0.44eb、Unreal Engine 5.4。已核对的 UE4SS experimental API 为 `v3.0.1-1140-gf58e8f84`，需要 `LoopInGameThreadWithDelay` 和 `ExecuteInGameThreadWithDelay`。缺少必需接口时停止 Mod，并记录 `[Bartender's Note]` 日志；不以旧稳定版 UE4SS 3.0.1 为目标。

### 手动脚本重载

首次安装或升级至 0.1.2-dev 时先关闭游戏，以清除旧版本遗留控件。之后仅更新 Lua 文件时，按[统一重载配置](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/docs/hot-reload.md#中文)设置加载器，复制完所有更新脚本，再按 **Ctrl+R**。正常关游戏更新不需要热重载。

实现与交接见上文；2026-09-26 总体测试反馈未单独提供连续重载、房主/客机隔离或运行中切换语言的结果。
