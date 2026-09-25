# Scan to Order / 扫码点餐

[English](#english) · [中文](#中文)

## English

**Version: 0.1.1-dev — in-game acceptance pending.**

Automatically places seated customers' food and drink orders in single player or on the multiplayer host. No waiter or player needs to take the order. Customers keep the choices made by the game's AI; the Mod does not select substitutes or change the menu.

Each item waits while its ingredients are out of stock. Available items can proceed independently; after restocking, outstanding items are checked again every second. Normal chef, bartender, equipment and speciality requirements still apply. Cooking, drink preparation, delivery, billing and customer patience remain the game's responsibility. No QR image or phone interaction is required.

Tables marked as handled by a player and tables currently being ordered by a waiter are left to that interaction. Completed orders are not repeated. Customers who have left, received their item, or exhausted enabled patience are excluded. A multiplayer client never sends orders; install this Mod on the host only.

### Installation

Requires **UE4SS experimental**. The checked API is `v3.0.1-1140-gf58e8f84`; old stable UE4SS 3.0.1 is not the target. Local game references were checked against Steam Build **25532071**, ProjectVersion **1.0.1.44eb**, Unreal Engine **5.4**. This is a development reference, not a gameplay test result.

1. Close the game and install the loader if needed.
2. Extract `ScanToOrder-0.1.1-dev.zip` so `Mods/ScanToOrder/Scripts/main.lua` and `Mods/ScanToOrder/enabled.txt` exist under the loader directory.
3. Start the game and enter your restaurant as the host or in single player. Ordering starts automatically.

The package contains original Mod scripts and documentation only. It does not include UE4SS or game files. The game retains its own translated order text; this Mod adds no in-game wording. Technical logs use `[ScanToOrder]`, including `START`, confirmed `ORDER` events and `ERROR` messages.

Lua-only updates support **Ctrl+R** when the loader's manual hot reload is configured. Complete copying both scripts before reloading. Confirmed orders stay recorded by the game and outstanding orders are read again. An uncertain engine call stops automation for the current world, including after reload; re-enter the session to reset it. First installation and removal require closing and restarting the game. To uninstall, remove `Mods/ScanToOrder` while the game is closed.

Build with `python scan-to-order-mod/build.py` from the repository root. Packages and SHA-256 files appear in `outputs/scan-to-order/`. Building does not install anything, change saves, or start or stop the game. See [development and validation](DEVELOPMENT.md#english).

## 中文

**版本：0.1.1-dev，待实机验收。**

在单人游戏或联机房主端，自动为已入座顾客提交食物和饮料订单，无需服务员或玩家操作点餐。沿用游戏 AI 已选好的餐品，不替顾客换菜、不修改菜单。

逐项检查食材库存：缺货的餐品保持待下单，有货的餐品可以先下；补货后每秒重新检查并继续提交尚未完成的订单。厨师、调酒师、设备和专长仍须满足游戏要求。烹饪、制作饮料、上菜、结账和顾客耐心仍按原游戏规则运行。无需实际二维码或手机交互。

标记为玩家负责的餐桌，以及服务员正在执行点餐的餐桌，会留给原交互处理。已下单的餐品不会重复提交；顾客离开、已获餐品或启用耐心且耐心耗尽后，不再下单。联机客机不会发送订单，只需房主安装。

### 安装

需要 **UE4SS experimental**，已核对 API 为 `v3.0.1-1140-gf58e8f84`，不以旧稳定版 UE4SS 3.0.1 为目标。本机参考核对基线为 Steam Build **25532071**、ProjectVersion **1.0.1.44eb**、Unreal Engine **5.4**；这不是游戏内测试通过的结论。

1. 关闭游戏，按需先安装加载器。
2. 解压 `ScanToOrder-0.1.1-dev.zip`，确保加载器目录下存在 `Mods/ScanToOrder/Scripts/main.lua` 和 `Mods/ScanToOrder/enabled.txt`。
3. 启动游戏，以房主或单人身份进入餐厅，自动点餐即可运行。

安装包仅含原创脚本和说明，不含 UE4SS 或游戏文件。订单文案沿用游戏当前语言，Mod 不新增游戏内文字。技术日志前缀为 `[ScanToOrder]`，包含 `START`、确认成功后的 `ORDER` 和 `ERROR`。

加载器配置手动热重载后，仅 Lua 更新支持 **Ctrl+R**。先完整复制两个脚本再重载。已完成的订单由游戏记录，未完成的订单重新读取；若引擎调用结果不确定，当前世界停止自动点餐，重载也不会重复发送，重新进入会话后重置。首次安装和卸载需关闭并重启游戏。卸载时，在游戏关闭后删除 `Mods/ScanToOrder`。

在仓库根目录执行 `python scan-to-order-mod/build.py`，ZIP 与 SHA-256 文件输出到 `outputs/scan-to-order/`。构建不安装、不改存档、不启动或关闭游戏。详见[开发与验收](DEVELOPMENT.md#中文)。
