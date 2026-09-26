# First to Serve / 出餐有序

[English](#english) · [中文](#中文)

## English

Hold the interaction key at a kitchen pass or drink output area to collect the earliest-made ready items with a tray or food trolley.

**Version: 0.1.7-dev.** Single player, multiplayer host or guest. Install it on each player's computer that wants to use the hold action; other players do not need it.

### How to use

1. Equip a tray or take hold of a food trolley.
2. Aim at the kitchen pickup area, drink output surface, a ready dish or a finished drink.
3. Hold the interaction key shown by the game. The default mouse control is the left button; keyboard/controller remapping follows the game.
4. Release the key, turn away, move away, change tools or open a menu to stop. Pickup also stops when the suitable slots are full.

You can move the crosshair within the same output area or leave it on an item's empty spot after pickup. Tap keeps the game's normal action. In a supported pickup area with a tray or trolley, holding takes items instead of opening the interaction wheel.

Only ready, clean items in reach at that source are collected. Dirty plates, unfinished drinks, other floors and carried items are excluded. Drink-only slots remain reserved for drinks; tower burgers need a top slot. Parked trolleys and storage carts do not activate pickup.

### In-game screenshots

Tray pickup at the kitchen pass, shown in a 4.48-second gameplay recording.

![Gameplay animation of tray pickup at the kitchen pass](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/first-to-serve-mod/assets/kitchen-pass-gameplay.gif?raw=1)

[Open animation (GIF, 81 MiB)](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/first-to-serve-mod/assets/kitchen-pass-gameplay.gif?raw=1)

With a tray at the kitchen pass, the hold hint appears above **Take the dish**.

![Tray at the kitchen pass showing Hold: take oldest first and Take the dish](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/first-to-serve-mod/assets/kitchen-pass-gameplay.png?raw=1)

With a tray at the drink output area, the same hold hint appears above **Take drinks**.

![Tray at the drink output area showing Hold: take oldest first and Take drinks](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/first-to-serve-mod/assets/drink-output-gameplay.png?raw=1)

### Requirements

Windows x64 Parisian Bistro Simulator and **UE4SS experimental**. The checked loader build is `v3.0.1-1140-gf58e8f84`; stable UE4SS 3.0.1 is not supported. Other loader builds have not been verified. UE4SS is installed separately.

### Download

1. Sign in to a GitHub account with access to this private repository. Open [Mod packages](https://github.com/martin-lzh/parisian-bistro-simulator-mods/actions/workflows/mods.yml?query=branch%3Adev) and choose the latest successful **dev** run with a **mod-packages** artifact.
2. Open that run → **Artifacts** → **mod-packages** and download it. Extract this outer archive, then extract **`FirstToServe-0.1.7-dev.zip`** inside it. Use the Mod ZIP, not GitHub's **Source code** archive.

Use a run containing the version named above. Artifacts expire after 14 days; if the package is missing or you cannot access it, see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english).

### Install

1. Close the game. In Steam, right-click **Parisian Bistro Simulator** → **Manage** → **Browse local files**. This opens the `<game>` folder used below.
2. Install the basic experimental UE4SS package using the [UE4SS installation guide](https://docs.ue4ss.com/dev/installation-guide.html), keeping that package's folder structure.
3. Copy the extracted **`FirstToServe`** folder, with all its contents, into `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/`. If your loader uses another location, use its existing `Mods` folder instead.
4. Confirm these files exist, with no extra `FirstToServe/FirstToServe` folder:

   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/FirstToServe/Scripts/main.lua`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/FirstToServe/enabled.txt`

5. Start the game, enter a restaurant, equip a tray or take hold of a food trolley, then try holding at an output area.

The included `enabled.txt` enables the Mod. Keep the whole Mod folder together; do not replace the loader's `mods.txt` or other Mods.

If you used the earlier **Oldest First** package, remove its old `Mods/OldestFirst` folder with the game closed before installing this Mod. Do not run both copies.

### Update or remove

**Update:** close the game, download and extract the new Mod ZIP, then copy its complete `FirstToServe` folder into the same `Mods` folder and replace matching files. Start the game again.

**Remove:** close the game and delete only `Mods/FirstToServe`. Leave UE4SS and other Mods in place. Removing the Mod restores the normal hold interaction. Items already picked up stay where the game placed them.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload). This is not required for normal installation or updates.

### Languages and help

The hold hint follows the game language and its keyboard/controller icons follow your current controls. No language setting or language pack is needed. Technical logs remain English.

Game languages: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese.

The hold hint appears below the normal pickup hint when an eligible item and a suitable free slot are available. A drink surface without the game's normal pickup hint can still accept the hold action. If pickup stops while there is room, release and hold again; slow multiplayer responses can also stop it. Include relevant `[FirstToServe]` lines from `UE4SS.log`, your controls and host/guest role with a problem report.

In-game testing was reported on 2026-09-26; the [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/releases/validation.md#english) describes its scope.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/first-to-serve-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) · [MIT License](LICENSE)

## 中文

持托盘或推餐车，对准厨房出餐口或饮料出品台长按交互键，优先连续拿取最早做好的成品。

**版本：0.1.7-dev。** 单人、联机房主和客机均可使用。想使用连续拿取的玩家在自己的电脑安装，其他玩家无需安装。

### 怎么使用

1. 装备托盘，或握住餐车进入推行状态。
2. 对准厨房拿取区域、饮料出品台面、可取菜品或成品饮料。
3. 长按游戏显示的交互键。鼠标默认为左键；键鼠和手柄跟随游戏改键。
4. 松键、转开视线、走离、换工具或打开菜单即可停止；合适的空位装满也会停止。

准星可以在同一出品区域内移动，拿走一份后也可留在原来的空位上。短按保留原版操作；持托盘或推餐车对准支持的取餐区域时，长按用于连续拿取，替代交互轮盘。

只拿取当前来源中、范围内的干净成品，不处理脏盘、未完成饮料、其他楼层或已被搬走的物品。饮料专用位仅收饮料，高层汉堡需要顶层空位；停放的餐车和搬货推车不会启动功能。

### 实机截图

持托盘在厨房出餐口取餐的实机演示，时长约 4.48 秒。

![实机动图：持托盘在厨房出餐口取餐](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/first-to-serve-mod/assets/kitchen-pass-gameplay.gif?raw=1)

[打开动图（GIF，81 MiB）](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/first-to-serve-mod/assets/kitchen-pass-gameplay.gif?raw=1)

持托盘对准厨房出餐口，**Take the dish（拿取菜品）** 上方显示长按优先拿取最早成品的提示。

![实机画面：持托盘对准出餐口，显示长按优先拿取最早成品及拿取菜品提示](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/first-to-serve-mod/assets/kitchen-pass-gameplay.png?raw=1)

持托盘对准饮料出品台，**Take drinks（拿取饮料）** 上方显示同样的长按提示。

![实机画面：持托盘对准饮料出品台，显示长按优先拿取最早成品及拿取饮料提示](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/first-to-serve-mod/assets/drink-output-gameplay.png?raw=1)

### 使用要求

Windows x64 版 Parisian Bistro Simulator，以及 **UE4SS experimental**。已核对的加载器版本为 `v3.0.1-1140-gf58e8f84`，不支持旧稳定版 UE4SS 3.0.1；其他加载器版本尚未验证。UE4SS 需单独安装。

### 下载

1. 登录有权访问本私密仓库的 GitHub 账号，打开[Mod 安装包](https://github.com/martin-lzh/parisian-bistro-simulator-mods/actions/workflows/mods.yml?query=branch%3Adev)，选择最近一次成功且含有 **mod-packages** 的 **dev** 运行。
2. 打开该次运行 → **Artifacts** → **mod-packages** 并下载。先解压这一层压缩包，再解压里面的 **`FirstToServe-0.1.7-dev.zip`**。请选择 Mod ZIP，不要把 GitHub 的 **Source code** 当作安装包。

请选择包含上方版本的运行。安装包保留 14 天；包已过期、缺失或无法访问时，参见[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

### 安装

1. 关闭游戏。在 Steam 中右键 **Parisian Bistro Simulator** → **管理** → **浏览本地文件**，打开的就是下方所说的 `<game>` 游戏目录。
2. 按 [UE4SS 安装说明](https://docs.ue4ss.com/dev/installation-guide.html)安装 experimental 的基础包，保留该发行包自己的目录结构。
3. 将解压出的 **`FirstToServe`** 文件夹连同全部内容复制到 `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/`。若加载器实际装在其他位置，请使用它已有的 `Mods` 文件夹。
4. 确认存在以下文件，不要多套一层 `FirstToServe/FirstToServe` 文件夹：

   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/FirstToServe/Scripts/main.lua`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/FirstToServe/enabled.txt`

5. 启动游戏进入餐厅，装备托盘或握住餐车，对准出品区域尝试长按。

包内的 `enabled.txt` 会启用 Mod。请完整保留 Mod 文件夹，不要替换加载器的整个 `mods.txt` 或其他 Mod。

若安装过旧名 **Oldest First** 的开发包，请先关闭游戏并删除旧的 `Mods/OldestFirst` 文件夹，避免同时运行两份。

### 更新与卸载

**更新：** 关闭游戏，下载并解压新版 Mod ZIP，把完整的 `FirstToServe` 文件夹复制到原来的 `Mods` 目录并覆盖同名文件，再启动游戏。

**卸载：** 关闭游戏，只删除 `Mods/FirstToServe`，保留 UE4SS 和其他 Mod。卸载后恢复原版长按交互，已拿取的餐品保持游戏中的现有位置。

可选操作：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。正常安装和更新不需要此操作。

### 语言与帮助

长按提示跟随游戏语言，键鼠或手柄图标跟随当前操作设置，无需额外语言设置或语言包。技术日志保持英文。

游戏语言包括英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。

有可取成品及合适空位时，长按提示出现在原版拿取提示下方。饮料台面没有原版拿取提示时仍可长按。仍有空位却停止时，请松键后重新长按；联机响应慢也可能让本次拿取停止。反馈时附上 `UE4SS.log` 中相关的 `[FirstToServe]` 日志、操作设备及房主或客机身份。

用户于 2026-09-26 反馈实机测试完成，具体范围见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/releases/validation.md#中文)。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/first-to-serve-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文) · [MIT 许可证](LICENSE)
