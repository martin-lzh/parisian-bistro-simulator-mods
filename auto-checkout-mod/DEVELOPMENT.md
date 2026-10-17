# Auto Checkout development / 收银管家开发

[English](#english) · [中文](#中文)

## English

Player instructions: [README](README.md#english). **Current source: 0.1.4.** Recorded testing: [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-checkout-v0.1.4/releases/validation.md#english).

### Implementation

| Module | Responsibility |
| --- | --- |
| `Scripts/game.lua` | Reads host/register/payment state, verifies world, type and relationships, then submits the game's default interaction request |
| `Scripts/checkout.lua` | Maintains plain-Lua stages and retry history per register; a new payment object identity marks a new transaction (never price or a loop counter) |
| `Scripts/main.lua` | Starts automatically, listens for arrival notifications, polls each second on the game thread and handles world changes/errors |
| `Scripts/diagnostics.lua` | Records state changes and repeats unchanged state every 30 polls without retaining engine objects; logs pre-call state, call return and the immediate snapshot separately |
| `Scripts/ai.lua` | Suppresses new AI counter-checkout jobs in the host world and restores its changes on exit/error |
| `Scripts/localization.lua` | Resolves the game language and translates original explanatory log messages |
| `Scripts/reload.lua` | Validates and saves primitive AI recovery and retry records across Lua reloads |

**Transaction flow**

- Accepting payment and closing the drawer each wait for game-state confirmation. A returned RPC call is not treated as a successful payment.
- Card processing and existing employee ownership block dispatch.
- The scheduler keeps only strings and counters between polls, never Unreal objects. Immediately before dispatch it rereads the transaction and skips invalidated or manually changed targets.

**What blocks automation**

- Player activity, held items, interfaces and `IsInteracting()` do not block. Only an actual game pause and the transaction's own constraints do.
- A temporarily unreadable snapshot keeps its retry history.
- A request canceled by the final recheck keeps its cooldown but does not consume a sent-request attempt.

**Errors**

- Module loading, scheduler registration/callbacks and game-call errors are logged with the execution phase and any available Lua stack. Native process crashes cannot be caught from Lua.
- The older timer fallback queues at most one callback, so a pause or stall cannot pile up requests.

### Interaction scope and AI tasks

#### Interaction range (since 0.1.2)

During a verified host game-thread request, only for the synchronous call on the current target:

- `GetDistanceTo` supplies the player-to-target distance.
- The target temporarily uses `EDistanceReference.Actor`, a `DistanceToInteract` of at least distance + 100 game units, and `bCanInteractWhilePlacing`.
- Partial preparation failures roll back. After a normal return or a Lua error, each field is restored and verified independently.
- A payment object already destroyed by native collection is not written back.
- A restoration failure stops automation and asks for a world reload.
- Player position, controller, busy state and the target object are never retained or changed outside that call.

This stays a normal player interaction, not an employee task. Local references show AI checkout needs employee/entity context, while the player request rebuilds host interaction context; a player flag alone cannot switch between the two. Progress is confirmed through payment/card/bill state, not distance diagnostics.

#### AI job suppression

- Uses the current world's `JobSubsystem.EvaluatorsByJob` containers and removes only `BillingStartTaskEvaluator`. Table checkout, other task order and employee configuration are preserved.
- Before rebuilding an array with UE4SS on the game thread, it verifies the original reference is still held in `AllEvaluators`.
- Only identity strings and original positions persist across callbacks. Unchanged arrays are not rewritten; newly created containers are processed too.
- Already claimed tasks and register ownership flags stay intact.
- Restoration reinserts only tasks this Mod removed that have not already returned, keeping other runtime changes. Write failures attempt rollback; scheduler/restoration failures are logged.
- Nothing is written to the save. Lua reload uses the handoff below.

### Lua reload lifecycle

**Shared state.** `ModRef` keeps one namespaced, versioned string for the game process. It holds only session/payment/register identity strings, attempt counts and times, warning flags, and the AI evaluator identities/positions needed for restoration. A bounded length-prefixed parser validates the schema without `load`, JSON dependencies or shared UObject wrappers. Invalid or unsupported state stops startup and leaves the record untouched. The state is process-local; it is not a crash-recovery file or save extension.

**Save order.**

- The AI recovery plan is saved before each AI array mutation.
- The incremented attempt and cooldown are saved before each native request.
- If the shared-state write fails, that mutation or request is not performed.
- Completed scans and `ModRef.OnUnload` save the latest plain state.

**Unload.** Unload only disables the old callbacks and serializes Lua values. It never reads an engine object, calls gameplay functions or queues work into the closing Lua state. The experimental loader unregisters old hooks and removes scheduled actions during teardown; guards also make any retired callback inert.

**New instance.**

- Restores inherited AI records on the game thread first, then resumes the normal suppression policy.
- If a controller is temporarily unavailable, recovery waits with the records intact.
- A different live session lets records from the destroyed old world be discarded. Missing containers in the same session, or a restoration failure, keep the records and stop automation so a later reload can retry.
- Retry history survives whether the first callback is a notification or a poll, including while the controller is missing, and resets only when a different real session is observed. Three failed requests stay exhausted across reloads.

**Upgrade and removal.** Versions 0.1.3-dev and earlier have no handoff, so upgrade from them with the game closed. Permanent removal also requires closing the game: the unload callback cannot restore engine arrays when no new instance loads.

### Notification handling

- A post-hook on `CashRegister:Multicast_DisplayCustomerAtBillingNotification` leaves parameters and return values unchanged.
- The callback copies only the receiver's identity string, never a UObject or Context.
- Modern scheduling checks on the game thread after 50 ms; older scheduling uses the game-thread queue.
- Repeated notifications coalesce by register; notifications raised during dispatch are deferred to the next check.
- Each event batch rechecks host/world and reads only the referenced registers. Periodic polling still reads all registers and shares the same state machine, cooldown and attempt budget.
- The hook is installed only after polling registration succeeds. If registering, reading or queueing the hook fails, only the listener is disabled (with a warning) and polling continues. Actual checkout failures still stop automation.
- `EVENT` records the state at the later check, not at the instant of the notification. The hook may not cover every native call, so polling always stays on.

### Localization

- Each game-thread poll or event batch refreshes the language through `KismetInternationalizationLibrary:GetCurrentLanguage()`.
- Supported cultures: `en`, `fr`, `zh-Hans`, `it`, `es`, `de`, `ru`, `ja`, `ko`, `zh-Hant`, `tr`, `pl`, `pt`, `pt-BR`. Resolution accepts case, underscores and regional variants, prefers explicit Chinese scripts and distinguishes Brazilian Portuguese. Failed reads and unsupported values fall back to English.
- Six original message categories are translated: host activation, AI restoration failure, failure to schedule that restoration, automation stopped after an error, notification listener unavailable, and no progress after three attempts.
- Tags, field keys, phases/reasons, object identities and exception details stay stable. Messages before the first safe game-thread language read (early startup and listener-registration errors) are English.
- The game's payment UI, notifications and names are untouched; there is no language toggle and no copied game catalog.

All game-interface research, native analysis, type exports and research tools stay in the ignored `work/` folder. Tracked source contains no native addresses, memory offsets or game code.

### Diagnostic reference

Diagnostics are on by default in `UE4SS.log`, under `[AutoCheckout]`. Unchanged state repeats every 30 polls (about 30 seconds). Stack traces may continue on the following lines.

| Marker | Meaning |
| --- | --- |
| `START version=0.1.4` | Loaded version, scheduler and `player_guard=transaction-only` |
| `RELOAD` | Inherited AI recovery completed before resuming retained retry history |
| `HOOK installed event=customer-at-billing` | Notification listener registered |
| `EVENT customer-at-billing` | Deferred game-thread register state and number of coalesced notifications |
| `EVENT_IGNORED` | Not host, or the notified register is invalid/outside the current world |
| `API` / `HOST` | Resolved API enum values and host session |
| `STATE session` | Pause state, register count and cumulative dispatched requests |
| `STATE ai` / `AI` | Task policy and discovered/processed containers; `restored_containers` counts restorations. Suppression is confirmed only when `suppressed` is greater than 0 |
| `STATE phase=wait-...` / `unavailable=...` | Wait/exclusion reason, with bill, payment, drawer, card and ownership state |
| `REQUEST` | Stage, attempt, target and pre-call state; `source` distinguishes polling/notification. In `context`: `distance` = host-to-target distance, `range_before` = original range, `range_for_call` = temporary range, `scope=target-call` = restriction scope |
| `DISPATCH_RETURNED` / `AFTER` | Call return and immediate state. A later `STATE` may show delayed changes; a return alone is not success |
| `SKIP` | Final recheck found a change; no request sent and no attempt consumed |
| `WARN` / `ERROR` | Repeated lack of progress or a stopping exception, with phase, last state and available Lua stack |

After updating, check the `START` version, then review `STATE ai`, `REQUEST`, `SKIP`, `AFTER` and the stack after any `ERROR`. Current code never emits `blocked=player-interacting`. Reload the world if interaction-range or AI task restoration fails.

### Offline checks and packaging

From the source repository root:

```powershell
uv run --with lupa==2.6 python auto-checkout-mod/tests/run.py
python auto-checkout-mod/build.py
python tools/check_repository.py
git diff --check
```

The suite has 68 offline tests plus 12 reload tests, run on Lua 5.4 with substitute game objects:

- **Checkout:** cash/card stages, animation waits, deduplication, bounded retries, unsent-attempt accounting, employee ownership, world/type/object validity, player activity, manual completion, multiple registers, world resets, automatic startup, both scheduling APIs, diagnostic throttling and stop-on-error.
- **Notifications:** coalescing, deferred reads, target selection, early notifications, shared budget, client/old-world filters, listener fallback and notifications during dispatch.
- **AI:** selective removal, reference/order preservation, late containers, repeated scans, rollback, failed restoration and host lifecycle.
- **Distance:** both payment stages, movement between stages, preserving original restrictions, request/diagnostic errors, partial preparation, independent restoration after a failed field, destroyed payments and invalid distances.
- **Localization:** all cultures and messages, aliases, failed language reads, live switches, missing-language fallback and stable diagnostic fields.
- **Reload:** both schedulers, retired callbacks, AI recovery/reapplication, failed or missing recovery, retry budgets for both stages, world/controller changes, pre-dispatch persistence, storage failure and malformed payloads.

Loader teardown, real hook delivery and engine behaviour are covered by the in-game checklist below.

The fixed allowlist produces `outputs/auto-checkout/AutoCheckout-0.1.4.zip` and its SHA-256 file. The package holds the original Lua, README, DEVELOPMENT, CHANGELOG, LICENSE and `enabled.txt`, with no tests, development tools, loader or game material. The loading marker is `START version=0.1.4` with `player_guard=transaction-only`.

### Earlier investigation and acceptance

- **2026-09-23, 0.1.0-dev:** a log from another computer showed loading and host recognition, but customers stayed at the counter and sometimes flickered, with no exception, exhausted retry or scheduling failure. 0.1.1-dev expanded diagnostics to close that gap.
- **2026-09-24, player guard:** cash and card logs showed `phase=wait-player-interacting`, `blocked=player-interacting` and `dispatched=0` while the player was not checking out and AI was working at the bar. The old player guard was blocking dispatch. The fix removed that guard, suppressed new AI checkout jobs and cancels requests overtaken by manual action.
- **Distance limits:** later hot-reload logs showed one cash transaction advancing immediately while other repeated calls returned without progress, sometimes exhausting three attempts (no card transaction in that sample). Local references identified native host-distance and furniture-placement restrictions; 0.1.2-dev addressed both and added distance diagnostics.
- **2026-09-24, 0.1.1:** the user confirmed 0.1.1-dev in-game; 0.1.1 kept that runtime logic and changed only the diagnostic version.
- **2026-09-24, 0.1.2:** the user confirmed 0.1.2-dev through 01:40:22. Three cash and two card transactions completed both payment and drawer steps on the first attempt, with no new errors or retry failures. Drawer-close distances were about 1341 (cash) and 796 (card), beyond the original range of 200, followed by a cleared bill and closed drawer. Runtime code corresponds to `61dd9c3`; 0.1.2 kept that implementation.
- **2026-09-26, 0.1.4:** in-game and multiplayer testing passed (see the validation record above).

### In-game regression checklist

Record game/loader versions, language, role and any manual intervention. Compare `REQUEST context` with `AFTER`, the bill and income.

1. In single player, let a finished customer reach the counter. Confirm automatic payment and departure, while seated and dining customers are unaffected.
2. Test cash and cards, prompts and drawer animation. Bills, tips, sales and income are each counted once.
3. Serve at least ten groups, including adjacent equal-price bills, multiple registers and rooftop counters.
4. Manually accept payment or close a drawer first. Stale requests skip, nobody is charged twice, and a destroyed/completed target does not disable the whole Mod.
5. Hold items, make drinks, open the tablet/chat and place furniture. The player's activity stays intact and automation continues; an actual pause waits and resumes.
6. Enter directly after installation, and again after a restart, with no key/toggle action. The first customer is handled automatically.
7. Return to the menu, switch saves and rejoin. Check old-world filtering, long-session logs and polling overhead.
8. Test host-only installation and installation on both host and client, then reconnect. Only the host acts and transactions synchronize.
9. Cause an unaccepted request. Retries are bounded, logs stay readable and manual completion still works.
10. Check notification `EVENT`, `source=notification` and later state against the correct register. Test missing/early notifications, listener failure, old-world and client notifications; periodic checks keep working.
11. `STATE ai` finds containers with `suppressed` greater than zero. AI stops accepting new counter jobs while still making drinks and doing other work; existing jobs finish. Check other floors, new employees, save switching and error restoration, with employee configuration unchanged.
12. Switch all 14 game languages after startup. Check the six translated message categories, unchanged technical fields and native notifications, including both Chinese scripts and both Portuguese cultures. English at startup is expected and is not a failed language switch.
13. Reload repeatedly while waiting for cash, during card processing, with an open drawer and with an exhausted retry budget. Check there is exactly one live listener/poller, cooldowns and attempt counts are unchanged, AI jobs are restored then reapplied, and test world travel and recovery failure.

Repeat the relevant checks after game or loader interface changes.

### Runtime compatibility and retry timing

- **Current version:** 0.1.4.
- **Supported game:** up to Steam Build 25822788 / 1.0.2.44eb.
- **Development reference build:** Windows, Steam Build 25393699 / ProjectVersion 1.0.0.44eb, Unreal Engine 5.4.
- **UE4SS:** experimental `v3.0.1-1140-gf58e8f84`. Old stable UE4SS 3.0.1 is not supported.

Retry timing: within each transaction stage, sent requests are at least three seconds apart and limited to three attempts. Exhaustion stops only that stage; later transactions still proceed. Polling covers every register in the current world, including other floors, even without an arrival notification.

### Manual script reload

Close the game for the first upgrade from 0.1.3-dev or earlier. Once 0.1.4 is running:

1. Set up the loader with the [shared reload configuration](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-checkout-v0.1.4/docs/hot-reload.md#english).
2. Replace the complete Lua package.
3. Press **Ctrl+R** or use the loader's Reload Mods action.
4. Check the new `START` version and review `RELOAD` and `ERROR` entries (see the diagnostic reference above).

Reload needs the experimental loader's `ModRef` shared-variable and unload support. Retry history, AI recovery and removal rules are described in the reload lifecycle section above. Restart the game if the shared state is damaged or uses an unsupported future format.

## 中文

玩家说明见 [README](README.md#中文)。**当前源码：0.1.4。** 测试记录见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-checkout-v0.1.4/releases/validation.md#中文)。

### 实现

| 模块 | 职责 |
| --- | --- |
| `Scripts/game.lua` | 通过 UE4SS 读取房主、收银机及付款状态，核对同一世界、对象类型和关联关系，再发起游戏默认交互请求 |
| `Scripts/checkout.lua` | 用普通 Lua 数据维护每台收银机的处理阶段和重试记录；以新的付款物件身份区分新交易，不用金额或循环计数器去重 |
| `Scripts/main.lua` | 加载后自动运行，监听顾客到达通知，在游戏线程每秒检查一次，处理世界切换和异常停用 |
| `Scripts/diagnostics.lua` | 记录状态变化，状态不变时每 30 次轮询复述一次，不持有游戏对象；请求前状态、调用返回和即时快照分别记录 |
| `Scripts/ai.lua` | 在房主世界中排除 AI 新的柜台收银任务，离开会话或异常时恢复本 Mod 的改动 |
| `Scripts/localization.lua` | 识别游戏语言并翻译原创说明日志 |
| `Scripts/reload.lua` | 在 Lua 重载之间校验并保存普通值形式的 AI 恢复记录和重试记录 |

**交易流程**

- 收款和关闭钱柜各自等待游戏状态确认，不把 RPC 调用返回当作付款成功。
- 刷卡尚未完成或已被员工认领时不发起请求。
- 调度在轮询之间只保留字符串与计数，不保存 Unreal 对象。实际请求前再次读取交易，跳过已失效或被手动操作改变的目标。

**阻塞条件**

- `IsInteracting()`、手持物品、操作界面和其他玩家动作都不阻塞，只有游戏实际暂停和交易自身的约束会让 Mod 等待。
- 某台收银机快照暂时无法读取时，保留其重试记录。
- 最后复查取消的请求保留冷却时间，但不消耗已发送请求的次数。

**异常**

- 模块加载、调度注册与回调、游戏调用的异常都会写入带执行阶段和 Lua 堆栈的错误日志；Lua 无法捕获原生进程崩溃。
- 旧计时接口回退最多只排队一个回调，暂停或卡顿时不会积压请求。

### 交互范围与 AI 任务

#### 交互范围（自 0.1.2 起）

在已确认的房主游戏线程请求中，仅对当前目标的这一次同步调用：

- 用 `GetDistanceTo` 获取角色到目标的距离。
- 临时使用 `EDistanceReference.Actor`，将 `DistanceToInteract` 扩大到至少“距离 + 100 游戏单位”，并启用 `bCanInteractWhilePlacing`。
- 准备中途失败时回滚已改动的部分；调用正常返回或抛出 Lua 异常后，逐项恢复并校验。
- 已被原生收款销毁的付款对象不再回写。
- 恢复失败时停止自动流程，并提示重新载入世界。
- 调用之外不保留、不改动玩家位置、控制器、忙碌状态或目标对象。

这里仍是普通玩家交互，不是员工任务。本机参考显示，AI 收银需要员工任务和实体上下文，玩家请求则会重建房主交互上下文，仅改一个玩家标记无法切换路径。进展以付款物件、刷卡和账单状态确认，而不是距离诊断。

#### AI 任务排除

- 通过当前世界的 `JobSubsystem.EvaluatorsByJob` 定位任务容器，只移除 `BillingStartTaskEvaluator`；保留餐桌结账、其他任务顺序和员工配置。
- 在游戏线程用 UE4SS 数组接口重建前，先核对原任务引用仍由 `AllEvaluators` 持有。
- 跨回调只保存身份字符串和原位置。未变化的数组不重写；之后新建的容器也会处理。
- 已领取的任务和收银机占用标记保持不变。
- 恢复时只插回本 Mod 移除且尚未恢复的任务，保留其他运行时改动。写入失败尝试回滚；调度或恢复失败会记录日志。
- 不写入存档。Lua 重载使用下述状态交接。

### Lua 热重载生命周期

**共享状态。** `ModRef` 在当前游戏进程中保留一个带独立名称和格式版本的字符串，只含会话、付款物件与收银机身份、尝试次数与时间、告警标志，以及恢复 AI 所需的任务身份和位置。解析器使用有界长度前缀并校验结构，不使用 `load`、外部 JSON 依赖或共享 UObject。记录损坏或格式不受支持时停止加载，并保留原记录。交接只存在于当前进程，不是崩溃恢复文件，也不是存档数据。

**保存顺序。**

- 每次改写 AI 数组前，先保存恢复方案。
- 每次原生请求前，先保存已增加的次数和冷却时间。
- 共享状态写入失败时，不执行该次数组改写或请求。
- 扫描完成及 `ModRef.OnUnload` 时保存最新普通值。

**卸载。** 卸载只停用旧回调并序列化 Lua 数据，不访问引擎对象、不调用游戏函数，也不向即将关闭的 Lua 状态排队。实验版加载器卸载时会注销旧 Hook 并移除计划动作；脚本也会让残留的旧回调直接返回。

**新实例。**

- 先在游戏线程恢复继承的 AI 记录，再重新应用正常的任务策略。
- 控制器暂时不可用时，保留记录等待。
- 确认进入不同的会话后，可丢弃已销毁旧世界的记录；同一会话中容器缺失或恢复失败时，保留记录并停止自动流程，留待下次重载重试。
- 无论第一次回调来自通知还是轮询，包括控制器暂时缺失时，都保留原交易的次数和冷却；确认进入不同的真实会话后才重置。已耗尽的三次尝试不会因重载重新获得。

**升级与卸载。** 0.1.3-dev 及更早版本没有交接记录，从这些版本升级时须关闭游戏。永久卸载也须关闭游戏：没有新实例加载时，卸载回调无法恢复引擎数组。

### 顾客提醒

- 对 `CashRegister:Multicast_DisplayCustomerAtBillingNotification` 使用后置 Hook，不修改参数或返回值。
- 回调只复制接收对象的身份字符串，不保留 UObject 或 Context。
- 现代调度接口延迟 50 毫秒后在游戏线程检查，旧接口使用游戏线程队列。
- 重复提醒按收银机合并；派发过程中产生的新提醒排到下一次检查。
- 每批事件重新确认房主及当前世界，只读取相关收银机。定时轮询仍检查全部收银机，并共用同一状态机、冷却和尝试次数。
- 监听在定时任务注册成功后才安装。监听注册、身份读取或事件排队失败时只停用监听并发出警告，定时检查照常进行；实际结账流程的异常仍会停止自动操作。
- `EVENT` 记录的是延后检查时的状态，而非通知发出瞬间的快照。Hook 未必覆盖全部原生调用，因此定时检查始终保留。

### 多语言适配

- 每次游戏线程轮询或事件批次通过 `KismetInternationalizationLibrary:GetCurrentLanguage()` 更新语言。
- 支持 `en`、`fr`、`zh-Hans`、`it`、`es`、`de`、`ru`、`ja`、`ko`、`zh-Hant`、`tr`、`pl`、`pt`、`pt-BR`。兼容大小写、下划线和地区变体，显式中文书写系统优先，巴西葡萄牙语单独识别；读取失败或不支持时回退英语。
- 翻译六类原创说明：房主自动结账启用、AI 任务恢复失败、无法安排恢复、异常后停止、提醒监听不可用、三次无进展。
- 事件标记、字段名、阶段与原因标识、对象身份及异常详情保持不变。首次安全读取游戏语言之前的消息（启动初期和监听注册错误）使用英语。
- 游戏付款界面、通知和名称保持原样，不提供语言开关，也不复制游戏翻译目录。

所有游戏接口研究、原生代码分析、类型导出和研究工具都放在被忽略的 `work/`。可跟踪代码不含原生地址、内存偏移或游戏代码。

### 诊断标记

默认写入 `UE4SS.log` 的 `[AutoCheckout]` 条目。状态变化时输出，不变时每 30 次轮询（约 30 秒）复述一次。异常堆栈可能占后续多行。

| 日志标记 | 含义 |
| --- | --- |
| `START version=0.1.4` | 已加载，并显示调度方式及 `player_guard=transaction-only` |
| `RELOAD` | 已恢复旧实例的 AI 变更，并继续沿用保留的重试记录 |
| `HOOK installed event=customer-at-billing` | 提醒监听注册成功 |
| `EVENT customer-at-billing` | 延后在游戏线程检查时的收银机状态和合并的提醒次数 |
| `EVENT_IGNORED` | 当前不是房主，或收银机已失效、不属于当前世界 |
| `API` / `HOST` | 解析出的接口枚举值与当前房主会话 |
| `STATE session` | 暂停状态、收银机数量和累计发起请求次数 |
| `STATE ai` / `AI` | AI 策略及发现、处理的容器数量，`restored_containers` 为恢复数量；`suppressed` 大于 0 才表示已排除收银任务 |
| `STATE phase=wait-...` / `unavailable=...` | 等待或排除原因，附账单、付款物件、钱柜、刷卡及占用状态 |
| `REQUEST` | 调用前的阶段、次数、目标和状态；`source` 区分提醒与轮询。`context` 中 `distance` 为房主到目标的距离，`range_before` 为原范围，`range_for_call` 为临时范围，`scope=target-call` 表示只影响本次调用 |
| `DISPATCH_RETURNED` / `AFTER` | 调用返回及即时状态；后续 `STATE` 可能显示延迟变化，仅有返回不代表成功 |
| `SKIP` | 最后复查发现变化，未发送请求，也不消耗次数 |
| `WARN` / `ERROR` | 多次无进展或异常停止，附阶段、最近状态及可用 Lua 堆栈 |

更新后先核对 `START` 版本，再查看 `STATE ai`、`REQUEST`、`SKIP`、`AFTER` 以及 `ERROR` 后的堆栈。当前代码不会输出 `blocked=player-interacting`。交互范围或 AI 任务恢复失败时，重新载入世界。

### 离线检查与打包

在仓库根目录执行：

```powershell
uv run --with lupa==2.6 python auto-checkout-mod/tests/run.py
python auto-checkout-mod/build.py
python tools/check_repository.py
git diff --check
```

共 68 项离线测试和 12 项重载测试，使用 Lua 5.4 和替代游戏对象运行：

- **结账：**现金和刷卡阶段、动画等待、去重、重试上限、未发送请求的计数、员工占用、世界／类型／对象有效性、玩家动作、手动完成、多台收银机、读档重置、自动启动、两种调度接口、诊断节流和异常停用。
- **提醒：**合并、延后读取、定位目标收银机、早于付款就绪的提醒、共用次数、客户端及旧世界过滤、监听失败回退和派发中的新提醒。
- **AI：**定向移除、引用与顺序保留、迟到的容器、重复扫描、回滚、恢复失败和房主生命周期。
- **距离：**两个付款阶段、两步之间玩家移动、保留原有限制、请求与诊断异常、部分准备失败、单项恢复失败后继续恢复其他项、付款物件销毁和无效距离。
- **多语言：**全部语言与消息、别名、读取失败、运行中切换、缺失语言回退和稳定的诊断字段。
- **重载：**两种调度接口、旧回调失效、AI 恢复后重新应用、恢复失败与容器缺失、两个阶段的次数保留、世界与控制器变化、请求前保存、共享写入失败和异常载荷。

加载器实际卸载、Hook 是否真实触发以及引擎行为，由下方游戏内清单覆盖。

打包使用固定文件白名单，生成 `outputs/auto-checkout/AutoCheckout-0.1.4.zip` 及其 SHA-256 文件。包内含原创 Lua、README、DEVELOPMENT、CHANGELOG、LICENSE 和 `enabled.txt`，不含测试、开发工具、加载器或游戏资料。加载标记为 `START version=0.1.4`，并带 `player_guard=transaction-only`。

### 早期排查与验收

- **2026-09-23，0.1.0-dev：**另一台电脑的日志显示已加载并识别房主，但顾客停在柜台、偶有闪动，没有异常、重试耗尽或调度失败日志。0.1.1-dev 为此补充了诊断。
- **2026-09-24，玩家检查：**现金与刷卡日志均出现 `phase=wait-player-interacting`、`blocked=player-interacting` 和 `dispatched=0`，当时玩家未在收银，AI 在吧台工作，说明旧的玩家检查阻止了请求。随后移除该检查、排除 AI 新的收银任务，并在玩家抢先操作时取消当次请求。
- **距离限制：**之后的热重载日志中，一笔现金交易立即推进，其他交易的相同请求多次返回而状态不变，有的耗尽三次尝试（该批日志没有刷卡交易）。本机参考确认原生校验存在房主距离限制和摆放家具限制；0.1.2-dev 修复了这两项并补充距离诊断。
- **2026-09-24，0.1.1：**用户确认 0.1.1-dev 实机正常；0.1.1 保留该运行逻辑，只更新诊断版本。
- **2026-09-24，0.1.2：**用户确认 0.1.2-dev 截至 01:40:22 完成 3 笔现金、2 笔刷卡，收款和钱柜两步均首次成功，没有新异常或重试失败。现金和刷卡关钱柜时距离分别约 1341 和 796，超过原范围 200，随后账单清空、钱柜关闭。运行代码对应提交 `61dd9c3`，0.1.2 保留该实现。
- **2026-09-26，0.1.4：**实机及联机测试通过（见上方验收记录）。

### 游戏内回归清单

记录游戏和加载器版本、语言、房主／客机身份以及是否手动介入；对照 `REQUEST context` 与紧接的 `AFTER`，并核对账单和收入。

1. 单人进入餐厅，让用餐完毕的顾客到达柜台，确认无需点击即可结账、正常离店；入座和用餐中的顾客不受影响。
2. 分别测试现金和银行卡、提示及钱柜动作；账单、小费、销售记录和收入每笔只计一次。
3. 连续接待至少十组顾客，包含金额相同的相邻账单、多台收银机和屋顶柜台。
4. 玩家抢先收款或关钱柜，确认旧请求被跳过、无重复收款；付款物件销毁或交易已完成不会让整个 Mod 停用。
5. 手持物品、制作饮料、打开平板／聊天、摆放家具，确认玩家当前操作不受影响、自动结账继续；游戏实际暂停时等待，恢复后继续。
6. 安装后直接进入餐厅，以及重启游戏后，不做任何按键或开关操作，首位顾客应自动结账。
7. 返回主菜单、切换存档、重新加入，确认不会操作旧世界的收银机，并检查长时间游玩的日志和轮询开销。
8. 分别测试仅房主安装和双方都安装，再断线重连；只有房主执行，交易正常同步。
9. 故意让某次请求不被游戏接受，确认重试有上限、日志可读，仍能手动完成结账。
10. 对照 `EVENT`、`source=notification` 及后续状态，确认对应正确的收银机。测试没有提醒、提醒早于付款就绪、监听失败、旧世界和客户端提醒；定时检查应始终可用。
11. `STATE ai` 发现任务容器且 `suppressed` 大于零；AI 不再领取新的柜台收银任务，仍制作饮料和做其他工作，已领取的任务能完成。检查其他楼层、新雇员工、切换存档和异常后的恢复，员工配置不变。
12. 启动后切换全部 14 种游戏语言，核对六类翻译说明、不变的技术字段和原生通知，包括简繁中文和两种葡萄牙语。启动初期为英语属于正常，不是语言切换失败。
13. 在等待现金、刷卡处理中、钱柜打开和重试已耗尽时连续热重载，确认只有一组有效的监听／轮询、冷却和次数不重置、员工任务先恢复再应用，并测试切换世界和恢复失败。

游戏或加载器接口变化后，重复相关检查。

### 运行兼容性与重试时序

- **当前版本：**0.1.4。
- **支持游戏：**至 Steam Build 25822788 / 1.0.2.44eb。
- **开发参考版本：**Windows、Steam Build 25393699 / ProjectVersion 1.0.0.44eb、Unreal Engine 5.4。
- **UE4SS：**experimental `v3.0.1-1140-gf58e8f84`；不支持旧稳定版 UE4SS 3.0.1。

重试时序：同一交易阶段发送请求至少间隔 3 秒，最多尝试 3 次；耗尽后只停止该阶段，后续交易照常处理。即使没有收到顾客到达通知，也会轮询当前世界的全部收银机，包括其他楼层。

### 手动脚本重载

首次从 0.1.3-dev 或更早版本升级时须关闭游戏。0.1.4 运行后：

1. 按[统一重载配置](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-checkout-v0.1.4/docs/hot-reload.md#中文)设置加载器。
2. 完整替换 Lua 安装包。
3. 按 **Ctrl+R** 或使用加载器的 Reload Mods。
4. 核对新的 `START` 版本，并按上方诊断标记检查 `RELOAD` 和 `ERROR`。

重载需要实验版加载器的 `ModRef` 共享变量及卸载支持。重试记录、AI 恢复和卸载要求见上方热重载生命周期章节；共享状态损坏或来自不支持的未来格式时，请重启游戏。
