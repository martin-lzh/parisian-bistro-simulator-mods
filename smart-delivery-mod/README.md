# Smart Delivery / 智选配送

[English](#english) · [中文](#中文)

## English

**Version: 0.1.0-dev — in-game acceptance pending.** Choose Free service, Budget delivery or Premium delivery for automatic smart orders from the restaurant computer's existing automatic-order settings dialog. Click the game's Save button to apply the choice; Cancel discards it.

The purchase minimum, stockout override, shopping list, money checks, night surcharge and delivery processing remain controlled by the game. Manual ingredient and furniture orders keep their own delivery choices. Delivery names use the game's current translations; the new field label supports all 14 game languages.

### Requirements and installation

- Windows x64, Steam Build **25393699**, ProjectVersion **1.0.0.44eb** (UE 5.4). The native helper checks the exact executable SHA-256 and refuses other builds or an already-modified automatic-order routine.
- UE4SS experimental, locally checked API `v3.0.1-1140-gf58e8f84`. UE4SS stable 3.0.1 is not supported.
- Single-player or the multiplayer host. Only the host's choice controls automatic deliveries; clients do not get an editable Mod selector.

Close the game before installing. Extract the package so `ue4ss/Mods/SmartDelivery/Scripts/main.lua` and `Scripts/delivery_bridge.dll` exist, with `SmartDelivery/enabled.txt`. Do not place the helper in UE4SS's `dlls` directory. The Lua Mod loads it itself. The ZIP includes only original Mod code and documentation; obtain UE4SS separately.

Open the restaurant computer → automatic smart-order settings → Delivery method → select an option → Save. **Premium delivery is the initial Mod preference.** The choice is stored in `SmartDelivery/Scripts/delivery-preference.txt`, shared across this installation's restaurants and retained after restarting the game. This is a Mod preference, not a new field in the game save. Keep that file when updating the Mod. The folder must be writable.

Free service uses the game's service fee and brings no unloading staff; Budget brings one worker; Premium brings four. Night surcharges still apply where the game requires them. This Mod does not make manual orders, trigger an extra timer, or order while native automatic ordering is disabled.

To uninstall, close the game and remove `SmartDelivery`. Native automatic ordering resumes its original delivery-selection behavior. Game saves require no conversion. Mod diagnostics begin with `[SmartDelivery]`; retain relevant error lines and `Scripts/bridge-status.txt` when reporting problems.

### Build

From the repository root, run `python smart-delivery-mod/build.py`. Windows x64, Visual Studio 2022 C++ Build Tools (or a compatible current installation) and the Windows SDK are required. Output: `outputs/smart-delivery/SmartDelivery-0.1.0-dev.zip` and `.zip.sha256`. Builds never install, launch or close the game, or edit saves.

See [development and validation](DEVELOPMENT.md#english) for the test scope.

## 中文

**版本：0.1.0-dev，待实机验收。** 在餐厅电脑原有的“自动智能订购”设置窗口中，新增免费服务、经济型配送、高级配送三种选择。点击游戏原有的“保存”后生效；“取消”放弃本次修改。

采购金额下限、缺货优先、采购清单、余额检查、夜间附加费及配送处理继续由游戏负责。手动购买食材或家具仍使用各自的配送选择。配送名称读取游戏当前译文，新字段标题覆盖游戏的 14 种语言。

### 依赖与安装

- Windows x64，Steam Build **25393699**，ProjectVersion **1.0.0.44eb**（UE 5.4）。原生辅助模块核对游戏可执行文件的完整 SHA-256；其他构建或已被修改的自动订购逻辑会被拒绝。
- UE4SS experimental，本机核对 API 为 `v3.0.1-1140-gf58e8f84`，不支持旧稳定版 3.0.1。
- 单人或联机房主使用。自动配送以房主选择为准；客户端不显示可编辑的 Mod 配送选项。

关闭游戏后安装，解压后应有 `ue4ss/Mods/SmartDelivery/Scripts/main.lua`、`Scripts/delivery_bridge.dll` 和 `SmartDelivery/enabled.txt`。辅助 DLL 由 Lua Mod 自行加载，不要放进 UE4SS 的 `dlls` 目录。安装包仅包含原创 Mod 代码和文档，UE4SS 需另行安装。

打开餐厅电脑 → 自动智能订购设置 → 配送方式 → 选择 → 保存。**Mod 初始偏好为高级配送。** 选择保存在 `SmartDelivery/Scripts/delivery-preference.txt`，重启游戏后保留，同一安装下的各餐厅共用。它是 Mod 偏好，不向游戏存档新增字段；升级 Mod 时保留这个文件，安装目录需可写。

免费服务沿用游戏服务费且不派卸货员，经济型配送为 1 名卸货员，高级配送为 4 名。游戏要求的夜间附加费仍然有效。Mod 不增加订购定时器，也不会在原生自动订购关闭时自行采购。

卸载时关闭游戏并删除 `SmartDelivery` 文件夹，原生自动订购恢复原配送选择逻辑，存档无需转换。日志前缀为 `[SmartDelivery]`；反馈问题时保留相关错误行及 `Scripts/bridge-status.txt`。

### 构建

在仓库根目录运行 `python smart-delivery-mod/build.py`。需要 Windows x64、Visual Studio 2022 C++ Build Tools（或兼容安装）和 Windows SDK。生成 `outputs/smart-delivery/SmartDelivery-0.1.0-dev.zip` 及 `.zip.sha256`。构建不会安装 Mod、启动或关闭游戏，也不修改存档。

验证范围见[开发与验收](DEVELOPMENT.md#中文)。
