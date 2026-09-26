# Scan to Order / 扫码点餐

[![Scan to Order / 扫码点餐 — AI-generated cover / AI 宣传封面](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/scan-to-order-mod/assets/cover.png?raw=1)](https://www.nexusmods.com/mods/7?game_id=10352)

[English](#english) · [中文](#中文)

## English

Automatically place seated customers' food and drink orders without a waiter or player taking them. No QR image or phone interaction is required.

**Version: 0.1.1.** Single player or multiplayer host only. Install it on the host; guests never send orders.

### How to use

1. Enter your restaurant in single player or as the multiplayer host. The Mod runs automatically while you control your character; it adds no menu, key, toggle, QR code or phone interaction.
2. Seat customers and let them choose food and drinks through the game's normal flow. You do not need to walk to each table and take the order, or assign a waiter just to place it.
3. Once a seated customer's chosen item is ready to be ordered, the Mod checks that table automatically, normally once per second. Eligible food and drink orders enter the game's existing preparation queues and receive the game's normal order notifications.
4. Continue preparing and serving the accepted orders through the normal game systems. The Mod takes orders; it does not make the food/drinks, carry them to tables or collect payment.
5. When the game creates a later food or drink order for a customer, the same checks apply again. Accepted orders are not submitted twice, and different tables require no separate activation.

The screenshot below shows the game's food and drink icons with green check marks. The Mod has no separate progress display or completion button; use the game's order notifications and preparation queues to follow accepted orders.

### When an order waits

- Customers keep their own dish choices. The Mod does not change the menu or choose substitutes.
- If an item lacks ingredients, that item waits while other available items can proceed. Restock it through the normal game controls; the Mod checks again and submits only the still-outstanding orders. There is no retry button and no automatic purchase of supplies.
- Normal chef, bartender, equipment and speciality requirements still apply. Food ordering requires a chef. Restore the requirements for the chosen item and it can be reconsidered on a later check; the Mod does not bypass the game's preparation rules.
- Tables marked for player service are left to the player. Tables a waiter is currently ordering from also wait. If you have taken responsibility for a table, complete its ordering through the normal interaction; the Mod does not remove that assignment.
- Actual game pause stops new requests. Unpause to continue. Customers must still be seated at their current table and waiting for that item; departed customers, already served items and groups ready to pay do not receive new orders.
- If patience is enabled and the order-wait timer has expired, the Mod does not place that order. Waiting for supplies or staff does not freeze the customer's patience.

In multiplayer, only the host needs to install it. Guest installations do not send orders, and installing it only on a guest does not automate the restaurant. There is no in-game off switch; close the game and remove the Mod to stop new automatic orders. Orders the game has already accepted remain available to prepare and serve.

### In-game screenshot

Food and drink order icons beside seated customers display green check marks.

![In-game food and drink order icons showing green check marks beside seated customers](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/scan-to-order-mod/assets/automatic-orders-gameplay.png?raw=1)

### Requirements

Windows x64 Parisian Bistro Simulator and **UE4SS experimental**. The checked loader build is `v3.0.1-1140-gf58e8f84`; stable UE4SS 3.0.1 is not supported. Other loader builds have not been verified. UE4SS is installed separately.

### Download

1. Open [Scan to Order 0.1.1](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/scan-to-order-v0.1.1).
2. Under **Assets**, download **`ScanToOrder-0.1.1.zip`** and `SHA256SUMS.txt`. Extract the Mod ZIP; GitHub's **Source code** archive is not an installable Mod.

If the package is missing or you cannot access it, see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english).

### Install

1. Close the game. In Steam, right-click **Parisian Bistro Simulator** → **Manage** → **Browse local files**. This opens the `<game>` folder used below.
2. Install the basic experimental UE4SS package using the [UE4SS installation guide](https://docs.ue4ss.com/dev/installation-guide.html), keeping that package's folder structure.
3. Copy the extracted **`ScanToOrder`** folder, with all its contents, into `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/`. If your loader uses another location, use its existing `Mods` folder instead.
4. Confirm these files exist, with no extra `ScanToOrder/ScanToOrder` folder:

   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/ScanToOrder/Scripts/main.lua`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/ScanToOrder/enabled.txt`

5. Start the game and enter your restaurant in single player or as the multiplayer host.

The included `enabled.txt` enables the Mod. Keep the whole Mod folder together; do not replace the loader's `mods.txt` or other Mods.

### Update or remove

**Update:** close the game, download and extract the new Mod ZIP, then copy its complete `ScanToOrder` folder into the same `Mods` folder and replace matching files. Start the game again.

**Remove:** close the game and delete only `Mods/ScanToOrder`. Leave UE4SS and other Mods in place. Removing the Mod stops new automatic orders. Orders already accepted by the game remain and can be prepared and served normally.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload). This is not required for normal installation or updates.

### Languages and help

Adds no in-game text. Dish names and order messages remain in the game's selected language; no language pack is needed. Technical logs remain English.

Game languages: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese.

If an order waits, first confirm you are the host and the game is unpaused, then check ingredients, staff, equipment, the customer's patience and whether a player or waiter is handling the table. Missing stock or a normal game refusal is checked again automatically; it does not require reinstalling or restarting the Mod. Available items may already have been ordered even if another item at the same table is still waiting.

An unexpected error can stop automatic ordering for the current restaurant to avoid repeating an order whose result is unclear. Check the game's existing queue before taking the order manually. Leave and re-enter the restaurant to reset that stopped session; restarting scripts alone does not clear it. If the stop persists, restart the game and include relevant `[ScanToOrder]` lines from `UE4SS.log` with a problem report.

In-game and multiplayer testing passed as reported by the maintainer on 2026-09-26; the [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/releases/validation.md#english) describes its scope.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/scan-to-order-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) · [MIT License](LICENSE)

## 中文

自动为已入座顾客提交食物和饮料订单，无需服务员或玩家点餐，也不需要实际二维码或手机交互。

**版本：0.1.1。** 仅单人或联机房主运行，只需房主安装，客机不会提交订单。

### 怎么使用

1. 以单人玩家或联机房主身份进入餐厅。能够控制角色后，Mod 自动运行，不增加菜单、按键、开关，也不需要二维码或手机交互。
2. 按游戏原有流程安排顾客入座，等待顾客选择食物和饮料。不需要逐桌走过去点餐，也不需要专门安排服务员来提交订单。
3. 已入座顾客的所选餐品进入待点餐状态后，Mod 会自动检查对应餐桌，通常每秒一次。条件满足的食物和饮料订单进入游戏原有制作队列，并产生原有的订单提醒。
4. 继续通过游戏原有系统制作并上餐。Mod 只负责提交订单，不会制作食物或饮料、把成品送到餐桌，也不会收款。
5. 游戏为顾客生成后续食物或饮料需求时，会再次按相同条件处理。已经提交的订单不会重复下单，不同餐桌无需分别启用。

下方实机图展示了游戏餐品与饮料图标上的绿色勾选标记。Mod 没有单独的进度界面或完成按钮，可通过游戏原有订单提醒和制作队列查看已接受的订单。

### 哪些情况会等待

- 沿用顾客已经选好的餐品，不修改菜单，也不替顾客换菜。
- 某项缺少原料时等待，其他有货项可以先下单。使用游戏原有操作补货后，Mod 会再次检查，只提交仍未下单的部分；无需重试按钮，也不会自动采购补货。
- 仍须满足厨师、调酒师、设备和专长等原有条件，食物下单需要有厨师。补齐所选餐品的条件后，后续检查会再次尝试，不会绕过游戏制作限制。
- 已标记为玩家负责的餐桌交给玩家处理，服务员正在点餐的餐桌也会等待。自己接手了餐桌时，请通过原有交互完成点餐；Mod 不会替你取消负责标记。
- 游戏实际暂停时停止新请求，恢复后继续。顾客必须仍在当前餐桌就座并等待对应餐品；顾客离开、该项已上餐或整组已可以结账时，不再生成新订单。
- 启用耐心且点餐等待时间已经耗尽时，不再提交该订单。等待库存或员工期间，顾客耐心不会被冻结。

联机时只需房主安装，客机安装不会发送订单，仅在客机安装也无法让餐厅自动点餐。没有游戏内停用开关；需要停止新的自动点餐时，关闭游戏并卸载 Mod。游戏已经接受的订单仍可正常制作和上菜。

### 实机截图

已入座顾客旁的餐品与饮料订单图标显示绿色勾选标记。

![实机画面：已入座顾客旁的餐品与饮料订单图标显示绿色勾选标记](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/scan-to-order-mod/assets/automatic-orders-gameplay.png?raw=1)

### 使用要求

Windows x64 版 Parisian Bistro Simulator，以及 **UE4SS experimental**。已核对的加载器版本为 `v3.0.1-1140-gf58e8f84`，不支持旧稳定版 UE4SS 3.0.1；其他加载器版本尚未验证。UE4SS 需单独安装。

### 下载

1. 打开 [扫码点餐 0.1.1](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/scan-to-order-v0.1.1)。
2. 在 **Assets** 中下载 **`ScanToOrder-0.1.1.zip`** 和 `SHA256SUMS.txt`。解压 Mod ZIP；GitHub 的 **Source code** 是源码，不能当作安装包。

找不到文件或无法访问时，见[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

### 安装

1. 关闭游戏。在 Steam 中右键 **Parisian Bistro Simulator** → **管理** → **浏览本地文件**，打开的就是下方所说的 `<game>` 游戏目录。
2. 按 [UE4SS 安装说明](https://docs.ue4ss.com/dev/installation-guide.html)安装 experimental 的基础包，保留该发行包自己的目录结构。
3. 将解压出的 **`ScanToOrder`** 文件夹连同全部内容复制到 `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/`。若加载器实际装在其他位置，请使用它已有的 `Mods` 文件夹。
4. 确认存在以下文件，不要多套一层 `ScanToOrder/ScanToOrder` 文件夹：

   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/ScanToOrder/Scripts/main.lua`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/ScanToOrder/enabled.txt`

5. 启动游戏，以单人玩家或联机房主身份进入餐厅。

包内的 `enabled.txt` 会启用 Mod。请完整保留 Mod 文件夹，不要替换加载器的整个 `mods.txt` 或其他 Mod。

### 更新与卸载

**更新：** 关闭游戏，下载并解压新版 Mod ZIP，把完整的 `ScanToOrder` 文件夹复制到原来的 `Mods` 目录并覆盖同名文件，再启动游戏。

**卸载：** 关闭游戏，只删除 `Mods/ScanToOrder`，保留 UE4SS 和其他 Mod。卸载后停止新的自动点餐；游戏已经接受的订单仍会保留，可正常制作和上菜。

可选操作：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。正常安装和更新不需要此操作。

### 语言与帮助

不新增游戏内文字，菜名和订单提示沿用游戏当前语言，无需语言包。技术日志保持英文。

游戏语言包括英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。

订单未提交时，先确认自己是房主且游戏未暂停，再检查原料、员工、设备、顾客耐心，以及餐桌是否由玩家或服务员处理。缺货或游戏正常拒绝下单时会自动复查，无需重装或重启 Mod。同桌某项还在等待时，其他有货项可能已经下单。

发生异常时，自动点餐可能停止处理当前餐厅，避免重复提交结果不明的订单。手动接手前先检查游戏现有队列；退出餐厅并重新进入后可重置这次会话的停止状态，仅重新加载脚本不会解除。仍然停止时请重启游戏，并在反馈中附上 `UE4SS.log` 中相关的 `[ScanToOrder]` 日志。

维护者于 2026-09-26 确认实机及联机测试全部通过并授权正式发布，具体范围见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/releases/validation.md#中文)。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/scan-to-order-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文) · [MIT 许可证](LICENSE)
