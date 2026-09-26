# Auto Checkout / 收银管家

[English](#english) · [中文](#中文)

## English

Automatically accept customers' cash or cards at the counter and finish the register interaction.

**Version: 0.1.4-dev.** Single player or multiplayer host only. Only the host needs to install it; guests do not run checkout.

### How to use

Enter your restaurant as host. Checkout starts automatically, with no key, toggle or settings to change. You can carry items, make drinks, open the tablet or work away from the counter.

- Bills, tips, income and customer departure follow the game's normal rules.
- It waits during a real pause, card processing, drawer movement or an employee's current checkout.
- Employees stop taking new counter-checkout jobs while the Mod runs; existing jobs may finish. Their other work is unchanged.
- Table checkout, cash declarations, withdrawals and cash bags are outside its scope.

If one transaction repeatedly fails, finish it manually; later customers can still be processed. If an error stops all checkout, check the help section before re-entering the restaurant.

### Requirements

Windows x64 Parisian Bistro Simulator and **UE4SS experimental**. The checked loader build is `v3.0.1-1140-gf58e8f84`; stable UE4SS 3.0.1 is not supported. Other loader builds have not been verified. UE4SS is installed separately.

### Download

1. Sign in to a GitHub account with access to this private repository. Open [Mod packages](https://github.com/martin-lzh/parisian-bistro-simulator-mods/actions/workflows/mods.yml?query=branch%3Adev) and choose the latest successful **dev** run with a **mod-packages** artifact.
2. Open that run → **Artifacts** → **mod-packages** and download it. Extract this outer archive, then extract **`AutoCheckout-0.1.4-dev.zip`** inside it. Use the Mod ZIP, not GitHub's **Source code** archive.

Use a run containing the version named above. Artifacts expire after 14 days; if the package is missing or you cannot access it, see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english).

### Install

1. Close the game. In Steam, right-click **Parisian Bistro Simulator** → **Manage** → **Browse local files**. This opens the `<game>` folder used below.
2. Install the basic experimental UE4SS package using the [UE4SS installation guide](https://docs.ue4ss.com/dev/installation-guide.html), keeping that package's folder structure.
3. Copy the extracted **`AutoCheckout`** folder, with all its contents, into `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/`. If your loader uses another location, use its existing `Mods` folder instead.
4. Confirm these files exist, with no extra `AutoCheckout/AutoCheckout` folder:

   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/AutoCheckout/Scripts/main.lua`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/AutoCheckout/enabled.txt`

5. Start the game and enter your restaurant in single player or as the multiplayer host.

The included `enabled.txt` enables the Mod. Keep the whole Mod folder together; do not replace the loader's `mods.txt` or other Mods.

### Update or remove

**Update:** close the game, download and extract the new Mod ZIP, then copy its complete `AutoCheckout` folder into the same `Mods` folder and replace matching files. Start the game again.

**Remove:** close the game and delete only `Mods/AutoCheckout`. Leave UE4SS and other Mods in place. Close the game before removal so the game's normal employee checkout behavior returns on the next launch. Completed sales and income are not undone.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload). This is not required for normal installation or updates.

### Languages and help

The game's payment prompts and notifications keep their normal translations. The Mod's explanatory log messages follow the game language, with English used at early startup or when a language is unavailable. Technical identifiers and error details stay unchanged. No language pack is needed.

Game languages: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese.

If checkout does not start, confirm you are the host and the Mod folder is in the correct place. For a stuck transaction, try finishing it manually. If a warning says employee jobs or interaction settings could not be restored, leave and reload the restaurant. Include relevant `[AutoCheckout]` lines from `UE4SS.log` with a problem report.

In-game testing was reported on 2026-09-26; the [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/releases/validation.md#english) describes its scope.

[Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) · [MIT License](LICENSE)

## 中文

自动接收柜台顾客递出的现金或银行卡，并完成收银机结账。

**版本：0.1.4-dev。** 仅单人或联机房主运行，只需房主安装，客机不会执行自动结账。

### 怎么使用

以房主身份进入餐厅即可自动结账，无需按键、开关或额外设置。可以同时搬运物品、制作饮料、打开平板或离开柜台做其他工作。

- 账单、小费、收入及顾客离店按游戏原有规则处理。
- 游戏实际暂停、刷卡中、钱柜移动中或员工正在处理该笔结账时会等待。
- Mod 运行时，员工不再领取新的柜台收银任务；已领取的任务可以完成，其他工作照常进行。
- 不处理餐桌结账、现金申报、取钱或现金袋。

某笔交易多次未成功时，请手动完成，后续顾客仍可自动处理。若异常导致全部自动结账停止，请先查看下方帮助，再重新进入餐厅。

### 使用要求

Windows x64 版 Parisian Bistro Simulator，以及 **UE4SS experimental**。已核对的加载器版本为 `v3.0.1-1140-gf58e8f84`，不支持旧稳定版 UE4SS 3.0.1；其他加载器版本尚未验证。UE4SS 需单独安装。

### 下载

1. 登录有权访问本私密仓库的 GitHub 账号，打开[Mod 安装包](https://github.com/martin-lzh/parisian-bistro-simulator-mods/actions/workflows/mods.yml?query=branch%3Adev)，选择最近一次成功且含有 **mod-packages** 的 **dev** 运行。
2. 打开该次运行 → **Artifacts** → **mod-packages** 并下载。先解压这一层压缩包，再解压里面的 **`AutoCheckout-0.1.4-dev.zip`**。请选择 Mod ZIP，不要把 GitHub 的 **Source code** 当作安装包。

请选择包含上方版本的运行。安装包保留 14 天；包已过期、缺失或无法访问时，参见[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

### 安装

1. 关闭游戏。在 Steam 中右键 **Parisian Bistro Simulator** → **管理** → **浏览本地文件**，打开的就是下方所说的 `<game>` 游戏目录。
2. 按 [UE4SS 安装说明](https://docs.ue4ss.com/dev/installation-guide.html)安装 experimental 的基础包，保留该发行包自己的目录结构。
3. 将解压出的 **`AutoCheckout`** 文件夹连同全部内容复制到 `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/`。若加载器实际装在其他位置，请使用它已有的 `Mods` 文件夹。
4. 确认存在以下文件，不要多套一层 `AutoCheckout/AutoCheckout` 文件夹：

   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/AutoCheckout/Scripts/main.lua`
   - `<game>/BrasserieSimulator/Binaries/Win64/ue4ss/Mods/AutoCheckout/enabled.txt`

5. 启动游戏，以单人玩家或联机房主身份进入餐厅。

包内的 `enabled.txt` 会启用 Mod。请完整保留 Mod 文件夹，不要替换加载器的整个 `mods.txt` 或其他 Mod。

### 更新与卸载

**更新：** 关闭游戏，下载并解压新版 Mod ZIP，把完整的 `AutoCheckout` 文件夹复制到原来的 `Mods` 目录并覆盖同名文件，再启动游戏。

**卸载：** 关闭游戏，只删除 `Mods/AutoCheckout`，保留 UE4SS 和其他 Mod。务必关闭游戏后卸载，下次启动恢复游戏原有的员工收银行为；已完成交易和收入不会撤销。

可选操作：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。正常安装和更新不需要此操作。

### 语言与帮助

付款提示和通知沿用游戏译文。Mod 的说明日志跟随游戏语言，启动初期或语言不可用时使用英语；技术标识与错误详情保持原样，无需语言包。

游戏语言包括英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。

未自动结账时，先确认自己是房主，且 Mod 文件夹位置正确。单笔交易卡住可先手动完成。若警告提示员工任务或交互设置恢复失败，请退出餐厅后重新载入。反馈时附上 `UE4SS.log` 中相关的 `[AutoCheckout]` 日志。

用户于 2026-09-26 反馈实机测试完成，具体范围见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/releases/validation.md#中文)。

[版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文) · [MIT 许可证](LICENSE)
