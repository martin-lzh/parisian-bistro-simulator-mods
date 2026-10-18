# Smart Delivery development / 配送随心开发

[English](#english) · [中文](#中文)

## English

### Compatibility

- Current version: **0.1.6**.
- **0.1.6 test status:** compared with 0.1.5, 0.1.6 changes only the license (PolyForm Noncommercial 1.0.0), the documentation and the version number; gameplay code is unchanged. In-game testing of 0.1.6 by the maintainer is still pending.
- Supported game: up to **1.0.2.44eb / Steam Build 25822788**. Last in-game acceptance: Build 25759268 (2026-10-07); see the [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/releases/validation.md#english).
- Native discovery reference build: Steam Build 25532071 / game 1.0.1.44eb. Detailed evidence is in `work/smart-delivery-research/build-25532071/`.
- Loader: UE4SS experimental `v3.0.1-1140-gf58e8f84`. Stable UE4SS 3.0.1 is not supported.

Research and compatibility evidence stay in the ignored `work/` folder.

### UI

Smart Delivery adds one UMG selector to the existing automatic smart-order dialog.

- It reads the three native delivery labels at runtime and uses the dialog font with explicit white dropdown text.
- The Save/Cancel footer is preserved. Unsaved changes are reset whenever the native settings are repopulated.
- Only a local authoritative owner can change the preference. The preference is installation-wide and lives outside game saves.

Since 0.1.5, each selector's `WidgetStyle` and `ItemStyle` are set before it is attached to the Slate tree.

- The popup's `TextColor` and `SelectedTextColor` must be set separately from `ForegroundColor`.
- The palette uses charcoal surfaces, soft white text and muted green selection. sRGB values are converted to linear Slate colors, and keyboard focus gets an outlined brush.
- The native arrow, font and selection behavior are kept. Disabled rendering is a regression checklist scenario.

### Why a native helper

The automatic-order evaluator is called by native timers and delegates, and it overwrites the shipping fee before checking affordability. A reflected `OrderIngredients` hook alone cannot intercept those direct calls.

The original Windows helper changes only the delivery selection inside that evaluator. Native list generation, thresholds, availability, money checks, night fees, staff assignment and the final order stay intact, including orders placed immediately when settings are saved. Manual order paths are not hooked.

### Native discovery

- The helper resolves the evaluator and three fee getters through native registration names in the installed PE image.
- Chained x64 unwind records bound the evaluator. Instruction operands identify the quantity branch, native coefficients and the common difficulty getter.
- Addresses and the quantity threshold come from discovery. There is no build-number, fixed executable-size or SHA-256 allowlist.
- Missing or ambiguous targets, or changed instruction structure, stop initialization.
- Before installing a game-thread jump, the helper compares the loaded evaluator and fee getters with the current file to detect conflicting modifications.
- The dispatch preserves registers, reads the live free-service coefficient and resumes the native budget/premium branches.
- No extracted bytes, game assets, UE4SS binaries, SDK dumps or third-party hook libraries are bundled.

The free-service coefficient is writable runtime data in the zero-filled tail of a PE section. Validate its mapped section bounds and permissions and keep its live value; don't require file bytes or compare it with disk contents. The 0.1.0-dev file lookup wrongly rejected this valid address. Synthetic PE regression tests cover this case, section boundaries, overflow and truncated files.

### Lua bridge

- Lua loads named C entry points through `package.loadlib`. They take no arguments, return no Lua values and touch no Lua ABI structures.
- Each game-thread operation writes a fresh status acknowledgment.
- A Lua failure on the game thread disables the preference and requests restoration of the original instruction. A conflicting later patch is never overwritten.
- The helper stays loaded until the process exits.

### Lua reload lifecycle

Supported since 0.1.4-dev.

1. `ModRef.OnUnload` stops the old closures and calls `delivery_suspend`. Its only effect is `InterlockedExchange(selected, -1)`: no UObject access, code patch, file operation or deferred callback.
2. The resident dispatch then uses its verified native quantity threshold.
3. The new state's game-thread startup resolves shared widget identity strings, removes old selector rows, checks that the installed jump still belongs to this helper, and reapplies the saved preference.
4. The installed trampoline is reused; no new one is allocated.

Shared variables never hold transient UObjects or callbacks. A changed native DLL, a loader replacement or removing the Mod requires restarting the game.

### Offline verification

```powershell
uv run --with lupa==2.6 python smart-delivery-mod/tests/run.py
python smart-delivery-mod/build.py
python tools/check_repository.py
python tools/check_syntax.py
python -m unittest discover -s tools/tests -v
python tools/ci.py build
git diff --check
```

The build requires Windows x64, MSVC C++ and MASM, and the Windows SDK. Compiler warnings are errors.

- **Native dispatch harness:** runs the generated dispatch code for every delivery mode, default routing, order-size boundaries, difficulty factors and register preservation. Discovered quantity thresholds of 4 and 7 are both covered.
- **Synthetic PE fixtures:** moved code/data, different image bases, unrelated file changes, duplicate targets, changed operands, malformed unwind records, code conflicts and live fee data.
- **Rejection test:** a separate process checks that an unrelated executable with no delivery registrations is rejected.
- **Lua tests:** preference parsing, recovery, Save/Cancel, host isolation and UI behavior.
- **Reload tests:** worker-thread suspension, patch reuse and conflict refusal, old callback guards, primitive-only widget cleanup and Save/Cancel recovery.
- **CI:** compares source files byte-for-byte and checks the explicitly allowed generated DLL against build hashes. Release verification uses the commit-bound CI evidence.

### In-game regression checklist

0.1.5 passed in-game and multiplayer testing on 2026-09-26; see the [validation record](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/releases/validation.md#english). Use these scenarios for future regression checks.

1. For each delivery option, save, reopen the dialog, restart the game and check the choice. Cancel a different choice and check the saved one survives, including a rapid close/reopen.
2. Trigger small and large automatic orders. Compare service fees, the full amount charged and arriving unloaders (0 / 1 / 4). Repeat on different difficulty levels and at night.
3. Test the stockout override below the amount threshold, insufficient funds, a delivery already under way, automatic ordering disabled, and saving while an order becomes eligible. Exactly one order should be placed.
4. Check that manual ingredient and furniture delivery options stay independent. Switch restaurants, return to the menu and reconnect as host/client.
5. Check all 14 languages, keyboard/gamepad navigation, narrow resolutions and large UI scale. The new row and dropdown must not cover Save/Cancel.
6. Check missing or changed target code, another Mod changing the same routine, invalid preferences and an unwritable Mod folder. Review diagnostics and make sure automatic orders don't silently use the displayed preference after an error.
7. Reload repeatedly with the dialog open and with an unsaved selection. Expect one selector, no duplicate hooks/timers, the saved preference restored and native orders continuing. Also reload during travel, as host/client, and while an automatic order becomes eligible.

### Loader, packaging and diagnostics

- The build writes `outputs/smart-delivery/SmartDelivery-0.1.6.zip` and its SHA-256 file. Builds don't install the Mod, start or stop the game, or edit saves.
- The compiled `Scripts/delivery_bridge.dll` is loaded by Lua, not from UE4SS's `dlls` folder.
- The preference file is `Scripts/delivery-preference.txt`; premium is the initial fallback.
- After upgrading with the game closed, check `UE4SS.log` for `[SmartDelivery] START version=0.1.6` and `UI attached to automatic-order settings`.
- Keep the original startup error from that log: cleanup may later replace `Scripts/bridge-status.txt` with `disabled`.

### Manual script reload

0.1.4-dev changed the helper, so upgrading to it the first time requires closing the game and replacing the complete package. After that, Lua-only updates can use **Ctrl+R** once the [shared reload configuration](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/docs/hot-reload.md#english) is in place. Replace all updated Lua files before reloading.

Reloading discards unsaved selector changes, removes the old selector on the new state's game-thread refresh and reapplies the saved preference. During the reload gap, native automatic ordering uses its quantity-based delivery choice. Replacing `delivery_bridge.dll`, updating UE4SS or removing the Mod requires restarting the game.

## 中文

### 兼容性

- 当前版本：**0.1.6**。
- **0.1.6 测试状态：**与 0.1.5 相比，0.1.6 只更改许可（PolyForm Noncommercial 1.0.0）、文档和版本号，玩法代码不变。维护者对 0.1.6 的实机测试尚待进行。
- 支持游戏：至 **1.0.2.44eb / Steam Build 25822788**。最近一次实机验收：Build 25759268（2026-10-07），见[验证记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/dev/releases/validation.md#中文)。
- 原生定位参考构建：Steam Build 25532071 / 游戏 1.0.1.44eb，详细证据位于 `work/smart-delivery-research/build-25532071/`。
- 加载器：UE4SS experimental `v3.0.1-1140-gf58e8f84`，不支持稳定版 UE4SS 3.0.1。

研究资料和兼容性证据仅保存在被忽略的 `work/` 文件夹。

### 界面

在原有自动智能订购窗口中增加一个 UMG 配送选择框。

- 运行时读取三种原生配送名称，沿用窗口字体，下拉框使用明确的白色文字。
- 保留底部保存/取消按钮；每次重新填充原生设置时，丢弃未保存的修改。
- 仅本地房主能修改偏好；偏好由同一安装下的餐厅共用，保存在游戏存档之外。

从 0.1.5 起，选择框挂入 Slate 树之前先设置实例的 `WidgetStyle` 和 `ItemStyle`。

- 弹出列表的 `TextColor`、`SelectedTextColor` 必须独立于 `ForegroundColor` 设置。
- 配色为炭灰背景、柔白文字和低饱和绿色选中项；sRGB 值转换为 Slate 线性色彩，键盘焦点使用描边。
- 保留原生箭头、字体和选择行为。禁用状态的显示列为回归检查场景。

### 为什么需要原生辅助模块

自动订购由原生定时器和委托调用，并在余额检查前覆盖配送费；只拦截反射的 `OrderIngredients` 无法截获这些直接调用。

原创 Windows 辅助模块只改变该执行过程中的配送选择。采购清单、下限、可用性、余额检查、夜间费用、配送人数和实际下单仍走游戏原逻辑，包括保存设置时立即触发的订购。手动订单不经过该修改。

### 原生定位

- 从当前 PE 文件的原生注册名称定位执行函数和三种费用查询函数。
- 通过 x64 链式展开记录确定执行函数边界，并用指令操作数识别数量分支、费用系数和共同的难度倍率查询。
- 地址与数量阈值均来自定位结果，不使用游戏构建号、EXE 固定大小或 SHA-256 白名单。
- 目标缺失、重复或指令结构不符时停止初始化。
- 安装游戏线程跳转前，比较内存中的执行函数和费用查询函数与当前文件，检测冲突修改。
- 分派代码保留寄存器，读取实时免费服务系数，并回到游戏的经济型/高级配送分支。
- 安装包不含游戏字节、游戏资产、UE4SS 二进制、SDK 导出或第三方 Hook 库。

免费服务系数是 PE 节区零填充尾部的可写运行时数据：应核验映射后的范围与权限并保留实时值，不要求它有文件字节，也不与磁盘内容比较。0.1.0-dev 错误地按文件范围查找，导致初始化拒绝合法地址。原创合成 PE 回归用例覆盖这一情况、节区边界、溢出及文件截断。

### Lua 桥接

- Lua 通过 `package.loadlib` 加载具名 C 入口；入口无参数、无 Lua 返回值，也不访问 Lua ABI 内部结构。
- 每次游戏线程操作都写入新的状态回执。
- 游戏线程上的 Lua 出错时停用偏好并请求恢复原指令；若之后有其他补丁覆盖此处，不会强行覆盖它。
- 辅助模块一直保留到进程结束。

### Lua 重载流程

0.1.4-dev 起支持。

1. `ModRef.OnUnload` 停止旧闭包并调用 `delivery_suspend`。该入口只执行 `InterlockedExchange(selected, -1)`，不访问 UObject、不修改代码、不写文件，也不安排延迟回调。
2. 驻留分派随即采用已核验的原生数量阈值。
3. 新状态在游戏线程按共享身份字符串查找并清理旧选择框，检查跳转仍属于本模块，再恢复已保存偏好。
4. 复用已安装的跳板，不重复分配。

共享变量不保存临时 UObject 或回调。更换原生 DLL、替换加载器或卸载 Mod 均需重启游戏。

### 离线验证

```powershell
uv run --with lupa==2.6 python smart-delivery-mod/tests/run.py
python smart-delivery-mod/build.py
python tools/check_repository.py
python tools/check_syntax.py
python -m unittest discover -s tools/tests -v
python tools/ci.py build
git diff --check
```

构建需要 Windows x64、MSVC C++/MASM 和 Windows SDK，编译警告按错误处理。

- **原生分派测试程序：**直接执行生成的分派代码，覆盖各配送方式、默认分支、订单数量边界、难度倍率及寄存器保留；动态取得的数量阈值 4 和 7 均有覆盖。
- **合成 PE 用例：**代码与数据移动、不同映像基址、无关文件变化、目标重复、操作数变化、异常展开记录、代码冲突及实时费用数据。
- **拒绝测试：**用独立进程确认不含配送注册信息的程序会被拒绝。
- **Lua 测试：**偏好解析、恢复、保存/取消、房主范围及界面行为。
- **重载测试：**工作线程原子暂停、跳板复用与冲突拒绝、旧回调停止、字符串控件身份清理和保存偏好恢复。
- **CI：**逐字节核对源码文件，并对显式允许的原创 DLL 核验构建哈希；发布校验使用绑定提交的 CI 证据。

### 实机回归清单

0.1.5 已于 2026-09-26 通过实机及联机测试，见[验收记录](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/releases/validation.md#中文)。以下场景用于今后的回归检查。

1. 对每种配送方式保存、重新打开窗口、重启游戏并核对选择；取消另一项选择，确认已保存的选择保留，包括快速关闭再打开。
2. 触发小额和大额自动订单，核对服务费、实际扣款和到达的卸货员人数（0 / 1 / 4）；在不同难度和夜间重复。
3. 测试低于金额下限的缺货优先、余额不足、配送进行中、关闭自动订购，以及保存时恰好满足下单条件，确认只下一单。
4. 确认手动购买食材/家具的配送选项独立；切换餐厅、返回菜单，并以房主/客户端身份重连。
5. 检查 14 种语言、键盘/手柄操作、窄分辨率和大 UI 缩放，新增行和下拉框不能遮挡保存/取消。
6. 检查目标代码缺失或变化、其他 Mod 修改同一函数、无效偏好及不可写目录；查看诊断信息，确认出错后自动订单不会悄悄沿用界面显示的偏好。
7. 在窗口打开、选项未保存时反复重载，确认只有一个选择框、没有重复 Hook/定时器、恢复已保存偏好且原生订单继续；另在切换餐厅途中、房主/客户端以及自动订单即将触发时重载。

### 加载器、打包与诊断

- 构建生成 `outputs/smart-delivery/SmartDelivery-0.1.6.zip` 及 SHA-256 文件。构建不安装 Mod、不启停游戏，也不修改存档。
- 编译出的 `Scripts/delivery_bridge.dll` 由 Lua 加载，不放入 UE4SS 的 `dlls` 目录。
- 偏好文件为 `Scripts/delivery-preference.txt`，初始后备选择为高级配送。
- 关闭游戏升级后，在 `UE4SS.log` 中核对 `[SmartDelivery] START version=0.1.6` 和 `UI attached to automatic-order settings`。
- 保留该日志中的原始启动错误：后续清理可能把 `Scripts/bridge-status.txt` 改为 `disabled`。

### 手动脚本重载

0.1.4-dev 更新了辅助模块，首次升级到该版本须关闭游戏并替换完整安装包。之后仅更新 Lua 文件时，可按[统一重载配置](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/smart-delivery-v0.1.5/docs/hot-reload.md#中文)设置加载器，复制全部更新脚本后按 **Ctrl+R**。

重载会放弃未保存的选项，新状态在游戏线程刷新时移除旧选择框并恢复已保存偏好；重载间隙中，原生自动订购按数量选择配送。更换 `delivery_bridge.dll`、更新 UE4SS 或卸载 Mod，均须重启游戏。
