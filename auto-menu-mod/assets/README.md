# Auto Menu images / 菜单巧配图片

[English](#english) · [中文](#中文)

## English

This folder holds the Mod's in-game screenshots and promotional artwork.

### Cover artwork

[cover.png](cover.png) is the AI-generated cover used on the [Nexus Mods page](https://www.nexusmods.com/mods/5?game_id=10352), created on 2026-09-26.

### In-game screenshots

Provided by the maintainer on 2026-09-26. Both show the English UI.

| Image | Size | What it shows |
| --- | --- | --- |
| [auto-compose-gameplay.png](auto-compose-gameplay.png) | 2534 × 1574 | Daily-menu page with the **Auto-compose** button beside **Print menu** and its tooltip visible |
| [menu-forecast-gameplay.png](menu-forecast-gameplay.png) | 2061 × 1048 | Menu forecast with **86% estimated adoption**, customer-profile compatibility, **68 menus available** and menu bonuses |

### Adding images

| Filename | Content |
| --- | --- |
| `cover.png` | Mod cover artwork for the README or a Mod listing |
| `<scene>-gameplay.png` | In-game screenshot, for example `auto-compose-gameplay.png` |
| `<scene>-promo.png` | Additional promotional artwork |

- Use PNG, JPG or WebP with lowercase, hyphenated filenames.
- Add an image embed only after the file exists. Put the cover below the README title and screenshots next to the matching usage text in both languages.
- For each new screenshot, note its date, Mod/game/UE4SS versions and host or guest role here. Mark generated or edited artwork as such.
- Keep extracted game assets in ignored `work/`.

These images stay outside Mod ZIPs. See the [shared image guidance](../../DEVELOPMENT.md#mod-images) for links that also work from an extracted package. Repository-only README example (paths relative to this Mod's README):

```markdown
![Auto Menu cover artwork](assets/cover.png)
![Auto Menu in-game screenshot](assets/auto-compose-gameplay.png)
```

## 中文

此目录存放本 Mod 的实机截图和宣传图。

### 宣传封面

[cover.png](cover.png) 是 [Nexus Mods 页面](https://www.nexusmods.com/mods/5?game_id=10352)使用的 AI 宣传封面，制作于 2026-09-26。

### 实机截图

维护者于 2026-09-26 提供，两张均为英语界面。

| 图片 | 尺寸 | 内容 |
| --- | --- | --- |
| [auto-compose-gameplay.png](auto-compose-gameplay.png) | 2534 × 1574 | 每日菜单页面中的 **Auto-compose（自动组合）** 按钮位于 **Print menu（打印菜单）** 旁，并显示悬浮说明 |
| [menu-forecast-gameplay.png](menu-forecast-gameplay.png) | 2061 × 1048 | 菜单预测显示 **86% 预计选择率**、顾客适配度、现有库存可提供的 **68 份菜单** 及菜单加成 |

### 添加图片

| 文件名 | 内容 |
| --- | --- |
| `cover.png` | README 或 Mod 页面使用的宣传封面 |
| `<scene>-gameplay.png` | 实机截图，例如 `auto-compose-gameplay.png` |
| `<scene>-promo.png` | 其他宣传图 |

- 使用 PNG、JPG 或 WebP，文件名用小写英文和连字符。
- 图片文件加入后再添加引用：封面放在 README 标题下，实机图放在中英文对应的使用说明旁。
- 每张新截图在本文件中记录拍摄日期、Mod／游戏／UE4SS 版本和房主或客机身份；生成或编辑过的宣传图要注明。
- 提取的游戏资源放在被忽略的 `work/`。

图片不放进 Mod ZIP。解压后的说明如何引用图片，见[公共图片说明](../../DEVELOPMENT.md#mod-图片)。仅在仓库中使用的 README 示例（路径相对于本 Mod 的 README）：

```markdown
![菜单巧配宣传封面](assets/cover.png)
![菜单巧配实机截图](assets/auto-compose-gameplay.png)
```
