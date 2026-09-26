# Script hot reload / 脚本热重载

[English](#english) · [中文](#中文)

## English

Auto Menu **0.5.0-dev** supports Ctrl+R for Lua updates after initial installation; updating its native DLL requires restarting the game. Its previous button is removed on the next game-thread update, then rebuilt without changing either saved service menu.

The development Mods support manual Lua reload with the checked UE4SS experimental API `v3.0.1-1140-gf58e8f84`. This requires the reload-aware versions: Bartender's Note **0.1.2-dev**, Auto Checkout **0.1.4-dev**, Fresh to Serve **0.1.2-dev**, First to Serve **0.1.5-dev**, Smart Delivery **0.1.4-dev**, and Scan to Order **0.1.0-dev** or later. Offline lifecycle tests do not establish in-game acceptance.

1. Close the game and install the updated Mod folders once. Older scripts cannot hand over state they never recorded, and Smart Delivery's updated DLL requires a new process.
2. Back up `UE4SS-settings.ini` next to your loader and edit these entries in its existing `[General]` section:

   ```ini
   EnableHotReloadSystem = 1
   HotReloadKey = R
   EnableAutoReloadingLuaMods = 0
   ```

3. Start the game. For subsequent Lua-only updates, copy all changed scripts into the matching installed Mod folder, finish copying, focus the game window and press **Ctrl+R** once. UE4SS reloads all enabled Mods, including any additional Mods you installed. Those additional Mods need their own reload support.
4. Check the UE4SS log for the reload and each Mod's startup or error message. Release the pickup key before starting another First to Serve hold.

The bundle includes `Enable-HotReload.ps1` (source: [setup script](../tools/enable_hot_reload.ps1)). Run it in PowerShell with `-Ue4ssDirectory "<your loader directory>"` to back up the existing INI and set just those three entries. It preserves other settings, does not install Mods or control the game, and takes effect at the next launch.

Manual reload keeps multi-file updates together. Automatic file watching stays disabled because it could load while only some files have been replaced; Smart Delivery also writes preference and acknowledgement files inside its Scripts folder.

Reload replaces Lua states, hooks and timers. The Mods retain only scalar state in UE4SS shared variables, resolve current game objects again on the game thread, and remove their previous UI rows. Auto Checkout retains AI recovery records and transaction retry history. Fresh to Serve retains pending replacement orders and their retry deadlines. First to Serve cancels the old hold. Smart Delivery restores the saved delivery choice; an unsaved dropdown edit is discarded.

**DLL changes, loader updates, first installation and removal require closing and restarting the game.** A Lua reload cannot replace Smart Delivery's loaded native helper. Disabling or deleting Auto Checkout without letting its next instance restore AI state requires reloading the world; script reload is not an uninstall procedure. A Fresh to Serve engine request with an uncertain outcome remains stopped for that world rather than being retried by reloading; enter a new session to reset it.

Shared state exists only in the current game process. It is not added to game saves. Builds still produce packages only; they do not edit the installation or control the game process.

Scan to Order reads outstanding orders again after reload, so replenishment can resume them without repeating accepted orders. An uncertain request keeps automation stopped in the current world across Ctrl+R; re-enter the session to reset it.

## 中文

Auto Menu **0.5.0-dev** 首次安装后支持 Ctrl+R 重载 Lua，更新原生 DLL 必须重启游戏；下一次游戏线程更新时清除旧按钮再创建新按钮，不改变已保存的午餐或晚餐菜单。

开发版 Mod 支持手动重载 Lua，使用已核对的 UE4SS experimental API `v3.0.1-1140-gf58e8f84`。需要支持状态交接的版本：Bartender's Note **0.1.2-dev**、Auto Checkout **0.1.4-dev**、Fresh to Serve **0.1.2-dev**、First to Serve **0.1.5-dev**、Smart Delivery **0.1.4-dev**、Scan to Order **0.1.0-dev** 或之后版本。离线生命周期测试不等于实机验收。

1. 首次先关闭游戏，安装更新后的 Mod。旧脚本无法交接此前未记录的状态，Smart Delivery 更新后的 DLL 也需要新进程。
2. 备份加载器旁的 `UE4SS-settings.ini`，在已有的 `[General]` 段修改以下三项：

   ```ini
   EnableHotReloadSystem = 1
   HotReloadKey = R
   EnableAutoReloadingLuaMods = 0
   ```

3. 启动游戏。之后仅更新 Lua 时，将全部改动脚本复制到对应的已安装 Mod 文件夹；复制完成后切回游戏，按一次 **Ctrl+R**。UE4SS 会重载所有已启用的 Mod，包括另外安装的其他 Mod；它们也须自行支持重载。
4. 在 UE4SS 日志中确认重载及各 Mod 的启动或错误信息。先做好先端需要先松开交互键，再重新长按。

组合包附带 `Enable-HotReload.ps1`（源码：[设置脚本](../tools/enable_hot_reload.ps1)）。在 PowerShell 运行时传入 `-Ue4ssDirectory "<加载器目录>"`，会备份现有 INI 并仅修改这三项。其他设置保持原样；脚本不安装 Mod、不控制游戏，配置在下次启动生效。

使用手动重载，确保多文件更新已全部复制完毕。关闭文件变动自动重载，避免只更新部分文件就开始加载；Smart Delivery 也会在 Scripts 文件夹内写入偏好和应答文件。

重载会替换 Lua 状态、Hook 和计时器。Mod 仅通过 UE4SS 共享变量交接标量状态，在游戏线程重新查找当前游戏对象并清理旧 UI。自动结账保留 AI 恢复记录和交易重试历史；焕新上桌保留待补单及重试期限；先做好先端取消原来的长按；智选配送恢复已保存的配送选项，尚未保存的下拉框选择会丢弃。

**DLL 变更、加载器更新、首次安装和卸载都需要关闭并重启游戏。** Lua 重载不能替换已经加载的 Smart Delivery 原生辅助模块。禁用或删除 Auto Checkout 而不让下个实例恢复 AI 状态时，需要重新加载世界；热重载不是卸载流程。焕新上桌遇到结果不确定的引擎请求后，在当前世界保持停止，不会因重载而再次发送；进入新的会话后才重置。

共享状态仅存在于当前游戏进程，不写入游戏存档。构建仍然只生成安装包，不修改安装目录，也不控制游戏进程。

扫码点餐在重载后重新读取未完成订单，补货后继续，不重复已完成项。结果不确定的请求会使当前世界的自动化跨 Ctrl+R 保持停止，重新进入会话后重置。
