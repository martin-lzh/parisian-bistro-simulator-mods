# Development and validation / 开发与验收

[English](#english) · [中文](#中文)

## English

Player instructions: [README](README.md#english). **Current source: 0.1.4-dev.** The user reported completion of in-game testing on 2026-09-26; see the [validation record](../releases/validation.md#english) for its scope. Individual checklist results were not reported separately. The 0.1.2 cash/card/distance confirmation applies to the earlier runtime version; its scope is preserved below.

### Implementation

| Module | Responsibility |
| --- | --- |
| `Scripts/game.lua` | Reads host/register/payment state, verifies world, type and relationships, then submits the game's default interaction request |
| `Scripts/checkout.lua` | Maintains plain-Lua stages and retry history per register, using payment object identity to distinguish transactions |
| `Scripts/main.lua` | Starts automatically, listens for arrival notifications, polls each second on the game thread and handles world changes/errors |
| `Scripts/diagnostics.lua` | Records state changes and repeats unchanged state every 30 polls without retaining engine objects |
| `Scripts/ai.lua` | Suppresses new AI counter-checkout jobs in the host world and restores its changes on exit/error |
| `Scripts/localization.lua` | Resolves the game language and translates original explanatory log messages |
| `Scripts/reload.lua` | Validates and saves primitive AI recovery and retry records across Lua reloads |

Accepting payment and closing the drawer each wait for game-state confirmation. Card processing and existing employee ownership block dispatch. The scheduler retains strings and counters, not Unreal objects across polls. Immediately before dispatch, it rereads the transaction to reject invalidated or manually changed targets. A returned RPC call is not evidence that the payment succeeded.

Player activity, held items, interfaces and `IsInteracting()` do not block automation. Actual game pause and transaction constraints still do. Temporarily unreadable snapshots retain retry history. A canceled request preserves cooldown but does not consume a sent-request attempt. Module loading, scheduler registration/callbacks and game-call errors are logged with execution phase and available Lua stacks; Lua exception handling cannot catch a native process crash. The older timer fallback queues at most one callback so a pause or stall cannot accumulate requests.

### Interaction scope and AI tasks

The 0.1.2 distance fix remains in use. During a verified host game-thread request, `GetDistanceTo` supplies the player-to-target distance. Only for the synchronous call, the target uses `EDistanceReference.Actor`, a `DistanceToInteract` of at least distance plus 100 game units, and `bCanInteractWhilePlacing`. Preparation failures roll back partial changes, and normal return or Lua errors restore each field independently with verification. A payment object destroyed by native collection is not written back. Restoration failure stops automation and asks for a world reload. No player position, controller, busy state or target object is retained or changed outside that call.

This remains a normal player interaction, not an employee task. Local references established that AI checkout requires employee/entity context while the player request rebuilds host interaction context; changing a player flag alone cannot substitute one path for the other. Distance diagnostics describe the call, but progress is still confirmed through payment/card/bill state.

AI suppression uses the current world's `JobSubsystem.EvaluatorsByJob` containers and removes only `BillingStartTaskEvaluator`, preserving table checkout, other task order and employee configuration. It verifies the original reference remains in `AllEvaluators` before rebuilding the array with UE4SS on the game thread. Only identity strings and original positions persist across callbacks. Unchanged arrays are not rewritten; newly appearing containers are processed too.

Already claimed tasks and register ownership flags remain intact. Restoration reinserts only tasks removed by this Mod that have not already returned, retaining other runtime changes. Write failures attempt rollback. Scheduler/restoration failures are logged. This policy writes no save state. Lua reload uses the handoff described below. All-floor coverage and error recovery remain on the in-game checklist.

### Lua reload lifecycle

`ModRef` keeps one namespaced, versioned string for this game process. It contains only session/payment/register identity strings, attempt counts and times, warning flags, and the AI evaluator identities/positions needed for restoration. The bounded length-prefixed parser validates the schema without `load`, JSON dependencies or shared UObject wrappers. Invalid or unsupported state stops startup without overwriting the record.

Before each AI array mutation, the script saves its recovery plan. It also saves the incremented attempt and cooldown before sending a native request. A failed shared-state write therefore prevents that mutation or request. Completed scans and `ModRef.OnUnload` save the latest plain state. Unload only disables the old callbacks and serializes Lua values; it never reads an engine object, calls gameplay functions, or queues work into a closing Lua state. The checked experimental loader unregisters the old hooks and removes its scheduled actions during teardown; guards also make retired callbacks inert.

The new instance first restores inherited AI records on the game thread, then resumes its normal suppression policy. When a controller is temporarily unavailable, recovery waits with its records intact. A different live session allows destroyed old-world records to be discarded; missing containers in the same session and restoration failures preserve the records and stop automation so a later reload can retry. Retry history survives both notification-driven and periodic first callbacks, including a temporarily missing controller, and resets when a different real session is observed. Three failed requests stay exhausted across reloads. Old versions lacking a handoff cannot supply their lost AI records, so upgrade from 0.1.3-dev or earlier with the game closed. Permanent removal also requires closing the game; unloading without a replacement cannot restore engine arrays from the unload callback. Shared state is process-local and is not a crash-recovery file or save extension.

The original 68 offline tests and 12 reload tests pass. Reload coverage includes both schedulers, retired callbacks, AI recovery/reapplication, failed or missing recovery, retry budgets for both stages, world/controller changes, pre-dispatch persistence, storage failure and malformed payloads. Loader teardown and actual engine behavior still require in-game testing.

### Notification handling

A post-hook on `CashRegister:Multicast_DisplayCustomerAtBillingNotification` leaves parameters and return values unchanged. The callback copies only the receiver's identity string, never a UObject or Context. Modern scheduling checks on the game thread after 50 ms; older scheduling uses the game-thread queue. Repeated notifications coalesce by register, with notifications raised during dispatch deferred to the next check.

Each event batch verifies host/world again and reads only the referenced registers. Periodic polling still reads all registers and shares the same state machine, cooldown and attempt budget. Registering, reading or queueing the notification hook can fail without disabling polling; actual checkout failures still stop automation. The hook is installed only after polling registration succeeds. `EVENT` records the later check's state, not a snapshot from the instant the notification was emitted, and the hook may not cover all native calls.

### Localization

On each game-thread poll or event batch, `KismetInternationalizationLibrary:GetCurrentLanguage()` refreshes the language. The 14 supported cultures are `en`, `fr`, `zh-Hans`, `it`, `es`, `de`, `ru`, `ja`, `ko`, `zh-Hant`, `tr`, `pl`, `pt` and `pt-BR`. Resolution accepts case, underscores and regional variants, gives explicit Chinese scripts priority, and distinguishes Brazilian Portuguese. Failed reads and unsupported values fall back to English.

Six original message categories are translated: host activation, AI restoration failure, failure to schedule that restoration, automation stopped after an error, unavailable notification listener, and no progress after three attempts. Tags, field keys, phases/reasons, object identities and exception details stay stable. Messages before the first safe game-thread language read, including early startup/listener-registration errors, remain English. The game's existing payment UI, notifications and names are untouched, with no custom language toggle or copied game catalogs.

All game-interface research, native analysis, type exports, tools and research scripts remain in ignored `work/`. Tracked source contains no native addresses, memory offsets or copies of game code.

### Diagnostic reference

Diagnostics are on by default in `UE4SS.log`, under `[AutoCheckout]`. Unchanged state repeats every 30 polls, usually about 30 seconds. Stack traces may continue on subsequent lines.

| Marker | Meaning |
| --- | --- |
| `START version=0.1.4-dev` | Loaded version, scheduler and `player_guard=transaction-only` |
| `RELOAD` | Inherited AI recovery completed before resuming retained retry history |
| `HOOK installed event=customer-at-billing` | Notification listener registered |
| `EVENT customer-at-billing` | Deferred game-thread register state and number of coalesced notifications |
| `EVENT_IGNORED` | Not host, or the notified register is invalid/outside the current world |
| `API` / `HOST` | Resolved API enum values and host session |
| `STATE session` | Pause state, register count and cumulative dispatched requests |
| `STATE ai` / `AI` | Task policy and discovered/processed containers; `restored_containers` counts restorations. `suppressed=0` does not demonstrate suppression |
| `STATE phase=wait-...` / `unavailable=...` | Wait/exclusion reason, with bill, payment, drawer, card and ownership state |
| `REQUEST` | Stage, attempt, target and pre-call state; `source` distinguishes polling/notification. In `context`, `distance` is host-to-target distance, `range_before` the original range, `range_for_call` the temporary range, and `scope=target-call` the restriction scope |
| `DISPATCH_RETURNED` / `AFTER` | Call return and immediate state. Later `STATE` may show delayed changes; return alone is not success |
| `SKIP` | Final recheck changed, no request sent and no attempt consumed |
| `WARN` / `ERROR` | Repeated lack of progress or a stopping exception, with phase, last state and available Lua stack |

After updating, verify the current `START` version and review `STATE ai`, `REQUEST`, `SKIP`, `AFTER` and the stack after `ERROR`. Current code does not emit `blocked=player-interacting`. Reload the world if interaction restrictions or AI task restoration fails.

### Offline checks and packaging

From the source repository root:

```powershell
uv run --with lupa==2.6 python auto-checkout-mod/tests/run.py
python auto-checkout-mod/build.py
python tools/check_repository.py
git diff --check
```

Lua 5.4 tests cover cash/card stages, animation waits, deduplication, bounded retries, unsent-attempt accounting, employee ownership, world/type/object validity, player activity, manual completion, multiple registers, world resets, automatic startup, both scheduling APIs, diagnostic throttling and stop-on-error behavior. Notification tests cover coalescing, deferred reads, target selection, early notifications, shared budget, client/old-world filters, listener fallback and notifications during dispatch. AI tests cover selective removal, reference/order preservation, late containers, repeated scans, rollback, failed restoration and host lifecycle.

The distance tests cover both payment stages, movement between stages, preserving original restrictions, request/diagnostic errors, partial preparation, independent restoration after a failed field, destroyed payments and invalid distances. Localization tests check all cultures and messages, aliases, failed language reads, live switches, missing-language fallback and stable diagnostic fields. Substitute objects cannot establish real engine bridging, actual hook delivery or gameplay results.

The fixed allowlist produces `outputs/auto-checkout/AutoCheckout-0.1.4-dev.zip` and its SHA-256 file. It includes original Lua, README, DEVELOPMENT, CHANGELOG and `enabled.txt`, with no tests, development tools, loader or game material. Builds neither write to the game directory nor operate saves or the game process. The loading marker is `START version=0.1.4-dev` with `player_guard=transaction-only`.

### Earlier investigation and acceptance

On 2026-09-23, another computer's 0.1.0-dev log showed loading and host recognition, but customers stayed at the counter and sometimes flickered. No exception, exhausted retry or scheduling failure was reported. This did not establish that requests had been sent or that the Mod caused flickering. Version 0.1.1-dev expanded diagnostics to investigate that gap.

On 2026-09-24, cash and card logs showed `phase=wait-player-interacting`, `blocked=player-interacting` and `dispatched=0` while the user reported no player checkout and AI work at the bar. That established that the old player guard blocked dispatch, not that AI had changed player state. The subsequent changes removed that guard and suppressed new AI checkout jobs, while canceling requests overtaken by manual action.

Later hot-reload logs showed one cash transaction advancing immediately and other repeated calls returning without progress, sometimes exhausting three attempts. Delayed state changes could not be attributed to the Mod, and no card transaction was present in that sample. Local references identified native host-distance and furniture-placement restrictions. Those logs lacked player position, so rejection causes could not be assigned per transaction; 0.1.2-dev addressed the confirmed restrictions and added distance diagnostics.

The user confirmed 0.1.1-dev in-game and requested 0.1.1 on 2026-09-24, retaining runtime logic and changing the diagnostic version. Full environment versions, multiplayer role and duration were not enumerated.

Also on 2026-09-24, the user confirmed 0.1.2-dev through 01:40:22: three cash and two card transactions completed both payment and drawer steps on the first attempt, without new errors or retry failures. Drawer-close distances were approximately 1341 for cash and 796 for card, exceeding the original range of 200, followed by a cleared bill and closed drawer. Runtime code corresponds to `61dd9c3`; the requested 0.1.2 release retained that implementation and updated version, package and documentation. Furniture placement, floors, multiplayer, manual intervention and long sessions were not individually confirmed. The 0.1.4-dev hot-reload behavior and localization have no in-game acceptance yet.

### In-game regression checklist

Reload repeatedly while waiting for cash, card processing, an open drawer, and an exhausted retry budget. Check one live notification listener/poller, unchanged cooldowns and attempt counts, restored/reapplied AI jobs, then world travel and recovery failure. These reload scenarios have not yet been accepted in-game.

These are pending scenarios, not completed test claims. Record actual game/loader versions, language, role and any manual intervention; compare `REQUEST context` with `AFTER`, bill and income.

1. In single player, let a finished customer reach the counter. Confirm automatic payment/departure while seated and dining customers remain unaffected.
2. Test cash and cards, prompts and drawer animation; verify bills, tips, sales and income are counted once.
3. Serve at least ten groups, including adjacent equal-price bills, multiple registers and rooftop counters.
4. Manually accept payment or close a drawer first. Confirm stale requests skip, no double charge occurs, and a destroyed/completed target does not disable the whole Mod.
5. Hold items, make drinks, open the tablet/chat and place furniture. Check the player's activity remains intact and automation continues; actual pause should wait and resume.
6. Enter directly after installation and after a restart with no key/toggle action; the first customer should be handled automatically.
7. Return to the menu, switch saves and rejoin; check old-world filtering, extended logs and polling overhead.
8. Test host-only installation and installation on both host and client, then reconnect. Only the host should act and transactions should synchronize.
9. Cause an unaccepted request and verify bounded retries, readable logs and manual completion.
10. Check notification `EVENT`, `source=notification` and later state against the correct register. Test missing/early notifications, listener failure, old-world and client notifications; periodic checks must remain available.
11. Verify `STATE ai` finds containers with `suppressed` greater than zero. AI should stop accepting new counter jobs while retaining drinks/other work; existing jobs finish. Check other floors, new employees, save switching and error restoration without employee-config changes.
12. Switch all 14 game languages after startup. Check the six translated explanation categories, unchanged technical fields and native notifications, including both Chinese scripts and Portuguese cultures. Startup English must not be mistaken for a failed later language switch.

Repeat the appropriate checks after game or loader interface changes. A passing build or offline test suite does not establish in-game acceptance.

## 中文

玩家说明见 [README](README.md#中文)。**当前源码：0.1.4-dev。** 用户于 2026-09-26 反馈实机测试完成，范围见[验收记录](../releases/validation.md#中文)；未单独反馈清单各项结果。0.1.2 的现金、刷卡及远距离结账确认仅适用于此前版本；下方历史排查记录与验收范围原样保留其事实，不将早期问题描述作为当前状态。

### 多语言适配

`Scripts/localization.lua` 负责自有日志文案。每次游戏线程轮询或提醒事件批次通过 `KismetInternationalizationLibrary:GetCurrentLanguage()` 更新语言，覆盖 `en`、`fr`、`zh-Hans`、`it`、`es`、`de`、`ru`、`ja`、`ko`、`zh-Hant`、`tr`、`pl`、`pt`、`pt-BR`。兼容大小写、下划线及地区变体，显式中文书写系统优先，巴西葡萄牙语独立处理；读取失败或不支持时回退英语。

翻译六类原创说明：房主自动结账启用、AI 任务恢复失败、无法安排恢复、异常后停止、提醒监听不可用、三次无进展后转人工处理。技术事件名、字段、阶段和原因标识、对象身份及异常详情保持不变。首次安全的游戏线程语言读取前，启动及早期监听注册错误仍使用英语。游戏付款界面、通知和名称保留原生值，不添加语言开关或游戏翻译目录。

离线多语言测试覆盖全部语言与消息、别名、读取失败、运行中切换、后备语言及稳定诊断字段。实机回归需在启动后切换全部 14 种语言，核对六类说明、技术字段及原生通知，包含简繁中文和两种葡萄牙语；不要把早期启动英语误判为后续切换失败。这些检查尚不能宣称已在游戏中完成。

### 诊断标记

默认在 `UE4SS.log` 的 `[AutoCheckout]` 条目记录；状态变化时输出，不变时每 30 次轮询再次记录，通常约 30 秒。异常堆栈可能占后续多行。

| 日志标记 | 含义 |
| --- | --- |
| `START version=0.1.4-dev` | 已加载，并显示调度方式及 `player_guard=transaction-only` |
| `RELOAD` | 已恢复旧实例的 AI 变更，并按当前会话核对交易历史 |
| `HOOK installed event=customer-at-billing` | 提醒监听注册成功 |
| `EVENT customer-at-billing` | 延后在游戏线程检查时的柜台状态和合并提醒次数 |
| `EVENT_IGNORED` | 当前不是房主，或柜台已失效、不属于当前世界 |
| `API` / `HOST` | 接口枚举值与当前房主会话 |
| `STATE session` | 暂停状态、柜台数量和累计发起请求次数 |
| `STATE ai` / `AI` | AI 策略及发现、处理的容器数量，`restored_containers` 为恢复数量；`suppressed=0` 不能证明收银已受抑制 |
| `STATE phase=wait-...` / `unavailable=...` | 等待或排除原因，附账单、付款物件、抽屉、刷卡及占用状态 |
| `REQUEST` | 调用前的阶段、次数、目标和状态；`source` 区分提醒与轮询。`context` 的 `distance` 是房主到目标的距离，`range_before` 是原范围，`range_for_call` 是临时范围，`scope=target-call` 表示只影响本次调用 |
| `DISPATCH_RETURNED` / `AFTER` | 返回及即时状态；返回不代表请求被接受，后续 `STATE` 可显示延迟变化 |
| `SKIP` | 最后复查发现变化，未发送请求，也不消耗次数 |
| `WARN` / `ERROR` | 多次无进展或异常停止，附阶段、最近状态及可用 Lua 堆栈 |

更新后核对 `START` 版本，重点保留 `STATE ai`、`REQUEST`、`SKIP`、`AFTER` 和 `ERROR` 后的堆栈。当前代码不产生 `blocked=player-interacting`；交互限制或 AI 任务恢复失败时，重新载入世界。

### 实现

- `Scripts/game.lua`：通过 UE4SS 读取当前房主、收银机及付款状态，核对同一世界、对象类型和关联关系，再发起游戏默认交互请求。
- `Scripts/checkout.lua`：使用普通 Lua 数据维护每台收银机的处理阶段和重试次数。付款物件身份区分新交易，避免用金额或循环计数器去重。
- `Scripts/main.lua`：加载后监听收银机的顾客到达通知，并在游戏线程每秒检查一次，处理世界切换和异常停用。旧计时接口回退只排队一次，避免暂停或卡顿期间积压回调。
- `Scripts/diagnostics.lua`：记录状态变化与每 30 次轮询的状态复述，保留普通字符串，不持有游戏对象。请求前、调用返回和即时快照分别记录，避免把无返回值的 RPC 调用当成付款成功。
- `Scripts/ai.lua`：在当前房主世界的运行时任务容器中排除柜台收银，保留其他任务顺序；离开会话或异常停止时恢复本次移除的任务。

收款和关闭抽屉各自等待游戏状态确认。刷卡尚未完成时不会关闭抽屉；已被员工认领时不会抢占。调度只保留普通字符串与计数，不跨轮询保存 Unreal 对象。实际请求前再次读取状态，处理失效对象和被手动操作改变的目标。

按用户要求，不再以 `IsInteracting()`、手持物品、操作界面或其他玩家动作作为阻塞条件，仅保留游戏实际暂停和交易自身的约束。玩家抢先处理后，最后复查应取消旧请求；下次检查按最新阶段决定是否还有工作，不修改玩家状态。暂时无法读取某个柜台快照时保留其重试历史，避免短暂不可用刷新预算。最后复查取消的请求记录原因、保留冷却时间，但不消耗已发送请求预算。模块加载、调度注册、调度回调和游戏调用异常均写入带阶段的错误日志；Lua 异常捕获不能捕获原生进程崩溃。

0.1.2 在已确认的本地房主游戏线程请求中，为当前目标设置仅覆盖同步调用的交互限制：以 `GetDistanceTo` 获取角色距离，临时使用 `EDistanceReference.Actor`，将 `DistanceToInteract` 扩大到至少距离加 100 游戏单位，并临时启用 `bCanInteractWhilePlacing`。调用成功或抛出 Lua 异常后逐项恢复，部分准备失败同样回滚；原生收款已销毁的对象不再回写。每项恢复单独尝试和校验，失败停止自动流程并明确要求重新载入世界。它不改动玩家位置、控制器或忙碌状态，也不跨回调保留目标。

此处仍使用默认交互，未改成 AI 任务入口。经本机参考核对，AI 收银有员工任务和实体上下文要求，玩家请求则会重建房主交互上下文，不能仅通过传入非玩家标记切换。按用户选择，本版保留 Lua 路线。请求日志记录距离与临时范围，仍以付款对象、刷卡和账单状态确认进展，不把 RPC 返回视为成功。

AI 策略只在已确认的房主会话中应用，通过当前世界 `JobSubsystem.EvaluatorsByJob` 定位任务容器，排除 `BillingStartTaskEvaluator`，不排除餐桌结账任务，也不写入员工任务排除配置。原任务对象仍由 `AllEvaluators` 持有；移除前核对该引用，随后通过 UE4SS 的数组接口在游戏线程重建并校验顺序。只保存容器、任务及所属子系统的身份字符串和原位置，不跨回调保存 UObject。重复扫描不重写未变的数组；后续新建容器也会处理。

AI 已领取的任务和收银机占用标记不被修改，避免中断已有交易。恢复时只插回本 Mod 移除且尚未恢复的任务，保留其他运行时改动。数组写入失败尝试回滚；自动流程异常时尝试恢复 AI 收银，恢复或游戏线程调度失败会告警。此策略不写存档，关闭游戏后卸载不需要恢复存档；Lua 热重载使用下述状态交接。所有楼层及异常恢复仍保留在后续回归清单中。

提醒监听采用 `CashRegister:Multicast_DisplayCustomerAtBillingNotification` 的后置 Hook，不修改参数或返回值。回调只复制接收对象的身份字符串，不跨回调保留 UObject 或 Context；现代调度接口延迟 50 毫秒后在游戏线程检查，旧接口使用游戏线程队列。重复提醒按柜台合并，派发过程中产生的新提醒排到后续检查。执行时重新确认房主及当前世界，仅处理本批提醒对应的柜台；定时轮询负责所有柜台，共用同一状态机，不因提醒清空冷却和重试历史。

监听在定时任务注册成功后安装。监听注册、回调身份读取或事件排队失败只禁用监听并记录警告，定时检查继续；实际结账流程的异常仍按原有规则停止自动操作。提醒回调未必能覆盖全部原生调用，因此定时检查始终保留。`EVENT` 记录的是延后检查时的状态，不声称是通知发出的瞬间快照。

所有游戏接口研究、原生代码分析、类型导出、工具与研究脚本均在根目录被忽略的 `work/`。可跟踪代码不包含内存偏移、原生函数地址或游戏代码副本。

### Lua 热重载生命周期

`ModRef` 在当前游戏进程中保留一个带独立名称与格式版本的字符串，只含会话、付款对象与柜台身份、尝试次数与时间、告警标志，以及恢复 AI 所需的任务身份和位置。解析器使用有界长度前缀并校验结构，不使用 `load`、外部 JSON 依赖或共享 UObject。记录损坏或格式不受支持时停止加载，并保留原记录。

每次改写 AI 数组前先保存恢复方案，每次原生请求前先保存已增加的次数与冷却时间；共享状态写入失败时，不继续该次数组修改或请求。完成扫描及 `ModRef.OnUnload` 时保存最新普通值。卸载只停用旧回调并序列化 Lua 数据，不访问引擎对象、不调用游戏函数、不向即将关闭的 Lua 状态排队。已核对的实验版加载器在卸载时注销旧 Hook 并移除计划动作；脚本也让残留旧回调直接返回。

新实例在第一次游戏线程回调中先恢复继承的 AI 记录，再重新应用正常任务策略。控制器暂时不可用时保留记录等待；确认进入不同会话后，可丢弃已销毁旧世界的记录。同会话容器不可用或恢复失败时保留记录并停止自动流程，下次热重载可重试。通知先到或轮询先到均保留原交易次数与冷却；控制器暂时不可用时继续保留，确认进入不同会话后才重置。已耗尽的三次尝试不会因重载重新获得预算。0.1.3-dev 及更早版本无法提供交接记录，首次升级必须关闭游戏；永久卸载也需关闭游戏。只卸载而不加载新实例时，卸载回调无法恢复引擎数组，应重新载入世界。交接仅存在当前进程，不是崩溃恢复文件或新增存档数据。

原有 68 项离线测试与 12 项重载测试通过。新增覆盖两个调度器、旧回调失效、AI 恢复后重新应用、恢复失败与容器缺失、两个付款阶段的次数保留、世界与控制器变化、请求前保存、共享写入失败及异常载荷。加载器实际卸载和引擎行为仍需实机测试。

### 离线检查与打包

在仓库根目录执行：

```powershell
uv run --with lupa==2.6 python auto-checkout-mod/tests/run.py
python auto-checkout-mod/build.py
python tools/check_repository.py
git diff --check
```

测试使用 Lua 5.4：覆盖现金和刷卡流程、动画等待、重复请求、重试上限、未发送请求的计数、现有员工占用、同一世界校验、对象失效、玩家动作不阻塞、手动抢先完成、多个柜台、读档重置、加载后自动运行、两种调度接口、诊断节流与异常停用。提醒测试另覆盖合并、延后读取、定位单个柜台、早于付款就绪的通知、与轮询共用预算、客户端及旧世界过滤、监听失败回退和交互过程中新增通知。AI 测试覆盖定向排除、其他任务与顺序保留、迟到的容器、重复扫描、对象引用保留、写入回滚、恢复失败和房主生命周期。替代对象只能验证 Mod 的逻辑，不能证明 UE4SS 的真实参数桥接、Hook 是否在游戏中触发或游戏运行结果。

0.1.2 新增远距离现金和刷卡两阶段执行、两步之间玩家距离变化、已有交互设置保留、请求与诊断异常、部分准备失败、单项恢复失败后继续恢复其他项、付款对象销毁以及无效距离输入的验证。

打包使用固定文件白名单，生成 `outputs/auto-checkout/AutoCheckout-0.1.4-dev.zip` 和 SHA-256 文件。包不包含测试、开发工具、加载器或游戏资料。构建不会写入游戏目录、操作存档或启动/关闭游戏。

本版的加载日志为 `START version=0.1.4-dev`，同时保留 `player_guard=transaction-only`；包的 SHA-256 用于核对完整内容。

### 远端测试反馈

2026-09-23，用户反馈另一台电脑的 0.1.0-dev 已记录加载与房主识别，顾客仍停留柜台，偶有闪动；未发现异常、重试耗尽或调度失败日志。这些记录不能证明结账请求曾被发送，也不能把闪动归因于 Mod。0.1.1-dev 用于补齐该诊断缺口，尚待同一环境的状态和请求日志；未将交互事件已修复或功能验收通过作为结论。

2026-09-24，现金与刷卡均出现 `phase=wait-player-interacting`、`blocked=player-interacting`，且 `dispatched=0`；用户确认玩家未处理、AI 在吧台工作。此证据确认旧玩家检查阻止了请求，不能单独证明 AI 改写了玩家状态。用户进一步要求抑制 AI 收银，且玩家操作不应阻塞自动结账，抢先完成时取消当次请求。本次按该规则调整；仍需验证请求发送后游戏是否接受并完成两步交互。

后续日志显示一次现金交易在收款和关闭钱柜调用后立即推进，但其他交易中相同请求多次返回而状态不变，有的耗尽三次预算。延迟出现的状态变化不能据此认定为 Mod 完成；这批热重载后的记录没有银行卡交易。本机参考确认两个动作的原生校验仍受房主距离限制，也有家具摆放限制。日志没有玩家位置，因此不能逐笔证明拒绝原因；0.1.2-dev 针对已确认存在的限制修复，并补充距离诊断，其后实机结果见下文。

### 游戏内验收

2026-09-24 用户在上述修正后确认最新 0.1.1-dev 实机测试成功，明确要求转为 0.1.1 正式版。正式版保留已测试的运行逻辑，仅更新诊断版本标识。本次反馈未逐项提供游戏及加载器完整版本、联机角色或测试时长。

2026-09-24 用户确认 0.1.2-dev 本次测试没有问题，报告截至 01:40:22 已完成 3 笔现金、2 笔刷卡，每笔均执行接收付款和钱柜交互；所有请求均为第一次尝试，没有重试失败或新异常。现金关钱柜时距离约 1341，刷卡约 796，均超过原交互范围 200，随后账单清空、钱柜关闭。这验证了本轮现金、刷卡及超出原范围的结账流程，随后按用户要求转为 0.1.2 正式版；运行逻辑保持已验收版本，仅更新诊断版本标识、包名和说明。来源为用户实机反馈，运行代码对应提交 `61dd9c3`；反馈未逐项确认摆放家具、跨楼层、联机同步或长时间运行场景。

以下保留为后续回归检查清单，不代表本次逐项完成。后续重点补充其他楼层、两步之间移动、同时摆放家具及手动交互设置恢复，记录是否手动介入，核对 `REQUEST context` 与紧接的 `AFTER`，并检查账单及收入。

1. 单人进入餐厅，让用餐完毕的顾客到达柜台，确认无点击即可结账、正常离店；入座前和用餐中的顾客不受影响。
2. 分别测试现金和银行卡，确认刷卡提示和抽屉动作正常；比较账单、小费、销售记录及收入，确认每笔只计一次。
3. 连续接待至少十组顾客，包含金额相同的相邻账单、多台收银机和屋顶柜台；检查队列正常推进。
4. 玩家抢先点击付款或收银机，确认旧请求被跳过，后续状态正常推进，无重复收款。付款对象销毁或柜台已完成时不得导致整个 Mod 停用。
5. 拿起其他物品、制作饮料、打开平板/聊天和摆放家具，确认自动功能继续，检查游戏是否保留玩家当前操作；游戏实际暂停时等待，恢复后继续。
6. 安装后直接进入餐厅，不做任何按键或开关操作，确认首位顾客自动结账；重新启动游戏后再次确认自动运行。
7. 返回主菜单、切换存档、重新加入游戏，确认不会操作旧世界的柜台；长时间游玩检查日志和轮询开销。
8. 房主启用、客户端未启用，以及双方都安装两种情况下，确认只有房主执行、交易正常同步。断线重连后再次检查。
9. 故意让某次请求不被游戏接受，确认重试有上限、日志不刷屏，仍能手动完成结账。
10. 顾客到柜台提醒出现时检查 `EVENT` 日志，确认对应正确柜台；与 `source=notification` 请求及后续状态对照。没有收到提醒、提醒早于付款就绪、监听注册失败时，确认定时检查仍可推进；旧世界通知和普通客户端通知不得触发交易。
11. 让 AI 在吧台工作，确认 `STATE ai` 中发现任务容器且 `suppressed` 大于零，AI 不再领取新的柜台收银任务，仍正常制作饮料和做其他工作。已领取的收银应能完成，各楼层及新雇员工同样检查。切换存档和自动流程异常后检查任务恢复，员工配置应不变。
12. 在等待现金、刷卡处理中、钱柜打开及重试已耗尽时连续热重载，检查只有一组有效监听/轮询、冷却与次数不重置、员工任务先恢复再应用，并测试切换世界及恢复失败；这些重载场景尚未实机验收。

接口或加载器升级后，应重新核对本机参考并重复上述验收。构建成功、离线测试通过不代表完成游戏内验收。
