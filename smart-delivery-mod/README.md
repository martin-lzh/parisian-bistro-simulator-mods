# Smart Delivery / 配送随心

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

1. Sign in to a GitHub account with access to this private repository and open [Smart Delivery 0.1.5](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/smart-delivery-v0.1.5).
2. Under **Assets**, download **`SmartDelivery-0.1.5.zip`** and `SHA256SUMS.txt`. Extract the Mod ZIP; GitHub's **Source code** archive is not an installable Mod.

If the package is missing or you cannot access it, see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/SUPPORT.md#english).

### Install

1. Close the game. In Steam, right-click **Parisian Bistro Simulator** → **Manage** → **Browse local files**. This opens the `<game>` folder used below.
2. Install the basic experimental UE4SS package using the [UE4SS installation guide](https://docs.ue4ss.com/dev/installation-guide.html), keeping that package's folder structure.
3. Copy the extracted **`SmartDelivery`** folder, with all its contents, into `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/`. If your loader uses another location, use its existing `Mods` folder instead.
4. Confirm these files exist, with no extra `SmartDelivery/SmartDelivery` folder:

   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/SmartDelivery/Scripts/main.lua`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/SmartDelivery/Scripts/delivery_bridge.dll`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/SmartDelivery/enabled.txt`

5. Start the game as host and open the automatic smart-order settings on the restaurant computer.

The included `enabled.txt` enables the Mod. Keep the whole Mod folder together; do not replace the loader's `mods.txt` or other Mods. Keep `delivery_bridge.dll` inside this Mod's `Scripts` folder.

### Update or remove

**Update:** close the game and back up `SmartDelivery/Scripts/delivery-preference.txt`. Download and extract the new Mod ZIP, copy its complete `SmartDelivery` folder into the same `Mods` folder and replace matching files. Keep or restore your preference file, then start the game again.

**Remove:** close the game and delete only `Mods/SmartDelivery`. Leave UE4SS and other Mods in place. The game returns to its normal automatic delivery selection. Deleting the whole folder also deletes the saved Mod preference, so back up the preference file first if you want to reuse it later. Game saves need no conversion.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload). This is not required for normal installation or updates.

### Languages and help

The delivery names use the game's translations, and the added field label follows the game language. No language pack or separate setting is needed. Technical logs remain English.

Game languages: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese.

If the selector is missing, confirm you are host and installed the complete folder, including the bundled helper. If the saved choice is not retained, check that the folder can be written to. For a problem report, include relevant `[SmartDelivery]` lines from `UE4SS.log` and `SmartDelivery/Scripts/bridge-status.txt` if it exists.

In-game and multiplayer testing passed as reported by the maintainer on 2026-09-26; the [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/releases/validation.md#english) describes its scope.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/smart-delivery-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/SUPPORT.md#english) · [MIT License](LICENSE)

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

1. 登录有权访问本私密仓库的 GitHub 账号，打开 [配送随心 0.1.5](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/smart-delivery-v0.1.5)。
2. 在 **Assets** 中下载 **`SmartDelivery-0.1.5.zip`** 和 `SHA256SUMS.txt`。解压 Mod ZIP；GitHub 的 **Source code** 是源码，不能当作安装包。

找不到文件或无法访问时，见[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/SUPPORT.md#中文)。

### 安装

1. 关闭游戏。在 Steam 中右键 **Parisian Bistro Simulator** → **管理** → **浏览本地文件**，打开的就是下方所说的 `<game>` 游戏目录。
2. 按 [UE4SS 安装说明](https://docs.ue4ss.com/dev/installation-guide.html)安装 experimental 的基础包，保留该发行包自己的目录结构。
3. 将解压出的 **`SmartDelivery`** 文件夹连同全部内容复制到 `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/`。若加载器实际装在其他位置，请使用它已有的 `Mods` 文件夹。
4. 确认存在以下文件，不要多套一层 `SmartDelivery/SmartDelivery` 文件夹：

   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/SmartDelivery/Scripts/main.lua`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/SmartDelivery/Scripts/delivery_bridge.dll`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/SmartDelivery/enabled.txt`

5. 启动游戏，以房主身份打开餐厅电脑的自动智能订购设置。

包内的 `enabled.txt` 会启用 Mod。请完整保留 Mod 文件夹，不要替换加载器的整个 `mods.txt` 或其他 Mod。`delivery_bridge.dll` 应留在本 Mod 的 `Scripts` 内。

### 更新与卸载

**更新：** 关闭游戏，先备份 `SmartDelivery/Scripts/delivery-preference.txt`。下载并解压新版 Mod ZIP，把完整的 `SmartDelivery` 文件夹复制到原来的 `Mods` 目录并覆盖同名文件；保留或放回偏好文件，再启动游戏。

**卸载：** 关闭游戏，只删除 `Mods/SmartDelivery`，保留 UE4SS 和其他 Mod。卸载后恢复游戏原有的自动配送选择。删除整个文件夹也会删除 Mod 保存的配送偏好，之后还想复用时请先备份偏好文件。游戏存档无需转换。

可选操作：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。正常安装和更新不需要此操作。

### 语言与帮助

配送名称沿用游戏译文，新增字段标题跟随游戏语言，无需语言包或独立设置。技术日志保持英文。

游戏语言包括英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。

选择框未出现时，先确认自己是房主，且已复制完整文件夹，包括包内辅助文件。选择无法保留时，请检查文件夹是否允许写入。反馈时附上 `UE4SS.log` 中相关的 `[SmartDelivery]` 日志，以及存在时的 `SmartDelivery/Scripts/bridge-status.txt`。

维护者于 2026-09-26 确认实机及联机测试全部通过并授权正式发布，具体范围见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/releases/validation.md#中文)。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/smart-delivery-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/SUPPORT.md#中文) · [MIT 许可证](LICENSE)
