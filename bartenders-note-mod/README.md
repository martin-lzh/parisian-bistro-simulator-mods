# Bartender's Note / 调饮手记

[English](#english) · [中文](#中文)

## English

See your claimed, unfinished drinks below the restaurant name. Repeated orders are grouped, such as `Espresso x 10 · Lemonade x 3`.

**Version: 0.1.2.** Single player, multiplayer host or guest. Install it on each player's computer that wants the display; each sees only their own claimed orders.

### How to use

1. Enter your restaurant and open the game's tablet using its on-screen prompt or your configured control.
2. Open the drink order list and use the game's existing claim action on the drinks you intend to make. Orders must be claimed by **you**; unclaimed orders and another player's claims do not appear in your note.
3. Close the tablet. The note appears automatically below the restaurant name when you have at least one unfinished claimed drink. It adds no button, shortcut or settings menu.
4. Prepare those drinks using the game's normal equipment and interactions. Both waiting and currently preparing drinks count. A drink leaves the note when preparation finishes, even if it is still on the counter waiting to be collected or served.
5. To change what you are working on, return to the tablet's order list and use the existing claim or unclaim controls. The note also updates when the game cancels an order; it hides after the last matching drink is finished, unclaimed or canceled.

### Reading the note

- Repeated drinks share one count: `Espresso x 10` means ten unfinished claimed orders of that drink. It is not an ingredient or prepared-stock count.
- The note uses at most two lines. “... + N more” counts hidden **drink types**, not cups; a name that is too long to fit may also be included. Reopen the tablet to inspect the full order list.
- The note follows the visibility of the restaurant name bar. If a tablet or other full-screen interface hides that bar, close the interface to see the note again. Language and window-size changes update the layout automatically.
- The note is a display only: it does not claim orders, make drinks, collect them or deliver them. Its text does not take mouse, keyboard or controller input. Use the game's normal controls for those actions.

In multiplayer, each installed copy reads that player's own claims. The host does not need the Mod for a guest to use their own display, and installing it only on the host does not give guests a note. To stop using the display, remove the Mod with the game closed as described below; there is no in-game toggle.

### Requirements

Windows x64 Parisian Bistro Simulator and **UE4SS experimental**. The checked loader build is `v3.0.1-1140-gf58e8f84`; stable UE4SS 3.0.1 is not supported. Other loader builds have not been verified. UE4SS is installed separately.

### Download

1. Sign in to a GitHub account with access to this private repository and open [Bartender's Note 0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/bartenders-note-v0.1.2).
2. Under **Assets**, download **`BartendersNote-0.1.2.zip`** and `SHA256SUMS.txt`. Extract the Mod ZIP; GitHub's **Source code** archive is not an installable Mod.

If the package is missing or you cannot access it, see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/bartenders-note-v0.1.2/SUPPORT.md#english).

### Install

1. Close the game. In Steam, right-click **Parisian Bistro Simulator** → **Manage** → **Browse local files**. This opens the `<game>` folder used below.
2. Install the basic experimental UE4SS package using the [UE4SS installation guide](https://docs.ue4ss.com/dev/installation-guide.html), keeping that package's folder structure.
3. Copy the extracted **`BartendersNote`** folder, with all its contents, into `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/`. If your loader uses another location, use its existing `Mods` folder instead.
4. Confirm these files exist, with no extra `BartendersNote/BartendersNote` folder:

   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/BartendersNote/Scripts/main.lua`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/BartendersNote/enabled.txt`

5. Start the game, enter your restaurant and claim a drink order on the tablet.

The included `enabled.txt` enables the Mod. Keep the whole Mod folder together; do not replace the loader's `mods.txt` or other Mods.

### Update or remove

**Update:** close the game, download and extract the new Mod ZIP, then copy its complete `BartendersNote` folder into the same `Mods` folder and replace matching files. Start the game again.

**Remove:** close the game and delete only `Mods/BartendersNote`. Leave UE4SS and other Mods in place. Removing the Mod removes only the display; your orders and save need no cleanup.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload). This is not required for normal installation or updates.

### Languages and help

Follows the game language automatically, with no separate setting or language pack. Drink names use the game's translations. Missing names use a translated drink label and item number; unsupported languages fall back to English. Technical logs remain English.

Game languages: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese.

If the note is missing, confirm the drink is still waiting or preparing and is claimed by your own player, then close any screen that hides the restaurant name bar. Allow a short refresh after changing an order; a completed drink is correctly absent even before delivery. Widen an unusually narrow game window. During loading or a temporarily unavailable order list, the note hides old counts and returns when current data is available. If it stays missing, use the help link below and include relevant `[Bartender's Note]` lines from `UE4SS.log`.

In-game and multiplayer testing passed as reported by the maintainer on 2026-09-26; the [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/bartenders-note-v0.1.2/releases/validation.md#english) describes its scope.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/bartenders-note-v0.1.2/bartenders-note-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/bartenders-note-v0.1.2/SUPPORT.md#english) · [MIT License](LICENSE)

## 中文

在餐厅名称下显示自己认领且尚未做完的饮料，同类订单合并计数，例如“浓缩咖啡 x 10 · 柠檬水 x 3”。

**版本：0.1.2。** 单人、联机房主和客机均可使用。想看到清单的玩家在自己的电脑安装，各自只显示自己的认领订单。

### 怎么使用

1. 进入餐厅，按游戏屏幕上的提示或自己设置的操作键打开平板。
2. 进入饮料订单列表，使用游戏原有的认领操作，认领准备制作的饮料。必须是**自己认领**的订单；未认领的订单和其他玩家认领的订单不会出现在自己的手记中。
3. 关闭平板。只要有尚未做完的认领饮料，手记就会自动出现在餐厅名称下，无需额外按钮、快捷键或设置。
4. 按游戏原有操作使用设备制作饮料。等待制作和正在制作的饮料都会计入；制作完成后便从手记中移除，即使成品仍在台面上、尚未拿取或送给顾客。
5. 需要调整负责的饮料时，回到平板订单列表使用原有的认领或取消认领操作。订单被游戏取消时，手记也会自动更新；最后一份符合条件的饮料完成、取消认领或被取消后，清单自动隐藏。

### 怎么看手记

- 同种饮料合并数量：“浓缩咖啡 x 10”表示自己认领且尚未做完的十份浓缩咖啡订单，不是原料库存或已做好的成品数量。
- 最多显示两行。“另有 N 种”表示隐藏的**饮料种类**，不是杯数；名称过长而无法放入的饮料也可能计入。需要查看完整订单时重新打开平板。
- 手记跟随餐厅名称条显示。平板或其他全屏界面隐藏名称条时，关闭对应界面即可再次查看；切换游戏语言或窗口尺寸后会自动调整布局。
- 手记只负责显示，不会自动认领、制作、拿取或配送饮料。文字区域不接收鼠标、键盘或手柄输入，实际操作继续使用游戏原有控件。

联机时，每位安装玩家只读取自己的认领清单。客机使用自己的手记不要求房主安装；只在房主安装也不会让客机看到手记。没有游戏内开关，需要停用时按下方说明关闭游戏并卸载。

### 使用要求

Windows x64 版 Parisian Bistro Simulator，以及 **UE4SS experimental**。已核对的加载器版本为 `v3.0.1-1140-gf58e8f84`，不支持旧稳定版 UE4SS 3.0.1；其他加载器版本尚未验证。UE4SS 需单独安装。

### 下载

1. 登录有权访问本私密仓库的 GitHub 账号，打开 [调饮手记 0.1.2](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/bartenders-note-v0.1.2)。
2. 在 **Assets** 中下载 **`BartendersNote-0.1.2.zip`** 和 `SHA256SUMS.txt`。解压 Mod ZIP；GitHub 的 **Source code** 是源码，不能当作安装包。

找不到文件或无法访问时，见[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/bartenders-note-v0.1.2/SUPPORT.md#中文)。

### 安装

1. 关闭游戏。在 Steam 中右键 **Parisian Bistro Simulator** → **管理** → **浏览本地文件**，打开的就是下方所说的 `<game>` 游戏目录。
2. 按 [UE4SS 安装说明](https://docs.ue4ss.com/dev/installation-guide.html)安装 experimental 的基础包，保留该发行包自己的目录结构。
3. 将解压出的 **`BartendersNote`** 文件夹连同全部内容复制到 `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/`。若加载器实际装在其他位置，请使用它已有的 `Mods` 文件夹。
4. 确认存在以下文件，不要多套一层 `BartendersNote/BartendersNote` 文件夹：

   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/BartendersNote/Scripts/main.lua`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/BartendersNote/enabled.txt`

5. 启动游戏进入餐厅，在平板中认领饮料订单。

包内的 `enabled.txt` 会启用 Mod。请完整保留 Mod 文件夹，不要替换加载器的整个 `mods.txt` 或其他 Mod。

### 更新与卸载

**更新：** 关闭游戏，下载并解压新版 Mod ZIP，把完整的 `BartendersNote` 文件夹复制到原来的 `Mods` 目录并覆盖同名文件，再启动游戏。

**卸载：** 关闭游戏，只删除 `Mods/BartendersNote`，保留 UE4SS 和其他 Mod。卸载仅移除显示，不需要清理订单或存档。

可选操作：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。正常安装和更新不需要此操作。

### 语言与帮助

自动跟随游戏语言，无需设置或安装语言包。饮料名沿用游戏译文；名称不可用时显示本地化饮料标签和编号，不支持的语言回退英语。技术日志保持英文。

游戏语言包括英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。

手记未出现时，先确认饮料仍在等待或制作中，且由自己的角色认领，再关闭会隐藏餐厅名称条的界面。改变订单后等待短暂刷新；饮料已经做完时，即使还没送出，也应从手记移除。游戏窗口过窄时请加宽。加载中或订单数据暂时不可用时会隐藏旧数量，数据恢复后自动重新显示。仍未恢复时，按下方反馈说明提供 `UE4SS.log` 中相关的 `[Bartender's Note]` 日志。

维护者于 2026-09-26 确认实机及联机测试全部通过并授权正式发布，具体范围见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/bartenders-note-v0.1.2/releases/validation.md#中文)。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/bartenders-note-v0.1.2/bartenders-note-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/bartenders-note-v0.1.2/SUPPORT.md#中文) · [MIT 许可证](LICENSE)
