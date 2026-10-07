# First to Serve / 出餐有序

[![First to Serve / 出餐有序 — AI-generated cover / AI 宣传封面](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/first-to-serve-mod/assets/cover.png?raw=1)](https://www.nexusmods.com/mods/6?game_id=10352)

[English](#english) · [中文](#中文)

## English

Hold the interaction key at a kitchen pass or drink output area to collect the earliest-made ready items with a tray or food trolley.

**Version: 0.1.7.** Single player, multiplayer host or guest. Install it on each player's computer that wants to use the hold action; other players do not need it.

### How to use

1. Equip a tray, or take hold of a **food trolley** so that you are pushing it. Keep at least one slot available for the type of item you want to collect.
2. Walk within the game's normal pickup distance. Aim at the kitchen pass's pickup area, the drink output surface, or a ready dish or full finished drink belonging to that source. Nearby furniture and a cup still at its preparation equipment do not start the action.
3. Hold the interaction control shown by the game. The default mouse control is the left button; keyboard/controller remapping follows the game. When a normal pickup hint and a suitable item are available, the Mod adds **Hold: take oldest first** in the game's language.
4. Keep holding to collect items one at a time. The first item is the oldest eligible item at that source, even if the crosshair points at a newer one. Each pickup must complete before the next request is sent.
5. Release when you have enough, then carry and serve the items using the game's normal controls. Unloading, putting down the tray/trolley and serving customers remain normal game actions; this Mod automates pickup only.

There is no separate settings panel or Mod hotkey. Short taps keep the game's normal action. With a tray or held food trolley at a supported source, a long hold performs pickup in place of that source's interaction wheel.

### Which items are collected

Items are ordered by their original creation time, from oldest to newest. Customer order time, position on the counter and food quality do not determine priority. The Mod keeps the game's capacity and interaction distance and lets the game choose the destination slot.

| Situation | Pickup behavior |
| --- | --- |
| Kitchen pass or a ready dish at that source | Collects eligible cooked dishes on your current floor and within reach. |
| Drink output surface or a full finished drink there | Collects eligible drinks from that output area's own slots. It does not switch to another drink area during the hold. |
| Dirty, already served, consumed, being picked up or carried item; unfinished drink | Leaves the item alone. Items on other floors or outside normal pickup range are also excluded. |
| Tray or food trolley with a drink-only free slot | Drinks can use it; food needs a normal free slot. |
| Food trolley with a stack of dirty plates | Gaps in that stack do not count as space for ready food or drinks; the stack slot must be completely empty. |
| Tower burger on a food trolley | Requires a free top slot. A newer eligible dish may be taken first if the older burger cannot fit. |
| Parked food trolley, storage cart or no equipped tray | Does not activate the hold action. You must be holding the supported carrier yourself. |

### Stop and start another pickup

You can pan across the same output area without aiming at each item. After the aimed item is taken, a small amount of camera/player movement is tolerated so pickup can continue over its empty spot. Looking away, walking away or aiming at a different eligible source cancels the current hold.

Releasing the interaction control, changing or putting down the carrier, opening a menu, interaction wheel or multiplayer chat, entering placement mode, or pausing also ends the pickup. Already collected items stay on the carrier.

When all suitable slots fill, pickup stops. **Release and hold again** after freeing space, returning to the source or changing carriers; simply keeping the button down does not restart a canceled/full pickup. An empty output area cannot start a new hold. If a pickup is not confirmed within two seconds, that hold stops as well; release, check the carrier and aim, then try again.

### Multiplayer

The same controls work for the host and guests. Install the Mod on each computer whose player wants the hold action; the host does not need it just to allow a guest to use it. Each installation controls only its own player's tray or trolley. Pickup still goes through the game's normal multiplayer interaction, so an item another player takes or a delayed server response can interrupt the sequence.

### In-game screenshots

Tray pickup at the kitchen pass, shown in a 4.48-second gameplay recording.

![Gameplay animation of tray pickup at the kitchen pass](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/first-to-serve-mod/assets/kitchen-pass-gameplay.gif?raw=1)

[Open animation (GIF, 5.13 MiB)](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/first-to-serve-mod/assets/kitchen-pass-gameplay.gif?raw=1)

With a tray at the kitchen pass, the hold hint appears above **Take the dish**.

![Tray at the kitchen pass showing Hold: take oldest first and Take the dish](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/first-to-serve-mod/assets/kitchen-pass-gameplay.png?raw=1)

With a tray at the drink output area, the same hold hint appears above **Take drinks**.

![Tray at the drink output area showing Hold: take oldest first and Take drinks](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/first-to-serve-mod/assets/drink-output-gameplay.png?raw=1)

### Requirements

**Game support: through Steam Build 25759268 / 1.0.2.44eb.** The maintainer confirmed in-game testing passed on 2026-10-07; see the [current validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/releases/validation.md#english). The 2026-09-26 multiplayer confirmation remains historical; a multiplayer retest on the new build was not separately reported.

Windows x64 Parisian Bistro Simulator and **UE4SS experimental**. The checked loader build is `v3.0.1-1140-gf58e8f84`; stable UE4SS 3.0.1 is not supported. Other loader builds have not been verified. UE4SS is installed separately.

### Download

Choose **one** download source; both provide the same Mod:

- **GitHub (no account needed):** open [First to Serve 0.1.7](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/first-to-serve-v0.1.7), scroll to **Assets**, expand it if needed and click **FirstToServe-0.1.7.zip**. `SHA256SUMS.txt` is an optional checksum file, not something to install. Do not choose **Source code**.
- **Nexus:** open the [Mod page](https://www.nexusmods.com/parisianbistrosimulator/mods/6), sign in or register a free account, select **Files → Main files → Manual download** for version **0.1.7**. Continue through the requirements notice if shown, select **Slow download** for a free account and wait for the ZIP. Keep the ZIP in your **Downloads** folder until the extraction step below.

### Install

These instructions start with only the Windows game installed. **Manual installation is free and does not require Vortex or a Nexus Premium subscription.** A web browser and Windows File Explorer are enough; Windows can extract ZIP files without WinRAR or 7-Zip. You do not need Git, Python, Visual Studio or Unreal Engine.

UE4SS is the **mod loader**: it starts the Mod when the game starts. Install it once for this game, then add any of the seven Mods to its `Mods` folder. Vortex is an optional **mod manager**, which copies and removes Mod files for you; it does not replace UE4SS.

1. **Exit the game completely.** In Steam, open **Library**, right-click **Parisian Bistro Simulator**, then choose **Manage → Browse local files**. The File Explorer window that opens is your game folder. Its name may be **Parisian Brasserie Simulator**. Do not use Documents or the save folder.
2. **Open the installation destination.** In that window, double-click **BrasserieSimulator**, then **Binaries**, then **Win64**. You should see **BrasserieSimulator-Win64-Shipping.exe** (Windows may hide `.exe`). Keep this window open. This is where the loader goes; do not put the loader beside the top-level `BrasserieSimulator.exe`.
3. **Download the loader.** Use [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip), the basic experimental build used as this project's reference. If the direct link fails, open [UE4SS experimental releases](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental), expand **Assets / Show all assets** and find that exact filename. Do not choose `zDEV`, `Source code` or the old stable `UE4SS_v3.0.1.zip`. Other experimental builds have not been verified for these Mods.
4. **Extract the loader ZIP.** In File Explorer's **Downloads** folder, right-click the downloaded ZIP → **Extract All… → Extract**. Open the extracted folder. Inside it, select **dwmapi.dll** and the entire **ue4ss** folder, right-click → **Copy**; return to the game's **Win64** window, right-click empty space → **Paste**. Copy both items themselves, not the outer folder named after the ZIP. There is no UE4SS installer to run. If you already have UE4SS installed, back up its folder and settings before replacing anything; keep your existing Mods.
5. **Check the loader location.** In **Win64**, `dwmapi.dll` must sit beside `BrasserieSimulator-Win64-Shipping.exe`. Open **ue4ss**: it must contain **UE4SS.dll**, **UE4SS-settings.ini** and **Mods**. If these are missing, repeat the extraction/copy step; an empty folder named `Mods` alone does not install the loader.
6. **Extract the Mod ZIP** downloaded above: right-click it → **Extract All… → Extract**. Open the extracted folder until you can see **FirstToServe**, the folder that contains **Scripts** and **enabled.txt**. Windows may show `enabled` without `.txt`; that is normal.
7. **Copy the whole FirstToServe folder.** Right-click it → **Copy**. In the game window, open **Win64 → ue4ss → Mods**, right-click empty space → **Paste**. Do not copy only `main.lua`, and do not place the ZIP itself in `Mods`.
8. **Check the result.** Open **Mods → FirstToServe → Scripts**: **main.lua** must be there. Go back once to **FirstToServe**: **enabled.txt** must be there beside **Scripts**. An extra `FirstToServe/FirstToServe` layer is incorrect. Leave `enabled.txt` as supplied, even if it is empty; it enables the Mod. Do not replace the loader's `mods.txt`.
9. **Start the game normally through Steam** and follow **How to use** above. Some Mods run in the background and have no startup message. Check the single-player/host/guest requirement at the top of this guide; the host is the player who opens the multiplayer restaurant for others to join.

The final entry point is `BrasserieSimulator/Binaries/Win64/ue4ss/Mods/FirstToServe/Scripts/main.lua`, starting from the Steam game folder. If the feature does not work, close the game, recheck the two folder layouts above, then open `Win64/ue4ss/UE4SS.log` with Notepad and look for a recent timestamp or an error. See [Help](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) before reinstalling.

**Using Vortex instead:** follow the [Vortex setup guide](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#english) to install Vortex, this game's extension and UE4SS first. Then import the original Mod ZIP, install, enable and deploy it. Use one installation method for this Mod. **The [collection](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz) currently requires an active Nexus Premium membership for one-click installation.** A free Nexus account or GitHub download can still be used for individual Mods; GitHub downloads need no account.

If you used the earlier **Oldest First** package, remove its old `Mods/OldestFirst` folder with the game closed before installing this Mod. Do not run both copies.

### Update or remove

**Update:** close the game, download and extract the new Mod ZIP, then copy its complete `FirstToServe` folder into the same `Mods` folder and replace matching files. Start the game again.

**Remove:** close the game and delete only `Mods/FirstToServe`. Leave UE4SS and other Mods in place. Removing the Mod restores the normal hold interaction. Items already picked up stay where the game placed them.

Optional: [reload scripts without restarting](DEVELOPMENT.md#manual-script-reload). This is not required for normal installation or updates.

### Languages and help

The hold hint follows the game language and its keyboard/controller icons follow your current controls. No language setting or language pack is needed. Technical logs remain English.

Game languages: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese.

The hold hint appears with the normal pickup hint when an eligible item and a suitable free slot are available. A drink surface without the game's normal pickup hint can still accept the hold action. If no pickup starts, check that you are holding the tray/trolley, that a compatible slot is empty, and that the item is ready, on your floor and within reach; try aiming directly at it. If pickup stops while there is room, release and hold again. Include relevant `[FirstToServe]` lines from `UE4SS.log`, your controls and host/guest role with a problem report.

In-game and multiplayer testing passed as reported by the maintainer on 2026-09-26; the [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/releases/validation.md#english) describes its scope.

[Screenshots and artwork](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/first-to-serve-mod/assets/README.md#english) · [Changes](CHANGELOG.md) · [Help and feedback](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#english) · [MIT License](LICENSE)

## 中文

持托盘或推餐车，对准厨房出餐口或饮料出品台长按交互键，优先连续拿取最早做好的成品。

**版本：0.1.7。** 单人、联机房主和客机均可使用。想使用连续拿取的玩家在自己的电脑安装，其他玩家无需安装。

### 怎么使用

1. 装备托盘，或握住**送餐餐车**进入推行状态。为要拿取的餐品保留至少一个适用空位。
2. 走进游戏正常拿取距离，对准厨房出餐口的拿取区域、饮料出品台面，或属于该来源的可取菜品、满杯成品饮料。附近家具和仍放在制作设备上的杯子不会启动功能。
3. 长按游戏显示的交互键。鼠标默认为左键；键鼠和手柄跟随游戏改键。有原版拿取提示及适用成品时，Mod 会按游戏语言显示长按优先拿取最早成品的提示，英文为 **Hold: take oldest first**。
4. 持续按住，逐份拿取。即使准星对着较新的成品，也会从当前来源中最早做好的适用成品开始；上一份拿取完成后才会继续请求下一份。
5. 拿够后松键，再按游戏原有操作搬运并给顾客上菜。卸下餐品、放下托盘／餐车及送餐仍使用原版操作；本 Mod 自动化的是取餐步骤。

无需单独设置，也没有新增快捷键。短按保留原版操作；持托盘或推餐车对准支持的来源时，长按会连续拿取，替代该处的交互轮盘。

### 会拿取哪些餐品

按成品原始制作时间从早到晚选择，顾客下单时间、台面位置和餐品品质不参与优先级排序。容量和交互距离沿用游戏规则，最终放入哪个槽位由游戏决定。

| 场景 | 拿取规则 |
| --- | --- |
| 厨房出餐口，或该来源中的可取菜品 | 拿取当前楼层、正常距离内的适用熟食。 |
| 饮料出品台面，或台上满杯成品饮料 | 只从该出品区自己的槽位取饮料，本次长按不会自动转到另一处饮料台。 |
| 脏餐具、已上桌、正在食用／拿取或已经搬走的餐品，以及未完成饮料 | 不处理；其他楼层或超出正常距离的餐品也不会拿取。 |
| 托盘或餐车只剩饮料专用空位 | 可以放饮料；食物需要普通空位。 |
| 餐车上已有脏盘堆叠 | 堆叠中的空隙不算成品空位，整个堆叠位完全空出后才能放食物或饮料。 |
| 餐车拿取高层汉堡 | 需要顶层空位；较早的汉堡放不下时，可以先取较新的其他适用餐品。 |
| 停放的送餐餐车、搬货推车，或未装备托盘 | 不会启动连续拿取，必须由自己持有支持的托盘或餐车。 |

### 停止与再次拿取

准星可在同一出品区域内移动，无需逐份瞄准。拿走准星下的餐品后，允许少量视角和位置变化，使准星留在原来空位时仍能继续；转开视线、走离或瞄准另一处适用来源会取消本次长按。

松开交互键、更换或放下托盘／餐车、打开菜单／交互轮盘／联机聊天、进入摆放模式或暂停，都会结束拿取。已经收集的餐品保留在托盘或餐车上。

适用空位全部装满后停止。腾出空位、返回出品区或更换托盘／餐车后，须**松键再重新长按**；一直按住不会重新启动已取消或已装满的拿取。空出品区不能开始新的一次长按。若某份拿取两秒内未获确认，本次长按也会停止；松键、检查空位和瞄准位置后再试。

### 联机使用

房主和客机使用相同操作。想使用长按功能的玩家在自己的电脑安装即可，客机使用时不要求房主也安装。每份安装只控制该玩家自己的托盘或餐车；拿取仍走游戏正常联机交互，因此其他玩家先拿走餐品或服务器响应延迟都可能中断连续拿取。

### 实机截图

持托盘在厨房出餐口取餐的实机演示，时长约 4.48 秒。

![实机动图：持托盘在厨房出餐口取餐](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/first-to-serve-mod/assets/kitchen-pass-gameplay.gif?raw=1)

[打开动图（GIF，5.13 MiB）](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/first-to-serve-mod/assets/kitchen-pass-gameplay.gif?raw=1)

持托盘对准厨房出餐口，**Take the dish（拿取菜品）** 上方显示长按优先拿取最早成品的提示。

![实机画面：持托盘对准出餐口，显示长按优先拿取最早成品及拿取菜品提示](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/first-to-serve-mod/assets/kitchen-pass-gameplay.png?raw=1)

持托盘对准饮料出品台，**Take drinks（拿取饮料）** 上方显示同样的长按提示。

![实机画面：持托盘对准饮料出品台，显示长按优先拿取最早成品及拿取饮料提示](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/first-to-serve-mod/assets/drink-output-gameplay.png?raw=1)

### 使用要求

**游戏支持至 Steam Build 25759268 / 1.0.2.44eb。** 维护者于 2026-10-07 确认新版实机测试通过，见[当前验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/releases/validation.md#中文)。2026-09-26 的联机确认保留为历史记录，本次未单独反馈新版联机重测结果。

Windows x64 版 Parisian Bistro Simulator，以及 **UE4SS experimental**。已核对的加载器版本为 `v3.0.1-1140-gf58e8f84`，不支持旧稳定版 UE4SS 3.0.1；其他加载器版本尚未验证。UE4SS 需单独安装。

### 下载

以下来源**二选一**即可，提供的是同一个 Mod：

- **GitHub（无需账号）：**打开 [出餐有序 0.1.7](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases/tag/first-to-serve-v0.1.7)，向下找到并展开 **Assets（附件）**，点击 **FirstToServe-0.1.7.zip**。`SHA256SUMS.txt` 是可选的校验文件，无需安装；不要下载 **Source code（源码）**。
- **Nexus：**打开 [Mod 页面](https://www.nexusmods.com/parisianbistrosimulator/mods/6)，登录或注册免费账号，在 **Files（文件）→ Main files（主要文件）** 找到 **0.1.7**，点击 **Manual download（手动下载）**。如出现前置要求提示，继续到下载页；免费账号选择 **Slow download（慢速下载）**，等待 ZIP 下载完成。先把 ZIP 保存在**下载**文件夹，下面再解压。

### 安装

以下步骤从电脑上只安装了 Windows 版游戏开始。**手动安装免费，不需要 Vortex，也不需要 Nexus Premium 会员。** 用浏览器和 Windows 文件资源管理器即可操作；Windows 自带 ZIP 解压功能，无需安装 WinRAR 或 7-Zip，也不需要 Git、Python、Visual Studio 或虚幻引擎。

UE4SS 是**加载器**，作用是在启动游戏时运行 Mod。每个游戏安装目录只需装一次，之后把所需 Mod 加入它的 `Mods` 文件夹即可。Vortex 是可选的 **Mod 管理器**，负责复制和移除 Mod 文件，不能代替 UE4SS。

1. **完全退出游戏。** 在 Steam 打开**库**，右键 **Parisian Bistro Simulator（法式小馆儿模拟器）→ 管理 → 浏览本地文件**。弹出的文件资源管理器窗口就是游戏目录，文件夹名可能是 **Parisian Brasserie Simulator**。不是“文档”或存档文件夹。
2. **打开安装位置。** 在该窗口依次双击 **BrasserieSimulator → Binaries → Win64**，应该能看到 **BrasserieSimulator-Win64-Shipping.exe**（Windows 可能隐藏 `.exe` 后缀）。保留此窗口，加载器就放在这里；不要放在最外层 `BrasserieSimulator.exe` 旁边。
3. **下载加载器。** 点击 [UE4SS_v3.0.1-1140-gf58e8f84.zip](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1140-gf58e8f84.zip)，这是本项目核对过的 experimental 基础包。若直链失效，打开 [UE4SS experimental 发布页](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental)，展开 **Assets / Show all assets（附件／显示全部附件）**，找到这个完整文件名。不要下载 `zDEV`、`Source code`，也不要使用旧稳定版 `UE4SS_v3.0.1.zip`。其他 experimental 构建尚未核验。
4. **解压并放入加载器。** 在文件资源管理器的**下载**文件夹里，右键刚下载的 ZIP → **全部解压缩 → 提取**。打开解压后的文件夹，选中里面的 **dwmapi.dll** 和整个 **ue4ss** 文件夹，右键**复制**；回到游戏的 **Win64** 窗口，在空白处右键**粘贴**。复制这两个项目本身，不要把以压缩包命名的外层文件夹一起套进去。UE4SS 没有需要双击运行的安装程序。已经安装过加载器时，替换前备份其文件夹和设置，并保留现有 Mod。
5. **检查加载器位置。** **Win64** 中的 `dwmapi.dll` 应与 `BrasserieSimulator-Win64-Shipping.exe` 并排。打开 **ue4ss**，里面应有 **UE4SS.dll**、**UE4SS-settings.ini** 和 **Mods**。缺少这些内容时回到上一步重新解压、复制；只新建一个空的 `Mods` 文件夹不能装好加载器。
6. **解压上面下载的 Mod ZIP。** 右键 ZIP → **全部解压缩 → 提取**。打开解压后的文件夹，找到 **FirstToServe** 文件夹；它里面应有 **Scripts** 和 **enabled.txt**。Windows 可能只显示 `enabled` 而隐藏 `.txt`，属于正常情况。
7. **复制整个 FirstToServe 文件夹。** 右键它 → **复制**。在游戏窗口打开 **Win64 → ue4ss → Mods**，在空白处右键**粘贴**。不要只复制 `main.lua`，也不要把 ZIP 本身放进去。
8. **检查安装结果。** 依次打开 **Mods → FirstToServe → Scripts**，应能看到 **main.lua**；返回一层到 **FirstToServe**，应能看到与 **Scripts** 并排的 **enabled.txt**。不要多套成 `FirstToServe/FirstToServe`。即使 `enabled.txt` 是空文件也应原样保留，它用于启用 Mod；不要替换加载器的 `mods.txt`。
9. **从 Steam 正常启动游戏**，按上方“怎么使用”操作。有的 Mod 在后台工作，没有启动提示。先核对本说明开头的单人／房主／客机要求；房主指开启联机餐厅、让其他人加入的玩家。

从 Steam 打开的游戏目录算起，最终脚本位置是 `BrasserieSimulator/Binaries/Win64/ue4ss/Mods/FirstToServe/Scripts/main.lua`。功能未生效时，先退出游戏、核对上述加载器和 Mod 两处目录，再用记事本打开 `Win64/ue4ss/UE4SS.log`，查看有没有本次运行的时间或错误。重装前可查看[帮助](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文)。

**如果选择 Vortex：** 先按 [Vortex 安装说明](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/vortex-extension/README.md#中文)装好 Vortex、本游戏扩展和 UE4SS，再导入原始 Mod ZIP，安装、启用并部署。同一个 Mod 只使用一种安装方式。**目前通过 [Nexus 合集](https://www.nexusmods.com/games/parisianbistrosimulator/collections/fymmvz)一键安装需要有效的 Nexus Premium 会员。** 免费 Nexus 账号仍可逐个下载 Mod；GitHub 下载无需账号。

若安装过旧名 **Oldest First** 的开发包，请先关闭游戏并删除旧的 `Mods/OldestFirst` 文件夹，避免同时运行两份。

### 更新与卸载

**更新：** 关闭游戏，下载并解压新版 Mod ZIP，把完整的 `FirstToServe` 文件夹复制到原来的 `Mods` 目录并覆盖同名文件，再启动游戏。

**卸载：** 关闭游戏，只删除 `Mods/FirstToServe`，保留 UE4SS 和其他 Mod。卸载后恢复原版长按交互，已拿取的餐品保持游戏中的现有位置。

可选操作：[不重启游戏重新加载脚本](DEVELOPMENT.md#手动脚本重载)。正常安装和更新不需要此操作。

### 语言与帮助

长按提示跟随游戏语言，键鼠或手柄图标跟随当前操作设置，无需额外语言设置或语言包。技术日志保持英文。

游戏语言包括英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语和巴西葡萄牙语。

有可取成品及合适空位时，长按提示与原版拿取提示一起显示。饮料台面没有原版拿取提示时仍可长按。没有开始拿取时，检查是否正持有托盘／餐车、是否有适用空位，以及餐品是否已完成、位于当前楼层且在正常距离内；也可直接瞄准餐品再试。仍有空位却停止时，请松键后重新长按。反馈时附上 `UE4SS.log` 中相关的 `[FirstToServe]` 日志、操作设备及房主或客机身份。

维护者于 2026-09-26 确认实机及联机测试全部通过并授权正式发布，具体范围见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/first-to-serve-v0.1.7/releases/validation.md#中文)。

[实机图与宣传图](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/first-to-serve-mod/assets/README.md#中文) · [版本变化](CHANGELOG.md) · [问题反馈](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/SUPPORT.md#中文) · [MIT 许可证](LICENSE)
