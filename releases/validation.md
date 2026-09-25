# In-game validation / 实机验收记录

[English](#english) · [中文](#中文)

## English

Scan to Order **0.1.0-dev** adds host/single-player automatic food and drink ordering with restock recovery. Local references were checked against Steam Build **25532071** / **1.0.1.44eb**. Offline stock-contention, customer-state, authority, native acceptance and reload tests pass; real engine calls, replenishment, staffing and multiplayer replication remain pending in-game acceptance.

First to Serve **0.1.7-dev** adds direct drink-output-surface holds with tray/trolley support. Offline area isolation, eligible full-drink filtering, three-cup sequencing, panning and cancellation tests pass. Drink-area targeting, hints and native short-click deposit still need in-game acceptance.

First to Serve **0.1.6-dev** adds held food-trolley support with ordinary/stack-slot acknowledgement, drink-only and top-slot capacity checks, and carrier-change cancellation. Offline tray/trolley regressions pass; trolley rendering, native pickup and host/guest behavior still need in-game acceptance.

The 2026-09-25 hot reload update (Bartender's Note 0.1.2-dev, Auto Checkout 0.1.4-dev, Fresh to Serve 0.1.2-dev, First to Serve 0.1.5-dev and Smart Delivery 0.1.4-dev) adds reload lifecycle and state handoff handling. Manual Ctrl+R reload, live UI cleanup, AI recovery and pending orders still need in-game acceptance; DLL updates require a process restart.

Smart Delivery **0.1.3-dev** changes the delivery dropdown text to white following a visibility report. Visual verification of the revised text remains pending.

On 2026-09-25, the user reported testing aiming and continuous holds at the updated game's kitchen pass and requested starting the hold on the pass itself. First to Serve **0.1.4-dev** adds that area-targeting behavior; its offline regression tests pass, while this new behavior still awaits in-game acceptance. The report does not establish a complete loader, multiplayer or display test matrix.

Smart Delivery **0.1.2-dev** is available for testing the updated game. On 2026-09-25, native code discovery was checked read-only against installed Steam Build **25532071**. This version removes mandatory game-version, executable-size and hash allowlists, retaining target-structure and code-conflict checks. Synthetic native discovery tests and dispatch execution tests passed; real game startup, UI, fees and delivery staffing remain unverified.

Earlier Smart Delivery startup history: On 2026-09-24, the user reported that 0.1.0-dev loaded but its native helper failed compatibility validation before UI injection. Version 0.1.1-dev corrects the treatment of zero-filled runtime data. Native dispatch execution tests, Lua behavior tests and package checks do not establish real UI, engine integration, delivery charges or multiplayer behavior. See its [acceptance checklist](../smart-delivery-mod/DEVELOPMENT.md#english).

Fresh to Serve 0.1.1-dev adds drinks and cocktails to meal cleanup and replacement; in-game acceptance is pending. Offline tests and package verification do not establish real cleanup, kitchen/bar ordering or waiter delivery.

Current source versions Bartender's Note 0.1.1-dev and Auto Checkout 0.1.3-dev include localization changes that still require in-game verification. The accepted stable versions remain Bartender's Note 0.1.0 and Auto Checkout 0.1.2. Current CI packages follow current source versions and do not extend these historical acceptance results.

### 2026-09-24

The user confirmed successful in-game testing of both latest development packages and explicitly requested stable versions:

| Mod | Tested development version | Stable version |
| --- | --- | --- |
| Bartender's Note | 0.1.0-dev | 0.1.0 |
| Auto Checkout | 0.1.1-dev | 0.1.1 |

The stable versions retain the tested runtime logic. Auto Checkout only changed its diagnostic version identifier; documentation, package names and CI were also updated. The tested functionality was based on commit `0ad7c11`.

The local development reference baseline is Steam Build 25393699, ProjectVersion 1.0.0.44eb and Unreal Engine 5.4; the checked UE4SS experimental API is `v3.0.1-1140-gf58e8f84`. The user did not provide the test machine's game version, full loader version, resolution, multiplayer role or test duration individually. These reference versions therefore do not constitute a complete tested environment record, and the regression scenarios in each Mod's development guide are not all marked as passed.

CI covers Lua offline behavior tests, source and version checks, ZIP allowlists and SHA-256 verification. Game or loader updates still require further in-game testing.

### Auto Checkout 0.1.2: 2026-09-24

The user confirmed that the 0.1.2-dev in-game test had no problems, then requested conversion to stable 0.1.2. The report covered results through 01:40:22:

| Check | User-reported result |
| --- | --- |
| Cash | Three transactions completed; each performed payment collection and the cash-register interaction |
| Card | Two transactions completed; each performed payment collection and the cash-register interaction |
| Requests | Every request succeeded on its first attempt, without retry failures or new exceptions |
| Beyond the original interaction range | Original range: 200. Distance when closing the drawer: about 1341 for cash and 796 for card; the bill then cleared and the drawer closed |

This confirms cash, card and distant two-stage checkout in that test environment. Runtime code corresponds to commit `61dd9c3`; the stable version retains that implementation and changes only the diagnostic version identifier, package name and documentation. The feedback did not separately confirm furniture placement, other floors, multiplayer synchronization, manual actions taking precedence or extended play, and did not provide complete environment versions. These scenarios remain in the development guide's regression checklist.

## 中文

Scan to Order（扫码点餐）**0.1.0-dev** 新增仅房主／单人自动提交食物和饮料订单、补货后续单。本机参考核对基于 Steam Build **25532071** / **1.0.1.44eb**。库存争用、顾客状态、权限、原生受理结果及热重载离线测试通过；真实引擎调用、补货、人员条件和联机同步仍待实机验收。

First to Serve **0.1.7-dev** 新增直接对准饮料出品台面长按，支持托盘和餐车。区域隔离、成品饮料过滤、连续三杯、移动准星及取消离线测试通过；饮料台实机瞄准、提示及原生短按放回饮料仍待验收。

First to Serve **0.1.6-dev** 新增握持餐车取餐，识别普通位/堆叠位装车确认、饮料专用位与顶层容量限制，并在更换工具时取消。托盘及餐车离线回归通过；餐车实机提示、原生取餐及房主/客机行为仍待验收。

2026-09-25 热重载更新（Bartender's Note 0.1.2-dev、Auto Checkout 0.1.4-dev、Fresh to Serve 0.1.2-dev、First to Serve 0.1.5-dev、Smart Delivery 0.1.4-dev）新增卸载处理及状态交接。Ctrl+R 手动重载、实机 UI 清理、AI 恢复和待补单仍待实机验收；DLL 更新需要重启游戏进程。

Smart Delivery **0.1.3-dev** 根据文字可读性反馈，将配送下拉框文字改为白色；修改后的显示效果仍待实机确认。

2026-09-25，用户反馈已实测新版出餐口的瞄准与连续长按，并要求直接对准出餐口启动长按。First to Serve **0.1.4-dev** 新增该区域触发方式；离线回归测试通过，新增行为仍待实机验收。此次反馈不代表加载器、联机及显示场景已完成全部验证。

Smart Delivery **0.1.2-dev** 用于测试更新后的游戏。2026-09-25，已对本机 Steam Build **25532071** 只读核对原生代码定位结果。本版取消游戏版本、EXE 固定大小与哈希白名单，保留目标结构及代码冲突检查。原生定位合成测试与分派执行测试通过；实际游戏启动、界面、费用及配送人数仍待验证。

此前 Smart Delivery 的启动问题记录：2026-09-24，用户反馈 0.1.0-dev 已加载，但原生辅助模块在界面注入前校验失败。0.1.1-dev 修正了零填充运行时数据的校验方式。原生分派执行测试、Lua 行为测试和包校验不代表真实界面、引擎集成、配送扣款或联机行为通过；见其[验收清单](../smart-delivery-mod/DEVELOPMENT.md#中文)。

Fresh to Serve 0.1.1-dev 将清理与重做从食物扩展至饮料和鸡尾酒，仍待游戏内验收。离线测试与包校验不等同于真实清理、厨房/吧台补单和服务员上菜成功。

当前源码 Bartender's Note 0.1.1-dev 和 Auto Checkout 0.1.3-dev 包含多语言改动，仍待游戏内验证。已验收正式版仍为 Bartender's Note 0.1.0 和 Auto Checkout 0.1.2。当前 CI 按当前源码版本打包，不扩展以下历史验收结论。

### 2026-09-24

用户确认两个最新开发包实机测试成功，并明确要求转为正式版：

| Mod | 已测试开发版本 | 正式版本 |
| --- | --- | --- |
| Bartender's Note | 0.1.0-dev | 0.1.0 |
| Auto Checkout | 0.1.1-dev | 0.1.1 |

正式版沿用已测试的运行逻辑。Auto Checkout 仅更新诊断中的版本标识；同时更新文档、包名和 CI。实测功能源码基于提交 `0ad7c11`。

本机开发参考基线为 Steam Build 25393699、ProjectVersion 1.0.0.44eb、Unreal Engine 5.4，核对的 UE4SS experimental API 为 `v3.0.1-1140-gf58e8f84`。用户本次未逐项提供测试机器的游戏版本、加载器完整版本号、分辨率、联机角色或测试时长，因此这些参考版本不等同于完整实测环境记录，也不将各 Mod 开发说明中的所有回归场景标记为逐项通过。

CI 负责 Lua 离线行为测试、源码与版本检查、ZIP 白名单和 SHA-256 校验；后续游戏或加载器更新仍需重新实测。

### Auto Checkout 0.1.2：2026-09-24

用户确认 0.1.2-dev 实机测试没有问题，随后要求转为 0.1.2 正式版。报告截至 01:40:22：

| 验证项 | 用户反馈 |
| --- | --- |
| 现金 | 完成 3 笔，每笔均执行接收付款和钱柜交互 |
| 刷卡 | 完成 2 笔，每笔均执行接收付款和钱柜交互 |
| 请求结果 | 所有请求均为第一次尝试，无重试失败或新异常 |
| 超出原交互范围 | 原范围为 200；现金关钱柜时距离约 1341，刷卡约 796，随后账单清空、钱柜关闭 |

本轮确认现金、刷卡和远距离两阶段结账在该测试环境中生效。运行代码对应提交 `61dd9c3`，正式版沿用该实现，仅更新诊断版本标识、包名和说明。反馈未逐项确认家具摆放、跨楼层、联机同步、手动抢先操作或长时间运行，也未提供完整测试环境版本；这些场景继续保留在开发说明的回归清单中。
