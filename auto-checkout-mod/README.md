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

1. Open [Auto Checkout 0.1.4](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-checkout-v0.1.4).
2. Under **Assets**, download **`AutoCheckout-0.1.4.zip`** and `SHA256SUMS.txt`. Extract the Mod ZIP; GitHub's **Source code** archive is not an installable Mod.

If the package is missing or you cannot access it, see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english).

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

1. 打开 [收银管家 0.1.4](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-checkout-v0.1.4)。
2. 在 **Assets** 中下载 **`AutoCheckout-0.1.4.zip`** 和 `SHA256SUMS.txt`。解压 Mod ZIP；GitHub 的 **Source code** 是源码，不能当作安装包。

找不到文件或无法访问时，见[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

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

未自动结账时，先确认自己是房主、Mod 文件夹位置正确，且顾客已到收银台，收银机有账单和准备好的现金或银行卡。等待正常的刷卡、钱柜动画或员工已接手的交易结束；单纯打开平板不会阻止自动结账。

收款和钱柜收尾两步各最多尝试三次，同一步至少间隔三秒。三次仍无进展后，该步会留给玩家：走到柜台，按游戏现有的现金／银行卡提示处理，付款就绪后完成钱柜交互。其他收银机及后续顾客仍可继续自动处理；重新加载脚本不会重置同一交易已耗尽的重试次数。

异常导致全部自动化停止，或警告提示员工任务、交互设置恢复失败时，请退出餐厅后重新载入。反馈时附上 `UE4SS.log` 中相关的 `[AutoCheckout]` 日志。

维护者于 2026-09-26 确认实机及联机测试全部通过并授权正式发布，具体范围见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-checkout-v0.1.4/releases/validation.md#中文)。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/auto-checkout-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文) · [MIT 许可证](LICENSE)
