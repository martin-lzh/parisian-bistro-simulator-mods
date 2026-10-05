# Parisian Bistro Simulator — Vortex Support

[English](#english) · [中文](#中文)

## English

**Version 0.1.0.** Adds Parisian Bistro Simulator to Vortex and installs complete UE4SS Lua mod folders without flattening their contents. Steam detection uses App ID `3058360`. This is a Vortex extension, separate from the seven gameplay mods.

### Install

1. In **Vortex → Home → Extensions**, click the **Drop File(s)** area, select the extension ZIP and restart Vortex.
2. Install **UE4SS experimental** separately using its [official guide](https://docs.ue4ss.com/dev/installation-guide.html). The seven LZH mods were checked with `v3.0.1-1140-gf58e8f84`; old stable 3.0.1 is unsupported. Keep `BrasserieSimulator/Binaries/Win64/ue4ss/UE4SS.dll` and its existing `Mods` folder.
3. Find **Parisian Bistro Simulator** under Games and select Manage. If detection fails, select the game root containing `BrasserieSimulator.exe`.
4. Close the game. Add the original mod ZIPs to Vortex, enable the mods you want and deploy. Each package must include `<ModName>/Scripts/main.lua` and `<ModName>/enabled.txt`.

Mods deploy to `BrasserieSimulator/Binaries/Win64/ue4ss/Mods` relative to the selected game folder. The installer keeps the mod's own folder, scripts, native helpers, README and license together. It also accepts one common outer archive folder. The extension does not download UE4SS, change loader settings, manage saves or launch the game automatically. It supports Lua mod packages; PAK mods and loader installation are outside its scope.

Before migrating existing manual installations, back up those mod folders and follow Vortex's conflict prompts. Do not keep two active copies of the same mod. Preserve `SmartDelivery/Scripts/delivery-preference.txt` during updates. Existing manual files are not automatically imported by this extension.

To remove a managed mod, disable it and deploy while the game is closed. Remove only the intended mods; preserve the loader and personal preferences. Removing the extension itself does not remove already deployed mod files.

### Build and verification

From the repository root:

```powershell
node --test vortex-extension/tests/*.test.js
python vortex-extension/build.py
```

The ZIP and SHA-256 file are written to ignored `outputs/vortex-extension/`. Packaging never installs the extension or mods. The archive includes original extension files and the MIT license only. `gameart.svg` is the original vector source for the bundled 640 × 360 PNG; it depicts a serving cloche and contains no game assets.

Installer tests check complete folders, multiple mods, native helpers, Windows paths, duplicate destinations and incomplete/unsafe packages. On 2026-10-05, Vortex 2.6.3 loaded the extension, detected the Steam installation and deployed all seven published LZH packages into an isolated test directory. All 76 deployed files matched the original ZIP contents byte for byte. This verifies installation, not gameplay; the actual game installation and saves were not modified.

[Source and support](https://github.com/martin-lzh/parisian-bistro-simulator-mods) · [Vortex extension documentation](https://github.com/Nexus-Mods/Vortex/wiki/LEGACY-General-Creating-a-game-extension)

## 中文

**版本 0.1.0。** 为 Vortex 添加《法式小馆儿模拟器》支持，安装 UE4SS Lua Mod 时保留完整的 Mod 文件夹。通过 Steam App ID `3058360` 查找游戏。这是 Vortex 游戏扩展，独立于七款游戏功能 Mod。

### 安装

1. 在 **Vortex → Home → Extensions** 中点击 **Drop File(s)** 区域，选择扩展 ZIP，然后重启 Vortex。
2. 按[官方指南](https://docs.ue4ss.com/dev/installation-guide.html)单独安装 **UE4SS experimental**。七款 LZH Mod 已核对加载器 `v3.0.1-1140-gf58e8f84`，不支持旧稳定版 3.0.1。保留 `BrasserieSimulator/Binaries/Win64/ue4ss/UE4SS.dll` 及已有的 `Mods` 文件夹。
3. 在 Games 中找到 **Parisian Bistro Simulator** 并选择 Manage。自动查找失败时，手动选择包含 `BrasserieSimulator.exe` 的游戏根目录。
4. 关闭游戏，将原版 Mod ZIP 加入 Vortex，启用所需 Mod 并部署。每个包必须包含 `<ModName>/Scripts/main.lua` 和 `<ModName>/enabled.txt`。

Mod 部署目标为所选游戏目录下的 `BrasserieSimulator/Binaries/Win64/ue4ss/Mods`。安装器保留每个 Mod 的独立目录、脚本、辅助 DLL、说明与许可，支持压缩包外层再有一个公共目录。扩展不自动下载加载器、不改加载器设置、不管理存档、不自动启动游戏，仅支持 Lua Mod 安装包，不负责 PAK Mod 或加载器安装。

从手动安装迁移前，备份现有 Mod 文件夹，并按 Vortex 的文件冲突提示处理；不要保留两个启用副本。更新配送随心时保留 `SmartDelivery/Scripts/delivery-preference.txt`。扩展不会自动接管手动安装的文件。

移除 Vortex 管理的 Mod 时，关闭游戏、禁用目标 Mod 后再部署；保留加载器和个人偏好。仅移除扩展不会删除已经部署的 Mod 文件。

### 构建与验证

在仓库根目录执行上方两条命令，运行 Node 安装器测试并生成扩展 ZIP。产物和 SHA-256 存入忽略的 `outputs/vortex-extension/`。打包不会安装扩展或 Mod，压缩包仅包含原创扩展文件与 MIT 许可。`gameart.svg` 是 640 × 360 PNG 图标的原创矢量源文件，图案为餐盘罩，不包含游戏资产。

离线测试覆盖目录结构、多个 Mod、辅助 DLL、Windows 路径、重复目标及不完整／不安全的压缩包。2026-10-05 已在 Vortex 2.6.3 中加载扩展、确认 Steam 游戏检测，并将七个已发布的 LZH 安装包部署到隔离测试目录；全部 76 个文件与原 ZIP 逐字节一致。此验证仅覆盖安装，不等于实机验收；实际游戏安装目录和存档未被修改。
