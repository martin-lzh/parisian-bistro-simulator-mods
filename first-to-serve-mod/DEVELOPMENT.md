# First to Serve development / 开发

[English](#english) · [中文](#中文)

## English

First to Serve is an independent, original UE4SS Lua Mod. Read the [repository development rules](../DEVELOPMENT.md#english) and [player guide](README.md#english). Local interface evidence and analysis remain under ignored `work/`; no game files are build inputs.

The adapter reads the current local pawn, physical mapped-key state, camera hit, source membership, native creation times and tray or food-trolley slots on the game thread. An eligible dish or finished drink identifies its source. The kitchen pass's native pickup box also identifies its world's kitchen through the reflected world subsystem. A drink output area's own StaticMesh identifies that area's OutputSlots, without aiming at a cup. Both area paths keep the same candidate filters and per-item default-action requests; neither dispatches the area's deposit or batch action. Area targeting requires an eligible candidate and a compatible free carrier slot; unrelated components and furniture remain excluded. The Mod still sends one request to the selected dish, never the native area-level batch interaction. The kitchen area class is optional so older builds retain direct-item targeting. The native hold locks the source by scalar identity and records the view direction and player position. Each request re-resolves that source and validates the candidate. When the aimed item becomes busy, carried or absent, pickup continues within 10 degrees and 30 cm of the last eligible aim. A different eligible source cancels immediately. Repeated native trigger events cannot reset a pending pickup or restart a canceled hold before release. It compares native date structs through the engine rather than converting opaque structs to Lua tables or imprecise numbers. A native hold event arms a session scoped to the player, world, carrier kind/identity and pickup area. A separate loop revalidates active pickups every 25 ms and allows a new ordinary interaction request after 50 ms, once the previous pickup is acknowledged. Idle and stopped sessions retain 100 ms scans; a fresh native hold bypasses that idle countdown. The pure sequencing module stores identities and timing only, waits for source/carrier acknowledgement and stops an unconfirmed gesture after two seconds. It never retries indefinitely or writes game queues, timestamps, capacity or distance settings.

Food-trolley sessions resolve the local player's currently held trolley and validate its ownership, type and world. Capacity uses ordinary slots and entirely empty stack slots, preserves drink-only and top-slot restrictions, and reads both item representations for pickup acknowledgement. Dish types are resolved by enum name. Requests remain ordinary per-item interactions; the game chooses the final trolley slot. Releasing or changing the carrier cancels the gesture.

The hint creates the game's own interaction-key widget at runtime directly below the visible native Click row in CenterInteractionsKeys, using the native center icon alignment. It never anchors to a sidebar row or adds a sidebar hint. It follows native row refreshes and disappears when that row, its ancestors or the HUD is hidden or removed. Insertion preserves trailing rows and their vertical slot settings; stable layouts are left untouched. A transparent owned container isolates it from native key-row removal. The game widget renders mapped key icons and tracks input-device changes; the Mod supplies only its translated hold wording. The original wheel row is temporarily hidden while aiming at the kitchen pickup area, drink output surface or supported ready items and restored on leaving. Hook installation waits for the player Blueprint and rolls back partial installation; runtime failures disable pickup and clear the owned hint. A native wheel-eligibility hook changes only the current local pickup hold. Short clicks and other surfaces retain native behavior. Each HUD update prunes orphaned Mod rows by their exact localized text, key and widget type, including legacy sidebar wrappers. A shared boolean marks reloads so repeated held-key events cannot arm the new runtime until release. Both schedulers stop and already queued callbacks become inert. Unload stops the runtime and clears its UI when on the game thread. Off-thread unload leaves UI cleanup to the next load; shared scalar identities and prior visibility values let that load restore hidden native wheel rows without retaining UObjects across reload.

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

Tests run the real adapter and runtime together through a three-item hold with both trays and food trolleys for direct food, drinks, the native kitchen pickup area and drink output surface, including panning across either area without aiming at an item, busy targets, missing hits, source removal and stale source lists with ordinary/stack-slot acknowledgement. Trolley cases cover dirty stacks with gaps, reserved drink slots, tower-burger top slots, stale hidden trays, wrong carrier types/worlds, capacity changes before dispatch, and releasing/switching trolleys during a pending pickup. They also cover reload orphan cleanup without an active tray session, native-row visibility recovery and game-thread/off-thread unloading. Tests cover time ordering and equal-time ties, source isolation, dirty/unfinished/busy/carried/foreign items, reach and floor checks, tray capacity, ownership and input revalidation, fast confirmed sequencing, the 50 ms request limit, idle scan throttling, delayed acknowledgement, rejection timeouts, canceled gestures, deferred hook startup, optional area discovery, exact pickup-component matching, world-specific manager lookup, area rejection with empty queues/full trays/ineligible items, direct-item targeting, native-hint placement after row refreshes, preserved sibling layout, missing pickup rows, hidden parent containers, sidebar isolation, insertion failure recovery, cleanup, and language changes. Tests use original engine-shaped doubles, not exported game code. The package uses an explicit allowlist, normalized source bytes and a SHA-256 sidecar. It is not installed automatically.

### In-game regression checklist

The user reported completion of in-game testing for 0.1.7-dev on 2026-09-26; see the [validation record](../releases/validation.md#english). These scenarios remain regression references; individual results were not reported separately.

- On the recorded game/loader baseline, equip a tray or take hold of a food trolley and aim at a newer dish with older dishes at the pass. Confirm the oldest is taken first; continue holding to fill available food slots. Keep the crosshair on the first item’s empty spot and confirm pickup continues without a new hold. Repeat at both pass shelves. Also start by aiming at the native pickup area between plates; pan across it while holding and verify oldest-first order and the native-adjacent hint. Confirm empty passes and unrelated components do not start pickup.
- At two separate drink output areas, arrange different completion times and partially filled drinks. Start on each output surface and pan across it while holding; repeat with direct finished-drink aiming. Verify source isolation, full drinks only, creation-time ordering, tray/trolley capacity and preserved short-click drink deposit. Empty areas and areas with only unfinished drinks must not activate pickup. Check hold behavior even if the surface has no visible native click row; the Mod does not add a hint without that row.
- With the trolley, repeat with dirty-plate stacks, ordinary and drink-only slots, and a tower burger when only lower slots remain free. Check a parked trolley and a storage cart do not activate pickup; releasing or changing trolleys during a pending request must stop further requests until release and a fresh hold.
- Check short clicks, key release, looking away, switching stations/trays, full trays, menus, chat, pause, day changes, travel and reload. No gesture should resume without another native hold after cancellation.
- In host and guest sessions, race another player or staff member for the oldest item. Compare consecutive-pickup responsiveness with 0.1.1-dev. Confirm server acceptance, acknowledgement under latency, no duplication and no uncontrolled request loop.
- Verify the native hold hint, mouse/gamepad switching, remapped keys, all 14 languages and common resolutions. Confirm the hold row stays directly below the native pickup row through row refreshes, no duplicated wheel row, no sidebar hint, no hint without the native pickup row or with a hidden pickup panel or on unrelated targets, and correct cleanup/restoration after menus and world changes.
- Hot reload while the hint is visible and while a pickup is pending; repeat with no tray and with menus open. Confirm one central Mod row, no legacy sidebar row, restored native hints and no resumed pickup before a fresh hold. Test upgrading from older development packages as well as reloading the current package.
- Verify coexistence with the other Mods, especially any Mod that remakes or replaces served items. Record exact versions, role, language and results before accepting a stable version.

Offline results are not in-game acceptance. No game process, installation files or saves are modified by the build/test workflow. GitHub release publication requires separate authorization.

## 中文

First to Serve 是独立的原创 UE4SS Lua Mod。先读[仓库开发规则](../DEVELOPMENT.md#中文)和[玩家说明](README.md#中文)。本机接口证据和分析仅位于忽略的 `work/`；游戏文件不是构建输入。

适配层在游戏线程读取本地玩家、实际按键状态、瞄准命中、出餐区域成员、原生创建时间及托盘或餐车空位。通过瞄准可拿取菜品、成品饮料、厨房出餐口的原生拿取框或饮料出品台的 StaticMesh 识别来源；饮料台直接使用自身 OutputSlots，无需瞄准杯子。两种区域入口均保留候选过滤和逐件默认交互请求，不发送区域放回饮料或批量拿取动作。对准出餐口时，通过其世界的反射子系统获取厨房管理器，仅在有符合条件的成品及对应承载工具空位时启动；不接受其他组件或无关家具。每次仍向排序选中的具体菜品发送一次交互请求，不调用区域的批量拿取。出餐口类可选，旧版游戏仍保留直接瞄准餐品的方式；原生长按以标量身份锁定来源，记录视线方向和玩家位置；每次请求重新查找来源并验证候选餐品。瞄准餐品变为正在拿取、已携带或消失后，只要仍在最后一次有效瞄准的 10 度及 30 厘米范围内就继续；瞄准其他有效来源时立即取消。重复的原生触发事件不会清空待确认的拿取，也不会在松键前重新启动已取消的操作。通过引擎比较原生日期结构，不将不透明结构转换成 Lua 表或有精度损失的数字。原生长按事件启动一次限定于玩家、世界、承载工具类型及身份和出餐区域的操作；长按取餐期间每 25 毫秒检查状态，上一件确认拿走且距离上次请求至少 50 毫秒后发送下一次普通交互请求。空闲及停止状态保持 100 毫秒检查，新长按会立即跳过空闲等待。纯逻辑模块仅保存身份和计时，等待台面成员或承载工具状态确认；两秒未确认则停止本次长按。不无限重试，也不改写队列、时间戳、容量或交互距离。

餐车会话从本地玩家解析当前握持的餐车，验证归属、类型及世界。空位判断区分普通位和完全空出的堆叠位，遵守饮料专用位与顶层限制，并读取两种餐品存储形式确认装车；餐品枚举按名称解析。仍发送逐件普通交互，由游戏选择最终放置位置；放开或更换承载工具会取消当前操作。

提示在运行时创建游戏自身的键位组件，仅放在 CenterInteractionsKeys 中可见的原生 Click 拿取提示正下方，使用原生中央提示图标方向；不挂接侧边栏行，也不创建侧边栏提示。跟随原生行刷新，原生拿取提示、上层容器或 HUD 隐藏或移除后同步清除。插入时保留后续行顺序及垂直槽布局，稳定布局不重复挂载。透明的自有容器防止原生按键行清理逻辑删除它；按键图标和输入设备切换沿用原生组件，Mod 仅提供翻译后的长按说明。对准厨房拿取区域、饮料出品台面或支持的成品时暂时隐藏原轮盘提示，离开时恢复。等待玩家蓝图加载后才安装 Hook；安装部分失败会回滚，运行异常会停止自动拿取并清理提示。轮盘资格 Hook 仅影响本地玩家当前的拿取长按；其他位置和短按保持原行为。HUD 更新按完整本地化文案、按键和组件类型识别并清理 Mod 遗留行，包括旧版侧边栏容器。共享布尔值标记重载，使新状态在松键前不响应持续按键的重复事件；两种调度器均停止，已排队回调也不再执行。卸载时停止逻辑；若处于游戏线程则立即清理 UI，否则由下次加载清理，避免操作即将销毁的 Lua 状态。共享的标量身份和原可见性用于在重载后恢复被隐藏的原生轮盘行，不跨重载持有 UObject。

在仓库根目录运行上方命令。离线测试将真实适配层与运行逻辑联动，覆盖托盘及餐车直接瞄准菜品、饮料、厨房出餐口及饮料出品台后一次长按连续拿取三份、准星在两种出品区域内移动而不瞄准具体盘子或杯子、瞄准餐品正在拿取、命中消失、来源移除、普通位或堆叠位已确认但来源列表滞后；餐车另覆盖脏盘堆叠空隙、饮料专用位、高层汉堡顶层限制、无效隐藏托盘、错误工具类型/世界、请求前容量变化，待确认期间放开/更换餐车。还覆盖无持盘会话时清理重载遗留提示、恢复原生行可见性、游戏线程及非游戏线程卸载。另覆盖时间排序与同时间决胜、区域隔离、脏盘/未完成/占用/已携带/其他世界的物品、距离和楼层、托盘容量、身份与按键重新验证、快速确认后的连续取餐、50 毫秒请求间隔、空闲检查限频、延迟确认、超时、取消、延迟安装 Hook、可选出餐口类、准确匹配拿取组件、按世界查找厨房、空队列/满托盘/无合适餐品时拒绝区域触发、直接瞄准成品、原生行刷新后的相邻布局、其他行布局保留、拿取提示缺失、父容器隐藏、侧边栏隔离、插入失败恢复、提示清理和语言切换。测试使用原创模拟对象，不使用导出的游戏代码。安装包采用明确白名单、统一源码换行和 SHA-256 校验文件，不会自动安装。

### 实机回归清单

用户于 2026-09-26 反馈实机测试完成，本次关联 0.1.7-dev，见[验收记录](../releases/validation.md#中文)。以下场景保留作为回归参考，未单独反馈逐项结果。

- 在基线游戏和加载器上装备托盘或握住餐车，瞄准较新的菜品，确认先拿最早制作的，并持续按住装满可用菜品位；第一盘拿走后保持准星在原空位，确认无需重新长按即可继续；覆盖上下两层出餐架；另对准盘子之间的原生拿取区域启动长按，在该区域内移动准星，确认最早优先及相邻原生提示；空出餐口和无关组件不启动取餐。
- 在两个饮料台放置不同时间的成品和未灌满饮料，分别对准出品台面启动并在台面内移动准星长按，再重复直接瞄准成品杯子；确认仅拿本区域成品、时间排序、托盘/餐车容量及短按放回饮料。空台面及仅有未灌满饮料时不触发功能。台面没有可见原生点击行时仍应能长按，Mod 不在缺少该行时添加提示。
- 餐车另测脏盘堆叠、普通位、饮料专用位，以及仅底层有空位时的高层汉堡；停放餐车和搬货推车不应启动取餐，待确认时放开或更换餐车后，必须松键并重新长按才能继续。
- 检查短按、松键、移开视线、切换台面/托盘、满托盘、菜单、聊天、暂停、跨天、切场景和读档；取消后必须重新长按才能继续。
- 在房主和客机会话中与员工或其他玩家同时拿取，与 0.1.1-dev 对比连续取餐响应，检查服务器确认、延迟、无重复餐品和请求次数受限。
- 检查原生长按提示、键鼠/手柄切换、改键、14 种语言和常用分辨率；提示刷新后长按行仍紧接原生拿取行下方，无重复轮盘行、不在侧边栏显示，不在原生拿取提示缺失、取餐提示容器隐藏或瞄准无关物体时显示、菜单或切场景后正确清理与恢复。
- 在提示显示、拿取待确认、未持托盘及菜单打开时热重载；确认仅一份中央 Mod 提示、无旧版侧边栏残留、原生提示恢复，重新长按前不继续拿取；同时覆盖旧开发版升级与当前版本重载。
- 验证与其他 Mod，尤其重做或替换餐品功能同时使用。正式验收前记录完整版本、联机身份、语言和实际结果。

离线结果不等于实机验收。构建和测试不操作游戏进程、安装文件及存档。GitHub Release 发布需要另外授权。
