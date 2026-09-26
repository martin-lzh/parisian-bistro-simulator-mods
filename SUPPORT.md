# Help and feedback / 帮助与反馈

[English](#english) · [中文](#中文)

## English

Start with the [Mod list](README.md#english) and the installation guide for your Mod.

### Download or installation problems

- **GitHub shows 404 or no download:** this repository is public and downloads do not require sign-in. Check the URL and open [Mod Releases](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases). Use the version link in the Mod guide, then download its ZIP under **Assets**. For missing files, contact the maintainer through an existing contact or an [issue](https://github.com/martin-lzh/parisian-bistro-simulator-mods/issues).
- **The download contains more ZIPs:** CI artifacts contain an outer `mod-packages` archive; extract that first, then the individual Mod ZIP. Release attachments are individual Mod ZIPs. Do not install the Source code archive.
- **The Mod does not appear:** check the folder layout. For example, use `Mods/AutoMenu/Scripts/main.lua` and `Mods/AutoMenu/enabled.txt`, not `Mods/AutoMenu/AutoMenu/Scripts/main.lua`. Keep every file from the package, including a DLL when present.
- **The loader does not start:** these Mods need UE4SS experimental, with checked version `v3.0.1-1140-gf58e8f84`. Follow the [official installation guide](https://docs.ue4ss.com/dev/installation-guide.html), keeping the loader's folder layout. Old stable 3.0.1 is not supported. With a custom loader location, use its actual `Mods` folder.

Close the game before changing Mod files, then start it again. Check the Mod's host/guest requirements and usage steps. When isolating a conflict, change one Mod at a time and keep the loader and unrelated Mods in place. Removing a Mod does not undo completed sales, orders or discarded items.

### Report a problem or suggest a feature

Use [GitHub Issues](https://github.com/martin-lzh/parisian-bistro-simulator-mods/issues/new/choose), in English or Chinese. Include:

- Mod name and version, where you downloaded it, and game/UE4SS versions if available.
- Windows version, game language, and single-player, host or guest role.
- Steps to reproduce, what you expected, what happened, and other Mods installed.
- A screenshot of the relevant display or a short error excerpt from the loader's `UE4SS.log` if available. Do not paste the entire log.

Review attachments for usernames, local paths, room codes and other private information. Do not upload saves, game files, extracted assets or decompiled material. For a security vulnerability, use [Security](SECURITY.md#english) instead of a bug report. Compatibility with every game update or Mod combination and fixed response times are not guaranteed.

## 中文

先查看 [Mod 列表](README.md#中文)及对应安装说明。

### 下载或安装遇到问题

- **GitHub 显示 404 或找不到下载：**仓库已公开，下载无需登录。请检查链接地址，打开 [Mod 正式版本](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases)，或使用 Mod 说明中的版本链接，在 **Assets** 下载 ZIP。文件缺失时，通过已有联系方式或 [Issue](https://github.com/martin-lzh/parisian-bistro-simulator-mods/issues)联系维护者。
- **解压后还有 ZIP：**CI artifact 包含外层 `mod-packages` 压缩包，先解压外层，再解压单个 Mod ZIP。Release 附件直接提供各 Mod ZIP。不要安装 Source code 源码包。
- **Mod 没有出现：**检查目录层级，例如应有 `Mods/AutoMenu/Scripts/main.lua` 和 `Mods/AutoMenu/enabled.txt`，不能多套成 `Mods/AutoMenu/AutoMenu/Scripts/main.lua`。保留安装包内全部文件，包含其中已有的 DLL。
- **加载器没有启动：**这些 Mod 需要 UE4SS experimental，已核对版本为 `v3.0.1-1140-gf58e8f84`。按[官方安装说明](https://docs.ue4ss.com/dev/installation-guide.html)保留加载器目录结构，不支持旧稳定版 3.0.1。自定义安装位置时，使用实际加载器的 `Mods` 文件夹。

修改 Mod 文件前先关闭游戏，完成后重新启动。检查对应 Mod 的房主／客机要求和使用方式。排查冲突时一次只调整一个 Mod，保留加载器和其他 Mod。卸载不会撤销已完成的交易、订单或已丢弃物品。

### 报告问题或建议功能

通过 [GitHub Issues](https://github.com/martin-lzh/parisian-bistro-simulator-mods/issues/new/choose)反馈，中英文均可。请提供：

- Mod 名称、版本及下载来源；能找到的游戏和 UE4SS 版本。
- Windows 版本、游戏语言，以及单人、房主或客机身份。
- 复现步骤、预期结果、实际结果及同时安装的其他 Mod。
- 相关画面截图，或加载器 `UE4SS.log` 中的少量错误片段，不必粘贴完整日志。

上传前检查用户名、本地路径、房间码等隐私。不要上传存档、游戏文件、提取资源或反编译资料。安全漏洞请使用[安全反馈](SECURITY.md#中文)，不要放入普通问题报告。不保证兼容所有游戏更新或 Mod 组合，也没有固定回复时限。
