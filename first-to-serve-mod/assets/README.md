# First to Serve images / 出餐有序图片

[English](#english) · [中文](#中文)

## English

This folder holds the Mod's in-game screenshots and promotional artwork, following the Old Market Simulator Mods folder layout.

### Cover artwork

[cover.png](cover.png) is AI-generated promotional artwork used on the [Nexus Mods page](https://www.nexusmods.com/mods/6?game_id=10352), created on 2026-09-26.

### In-game screenshots

Provided by the maintainer on 2026-09-26. Both show the English UI with mouse-button hints while holding a tray.

| Image | Size | What it shows |
| --- | --- | --- |
| [kitchen-pass-gameplay.png](kitchen-pass-gameplay.png) | 832 × 474 | Tray at a kitchen pass, with **Hold: take oldest first** above **Take the dish** |
| [drink-output-gameplay.png](drink-output-gameplay.png) | 721 × 375 | Tray at a highlighted drink output area, with **Hold: take oldest first** above **Take drinks** |

### Gameplay animation

[kitchen-pass-gameplay.gif](kitchen-pass-gameplay.gif), provided by the maintainer on 2026-09-26: tray pickup at the kitchen pass with the English pickup hints. 960 × 600, 4.48 seconds, looping, 5.13 MiB.

### Adding images

| Filename | Content |
| --- | --- |
| `cover.png` | Mod cover artwork for the README or a Mod listing |
| `<scene>-gameplay.png` | In-game screenshot, for example `kitchen-pass-gameplay.png` |
| `<scene>-gameplay.gif` | Gameplay recording, for example `kitchen-pass-gameplay.gif` |
| `<scene>-promo.png` | Additional promotional artwork |

- Use PNG, JPG or WebP for still images and GIF for animations, with lowercase hyphenated filenames.
- Add an image embed only after the file exists. Put the cover below the README title and gameplay images next to the matching usage text in both languages.
- Note the date and versions for each new screenshot here, and label generated or edited artwork as such.
- Keep extracted game assets and reverse-engineering material in ignored `work/`.

Images stay in the repository and are not included in Mod ZIPs. For links that also work from an extracted package, see the [shared image guidance](../../DEVELOPMENT.md#mod-images). Repository-only README example (paths relative to this Mod's README):

```markdown
![First to Serve cover artwork](assets/cover.png)
![First to Serve at the kitchen pass](assets/kitchen-pass-gameplay.png)
```

## 中文

此目录存放本 Mod 的实机截图和宣传图，沿用菜市场模拟器 Mods 的目录约定。

### 宣传封面

[cover.png](cover.png) 是 [Nexus Mods 页面](https://www.nexusmods.com/mods/6?game_id=10352)使用的 AI 宣传图，制作于 2026-09-26。

### 实机截图

维护者于 2026-09-26 提供。两张图均为持托盘时的英语界面和鼠标按键提示。

| 图片 | 尺寸 | 画面内容 |
| --- | --- | --- |
| [kitchen-pass-gameplay.png](kitchen-pass-gameplay.png) | 832 × 474 | 持托盘对准厨房出餐口，**Take the dish** 上方显示 **Hold: take oldest first** |
| [drink-output-gameplay.png](drink-output-gameplay.png) | 721 × 375 | 持托盘对准高亮的饮料出品台，**Take drinks** 上方显示 **Hold: take oldest first** |

### 实机动图

[kitchen-pass-gameplay.gif](kitchen-pass-gameplay.gif)，维护者于 2026-09-26 提供：持托盘在厨房出餐口取餐，显示英语拿取提示。960 × 600，时长 4.48 秒，循环播放，5.13 MiB。

### 添加图片

| 文件名 | 内容 |
| --- | --- |
| `cover.png` | README 或 Mod 页面使用的宣传封面 |
| `<scene>-gameplay.png` | 实机截图，例如 `kitchen-pass-gameplay.png` |
| `<scene>-gameplay.gif` | 实机录制动图，例如 `kitchen-pass-gameplay.gif` |
| `<scene>-promo.png` | 其他宣传图 |

- 静态图片用 PNG、JPG 或 WebP，动图用 GIF；文件名使用小写英文和连字符。
- 图片加入后再添加引用：封面放在 README 标题下，实机图放在中英文对应的使用说明旁。
- 每张新截图在本文件记录拍摄日期和版本；生成或编辑过的宣传图需注明。
- 提取的游戏资源和反编译资料放在被忽略的 `work/`。

图片只保留在仓库中，不进入 Mod ZIP。解压后的说明如何引用图片，见[公共图片说明](../../DEVELOPMENT.md#mod-图片)。仅在仓库中使用的 README 示例（路径相对于本 Mod 的 README）：

```markdown
![出餐有序宣传封面](assets/cover.png)
![出餐有序在厨房出餐口的实机画面](assets/kitchen-pass-gameplay.png)
```
