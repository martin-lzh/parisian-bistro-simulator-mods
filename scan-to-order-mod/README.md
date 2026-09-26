# Scan to Order / 扫码点餐

[English](#english) · [中文](#中文)

## English

Automatically place seated customers' food and drink orders without a waiter or player taking them. No QR image or phone interaction is required.

**Version: 0.1.1.** Single player or multiplayer host only. Install it on the host; guests never send orders.

### How to use

Enter your restaurant as host. Ordering starts automatically, with no key or settings to change.

- Customers keep their own dish choices. The Mod does not change the menu or choose substitutes.
- An out-of-stock item waits; available items can proceed. Restocking lets outstanding orders continue automatically.
- Normal chef, bartender, equipment and speciality requirements still apply. Cooking, drinks, serving, billing and patience remain the game's responsibility.
- Tables marked for player service and tables currently being ordered by a waiter are left to that interaction. Completed orders are not repeated.
- Customers who have left, received their item or run out of enabled patience do not receive new orders.

### In-game screenshot

Food and drink order icons beside seated customers display green check marks.

![In-game food and drink order icons showing green check marks beside seated customers](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/scan-to-order-mod/assets/automatic-orders-gameplay.png?raw=1)

### Requirements

Windows x64 Parisian Bistro Simulator and **UE4SS experimental**. The checked loader build is `v3.0.1-1140-gf58e8f84`; stable UE4SS 3.0.1 is not supported. Other loader builds have not been verified. UE4SS is installed separately.

### Download

1. Sign in to a GitHub account with access to this private repository and open [Scan to Order 0.1.1](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/scan-to-order-v0.1.1).
2. Under **Assets**, download **`ScanToOrder-0.1.1.zip`** and `SHA256SUMS.txt`. Extract the Mod ZIP; GitHub's **Source code** archive is not an installable Mod.

If the package is missing or you cannot access it, see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/SUPPORT.md#english).

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

If an order waits, check stock, staff, equipment and whether the table is being handled manually. If an error stops automation, leave and re-enter the restaurant; restarting scripts alone does not clear an uncertain order. Include relevant `[ScanToOrder]` lines from `UE4SS.log` with a problem report.

In-game and multiplayer testing passed as reported by the maintainer on 2026-09-26; the [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/releases/validation.md#english) describes its scope.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/scan-to-order-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/SUPPORT.md#english) · [MIT License](LICENSE)

## 中文

自动为已入座顾客提交食物和饮料订单，无需服务员或玩家点餐，也不需要实际二维码或手机交互。

**版本：0.1.1。** 仅单人或联机房主运行，只需房主安装，客机不会提交订单。

### 怎么使用

以房主身份进入餐厅后自动点餐，无需按键或设置。

- 沿用顾客已经选好的餐品，不修改菜单，也不替顾客换菜。
- 缺货餐品等待，有货项可以先下单；补货后自动继续处理尚未完成的订单。
- 仍须满足厨师、调酒师、设备和专长条件；烹饪、饮料制作、上菜、结账与耐心由游戏处理。
- 玩家负责的餐桌，以及服务员正在点餐的餐桌，留给原有交互；已完成的订单不会重复提交。
- 顾客已离开、已拿到餐品，或启用耐心且耐心耗尽后，不再下单。

### 实机截图

已入座顾客旁的餐品与饮料订单图标显示绿色勾选标记。

![实机画面：已入座顾客旁的餐品与饮料订单图标显示绿色勾选标记](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/scan-to-order-mod/assets/automatic-orders-gameplay.png?raw=1)

### 使用要求

Windows x64 版 Parisian Bistro Simulator，以及 **UE4SS experimental**。已核对的加载器版本为 `v3.0.1-1140-gf58e8f84`，不支持旧稳定版 UE4SS 3.0.1；其他加载器版本尚未验证。UE4SS 需单独安装。

### 下载

1. 登录有权访问本私密仓库的 GitHub 账号，打开 [扫码点餐 0.1.1](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/scan-to-order-v0.1.1)。
2. 在 **Assets** 中下载 **`ScanToOrder-0.1.1.zip`** 和 `SHA256SUMS.txt`。解压 Mod ZIP；GitHub 的 **Source code** 是源码，不能当作安装包。

找不到文件或无法访问时，见[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/SUPPORT.md#中文)。

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

订单未提交时，先检查库存、员工、设备，以及餐桌是否正由玩家处理。异常导致自动点餐停止后，请退出餐厅并重新进入；仅重新加载脚本不会解除结果未确认订单的停止状态。反馈时附上 `UE4SS.log` 中相关的 `[ScanToOrder]` 日志。

维护者于 2026-09-26 确认实机及联机测试全部通过并授权正式发布，具体范围见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/releases/validation.md#中文)。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/scan-to-order-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/scan-to-order-v0.1.1/SUPPORT.md#中文) · [MIT 许可证](LICENSE)
