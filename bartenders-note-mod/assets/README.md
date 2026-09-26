# Bartender's Note images / 调饮手记图片

[English](#english) · [中文](#中文)

## English

Store this Mod's in-game test screenshots and promotional artwork here, following the Old Market Simulator Mods directory convention.

### Gameplay animation

[claimed-drinks-gameplay.gif](claimed-drinks-gameplay.gif) is a compressed copy of the Bartender's Note gameplay recording provided by the maintainer on 2026-09-26. It is stored using Git LFS: 960 × 600, 84 frames at approximately 6.25 fps, a 96-color palette, 13.28 seconds and continuous looping; 12,605,213 bytes (12.02 MiB), down 92.76% from 174,083,577 bytes. The complete recording duration, first and last frames, and full scene framing are retained; the local source recording is unchanged. The capture date, Mod/game/UE4SS versions and host/guest role were not supplied.

With Git LFS installed, retrieve this animation from the repository root using `git lfs pull --include="bartenders-note-mod/assets/claimed-drinks-gameplay.gif"`.

### Adding images

| Filename | Content |
| --- | --- |
| `cover.png` | Mod cover artwork for the README or a Mod listing |
| `<scene>-gameplay.png` | Actual in-game test capture, for example `claimed-drinks-gameplay.png` |
| `<scene>-gameplay.gif` | Animated gameplay recording, for example `claimed-drinks-gameplay.gif` |
| `<scene>-promo.png` | Additional promotional artwork |

Use PNG, JPG or WebP for still images and GIF for animations; use lowercase filenames with hyphens. Add image embeds only after the referenced files exist. Place the cover below the README title and gameplay images beside the relevant usage text in both languages.

For each test capture, record its date, Mod/game/UE4SS versions, host or guest role, and observed result in this file. Identify generated or edited promotional artwork as such; it does not establish in-game acceptance. Keep extracted game assets and reverse-engineering material in ignored `work/`.

These images are repository documentation and stay outside Mod ZIPs. See the [shared image guidance](../../DEVELOPMENT.md#mod-images) for links that also work from an extracted package. Repository-only README example (paths relative to this Mod's README):

```markdown
![Bartender's Note cover artwork](assets/cover.png)
![Bartender's Note in-game test](assets/claimed-drinks-gameplay.png)
```

## 中文

此目录存放本 Mod 的实机测试图和宣传图，沿用菜市场模拟器 Mods 的目录约定。

### 实机动图

实机动图 [claimed-drinks-gameplay.gif](claimed-drinks-gameplay.gif) 由维护者于 2026-09-26 提供的调饮手记录制压缩而来，通过 Git LFS 保存：960 × 600、84 帧、约 6.25 帧/秒、96 色、13.28 秒、循环播放；大小为 12,605,213 字节（12.02 MiB），较原始 174,083,577 字节减少 92.76%。保留完整录制时长、首尾画面及全画面范围，本地原始录制保持不变。拍摄日期、Mod／游戏／UE4SS 版本及房主／客机身份未提供。

安装 Git LFS 后，在仓库根目录运行 `git lfs pull --include="bartenders-note-mod/assets/claimed-drinks-gameplay.gif"` 即可取回此动图。

### 添加图片

| 文件名 | 内容 |
| --- | --- |
| `cover.png` | README 或 Mod 页面使用的宣传封面 |
| `<scene>-gameplay.png` | 真实实机测试截图，例如 `claimed-drinks-gameplay.png` |
| `<scene>-gameplay.gif` | 实机录制动图，例如 `claimed-drinks-gameplay.gif` |
| `<scene>-promo.png` | 其他宣传图 |

静态图片可使用 PNG、JPG 或 WebP，动图使用 GIF；文件名使用小写英文和连字符。图片实际加入后再启用引用：封面放在 README 标题下，实机图放在中英文对应的使用说明附近。

每张测试图在本文件中记录拍摄日期、Mod／游戏／UE4SS 版本、房主或客机身份及观察结果。生成或编辑过的宣传图应注明来源，不能作为实机验收依据。提取的游戏资源和反编译资料仍放在被忽略的 `work/`。

图片用于仓库文档，不进入 Mod ZIP。解压后的说明如何引用图片，见[公共图片说明](../../DEVELOPMENT.md#mod-图片)。仅在仓库中使用的 README 示例（路径相对于本 Mod 的 README）：

```markdown
![调饮手记宣传封面](assets/cover.png)
![调饮手记实机测试](assets/claimed-drinks-gameplay.png)
```
