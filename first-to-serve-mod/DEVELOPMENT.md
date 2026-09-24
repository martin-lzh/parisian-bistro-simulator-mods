# First to Serve development / 开发

[English](#english) · [中文](#中文)

## English

First to Serve is an independent, original UE4SS Lua Mod. Read the [repository development rules](../DEVELOPMENT.md#english) and [player guide](README.md#english). Local interface evidence and analysis remain under ignored `work/`; no game files are build inputs.

The adapter reads the current local pawn, physical mapped-key state, camera hit, source membership, native creation times and tray slots on the game thread. Only an eligible dish or finished drink identifies its source; output-area furniture and pass pickup spots are excluded. The aimed item is revalidated before each request. It compares native date structs through the engine rather than converting opaque structs to Lua tables or imprecise numbers. A native hold event arms a session scoped to the player, world, tray and pickup area. A separate loop revalidates active pickups every 25 ms and allows a new ordinary interaction request after 50 ms, once the previous pickup is acknowledged. Idle and stopped sessions retain 100 ms scans; a fresh native hold bypasses that idle countdown. The pure sequencing module stores identities and timing only, waits for membership/tray acknowledgement and stops an unconfirmed gesture after two seconds. It never retries indefinitely or writes game queues, timestamps, capacity or distance settings.

The hint creates the game's own interaction-key widget at runtime directly below the visible native Click row in CenterInteractionsKeys, using the native center icon alignment. It never anchors to a sidebar row or adds a sidebar hint. It follows native row refreshes and disappears when that row, its ancestors or the HUD is hidden or removed. Insertion preserves trailing rows and their vertical slot settings; stable layouts are left untouched. A transparent owned container isolates it from native key-row removal. The game widget renders mapped key icons and tracks input-device changes; the Mod supplies only its translated hold wording. The original wheel row is temporarily hidden while aiming at supported ready items and restored on leaving. Hook installation waits for the player Blueprint and rolls back partial installation; runtime failures disable pickup and clear the owned hint. A native wheel-eligibility hook changes only the current local pickup hold. Short clicks and other surfaces retain native behavior.

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

Tests cover time ordering and equal-time ties, source isolation, dirty/unfinished/busy/carried/foreign items, reach and floor checks, tray capacity, ownership and input revalidation, fast confirmed sequencing, the 50 ms request limit, idle scan throttling, delayed acknowledgement, rejection timeouts, canceled gestures, deferred hook startup, item-only targeting, native-hint placement after row refreshes, preserved sibling layout, missing pickup rows, hidden parent containers, sidebar isolation, insertion failure recovery, cleanup, and language changes. Tests use original engine-shaped doubles, not exported game code. The package uses an explicit allowlist, normalized source bytes and a SHA-256 sidecar. It is not installed automatically.

### In-game acceptance — pending

- On the recorded game/loader baseline, equip a tray and aim at a newer dish with older dishes at the pass. Confirm the oldest is taken first; continue holding to fill available food slots. Repeat at both pass shelves. Confirm empty shelves and nearby pickup spots do not trigger pickup.
- At two separate drink output areas, arrange different completion times and partially filled drinks. Aim at each finished drink; verify source isolation, full drinks only, creation-time ordering and drink-only tray slots. The area itself and unfinished drinks must not activate pickup.
- Check short clicks, key release, looking away, switching stations/trays, full trays, menus, chat, pause, day changes, travel and reload. No gesture should resume without another native hold after cancellation.
- In host and guest sessions, race another player or staff member for the oldest item. Compare consecutive-pickup responsiveness with 0.1.1-dev. Confirm server acceptance, acknowledgement under latency, no duplication and no uncontrolled request loop.
- Verify the native hold hint, mouse/gamepad switching, remapped keys, all 14 languages and common resolutions. Confirm the hold row stays directly below the native pickup row through row refreshes, no duplicated wheel row, no sidebar hint, no hint without the native pickup row or with a hidden pickup panel or on unrelated targets, and correct cleanup/restoration after menus and world changes.
- Verify coexistence with the other Mods, especially any Mod that remakes or replaces served items. Record exact versions, role, language and results before accepting a stable version.

Offline results are not in-game acceptance. No game process, installation files or saves are modified by the build/test workflow. GitHub release publication requires separate authorization.

## 中文

First to Serve 是独立的原创 UE4SS Lua Mod。先读[仓库开发规则](../DEVELOPMENT.md#中文)和[玩家说明](README.md#中文)。本机接口证据和分析仅位于忽略的 `work/`；游戏文件不是构建输入。

适配层在游戏线程读取本地玩家、实际按键状态、瞄准命中、出餐区域成员、原生创建时间及托盘空位。仅通过瞄准的可拿取菜品或成品饮料识别来源，不接受饮料台家具和出餐口拿取点；每次请求前重新验证瞄准餐品。通过引擎比较原生日期结构，不将不透明结构转换成 Lua 表或有精度损失的数字。原生长按事件启动一次限定于玩家、世界、托盘和出餐区域的操作；长按取餐期间每 25 毫秒检查状态，上一件确认拿走且距离上次请求至少 50 毫秒后发送下一次普通交互请求。空闲及停止状态保持 100 毫秒检查，新长按会立即跳过空闲等待。纯逻辑模块仅保存身份和计时，等待台面成员或托盘状态确认；两秒未确认则停止本次长按。不无限重试，也不改写队列、时间戳、容量或交互距离。

提示在运行时创建游戏自身的键位组件，仅放在 CenterInteractionsKeys 中可见的原生 Click 拿取提示正下方，使用原生中央提示图标方向；不挂接侧边栏行，也不创建侧边栏提示。跟随原生行刷新，原生拿取提示、上层容器或 HUD 隐藏或移除后同步清除。插入时保留后续行顺序及垂直槽布局，稳定布局不重复挂载。透明的自有容器防止原生按键行清理逻辑删除它；按键图标和输入设备切换沿用原生组件，Mod 仅提供翻译后的长按说明。瞄准支持的成品时暂时隐藏原轮盘提示，离开时恢复。等待玩家蓝图加载后才安装 Hook；安装部分失败会回滚，运行异常会停止自动拿取并清理提示。轮盘资格 Hook 仅影响本地玩家当前的拿取长按；其他位置和短按保持原行为。

在仓库根目录运行上方命令。离线测试覆盖时间排序与同时间决胜、区域隔离、脏盘/未完成/占用/已携带/其他世界的物品、距离和楼层、托盘容量、身份与按键重新验证、快速确认后的连续取餐、50 毫秒请求间隔、空闲检查限频、延迟确认、超时、取消、延迟安装 Hook、只识别具体成品、原生行刷新后的相邻布局、其他行布局保留、拿取提示缺失、父容器隐藏、侧边栏隔离、插入失败恢复、提示清理和语言切换。测试使用原创模拟对象，不使用导出的游戏代码。安装包采用明确白名单、统一源码换行和 SHA-256 校验文件，不会自动安装。

### 实机验收——待完成

- 在基线游戏和加载器上装备托盘，瞄准较新的菜品，确认先拿最早制作的，并持续按住装满可用菜品位；覆盖上下两层出餐架；确认空架和附近拿取点不触发功能。
- 在两个饮料台放置不同时间的成品和未灌满饮料，分别瞄准成品杯子，确认仅拿本区域成品、时间排序和饮料专用托盘位；台面本身和未灌满的饮料不触发功能。
- 检查短按、松键、移开视线、切换台面/托盘、满托盘、菜单、聊天、暂停、跨天、切场景和读档；取消后必须重新长按才能继续。
- 在房主和客机会话中与员工或其他玩家同时拿取，与 0.1.1-dev 对比连续取餐响应，检查服务器确认、延迟、无重复餐品和请求次数受限。
- 检查原生长按提示、键鼠/手柄切换、改键、14 种语言和常用分辨率；提示刷新后长按行仍紧接原生拿取行下方，无重复轮盘行、不在侧边栏显示，不在原生拿取提示缺失、取餐提示容器隐藏或瞄准无关物体时显示、菜单或切场景后正确清理与恢复。
- 验证与其他 Mod，尤其重做或替换餐品功能同时使用。正式验收前记录完整版本、联机身份、语言和实际结果。

离线结果不等于实机验收。构建和测试不操作游戏进程、安装文件及存档。GitHub Release 发布需要另外授权。
