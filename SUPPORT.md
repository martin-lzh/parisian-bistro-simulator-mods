# Help and feedback / 帮助与反馈

[English](#english) · [中文](#中文)

## English

First go through the [manual installation steps](README.md#manual-download-and-installation) or the [Vortex setup guide](vortex-extension/README.md#english), then the Mod's own **How to use** section.

### Download or installation problems

- **Vortex asks for Premium when adding the collection:** one-click collection install requires Nexus Premium. With a free account, download each Mod ZIP and install it manually, or import it with Vortex's **Install From File**, enable it and deploy. GitHub downloads need no account. With or without Premium, install the game extension and UE4SS yourself first.
- **Windows says `VCRUNTIME140`, `MSVCP140` or a similar DLL is missing:** install or repair the [Microsoft Visual C++ v14 Redistributable X64](https://aka.ms/vc14/vc_redist.x64.exe) and restart if asked. Don't download single DLLs from other sites.
- **GitHub shows 404 or no download:** check the link, or open [Mod Releases](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases) and download the ZIP under **Assets**. If a file is missing, open an [issue](https://github.com/martin-lzh/parisian-bistro-simulator-mods/issues).
- **The download contains another ZIP:** a CI artifact has an outer `mod-packages` archive — extract it, then extract the Mod ZIP inside. Release downloads are already individual Mod ZIPs. Don't install the **Source code** archive.
- **The Mod doesn't appear:** check the folder layout. It should be `Mods/AutoMenu/Scripts/main.lua` plus `Mods/AutoMenu/enabled.txt`, not `Mods/AutoMenu/AutoMenu/Scripts/main.lua`. Keep every file from the ZIP, including any DLL.
- **The loader doesn't start:** these Mods need UE4SS experimental `v3.0.1-1140-gf58e8f84`; the old stable 3.0.1 doesn't work. See the [official UE4SS installation guide](https://docs.ue4ss.com/dev/installation-guide.html). If UE4SS is installed somewhere else, use that installation's `Mods` folder.
- **Still not working:** after running the game once, open `Win64/ue4ss/UE4SS.log` with Notepad. If there is no log, UE4SS isn't starting; recheck the loader install. If there is one, look for lines tagged with the Mod's name.

Always close the game before changing Mod files. Check the Mod's host/guest requirements. To find a conflict, change one Mod at a time and leave the loader and other Mods in place.

### Report a problem or suggest a feature

Use [GitHub Issues](https://github.com/martin-lzh/parisian-bistro-simulator-mods/issues/new/choose), in English or Chinese. Please include:

- Mod name and version, where you downloaded it, and the game/UE4SS versions if you know them.
- Windows version, game language, and whether you played single-player, as host or as guest.
- Steps to reproduce, what you expected, what happened, and which other Mods are installed.
- A screenshot, or a short excerpt of the relevant lines from `UE4SS.log` (not the whole log).

Before uploading, remove usernames, local paths, room codes and other private details. Don't upload saves, game files or extracted game assets. Report security issues through [Security](SECURITY.md#english), not a public issue.

## 中文

先按[手动安装步骤](README.md#手动下载与安装)或 [Vortex 安装说明](vortex-extension/README.md#中文)操作，再看对应 Mod 的“怎么使用”。

### 下载或安装遇到问题

- **Vortex 添加合集时要求 Premium：**合集一键安装需要 Nexus Premium。免费账号可以逐个下载 Mod ZIP 手动安装，或用 Vortex 的 **Install From File（从文件安装）**导入，再启用并部署。GitHub 下载无需账号。无论是否有 Premium，都要先自行装好游戏扩展和 UE4SS。
- **Windows 提示缺少 `VCRUNTIME140`、`MSVCP140` 等 DLL：**安装或修复 [Microsoft Visual C++ v14 Redistributable X64](https://aka.ms/vc14/vc_redist.x64.exe)，按提示重启。不要从其他网站下载单个 DLL。
- **GitHub 显示 404 或找不到下载：**检查链接，或打开 [Mod 发布页](https://github.com/martin-lzh/parisian-bistro-simulator-mods/releases)，在 **Assets** 下载 ZIP。文件缺失时请提交 [Issue](https://github.com/martin-lzh/parisian-bistro-simulator-mods/issues)。
- **解压后还有 ZIP：**CI artifact 外层是 `mod-packages` 压缩包，先解压外层，再解压里面的 Mod ZIP。Release 下载的已经是单个 Mod ZIP。不要安装 **Source code** 源码包。
- **Mod 没有出现：**检查目录层级，应为 `Mods/AutoMenu/Scripts/main.lua` 加 `Mods/AutoMenu/enabled.txt`，而不是 `Mods/AutoMenu/AutoMenu/Scripts/main.lua`。保留 ZIP 内全部文件，包括 DLL。
- **加载器没有启动：**这些 Mod 需要 UE4SS experimental `v3.0.1-1140-gf58e8f84`，旧稳定版 3.0.1 无法使用。可参考 [UE4SS 官方安装说明](https://docs.ue4ss.com/dev/installation-guide.html)。UE4SS 装在其他位置时，使用那份安装的 `Mods` 文件夹。
- **仍然无效：**运行一次游戏后，用记事本打开 `Win64/ue4ss/UE4SS.log`。没有日志说明 UE4SS 没有启动，请重新检查加载器安装；有日志时，查找带有该 Mod 名称的行。

修改 Mod 文件前务必退出游戏。注意各 Mod 的房主／客机要求。排查冲突时一次只调整一个 Mod，保留加载器和其他 Mod。

### 报告问题或建议功能

通过 [GitHub Issues](https://github.com/martin-lzh/parisian-bistro-simulator-mods/issues/new/choose)反馈，中英文均可。请提供：

- Mod 名称、版本及下载来源；知道的话附上游戏和 UE4SS 版本。
- Windows 版本、游戏语言，以及单人、房主还是客机。
- 复现步骤、预期结果、实际结果，以及同时安装的其他 Mod。
- 截图，或 `UE4SS.log` 中相关的几行（不必贴完整日志）。

上传前请去掉用户名、本地路径、房间码等隐私信息。不要上传存档、游戏文件或提取的游戏资源。安全问题请走[安全反馈](SECURITY.md#中文)，不要公开提交。
