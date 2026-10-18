# Scan to Order images / 扫码点餐图片

[English](#english) · [中文](#中文)

## English

This folder holds the Mod's in-game screenshots and promotional artwork, following the Old Market Simulator Mods folder layout.

### Cover artwork

[cover.png](cover.png) is the AI-generated cover used on the [Nexus Mods page](https://www.nexusmods.com/mods/7?game_id=10352).

### In-game screenshot

| Image | Size | What it shows |
| --- | --- | --- |
| [automatic-orders-gameplay.png](automatic-orders-gameplay.png) | 650 × 419 | Seated customers with Croque Monsieur, Green Tea, Pear Liqueur and Espresso order icons and green check marks (English UI) |

### Adding images

| Filename | Content |
| --- | --- |
| `cover.png` | Mod cover artwork for the README or a Mod listing |
| `<scene>-gameplay.png` | In-game screenshot, for example `automatic-orders-gameplay.png` |
| `<scene>-promo.png` | Additional promotional artwork |

- Use PNG, JPG or WebP, with lowercase hyphenated filenames.
- Add an image embed only after the file exists. Put the cover below the README title and gameplay images next to the matching usage text, in both languages.
- For each new screenshot, note here its date, Mod/game/UE4SS versions, host or guest role and what it shows. Label generated or edited artwork as such.
- Keep extracted game assets and reverse-engineering material in ignored `work/`.

Images are repository documentation and are not included in Mod ZIPs. See the [shared image guidance](../../DEVELOPMENT.md#mod-images) for links that also work from an extracted package. Repository-only README example (paths relative to this Mod's README):

```markdown
![Scan to Order cover artwork](assets/cover.png)
![Scan to Order in-game screenshot](assets/automatic-orders-gameplay.png)
```

## 中文

此目录存放本 Mod 的实机截图和宣传图，沿用菜市场模拟器 Mods 的目录结构。

### 宣传封面

[cover.png](cover.png) 是 [Nexus Mods 页面](https://www.nexusmods.com/mods/7?game_id=10352)使用的 AI 宣传封面。

### 实机截图

| 图片 | 尺寸 | 画面内容 |
| --- | --- | --- |
| [automatic-orders-gameplay.png](automatic-orders-gameplay.png) | 650 × 419 | 已入座顾客旁显示 Croque Monsieur、Green Tea、Pear Liqueur、Espresso 订单图标与绿色勾选标记（英语界面） |

### 添加图片

| 文件名 | 内容 |
| --- | --- |
| `cover.png` | README 或 Mod 页面使用的宣传封面 |
| `<scene>-gameplay.png` | 实机截图，例如 `automatic-orders-gameplay.png` |
| `<scene>-promo.png` | 其他宣传图 |

- 使用 PNG、JPG 或 WebP，文件名用小写英文和连字符。
- 图片文件加入后再添加引用：封面放在 README 标题下，实机图放在对应的使用说明旁，中英文都要加。
- 每张新截图在本文件中注明拍摄日期、Mod／游戏／UE4SS 版本、房主或客机身份及画面内容；生成或编辑过的宣传图要注明。
- 提取的游戏资源和反编译资料放在被忽略的 `work/`。

图片用于仓库文档，不进入 Mod ZIP。解压后的说明如何引用图片，见[公共图片说明](../../DEVELOPMENT.md#mod-图片)。仅在仓库中使用的 README 示例（路径相对于本 Mod 的 README）：

```markdown
![扫码点餐宣传封面](assets/cover.png)
![扫码点餐实机截图](assets/automatic-orders-gameplay.png)
```
