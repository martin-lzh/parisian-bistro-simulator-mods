# Auto Menu / 每日菜单组合

[English](#english) · [中文](#中文)

## English

Adds an **Auto-compose** button beside **Print menu** on the computer's daily-menu page. This is an independent Mod.

**Current source: 0.5.0-dev. In-game acceptance is pending.** Requires UE4SS experimental; the checked API is `v3.0.1-1140-gf58e8f84`. Local interfaces were checked on Steam Build 25532071 / ProjectVersion 1.0.1.44eb, Unreal Engine 5.4.

### Use

1. As host, open the daily-menu page and choose lunch or dinner.
2. Click **Auto-compose**. The Mod tries combinations of available, enabled and staffed dishes using the game's native **estimated selection rate**, then applies the best result.
3. Review the native forecast. Edit, activate or print the menu using the existing controls.

Each course may be empty, including a completely empty menu. Every eligible combination is considered unless the native maximum rate is reached first. Rates are compared without rounding or custom preference weights. Equal rates retain the eligible current menu; other ties follow a stable order.

Search runs directly within the click, without a search timer or progress display. A native helper enumerates combinations and reuses original single-dish scores within this click. The game still calculates the complete menu prediction, including prices, ingredients, customer preferences, weather and events; its formula is not replaced. Large candidate sets can take longer and pause gameplay until enumeration finishes. The Mod does not promise instant results for every menu size.

Trial menus are never saved. The original menu is restored after trial evaluation, including when a prediction fails. The winner is applied once through the game's save function, and the page refreshes. The other service is preserved. A nonempty menu retains its active state; the game automatically deactivates an empty menu. Nothing is purchased, repriced or printed automatically.

The button follows the game's 14 languages and is available only to the local host. There is no daily background composition or separate save file.

### Install and update

1. Close the game and install UE4SS experimental following its instructions.
2. Put the ZIP's `AutoMenu` folder in the loader's `Mods` directory, including `Scripts/main.lua`, `Scripts/auto_menu_bridge.dll` and `enabled.txt`.
3. Start the game and enter a restaurant as host.

The package contains original Mod scripts, a compiled native helper and documentation. The helper refuses an unrecognized native calling convention. Building does not install it or start/stop the game. After initial installation, Lua updates support **Ctrl+R** with `EnableHotReloadSystem=1` in UE4SS settings. Reload removes the old button before creating a replacement. Close and restart the game for DLL updates, removing the Mod or updating the loader. Ctrl+R reloads Lua only.

For failures, check `[AutoMenu]` in the loader's `UE4SS.log`. Include Mod/game/loader versions, language and host/client role. Each click logs `SEARCH` with option counts (including empty) and the full combination count. Successful runs add `COMPOSED`, `TIMING_PARTS` and `NATIVE` with evaluations, total/phase times, native search time, cache hits/misses and differential check counts. No individual trials are logged. A refused native save is not repeatedly retried. See the [timing field descriptions](DEVELOPMENT.md#timing-logs).

[Development and validation](DEVELOPMENT.md#english) · [Changes](CHANGELOG.md)

## 中文

在电脑每日菜单页面的“打印菜单”旁增加 **自动组合** 按钮。这是独立 Mod。

**当前源码：0.5.0-dev，待游戏内验收。** 需要 UE4SS experimental，核对的 API 为 `v3.0.1-1140-gf58e8f84`。本机接口核对版本为 Steam Build 25532071 / ProjectVersion 1.0.1.44eb、Unreal Engine 5.4。

### 使用

1. 房主打开每日菜单页面，选择午餐或晚餐。
2. 点击 **自动组合**。Mod 对实际可用、启用且满足员工条件的菜品逐个组合，调用游戏原生 **预计选择率**，然后应用最佳结果。
3. 查看原生预测；通过原有按钮继续编辑、启用或打印菜单。

每个类别都可以留空，全空菜单也参与比较。除非已经达到原生选择率上限，否则覆盖全部可用组合。直接比较未取整的选择率，不设置自定义偏好权重。同值时保留符合条件的当前菜单，其余并列情况采用固定顺序。

搜索直接在这次点击中完成，没有搜索定时器或进度显示。原生辅助模块负责枚举，并在本次点击内复用原生单菜评分；整份菜单的价格、食材、客流偏好、天气和活动仍由游戏原生预测处理，不改写评分公式。候选较多时，同步枚举会让游戏等待计算完成，耗时仍随组合数量增长。

候选菜单不进入保存流程。试算结束后恢复原菜单，预测异常也会恢复；随后通过原生保存函数应用最佳结果一次，并刷新页面。保留另一餐段；非空菜单保留原启用状态，全空菜单由游戏自动停用。不自动采购、调价或打印。

按钮跟随游戏的 14 种语言，仅本地房主可用。不在每天开始时后台组合，也不创建独立存档。

### 安装与更新

1. 关闭游戏，按加载器说明安装 UE4SS experimental。
2. 将 ZIP 中的 `AutoMenu` 文件夹放入加载器的 `Mods` 目录，包含 `Scripts/main.lua`、`Scripts/auto_menu_bridge.dll` 和 `enabled.txt`。
3. 启动游戏，以房主身份进入餐厅。

安装包含原创 Mod 脚本、编译的原生辅助模块和文档；无法识别原生调用方式时停止操作。构建不自动安装、不启动或关闭游戏。首次安装后，在 UE4SS 设置中启用 `EnableHotReloadSystem=1`，Lua 更新可按 **Ctrl+R** 重载；重载会先移除旧按钮再建立新按钮。更新 DLL、卸载 Mod 或更新加载器时必须关闭并重启游戏；Ctrl+R 只重载 Lua。

若组合失败，查看加载器 `UE4SS.log` 中的 `[AutoMenu]` 日志，反馈 Mod／游戏／加载器版本、语言和房主／访客身份。每次点击先输出 `SEARCH`，记录含留空的各类候选数和全部组合数；成功后输出 `COMPOSED`、`TIMING_PARTS` 和 `NATIVE`，记录实际试算次数、总／各阶段耗时、原生搜索耗时、缓存命中／未命中数和对照检查数，不逐组合刷日志。原生保存被拒绝时不会反复提交。见[计时字段说明](DEVELOPMENT.md#计时日志)。

[开发与验收](DEVELOPMENT.md#中文) · [版本变化](CHANGELOG.md)
