# Bartender's Note images / 调饮手记图片

[English](#english) · [中文](#中文)

## English

Screenshots and artwork for this Mod, following the Old Market Simulator Mods folder layout.

### Images

| File | Size | Shows |
| --- | --- | --- |
| [cover.png](cover.png) | 2.00 MiB, 2089 × 753 | AI-generated cover artwork used on the [Nexus Mods page](https://www.nexusmods.com/mods/1?game_id=10352) |
| [claimed-drinks-gameplay.gif](claimed-drinks-gameplay.gif) | 12.02 MiB, 960 × 600, 13 s loop | Gameplay recording of the note showing claimed drinks |

The GIF is stored with Git LFS. To download it, run this from the repository root:

```powershell
git lfs pull --include="bartenders-note-mod/assets/claimed-drinks-gameplay.gif"
```

### Adding images

| Filename | Content |
| --- | --- |
| `cover.png` | Mod cover artwork for the README or a Mod listing |
| `<scene>-gameplay.png` | In-game screenshot, for example `claimed-drinks-gameplay.png` |
| `<scene>-gameplay.gif` | Gameplay recording, for example `claimed-drinks-gameplay.gif` |
| `<scene>-promo.png` | Additional promotional artwork |

- Use PNG, JPG or WebP for still images and GIF for animations, with lowercase, hyphenated filenames.
- Add an image embed only after the file exists. Put the cover below the README title and gameplay images next to the matching usage text in both languages.
- For each gameplay capture, note here its date, Mod and game version, host or guest role, and what it shows. Label generated or edited artwork as such.
- Images stay out of Mod ZIPs. Extracted game assets belong in the ignored `work/` folder.

For links that also work inside an extracted download, see the [shared image guidance](../../DEVELOPMENT.md#mod-images). Repository-only README example (paths relative to this Mod's README):

```markdown
![Bartender's Note cover artwork](assets/cover.png)
![Bartender's Note in-game test](assets/claimed-drinks-gameplay.png)
```

## 中文

本 Mod 的实机图和宣传图，沿用菜市场模拟器 Mods 的目录约定。

### 图片

| 文件 | 大小 | 内容 |
| --- | --- | --- |
| [cover.png](cover.png) | 2.00 MiB，2089 × 753 | [Nexus Mods 页面](https://www.nexusmods.com/mods/1?game_id=10352)使用的 AI 宣传封面 |
| [claimed-drinks-gameplay.gif](claimed-drinks-gameplay.gif) | 12.02 MiB，960 × 600，13 秒循环 | 手记显示认领饮料的实机录制 |

动图通过 Git LFS 保存。在仓库根目录运行以下命令取回：

```powershell
git lfs pull --include="bartenders-note-mod/assets/claimed-drinks-gameplay.gif"
```

### 添加图片

| 文件名 | 内容 |
| --- | --- |
| `cover.png` | README 或 Mod 页面使用的宣传封面 |
| `<scene>-gameplay.png` | 实机截图，例如 `claimed-drinks-gameplay.png` |
| `<scene>-gameplay.gif` | 实机录制动图，例如 `claimed-drinks-gameplay.gif` |
| `<scene>-promo.png` | 其他宣传图 |

- 静态图片用 PNG、JPG 或 WebP，动图用 GIF；文件名用小写英文和连字符。
- 图片实际加入后再添加引用：封面放在 README 标题下，实机图放在中英文对应的使用说明旁。
- 每张实机图在本文件中注明拍摄日期、Mod 和游戏版本、房主或客机身份及画面内容；生成或编辑过的宣传图注明来源。
- 图片不进入 Mod ZIP。提取的游戏资源放在被忽略的 `work/` 文件夹。

解压后的说明中如何引用图片，见[公共图片说明](../../DEVELOPMENT.md#mod-图片)。仅在仓库中使用的 README 示例（路径相对于本 Mod 的 README）：

```markdown
![调饮手记宣传封面](assets/cover.png)
![调饮手记实机测试](assets/claimed-drinks-gameplay.png)
```
