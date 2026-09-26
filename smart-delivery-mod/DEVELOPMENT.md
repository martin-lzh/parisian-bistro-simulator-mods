# Smart Delivery development / 开发说明

[English](#english) · [中文](#中文)

## English

Smart Delivery adds one UMG selector to the existing automatic smart-order dialog. It reads the three native delivery labels at runtime, uses the dialog font and explicit white dropdown text, preserves the Save/Cancel footer and resets unsaved changes whenever the native settings are repopulated. Only a local authoritative owner can change the preference. The preference is installation-wide and lives outside game saves.

The automatic-order evaluator is called by native timers and delegates and overwrites the shipping fee before checking affordability. A reflected `OrderIngredients` hook alone cannot intercept those direct calls. The original Windows helper changes only delivery selection within that evaluator. Native list generation, thresholds, availability, money checks, night fees, staff assignment and the eventual order remain intact, including calls made immediately when settings are saved. Manual order paths are outside the hook.

The helper resolves the evaluator and three fee getters through native registration names in the installed PE image. Chained x64 unwind records bound the evaluator; instruction operands identify the quantity branch, native coefficients and common difficulty getter. Addresses and the quantity threshold come from this discovery. It has no build-number, fixed executable-size or SHA-256 allowlist. Missing or ambiguous targets and changed instruction structure stop initialization. Before installing a game-thread jump, it compares the loaded evaluator and fee getters with the current file to detect conflicting modifications. The dispatch preserves registers, reads the live free-service coefficient and resumes the native budget/premium branches. No extracted bytes, game assets, UE4SS binaries, SDK dumps or third-party hook libraries are bundled. Research and detailed compatibility evidence stay in ignored `work/`.

The free-service coefficient is writable runtime data in the zero-filled tail of a PE section. Validate its mapped section bounds and permissions, preserving its live value; do not require file bytes or compare it with disk contents. The 0.1.0-dev file lookup incorrectly rejected this valid address during initialization. Synthetic PE regression tests cover this distinction, section boundaries, overflow and truncated files.

Lua loads named C entry points through `package.loadlib`; they accept no arguments, return no Lua values and access no Lua ABI structures. Game-thread operations write a fresh status acknowledgment. Lua failures on the game thread disable the preference and request restoration of the original instruction; a conflicting later patch is never overwritten. The helper is pinned until process exit.

Lua reload is supported from 0.1.4-dev. `ModRef.OnUnload` stops the old closures and calls `delivery_suspend`, whose only effect is `InterlockedExchange(selected, -1)`. It performs no UObject access, code patch, file operation or deferred callback. The resident dispatch then uses its verified native quantity threshold. The new state's game-thread startup resolves shared widget identity strings, removes old selector rows, verifies that the installed jump still belongs to this helper, and reapplies the saved preference. The installed trampoline is reused without allocating another one. Shared variables never contain transient UObjects or callbacks. A changed native DLL, loader replacement or Mod removal requires restarting the game.

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

The build requires Windows x64, MSVC C++ and MASM, and the Windows SDK. Compiler warnings are errors. The native executable harness exercises the generated dispatch code for every delivery mode, default routing, order-size boundaries, difficulty factors and register preservation. Synthetic PE fixtures cover moved code/data, different image bases, unrelated file changes, duplicate targets, changed operands, malformed unwind records, code conflicts and live fee data. Dispatch tests include discovered quantity thresholds of 4 and 7. A separate process verifies that an unrelated executable with no delivery registrations is rejected. Native discovery was also checked read-only against the installed Steam Build 25532071; detailed evidence remains in `work/smart-delivery-research/build-25532071/`. Lua tests cover preference parsing, recovery, Save/Cancel, host isolation and UI behavior. CI compares source files byte-for-byte and verifies the explicitly allowed generated DLL against build hashes; release verification uses the commit-bound CI evidence.

### In-game regression checklist

The user reported completion of in-game testing for 0.1.4-dev on 2026-09-26; see the [validation record](../releases/validation.md#english). These scenarios remain regression references; individual results were not reported separately.

1. For each delivery option, save settings, reopen the dialog, restart the game and verify the choice. Cancel a different choice and verify the saved choice survives, including rapid close/reopen.
2. Trigger small and large automatic orders. Compare service fees, full amount charged and arriving unloaders: 0 / 1 / 4. Repeat on different difficulty levels and at night.
3. Test stockout override below the amount threshold, insufficient funds, an ongoing delivery, automatic ordering disabled, and saving settings while an order becomes eligible. Ensure exactly one order.
4. Verify manual ingredient and furniture delivery options remain independent; switch restaurants, return to the menu and reconnect as host/client.
5. Check all 14 languages, keyboard/gamepad navigation, narrow resolutions and large UI scale. Verify the new row and dropdown do not cover Save/Cancel.
6. Check missing or changed target code, another Mod changing the same routine, invalid preferences and an unwritable Mod directory. Review diagnostics and ensure automatic orders do not silently use the displayed preference after an error.
7. Reload repeatedly with the dialog open and with an unsaved selection. Confirm one selector, no duplicate hooks/timers, restored saved preference and continued native orders. Test reload during travel, on host/client, and while an automatic order becomes eligible. Offline tests exercise worker-thread suspension, patch reuse/conflict refusal, old callback guards, primitive-only widget cleanup and Save/Cancel recovery; they do not establish real engine timing.

Offline results do not establish engine bridging, layout, multiplayer or real transaction correctness. The user-reported in-game testing is recorded separately above.

## 中文

在原有自动智能订购窗口中增加一个 UMG 配送选择框，运行时读取原生配送名称并沿用窗口字体，下拉框使用明确的白色文字，保留底部保存/取消按钮；每次重新填充原生设置时恢复已保存选择。仅本地房主能修改偏好；偏好由同一安装下的餐厅共用，保存在游戏存档之外。

自动订购通过原生定时器和委托执行，在余额检查前覆盖配送费；只拦截反射的 `OrderIngredients` 无法截获这些直接调用。原创 Windows 辅助模块仅改变该执行过程中的配送选择。采购清单、下限、可用性、余额检查、夜间费用、配送人数与实际下单继续走游戏原逻辑，包括保存设置时立即触发的订购；手动订单不经过该修改。

辅助模块从当前 PE 文件的原生注册名称定位执行函数和三种费用查询函数，通过 x64 链式展开记录确定函数边界，并核对数量分支、费用系数和共同的难度倍率查询。地址与数量阈值均来自定位结果，不使用游戏构建号、EXE 固定大小或 SHA-256 白名单。目标缺失、重复或指令结构不符时停止初始化；安装跳转前比较内存中的执行函数和费用查询函数与当前文件，以检测冲突修改。分派代码保留寄存器，读取实时免费服务系数，并使用游戏经济型/高级配送分支。安装包不含游戏字节、游戏资产、UE4SS 二进制、SDK 导出或第三方 Hook 库；研究和详细兼容性证据仅保存在被忽略的 `work/`。

免费服务系数是 PE 节区零填充尾部的可写运行时数据，应核验映射后的范围与权限并保留实时值，不要求它具有文件字节，也不与磁盘内容比较。0.1.0-dev 错误地按文件范围查找，导致初始化拒绝合法地址。新增原创合成 PE 回归用例覆盖这一差异、节区边界、溢出及文件截断。

Lua 通过 `package.loadlib` 加载具名 C 入口；入口无参数、无 Lua 返回值，也不访问 Lua ABI 内部结构，游戏线程操作写入新的状态回执。游戏线程上的 Lua 出错时停用偏好并请求恢复原指令；若之后有其他补丁覆盖此处，则不强行覆盖它。辅助模块固定保留到进程结束。

0.1.4-dev 支持 Lua 热重载。`ModRef.OnUnload` 仅停止旧闭包并调用 `delivery_suspend`；该入口只执行 `InterlockedExchange(selected, -1)`，不访问 UObject、不修改代码、不写文件，也不安排延迟回调。驻留分派随即采用已核验的原生数量阈值。新状态在游戏线程按共享身份字符串重新查找并清理旧选择框，检查跳转仍属于本模块，再恢复已保存偏好，复用原跳板而不重复分配。共享变量不包含临时 UObject 或回调。更换 DLL、加载器或卸载 Mod 仍需重启游戏。

### 离线验证

命令见上方。构建需要 Windows x64、MSVC C++/MASM 和 Windows SDK，编译警告按错误处理。原生测试程序直接执行生成的分派代码，覆盖配送方式、默认分支、订单数量边界、难度倍率及寄存器保留；合成 PE 用例覆盖代码与数据移动、不同映像基址、无关文件变化、目标重复、操作数变化、异常展开记录、代码冲突及实时费用数据；分派执行用例覆盖动态取得的 4 和 7 两种数量阈值。另用独立进程确认不含配送注册信息的程序被拒绝。已对本机 Steam Build 25532071 只读核对原生定位结果，详细证据保存在 `work/smart-delivery-research/build-25532071/`。Lua 测试覆盖偏好解析、恢复、保存/取消、房主范围及界面行为。CI 逐字节核对源码文件，并对显式允许的原创 DLL 核验构建哈希；发布校验使用绑定提交的 CI 证据。

### 实机回归清单

用户于 2026-09-26 反馈实机测试完成，本次关联 0.1.4-dev，见[验收记录](../releases/validation.md#中文)。以下场景保留作为回归参考，未单独反馈逐项结果。

逐项检查三种配送的保存、重新打开、重启保留及取消恢复；小额/大额、不同难度和夜间订单的费用与 0/1/4 名卸货员；缺货优先、采购下限、余额不足、配送进行中、关闭自动订购及保存时立即触发的行为，确认不重复下单。确认手动食材/家具采购独立，切换餐厅、返回菜单及房主/客户端重连正常。检查 14 种语言、键盘/手柄、窄分辨率和大 UI 缩放。检查目标代码缺失或变化、冲突 Mod、无效配置及不可写目录的诊断与停用行为。

新增离线测试覆盖工作线程原子暂停、跳板复用和冲突拒绝、旧回调停止、字符串控件身份清理和保存偏好恢复。实机需在窗口打开、选项未保存、切换餐厅、联机和自动订单即将触发时连续重载，确认单一选择框且无重复 Hook/定时器。

离线检查不代表引擎桥接、界面布局、联机或真实扣款验收通过；用户实机测试反馈单独记录于上文。
