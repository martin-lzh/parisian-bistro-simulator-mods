# First to Serve · 先做好先端

[English](#english) · [中文](#中文)

## English

Version: **0.1.3-dev**. Aim directly at a ready dish at the kitchen pass or a finished drink on its output area, then hold the interaction key. The aimed item identifies the pickup area: First to Serve takes the earliest-created ready item from that area first, even if you are aiming at a newer one. Keep holding toward the same area to continue collecting in time order. The gesture remembers the source, so taking the aimed item does not interrupt pickup or require aiming at each next item. Empty surfaces and nearby pickup spots do not activate the Mod.

Equip your tray first. A native hold-key hint appears directly below the normal click-to-pick-up hint when the aimed item is eligible and a suitable tray slot is available. It appears only in the native central pickup panel, with no extra sidebar hint, and disappears when the pickup hint or its panel is hidden. Hot reload removes leftover Mod hints, including old sidebar hints, before showing a single central row. Its icon follows the game's keyboard/controller mappings and its wording follows the game's language. The default mouse binding is the left button; gamepad uses the game's hold-interaction binding. Tap keeps the normal single-item behavior. While carrying a tray and aiming at a supported ready item, holding is used for pickup instead of the interaction wheel. Furniture keeps its normal interaction.

Items are ordered by their native creation timestamps, not order placement time, recipe duration or when the Mod first saw them. Only ready, clean, unconsumed items in the current source are considered. Dirty plates, unfinished drinks, carried items, other floors and items outside pickup reach are excluded. No items are spawned, teleported or removed directly.

Release the key, turn away, walk away, switch areas/tools, or open a menu to stop. After taking the aimed item, the crosshair may stay on its empty spot while the remaining items are collected. The Mod stops when the suitable tray slots are full. Requests are at least 0.05 seconds apart, with progress checked every 25 ms during the hold. Each request still waits for the previous pickup to be confirmed; actual speed depends on the game and network response. If a request remains unconfirmed for two seconds, release and hold again to retry. Staff and other players can take items in between; the game retains final authority over each request.

### Installation

Requires Windows Parisian Bistro Simulator and **UE4SS experimental**. Development references: Steam Build **25393699**, ProjectVersion **1.0.0.44eb**, UE **5.4**, UE4SS API **v3.0.1-1140-gf58e8f84**. Older stable UE4SS 3.0.1 is not the target.

1. With the game closed, install the required loader separately.
2. Extract `FirstToServe-0.1.3-dev.zip` into the loader's `Mods` directory. It should contain `Mods/FirstToServe/Scripts/main.lua` and `Mods/FirstToServe/enabled.txt`.
3. Start the game yourself, enter the restaurant, equip the tray and aim directly at a ready dish or a finished drink. Check for the hold hint, then hold the mapped key.

Previously named **Oldest First**. If you installed that development package, disable its `Mods/OldestFirst/enabled.txt` before enabling `FirstToServe` so only one copy runs.

Disable by removing `FirstToServe/enabled.txt` while the game is closed. The package includes only original Mod scripts and documentation, with no loader or game assets. Building does not install anything or change saves.

The implementation handles the local player in solo, host and guest sessions and uses ordinary server-validated interaction requests. **In-game acceptance, including guest synchronization and native hint rendering, is pending.** Offline tests do not establish engine or multiplayer compatibility. See [development and acceptance checks](DEVELOPMENT.md#english). Other Mods are optional; combinations still need acceptance testing.

The hint supports English, French, Simplified Chinese, Traditional Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Turkish, Polish, Portuguese and Brazilian Portuguese. Diagnostic logs use `[FirstToServe]`. Report the Mod/loader/game versions, language, keyboard or gamepad, host/guest role, surface type and relevant log lines. Keep extracted files and full saves out of the repository.

## 中文

**First to Serve（先做好先端）**：先制作好的餐品，优先拿取出餐。

版本：**0.1.3-dev**。对准出餐口某一盘可拿取的菜品，或饮料台上某一杯已完成的饮料，长按交互键。瞄准的餐品用于识别所属出餐区域；即使对准较新的那份，也会优先拿取同一区域制作时间最早的成品。保持朝向该区域并持续按住，会继续按时间顺序拿取。长按会记住所选区域，瞄准的第一份被拿走后仍会继续，无需逐份重新瞄准。空台面和附近拿取点不触发本功能。

使用前先装备托盘。瞄准的成品可拿取且托盘有对应空位时，在原生“点击拿取”提示正下方显示长按键位提示；仅显示在原生中央取餐提示区，不在右侧栏额外显示；原生拿取提示或其容器隐藏时，长按提示也随之清除。热重载后会清理遗留的 Mod 提示，包括旧版侧边栏提示，仅保留一份中央提示。按键图标跟随游戏的键鼠/手柄映射和改键，说明文字跟随游戏语言。鼠标默认是左键；手柄使用游戏的长按交互键。短按保留原来的单件交互。持托盘瞄准支持的成品时，长按用于拿取；家具保留原本的交互。

排序使用餐品原生创建时间，不按顾客下单时间、配方制作耗时或 Mod 首次看到餐品的时间排序。只考虑当前出餐区域中已完成、干净且尚未食用的成品；排除脏盘、未灌满的饮料、已被拿走的餐品、其他楼层及拿取范围外的物品。不直接生成、传送或删除餐品。

松键、明显转开视线、走离原位置、切换区域或工具、打开菜单后停止。瞄准的餐品被拿走后，准星可以保持在原来的空位上，继续拿取同一区域剩余成品；托盘对应位置装满也会停止。两次请求最短间隔降为 0.05 秒，长按期间每 25 毫秒检查进展。仍需确认上一件已被拿走，实际速度取决于游戏和网络响应。若两秒内仍未确认进展，本次长按停止，松开后重新长按可重试。员工或其他玩家可以同时拿取，最终是否允许交互仍由游戏判断。

### 安装

需要 Windows 版 Parisian Bistro Simulator 和 **UE4SS experimental**。开发参考基线：Steam Build **25393699**、ProjectVersion **1.0.0.44eb**、UE **5.4**，UE4SS API **v3.0.1-1140-gf58e8f84**。旧稳定版 UE4SS 3.0.1 不是目标加载器。

1. 关闭游戏后，单独安装所需加载器。
2. 将 `FirstToServe-0.1.3-dev.zip` 解压到加载器的 `Mods` 目录。应出现 `Mods/FirstToServe/Scripts/main.lua` 和 `Mods/FirstToServe/enabled.txt`。
3. 自行启动游戏进入餐厅，装备托盘，对准某一盘可拿取菜品或某一杯成品饮料；看到长按提示后，按住对应键位。

本 Mod 原名 **Oldest First**。若已安装旧开发包，请先禁用旧目录中的 `Mods/OldestFirst/enabled.txt`，再启用 `FirstToServe`，避免两个副本同时运行。

关闭游戏后移除 `FirstToServe/enabled.txt` 可禁用。安装包仅含原创 Mod 脚本和说明，不包含加载器及游戏资产。构建不会自动安装或修改存档。

实现面向单人、房主和联机客机的本地玩家，通过原生服务器交互请求拿取。**仍待实机验收，包括客机同步、原生提示渲染和键位行为。** 离线测试不能证明引擎桥接及联机兼容性，详见[开发与验收清单](DEVELOPMENT.md#中文)。无需安装其他 Mod；组合使用仍需验收。

提示适配英语、法语、简体中文、繁体中文、意大利语、西班牙语、德语、俄语、日语、韩语、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。日志前缀为 `[FirstToServe]`。反馈时请提供 Mod、加载器及游戏版本、语言、键鼠或手柄、房主或客机身份、出餐区域类型和相关日志片段。请勿提交提取资料或完整存档。
