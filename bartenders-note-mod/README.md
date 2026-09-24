# Bartender's Note

[English](#english) · [中文](#中文)

## English

See the drinks you have claimed and still need to make, directly below the restaurant name. Repeated orders are grouped by drink type, for example `Espresso x 10 · Lemonade x 3`.

**Current source: 0.1.1-dev.** The two-line layout and expanded localization await in-game acceptance. Version 0.1.0 was confirmed in-game on 2026-09-24; that confirmation does not cover these new changes.

### How it works

Claim drink orders on the tablet, then close it to see your list. Only the local player's claimed orders count. Drinks waiting to be made or currently being made are included; finished drinks are removed without waiting for delivery. Canceling a claim or order updates the count. An empty list is hidden.

The display uses the restaurant name bar's native background, font and text color. Entries wrap as whole `name x quantity` items across at most two lines, keeping the original font size and leaving space inside the faded ends of the bar. Overflow shows a translated “... + N more”; **N counts hidden drink types, not cups**. An overlong name joins that count instead of being split or cut off.

The list follows changes in the window size and game language, and never takes keyboard, mouse or controller focus. It does not modify orders, saves or the existing restaurant name bar.

### Languages

Supports the game's 14 languages: English, French, Simplified Chinese, Italian, Spanish, German, Russian, Japanese, Korean, Traditional Chinese, Turkish, Polish, Portuguese and Brazilian Portuguese. No separate setting or language pack is needed.

Drink names come from the game's native translation lookup. If a name is unavailable, the Mod first uses the game's translated “Drinks” category plus `#ID`; if that also fails, it uses its own translated generic drink label and ID. Different drinks with identical translated names remain separate types. The overflow message and final fallback label have Mod-owned translations; unsupported or unreadable languages use English. Technical loader/error logs remain English.

### Install

For Windows Parisian Bistro Simulator with **UE4SS experimental**. The local reference baseline is Steam Build 25393699 / ProjectVersion 1.0.0.44eb, Unreal Engine 5.4. The checked loader API is `v3.0.1-1140-gf58e8f84`, requiring `LoopInGameThreadWithDelay` and `ExecuteInGameThreadWithDelay`; this is an experimental build, not stable UE4SS 3.0.1.

1. Close the game and install the required experimental loader using the [UE4SS installation guide](https://docs.ue4ss.com/dev/installation-guide.html). Keep that release's own directory structure and default settings.
2. Extract the ZIP's `BartendersNote` folder into the loader's `Mods` directory. A common location is `BrasserieSimulator/Binaries/Win64/ue4ss/Mods/BartendersNote`; use your actual loader location.
3. Check that `BartendersNote/Scripts/main.lua` and `BartendersNote/enabled.txt` exist. Do not replace the whole `mods.txt` or add a duplicate enable entry.
4. Start the game, enter the restaurant and claim drink orders on the tablet.

The package includes neither UE4SS nor game assets. Building from source does not install anything. Restart the game after installing or updating.

### If the list is missing

It is hidden when you have no unfinished claimed drinks, the restaurant name bar is hidden, or you are outside the gameplay HUD. Very narrow windows may leave no room even for the overflow indicator; widening the window allows it to reappear.

The Mod refreshes after relevant events and checks the queue every 750 ms. It clears stale entries when a data source becomes unavailable, logs the reason under `[Bartender's Note]`, and reconnects when the source recovers. Missing required loader APIs disable the Mod with a log message. For an unexpected problem, record the Mod/game/loader versions, language, resolution, host/client role and relevant log excerpt.

### Update or remove

Close the game before replacing or removing the `BartendersNote` folder. No custom save data needs cleanup. Host/client isolation and live language changes remain part of the pending regression checklist.

[Changes](CHANGELOG.md) · [Build, implementation and validation](DEVELOPMENT.md#english)

## 中文

在餐厅名称下方显示自己认领且尚未制作完成的饮料，同类订单合并计数，例如：`浓缩咖啡 x 10 · 柠檬水 x 3`。

**当前源码：0.1.1-dev。** 两行布局与多语言扩展仍待实机验收。0.1.0 已于 2026-09-24 获得实机确认，该结论不覆盖这些新改动。

### 怎么使用

在平板认领饮料订单，关闭平板即可查看清单。只统计当前本地玩家认领的订单，待制作和制作中均计入；制作完成后移除，无需等到送达。取消认领或取消订单会更新数量，清单为空时隐藏。

显示栏沿用餐厅名称条的原生背景、字体与文字颜色。每个“饮料名 x 数量”整体换行，最多两行，保留原字号，并避开两端渐隐区域。超出部分显示本地化的“另有 N 种”提示；**N 表示隐藏的饮料种类数，不是杯数**。名称过长时也计入隐藏种类，不截断名称或拆开数量。

清单会随窗口尺寸和游戏语言重新排版，不占用鼠标、键盘或手柄焦点，也不修改订单、存档或原有餐厅名称条。

### 语言

支持游戏中的英语、法语、简体中文、意大利语、西班牙语、德语、俄语、日语、韩语、繁体中文、土耳其语、波兰语、葡萄牙语与巴西葡萄牙语，无需额外设置或语言包。

饮料名通过游戏原生翻译接口读取。名称不可用时，先使用游戏原生的“饮料”分类翻译加 `#编号`；该查询也失败时，使用 Mod 自有的本地化通用饮料标签和编号。不同饮料即使译名相同，仍分别统计。隐藏种类提示与最终后备标签由 Mod 提供翻译；语言不支持或不可读时回退英语。加载器及异常等技术日志保留英文。

### 安装

适用于 Windows 版 Parisian Bistro Simulator，需要 **UE4SS experimental**。本机参考基线为 Steam Build 25393699 / ProjectVersion 1.0.0.44eb，Unreal Engine 5.4。核对的加载器 API 为 `v3.0.1-1140-gf58e8f84`，需要 `LoopInGameThreadWithDelay` 和 `ExecuteInGameThreadWithDelay`；这是实验版，不是稳定版 UE4SS 3.0.1。

1. 关闭游戏，按 [UE4SS 安装说明](https://docs.ue4ss.com/dev/installation-guide.html)安装所需实验版，使用该版本自己的目录结构与默认设置。
2. 将 ZIP 内的 `BartendersNote` 文件夹放到加载器的 `Mods` 目录。常见位置为 `BrasserieSimulator/Binaries/Win64/ue4ss/Mods/BartendersNote`，以实际加载器位置为准。
3. 确认存在 `BartendersNote/Scripts/main.lua` 和 `BartendersNote/enabled.txt`。无需替换整个 `mods.txt`，也不要添加重复启用项。
4. 启动游戏、进入餐厅，在平板中认领饮料订单。

包内不含 UE4SS 或游戏资产。从源码构建不会自动安装；安装或更新后须重新启动游戏。

### 清单没有出现时

没有未完成的已认领饮料、餐厅名称条隐藏或不在游戏 HUD 时，清单会隐藏。极窄窗口可能连隐藏种类提示也容纳不下，加宽窗口后会重新显示。

Mod 在相关事件后刷新，并每 750 毫秒核对队列。数据源不可用时清空旧条目，在 `[Bartender's Note]` 日志中记录原因，恢复后自动重连。缺少所需加载器 API 时会停用并记录提示。反馈异常时请提供 Mod、游戏和加载器版本、语言、分辨率、房主或客户端身份及相关日志片段。

### 更新与卸载

关闭游戏后替换或删除 `BartendersNote` 文件夹，无需清理自定义存档数据。房主与客户端各自显示、运行中语言切换仍列在后续回归清单中。

[版本变化](CHANGELOG.md) · [构建、实现与验收](DEVELOPMENT.md#中文)
