# Bartender's Note / 调饮手记

[English](#english) · [中文](#中文)

## English

See your claimed, unfinished drinks below the restaurant name. Repeated orders are grouped, such as `Espresso x 10 · Lemonade x 3`.

**Version: 0.1.2-dev.** Single player, multiplayer host or guest. Install it on each player's computer that wants the display; each sees only their own claimed orders.

### How to use

1. Claim drink orders on the tablet.
2. Close the tablet to see the list below the restaurant name.
3. Make the drinks. Finished drinks leave the list immediately; canceled claims and orders also update it.

The list hides when empty. It uses up to two lines; “... + N more” counts hidden drink types, not cups. Long names may be included in that count. The display follows the game language and window size and does not take control of your mouse, keyboard or controller.

### Requirements

Windows x64 Parisian Bistro Simulator and **UE4SS experimental**. The checked loader build is `v3.0.1-1140-gf58e8f84`; stable UE4SS 3.0.1 is not supported. Other loader builds have not been verified. UE4SS is installed separately.

### Download

1. Sign in to a GitHub account with access to this private repository. Open [Mod packages](https://github.com/martin-lzh/parisian-bistro-simulator-mods/actions/workflows/mods.yml?query=branch%3Adev) and choose the latest successful **dev** run with a **mod-packages** artifact.
2. Open that run → **Artifacts** → **mod-packages** and download it. Extract this outer archive, then extract **`BartendersNote-0.1.2-dev.zip`** inside it. Use the Mod ZIP, not GitHub's **Source code** archive.

Use a run containing the version named above. Artifacts expire after 14 days; if the package is missing or you cannot access it, see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english).

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

If the list is missing, first claim an unfinished drink and close any screen that hides the restaurant name bar. Widen an unusually narrow game window. If the problem remains, use the help link below and include relevant `[Bartender's Note]` lines from `UE4SS.log`.

In-game testing was reported on 2026-09-26; the [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/releases/validation.md#english) describes its scope.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/bartenders-note-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) · [MIT License](LICENSE)

## 中文

在餐厅名称下显示自己认领且尚未做完的饮料，同类订单合并计数，例如“浓缩咖啡 x 10 · 柠檬水 x 3”。

**版本：0.1.2-dev。** 单人、联机房主和客机均可使用。想看到清单的玩家在自己的电脑安装，各自只显示自己的认领订单。

### 怎么使用

1. 在平板中认领饮料订单。
2. 关闭平板，在餐厅名称下查看清单。
3. 制作饮料。制作完成后立即从清单移除；取消认领或订单也会更新数量。

清单为空时隐藏，最多显示两行；“另有 N 种”表示隐藏的饮料种类，不是杯数。过长的名称也可能计入隐藏数量。显示跟随游戏语言和窗口尺寸，不影响鼠标、键盘或手柄操作。

### 使用要求

Windows x64 版 Parisian Bistro Simulator，以及 **UE4SS experimental**。已核对的加载器版本为 `v3.0.1-1140-gf58e8f84`，不支持旧稳定版 UE4SS 3.0.1；其他加载器版本尚未验证。UE4SS 需单独安装。

### 下载

1. 登录有权访问本私密仓库的 GitHub 账号，打开[Mod 安装包](https://github.com/martin-lzh/parisian-bistro-simulator-mods/actions/workflows/mods.yml?query=branch%3Adev)，选择最近一次成功且含有 **mod-packages** 的 **dev** 运行。
2. 打开该次运行 → **Artifacts** → **mod-packages** 并下载。先解压这一层压缩包，再解压里面的 **`BartendersNote-0.1.2-dev.zip`**。请选择 Mod ZIP，不要把 GitHub 的 **Source code** 当作安装包。

请选择包含上方版本的运行。安装包保留 14 天；包已过期、缺失或无法访问时，参见[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

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

清单未出现时，先确认已认领尚未做完的饮料，并关闭会遮住餐厅名称条的界面。游戏窗口过窄时请加宽。仍有问题时，按下方反馈说明提供 `UE4SS.log` 中相关的 `[Bartender's Note]` 日志。

用户于 2026-09-26 反馈实机测试完成，具体范围见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/releases/validation.md#中文)。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/bartenders-note-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文) · [MIT 许可证](LICENSE)
