# First to Serve · 先做好先端

[English](#english) · [中文](#中文)

## English

Version: **0.1.5-dev**. Aim at the kitchen pass's native pickup area and hold the interaction key to collect the earliest-created ready dishes in order. You do not need to aim at a particular plate; moving the crosshair across the same pickup area keeps the hold active. You can also start by aiming at a ready dish, or at a finished drink on a drink output area. The gesture remembers the source after each item is taken. Empty passes and unrelated surfaces do not start pickup.

Equip your tray first. A native hold-key hint appears directly below the normal click-to-pick-up hint when the targeted pass or item has an eligible candidate and a suitable tray slot is available. It appears only in the native central pickup panel, with no extra sidebar hint, and disappears when the pickup hint or its panel is hidden. Hot reload removes leftover Mod hints, including old sidebar hints, before showing a single central row. Its icon follows the game's keyboard/controller mappings and its wording follows the game's language. The default mouse binding is the left button; gamepad uses the game's hold-interaction binding. Tap keeps the game's normal behavior, including its native pass pickup. While carrying a tray and aiming at the kitchen pickup area or a supported ready item, holding is used for oldest-first pickup instead of the interaction wheel. Other furniture keeps its normal interaction.

Items are ordered by their native creation timestamps, not order placement time, recipe duration or when the Mod first saw them. Only ready, clean, unconsumed items in the current source are considered. Dirty plates, unfinished drinks, carried items, other floors and items outside pickup reach are excluded. No items are spawned, teleported or removed directly.

Release the key, turn away, walk away, switch areas/tools, or open a menu to stop. After taking the aimed item, the crosshair may stay on its empty spot while the remaining items are collected. The Mod stops when the suitable tray slots are full. Requests are at least 0.05 seconds apart, with progress checked every 25 ms during the hold. Each request still waits for the previous pickup to be confirmed; actual speed depends on the game and network response. If a request remains unconfirmed for two seconds, release and hold again to retry. Staff and other players can take items in between; the game retains final authority over each request.

### Script hot reload

Enable `EnableHotReloadSystem = 1` and `HotReloadKey = R` in the `[General]` section of `UE4SS-settings.ini`, then restart the game once. Keep `EnableAutoReloadingLuaMods = 0` so copying several files cannot load a partial update. With the game focused, press **Ctrl+R** after replacing all Lua scripts. A reload cancels the current pickup; release the interaction key before starting a new hold. Hooks and timers are replaced by UE4SS, and leftover hints are cleaned on the game thread. Install this version with the game closed before the first reload; older versions cannot hand over all state.

### Installation

Requires Windows Parisian Bistro Simulator and **UE4SS experimental**. Current pickup-area reference: Steam Build **25532071**, ProjectVersion **1.0.1.44eb**, UE **5.4**, UE4SS API **v3.0.1-1140-gf58e8f84**. Older stable UE4SS 3.0.1 is not the target.

1. With the game closed, install the required loader separately.
2. Extract `FirstToServe-0.1.5-dev.zip` into the loader's `Mods` directory. It should contain `Mods/FirstToServe/Scripts/main.lua` and `Mods/FirstToServe/enabled.txt`.
3. Start the game yourself, enter the restaurant, equip the tray and aim at the kitchen pickup area, a ready dish or a finished drink. Check for the hold hint, then hold the mapped key.

Previously named **Oldest First**. If you installed that development package, disable its `Mods/OldestFirst/enabled.txt` before enabling `FirstToServe` so only one copy runs.

Disable by removing `FirstToServe/enabled.txt` while the game is closed. The package includes only original Mod scripts and documentation, with no loader or game assets. Building does not install anything or change saves.

The implementation handles the local player in solo, host and guest sessions and uses ordinary server-validated interaction requests. **In-game acceptance, including guest synchronization and native hint rendering, is pending.** Offline tests do not establish engine or multiplayer compatibility. See [development and acceptance checks](DEVELOPMENT.md#english). Other Mods are optional; combinations still need acceptance testing.

The hint supports English, French, Simplified Chinese, Traditional Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Turkish, Polish, Portuguese and Brazilian Portuguese. Diagnostic logs use `[FirstToServe]`. Report the Mod/loader/game versions, language, keyboard or gamepad, host/guest role, surface type and relevant log lines. Keep extracted files and full saves out of the repository.

## 中文

**First to Serve（先做好先端）**：先制作好的餐品，优先拿取出餐。

版本：**0.1.5-dev**。对准厨房出餐口的原生拿取区域，长按交互键，即可按制作时间先后连续拿取成品。无需固定瞄准某一盘菜品，准星在同一拿取区域内移动时仍会继续。也可以沿用直接瞄准一盘成品菜品，或饮料台上一杯成品饮料的方式启动；每份拿走后会记住所选来源。空出餐口和无关台面不启动取餐。

使用前先装备托盘。对准的出餐口或餐品有可取成品，且托盘有对应空位时，在原生“点击拿取”提示正下方显示长按键位提示；仅显示在原生中央取餐提示区，不在右侧栏额外显示；原生拿取提示或其容器隐藏时，长按提示也随之清除。热重载后会清理遗留的 Mod 提示，包括旧版侧边栏提示，仅保留一份中央提示。按键图标跟随游戏的键鼠/手柄映射和改键，说明文字跟随游戏语言。鼠标默认是左键；手柄使用游戏的长按交互键。短按保留游戏原本的交互，包括出餐口的原生拿取。持托盘对准厨房拿取区域或支持的成品时，长按用于按制作时间取餐；其他家具保留原本的交互。

排序使用餐品原生创建时间，不按顾客下单时间、配方制作耗时或 Mod 首次看到餐品的时间排序。只考虑当前出餐区域中已完成、干净且尚未食用的成品；排除脏盘、未灌满的饮料、已被拿走的餐品、其他楼层及拿取范围外的物品。不直接生成、传送或删除餐品。

松键、明显转开视线、走离原位置、切换区域或工具、打开菜单后停止。瞄准的餐品被拿走后，准星可以保持在原来的空位上，继续拿取同一区域剩余成品；托盘对应位置装满也会停止。两次请求最短间隔降为 0.05 秒，长按期间每 25 毫秒检查进展。仍需确认上一件已被拿走，实际速度取决于游戏和网络响应。若两秒内仍未确认进展，本次长按停止，松开后重新长按可重试。员工或其他玩家可以同时拿取，最终是否允许交互仍由游戏判断。

### 脚本热重载

在 `UE4SS-settings.ini` 的 `[General]` 中设置 `EnableHotReloadSystem = 1`、`HotReloadKey = R`，然后重启游戏一次。保持 `EnableAutoReloadingLuaMods = 0`，避免多文件覆盖到一半就自动加载。更新完所有 Lua 脚本后，游戏窗口中按 **Ctrl+R**。重载会取消当前取餐，松开交互键后才能重新长按。UE4SS 替换 Hook 与计时器，遗留提示由游戏线程清理。首次升级请关闭游戏安装本版，旧版无法交接完整状态。

### 安装

需要 Windows 版 Parisian Bistro Simulator 和 **UE4SS experimental**。当前出餐口参考：Steam Build **25532071**、ProjectVersion **1.0.1.44eb**、UE **5.4**，UE4SS API **v3.0.1-1140-gf58e8f84**。旧稳定版 UE4SS 3.0.1 不是目标加载器。

1. 关闭游戏后，单独安装所需加载器。
2. 将 `FirstToServe-0.1.5-dev.zip` 解压到加载器的 `Mods` 目录。应出现 `Mods/FirstToServe/Scripts/main.lua` 和 `Mods/FirstToServe/enabled.txt`。
3. 自行启动游戏进入餐厅，装备托盘，对准厨房出餐口的拿取区域、某一盘可取菜品或某一杯成品饮料；看到长按提示后，按住对应键位。

本 Mod 原名 **Oldest First**。若已安装旧开发包，请先禁用旧目录中的 `Mods/OldestFirst/enabled.txt`，再启用 `FirstToServe`，避免两个副本同时运行。

关闭游戏后移除 `FirstToServe/enabled.txt` 可禁用。安装包仅含原创 Mod 脚本和说明，不包含加载器及游戏资产。构建不会自动安装或修改存档。

实现面向单人、房主和联机客机的本地玩家，通过原生服务器交互请求拿取。**仍待实机验收，包括客机同步、原生提示渲染和键位行为。** 离线测试不能证明引擎桥接及联机兼容性，详见[开发与验收清单](DEVELOPMENT.md#中文)。无需安装其他 Mod；组合使用仍需验收。

提示适配英语、法语、简体中文、繁体中文、意大利语、西班牙语、德语、俄语、日语、韩语、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。日志前缀为 `[FirstToServe]`。反馈时请提供 Mod、加载器及游戏版本、语言、键鼠或手柄、房主或客机身份、出餐区域类型和相关日志片段。请勿提交提取资料或完整存档。
