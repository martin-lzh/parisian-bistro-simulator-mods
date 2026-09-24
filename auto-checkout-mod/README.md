# Auto Checkout

[English](#english) · [中文](#中文)

## English

Automatically accept cash or cards from customers at the counter, wait for the register to be ready, and complete its checkout interaction.

**Current source: 0.1.3-dev.** This version adds language-aware log explanations and awaits in-game acceptance. The latest accepted version is 0.1.2: on 2026-09-24, the user confirmed three cash and two card transactions, all on the first attempt, including checkout beyond the original interaction range. That result does not establish acceptance of the new localization.

### How to use

Enter the restaurant as the single-player host or multiplayer host. The Mod starts automatically, with no key binding, toggle or settings file. Ordinary multiplayer clients remain idle; only the host needs it enabled. Multiplayer synchronization still needs in-game testing.

The Mod uses the game's normal interaction requests, so the game calculates bills, tips and income and handles customers leaving. It does not directly rewrite money, payment flags or customer state, and does not handle table checkout, cash declarations, withdrawals or cash bags.

It checks a register when the game's customer-at-counter notification arrives, and checks all current-world registers every second, including counters on other floors. A missing notification does not disable periodic checks. Actual acceptance across floors remains on the regression checklist.

### During play

You can carry items, make drinks, open interfaces or move away from the register while it works. Immediately before each request, the Mod checks that the same transaction is still waiting. A manual payment, closed drawer or invalidated payment object cancels the outdated request. It waits while the game is actually paused, a card payment is processing, a drawer is moving, or an employee already owns that transaction.

New AI counter-checkout jobs are suppressed on the host while the Mod runs; drink preparation, serving and other jobs are retained. Already claimed checkout jobs may finish. Employee configuration and saves are not edited. On leaving a host session, changing worlds or stopping after an error, the Mod attempts to restore the jobs it removed. A failed restoration is logged and requires reloading the world.

The Mod temporarily adjusts only the current target's interaction distance and furniture-placement restriction for the immediate native call, then restores them. It does not move the player or change the player's current activity.

Requests in the same stage are at least three seconds apart, with at most three attempts. If the game does not advance that stage, the Mod stops retrying it and logs a warning; finish that transaction manually. Later customers can still be processed. An interface or execution error can stop automation for the current load; inspect the log before reloading.

### Languages

The game's own payment prompts, notifications and item names remain native. The Mod adds no payment interface. Its host explanations, retry warnings, stop messages, notification fallback and AI-restoration advice follow the game's 14 supported languages: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese.

Technical event names, field keys, phase/reason identifiers and exception details stay unchanged. Startup messages before the first safe game-thread language read remain English; unsupported or unavailable languages also fall back to English. There is no separate Mod language setting.

### Install, update or remove

The local reference baseline is Windows Parisian Bistro Simulator, Steam Build 25393699 / ProjectVersion 1.0.0.44eb, Unreal Engine 5.4. Use **UE4SS experimental** with UE 5.4 support; the locally checked API is `v3.0.1-1140-gf58e8f84`, not old stable 3.0.1.

1. Close the game and install the experimental loader following the [UE4SS installation guide](https://docs.ue4ss.com/dev/installation-guide.html).
2. Place the ZIP's `AutoCheckout` folder in the loader's `Mods` directory. A common location is `BrasserieSimulator/Binaries/Win64/ue4ss/Mods/AutoCheckout`; use your actual loader layout.
3. Check that `AutoCheckout/Scripts/main.lua` and `AutoCheckout/enabled.txt` exist. Do not replace the whole `mods.txt` or add a duplicate enable entry.
4. Start the game and enter your restaurant as host.

Close the game before replacing or deleting the `AutoCheckout` folder. Script hot reload is not supported. The Mod creates no custom save data, but completed transactions are saved normally by the game and are not reversed by removal. Packages contain no loader, game files or research material; builds do not install anything.

### If checkout does not start

Diagnostics are always enabled in `UE4SS.log` under `[AutoCheckout]`. Check `START version=0.1.3-dev` after updating, followed by `HOST`, `STATE ai`, `REQUEST`, `SKIP` and `AFTER`. Keep the stack after any `ERROR` as well. A returned call does not by itself mean that the game accepted the request.

State changes are logged immediately, with unchanged state repeated every 30 polls, usually about 30 seconds. `suppressed=0` does not prove AI checkout is suppressed. Current code should not emit `blocked=player-interacting`. If a warning reports that interaction restrictions or AI jobs could not be restored, reload the world. The development guide contains the [diagnostic reference](DEVELOPMENT.md#diagnostic-reference) and test checklist.

[Changes](CHANGELOG.md) · [Build, implementation and validation](DEVELOPMENT.md#english)

## 中文

自动接收柜台顾客递出的现金或银行卡，等待收银机准备好，再完成收银机结账交互。

**当前源码：0.1.3-dev。** 本版增加跟随游戏语言的日志说明，仍待实机验收。最近已验收版本为 0.1.2：2026-09-24 用户确认 3 笔现金、2 笔刷卡均首次尝试成功，包括超出原交互范围的结账。该结论不代表新增多语言功能已验收。

### 怎么使用

以单人玩家或联机房主身份进入餐厅即可自动运行，无需按键、开关或设置文件。普通联机客户端保持空闲，只需房主启用；联机同步仍待实机测试。

Mod 使用游戏原有交互请求，由游戏计算账单、小费和收入并处理顾客离店，不直接改写金额、付款标记或顾客状态，也不处理餐桌结账、现金申报、取钱或现金袋。

收到游戏的顾客到柜台提醒后检查对应收银机，同时每秒检查当前世界所有收银机，包括其他楼层柜台。提醒缺失时仍有定时检查；跨楼层实际验收继续保留在回归清单中。

### 运行行为

玩家手持物品、制作饮料、打开界面或远离柜台时仍可运行。每次请求前重新确认同一笔交易是否还在等待；玩家手动收款、关闭钱柜或付款对象失效时，取消过时请求。游戏实际暂停、刷卡进行中、钱柜运动中或员工已认领该笔交易时会等待。

运行期间，房主端禁止 AI 新领取柜台收银任务，保留制作饮料、上菜及其他任务。已领取的收银任务允许完成，不修改员工配置或存档。离开房主会话、切换世界或异常停止时尝试恢复本次移除的任务；恢复失败会记录警告，需要重新载入世界。

每次原生调用仅临时调整当前目标的交互距离和摆放家具限制，调用后恢复，不移动玩家，也不改变玩家正在做的工作。

同一阶段的请求至少间隔三秒、最多三次。游戏状态未推进时，停止重试该阶段并记录警告，可手动完成这笔交易；后续顾客仍可自动处理。接口读取或执行异常可能停止本次加载的自动功能，请先检查日志再重新加载。

### 语言

付款提示、通知与物品名称保留游戏原生值，不新增付款界面。房主状态说明、重试警告、停止信息、提醒监听回退和 AI 恢复建议适配游戏中的 14 种语言：英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语与巴西葡萄牙语。

技术事件名、字段名、阶段与原因标识、异常详情保持不变。首次安全的游戏线程语言读取之前，启动信息使用英语；语言不支持或不可用时也回退英语。无需独立的 Mod 语言设置。

### 安装、更新与卸载

本机参考基线为 Windows 版 Parisian Bistro Simulator，Steam Build 25393699 / ProjectVersion 1.0.0.44eb，Unreal Engine 5.4。需要支持 UE 5.4 的 **UE4SS experimental**；本机核对的 API 为 `v3.0.1-1140-gf58e8f84`，不是旧稳定版 3.0.1。

1. 关闭游戏，按 [UE4SS 安装说明](https://docs.ue4ss.com/dev/installation-guide.html)安装实验版加载器。
2. 将 ZIP 内的 `AutoCheckout` 文件夹放入加载器 `Mods` 目录。常见位置为 `BrasserieSimulator/Binaries/Win64/ue4ss/Mods/AutoCheckout`，以实际布局为准。
3. 确认存在 `AutoCheckout/Scripts/main.lua` 和 `AutoCheckout/enabled.txt`。不要替换整个 `mods.txt` 或添加重复启用项。
4. 启动游戏，以房主身份进入餐厅。

更新或删除 `AutoCheckout` 文件夹前关闭游戏，不支持脚本热重载。Mod 不创建自定义存档数据，但已完成交易会由游戏正常保存，卸载不会撤销。包内不含加载器、游戏文件或研究资料；构建不会自动安装。

### 没有自动结账时

诊断默认启用，在 `UE4SS.log` 中查看 `[AutoCheckout]` 条目。更新后检查 `START version=0.1.3-dev`，再查看 `HOST`、`STATE ai`、`REQUEST`、`SKIP` 和 `AFTER`；保留 `ERROR` 后的堆栈。调用返回本身不代表游戏接受请求。

状态变化时立即记录，不变时每 30 次轮询再次记录，通常约 30 秒。`suppressed=0` 不能证明 AI 收银已被抑制，当前代码不应产生 `blocked=player-interacting`。若日志报告交互限制或 AI 任务恢复失败，请重新载入世界。开发说明提供完整[诊断标记](DEVELOPMENT.md#诊断标记)及验收清单。

[版本变化](CHANGELOG.md) · [构建、实现与验收](DEVELOPMENT.md#中文)
