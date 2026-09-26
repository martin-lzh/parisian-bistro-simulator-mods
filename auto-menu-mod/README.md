# Auto Menu / 每日菜单组合

[English](#english) · [中文](#中文)

## English

Adds an **Auto-compose** button beside **Print menu** in the computer's daily-menu page. This is an independent Mod; no other Mod is required.

**Current source: 0.3.0-dev. In-game acceptance is pending.** The local interface reference is Steam Build 25532071 / ProjectVersion 1.0.1.44eb, Unreal Engine 5.4. Requires UE4SS experimental; the checked API is `v3.0.1-1140-gf58e8f84`.

### Use

1. As host, open the computer's daily-menu page and select lunch or dinner.
2. Click **Auto-compose**. The Mod searches complete menu combinations to maximize the game's native **estimated selection rate** for that service. The button shows progress; click it again to cancel.
3. Review the result and its native forecast. You can edit individual dishes, enable/disable the menu or print it with the normal controls.

Every representative candidate is evaluated by the same native prediction used on the daily-menu page. A search uses the influence and satisfaction sampled when you click, so ordinary time passage or customer feedback does not cancel it. Before saving, both the winner and your existing menu are evaluated with current native values; if the existing menu is better, it is retained. Customer preferences, weather, events, prices and other factors follow the game's calculation. The Mod compares the unrounded rate, without its own tag weights or a profit objective. It first removes unavailable, disabled and unstaffed dishes, then merges choices with identical native selection-rate inputs. It searches every remaining representative combination, including optional empty courses, unless a candidate reaches the native rate ceiling first. The result is the same global maximum over eligible dishes for the sampled conditions on the checked game version. A wholly empty menu is excluded; the result can be a partial menu.

Only a completed search saves the selected service, once. The other service and the enabled state are preserved. Trial menus are never saved; the original menu and live simulation properties are restored before each synchronous search batch returns. A tied existing menu is retained; otherwise ties follow a stable search order, with stocked options first. Stock does not override a higher native rate. This Mod does not order stock, change prices or print automatically.

Equivalent choices can greatly reduce work. Distinct choices still have exponential worst-case cost; the Mod does not claim that a greedy result is globally optimal. A short warm start can finish early only if it reaches the native ceiling. Work is split across game-thread ticks, with a progress display and cancellation. Closing the page, switching services, editing the menu, or actual changes to forecast, prices, ingredient availability or eligibility cancel the search without applying it. Reordering identical native lists does not cancel it. Cancellation logs name the changed input. Missing forecasts or no eligible dishes leave the menu unchanged.

The button follows the game's 14 languages and is available only to the local host. There is no automatic daily run or separate Mod save file. Changes use the game's normal daily-menu save behavior.

### Install and update

1. Close the game and install UE4SS experimental using its own installation instructions.
2. Put the ZIP's `AutoMenu` folder in the loader's `Mods` directory. It must contain `Scripts/main.lua` and `enabled.txt`.
3. Start the game and open a restaurant as host.

The ZIP contains original Mod scripts and documentation only. Builds do not install it or start/stop the game. After the initial installation, Lua updates support **Ctrl+R** with `EnableHotReloadSystem=1` in UE4SS settings. Reload removes the old button before creating a replacement. Removal and loader changes require closing the game.

If composition fails, check the `[AutoMenu]` log and provide the game/loader versions, language and host/client role. Native rejection is reported without repeatedly submitting the menu. Inspect the game's forecast for resulting compatibility and stock.

[Development and validation](DEVELOPMENT.md#english) · [Changes](CHANGELOG.md)

## 中文

在电脑的每日菜单页面、“打印菜单”旁新增 **自动组合** 按钮。这是独立 Mod，不依赖本仓库其他 Mod。

**当前源码：0.3.0-dev，待游戏内验收。** 本机接口参考为 Steam Build 25532071 / ProjectVersion 1.0.1.44eb、Unreal Engine 5.4。需要 UE4SS experimental，核对的 API 为 `v3.0.1-1140-gf58e8f84`。

### 使用

1. 房主打开电脑的每日菜单页面，选择午餐或晚餐。
2. 点击 **自动组合**，搜索让当前餐段原生 **预计选择率最大化** 的菜单组合。按钮显示搜索进度，再次点击可取消。
3. 查看结果及游戏原生预测；可以继续逐项换菜，使用原有按钮启用、停用或打印菜单。

每个代表候选都调用每日菜单页面使用的原生预测。一轮搜索统一采用点击时的推广影响力和满意度，正常时间流逝或顾客反馈不会取消搜索。保存前用当前原生数值复核候选与现有菜单；如果现有菜单更好，就保留现有菜单。顾客喜好、天气、活动、价格及其他因素完全沿用游戏计算，直接比较未取整的选择率，不再使用自定义标签权重，也不以利润为目标。先排除实际不可用、停用或不满足员工条件的菜品，再合并原生选择率输入等价的候选。覆盖剩余全部代表组合，包括原生允许的类别留空；达到原生选择率上限时提前结束。在已核对游戏版本及采样条件下，保持可用菜品范围内相同的全局最高选择率。排除全空菜单，最终结果可能是部分菜单。

只有搜索完成才保存当前餐段一次，保留另一餐段和原有启用状态。候选菜单不进入保存流程，每个同步批次返回前统一恢复原菜单和实时属性。同选择率时保留符合条件的现有菜单；其他并列结果按固定搜索顺序选择，食材齐全的候选优先搜索。库存不会压过更高的原生选择率；本 Mod 不自动下单、不调价、不自动打印。

等价候选较多时可大幅减少工作量；互不等价的候选仍有指数级最坏耗时，不会把贪心结果冒充全局最优。搜索开始先快速尝试较好的组合，只有达到原生上限才提前完成；搜索分批运行，可查看进度或取消。关闭页面、切换餐段、手动改菜单，或预测、价格、食材可用性、菜品资格真实变化时，会取消搜索且不应用结果。原生列表仅改变排列顺序不会取消；取消日志会指出具体变化项。预测缺失或无可选菜品时保留原菜单。

按钮跟随游戏的 14 种语言，仅本地房主可用。不在每天开始时自行执行，也不创建独立 Mod 存档；点击后的菜单通过游戏原有流程保存。

### 安装与更新

1. 关闭游戏，按加载器自己的说明安装 UE4SS experimental。
2. 将 ZIP 中的 `AutoMenu` 文件夹放入加载器的 `Mods` 目录，确认包含 `Scripts/main.lua` 和 `enabled.txt`。
3. 启动游戏，以房主身份进入餐厅。

安装包只含原创 Mod 脚本和文档。构建不自动安装、不启动或关闭游戏。首次安装后，在 UE4SS 设置中启用 `EnableHotReloadSystem=1`，Lua 更新可按 **Ctrl+R** 重载，先清除旧按钮再建立新按钮。卸载或更新加载器前应关闭游戏。

若组合失败，查看 `[AutoMenu]` 日志，反馈游戏及加载器版本、语言、房主或访客身份。原生保存被拒绝时会报告错误，不会反复提交。组合后的匹配程度和库存仍以游戏原生预测为准。

[开发与验收](DEVELOPMENT.md#中文) · [版本变化](CHANGELOG.md)
