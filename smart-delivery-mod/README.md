# Smart Delivery / 配送随心

[![Smart Delivery / 配送随心 — AI-generated cover / AI 宣传封面](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/smart-delivery-mod/assets/cover.png?raw=1)](https://www.nexusmods.com/mods/4?game_id=10352)

[English](#english) · [中文](#中文)

## English

Choose Free service, Budget delivery or Premium delivery for automatic smart orders on the restaurant computer.

**Version: 0.1.5.** Single player or multiplayer host only. Only the host needs to install it; guests cannot edit the Mod's delivery choice.

### How to use

1. In single player, or as the multiplayer host, open the restaurant computer's **Menu** app. Click the game's **Automatic Smart Order** button to open its settings window.
2. Check **Enable automatic ordering** if you want the game to replenish supplies automatically. Set **Minimum order value (€)** and **Order immediately when out of stock** as described below.
3. At the bottom of this window, above **Save** and **Cancel**, open **Delivery method** and select **Free service**, **Budget delivery** or **Premium delivery**.
4. Click **Save** to apply both the game's automatic-order settings and the Mod's delivery choice. Selecting an item in the dropdown alone does not apply it. If an order is already eligible when you save, the game can place it immediately using the saved delivery method.
5. Reopen **Automatic Smart Order** to check the saved selection. Once saved, you can close the computer and continue playing; future automatic orders use this choice without another click.

Click **Cancel** to discard the unsaved settings and delivery selection. Reopening the window restores the last saved delivery choice. To stop automatic ordering, uncheck **Enable automatic ordering** and click **Save**; the delivery preference remains available for when you enable it again. The Mod adds no gameplay hotkey or separate settings window.

### Settings and delivery choices

The first three controls belong to the game. The Mod adds only **Delivery method**.

| Setting | What it does |
| --- | --- |
| Enable automatic ordering | Lets the game monitor stock and place supply orders automatically. Choosing a delivery method does not enable this option for you. |
| Minimum order value (€) | Holds an automatic order until its item subtotal reaches the specified amount. This is a purchase threshold, not a limit on shipping fees or total spending. |
| Order immediately when out of stock | Allows a stockout to trigger an order below that purchase threshold. It does not bypass the game's other ordering conditions or money checks. |
| Delivery method | Selects the service used when the game actually places an automatic smart order. |

| Delivery method | Unloading staff |
| --- | --- |
| Free service | No unloading worker; handle the delivery yourself. |
| Budget delivery | 1 unloading worker. |
| Premium delivery | 4 unloading workers. This is the initial preference if no preference has been saved. |

Service fees, difficulty adjustments and night surcharges use the game's rules. Choosing Free service does not make the supplies free. The selected method applies to both small and large automatic orders; the Mod does not choose a different service based on order size.

### What changes and what stays under your control

Automatic smart ordering is already a game feature. This Mod changes its delivery choice; it does not create an additional ordering system. Stock calculations, order quantities, purchase thresholds, available funds and delivery availability remain controlled by the game. If no automatic order is due, saving a delivery method alone does not buy supplies.

Manual ingredient orders and furniture deliveries keep their own delivery choices. An order already placed is not changed by selecting another method. The dropdown follows the game's settings lock and cannot be edited while the game locks automatic-order settings; it does not unlock unavailable game features.

Only the host's installation controls the preference in multiplayer. Guests do not need the Mod and cannot change this setting, even if they install it. Your saved choice survives restarts and is shared by this installation's restaurants, rather than being stored separately in each game save. It is stored in `SmartDelivery/Scripts/delivery-preference.txt`; keep that file when updating. The Mod folder must be writable.

### In-game screenshots

The automatic smart-order settings include a **Delivery method** field, shown here with **Premium delivery** selected.

![Automatic Smart Order settings with the Delivery method field set to Premium delivery](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/smart-delivery-mod/assets/delivery-settings-gameplay.png?raw=1)

Open the selector to choose **Free service**, **Budget delivery** or **Premium delivery**.

![Expanded delivery selector showing Free service, Budget delivery and Premium delivery](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/smart-delivery-mod/assets/delivery-selector-gameplay.png?raw=1)

### Requirements

Windows x64 Parisian Bistro Simulator and **UE4SS experimental**. The checked loader build is `v3.0.1-1140-gf58e8f84`; stable UE4SS 3.0.1 is not supported. Other loader builds have not been verified. UE4SS is installed separately. The ready-to-use Mod ZIP includes its helper; no compiling is needed.

### Download

Choose **one** download source; both provide the same Mod:

- **GitHub (no account needed):** open [Smart Delivery 0.1.5](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/smart-delivery-v0.1.5), scroll to **Assets**, expand it if needed and click **SmartDelivery-0.1.5.zip**. `SHA256SUMS.txt` is an optional checksum file, not something to install. Do not choose **Source code**.
- **Nexus:** open the [Mod page](https://www.nexusmods.com/parisianbistrosimulator/mods/4), sign in or register a free account, select **Files → Main files → Manual download** for version **0.1.5**. Continue through the requirements notice if shown, select **Slow download** for a free account and wait for the ZIP. Keep the ZIP in your **Downloads** folder until the extraction step below.

### Install

These instructions start with only the Windows game installed. **Manual installation is free and does not require Vortex or a Nexus Premium subscription.** A web browser and Windows File Explorer are enough; Windows can extract ZIP files without WinRAR or 7-Zip. You do not need Git, Python, Visual Studio or Unreal Engine.

UE4SS is the **mod loader**: it starts the Mod when the game starts. Install it once for this game, then add any of the seven Mods to its `Mods` folder. Vortex is an optional **mod manager**, which copies and removes Mod files for you; it does not replace UE4SS.

1. **Exit the game completely.** In Steam, open **Library**, right-click **Parisian Bistro Simulator**, then choose **Manage → Browse local files**. The File Explorer window that opens is your game folder. Its name may be **Parisian Brasserie Simulator**. Do not use Documents or the save folder.
2. **Open the installation destination.** In that window, double-click **BrasserieSimulator**, then **Binaries**, then **Win64**. You should see **BrasserieSimulator-Win64-Shipping.exe** (Windows may hide `.exe`). Keep this window open. This is where the loader goes; do not put the loader beside the top-level `BrasserieSimulator.exe`.
3. **Download the loader.** Use [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip), the basic experimental build used as this project's reference. If the direct link fails, open [UE4SS experimental releases](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental), expand **Assets / Show all assets** and find that exact filename. Do not choose `zDEV`, `Source code` or the old stable `UE4SS_v3.0.1.zip`. Other experimental builds have not been verified for these Mods.
4. **Extract the loader ZIP.** In File Explorer's **Downloads** folder, right-click the downloaded ZIP → **Extract All… → Extract**. Open the extracted folder. Inside it, select **dwmapi.dll** and the entire **ue4ss** folder, right-click → **Copy**; return to the game's **Win64** window, right-click empty space → **Paste**. Copy both items themselves, not the outer folder named after the ZIP. There is no UE4SS installer to run. If you already have UE4SS installed, back up its folder and settings before replacing anything; keep your existing Mods.
5. **Check the loader location.** In **Win64**, `dwmapi.dll` must sit beside `BrasserieSimulator-Win64-Shipping.exe`. Open **ue4ss**: it must contain **UE4SS.dll**, **UE4SS-settings.ini** and **Mods**. If these are missing, repeat the extraction/copy step; an empty folder named `Mods` alone does not install the loader.
6. **Extract the Mod ZIP** downloaded above: right-click it → **Extract All… → Extract**. Open the extracted folder until you can see **SmartDelivery**, the folder that contains **Scripts** and **enabled.txt**. Windows may show `enabled` without `.txt`; that is normal.
7. **Copy the whole SmartDelivery folder.** Right-click it → **Copy**. In the game window, open **Win64 → ue4ss → Mods**, right-click empty space → **Paste**. Do not copy only `main.lua`, and do not place the ZIP itself in `Mods`. Also keep **Scripts/delivery_bridge.dll** in place; it is included in the ZIP.
8. **Check the result.** Open **Mods → SmartDelivery → Scripts**: **main.lua** must be there. Go back once to **SmartDelivery**: **enabled.txt** must be there beside **Scripts**. An extra `SmartDelivery/SmartDelivery` layer is incorrect. Leave `enabled.txt` as supplied, even if it is empty; it enables the Mod. Do not replace the loader's `mods.txt`.
9. **Start the game normally through Steam** and follow **How to use** above. Some Mods run in the background and have no startup message. Check the single-player/host/guest requirement at the top of this guide; the host is the player who opens the multiplayer restaurant for others to join.

The final entry point is `BrasserieSimulator/Binaries/Win64/ue4ss/Mods/SmartDelivery/Scripts/main.lua`, starting from the Steam game folder. If the feature does not work, close the game, recheck the two folder layouts above, then open `Win64/ue4ss/UE4SS.log` with Notepad and look for a recent timestamp or an error. See [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) before reinstalling.

**Using Vortex instead:** follow the [Vortex setup guide](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#english) to install Vortex, this game's extension and UE4SS first. Then import the original Mod ZIP, install, enable and deploy it. Use one installation method for this Mod. **The [collection](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz) currently requires an active Nexus Premium membership for one-click installation.** A free Nexus account or GitHub download can still be used for individual Mods; GitHub downloads need no account.

### Update or remove

**Update:** close the game and back up `SmartDelivery/Scripts/delivery-preference.txt`. Download and extract the new Mod ZIP, copy its complete `SmartDelivery` folder into the same `Mods` folder and replace matching files. Keep or restore your preference file, then start the game again.

**Remove:** close the game and delete only `Mods/SmartDelivery`. Leave UE4SS and other Mods in place. The game returns to its normal automatic delivery selection. Deleting the whole folder also deletes the saved Mod preference, so back up the preference file first if you want to reuse it later. Game saves need no conversion.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload). This is not required for normal installation or updates.

### Languages and help

The delivery names use the game's translations, and the added field label follows the game language. No language pack or separate setting is needed. Technical logs remain English.

Game languages: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese.

If the selector is missing, confirm you are host and installed the complete folder, including the bundled helper. If the saved choice is not retained, check that the folder can be written to. For a problem report, include relevant `[SmartDelivery]` lines from `UE4SS.log` and `SmartDelivery/Scripts/bridge-status.txt` if it exists.

In-game and multiplayer testing passed as reported by the maintainer on 2026-09-26; the [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/releases/validation.md#english) describes its scope.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/smart-delivery-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) · [MIT License](LICENSE)

## 中文

在餐厅电脑的自动智能订购设置中，选择免费服务、经济型配送或高级配送。

**版本：0.1.5。** 仅单人或联机房主可设置，只需房主安装；客机不能修改 Mod 配送选项。

### 怎么使用

1. 在单人游戏中，或以联机房主身份打开餐厅电脑的 **菜单（Menu）** 应用，点击游戏原有的 **自动智能订购（Automatic Smart Order）** 按钮，进入设置窗口。
2. 如需让游戏自动补货，勾选 **启用自动订购（Enable automatic ordering）**，再按下方说明设置 **最低订购金额（Minimum order value）** 与 **缺货时立即订购（Order immediately when out of stock）**。
3. 在窗口底部、**保存（Save）** 与 **取消（Cancel）** 上方展开 **配送方式（Delivery method）**，选择 **免费服务**、**经济型配送** 或 **高级配送**。
4. 点击 **保存**，应用游戏的自动订购设置和 Mod 的配送选择。只改变下拉框、尚未保存时不会生效。如果此时已经满足下单条件，游戏可能立即使用刚保存的配送方式下单。
5. 重新打开 **自动智能订购**，即可核对已保存的选择。保存后可以关闭电脑继续经营，之后的自动订单会沿用该配送方式，无需每次点击。

点击 **取消** 会放弃未保存的设置与配送选择；再次打开窗口时恢复上次保存的配送方式。如需停止自动订购，取消勾选 **启用自动订购** 后点击 **保存**；配送偏好仍会保留，供再次启用时使用。Mod 没有额外的游戏操作快捷键或独立设置窗口。

### 设置项与配送选择

前三项为游戏自带设置，Mod 只新增 **配送方式**。

| 设置 | 实际作用 |
| --- | --- |
| 启用自动订购 | 允许游戏监测库存并自动采购。选择配送方式不会替你勾选此项。 |
| 最低订购金额 | 待采购商品的小计达到设定金额才自动下单。这是采购门槛，不是配送费或总花费上限。 |
| 缺货时立即订购 | 缺货时允许低于上述采购门槛下单，但不会跳过游戏的其他下单条件或余额检查。 |
| 配送方式 | 决定游戏实际发出自动智能订单时采用哪种配送服务。 |

| 配送方式 | 卸货人员 |
| --- | --- |
| 免费服务（Free service） | 没有卸货员，需要自行处理到货。 |
| 经济型配送（Budget delivery） | 1 名卸货员。 |
| 高级配送（Premium delivery） | 4 名卸货员；尚未保存过偏好时默认使用此项。 |

服务费、难度调整和夜间附加费仍按游戏规则计算；免费服务不代表商品免费。大小自动订单都使用所选方式，Mod 不会再按订单规模切换配送服务。

### 功能范围与联机行为

自动智能订购原本就是游戏功能，Mod 为它增加配送选择，并未另外建立一套下单机制。库存计算、采购数量、金额门槛、可用余额和配送可用性仍由游戏控制；未满足自动下单条件时，只保存配送方式不会购买商品。

手动购买食材和家具时，仍使用各自的配送选项。改变配送方式不会修改已经发出的订单。原版自动订购设置被锁定时，下拉框也会禁用；Mod 不会解锁尚不可用的游戏功能。

联机只需房主安装，客机无需安装；即使客机安装也不能改变此设置。配送选择在重启后保留，同一安装下的各餐厅共用，并非每个游戏存档单独保存。偏好文件为 `SmartDelivery/Scripts/delivery-preference.txt`，更新时请保留；Mod 文件夹需允许写入。

### 实机截图

自动智能订购设置中新增 **Delivery method（配送方式）** 字段，图中选择的是 **Premium delivery（高级配送）**。

![实机画面：自动智能订购设置显示配送方式字段，当前为高级配送](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/smart-delivery-mod/assets/delivery-settings-gameplay.png?raw=1)

展开列表可选择 **Free service（免费服务）**、**Budget delivery（经济型配送）** 或 **Premium delivery（高级配送）**。

![实机画面：展开配送方式列表，显示免费服务、经济型配送和高级配送](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/smart-delivery-mod/assets/delivery-selector-gameplay.png?raw=1)

### 使用要求

Windows x64 版 Parisian Bistro Simulator，以及 **UE4SS experimental**。已核对的加载器版本为 `v3.0.1-1140-gf58e8f84`，不支持旧稳定版 UE4SS 3.0.1；其他加载器版本尚未验证。UE4SS 需单独安装。Mod ZIP 已含可直接使用的辅助文件，无需自行编译。

### 下载

以下来源**二选一**即可，提供的是同一个 Mod：

- **GitHub（无需账号）：**打开 [配送随心 0.1.5](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/smart-delivery-v0.1.5)，向下找到并展开 **Assets（附件）**，点击 **SmartDelivery-0.1.5.zip**。`SHA256SUMS.txt` 是可选的校验文件，无需安装；不要下载 **Source code（源码）**。
- **Nexus：**打开 [Mod 页面](https://www.nexusmods.com/parisianbistrosimulator/mods/4)，登录或注册免费账号，在 **Files（文件）→ Main files（主要文件）** 找到 **0.1.5**，点击 **Manual download（手动下载）**。如出现前置要求提示，继续到下载页；免费账号选择 **Slow download（慢速下载）**，等待 ZIP 下载完成。先把 ZIP 保存在**下载**文件夹，下面再解压。

### 安装

以下步骤从电脑上只安装了 Windows 版游戏开始。**手动安装免费，不需要 Vortex，也不需要 Nexus Premium 会员。** 用浏览器和 Windows 文件资源管理器即可操作；Windows 自带 ZIP 解压功能，无需安装 WinRAR 或 7-Zip，也不需要 Git、Python、Visual Studio 或虚幻引擎。

UE4SS 是**加载器**，作用是在启动游戏时运行 Mod。每个游戏安装目录只需装一次，之后把所需 Mod 加入它的 `Mods` 文件夹即可。Vortex 是可选的 **Mod 管理器**，负责复制和移除 Mod 文件，不能代替 UE4SS。

1. **完全退出游戏。** 在 Steam 打开**库**，右键 **Parisian Bistro Simulator（法式小馆儿模拟器）→ 管理 → 浏览本地文件**。弹出的文件资源管理器窗口就是游戏目录，文件夹名可能是 **Parisian Brasserie Simulator**。不是“文档”或存档文件夹。
2. **打开安装位置。** 在该窗口依次双击 **BrasserieSimulator → Binaries → Win64**，应该能看到 **BrasserieSimulator-Win64-Shipping.exe**（Windows 可能隐藏 `.exe` 后缀）。保留此窗口，加载器就放在这里；不要放在最外层 `BrasserieSimulator.exe` 旁边。
3. **下载加载器。** 点击 [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip)，这是本项目核对过的 experimental 基础包。若直链失效，打开 [UE4SS experimental 发布页](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental)，展开 **Assets / Show all assets（附件／显示全部附件）**，找到这个完整文件名。不要下载 `zDEV`、`Source code`，也不要使用旧稳定版 `UE4SS_v3.0.1.zip`。其他 experimental 构建尚未核验。
4. **解压并放入加载器。** 在文件资源管理器的**下载**文件夹里，右键刚下载的 ZIP → **全部解压缩 → 提取**。打开解压后的文件夹，选中里面的 **dwmapi.dll** 和整个 **ue4ss** 文件夹，右键**复制**；回到游戏的 **Win64** 窗口，在空白处右键**粘贴**。复制这两个项目本身，不要把以压缩包命名的外层文件夹一起套进去。UE4SS 没有需要双击运行的安装程序。已经安装过加载器时，替换前备份其文件夹和设置，并保留现有 Mod。
5. **检查加载器位置。** **Win64** 中的 `dwmapi.dll` 应与 `BrasserieSimulator-Win64-Shipping.exe` 并排。打开 **ue4ss**，里面应有 **UE4SS.dll**、**UE4SS-settings.ini** 和 **Mods**。缺少这些内容时回到上一步重新解压、复制；只新建一个空的 `Mods` 文件夹不能装好加载器。
6. **解压上面下载的 Mod ZIP。** 右键 ZIP → **全部解压缩 → 提取**。打开解压后的文件夹，找到 **SmartDelivery** 文件夹；它里面应有 **Scripts** 和 **enabled.txt**。Windows 可能只显示 `enabled` 而隐藏 `.txt`，属于正常情况。
7. **复制整个 SmartDelivery 文件夹。** 右键它 → **复制**。在游戏窗口打开 **Win64 → ue4ss → Mods**，在空白处右键**粘贴**。不要只复制 `main.lua`，也不要把 ZIP 本身放进去。 其中的 **Scripts/delivery_bridge.dll** 也必须保留在原位，ZIP 已包含此文件。
8. **检查安装结果。** 依次打开 **Mods → SmartDelivery → Scripts**，应能看到 **main.lua**；返回一层到 **SmartDelivery**，应能看到与 **Scripts** 并排的 **enabled.txt**。不要多套成 `SmartDelivery/SmartDelivery`。即使 `enabled.txt` 是空文件也应原样保留，它用于启用 Mod；不要替换加载器的 `mods.txt`。
9. **从 Steam 正常启动游戏**，按上方“怎么使用”操作。有的 Mod 在后台工作，没有启动提示。先核对本说明开头的单人／房主／客机要求；房主指开启联机餐厅、让其他人加入的玩家。

从 Steam 打开的游戏目录算起，最终脚本位置是 `BrasserieSimulator/Binaries/Win64/ue4ss/Mods/SmartDelivery/Scripts/main.lua`。功能未生效时，先退出游戏、核对上述加载器和 Mod 两处目录，再用记事本打开 `Win64/ue4ss/UE4SS.log`，查看有没有本次运行的时间或错误。重装前可查看[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

**如果选择 Vortex：** 先按 [Vortex 安装说明](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#中文)装好 Vortex、本游戏扩展和 UE4SS，再导入原始 Mod ZIP，安装、启用并部署。同一个 Mod 只使用一种安装方式。**目前通过 [Nexus 合集](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz)一键安装需要有效的 Nexus Premium 会员。** 免费 Nexus 账号仍可逐个下载 Mod；GitHub 下载无需账号。

### 更新与卸载

**更新：** 关闭游戏，先备份 `SmartDelivery/Scripts/delivery-preference.txt`。下载并解压新版 Mod ZIP，把完整的 `SmartDelivery` 文件夹复制到原来的 `Mods` 目录并覆盖同名文件；保留或放回偏好文件，再启动游戏。

**卸载：** 关闭游戏，只删除 `Mods/SmartDelivery`，保留 UE4SS 和其他 Mod。卸载后恢复游戏原有的自动配送选择。删除整个文件夹也会删除 Mod 保存的配送偏好，之后还想复用时请先备份偏好文件。游戏存档无需转换。

可选操作：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。正常安装和更新不需要此操作。

### 语言与帮助

配送名称沿用游戏译文，新增字段标题跟随游戏语言，无需语言包或独立设置。技术日志保持英文。

游戏语言包括英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。

选择框未出现时，先确认自己是房主，且已复制完整文件夹，包括包内辅助文件。选择无法保留时，请检查文件夹是否允许写入。反馈时附上 `UE4SS.log` 中相关的 `[SmartDelivery]` 日志，以及存在时的 `SmartDelivery/Scripts/bridge-status.txt`。

维护者于 2026-09-26 确认实机及联机测试全部通过并授权正式发布，具体范围见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/releases/validation.md#中文)。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/smart-delivery-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文) · [MIT 许可证](LICENSE)
