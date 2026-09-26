# Fresh to Serve / 焕鲜上桌

[English](#english) · [中文](#中文)

## English

Clear spoiled cooked meals and finished drinks from kitchen passes, drink output areas and elevator serving slots. If the original customer is still waiting and has enough patience, request a replacement for the game's staff to prepare and serve.

**Version: 0.1.2.** Single player or multiplayer host only. Only the host needs to install it; guests do not remove items or place replacement orders.

### How to use

Enter your restaurant as host. Cleanup starts automatically, with no hotkey or settings to change. Finished cocktails are included.

- Replacements still need the normal ingredients, equipment and staff. Patience is never reset; a busy kitchen or bar may leave too little time to remake an item.
- If the customer has left or a timely replacement cannot be confirmed, the spoiled item is removed without a replacement.
- Good-quality items, dirty dishes, served or carried items, unfinished drinks, drinks still being poured and player-service tables are left alone. Bakery trays are outside this version's scope.
- Player-claimed unfinished drinks delay automatic drink remakes. The assigned floor needs a working bartender who is allowed to make that drink.
- Discarding removes the spoiled item and its plate or glass; it does not return dishes to the sink, refund ingredients or add trash to a bin. Staff and delivery delays can still prevent timely service.

### Requirements

Windows x64 Parisian Bistro Simulator and **UE4SS experimental**. The checked loader build is `v3.0.1-1140-gf58e8f84`; stable UE4SS 3.0.1 is not supported. Other loader builds have not been verified. UE4SS is installed separately.

### Download

1. Sign in to a GitHub account with access to this private repository and open [Fresh to Serve 0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/fresh-to-serve-v0.1.2).
2. Under **Assets**, download **`FreshToServe-0.1.2.zip`** and `SHA256SUMS.txt`. Extract the Mod ZIP; GitHub's **Source code** archive is not an installable Mod.

If the package is missing or you cannot access it, see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/fresh-to-serve-v0.1.2/SUPPORT.md#english).

### Install

1. Close the game. In Steam, right-click **Parisian Bistro Simulator** → **Manage** → **Browse local files**. This opens the `<game>` folder used below.
2. Install the basic experimental UE4SS package using the [UE4SS installation guide](https://docs.ue4ss.com/dev/installation-guide.html), keeping that package's folder structure.
3. Copy the extracted **`FreshToServe`** folder, with all its contents, into `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/`. If your loader uses another location, use its existing `Mods` folder instead.
4. Confirm these files exist, with no extra `FreshToServe/FreshToServe` folder:

   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/FreshToServe/Scripts/main.lua`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/FreshToServe/enabled.txt`

5. Start the game and enter your restaurant in single player or as the multiplayer host.

The included `enabled.txt` enables the Mod. Keep the whole Mod folder together; do not replace the loader's `mods.txt` or other Mods.

If you used the earlier **Fresh Service** package, remove its old `Mods/FreshService` folder with the game closed before installing this Mod. Do not run both copies.

### Update or remove

**Update:** close the game, download and extract the new Mod ZIP, then copy its complete `FreshToServe` folder into the same `Mods` folder and replace matching files. Start the game again.

**Remove:** close the game and delete only `Mods/FreshToServe`. Leave UE4SS and other Mods in place. Removing the Mod does not restore discarded items or cancel orders already accepted by the game.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload). This is not required for normal installation or updates.

### Languages and help

Adds no in-game text. Dish names, drink names and order messages remain in the game's selected language; no language pack is needed. Technical logs remain English.

Game languages: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese.

If an item is not remade, check customer patience, stock, staff and equipment first. A cleanup does not guarantee a replacement or delivery. After an error stops automation, leave and re-enter the restaurant. Include relevant `[FreshToServe]` lines from `UE4SS.log` with a problem report.

In-game and multiplayer testing passed as reported by the maintainer on 2026-09-26; the [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/fresh-to-serve-v0.1.2/releases/validation.md#english) describes its scope.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/fresh-to-serve-v0.1.2/fresh-to-serve-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/fresh-to-serve-v0.1.2/SUPPORT.md#english) · [MIT License](LICENSE)

## 中文

自动清理厨房出餐台、饮料出品区及升降机出餐位上的低劣熟食和成品饮料；原顾客仍在等待且耐心足够时补单，由游戏原有员工制作并送达。

**版本：0.1.2。** 仅单人或联机房主运行，只需房主安装，客机不执行清理或补单。

### 怎么使用

以房主身份进入餐厅后自动清理，无需快捷键或设置，成品鸡尾酒也包括在内。

- 重做仍需正常消耗原料，并满足设备和员工条件。不会重置耐心；厨房或吧台积压过多时可能来不及补单。
- 顾客已离开，或无法确认有足够时间重做时，只清理低劣成品，不补单。
- 不处理正常成品、脏餐具、已上桌或搬运中的餐品、未完成或正在灌装的饮料，以及玩家负责的餐桌。本版也不处理烘焙托盘。
- 玩家已认领且尚未做完的饮料会延后自动重做；目标楼层须有正在工作并允许制作该饮料的调酒师。
- 清理会连同餐盘或杯子一起移除，不返还脏餐具、不退原料，也不增加垃圾桶内的垃圾；员工和送餐延迟仍可能导致来不及上桌。

### 使用要求

Windows x64 版 Parisian Bistro Simulator，以及 **UE4SS experimental**。已核对的加载器版本为 `v3.0.1-1140-gf58e8f84`，不支持旧稳定版 UE4SS 3.0.1；其他加载器版本尚未验证。UE4SS 需单独安装。

### 下载

1. 登录有权访问本私密仓库的 GitHub 账号，打开 [焕鲜上桌 0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/fresh-to-serve-v0.1.2)。
2. 在 **Assets** 中下载 **`FreshToServe-0.1.2.zip`** 和 `SHA256SUMS.txt`。解压 Mod ZIP；GitHub 的 **Source code** 是源码，不能当作安装包。

找不到文件或无法访问时，见[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/fresh-to-serve-v0.1.2/SUPPORT.md#中文)。

### 安装

1. 关闭游戏。在 Steam 中右键 **Parisian Bistro Simulator** → **管理** → **浏览本地文件**，打开的就是下方所说的 `<game>` 游戏目录。
2. 按 [UE4SS 安装说明](https://docs.ue4ss.com/dev/installation-guide.html)安装 experimental 的基础包，保留该发行包自己的目录结构。
3. 将解压出的 **`FreshToServe`** 文件夹连同全部内容复制到 `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/`。若加载器实际装在其他位置，请使用它已有的 `Mods` 文件夹。
4. 确认存在以下文件，不要多套一层 `FreshToServe/FreshToServe` 文件夹：

   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/FreshToServe/Scripts/main.lua`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/FreshToServe/enabled.txt`

5. 启动游戏，以单人玩家或联机房主身份进入餐厅。

包内的 `enabled.txt` 会启用 Mod。请完整保留 Mod 文件夹，不要替换加载器的整个 `mods.txt` 或其他 Mod。

若安装过旧名 **Fresh Service** 的开发包，请先关闭游戏并删除旧的 `Mods/FreshService` 文件夹，避免同时运行两份。

### 更新与卸载

**更新：** 关闭游戏，下载并解压新版 Mod ZIP，把完整的 `FreshToServe` 文件夹复制到原来的 `Mods` 目录并覆盖同名文件，再启动游戏。

**卸载：** 关闭游戏，只删除 `Mods/FreshToServe`，保留 UE4SS 和其他 Mod。卸载不会恢复已丢弃的物品，也不会取消游戏已经接受的补单。

可选操作：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。正常安装和更新不需要此操作。

### 语言与帮助

不新增游戏内文字，菜名、饮料名和订单提示沿用游戏当前语言，无需语言包。技术日志保持英文。

游戏语言包括英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。

没有重做时，先检查顾客耐心、库存、员工及设备。清理成功不代表一定补单或送达。异常导致自动流程停止后，可退出餐厅并重新进入。反馈时附上 `UE4SS.log` 中相关的 `[FreshToServe]` 日志。

维护者于 2026-09-26 确认实机及联机测试全部通过并授权正式发布，具体范围见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/fresh-to-serve-v0.1.2/releases/validation.md#中文)。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/fresh-to-serve-v0.1.2/fresh-to-serve-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/fresh-to-serve-v0.1.2/SUPPORT.md#中文) · [MIT 许可证](LICENSE)
