# Smart Delivery / 配送随心

[English](#english) · [中文](#中文)

## English

Choose Free service, Budget delivery or Premium delivery for automatic smart orders on the restaurant computer.

**Version: 0.1.5-dev.** Single player or multiplayer host only. Only the host needs to install it; guests cannot edit the Mod's delivery choice.

### How to use

1. Open the restaurant computer's **automatic smart-order settings**.
2. Choose a **Delivery method**.
3. Click the game's **Save** button. **Cancel** discards your unsaved change.

**Premium delivery is the initial preference.** Free service has no unloading staff, Budget has one worker, and Premium has four. The game's service fees and night surcharges still apply.

Automatic ordering must already be enabled in the game. The Mod does not place extra orders or change manual ingredient/furniture deliveries. Stock rules, the purchase minimum and money checks remain controlled by the game.

Your saved choice survives restarts and is shared by this installation's restaurants. It is stored in `SmartDelivery/Scripts/delivery-preference.txt`; keep that file when updating. The Mod folder must be writable.

### Requirements

Windows x64 Parisian Bistro Simulator and **UE4SS experimental**. The checked loader build is `v3.0.1-1140-gf58e8f84`; stable UE4SS 3.0.1 is not supported. Other loader builds have not been verified. UE4SS is installed separately. The ready-to-use Mod ZIP includes its helper; no compiling is needed.

### Download

1. Sign in to a GitHub account with access to this private repository. Open [Mod packages](https://github.com/martin-lzh/parisian-bistro-simulator-mods/actions/workflows/mods.yml?query=branch%3Adev) and choose the latest successful **dev** run with a **mod-packages** artifact.
2. Open that run → **Artifacts** → **mod-packages** and download it. Extract this outer archive, then extract **`SmartDelivery-0.1.5-dev.zip`** inside it. Use the Mod ZIP, not GitHub's **Source code** archive.

Use a run containing the version named above. Artifacts expire after 14 days; if the package is missing or you cannot access it, see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english).

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

**Remove:** close the game and delete only `Mods/SmartDelivery`. Leave UE4SS and other Mods in place. The game returns to its normal automatic delivery selection. To disable the Mod while retaining its preference, remove only `SmartDelivery/enabled.txt` with the game closed; restoring that empty file enables it again. Deleting the whole folder also deletes the saved Mod preference. Game saves need no conversion.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload). This is not required for normal installation or updates.

### Languages and help

The delivery names use the game's translations, and the added field label follows the game language. No language pack or separate setting is needed. Technical logs remain English.

Game languages: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese.

If the selector is missing, confirm you are host and installed the complete folder, including the bundled helper. If the saved choice is not retained, check that the folder can be written to. For a problem report, include relevant `[SmartDelivery]` lines from `UE4SS.log` and `SmartDelivery/Scripts/bridge-status.txt` if it exists.

In-game testing was reported on 2026-09-26; the [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/releases/validation.md#english) describes its scope.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/smart-delivery-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) · [MIT License](LICENSE)

## 中文

在餐厅电脑的自动智能订购设置中，选择免费服务、经济型配送或高级配送。

**版本：0.1.5-dev。** 仅单人或联机房主可设置，只需房主安装；客机不能修改 Mod 配送选项。

### 怎么使用

1. 打开餐厅电脑的 **自动智能订购设置**。
2. 选择 **配送方式**。
3. 点击游戏原有的 **保存**。点击 **取消** 会放弃未保存的修改。

**首次使用默认为高级配送。** 免费服务没有卸货员，经济型配送有 1 人，高级配送有 4 人；游戏原有服务费和夜间附加费仍然有效。

须先在游戏中启用自动订购。Mod 不会额外下单，也不改变手动购买食材或家具的配送方式；库存规则、采购金额下限及余额检查仍由游戏处理。

已保存的选择在重启后保留，同一安装下的各餐厅共用，保存在 `SmartDelivery/Scripts/delivery-preference.txt`。更新时请保留此文件，Mod 文件夹需允许写入。

### 使用要求

Windows x64 版 Parisian Bistro Simulator，以及 **UE4SS experimental**。已核对的加载器版本为 `v3.0.1-1140-gf58e8f84`，不支持旧稳定版 UE4SS 3.0.1；其他加载器版本尚未验证。UE4SS 需单独安装。Mod ZIP 已含可直接使用的辅助文件，无需自行编译。

### 下载

1. 登录有权访问本私密仓库的 GitHub 账号，打开[Mod 安装包](https://github.com/martin-lzh/parisian-bistro-simulator-mods/actions/workflows/mods.yml?query=branch%3Adev)，选择最近一次成功且含有 **mod-packages** 的 **dev** 运行。
2. 打开该次运行 → **Artifacts** → **mod-packages** 并下载。先解压这一层压缩包，再解压里面的 **`SmartDelivery-0.1.5-dev.zip`**。请选择 Mod ZIP，不要把 GitHub 的 **Source code** 当作安装包。

请选择包含上方版本的运行。安装包保留 14 天；包已过期、缺失或无法访问时，参见[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

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

**卸载：** 关闭游戏，只删除 `Mods/SmartDelivery`，保留 UE4SS 和其他 Mod。卸载后恢复游戏原有的自动配送选择。若只想停用并保留偏好，关闭游戏后仅删除 `SmartDelivery/enabled.txt`；重新放回这个空文件即可启用。删除整个文件夹也会删除 Mod 保存的配送偏好，游戏存档无需转换。

可选操作：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。正常安装和更新不需要此操作。

### 语言与帮助

配送名称沿用游戏译文，新增字段标题跟随游戏语言，无需语言包或独立设置。技术日志保持英文。

游戏语言包括英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。

选择框未出现时，先确认自己是房主，且已复制完整文件夹，包括包内辅助文件。选择无法保留时，请检查文件夹是否允许写入。反馈时附上 `UE4SS.log` 中相关的 `[SmartDelivery]` 日志，以及存在时的 `SmartDelivery/Scripts/bridge-status.txt`。

用户于 2026-09-26 反馈实机测试完成，具体范围见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/releases/validation.md#中文)。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/smart-delivery-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文) · [MIT 许可证](LICENSE)
