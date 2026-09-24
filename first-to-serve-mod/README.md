# First to Serve · 先做好先端

[English](#english) · [中文](#中文)

## English

Version: **0.1.0-dev**. Hold the interaction key over a dish at the kitchen pass, a nearby pass pickup spot, a drink on an output area, or the drink output area itself. First to Serve requests the earliest-created ready item first, then continues while you hold the key and keep looking at the same pickup area.

Equip your tray first. A native interaction-key hint appears when a suitable item and tray slot are available. Its icon follows the game's keyboard/controller mappings and its wording follows the game's language. The default mouse binding is the left button; gamepad uses the game's hold-interaction binding. Tap keeps the normal single-item behavior. While carrying a tray at these pickup surfaces, holding is used for pickup instead of the interaction wheel; put the tray away to use the furniture wheel.

Items are ordered by their native creation timestamps, not order placement time, recipe duration or when the Mod first saw them. Only ready, clean, unconsumed items in the current source are considered. Dirty plates, unfinished drinks, carried items, other floors and items outside pickup reach are excluded. No items are spawned, teleported or removed directly.

Release the key, look away, switch areas/tools, or open a menu to stop. The Mod stops when the suitable tray slots are full. Requests are at least 0.3 seconds apart and wait for observed pickup progress. If a request remains unconfirmed for two seconds, release and hold again to retry. Staff and other players can take items in between; the game retains final authority over each request.

### Installation

Requires Windows Parisian Bistro Simulator and **UE4SS experimental**. Development references: Steam Build **25393699**, ProjectVersion **1.0.0.44eb**, UE **5.4**, UE4SS API **v3.0.1-1140-gf58e8f84**. Older stable UE4SS 3.0.1 is not the target.

1. With the game closed, install the required loader separately.
2. Extract `FirstToServe-0.1.0-dev.zip` into the loader's `Mods` directory. It should contain `Mods/FirstToServe/Scripts/main.lua` and `Mods/FirstToServe/enabled.txt`.
3. Start the game yourself, enter the restaurant, equip the tray and aim at a ready item or drink output area. Check for the hold hint, then hold the mapped key.

Previously named **Oldest First**. If you installed that development package, disable its `Mods/OldestFirst/enabled.txt` before enabling `FirstToServe` so only one copy runs.

Disable by removing `FirstToServe/enabled.txt` while the game is closed. The package includes only original Mod scripts and documentation, with no loader or game assets. Building does not install anything or change saves.

The implementation handles the local player in solo, host and guest sessions and uses ordinary server-validated interaction requests. **In-game acceptance, including guest synchronization and native hint rendering, is pending.** Offline tests do not establish engine or multiplayer compatibility. See [development and acceptance checks](DEVELOPMENT.md#english). Other Mods are optional; combinations still need acceptance testing.

The hint supports English, French, Simplified Chinese, Traditional Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Turkish, Polish, Portuguese and Brazilian Portuguese. Diagnostic logs use `[FirstToServe]`. Report the Mod/loader/game versions, language, keyboard or gamepad, host/guest role, surface type and relevant log lines. Keep extracted files and full saves out of the repository.

## 中文

**First to Serve（先做好先端）**：先制作好的餐品，优先拿取出餐。

版本：**0.1.0-dev**。瞄准出餐口的菜品、出餐口附近的拿取点、饮料台上的饮料或饮料台本身，长按交互键，即可优先拿取制作时间最早的成品。持续按住并保持瞄准同一出餐区域，会继续按时间顺序拿取。

使用前先装备托盘。有可拿取成品且托盘有对应空位时，显示原生风格的长按键位提示。按键图标跟随游戏的键鼠/手柄映射和改键，说明文字跟随游戏语言。鼠标默认是左键；手柄使用游戏的长按交互键。短按保留原来的单件交互。持托盘瞄准这些出餐区域时，长按用于拿取；如需打开家具交互轮盘，先收起托盘。

排序使用餐品原生创建时间，不按顾客下单时间、配方制作耗时或 Mod 首次看到餐品的时间排序。只考虑当前出餐区域中已完成、干净且尚未食用的成品；排除脏盘、未灌满的饮料、已被拿走的餐品、其他楼层及拿取范围外的物品。不直接生成、传送或删除餐品。

松键、移开视线、切换区域或工具、打开菜单后停止；托盘对应位置装满也会停止。两次请求至少间隔 0.3 秒，并等待上一件拿取的结果。若两秒内仍未确认进展，本次长按停止，松开后重新长按可重试。员工或其他玩家可以同时拿取，最终是否允许交互仍由游戏判断。

### 安装

需要 Windows 版 Parisian Bistro Simulator 和 **UE4SS experimental**。开发参考基线：Steam Build **25393699**、ProjectVersion **1.0.0.44eb**、UE **5.4**，UE4SS API **v3.0.1-1140-gf58e8f84**。旧稳定版 UE4SS 3.0.1 不是目标加载器。

1. 关闭游戏后，单独安装所需加载器。
2. 将 `FirstToServe-0.1.0-dev.zip` 解压到加载器的 `Mods` 目录。应出现 `Mods/FirstToServe/Scripts/main.lua` 和 `Mods/FirstToServe/enabled.txt`。
3. 自行启动游戏进入餐厅，装备托盘，瞄准可拿取的餐品或饮料台；看到长按提示后，按住对应键位。

本 Mod 原名 **Oldest First**。若已安装旧开发包，请先禁用旧目录中的 `Mods/OldestFirst/enabled.txt`，再启用 `FirstToServe`，避免两个副本同时运行。

关闭游戏后移除 `FirstToServe/enabled.txt` 可禁用。安装包仅含原创 Mod 脚本和说明，不包含加载器及游戏资产。构建不会自动安装或修改存档。

实现面向单人、房主和联机客机的本地玩家，通过原生服务器交互请求拿取。**仍待实机验收，包括客机同步、原生提示渲染和键位行为。** 离线测试不能证明引擎桥接及联机兼容性，详见[开发与验收清单](DEVELOPMENT.md#中文)。无需安装其他 Mod；组合使用仍需验收。

提示适配英语、法语、简体中文、繁体中文、意大利语、西班牙语、德语、俄语、日语、韩语、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。日志前缀为 `[FirstToServe]`。反馈时请提供 Mod、加载器及游戏版本、语言、键鼠或手柄、房主或客机身份、出餐区域类型和相关日志片段。请勿提交提取资料或完整存档。
