# Smart Delivery images / 配送随心图片

[English](#english) · [中文](#中文)

## English

This folder holds this Mod's in-game screenshots and promotional artwork, following the Old Market Simulator Mods folder layout.

### Cover artwork

[cover.png](cover.png) is the AI-generated cover used on the [Nexus Mods page](https://www.nexusmods.com/mods/4?game_id=10352).

### In-game screenshots

Both screenshots show the Smart Delivery selector in the English game UI.

| Image | Size | Shows |
| --- | --- | --- |
| [delivery-settings-gameplay.png](delivery-settings-gameplay.png) | 1231 × 1228 | Automatic Smart Order settings with automatic ordering enabled and **Premium delivery** selected |
| [delivery-selector-gameplay.png](delivery-selector-gameplay.png) | 1080 × 327 | Expanded **Delivery method** list with **Free service**, **Budget delivery** and highlighted **Premium delivery** |

### Adding images

| Filename | Content |
| --- | --- |
| `cover.png` | Mod cover for the README or a Mod listing |
| `<scene>-gameplay.png` | In-game screenshot, for example `delivery-selector-gameplay.png` |
| `<scene>-promo.png` | Additional promotional artwork |

- Use PNG, JPG or WebP, with lowercase filenames and hyphens.
- Add the image file before embedding it. Put the cover below the README title and screenshots next to the matching usage text, in both languages.
- For each new screenshot, note the date, Mod/game/UE4SS versions, host or guest role and what it shows. Label generated or edited artwork as such.
- Keep extracted game assets and reverse-engineering material in the ignored `work/` folder.

These images are repository documentation and are not included in the Mod ZIP. See the [shared image guidance](../../DEVELOPMENT.md#mod-images) for links that also work from an extracted package. Repository-only README example (paths relative to this Mod's README):

```markdown
![Smart Delivery cover artwork](assets/cover.png)
![Smart Delivery in-game screenshot](assets/delivery-selector-gameplay.png)
```

## 中文

此目录存放本 Mod 的实机截图和宣传图，沿用菜市场模拟器 Mods 的目录结构。

### 宣传封面

[cover.png](cover.png) 是 [Nexus Mods 页面](https://www.nexusmods.com/mods/4?game_id=10352)使用的 AI 宣传封面。

### 实机截图

两张图均为英语界面中的配送随心选择框。

| 图片 | 尺寸 | 画面内容 |
| --- | --- | --- |
| [delivery-settings-gameplay.png](delivery-settings-gameplay.png) | 1231 × 1228 | 自动智能订购设置，已勾选自动订购，配送方式为 **Premium delivery（高级配送）** |
| [delivery-selector-gameplay.png](delivery-selector-gameplay.png) | 1080 × 327 | **Delivery method（配送方式）** 展开列表，含免费服务、经济型配送及高亮的高级配送 |

### 添加图片

| 文件名 | 内容 |
| --- | --- |
| `cover.png` | README 或 Mod 页面使用的宣传封面 |
| `<scene>-gameplay.png` | 实机截图，例如 `delivery-selector-gameplay.png` |
| `<scene>-promo.png` | 其他宣传图 |

- 使用 PNG、JPG 或 WebP，文件名用小写英文和连字符。
- 先放入图片文件，再添加引用。封面放在 README 标题下，截图放在中英文对应的使用说明旁。
- 每张新截图记下拍摄日期、Mod／游戏／UE4SS 版本、房主或客机身份及画面内容；生成或编辑过的宣传图需注明。
- 提取的游戏资源和反编译资料放在被忽略的 `work/` 文件夹。

图片用于仓库文档，不放进 Mod ZIP。解压后的说明如何引用图片，见[公共图片说明](../../DEVELOPMENT.md#mod-图片)。仅在仓库中使用的 README 示例（路径相对于本 Mod 的 README）：

```markdown
![配送随心宣传封面](assets/cover.png)
![配送随心实机截图](assets/delivery-selector-gameplay.png)
```
