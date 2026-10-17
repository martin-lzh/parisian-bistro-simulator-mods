# Smart Delivery / 配送随心

[![Smart Delivery / 配送随心 — AI-generated cover / AI 宣传封面](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/smart-delivery-mod/assets/cover.png?raw=1)](https://www.nexusmods.com/mods/4?game_id=10352)

[English](#english) · [中文](#中文)

## English

Choose Free service, Budget delivery or Premium delivery for automatic smart orders on the restaurant computer.

**Version: 0.1.5.** Single player or multiplayer host. Only the host installs it; guests don't need it and can't change the delivery choice.

### How to use

1. In single player, or as the multiplayer host, open the restaurant computer's **Menu** app and click **Automatic Smart Order**.
2. To let the game restock automatically, check **Enable automatic ordering**, then set **Minimum order value (€)** and **Order immediately when out of stock** (see the table below).
3. Above **Save** and **Cancel**, open **Delivery method** and pick **Free service**, **Budget delivery** or **Premium delivery**.
4. Click **Save**. This applies both the game's settings and your delivery choice; picking from the list alone applies nothing. If an order is already due when you save, the game may place it straight away with the new method.
5. Close the computer and keep playing. Every later automatic order uses the saved method. Reopen **Automatic Smart Order** any time to check it.

- **Cancel** discards unsaved changes. Reopening the window shows the last saved choice.
- To stop automatic ordering, uncheck **Enable automatic ordering** and click **Save**. Your delivery choice is kept for when you turn it back on.
- There is no hotkey or separate settings window.

### Settings and delivery choices

The first three settings are the game's own. The Mod adds **Delivery method**.

| Setting | What it does |
| --- | --- |
| Enable automatic ordering | The game watches stock and orders supplies automatically. Picking a delivery method doesn't turn this on for you. |
| Minimum order value (€) | An automatic order waits until the goods total reaches this amount. Shipping fees don't count toward it. |
| Order immediately when out of stock | A stockout can trigger an order below the minimum. The game still checks its other conditions and your money. |
| Delivery method | The delivery service used whenever the game places an automatic smart order. |

| Delivery method | Unloading staff |
| --- | --- |
| Free service | None; you unload the delivery yourself. |
| Budget delivery | 1 worker. |
| Premium delivery | 4 workers. Used until you save a different choice. |

- Service fees, difficulty adjustments and night surcharges follow the game's rules. With Free service you still pay for the goods.
- The chosen method is used for small and large automatic orders alike.

### What the Mod changes

The Mod only picks the delivery method for the game's existing automatic smart orders. The game still decides when to order, what and how much to buy, whether you can afford it and whether delivery is available. Saving a delivery method doesn't buy anything by itself.

- Manual ingredient orders and furniture deliveries keep their own delivery choice.
- Orders already placed keep the method they were placed with.
- When the game locks the automatic-order settings, the **Delivery method** list is locked too.

### Multiplayer and saved choice

- In multiplayer, only the host's choice counts. Guests don't need the Mod, and can't change the setting even if they install it.
- Your choice survives restarts and applies to every restaurant on this installation (it isn't stored in each save).
- It is saved in `SmartDelivery/Scripts/delivery-preference.txt`. Keep this file when updating. The Mod folder must be writable.

### In-game screenshots

The automatic smart-order settings include a **Delivery method** field, shown here with **Premium delivery** selected.

![Automatic Smart Order settings with the Delivery method field set to Premium delivery](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/smart-delivery-mod/assets/delivery-settings-gameplay.png?raw=1)

Open the selector to choose **Free service**, **Budget delivery** or **Premium delivery**.

![Expanded delivery selector showing Free service, Budget delivery and Premium delivery](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/smart-delivery-mod/assets/delivery-selector-gameplay.png?raw=1)

### Requirements

- Windows version of Parisian Bistro Simulator, up to game version 1.0.2.44eb (Steam Build 25822788).
- [UE4SS experimental](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental) `v3.0.1-1140-gf58e8f84`, installed separately (see **Install**). The older stable UE4SS 3.0.1 does not work.
- Single player or multiplayer host. The Mod ZIP already includes its helper file `Scripts/delivery_bridge.dll`.

### Download

Pick either source; both have the same file.

- **GitHub (no account needed):** open [Smart Delivery 0.1.5](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/smart-delivery-v0.1.5) and download **SmartDelivery-0.1.5.zip** under **Assets**. Don't pick **Source code**.
- **Nexus:** open the [Mod page](https://www.nexusmods.com/parisianbistrosimulator/mods/4), go to **Files → Main files → Manual download**, then choose **Slow download** if you have a free account.

### Install

Manual installation is free and needs neither Vortex nor Nexus Premium.

UE4SS is the mod loader that runs Mods when the game starts. Install it once, then put Mods in its `Mods` folder. If UE4SS is already installed, start at step 6.

1. **Close the game.** In Steam, open **Library**, right-click **Parisian Bistro Simulator** → **Manage → Browse local files**. This opens the game folder (it may be named **Parisian Brasserie Simulator**).
2. **Open BrasserieSimulator → Binaries → Win64.** You should see **BrasserieSimulator-Win64-Shipping.exe** (Windows may hide the `.exe`). Keep this window open; the loader goes here.
3. **Download UE4SS:** [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip). If the link doesn't open, find that exact file under **Assets** on the [UE4SS experimental release page](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental). Don't use `zDEV`, `Source code` or the old stable `UE4SS_v3.0.1.zip`.
4. **Copy the loader into Win64.** Right-click the ZIP → **Extract All… → Extract**. From the extracted folder, copy **dwmapi.dll** and the **ue4ss** folder and paste both into **Win64**. If you are replacing an existing UE4SS, back up its folder first.
5. **Check the loader:** `dwmapi.dll` sits next to `BrasserieSimulator-Win64-Shipping.exe`, and the **ue4ss** folder contains **UE4SS.dll**, **UE4SS-settings.ini** and **Mods**.
6. **Extract the Mod ZIP** and open it until you see the **SmartDelivery** folder, which contains **Scripts** and **enabled.txt**.
7. **Copy the whole SmartDelivery folder** into **Win64 → ue4ss → Mods**.
8. **Check the Mod:** `Mods/SmartDelivery/Scripts/main.lua`, `Mods/SmartDelivery/Scripts/delivery_bridge.dll` and `Mods/SmartDelivery/enabled.txt` should exist (not `SmartDelivery/SmartDelivery`). Keep `enabled.txt` even if it is empty, and keep `delivery_bridge.dll` in **Scripts**.
9. **Start the game through Steam** and follow **How to use** above.

If the Mod doesn't work, close the game, recheck steps 5 and 8, then see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english).

**Using Vortex instead:** set up Vortex, the game extension and UE4SS with the [Vortex guide](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#english), then import the Mod ZIP, enable it and deploy. Install each Mod either with Vortex or manually, not both. One-click install of the [collection](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz) requires Nexus Premium.

### Update or remove

**Update:** close the game and back up `SmartDelivery/Scripts/delivery-preference.txt`. Extract the new Mod ZIP, copy its whole `SmartDelivery` folder into the same `Mods` folder and replace the existing files. Put your preference file back if it was replaced, then start the game.

**Remove:** close the game and delete only `Mods/SmartDelivery`, leaving UE4SS and other Mods in place. Automatic orders go back to the game's own delivery choice, and your saves keep working. Deleting the folder also deletes your saved delivery choice, so back up `delivery-preference.txt` first if you want it later.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload). This is not required for normal installation or updates.

### Languages and help

Delivery names and the new field label follow the game language: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese.

- **The Delivery method list is missing:** make sure you are the host and copied the whole `SmartDelivery` folder, including `Scripts/delivery_bridge.dll`.
- **Your choice isn't kept:** make sure the Mod folder can be written to.
- **Reporting a problem:** include the `[SmartDelivery]` lines from `Win64/ue4ss/UE4SS.log` and, if it exists, `SmartDelivery/Scripts/bridge-status.txt`.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/smart-delivery-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) · [MIT License](LICENSE)

## 中文

在餐厅电脑的自动智能订购设置中，选择免费服务、经济型配送或高级配送。

**版本：0.1.5。** 适用于单人游戏或联机房主。只需房主安装；客机无需安装，也不能修改配送选择。

### 怎么使用

1. 在单人游戏中，或以联机房主身份，打开餐厅电脑的 **菜单（Menu）** 应用，点击 **自动智能订购（Automatic Smart Order）**。
2. 想让游戏自动补货，就勾选 **启用自动订购（Enable automatic ordering）**，再设置 **最低订购金额（Minimum order value）** 和 **缺货时立即订购（Order immediately when out of stock）**（见下表）。
3. 在 **保存（Save）** 和 **取消（Cancel）** 上方展开 **配送方式（Delivery method）**，选择 **免费服务**、**经济型配送** 或 **高级配送**。
4. 点击 **保存**，游戏设置和配送选择一起生效；只在列表里选中而不保存，不会生效。如果保存时已经满足下单条件，游戏可能马上用新的配送方式下单。
5. 关掉电脑继续经营即可，之后的自动订单都会用已保存的配送方式。随时可以重新打开 **自动智能订购** 查看。

- 点击 **取消** 会放弃未保存的修改，再次打开窗口时显示上次保存的选择。
- 要停止自动订购，取消勾选 **启用自动订购** 并点击 **保存**；配送选择会保留，下次启用时继续使用。
- 没有快捷键，也没有单独的设置窗口。

### 设置项与配送选择

前三项是游戏自带的设置，Mod 新增 **配送方式**。

| 设置 | 作用 |
| --- | --- |
| 启用自动订购 | 游戏监测库存并自动采购。选了配送方式不会自动勾选此项。 |
| 最低订购金额 | 商品金额达到设定值才自动下单，配送费不计入。 |
| 缺货时立即订购 | 缺货时可以低于最低金额下单，游戏仍会检查其他下单条件和余额。 |
| 配送方式 | 游戏发出自动智能订单时使用的配送服务。 |

| 配送方式 | 卸货人员 |
| --- | --- |
| 免费服务（Free service） | 无，需要自己卸货。 |
| 经济型配送（Budget delivery） | 1 名卸货员。 |
| 高级配送（Premium delivery） | 4 名卸货员；保存其他选择前默认使用此项。 |

- 服务费、难度调整和夜间附加费按游戏规则计算。选择免费服务，商品仍要照常付钱。
- 无论自动订单大小，都使用所选的配送方式。

### Mod 改变了什么

Mod 只为游戏原有的自动智能订购选择配送方式。什么时候下单、买什么、买多少、余额够不够、能否配送，仍由游戏决定。只保存配送方式不会购买任何商品。

- 手动购买食材和家具时，仍使用各自的配送选项。
- 已经发出的订单保持下单时的配送方式。
- 游戏锁定自动订购设置时，**配送方式** 列表也会一起锁定。

### 联机与偏好保存

- 联机时只看房主的选择。客机无需安装；即使安装了也不能修改此设置。
- 选择在重启后保留，同一安装下的所有餐厅共用（不随单个存档保存）。
- 选择保存在 `SmartDelivery/Scripts/delivery-preference.txt`，更新时请保留此文件。Mod 文件夹需要可写入。

### 实机截图

自动智能订购设置中新增 **Delivery method（配送方式）** 字段，图中选择的是 **Premium delivery（高级配送）**。

![实机画面：自动智能订购设置显示配送方式字段，当前为高级配送](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/smart-delivery-mod/assets/delivery-settings-gameplay.png?raw=1)

展开列表可选择 **Free service（免费服务）**、**Budget delivery（经济型配送）** 或 **Premium delivery（高级配送）**。

![实机画面：展开配送方式列表，显示免费服务、经济型配送和高级配送](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/smart-delivery-mod/assets/delivery-selector-gameplay.png?raw=1)

### 使用要求

- Windows 版 Parisian Bistro Simulator，支持至游戏版本 1.0.2.44eb（Steam Build 25822788）。
- [UE4SS experimental](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental) `v3.0.1-1140-gf58e8f84`，需单独安装（见“安装”）。旧稳定版 UE4SS 3.0.1 无法使用。
- 单人游戏或联机房主。Mod ZIP 已自带辅助文件 `Scripts/delivery_bridge.dll`。

### 下载

以下两个来源任选其一，文件相同。

- **GitHub（无需账号）：**打开 [配送随心 0.1.5](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/smart-delivery-v0.1.5)，在 **Assets（附件）** 下载 **SmartDelivery-0.1.5.zip**。不要选 **Source code（源码）**。
- **Nexus：**打开 [Mod 页面](https://www.nexusmods.com/parisianbistrosimulator/mods/4)，进入 **Files（文件）→ Main files（主要文件）→ Manual download（手动下载）**；免费账号选择 **Slow download（慢速下载）**。

### 安装

手动安装免费，不需要 Vortex，也不需要 Nexus Premium。

UE4SS 是 Mod 加载器，负责在游戏启动时运行 Mod。只需安装一次，之后把 Mod 放进它的 `Mods` 文件夹。已经装好 UE4SS 的，从第 6 步开始。

1. **退出游戏。** 在 Steam **库**中右键 **Parisian Bistro Simulator（法式小馆儿模拟器）→ 管理 → 浏览本地文件**，打开游戏目录（文件夹名可能是 **Parisian Brasserie Simulator**）。
2. **依次打开 BrasserieSimulator → Binaries → Win64**，能看到 **BrasserieSimulator-Win64-Shipping.exe**（Windows 可能隐藏 `.exe` 后缀）。保持这个窗口打开，加载器就装在这里。
3. **下载 UE4SS：**[UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip)。链接打不开时，到 [UE4SS experimental 发布页](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental)的 **Assets** 中找同名文件。不要下载 `zDEV`、`Source code` 或旧稳定版 `UE4SS_v3.0.1.zip`。
4. **把加载器放进 Win64。** 右键 ZIP → **全部解压缩 → 提取**，从解压出的文件夹中复制 **dwmapi.dll** 和 **ue4ss** 文件夹，粘贴到 **Win64**。替换已有的 UE4SS 前，先备份原文件夹。
5. **检查加载器：**`dwmapi.dll` 与 `BrasserieSimulator-Win64-Shipping.exe` 在同一层；**ue4ss** 文件夹里有 **UE4SS.dll**、**UE4SS-settings.ini** 和 **Mods**。
6. **解压 Mod ZIP**，打开到能看到 **SmartDelivery** 文件夹，里面有 **Scripts** 和 **enabled.txt**。
7. **把整个 SmartDelivery 文件夹**复制到 **Win64 → ue4ss → Mods**。
8. **检查 Mod：**应有 `Mods/SmartDelivery/Scripts/main.lua`、`Mods/SmartDelivery/Scripts/delivery_bridge.dll` 和 `Mods/SmartDelivery/enabled.txt`（不要多套一层 `SmartDelivery/SmartDelivery`）。`enabled.txt` 即使是空文件也要保留，`delivery_bridge.dll` 也要留在 **Scripts** 中。
9. **从 Steam 启动游戏**，按上方“怎么使用”操作。

不生效时，先退出游戏，核对第 5、8 步，再查看[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

**改用 Vortex：**先按 [Vortex 安装说明](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#中文)装好 Vortex、游戏扩展和 UE4SS，再导入 Mod ZIP，启用并部署。同一个 Mod 只用 Vortex 或手动其中一种方式安装。通过 [Nexus 合集](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz)一键安装需要 Nexus Premium。

### 更新与卸载

**更新：**关闭游戏，先备份 `SmartDelivery/Scripts/delivery-preference.txt`。解压新版 Mod ZIP，把整个 `SmartDelivery` 文件夹复制到原来的 `Mods` 文件夹并覆盖同名文件。如果偏好文件被覆盖，再把备份放回去，然后启动游戏。

**卸载：**关闭游戏，只删除 `Mods/SmartDelivery`，保留 UE4SS 和其他 Mod。自动订单会恢复使用游戏原本的配送选择，存档照常可用。删除文件夹会一并删除保存的配送选择，以后还想用的话，先备份 `delivery-preference.txt`。

可选操作：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。正常安装和更新不需要此操作。

### 语言与帮助

配送名称和新增字段标题跟随游戏语言：英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。

- **看不到配送方式列表：**确认自己是房主，并且复制了完整的 `SmartDelivery` 文件夹，包括 `Scripts/delivery_bridge.dll`。
- **选择没有保留：**检查 Mod 文件夹是否可以写入。
- **反馈问题：**附上 `Win64/ue4ss/UE4SS.log` 中的 `[SmartDelivery]` 日志；如果有 `SmartDelivery/Scripts/bridge-status.txt`，也一并附上。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/smart-delivery-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文) · [MIT 许可证](LICENSE)
