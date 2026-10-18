# Auto Checkout / 收银管家

[![Auto Checkout / 收银管家 — AI-generated cover / AI 宣传封面](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/auto-checkout-mod/assets/cover.png?raw=1)](https://www.nexusmods.com/mods/2?game_id=10352)

[English](#english) · [中文](#中文)

## English

Automatically accepts customers' cash or cards at the counter and finishes checkout at the register.

**Version: 0.1.4.** Works in single player or for the multiplayer host. Only the host needs to install it.

### How to use

1. Enter your restaurant in single player or as the multiplayer host. The Mod starts on its own; there is no key, button, toggle or settings screen.
2. Serve customers as usual. When a customer reaches a checkout counter and the register shows a bill with cash or a card ready, the Mod takes over. You don't need to click the arrival notification or stand at the counter.
3. **Cash:** the Mod accepts the money, waits for the drawer to finish moving, then closes the drawer to finish checkout.
4. **Card:** the Mod accepts the card, waits for the terminal to approve the payment, then closes the drawer. The short card-processing wait is normal.
5. The game clears the bill and the customer leaves; the Mod then handles the next customer. Every register in the restaurant, on every floor, is covered automatically.

While it runs you can carry items, make drinks, use the tablet, place furniture or work elsewhere. Automation waits only while the game is paused and continues when you unpause.

### What it handles

- Bills, tips, income and customer departure follow the game's normal rules.
- It waits while the drawer is moving, a card is processing, an employee is already handling that checkout, or the bill or payment isn't ready yet.
- While the Mod runs, employees stop taking new **counter checkout** jobs. Jobs they already started still finish, and they keep making drinks, doing table checkout and their other work.
- Orders, serving, table checkout, cash declarations, withdrawals and cash bags stay manual, using the game's own interactions.
- You can still step in at any time. If you accept a payment or close the drawer yourself, the Mod picks up from there, and it can finish a checkout whose payment you already accepted.

In multiplayer, the host's installation runs automatic checkout for the whole session; guests play normally. There is no in-game off switch. To get normal employee counter checkout back, close the game and remove the Mod (see below).

### In-game screenshot

A customer stands at the checkout counter, with the bill displayed on the register and the cash drawer open.

![Customer at the checkout counter with the bill on the register screen and the cash drawer open](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-checkout-v0.1.4/auto-checkout-mod/assets/counter-checkout-gameplay.png?raw=1)

### Requirements

- Windows version of Parisian Bistro Simulator, up to game version 1.0.2.44eb (Steam Build 25822788).
- [UE4SS experimental](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental) `v3.0.1-1140-gf58e8f84`, installed separately (see **Install**). The older stable UE4SS 3.0.1 does not work.
- In multiplayer, only the host needs the Mod.

### Download

Pick either source; both have the same file.

- **GitHub (no account needed):** open [Auto Checkout 0.1.4](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-checkout-v0.1.4) and download **AutoCheckout-0.1.4.zip** under **Assets**. Don't pick **Source code**.
- **Nexus:** open the [Mod page](https://www.nexusmods.com/parisianbistrosimulator/mods/2), go to **Files → Main files → Manual download**, then choose **Slow download** if you have a free account.

### Install

Manual installation is free and needs neither Vortex nor Nexus Premium.

UE4SS is the mod loader that runs Mods when the game starts. Install it once, then put Mods in its `Mods` folder. If UE4SS is already installed, start at step 6.

1. **Close the game.** In Steam, open **Library**, right-click **Parisian Bistro Simulator** → **Manage → Browse local files**. This opens the game folder (it may be named **Parisian Brasserie Simulator**).
2. **Open BrasserieSimulator → Binaries → Win64.** You should see **BrasserieSimulator-Win64-Shipping.exe** (Windows may hide the `.exe`). Keep this window open; the loader goes here.
3. **Download UE4SS:** [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip). If the link doesn't open, find that exact file under **Assets** on the [UE4SS experimental release page](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental). Don't use `zDEV`, `Source code` or the old stable `UE4SS_v3.0.1.zip`.
4. **Copy the loader into Win64.** Right-click the ZIP → **Extract All… → Extract**. From the extracted folder, copy **dwmapi.dll** and the **ue4ss** folder and paste both into **Win64**. If you are replacing an existing UE4SS, back up its folder first.
5. **Check the loader:** `dwmapi.dll` sits next to `BrasserieSimulator-Win64-Shipping.exe`, and the **ue4ss** folder contains **UE4SS.dll**, **UE4SS-settings.ini** and **Mods**.
6. **Extract the Mod ZIP** and open it until you see the **AutoCheckout** folder, which contains **Scripts** and **enabled.txt**.
7. **Copy the whole AutoCheckout folder** into **Win64 → ue4ss → Mods**.
8. **Check the Mod:** `Mods/AutoCheckout/Scripts/main.lua` and `Mods/AutoCheckout/enabled.txt` should exist (not `AutoCheckout/AutoCheckout`). Keep `enabled.txt` even if it is empty.
9. **Start the game through Steam** and follow **How to use** above.

If the Mod doesn't work, close the game, recheck steps 5 and 8, then see [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english).

**Using Vortex instead:** set up Vortex, the game extension and UE4SS with the [Vortex guide](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#english), then import the Mod ZIP, enable it and deploy. Install each Mod either with Vortex or manually, not both. One-click install of the [collection](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz) requires Nexus Premium.

### Update or remove

**Update:** close the game, extract the new Mod ZIP and copy its whole `AutoCheckout` folder into the same `Mods` folder, replacing the existing files. Then start the game.

**Remove:** close the game and delete only `Mods/AutoCheckout`; leave UE4SS and other Mods in place. Normal employee counter checkout returns the next time you start the game.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload). Normal installs and updates don't need this.

### Languages and help

Payment prompts and notifications are the game's own. The Mod's log messages follow the game language: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese or Brazilian Portuguese.

**If checkout doesn't start:** make sure you are the host, the Mod folder is in the right place, and the customer is at a register with a bill and cash or a card ready. Let any card or drawer animation, or an employee's checkout already in progress, finish first.

**If one step keeps failing:** the Mod tries accepting payment and closing the drawer up to three times each, at least three seconds apart. After that it leaves that step to you: go to the counter, follow the game's normal cash or card prompts, and close the drawer once payment is done. Other registers and later customers are still handled automatically. Reloading scripts doesn't give the same checkout new tries.

**If automation stops with an error,** or a warning says employee jobs or interaction settings couldn't be restored, leave the restaurant and load it again. When reporting a problem, include the `[AutoCheckout]` lines from `Win64/ue4ss/UE4SS.log`.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/auto-checkout-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) · [PolyForm Noncommercial License 1.0.0](LICENSE)

## 中文

自动接收柜台顾客递出的现金或银行卡，并在收银机上完成结账。

**版本：0.1.4。** 适用于单人游戏或联机房主，只需房主安装。

### 怎么使用

1. 以单人或联机房主身份进入餐厅，Mod 自动运行，没有按键、按钮、开关或设置界面。
2. 照常接待顾客。顾客走到收银柜台、收银机显示账单且现金或银行卡已递出后，Mod 自动接手；不用点击顾客到达通知，也不用站在柜台旁。
3. **现金：**自动收下现金，等钱柜动作结束后关上钱柜，完成结账。
4. **银行卡：**自动接过银行卡，等终端确认付款成功后关上钱柜。刷卡时稍等片刻属于正常现象。
5. 游戏清空账单、顾客离店后，Mod 接着处理下一位顾客。餐厅各楼层的所有收银机都会自动处理。

运行期间可以照常搬东西、调饮料、用平板、摆家具或去别处忙。只有游戏暂停时才会等待，取消暂停后继续。

### 功能范围

- 账单、小费、收入和顾客离店均按游戏原有规则处理。
- 钱柜正在移动、正在刷卡、员工已在处理这笔结账，或账单、付款尚未就绪时，Mod 会等待。
- Mod 运行时，员工不再领取新的**柜台收银**任务；已经开始的任务照常完成，调饮、餐桌结账和其他工作不受影响。
- 点餐、上菜、餐桌结账、现金申报、取钱和搬运现金袋仍需手动，使用游戏原有交互。
- 随时可以手动介入。你先收款或先关钱柜时，Mod 会接着当前进度继续；你已手动收款的交易，Mod 也能接着完成。

联机时，房主安装即可为整个房间自动结账，客机照常游玩。没有游戏内关闭开关；想恢复员工柜台收银，请关闭游戏后卸载 Mod（见下文）。

### 实机截图

顾客站在收银台前，收银机显示账单，钱箱处于打开状态。

![实机画面：顾客站在收银台前，收银机显示账单，钱箱打开](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-checkout-v0.1.4/auto-checkout-mod/assets/counter-checkout-gameplay.png?raw=1)

### 使用要求

- Windows 版 Parisian Bistro Simulator，支持至游戏版本 1.0.2.44eb（Steam Build 25822788）。
- [UE4SS experimental](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental) `v3.0.1-1140-gf58e8f84`，需单独安装（见“安装”）。旧稳定版 UE4SS 3.0.1 无法使用。
- 联机时只需房主安装。

### 下载

以下两个来源任选其一，文件相同。

- **GitHub（无需账号）：**打开 [收银管家 0.1.4](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/auto-checkout-v0.1.4)，在 **Assets（附件）** 下载 **AutoCheckout-0.1.4.zip**。不要选 **Source code（源码）**。
- **Nexus：**打开 [Mod 页面](https://www.nexusmods.com/parisianbistrosimulator/mods/2)，进入 **Files（文件）→ Main files（主要文件）→ Manual download（手动下载）**；免费账号选择 **Slow download（慢速下载）**。

### 安装

手动安装免费，不需要 Vortex，也不需要 Nexus Premium。

UE4SS 是 Mod 加载器，负责在游戏启动时运行 Mod。只需安装一次，之后把 Mod 放进它的 `Mods` 文件夹。已经装好 UE4SS 的，从第 6 步开始。

1. **退出游戏。** 在 Steam **库**中右键 **Parisian Bistro Simulator（法式小馆儿模拟器）→ 管理 → 浏览本地文件**，打开游戏目录（文件夹名可能是 **Parisian Brasserie Simulator**）。
2. **依次打开 BrasserieSimulator → Binaries → Win64**，能看到 **BrasserieSimulator-Win64-Shipping.exe**（Windows 可能隐藏 `.exe` 后缀）。保持这个窗口打开，加载器就装在这里。
3. **下载 UE4SS：**[UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip)。链接打不开时，到 [UE4SS experimental 发布页](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental)的 **Assets** 中找同名文件。不要下载 `zDEV`、`Source code` 或旧稳定版 `UE4SS_v3.0.1.zip`。
4. **把加载器放进 Win64。** 右键 ZIP → **全部解压缩 → 提取**，从解压出的文件夹中复制 **dwmapi.dll** 和 **ue4ss** 文件夹，粘贴到 **Win64**。替换已有的 UE4SS 前，先备份原文件夹。
5. **检查加载器：**`dwmapi.dll` 与 `BrasserieSimulator-Win64-Shipping.exe` 在同一层；**ue4ss** 文件夹里有 **UE4SS.dll**、**UE4SS-settings.ini** 和 **Mods**。
6. **解压 Mod ZIP**，打开到能看到 **AutoCheckout** 文件夹，里面有 **Scripts** 和 **enabled.txt**。
7. **把整个 AutoCheckout 文件夹**复制到 **Win64 → ue4ss → Mods**。
8. **检查 Mod：**应有 `Mods/AutoCheckout/Scripts/main.lua` 和 `Mods/AutoCheckout/enabled.txt`（不要多套一层 `AutoCheckout/AutoCheckout`）。`enabled.txt` 即使是空文件也要保留。
9. **从 Steam 启动游戏**，按上方“怎么使用”操作。

不生效时，先退出游戏，核对第 5、8 步，再查看[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

**改用 Vortex：**先按 [Vortex 安装说明](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#中文)装好 Vortex、游戏扩展和 UE4SS，再导入 Mod ZIP，启用并部署。同一个 Mod 只用 Vortex 或手动其中一种方式安装。通过 [Nexus 合集](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz)一键安装需要 Nexus Premium。

### 更新与卸载

**更新：**关闭游戏，解压新版 Mod ZIP，把完整的 `AutoCheckout` 文件夹复制到原来的 `Mods` 文件夹并覆盖同名文件，再启动游戏。

**卸载：**关闭游戏，只删除 `Mods/AutoCheckout`，保留 UE4SS 和其他 Mod。下次启动游戏时，员工柜台收银恢复正常。

可选操作：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。正常安装和更新不需要。

### 语言与帮助

付款提示和通知使用游戏自带文本。Mod 的日志说明跟随游戏语言：英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语或巴西葡萄牙语。

**没有自动结账时：**确认自己是房主、Mod 文件夹位置正确，并且顾客已在收银台、收银机有账单、现金或银行卡已递出。刷卡、钱柜动画或员工正在处理的结账需要先完成。

**某一步一直没成功时：**收款和关钱柜两步各最多尝试三次，每次至少间隔三秒。三次后这一步交给你：走到柜台，按游戏原有的现金或银行卡提示操作，付款完成后关上钱柜。其他收银机和后面的顾客仍会自动处理。重新加载脚本不会让同一笔交易重新获得尝试次数。

**自动结账因错误停止，**或提示员工任务、交互设置无法恢复时，请退出餐厅后重新载入。反馈问题时，请附上 `Win64/ue4ss/UE4SS.log` 中的 `[AutoCheckout]` 日志。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/auto-checkout-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文) · [PolyForm Noncommercial 1.0.0 许可](LICENSE)
