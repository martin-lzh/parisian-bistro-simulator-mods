# Auto Menu development / 菜单巧配开发

[English](#english) · [中文](#中文)

## English

Auto Menu is an independent Lua Mod with an original Windows x64 helper DLL.

- Current version: **0.5.1**, supporting **Steam Build 25822788 / 1.0.2.44eb**.
- **0.5.1 test status:** compared with 0.5.0, 0.5.1 changes only the license (PolyForm Noncommercial 1.0.0), the documentation and the version number; gameplay code is unchanged. In-game testing of 0.5.1 was waived by the maintainer on 2026-10-19 because gameplay code is unchanged.
- Development reference build: Steam Build 25532071 / ProjectVersion 1.0.1.44eb.
- Loader: UE4SS experimental `v3.0.1-1140-gf58e8f84`.

All game references and native analysis stay in ignored `work/`.

### Implementation

#### Lua

- `game.lua` collects selector IDs intersected with `AvailableDishes`, excluding disabled, unstaffed and wrong-course entries. Every course includes zero (empty). Eligible current choices come first, then ascending IDs.
- `planner.lua` holds the course metadata and the menu-copy operation.
- `bridge.lua` loads `auto_menu_bridge.dll` through `package.loadlib`. One synchronous request/result exchange passes object/property addresses, the original menu, the native baseline rate, the ceiling and the domains.
  - No Lua ABI internals or second Lua runtime are used.
  - Previous results are cleared before the call; the pointer request is removed after it.
  - Returned IDs must belong to the supplied domains.
  - No per-candidate disk I/O.

#### Native helper

- `Native/search.hpp` enumerates the complete product, including empty menus. Only strict improvements replace the winner; exact equality with the native ceiling allows early exit. No heuristics, rounded percentages or independent per-course ranking.
- `Native/contract.hpp` discovers the named native projection registration and checks the supported x64 instructions, return ownership, menu storage and the five single-dish scoring call sites. Targets come from the installed executable, without fixed game RVAs or an executable hash allowlist. Unsupported layouts and pre-existing modifications are rejected before installation.
- `Native/bridge.cpp` redirects those five calls to an original adapter. The pinned DLL and a nearby leaf jump stay until process exit.
  - Outside a search, and on other threads, calls forward to the original function.
  - During one synchronous game-thread search, a scoped cache reuses original float scores by dish, profile and intent for the same manager. Personal preferences and unknown enum values bypass the cache.
  - The cache is discarded after each click. Menu-specific compatibility, ingredient filtering, weather/event effects, promotion, float accumulation and native caps still run in the game's complete projection.
- Enumeration and projection calls stay inside the DLL, so there are no per-candidate Lua writes and no conversion of the returned projection/profile arrays. Native-owned return arrays are released through the matching engine allocator.
- The projection still performs its display-only calculations; this is not an adoption-only API.

#### Checks and restoration

- Before trials, the direct native projection must match the Lua baseline bit-for-bit.
- Domains of at most 243 combinations compare every visited candidate with caching disabled; larger domains compare the first 32. Every winner is checked again with caching disabled. Any mismatch aborts.
- The native scope restores all seven menu bytes on success or C++ exceptions. Lua also restores the original definition, then saves the winner once and refreshes. A process crash cannot be recovered.

#### Constraints

- Prices, dish data, weather and events stay fixed during the synchronous call on the game thread.
- No cache survives across clicks or Lua reload. DLL updates require restarting the game.
- Search is exponential and can pause gameplay on large catalogues. Small-domain differential checks add extra projections.
- Correctness relies on the cache contract plus exhaustive small-domain comparisons; the final-winner check alone is not enough.

### Timing logs

Each successful composition writes four lines:

| Line | Meaning |
| --- | --- |
| `SEARCH` | Period, eligible counts including empty, full product, Lua clock |
| `COMPOSED` | Version, exact native rate, candidate evaluations, total seconds |
| `TIMING_PARTS` | Setup, search/bridge, restoration, save, verification, refresh and residual Lua work; milliseconds and shares |
| `NATIVE` | Native search milliseconds, cache hits/misses/bypasses, cached-versus-uncached checks, stopping reason |

- `TIMING_PARTS.search` covers DLL loading/discovery on first use, request I/O, the baseline, native enumeration and result decoding.
- `NATIVE.search_ms` uses a monotonic native clock and covers enumeration, differential checks, winner verification and restoration, excluding initialization and the baseline. It is an inclusive subtotal, not another share.
- Candidate evaluations exclude diagnostic projections. `checks` excludes the initial Lua/native baseline comparison.
- Cache misses count original single-dish calls kept for reuse; bypasses include the uncached checks. Full projections still build their own UI data, so cache statistics don't directly measure saved time.
- Lua `os.clock` has limited resolution, so 0 ms can still mean some cost.
- No per-candidate logs, progress UI or search timers.

### Build and verification

Requires Windows x64 with MSVC C++ Build Tools and the Windows SDK:

```powershell
uv run --with lupa==2.6 python auto-menu-mod/tests/run.py
python auto-menu-mod/build.py
python tools/check_repository.py
python tools/check_syntax.py
python -m unittest discover -s tools/tests -v
git diff --check
```

The build runs the native tests before packaging.

- **Lua (six suites):** request serialization/cleanup, fresh results, eligible domains, host restrictions, final save/restoration, logs, language and reload.
- **Native harness:** every supported dish/profile/intent cache key, cache lifetime and thread isolation, exhaustive non-additive search, empty menus, ties, exact ceilings, float comparisons, synthetic full-projection differential checks, native array ownership and restoration on failure. A non-game executable must be rejected before patching.
- **Native discovery** is also checked read-only against the local reference executable.

Build output: `outputs/auto-menu/AutoMenu-0.5.1.zip` and its SHA-256.

- The package allowlist contains seven Lua modules, one generated helper DLL, README, DEVELOPMENT, CHANGELOG, LICENSE and the activation marker. CI verifies the generated DLL hash.
- Source, tests, request/result files, tools and game references are excluded.

### In-game checks

1. Restart after installing a new DLL. Test both services with small domains and confirm every visited menu passes the cached/uncached checks, including empty menus, absent main dishes, missing ingredients and promotion.
2. Change prices, weather/events and enabled/staffed choices between clicks. Confirm each search rebuilds its cache and the native forecast matches the chosen rate.
3. Repeat the larger catalogue used with 0.4.1-dev. Compare native time, cache misses/hits, checks and candidate counts.
4. Confirm one final save, the other service untouched, native empty-menu deactivation, host-only behaviour, one localized button and repeated Lua reload. Removing or updating the DLL requires exiting the game.

### Manual script reload

First installation and helper updates need the game closed and the complete package installed.

For later Lua-only updates, follow the [shared reload configuration](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-menu-v0.5.0/docs/hot-reload.md#english), replace every updated Lua file, then press **Ctrl+R**. The reloaded state removes the old button before attaching one replacement. The search cache does not survive reload.

- Lua reload cannot replace `Scripts/auto_menu_bridge.dll`. Restart the game for DLL changes, loader updates or Mod removal.
- A refused native save is not retried automatically.
- The `[AutoMenu]` diagnostic and timing lines above describe each attempt, without per-candidate logs.

## 中文

菜单巧配是独立的 Lua Mod，附带原创 Windows x64 辅助 DLL。

- 当前版本：**0.5.1**，支持至 **Steam Build 25822788 / 1.0.2.44eb**。
- **0.5.1 测试状态：**与 0.5.0 相比，0.5.1 只更改许可（PolyForm Noncommercial 1.0.0）、文档和版本号，玩法代码不变。维护者于 2026-10-19 以玩法代码未改为由免除 0.5.1 的实机测试。
- 开发参考版本：Steam Build 25532071 / ProjectVersion 1.0.1.44eb。
- 加载器：UE4SS experimental `v3.0.1-1140-gf58e8f84`。

游戏参考资料和原生分析全部放在被忽略的 `work/`。

### 实现

#### Lua

- `game.lua` 取选择器编号与 `AvailableDishes` 的交集，排除已停用、员工条件不满足和类别不符的菜品。每类都包含 0（留空）。符合条件的当前选项排在最前，其余按编号升序。
- `planner.lua` 保存类别元数据和菜单复制操作。
- `bridge.lua` 通过 `package.loadlib` 加载 `auto_menu_bridge.dll`。一次同步请求／结果交换传入对象／属性地址、原菜单、原生基准选择率、上限和各类候选。
  - 不依赖 Lua ABI 内部结构，也不使用第二个 Lua 运行时。
  - 调用前清除旧结果，调用后删除含地址的请求。
  - 返回的编号必须属于传入的候选。
  - 不逐组合读写文件。

#### 原生辅助模块

- `Native/search.hpp` 完整枚举全部组合（含空菜单）。只有严格更优才替换当前最佳，精确达到原生上限才提前结束。不使用贪心、取整百分比或按类别独立排名。
- `Native/contract.hpp` 根据游戏原生预测函数的注册名找到调用目标，核对支持的 x64 指令、返回数组归属、菜单存储和五处单菜评分调用。目标从已安装的 EXE 中推导，不写死游戏 RVA，也不要求 EXE 哈希匹配。布局不支持或已被其他模块修改时，在安装前拒绝。
- `Native/bridge.cpp` 把这五处调用转到原创适配器；固定的 DLL 和附近的跳转保留到进程退出。
  - 搜索之外以及其他线程上，调用直接转发给原函数。
  - 在一次同步的游戏线程搜索内，按同一餐厅管理器、菜品、顾客类型和用餐意图缓存原始浮点评分。个体偏好和未知枚举值不走缓存。
  - 每次点击后丢弃缓存。菜单组合适配度、食材过滤、天气／活动、推广、浮点累加和原生上限仍在游戏完整预测中计算。
- 枚举和预测调用都在 DLL 内完成，因此没有逐组合的 Lua 属性写入，也不把返回的预测／顾客数组转成 Lua 表。原生返回数组由匹配的引擎释放函数回收。
- 预测仍会计算仅用于显示的字段；这不是只算选择率的接口。

#### 核对与恢复

- 试算前，直接原生预测必须与 Lua 基准值逐位一致。
- 最多 243 个组合时，逐个关闭缓存复算每个访问到的组合；更大的搜索只对照前 32 个。每次都关闭缓存复核最终菜单。任何不一致都会中止。
- 正常结束或发生 C++ 异常时，原生作用域恢复七字节原菜单；Lua 也会恢复原菜单，再保存最终结果一次并刷新。进程崩溃无法恢复。

#### 约束

- 同步调用在游戏线程上进行，期间价格、菜品数据、天气和活动保持不变。
- 缓存不跨点击或 Lua 重载保留；更新 DLL 须重启游戏。
- 组合数按乘积增长，菜品很多时可能让游戏停顿；小规模逐项对照会额外调用预测。
- 正确性依赖缓存输入契约和完整的小规模对照，仅复核最终菜单不够。

### 计时日志

每次成功组合输出四行：

| 行 | 内容 |
| --- | --- |
| `SEARCH` | 餐段、含留空的候选数、全部组合数、Lua 时钟 |
| `COMPOSED` | 版本、精确原生选择率、试算次数、总秒数 |
| `TIMING_PARTS` | 准备、搜索／桥接、恢复、保存、保存核对、刷新和其余 Lua 开销的毫秒数与占比 |
| `NATIVE` | 原生搜索毫秒数、缓存命中／未命中／绕过次数、缓存与非缓存对照次数、结束原因 |

- `TIMING_PARTS.search` 包括首次 DLL 加载／定位、请求读写、基准预测、原生枚举和结果解析。
- `NATIVE.search_ms` 使用原生单调时钟，覆盖枚举、对照、最终菜单复核和恢复，不含初始化和基准值。它是包含关系的子合计，不能再算进占比。
- 试算次数不含诊断预测；`checks` 不含开始时的 Lua／原生基准对照。
- 未命中次数统计为复用而保留的原始单菜调用；绕过次数包含关闭缓存的对照。完整预测仍会生成自己的界面数据，所以缓存统计不能直接换算为节省的时间。
- Lua `os.clock` 精度有限，0 毫秒不代表没有开销。
- 没有逐组合日志、进度界面或搜索定时器。

### 构建与验证

需要 Windows x64、MSVC C++ Build Tools 和 Windows SDK：

```powershell
uv run --with lupa==2.6 python auto-menu-mod/tests/run.py
python auto-menu-mod/build.py
python tools/check_repository.py
python tools/check_syntax.py
python -m unittest discover -s tools/tests -v
git diff --check
```

构建会在打包前运行原生测试。

- **Lua（六组）：**请求序列化／清理、新结果、候选资格、房主限制、最终保存／恢复、日志、语言和重载。
- **原生测试：**全部支持的菜品／顾客类型／用餐意图缓存键、缓存生命周期和线程隔离、非加性完整枚举、空菜单、同分、精确上限、浮点比较、合成完整预测的逐组合缓存对照、原生数组归属以及失败时的恢复。非游戏 EXE 必须在打补丁前被拒绝。
- **原生目标发现**另外以只读方式对照本机参考 EXE 核对。

构建产物：`outputs/auto-menu/AutoMenu-0.5.1.zip` 及其 SHA-256。

- 打包白名单只含七个 Lua 模块、一个编译生成的辅助 DLL、README、DEVELOPMENT、CHANGELOG、LICENSE 和启用标记。CI 核对生成 DLL 的哈希。
- 不包含源码、测试、请求／结果文件、工具或游戏参考资料。

### 实机检查

1. 安装新 DLL 后重启游戏。午餐、晚餐分别用少量候选测试，确认每个访问到的菜单都通过缓存／非缓存对照，涵盖空菜单、无主菜、缺食材和推广影响。
2. 两次点击之间改变价格、天气／活动和启用／员工条件，确认每次搜索都重建缓存，且原生预测与选中的选择率一致。
3. 用 0.4.1-dev 时的大菜单条件再测一次，比较原生耗时、缓存命中／未命中、对照次数和组合数。
4. 确认只保存一次、另一餐段不变、空菜单由原生逻辑停用、房主限制、只有一个本地化按钮，以及反复 Lua 重载正常。更新或移除 DLL 必须退出游戏。

### 手动脚本重载

首次安装和辅助模块更新须关闭游戏，安装完整包。

之后只更新 Lua 文件时，按[统一重载配置](https://github.com/martin-lzh/parisian-bistro-simulator-mods/blob/auto-menu-v0.5.0/docs/hot-reload.md#中文)设置加载器，替换全部更新的脚本，再按 **Ctrl+R**。重载后先移除旧按钮，再挂接一个新按钮；搜索缓存不跨重载保留。

- Lua 重载不能替换 `Scripts/auto_menu_bridge.dll`。DLL 变更、加载器更新或卸载 Mod 都须重启游戏。
- 原生保存被拒绝后不会自动重试。
- `[AutoMenu]` 诊断和计时日志见上文，不逐组合输出。
