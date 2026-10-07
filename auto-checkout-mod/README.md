# Auto Checkout / 收银管家

[![Auto Checkout / 收银管家 — AI-generated cover / AI 宣传封面](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/auto-checkout-mod/assets/cover.png?raw=1)](https://www.nexusmods.com/mods/2?game_id=10352)

[English](#english) · [中文](#中文)

## English

Automatically accept customers' cash or cards at the counter and finish the register interaction.

**Version: 0.1.4.** Single player or multiplayer host only. Only the host needs to install it; guests do not run checkout.

### How to use

1. Enter your restaurant in single player or as the multiplayer host. The Mod starts automatically; there is no new key, button, toggle or settings screen.
2. Let customers dine and come to an available checkout counter as usual. Automation waits for a bill and the customer's cash or card to be ready at the register. You do not need to click the customer-arrival notification or stand beside the counter.
3. For **cash**, the Mod accepts the offered money, waits for the drawer movement to finish, then performs the register interaction that closes the drawer and finishes checkout.
4. For a **card**, it accepts the card and waits for the terminal to finish processing and payment to succeed before finishing the open-drawer interaction. Do not treat the normal card-processing delay as a failure.
5. The game clears the completed bill and handles customer departure; the Mod then processes the next transaction. All eligible registers in the current restaurant are checked automatically, with no register selection required.

You can carry items, make drinks, open the tablet, place furniture or work away from the counter while it runs. Those activities do not pause automation; an actual game pause does, and processing continues after unpausing.

### What it handles

- Bills, tips, income and customer departure follow the game's normal rules.
- It waits while the drawer moves, a card is processing or an employee already owns that checkout. It also waits if the customer's bill or payment is not ready yet.
- Employees stop taking new **counter-checkout** jobs while the Mod runs. Already claimed jobs can finish; drink preparation, table checkout and their other work remain available.
- It does not take orders, serve meals, perform table checkout, make cash declarations, withdraw money or move cash bags. Continue using the game's own interactions for these tasks.
- You can still intervene manually. If you accept payment or finish the drawer first, the Mod reads the new state before its next action. It can also finish a valid transaction whose payment was already accepted manually.

In multiplayer, only the host installs the Mod to provide automatic checkout for the session. Guests can continue playing normally; a guest's installation alone cannot activate it. There is no in-game off switch. To return to normal employee counter checkout, close the game and remove the Mod as described below.

### In-game screenshot

A customer stands at the checkout counter, with the bill displayed on the register and the cash drawer open.

![Customer at the checkout counter with the bill on the register screen and the cash drawer open](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-checkout-v0.1.4/auto-checkout-mod/assets/counter-checkout-gameplay.png?raw=1)

### Requirements

Windows x64 Parisian Bistro Simulator and **UE4SS experimental**. The checked loader build is `v3.0.1-1140-gf58e8f84`; stable UE4SS 3.0.1 is not supported. Other loader builds have not been verified. UE4SS is installed separately.

### Download

Choose **one** download source; both provide the same Mod:

- **GitHub (no account needed):** open [Auto Checkout 0.1.4](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-checkout-v0.1.4), scroll to **Assets**, expand it if needed and click **AutoCheckout-0.1.4.zip**. `SHA256SUMS.txt` is an optional checksum file, not something to install. Do not choose **Source code**.
- **Nexus:** open the [Mod page](https://www.nexusmods.com/parisianbistrosimulator/mods/2), sign in or register a free account, select **Files → Main files → Manual download** for version **0.1.4**. Continue through the requirements notice if shown, select **Slow download** for a free account and wait for the ZIP. Keep the ZIP in your **Downloads** folder until the extraction step below.

### Install

These instructions start with only the Windows game installed. **Manual installation is free and does not require Vortex or a Nexus Premium subscription.** A web browser and Windows File Explorer are enough; Windows can extract ZIP files without WinRAR or 7-Zip. You do not need Git, Python, Visual Studio or Unreal Engine.

UE4SS is the **mod loader**: it starts the Mod when the game starts. Install it once for this game, then add any of the seven Mods to its `Mods` folder. Vortex is an optional **mod manager**, which copies and removes Mod files for you; it does not replace UE4SS.

1. **Exit the game completely.** In Steam, open **Library**, right-click **Parisian Bistro Simulator**, then choose **Manage → Browse local files**. The File Explorer window that opens is your game folder. Its name may be **Parisian Brasserie Simulator**. Do not use Documents or the save folder.
2. **Open the installation destination.** In that window, double-click **BrasserieSimulator**, then **Binaries**, then **Win64**. You should see **BrasserieSimulator-Win64-Shipping.exe** (Windows may hide `.exe`). Keep this window open. This is where the loader goes; do not put the loader beside the top-level `BrasserieSimulator.exe`.
3. **Download the loader.** Use [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip), the basic experimental build used as this project's reference. If the direct link fails, open [UE4SS experimental releases](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental), expand **Assets / Show all assets** and find that exact filename. Do not choose `zDEV`, `Source code` or the old stable `UE4SS_v3.0.1.zip`. Other experimental builds have not been verified for these Mods.
4. **Extract the loader ZIP.** In File Explorer's **Downloads** folder, right-click the downloaded ZIP → **Extract All… → Extract**. Open the extracted folder. Inside it, select **dwmapi.dll** and the entire **ue4ss** folder, right-click → **Copy**; return to the game's **Win64** window, right-click empty space → **Paste**. Copy both items themselves, not the outer folder named after the ZIP. There is no UE4SS installer to run. If you already have UE4SS installed, back up its folder and settings before replacing anything; keep your existing Mods.
5. **Check the loader location.** In **Win64**, `dwmapi.dll` must sit beside `BrasserieSimulator-Win64-Shipping.exe`. Open **ue4ss**: it must contain **UE4SS.dll**, **UE4SS-settings.ini** and **Mods**. If these are missing, repeat the extraction/copy step; an empty folder named `Mods` alone does not install the loader.
6. **Extract the Mod ZIP** downloaded above: right-click it → **Extract All… → Extract**. Open the extracted folder until you can see **AutoCheckout**, the folder that contains **Scripts** and **enabled.txt**. Windows may show `enabled` without `.txt`; that is normal.
7. **Copy the whole AutoCheckout folder.** Right-click it → **Copy**. In the game window, open **Win64 → ue4ss → Mods**, right-click empty space → **Paste**. Do not copy only `main.lua`, and do not place the ZIP itself in `Mods`.
8. **Check the result.** Open **Mods → AutoCheckout → Scripts**: **main.lua** must be there. Go back once to **AutoCheckout**: **enabled.txt** must be there beside **Scripts**. An extra `AutoCheckout/AutoCheckout` layer is incorrect. Leave `enabled.txt` as supplied, even if it is empty; it enables the Mod. Do not replace the loader's `mods.txt`.
9. **Start the game normally through Steam** and follow **How to use** above. Some Mods run in the background and have no startup message. Check the single-player/host/guest requirement at the top of this guide; the host is the player who opens the multiplayer restaurant for others to join.

The final entry point is `BrasserieSimulator/Binaries/Win64/ue4ss/Mods/AutoCheckout/Scripts/main.lua`, starting from the Steam game folder. If the feature does not work, close the game, recheck the two folder layouts above, then open `Win64/ue4ss/UE4SS.log` with Notepad and look for a recent timestamp or an error. See [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) before reinstalling.

**Using Vortex instead:** follow the [Vortex setup guide](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#english) to install Vortex, this game's extension and UE4SS first. Then import the original Mod ZIP, install, enable and deploy it. Use one installation method for this Mod. **The [collection](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz) currently requires an active Nexus Premium membership for one-click installation.** A free Nexus account or GitHub download can still be used for individual Mods; GitHub downloads need no account.

### Update or remove

**Update:** close the game, download and extract the new Mod ZIP, then copy its complete `AutoCheckout` folder into the same `Mods` folder and replace matching files. Start the game again.

**Remove:** close the game and delete only `Mods/AutoCheckout`. Leave UE4SS and other Mods in place. Close the game before removal so the game's normal employee checkout behavior returns on the next launch. Completed sales and income are not undone.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload). This is not required for normal installation or updates.

### Languages and help

The game's payment prompts and notifications keep their normal translations. The Mod's explanatory log messages follow the game language, with English used at early startup or when a language is unavailable. Technical identifiers and error details stay unchanged. No language pack is needed.

Game languages: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese.

If checkout does not start, confirm you are the host, the Mod folder is in the correct place, and the customer has reached a register with a bill and cash or a card ready. Allow the normal card/drawer animation and any employee's existing checkout to finish. Opening the tablet alone is not a reason for automation to stop.

For each of the two actions, the Mod makes at most three attempts, at least three seconds apart. After three attempts without progress it leaves that action for you: approach the counter, follow the game's normal cash/card interaction prompts, and finish the drawer interaction when payment is ready. Other registers and later customers can still be processed. Script reload does not reset the exhausted retry allowance for the same transaction.

If an error stops all automation, or a warning says employee jobs or interaction settings could not be restored, leave and reload the restaurant. Include relevant `[AutoCheckout]` lines from `UE4SS.log` with a problem report.

In-game and multiplayer testing passed as reported by the maintainer on 2026-09-26; the [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-checkout-v0.1.4/releases/validation.md#english) describes its scope.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/auto-checkout-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) · [MIT License](LICENSE)

## 中文

自动接收柜台顾客递出的现金或银行卡，并完成收银机结账。

**版本：0.1.4。** 仅单人或联机房主运行，只需房主安装，客机不会执行自动结账。

### 怎么使用

1. 以单人玩家或联机房主身份进入餐厅，Mod 自动运行，不需要新增按键、按钮、开关或设置界面。
2. 正常接待顾客用餐，等待顾客前往可用的收银柜台。收银机有账单、顾客的现金或银行卡准备好后才开始处理；不需要点击顾客到达收银台的通知，也不需要站在柜台旁。
3. **现金付款：**自动接收顾客递出的现金，等待钱柜动画结束，再执行收银机交互，关闭钱柜并完成结账。
4. **银行卡付款：**自动接收银行卡，等待终端处理结束且付款成功后，再完成打开的钱柜交互。正常刷卡等待期间无需干预。
5. 游戏清空已完成账单并处理顾客离店，Mod 随后处理下一笔交易。当前餐厅内符合条件的收银机都会自动检查，不需要逐台选择。

运行时可以继续搬运物品、制作饮料、打开平板、摆放家具或离开柜台做其他工作。这些操作不会暂停自动结账；游戏实际暂停时才等待，恢复游戏后继续。

### 功能范围

- 账单、小费、收入及顾客离店按游戏原有规则处理。
- 钱柜移动中、刷卡处理中或该笔结账已被员工接手时会等待；顾客账单或付款尚未准备好时也不会抢先操作。
- Mod 运行时，员工不再领取新的**柜台收银**任务，已经领取的任务可以完成；调饮、餐桌结账和其他工作仍可正常进行。
- 不负责点餐、上菜、餐桌结账、现金申报、取钱或搬运现金袋，这些操作继续使用游戏原有交互。
- 仍可手动介入。玩家先收款或先完成钱柜交互时，Mod 会在下一步前重新读取状态；手动收款后，只要交易状态允许，也可由 Mod 接着完成收尾。

联机时只需房主安装，即可为当前房间自动结账；客机照常游玩。仅在客机安装不能启用自动结账。没有游戏内停用开关；需要恢复员工正常柜台收银时，按下方说明关闭游戏并卸载。

### 实机截图

顾客站在收银台前，收银机显示账单，钱箱处于打开状态。

![实机画面：顾客站在收银台前，收银机显示账单，钱箱打开](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-checkout-v0.1.4/auto-checkout-mod/assets/counter-checkout-gameplay.png?raw=1)

### 使用要求

Windows x64 版 Parisian Bistro Simulator，以及 **UE4SS experimental**。已核对的加载器版本为 `v3.0.1-1140-gf58e8f84`，不支持旧稳定版 UE4SS 3.0.1；其他加载器版本尚未验证。UE4SS 需单独安装。

### 下载

以下来源**二选一**即可，提供的是同一个 Mod：

- **GitHub（无需账号）：**打开 [收银管家 0.1.4](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-checkout-v0.1.4)，向下找到并展开 **Assets（附件）**，点击 **AutoCheckout-0.1.4.zip**。`SHA256SUMS.txt` 是可选的校验文件，无需安装；不要下载 **Source code（源码）**。
- **Nexus：**打开 [Mod 页面](https://www.nexusmods.com/parisianbistrosimulator/mods/2)，登录或注册免费账号，在 **Files（文件）→ Main files（主要文件）** 找到 **0.1.4**，点击 **Manual download（手动下载）**。如出现前置要求提示，继续到下载页；免费账号选择 **Slow download（慢速下载）**，等待 ZIP 下载完成。先把 ZIP 保存在**下载**文件夹，下面再解压。

### 安装

以下步骤从电脑上只安装了 Windows 版游戏开始。**手动安装免费，不需要 Vortex，也不需要 Nexus Premium 会员。** 用浏览器和 Windows 文件资源管理器即可操作；Windows 自带 ZIP 解压功能，无需安装 WinRAR 或 7-Zip，也不需要 Git、Python、Visual Studio 或虚幻引擎。

UE4SS 是**加载器**，作用是在启动游戏时运行 Mod。每个游戏安装目录只需装一次，之后把所需 Mod 加入它的 `Mods` 文件夹即可。Vortex 是可选的 **Mod 管理器**，负责复制和移除 Mod 文件，不能代替 UE4SS。

1. **完全退出游戏。** 在 Steam 打开**库**，右键 **Parisian Bistro Simulator（法式小馆儿模拟器）→ 管理 → 浏览本地文件**。弹出的文件资源管理器窗口就是游戏目录，文件夹名可能是 **Parisian Brasserie Simulator**。不是“文档”或存档文件夹。
2. **打开安装位置。** 在该窗口依次双击 **BrasserieSimulator → Binaries → Win64**，应该能看到 **BrasserieSimulator-Win64-Shipping.exe**（Windows 可能隐藏 `.exe` 后缀）。保留此窗口，加载器就放在这里；不要放在最外层 `BrasserieSimulator.exe` 旁边。
3. **下载加载器。** 点击 [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip)，这是本项目核对过的 experimental 基础包。若直链失效，打开 [UE4SS experimental 发布页](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental)，展开 **Assets / Show all assets（附件／显示全部附件）**，找到这个完整文件名。不要下载 `zDEV`、`Source code`，也不要使用旧稳定版 `UE4SS_v3.0.1.zip`。其他 experimental 构建尚未核验。
4. **解压并放入加载器。** 在文件资源管理器的**下载**文件夹里，右键刚下载的 ZIP → **全部解压缩 → 提取**。打开解压后的文件夹，选中里面的 **dwmapi.dll** 和整个 **ue4ss** 文件夹，右键**复制**；回到游戏的 **Win64** 窗口，在空白处右键**粘贴**。复制这两个项目本身，不要把以压缩包命名的外层文件夹一起套进去。UE4SS 没有需要双击运行的安装程序。已经安装过加载器时，替换前备份其文件夹和设置，并保留现有 Mod。
5. **检查加载器位置。** **Win64** 中的 `dwmapi.dll` 应与 `BrasserieSimulator-Win64-Shipping.exe` 并排。打开 **ue4ss**，里面应有 **UE4SS.dll**、**UE4SS-settings.ini** 和 **Mods**。缺少这些内容时回到上一步重新解压、复制；只新建一个空的 `Mods` 文件夹不能装好加载器。
6. **解压上面下载的 Mod ZIP。** 右键 ZIP → **全部解压缩 → 提取**。打开解压后的文件夹，找到 **AutoCheckout** 文件夹；它里面应有 **Scripts** 和 **enabled.txt**。Windows 可能只显示 `enabled` 而隐藏 `.txt`，属于正常情况。
7. **复制整个 AutoCheckout 文件夹。** 右键它 → **复制**。在游戏窗口打开 **Win64 → ue4ss → Mods**，在空白处右键**粘贴**。不要只复制 `main.lua`，也不要把 ZIP 本身放进去。
8. **检查安装结果。** 依次打开 **Mods → AutoCheckout → Scripts**，应能看到 **main.lua**；返回一层到 **AutoCheckout**，应能看到与 **Scripts** 并排的 **enabled.txt**。不要多套成 `AutoCheckout/AutoCheckout`。即使 `enabled.txt` 是空文件也应原样保留，它用于启用 Mod；不要替换加载器的 `mods.txt`。
9. **从 Steam 正常启动游戏**，按上方“怎么使用”操作。有的 Mod 在后台工作，没有启动提示。先核对本说明开头的单人／房主／客机要求；房主指开启联机餐厅、让其他人加入的玩家。

从 Steam 打开的游戏目录算起，最终脚本位置是 `BrasserieSimulator/Binaries/Win64/ue4ss/Mods/AutoCheckout/Scripts/main.lua`。功能未生效时，先退出游戏、核对上述加载器和 Mod 两处目录，再用记事本打开 `Win64/ue4ss/UE4SS.log`，查看有没有本次运行的时间或错误。重装前可查看[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

**如果选择 Vortex：** 先按 [Vortex 安装说明](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#中文)装好 Vortex、本游戏扩展和 UE4SS，再导入原始 Mod ZIP，安装、启用并部署。同一个 Mod 只使用一种安装方式。**目前通过 [Nexus 合集](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz)一键安装需要有效的 Nexus Premium 会员。** 免费 Nexus 账号仍可逐个下载 Mod；GitHub 下载无需账号。

### 更新与卸载

**更新：** 关闭游戏，下载并解压新版 Mod ZIP，把完整的 `AutoCheckout` 文件夹复制到原来的 `Mods` 目录并覆盖同名文件，再启动游戏。

**卸载：** 关闭游戏，只删除 `Mods/AutoCheckout`，保留 UE4SS 和其他 Mod。务必关闭游戏后卸载，下次启动恢复游戏原有的员工收银行为；已完成交易和收入不会撤销。

可选操作：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。正常安装和更新不需要此操作。

### 语言与帮助

付款提示和通知沿用游戏译文。Mod 的说明日志跟随游戏语言，启动初期或语言不可用时使用英语；技术标识与错误详情保持原样，无需语言包。

游戏语言包括英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。

未自动结账时，先确认自己是房主、Mod 文件夹位置正确，且顾客已到收银台，收银机有账单和准备好的现金或银行卡。等待正常的刷卡、钱柜动画或员工已接手的交易结束；单纯打开平板不会阻止自动结账。

收款和钱柜收尾两步各最多尝试三次，同一步至少间隔三秒。三次仍无进展后，该步会留给玩家：走到柜台，按游戏现有的现金／银行卡提示处理，付款就绪后完成钱柜交互。其他收银机及后续顾客仍可继续自动处理；重新加载脚本不会重置同一交易已耗尽的重试次数。

异常导致全部自动化停止，或警告提示员工任务、交互设置恢复失败时，请退出餐厅后重新载入。反馈时附上 `UE4SS.log` 中相关的 `[AutoCheckout]` 日志。

维护者于 2026-09-26 确认实机及联机测试全部通过并授权正式发布，具体范围见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-checkout-v0.1.4/releases/validation.md#中文)。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/auto-checkout-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文) · [MIT 许可证](LICENSE)
