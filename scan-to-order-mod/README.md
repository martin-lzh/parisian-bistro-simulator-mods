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

Choose **one** download source; both provide the same Mod:

- **GitHub (no account needed):** open [Scan to Order 0.1.1](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/scan-to-order-v0.1.1), scroll to **Assets**, expand it if needed and click **ScanToOrder-0.1.1.zip**. `SHA256SUMS.txt` is an optional checksum file, not something to install. Do not choose **Source code**.
- **Nexus:** open the [Mod page](https://www.nexusmods.com/parisianbistrosimulator/mods/7), sign in or register a free account, select **Files → Main files → Manual download** for version **0.1.1**. Continue through the requirements notice if shown, select **Slow download** for a free account and wait for the ZIP. Keep the ZIP in your **Downloads** folder until the extraction step below.

### Install

These instructions start with only the Windows game installed. **Manual installation is free and does not require Vortex or a Nexus Premium subscription.** A web browser and Windows File Explorer are enough; Windows can extract ZIP files without WinRAR or 7-Zip. You do not need Git, Python, Visual Studio or Unreal Engine.

UE4SS is the **mod loader**: it starts the Mod when the game starts. Install it once for this game, then add any of the seven Mods to its `Mods` folder. Vortex is an optional **mod manager**, which copies and removes Mod files for you; it does not replace UE4SS.

1. **Exit the game completely.** In Steam, open **Library**, right-click **Parisian Bistro Simulator**, then choose **Manage → Browse local files**. The File Explorer window that opens is your game folder. Its name may be **Parisian Brasserie Simulator**. Do not use Documents or the save folder.
2. **Open the installation destination.** In that window, double-click **BrasserieSimulator**, then **Binaries**, then **Win64**. You should see **BrasserieSimulator-Win64-Shipping.exe** (Windows may hide `.exe`). Keep this window open. This is where the loader goes; do not put the loader beside the top-level `BrasserieSimulator.exe`.
3. **Download the loader.** Use [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip), the basic experimental build used as this project's reference. If the direct link fails, open [UE4SS experimental releases](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental), expand **Assets / Show all assets** and find that exact filename. Do not choose `zDEV`, `Source code` or the old stable `UE4SS_v3.0.1.zip`. Other experimental builds have not been verified for these Mods.
4. **Extract the loader ZIP.** In File Explorer's **Downloads** folder, right-click the downloaded ZIP → **Extract All… → Extract**. Open the extracted folder. Inside it, select **dwmapi.dll** and the entire **ue4ss** folder, right-click → **Copy**; return to the game's **Win64** window, right-click empty space → **Paste**. Copy both items themselves, not the outer folder named after the ZIP. There is no UE4SS installer to run. If you already have UE4SS installed, back up its folder and settings before replacing anything; keep your existing Mods.
5. **Check the loader location.** In **Win64**, `dwmapi.dll` must sit beside `BrasserieSimulator-Win64-Shipping.exe`. Open **ue4ss**: it must contain **UE4SS.dll**, **UE4SS-settings.ini** and **Mods**. If these are missing, repeat the extraction/copy step; an empty folder named `Mods` alone does not install the loader.
6. **Extract the Mod ZIP** downloaded above: right-click it → **Extract All… → Extract**. Open the extracted folder until you can see **ScanToOrder**, the folder that contains **Scripts** and **enabled.txt**. Windows may show `enabled` without `.txt`; that is normal.
7. **Copy the whole ScanToOrder folder.** Right-click it → **Copy**. In the game window, open **Win64 → ue4ss → Mods**, right-click empty space → **Paste**. Do not copy only `main.lua`, and do not place the ZIP itself in `Mods`.
8. **Check the result.** Open **Mods → ScanToOrder → Scripts**: **main.lua** must be there. Go back once to **ScanToOrder**: **enabled.txt** must be there beside **Scripts**. An extra `ScanToOrder/ScanToOrder` layer is incorrect. Leave `enabled.txt` as supplied, even if it is empty; it enables the Mod. Do not replace the loader's `mods.txt`.
9. **Start the game normally through Steam** and follow **How to use** above. Some Mods run in the background and have no startup message. Check the single-player/host/guest requirement at the top of this guide; the host is the player who opens the multiplayer restaurant for others to join.

The final entry point is `BrasserieSimulator/Binaries/Win64/ue4ss/Mods/ScanToOrder/Scripts/main.lua`, starting from the Steam game folder. If the feature does not work, close the game, recheck the two folder layouts above, then open `Win64/ue4ss/UE4SS.log` with Notepad and look for a recent timestamp or an error. See [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) before reinstalling.

**Using Vortex instead:** follow the [Vortex setup guide](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#english) to install Vortex, this game's extension and UE4SS first. Then import the original Mod ZIP, install, enable and deploy it. Use one installation method for this Mod. **The [collection](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz) currently requires an active Nexus Premium membership for one-click installation.** A free Nexus account or GitHub download can still be used for individual Mods; GitHub downloads need no account.

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

以下来源**二选一**即可，提供的是同一个 Mod：

- **GitHub（无需账号）：**打开 [扫码点餐 0.1.1](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/scan-to-order-v0.1.1)，向下找到并展开 **Assets（附件）**，点击 **ScanToOrder-0.1.1.zip**。`SHA256SUMS.txt` 是可选的校验文件，无需安装；不要下载 **Source code（源码）**。
- **Nexus：**打开 [Mod 页面](https://www.nexusmods.com/parisianbistrosimulator/mods/7)，登录或注册免费账号，在 **Files（文件）→ Main files（主要文件）** 找到 **0.1.1**，点击 **Manual download（手动下载）**。如出现前置要求提示，继续到下载页；免费账号选择 **Slow download（慢速下载）**，等待 ZIP 下载完成。先把 ZIP 保存在**下载**文件夹，下面再解压。

### 安装

以下步骤从电脑上只安装了 Windows 版游戏开始。**手动安装免费，不需要 Vortex，也不需要 Nexus Premium 会员。** 用浏览器和 Windows 文件资源管理器即可操作；Windows 自带 ZIP 解压功能，无需安装 WinRAR 或 7-Zip，也不需要 Git、Python、Visual Studio 或虚幻引擎。

UE4SS 是**加载器**，作用是在启动游戏时运行 Mod。每个游戏安装目录只需装一次，之后把所需 Mod 加入它的 `Mods` 文件夹即可。Vortex 是可选的 **Mod 管理器**，负责复制和移除 Mod 文件，不能代替 UE4SS。

1. **完全退出游戏。** 在 Steam 打开**库**，右键 **Parisian Bistro Simulator（法式小馆儿模拟器）→ 管理 → 浏览本地文件**。弹出的文件资源管理器窗口就是游戏目录，文件夹名可能是 **Parisian Brasserie Simulator**。不是“文档”或存档文件夹。
2. **打开安装位置。** 在该窗口依次双击 **BrasserieSimulator → Binaries → Win64**，应该能看到 **BrasserieSimulator-Win64-Shipping.exe**（Windows 可能隐藏 `.exe` 后缀）。保留此窗口，加载器就放在这里；不要放在最外层 `BrasserieSimulator.exe` 旁边。
3. **下载加载器。** 点击 [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip)，这是本项目核对过的 experimental 基础包。若直链失效，打开 [UE4SS experimental 发布页](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental)，展开 **Assets / Show all assets（附件／显示全部附件）**，找到这个完整文件名。不要下载 `zDEV`、`Source code`，也不要使用旧稳定版 `UE4SS_v3.0.1.zip`。其他 experimental 构建尚未核验。
4. **解压并放入加载器。** 在文件资源管理器的**下载**文件夹里，右键刚下载的 ZIP → **全部解压缩 → 提取**。打开解压后的文件夹，选中里面的 **dwmapi.dll** 和整个 **ue4ss** 文件夹，右键**复制**；回到游戏的 **Win64** 窗口，在空白处右键**粘贴**。复制这两个项目本身，不要把以压缩包命名的外层文件夹一起套进去。UE4SS 没有需要双击运行的安装程序。已经安装过加载器时，替换前备份其文件夹和设置，并保留现有 Mod。
5. **检查加载器位置。** **Win64** 中的 `dwmapi.dll` 应与 `BrasserieSimulator-Win64-Shipping.exe` 并排。打开 **ue4ss**，里面应有 **UE4SS.dll**、**UE4SS-settings.ini** 和 **Mods**。缺少这些内容时回到上一步重新解压、复制；只新建一个空的 `Mods` 文件夹不能装好加载器。
6. **解压上面下载的 Mod ZIP。** 右键 ZIP → **全部解压缩 → 提取**。打开解压后的文件夹，找到 **ScanToOrder** 文件夹；它里面应有 **Scripts** 和 **enabled.txt**。Windows 可能只显示 `enabled` 而隐藏 `.txt`，属于正常情况。
7. **复制整个 ScanToOrder 文件夹。** 右键它 → **复制**。在游戏窗口打开 **Win64 → ue4ss → Mods**，在空白处右键**粘贴**。不要只复制 `main.lua`，也不要把 ZIP 本身放进去。
8. **检查安装结果。** 依次打开 **Mods → ScanToOrder → Scripts**，应能看到 **main.lua**；返回一层到 **ScanToOrder**，应能看到与 **Scripts** 并排的 **enabled.txt**。不要多套成 `ScanToOrder/ScanToOrder`。即使 `enabled.txt` 是空文件也应原样保留，它用于启用 Mod；不要替换加载器的 `mods.txt`。
9. **从 Steam 正常启动游戏**，按上方“怎么使用”操作。有的 Mod 在后台工作，没有启动提示。先核对本说明开头的单人／房主／客机要求；房主指开启联机餐厅、让其他人加入的玩家。

从 Steam 打开的游戏目录算起，最终脚本位置是 `BrasserieSimulator/Binaries/Win64/ue4ss/Mods/ScanToOrder/Scripts/main.lua`。功能未生效时，先退出游戏、核对上述加载器和 Mod 两处目录，再用记事本打开 `Win64/ue4ss/UE4SS.log`，查看有没有本次运行的时间或错误。重装前可查看[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

**如果选择 Vortex：** 先按 [Vortex 安装说明](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#中文)装好 Vortex、本游戏扩展和 UE4SS，再导入原始 Mod ZIP，安装、启用并部署。同一个 Mod 只使用一种安装方式。**目前通过 [Nexus 合集](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz)一键安装需要有效的 Nexus Premium 会员。** 免费 Nexus 账号仍可逐个下载 Mod；GitHub 下载无需账号。

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
