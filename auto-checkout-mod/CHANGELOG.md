# Changelog / 变更记录

## Unreleased

## 0.1.4 - 2026-09-26

### English

- Promote 0.1.4-dev to 0.1.4 after the maintainer confirmed that all current Mods passed in-game and multiplayer testing and explicitly authorized stable publication on 2026-09-26. Retain the tested gameplay logic; update version identifiers, package names and release documentation.
- Complete cash and card checkout on the host, including distant interactions, temporary-setting restoration, localization and reload recovery.
- Include the checkout-counter gameplay screenshot in both player-guide languages.
- Include English/Chinese installation, usage and update guides, the MIT license, and verified package contents. Documentation images remain outside the installable ZIP.

### 中文

- 维护者于 2026-09-26 确认全部当前 Mod 实机及联机测试通过，并明确授权发布正式版，据此将 0.1.4-dev 转为 0.1.4；保留已测试的玩法逻辑，更新版本标识、包名和发布说明。
- 房主端自动完成现金与刷卡结账，支持远距离交互、临时设置恢复、本地化及重载恢复。
- 中英文玩家说明附上收银台实机截图。
- 附上中英文安装、使用、更新说明及 MIT 许可，并校验包内容；文档图片不进入安装 ZIP。

## 0.1.4-dev

### English

- Add the maintainer-provided checkout-counter screenshot to the English and Chinese README sections, with image provenance and scene notes.
- Add an assets directory for in-game test screenshots and promotional artwork, with README links and embedding examples.
- Adopt **收银管家** as the Chinese display name in player guides and shared documentation.
- Rewrite player installation, usage, update and removal guides; move implementation and reload details into developer documentation and repair links used from extracted packages.
- Include the MIT license in source and installable packages, with packaging checks for missing or changed license text.

- 0.1.4-dev: support experimental UE4SS Lua hot reload. Persist primitive AI recovery records and per-transaction cooldowns/retry budgets across instances, and restore inherited AI changes on the game thread before continuing.
- Save recovery plans before engine-array writes and attempts before dispatch. Retire old callbacks without touching UObjects or scheduling work during unload; preserve failed recovery records for another reload and reject malformed handoff data without executing it.
- Add 12 offline reload checks covering both schedulers, AI recovery failures, notifications, retry limits, temporary controller loss and storage errors. Upgrade from earlier versions and permanently remove the Mod with the game closed; real loader and in-game reload acceptance is pending.
- 0.1.3-dev: explanatory status and warning logs follow the game's current language across all 14 supported languages. Language is checked on the game thread; unavailable or unsupported languages fall back to English without stopping checkout.
- Keep game notifications and interaction text native, without copying game translation assets. Structured diagnostic tags, fields and exception details remain unchanged.
- Add offline coverage for language changes, regional/script variants and safe fallback without a world or a working language reader. In-game localization verification is still pending.

### 中文

- 将维护者提供的收银台实机图加入中英文 README，并记录图片来源及可见场景。
- 新增 assets 目录存放实机测试图与宣传图，并提供 README 入口和图片引用示例。
- 中文名称统一为 **收银管家**，同步玩家说明及公共文档。
- 重写面向玩家的安装、使用、更新及卸载说明，将实现与重载细节移入开发文档，并修复解压后使用的文档链接。
- 为源码及安装包附上 MIT 许可全文，增加许可缺失或内容改变时的打包校验。
- 0.1.4-dev：支持 UE4SS 实验版 Lua 热重载；跨实例保留普通值形式的 AI 恢复记录、每笔交易冷却时间及重试预算，新实例先在游戏线程恢复旧 AI 改动，再继续运行。
- 改写引擎数组和发送请求前先保存恢复方案与尝试次数；卸载时停用旧回调，不访问 UObject、不排队，并保留失败恢复记录供下次重载重试；异常交接内容被校验拒绝，不作为代码执行。
- 新增 12 项离线重载检查，覆盖两个调度器、AI 恢复失败、通知、重试上限、控制器暂失及存储错误。从旧版首次升级或永久卸载需关闭游戏；加载器与游戏内热重载仍待实机验收。
- 0.1.3-dev：说明性状态与警告日志跟随游戏当前语言，覆盖游戏支持的 14 种语言；每次游戏线程检查时重新读取语言，读取失败或不支持的语言回退英语，不影响结账。
- 保留原生游戏通知与交互文本，不复制游戏翻译资源；结构化日志标记、字段和异常详情保持原样。
- 新增语言切换、地区与文字变体、无世界及读取失败回退的离线验证；本次多语言改动尚未经过游戏内验收。

## 0.1.2 - 2026-09-24

### English

- Promote the accepted 0.1.2-dev build to a stable release at the user's request; retain the tested runtime logic and update the diagnostic version, package name and documentation.
- Fix automatic interactions being restricted by the host's distance from the payment object or cash register. Expand the interaction range and allow interaction during placement only for a single synchronous call on the current target, then restore the original settings without moving or modifying the player.
- Attempt restoration even if a settings write, diagnostic operation or request fails. Do not write back to destroyed payment objects; explicitly advise reloading the world if restoration fails.
- Add player distance, original interaction range and the range used for the current call to request logs. Add offline verification of distant cash and card payments, player movement and recovery after errors.
- On 2026-09-24, the user confirmed that 0.1.2-dev completed three cash payments and two card payments in-game, all on the first attempt, with no failed retries or new exceptions. Drawer closure occurred at distances of approximately 1341 for cash and 796 for card payments, exceeding the original range of 200 while still clearing bills and closing the drawer correctly. This feedback is the in-game acceptance basis for the 0.1.2 stable release.

### 中文

- 按用户要求将已验收的 0.1.2-dev 转为正式版；保留已测试的运行逻辑，更新诊断版本、包名和说明。
- 修复自动交互仍受房主到付款物件或收银机距离限制的问题；在当前目标的单次同步调用期间扩大交互范围并允许摆放期间交互，随后恢复原设置，不移动或修改玩家。
- 部分设置写入失败、诊断或请求异常时也尝试恢复；付款对象已销毁时不再回写，恢复失败明确提示重新载入世界。
- 请求日志增加玩家距离、原交互范围及本次调用范围；新增远距离现金/刷卡、玩家位置变化和异常恢复的离线验证。
- 2026-09-24 用户确认 0.1.2-dev 实机完成 3 笔现金和 2 笔刷卡，全部首次尝试成功，无重试失败或新异常；现金和刷卡关钱柜时距离分别约 1341、796，超过原范围 200 后仍正常清空账单并关闭钱柜。此反馈作为 0.1.2 正式版的实机验收依据。

## 0.1.1 - 2026-09-24

### English

- Promote the latest development package to a stable release after the user confirmed successful in-game testing; retain the tested runtime logic and update the version identifier in logs.
- Remove player-busy guards such as `IsInteracting()`, allowing the player to perform other work at the same time. Cancel the current request if the player collects payment or closes the drawer first, or if the payment object becomes invalid, then handle the latest transaction state.
- Exclude new AI counter-checkout tasks on the host at runtime while preserving other work and employee settings. Allow already claimed tasks to finish. Attempt restoration when leaving the session or after an automation error, and issue an explicit warning if restoration fails.
- Add the `player_guard=transaction-only` build identifier, AI policy status and restoration logs, plus offline regression coverage for player intervention, task filtering and restoration.
- Respond to customer-at-counter notifications by checking the corresponding cash register on the game thread, while retaining checks every second. Events and polling share cooldowns and retry counts.
- Add `HOOK`, `EVENT`, `EVENT_IGNORED` and request-source logs, and coalesce duplicate notifications. Fall back to polling if the listener cannot be registered.
- In response to test feedback that customers remained at the counter without error logs, add diagnostics for host waiting reasons, discovered register counts, payment snapshots, request targets and stages, call returns and state changes.
- Add version and scheduling identifiers, throttle state logs, catch module-loading and scheduling-registration errors, and include execution stages and Lua stack traces.
- Do not consume the sent-request budget for actions cancelled by the final check. Preserve retry history when a register snapshot is temporarily invalid.
- Retain the existing two-stage interaction calls and include development and acceptance documentation in the installation package.

### 中文

- 用户确认最新开发包实机测试成功，转为正式版；运行逻辑保持已测试版本，更新日志版本标识。
- 移除 `IsInteracting()` 等玩家忙碌拦截；玩家可同时做其他工作，抢先收款、关闭抽屉或付款对象失效时取消当前请求，再按最新交易状态处理。
- 房主端在运行时排除 AI 的新柜台收银任务，保留其他工作及员工配置；已领取任务允许完成。离开会话或自动流程异常时尝试恢复，失败会明确告警。
- 增加 `player_guard=transaction-only` 构建辨识、AI 策略状态和恢复日志，以及玩家抢先操作、任务筛选和恢复的离线回归验证。
- 接入“顾客到柜台”提醒，在游戏线程检查对应收银机，保留每秒定时检查；事件与轮询共用冷却和重试次数。
- 增加 `HOOK`、`EVENT`、`EVENT_IGNORED` 和请求来源日志，合并重复提醒；监听失败时回退到定时检查。
- 针对顾客停在柜台但没有错误日志的测试反馈，补充房主等待原因、柜台发现数量、付款快照、请求目标与阶段、调用返回和状态变化日志。
- 增加版本号与调度方式标识、状态日志节流、模块加载及调度注册的异常捕获，以及执行阶段和 Lua 堆栈。
- 最后复查取消的操作不再消耗已发送请求预算；短暂无效的柜台快照不清空重试历史。
- 保留原有两阶段交互调用，并将开发与验收说明加入安装包。

## 0.1.0-dev

### English

- Add a development version of automatic counter checkout, handling cash and card payments through the game's default interactions.
- Wait for card-payment and drawer animations, and defer to employee activity, player actions and pause screens.
- Run automatically after installation without a key binding or toggle; provide a retry limit for each stage, disable automation after errors and write logs.
- Run only in single-player or on the multiplayer host, validate the current world and clear state when changing saves.
- Add offline Lua behavior tests and a packaging entry point with an allowlist of original files.
- Offline checks passed. Subsequent testing confirmed loading and host detection, but automatic checkout did not complete correctly; functionality, performance and multiplayer behavior remained unaccepted.

### 中文

- 新增柜台自动结账开发版本，按游戏默认交互处理现金与银行卡。
- 等待刷卡和抽屉动画，避让员工处理、玩家操作及暂停界面。
- 安装后自动运行，无需按键或开关；提供每阶段重试上限、异常停用与日志。
- 限制为单人或联机房主执行，校验当前世界并在切换存档时清理状态。
- 添加 Lua 离线行为测试和原创文件白名单打包入口。
- 离线检查通过；后续测试反馈已加载并识别房主，但未正常完成自动结账，功能、性能和联机尚未验收。
