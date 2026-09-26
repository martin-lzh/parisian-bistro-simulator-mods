# Auto Menu / 菜单巧配

[English](#english) · [中文](#中文)

## English

Add an **Auto-compose** button beside **Print menu** on the computer's daily-menu page to find a menu with the highest estimated selection rate.

**Version: 0.5.0-dev.** Single player or multiplayer host only. Only the host needs to install it; guests do not get the button.

### How to use

1. Open the computer's daily-menu page and choose lunch or dinner.
2. Click **Auto-compose**. It compares combinations of available, enabled and staffed dishes using the game's estimated selection rate.
3. Review the result, then edit, activate or print it with the game's existing controls.

The chosen menu is saved; the other service is unchanged. No ingredients are bought, prices changed or menus printed automatically. If your current eligible menu ties for the best rate, it is retained. Categories may be empty, including a completely empty menu; the game deactivates an empty menu.

**A large dish selection can pause gameplay while the search finishes.** There is no progress display. The Mod runs only when you click the button, not automatically each day.

### Requirements

Windows x64 Parisian Bistro Simulator and **UE4SS experimental**. The checked loader build is `v3.0.1-1140-gf58e8f84`; stable UE4SS 3.0.1 is not supported. Other loader builds have not been verified. UE4SS is installed separately. The ready-to-use Mod ZIP includes its helper; no compiling is needed.

### Download

1. Sign in to a GitHub account with access to this private repository. Open [Mod packages](https://github.com/martin-lzh/parisian-bistro-simulator-mods/actions/workflows/mods.yml?query=branch%3Adev) and choose the latest successful **dev** run with a **mod-packages** artifact.
2. Open that run → **Artifacts** → **mod-packages** and download it. Extract this outer archive, then extract **`AutoMenu-0.5.0-dev.zip`** inside it. Use the Mod ZIP, not GitHub's **Source code** archive.

Use a run containing the version named above. Artifacts expire after 14 days; if the package is missing or you cannot access it, see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english).

### Install

1. Close the game. In Steam, right-click **Parisian Bistro Simulator** → **Manage** → **Browse local files**. This opens the `<game>` folder used below.
2. Install the basic experimental UE4SS package using the [UE4SS installation guide](https://docs.ue4ss.com/dev/installation-guide.html), keeping that package's folder structure.
3. Copy the extracted **`AutoMenu`** folder, with all its contents, into `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/`. If your loader uses another location, use its existing `Mods` folder instead.
4. Confirm these files exist, with no extra `AutoMenu/AutoMenu` folder:

   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/AutoMenu/Scripts/main.lua`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/AutoMenu/Scripts/auto_menu_bridge.dll`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/AutoMenu/enabled.txt`

5. Start the game as host and open the daily-menu page on the restaurant computer.

The included `enabled.txt` enables the Mod. Keep the whole Mod folder together; do not replace the loader's `mods.txt` or other Mods. Keep `auto_menu_bridge.dll` inside this Mod's `Scripts` folder.

### Update or remove

**Update:** close the game, download and extract the new Mod ZIP, then copy its complete `AutoMenu` folder into the same `Mods` folder and replace matching files. Start the game again.

**Remove:** close the game and delete only `Mods/AutoMenu`. Leave UE4SS and other Mods in place. Removing the Mod removes its button but does not undo a menu already saved by the game. You can edit that menu with the normal controls.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload). This is not required for normal installation or updates.

### Languages and help

The button follows the game's selected language, with no separate setting or language pack. Menu names and forecasts remain the game's own text. Technical logs remain English.

Game languages: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese.

If the button is missing, confirm you are host and the complete Mod folder, including its helper, is installed. If composition fails, keep the existing menu and report relevant `[AutoMenu]` lines from `UE4SS.log` with what you clicked.

In-game testing was reported on 2026-09-26; the [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/releases/validation.md#english) describes its scope.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/auto-menu-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) · [MIT License](LICENSE)

## 中文

在电脑每日菜单页面的“打印菜单”旁增加 **自动组合** 按钮，按游戏的预计选择率选择菜单组合。

**版本：0.5.0-dev。** 仅单人或联机房主可用，只需房主安装，客机不显示该按钮。

### 怎么使用

1. 打开电脑的每日菜单页面，选择午餐或晚餐。
2. 点击 **自动组合**，对可用、启用且满足员工条件的菜品进行组合，比较游戏的预计选择率。
3. 查看结果，再通过游戏原有按钮编辑、启用或打印。

选中的菜单会保存，另一餐段保持原样。不自动采购、调价或打印；当前菜单符合条件且与最高值持平时会保留。类别可以留空，也可能得到全空菜单；全空菜单由游戏自动停用。

**可选菜品较多时，游戏可能会等待计算完成。** 没有进度条；只在点击按钮时运行，不会每天自动组合。

### 使用要求

Windows x64 版 Parisian Bistro Simulator，以及 **UE4SS experimental**。已核对的加载器版本为 `v3.0.1-1140-gf58e8f84`，不支持旧稳定版 UE4SS 3.0.1；其他加载器版本尚未验证。UE4SS 需单独安装。Mod ZIP 已含可直接使用的辅助文件，无需自行编译。

### 下载

1. 登录有权访问本私密仓库的 GitHub 账号，打开[Mod 安装包](https://github.com/martin-lzh/parisian-bistro-simulator-mods/actions/workflows/mods.yml?query=branch%3Adev)，选择最近一次成功且含有 **mod-packages** 的 **dev** 运行。
2. 打开该次运行 → **Artifacts** → **mod-packages** 并下载。先解压这一层压缩包，再解压里面的 **`AutoMenu-0.5.0-dev.zip`**。请选择 Mod ZIP，不要把 GitHub 的 **Source code** 当作安装包。

请选择包含上方版本的运行。安装包保留 14 天；包已过期、缺失或无法访问时，参见[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

### 安装

1. 关闭游戏。在 Steam 中右键 **Parisian Bistro Simulator** → **管理** → **浏览本地文件**，打开的就是下方所说的 `<game>` 游戏目录。
2. 按 [UE4SS 安装说明](https://docs.ue4ss.com/dev/installation-guide.html)安装 experimental 的基础包，保留该发行包自己的目录结构。
3. 将解压出的 **`AutoMenu`** 文件夹连同全部内容复制到 `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/`。若加载器实际装在其他位置，请使用它已有的 `Mods` 文件夹。
4. 确认存在以下文件，不要多套一层 `AutoMenu/AutoMenu` 文件夹：

   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/AutoMenu/Scripts/main.lua`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/AutoMenu/Scripts/auto_menu_bridge.dll`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/AutoMenu/enabled.txt`

5. 启动游戏，以房主身份打开餐厅电脑的每日菜单页面。

包内的 `enabled.txt` 会启用 Mod。请完整保留 Mod 文件夹，不要替换加载器的整个 `mods.txt` 或其他 Mod。`auto_menu_bridge.dll` 应留在本 Mod 的 `Scripts` 内。

### 更新与卸载

**更新：** 关闭游戏，下载并解压新版 Mod ZIP，把完整的 `AutoMenu` 文件夹复制到原来的 `Mods` 目录并覆盖同名文件，再启动游戏。

**卸载：** 关闭游戏，只删除 `Mods/AutoMenu`，保留 UE4SS 和其他 Mod。卸载会移除按钮，但不会撤销已由游戏保存的菜单；仍可使用原版按钮继续编辑。

可选操作：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。正常安装和更新不需要此操作。

### 语言与帮助

按钮跟随游戏当前语言，无需独立设置或语言包。菜名及预测结果沿用游戏原有文案，技术日志保持英文。

游戏语言包括英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。

按钮未出现时，先确认自己是房主，并已安装包含辅助文件的完整 Mod 文件夹。组合失败时保留当前菜单，反馈点击过程及 `UE4SS.log` 中相关的 `[AutoMenu]` 日志。

用户于 2026-09-26 反馈实机测试完成，具体范围见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/releases/validation.md#中文)。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/auto-menu-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文) · [MIT 许可证](LICENSE)
