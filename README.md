# Parisian Bistro Simulator Mods

![LZH's MODS — Parisian Bistro Simulator; AI-generated cover / AI 宣传封面](assets/cover.png)

[English](#english) · [中文](#中文)

## English

Unofficial Mods for Parisian Bistro Simulator on Windows. Choose the features you want and follow their installation guides.

### Choose a Mod

| Mod | What it does | Version |
| --- | --- | --- |
| [Bartender's Note](bartenders-note-mod/README.md#english) | Shows your claimed, unfinished drinks below the restaurant name | 0.1.2 |
| [Auto Checkout](auto-checkout-mod/README.md#english) | Accepts cash or cards and completes checkout automatically | 0.1.4 |
| [Fresh to Serve](fresh-to-serve-mod/README.md#english) | Clears spoiled meals and drinks and requests replacements when the customer can still wait | 0.1.2 |
| [First to Serve](first-to-serve-mod/README.md#english) | Hold at a kitchen pass or drink output area to collect the oldest ready items with a tray or food trolley | 0.1.7 |
| [Smart Delivery](smart-delivery-mod/README.md#english) | Choose free, budget or premium delivery for automatic smart orders | 0.1.5 |
| [Auto Menu](auto-menu-mod/README.md#english) | Choose a lunch or dinner menu with the highest estimated selection rate | 0.5.0 |
| [Scan to Order](scan-to-order-mod/README.md#english) | Take customer orders automatically, waiting for missing stock and continuing after replenishment | 0.1.1 |

These stable versions follow the maintainer's confirmation that all seven Mods passed in-game and multiplayer testing on 2026-09-26. Check each guide for host/guest requirements and gameplay limits; see the [validation record](releases/validation.md#english).

### Download and install

1. Open [Mod Releases](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases), or use the version-specific release link in each Mod guide.
2. Download the Mod ZIP and `SHA256SUMS.txt` under **Assets**, then extract the ZIP. GitHub's **Source code** archive is not an installable Mod.
3. Close the game. In Steam, right-click **Parisian Bistro Simulator → Manage → Browse local files**. Install **UE4SS experimental** using its [installation guide](https://docs.ue4ss.com/dev/installation-guide.html). The checked loader version is `v3.0.1-1140-gf58e8f84`; old stable UE4SS 3.0.1 is not supported. Use the loader package's own folder layout.
4. Put the extracted Mod folder inside the loader's existing `Mods` folder. The usual location is `BrasserieSimulator/Binaries/Win64/ue4ss/Mods` inside the game folder. For example, Bartender's Note should contain `Mods/BartendersNote/Scripts/main.lua` and `Mods/BartendersNote/enabled.txt`, with no extra nested `BartendersNote` folder.
5. Start the game and follow the Mod's usage steps. Install only the Mods you want. The loader is not included; no compilation is needed to use a Mod ZIP.

The repository and Release downloads are public; no GitHub sign-in is required. Updates and removal should be done with the game closed; each Mod's guide names the folder to replace or remove. Keep the loader and other Mods in place.

### Languages and help

Mod text follows the game's language. English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese are supported. No extra language pack is needed. Mods without their own interface keep the game's original text.

For installation problems or a feature that is not working, start with [help and feedback](SUPPORT.md#english). Include the Mod version, game and loader versions, language, and whether you are the host or a guest.

Original Mod code and documentation are by **Zhaohan Liu**, under the [MIT License](LICENSE). Each Mod ZIP includes its license. Game files and the loader are distributed separately under their own terms. This project is not affiliated with the game's creators.

[Contributing](CONTRIBUTING.md#english) · [Development](DEVELOPMENT.md#english) · [Security](SECURITY.md#english) · [Community guidelines](CODE_OF_CONDUCT.md#english)

## 中文

为 Windows 版法式小馆儿模拟器提供便利的非官方 Mod。按需选择功能，再按对应说明安装即可。

### 选择 Mod

| Mod | 功能 | 版本 |
| --- | --- | --- |
| [Bartender's Note（调饮手记）](bartenders-note-mod/README.md#中文) | 在餐厅名称下显示自己认领且尚未做完的饮料 | 0.1.2 |
| [Auto Checkout（收银管家）](auto-checkout-mod/README.md#中文) | 自动接收现金或银行卡并完成结账 | 0.1.4 |
| [Fresh to Serve（焕鲜上桌）](fresh-to-serve-mod/README.md#中文) | 清理低劣食物和饮料；顾客仍有足够耐心时请求重做 | 0.1.2 |
| [First to Serve（出餐有序）](first-to-serve-mod/README.md#中文) | 持托盘或推餐车，对准出餐口或饮料出品台长按，优先拿取最早做好的成品 | 0.1.7 |
| [Smart Delivery（配送随心）](smart-delivery-mod/README.md#中文) | 为自动智能订购选择免费服务、经济型配送或高级配送 | 0.1.5 |
| [Auto Menu（菜单巧配）](auto-menu-mod/README.md#中文) | 为午餐或晚餐选择预计选择率最高的菜单 | 0.5.0 |
| [Scan to Order（扫码点餐）](scan-to-order-mod/README.md#中文) | 自动提交顾客订单，缺货时等待、补货后继续 | 0.1.1 |

维护者于 2026-09-26 确认全部 7 个 Mod 实机及联机测试通过，当前提供对应正式版。房主／客机要求及玩法限制见各 Mod 说明，测试反馈见[验收记录](releases/validation.md#中文)。

### 下载与安装

1. 打开 [Mod 正式版本](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases)，或使用各 Mod 说明中的对应版本下载链接。
2. 在 **Assets** 中下载 Mod ZIP 和 `SHA256SUMS.txt`，再解压 ZIP。GitHub 的 **Source code** 是源码，不能当作 Mod 安装。
3. 关闭游戏。在 Steam 中右键点击**法式小馆儿模拟器 → 管理 → 浏览本地文件**。按[官方安装说明](https://docs.ue4ss.com/dev/installation-guide.html)安装 **UE4SS experimental**。已核对的加载器版本为 `v3.0.1-1140-gf58e8f84`，不支持旧稳定版 UE4SS 3.0.1；请保留加载器压缩包自身的目录结构。
4. 将解压出的 Mod 文件夹整体放入加载器已有的 `Mods` 文件夹。常见位置是游戏目录中的 `BrasserieSimulator/Binaries/Win64/ue4ss/Mods`。例如 Bartender's Note 安装后应有 `Mods/BartendersNote/Scripts/main.lua` 和 `Mods/BartendersNote/enabled.txt`，不要多套一层同名文件夹。
5. 启动游戏，按对应 Mod 的操作说明使用。可以只安装需要的 Mod；安装包不含加载器，使用 Mod ZIP 无需自行编译。

仓库及 Release 附件均已公开，无需登录 GitHub 即可下载。更新和卸载均应先关闭游戏；各 Mod 说明列出应替换或移除的文件夹，请保留加载器及其他 Mod。

### 语言与帮助

Mod 文案跟随游戏语言，支持英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语及巴西葡萄牙语，无需额外语言包。不新增界面的 Mod 继续使用游戏原有文案。

安装遇到问题或功能没有生效时，先查看[帮助与反馈](SUPPORT.md#中文)。反馈时请提供 Mod、游戏及加载器版本、所选语言，以及自己是房主还是客机。

原创 Mod 代码及文档由 **Zhaohan Liu** 编写，使用 [MIT 许可证](LICENSE)，每份 Mod ZIP 均附许可全文。游戏文件及加载器另行分发，遵循各自条款。本项目与游戏制作方无隶属关系。

[参与贡献](CONTRIBUTING.md#中文) · [开发说明](DEVELOPMENT.md#中文) · [安全反馈](SECURITY.md#中文) · [社区规范](CODE_OF_CONDUCT.md#中文)
