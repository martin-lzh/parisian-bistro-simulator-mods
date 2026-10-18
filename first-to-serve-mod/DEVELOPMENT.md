# First to Serve development / 出餐有序开发

[English](#english) · [中文](#中文)

## English

First to Serve is an independent, original UE4SS Lua Mod. Read the [repository development rules](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/DEVELOPMENT.md#english) and the [player guide](README.md#english) first. Interface evidence and analysis notes stay in ignored `work/`; no game files are build inputs.

### How it works

**Targeting**

- On the game thread, the adapter reads the local pawn, the physical mapped-key state, the camera hit, source membership, native creation times and the tray or food-trolley slots.
- A source is identified by one of:
  - an eligible dish or finished drink;
  - the kitchen pass's native pickup box, whose kitchen is resolved through the world's reflected subsystem;
  - a drink output area's own StaticMesh, which maps to that area's OutputSlots without aiming at a cup.
- Area targeting needs an eligible candidate and a compatible free carrier slot. Unrelated components and furniture are excluded.
- Both area paths use the same candidate filters and send one default-action request per item to the selected dish or drink. They never dispatch the area's deposit or batch interaction.
- The kitchen area class is optional, so older builds keep direct-item targeting.
- Native date structs are compared through the engine, not converted to Lua tables or imprecise numbers.

**Hold session and timing**

- A native hold event arms a session scoped to the player, world, carrier kind/identity and pickup area. The source is locked by scalar identity, and the view direction and player position are recorded.
- Each request re-resolves the source and revalidates the candidate. When the aimed item becomes busy, carried or absent, pickup continues within 10 degrees and 30 cm of the last eligible aim. A different eligible source cancels immediately.
- Repeated native trigger events cannot reset a pending pickup or restart a canceled hold before release.
- A separate loop revalidates active pickups every 25 ms and sends the next ordinary interaction request after 50 ms, once the previous pickup is acknowledged. Idle and stopped sessions scan every 100 ms; a fresh native hold skips the idle countdown.
- The pure sequencing module stores only identities and timing, waits for source/carrier acknowledgement and stops an unconfirmed gesture after two seconds. It never retries indefinitely and never writes game queues, timestamps, capacity or distance settings.

**Food trolleys**

- The session resolves the local player's currently held trolley and validates its ownership, type and world.
- Capacity counts ordinary slots and entirely empty stack slots, keeps drink-only and top-slot restrictions, and reads both item representations for pickup acknowledgement. Dish types are resolved by enum name.
- Requests stay ordinary per-item interactions; the game chooses the final trolley slot. Releasing or changing the carrier cancels the gesture.

**Hold hint**

- At runtime the Mod creates the game's own interaction-key widget directly below the visible native Click row in CenterInteractionsKeys, using the native center icon alignment. It never anchors to a sidebar row or adds a sidebar hint.
- The hint follows native row refreshes and disappears when that row, its ancestors or the HUD is hidden or removed.
- Insertion preserves trailing rows and their vertical slot settings; stable layouts are left untouched. A transparent owned container protects the hint from native key-row removal.
- The game widget renders mapped key icons and tracks input-device changes; the Mod supplies only the translated hold wording.
- The original wheel row is hidden while aiming at the kitchen pickup area, drink output surface or supported ready items, and restored on leaving.

**Hooks, reload and unload**

- Hook installation waits for the player Blueprint and rolls back a partial installation. Runtime failures disable pickup and clear the owned hint.
- A native wheel-eligibility hook changes only the current local pickup hold. Short clicks and other surfaces keep native behaviour.
- Each HUD update prunes orphaned Mod rows by their exact localized text, key and widget type, including legacy sidebar wrappers.
- A shared boolean marks reloads, so repeated held-key events cannot arm the new runtime until release. Both schedulers stop and already queued callbacks become inert.
- Unload stops the runtime and clears its UI when on the game thread. Off-thread unload leaves UI cleanup to the next load; shared scalar identities and prior visibility values let that load restore hidden native wheel rows without keeping UObjects across reload.

### Tests and build

Run from the repository root:

```powershell
uv run --with lupa==2.6 python first-to-serve-mod/tests/run.py
python first-to-serve-mod/build.py
python tools/check_repository.py
python tools/check_syntax.py
python -m unittest discover -s tools/tests -v
python tools/ci.py build
git diff --check
```

The tests run the real adapter and runtime together, using original engine-shaped doubles rather than exported game code. They cover:

- **Three-item holds** with trays and food trolleys for direct food, drinks, the native kitchen pickup area and the drink output surface, including panning across either area without aiming at an item, busy targets, missing hits, source removal and stale source lists with ordinary/stack-slot acknowledgement.
- **Trolleys:** dirty stacks with gaps, reserved drink slots, tower-burger top slots, stale hidden trays, wrong carrier types/worlds, capacity changes before dispatch, and releasing/switching trolleys during a pending pickup.
- **Selection rules:** time ordering and equal-time ties, source isolation, dirty/unfinished/busy/carried/foreign items, reach and floor checks, tray capacity, ownership and input revalidation.
- **Timing:** fast confirmed sequencing, the 50 ms request limit, idle scan throttling, delayed acknowledgement, rejection timeouts and canceled gestures.
- **Startup and discovery:** deferred hook startup, optional area discovery, exact pickup-component matching, world-specific manager lookup, area rejection with empty queues/full trays/ineligible items, and direct-item targeting.
- **Hint:** placement after row refreshes, preserved sibling layout, missing pickup rows, hidden parent containers, sidebar isolation, insertion failure recovery, cleanup and language changes.
- **Reload:** orphan cleanup without an active tray session, native-row visibility recovery, and game-thread/off-thread unloading.

The package uses an explicit allowlist, normalized source bytes and a SHA-256 sidecar. It is not installed automatically.

### In-game regression checklist

0.1.7 passed in-game and multiplayer testing on 2026-09-26 ([validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/releases/validation.md#english)). Use these scenarios when retesting:

- **Kitchen pass:** equip a tray or take hold of a food trolley and aim at a newer dish with older dishes at the pass. Confirm the oldest is taken first and that holding fills the available food slots. Keep the crosshair on the first item's empty spot and confirm pickup continues without a new hold. Repeat at both pass shelves. Also start by aiming at the native pickup area between plates, pan across it while holding, and check oldest-first order and the native-adjacent hint. Empty passes and unrelated components must not start pickup.
- **Drink output:** at two separate drink output areas, arrange different completion times and partially filled drinks. Start on each output surface and pan across it while holding; repeat by aiming directly at finished drinks. Check source isolation, full drinks only, creation-time ordering, tray/trolley capacity and the preserved short-click drink deposit. Empty areas and areas with only unfinished drinks must not activate pickup. Check the hold even if the surface has no visible native click row; the Mod adds no hint without that row.
- **Trolley:** repeat with dirty-plate stacks, ordinary and drink-only slots, and a tower burger when only lower slots are free. A parked trolley and a storage cart must not activate pickup. Releasing or changing trolleys during a pending request must stop further requests until release and a fresh hold.
- **Cancellation:** check short clicks, key release, looking away, switching stations/trays, full trays, menus, chat, pause, day changes, travel and reload. No gesture should resume without a new native hold.
- **Multiplayer:** in host and guest sessions, race another player or staff member for the oldest item. Compare consecutive-pickup responsiveness with 0.1.1-dev. Confirm server acceptance, acknowledgement under latency, no duplication and no uncontrolled request loop.
- **Hint and input:** check the native hold hint, mouse/gamepad switching, remapped keys, all 14 languages and common resolutions. The hold row must stay directly below the native pickup row through row refreshes, with no duplicated wheel row and no sidebar hint. It must not appear without the native pickup row, with a hidden pickup panel or on unrelated targets, and must clean up and restore correctly after menus and world changes.
- **Hot reload:** reload while the hint is visible and while a pickup is pending; repeat with no tray and with menus open. Expect one central Mod row, no legacy sidebar row, restored native hints and no resumed pickup before a fresh hold. Test upgrading from older development packages as well as reloading the current package.
- **Other Mods:** check coexistence, especially with any Mod that remakes or replaces served items. Record exact versions, role, language and results before accepting a stable version.

### Runtime compatibility

- Current version: **0.1.8**, supporting **Steam Build 25822788 / 1.0.2.44eb**.
- **0.1.8 test status:** compared with 0.1.7, 0.1.8 changes only the license (PolyForm Noncommercial 1.0.0), the documentation and the version number; gameplay code is unchanged. In-game testing of 0.1.8 by the maintainer is still pending.
- Development reference for the pickup areas: Windows, Steam Build 25532071 / ProjectVersion 1.0.1.44eb, Unreal Engine 5.4.
- Loader: UE4SS experimental `v3.0.1-1140-gf58e8f84`. Stable UE4SS 3.0.1 is not the target.

When reporting issues, include the `[FirstToServe]` log lines with the exact versions, language, keyboard/controller, host/guest role and targeted surface.

### Manual script reload

Install this version with the game closed before the first reload; older versions cannot hand over every state field.

1. In `UE4SS-settings.ini`, under `[General]`, set `EnableHotReloadSystem = 1`, `HotReloadKey = R` and `EnableAutoReloadingLuaMods = 0`, then restart the game once.
2. After replacing every Lua script, focus the game and press **Ctrl+R**. See the [shared reload guide](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/docs/hot-reload.md#english).

Reload cancels the current pickup; release the interaction key before holding again. Cleanup and native-hint restoration work as described under **Hooks, reload and unload**. Keep automatic Lua reload off so a half-finished multi-file copy is never loaded.

## 中文

First to Serve 是独立的原创 UE4SS Lua Mod。请先读[仓库开发规则](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/DEVELOPMENT.md#中文)和[玩家说明](README.md#中文)。接口证据和分析笔记只放在被忽略的 `work/`；游戏文件不是构建输入。

### 工作原理

**识别来源**

- 适配层在游戏线程读取本地玩家、实际按键状态、瞄准命中、出餐区域成员、原生创建时间，以及托盘或餐车空位。
- 来源通过以下任一方式识别：
  - 可拿取的菜品或成品饮料；
  - 厨房出餐口的原生拿取框，通过其所在世界的反射子系统获取厨房管理器；
  - 饮料出品台自身的 StaticMesh，直接对应该台的 OutputSlots，无需瞄准杯子。
- 区域触发需要有符合条件的成品，以及承载工具上对应的空位；其他组件和无关家具不触发。
- 两种区域入口使用相同的候选过滤，每次只向排序选中的具体菜品或饮料发送一次默认交互请求，不调用区域的放回饮料或批量拿取动作。
- 出餐口类为可选，旧版游戏仍可直接瞄准餐品。
- 原生日期结构通过引擎比较，不转换成 Lua 表或有精度损失的数字。

**长按会话与计时**

- 原生长按事件启动一次会话，限定于玩家、世界、承载工具类型及身份和出餐区域；以标量身份锁定来源，并记录视线方向和玩家位置。
- 每次请求重新查找来源并验证候选餐品。瞄准的餐品变为正在拿取、已携带或消失后，只要仍在最后一次有效瞄准的 10 度、30 厘米范围内就继续；瞄准其他有效来源时立即取消。
- 重复的原生触发事件不会清空待确认的拿取，也不会在松键前重新启动已取消的操作。
- 独立循环在长按期间每 25 毫秒检查状态；上一件确认拿走、且距上次请求至少 50 毫秒后，才发送下一次普通交互请求。空闲及停止状态每 100 毫秒检查一次，新的长按会立即跳过空闲等待。
- 纯逻辑模块只保存身份和计时，等待台面成员或承载工具状态确认，两秒未确认即停止本次长按。不会无限重试，也不改写游戏队列、时间戳、容量或交互距离。

**送餐餐车**

- 会话从本地玩家解析当前握持的餐车，并验证归属、类型及世界。
- 空位判断区分普通位和完全空出的堆叠位，遵守饮料专用位与顶层限制，并读取两种餐品存储形式确认装车；餐品类型按枚举名称解析。
- 仍逐件发送普通交互，由游戏选择最终放置位置；放开或更换承载工具会取消当前操作。

**长按提示**

- 运行时创建游戏自身的键位组件，放在 CenterInteractionsKeys 中可见的原生 Click 拿取提示正下方，使用原生中央提示的图标方向；不挂接侧边栏行，也不创建侧边栏提示。
- 跟随原生行刷新；原生拿取提示、上层容器或 HUD 隐藏或移除时同步清除。
- 插入时保留后续行顺序及垂直槽布局，稳定布局不重复挂载。透明的自有容器防止原生按键行清理逻辑删除提示。
- 按键图标和输入设备切换沿用原生组件，Mod 只提供翻译后的长按文案。
- 对准厨房拿取区域、饮料出品台面或支持的成品时暂时隐藏原轮盘提示，离开时恢复。

**Hook、重载与卸载**

- 等待玩家蓝图加载后才安装 Hook，部分安装失败会回滚；运行异常会停止自动拿取并清理提示。
- 轮盘资格 Hook 只影响本地玩家当前的拿取长按；短按和其他位置保持原版行为。
- 每次 HUD 更新按完整本地化文案、按键和组件类型识别并清理 Mod 遗留行，包括旧版侧边栏容器。
- 共享布尔值标记重载，新状态在松键前不响应持续按键的重复事件；两种调度器均停止，已排队的回调也不再执行。
- 卸载时停止逻辑；在游戏线程上会立即清理 UI，否则由下次加载清理，避免操作即将销毁的 Lua 状态。共享的标量身份和原可见性用于在重载后恢复被隐藏的原生轮盘行，不跨重载持有 UObject。

### 测试与构建

在仓库根目录运行：

```powershell
uv run --with lupa==2.6 python first-to-serve-mod/tests/run.py
python first-to-serve-mod/build.py
python tools/check_repository.py
python tools/check_syntax.py
python -m unittest discover -s tools/tests -v
python tools/ci.py build
git diff --check
```

离线测试将真实适配层与运行逻辑联动，使用原创模拟对象，不使用导出的游戏代码。覆盖范围：

- **连续拿取三份：**托盘及餐车直接瞄准菜品、饮料、厨房出餐口和饮料出品台；准星在两种出品区域内移动而不瞄准具体盘子或杯子；瞄准餐品正在拿取、命中消失、来源移除，以及普通位或堆叠位已确认但来源列表滞后。
- **餐车：**脏盘堆叠空隙、饮料专用位、高层汉堡顶层限制、无效隐藏托盘、错误工具类型或世界、请求前容量变化，以及待确认期间放开或更换餐车。
- **选取规则：**时间排序与同时间决胜、区域隔离、脏盘／未完成／占用／已携带／其他世界的物品、距离和楼层、托盘容量、身份与按键重新验证。
- **计时：**确认后快速连续取餐、50 毫秒请求间隔、空闲检查限频、延迟确认、超时和取消。
- **启动与定位：**延迟安装 Hook、可选出餐口类、准确匹配拿取组件、按世界查找厨房、空队列／满托盘／无合适餐品时拒绝区域触发、直接瞄准成品。
- **提示：**原生行刷新后的相邻布局、其他行布局保留、拿取提示缺失、父容器隐藏、侧边栏隔离、插入失败恢复、提示清理和语言切换。
- **重载：**无持盘会话时清理重载遗留提示、恢复原生行可见性、游戏线程及非游戏线程卸载。

安装包采用明确白名单、统一源码换行和 SHA-256 校验文件，不会自动安装。

### 实机回归清单

0.1.7 已于 2026-09-26 通过实机及联机测试（[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/releases/validation.md#中文)）。重新测试时参考以下场景：

- **厨房出餐口：**装备托盘或握住餐车，瞄准较新的菜品，确认先拿最早做好的，持续按住能装满可用菜品位；第一盘拿走后让准星停在原空位，确认无需重新长按即可继续；覆盖上下两层出餐架。另对准盘子之间的原生拿取区域开始长按，在该区域内移动准星，确认最早优先及紧邻原生提示；空出餐口和无关组件不应开始拿取。
- **饮料出品台：**在两个饮料台放置不同时间的成品和未灌满的饮料，分别对准出品台面开始长按并在台面内移动准星，再改为直接瞄准成品杯子重复；确认只拿本区域成品、按时间排序、遵守托盘／餐车容量，短按仍能放回饮料。空台面及只有未灌满饮料的台面不应触发。台面没有可见的原生点击行时也应能长按，此时 Mod 不添加提示。
- **餐车：**另测脏盘堆叠、普通位、饮料专用位，以及只剩底层空位时的高层汉堡；停放的餐车和搬货推车不应开始拿取。待确认期间放开或更换餐车后，必须松键并重新长按才能继续。
- **取消：**检查短按、松键、移开视线、切换台面／托盘、托盘装满、菜单、聊天、暂停、跨天、切场景和读档；取消后必须重新长按才能继续。
- **联机：**在房主和客机会话中与员工或其他玩家抢拿最早的餐品，与 0.1.1-dev 对比连续取餐响应；检查服务器确认、延迟下的确认、无重复餐品，且请求次数受控。
- **提示与输入：**检查原生长按提示、键鼠／手柄切换、改键、14 种语言和常用分辨率。提示刷新后长按行仍紧接原生拿取行下方，无重复轮盘行、不在侧边栏显示；原生拿取提示缺失、取餐提示容器隐藏或瞄准无关物体时不显示；打开菜单或切场景后正确清理与恢复。
- **热重载：**在提示显示、拿取待确认、未持托盘及菜单打开时分别重载；确认只有一份中央 Mod 提示、无旧版侧边栏残留、原生提示已恢复，重新长按前不继续拿取。同时覆盖从旧开发版升级和当前版本重载。
- **其他 Mod：**验证与其他 Mod 同时使用，尤其是重做或替换餐品的 Mod。正式验收前记录完整版本、联机身份、语言和实际结果。

### 运行兼容性

- 当前版本：**0.1.8**，支持至 **Steam Build 25822788 / 1.0.2.44eb**。
- **0.1.8 测试状态：**与 0.1.7 相比，0.1.8 只更改许可（PolyForm Noncommercial 1.0.0）、文档和版本号，玩法代码不变。维护者对 0.1.8 的实机测试尚待进行。
- 出餐区域开发参考：Windows、Steam Build 25532071 / ProjectVersion 1.0.1.44eb、Unreal Engine 5.4。
- 加载器：UE4SS experimental `v3.0.1-1140-gf58e8f84`；不以旧稳定版 UE4SS 3.0.1 为目标。

反馈问题时，请附上 `[FirstToServe]` 日志，并注明完整版本、语言、键鼠或手柄、房主或客机身份及目标台面。

### 手动脚本重载

首次重载前，须在关闭游戏时安装本版；旧版无法交接全部状态。

1. 在 `UE4SS-settings.ini` 的 `[General]` 中设置 `EnableHotReloadSystem = 1`、`HotReloadKey = R`、`EnableAutoReloadingLuaMods = 0`，然后重启游戏一次。
2. 替换完全部 Lua 脚本后，在游戏窗口中按 **Ctrl+R**。参见[统一重载说明](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/docs/hot-reload.md#中文)。

重载会取消当前取餐，须松开交互键后重新长按。遗留清理和原生提示恢复见上方“Hook、重载与卸载”。保持自动 Lua 重载关闭，避免多文件复制到一半时加载不完整的更新。
