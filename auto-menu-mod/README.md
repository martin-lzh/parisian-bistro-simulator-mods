# Auto Menu / 每日菜单组合

[English](#english) · [中文](#中文)

## English

Adds an **Auto-compose** button beside **Print menu** in the computer's daily-menu page. This is an independent Mod; no other Mod is required.

**Current source: 0.1.0-dev. In-game acceptance is pending.** The local interface reference is Steam Build 25532071 / ProjectVersion 1.0.1.44eb, Unreal Engine 5.4. Requires UE4SS experimental; the checked API is `v3.0.1-1140-gf58e8f84`.

### Use

1. As host, open the computer's daily-menu page and select lunch or dinner.
2. Click **Auto-compose**. The Mod selects a dish in each available course using the customer profiles and dining intentions shown in that service's forecast, plus the day's temperature.
3. Review the result and its native forecast. You can edit individual dishes, enable/disable the menu or print it with the normal controls.

Local events are included through the game's forecast, without adding the event adjustment a second time. Cool weather favors hot/comfort dishes; very hot weather favors light/cold dishes. Recommendations use an original scoring policy, not the game's exact adoption or profit formula. They do not guarantee the highest adoption rate or profit.

Only the selected service is saved, once per click. The other service and the enabled state are preserved. Unavailable courses stay empty; no eligible dishes or missing forecasts leaves the menu unchanged. Equal scores prefer dishes with ingredients, then the existing choice, then a stable identifier. Better-matching dishes may require purchasing ingredients; this Mod does not order stock, change prices or print automatically.

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

**当前源码：0.1.0-dev，待游戏内验收。** 本机接口参考为 Steam Build 25532071 / ProjectVersion 1.0.1.44eb、Unreal Engine 5.4。需要 UE4SS experimental，核对的 API 为 `v3.0.1-1140-gf58e8f84`。

### 使用

1. 房主打开电脑的每日菜单页面，选择午餐或晚餐。
2. 点击 **自动组合**。按当前餐段页面显示的顾客类型、用餐意向预测及当天气温，为各道菜选择可用菜品。
3. 查看结果及游戏原生预测；可以继续逐项换菜，使用原有按钮启用、停用或打印菜单。

活动影响已包含在游戏预测中，不会重复叠加。凉爽天气偏向热食、暖心菜；酷热天气偏向清淡、冷食。推荐采用 Mod 自有评分规则，并非游戏精确的采用率或利润公式，不保证最高采用率或利润。

每次点击只保存当前餐段一次，保留另一餐段和原有启用状态。没有可选菜的类别留空；所有类别都没有可选菜或预测缺失时，不更改菜单。同分优先食材齐全的菜，再保留当前选择，最后按固定编号选择。匹配度较高的菜仍可能需要采购；本 Mod 不自动下单、不调价、不自动打印。

按钮跟随游戏的 14 种语言，仅本地房主可用。不在每天开始时自行执行，也不创建独立 Mod 存档；点击后的菜单通过游戏原有流程保存。

### 安装与更新

1. 关闭游戏，按加载器自己的说明安装 UE4SS experimental。
2. 将 ZIP 中的 `AutoMenu` 文件夹放入加载器的 `Mods` 目录，确认包含 `Scripts/main.lua` 和 `enabled.txt`。
3. 启动游戏，以房主身份进入餐厅。

安装包只含原创 Mod 脚本和文档。构建不自动安装、不启动或关闭游戏。首次安装后，在 UE4SS 设置中启用 `EnableHotReloadSystem=1`，Lua 更新可按 **Ctrl+R** 重载，先清除旧按钮再建立新按钮。卸载或更新加载器前应关闭游戏。

若组合失败，查看 `[AutoMenu]` 日志，反馈游戏及加载器版本、语言、房主或访客身份。原生保存被拒绝时会报告错误，不会反复提交。组合后的匹配程度和库存仍以游戏原生预测为准。

[开发与验收](DEVELOPMENT.md#中文) · [版本变化](CHANGELOG.md)
