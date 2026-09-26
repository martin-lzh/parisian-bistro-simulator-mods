# Auto Menu development / 开发

[English](#english) · [中文](#中文)

## English

**0.5.0-dev, pending in-game acceptance.** Independent Lua Mod with an original Windows x64 helper. Local interfaces were checked on Steam Build 25532071 / ProjectVersion 1.0.1.44eb and UE4SS experimental `v3.0.1-1140-gf58e8f84`. All game references and native analysis remain in ignored `work/`.

### Implementation

- `game.lua` collects selector IDs intersected with `AvailableDishes`, excluding disabled, unstaffed and wrong-course entries. Every course includes zero. Eligible current choices lead, followed by ascending IDs. `planner.lua` holds the course metadata and menu-copy operation.
- `bridge.lua` loads `auto_menu_bridge.dll` through `package.loadlib`. One synchronous request/result exchange passes object/property addresses, the original menu, native baseline rate, ceiling and domains. No Lua ABI internals or second Lua runtime are used. The pointer request is removed after invocation, previous results are cleared before it, and returned IDs must belong to the supplied domains. No per-candidate disk I/O occurs.
- `Native/search.hpp` enumerates the complete product, including empty menus. Only strict improvements replace the winner; exact equality with the native ceiling permits early exit. It never applies a heuristic, rounded percentage or independent-course ranking.
- `Native/contract.hpp` discovers the named native projection registration and checks the supported x64 instructions, return ownership, menu storage and five single-dish scoring call sites. Targets are derived from the installed executable, without fixed game RVAs or an executable hash allowlist. Unsupported layouts and pre-existing modifications are rejected before installation.
- `Native/bridge.cpp` redirects those five calls to an original adapter. A pinned DLL and nearby leaf jump remain until process exit. Outside a search, including other threads, calls forward to the original function. During one synchronous game-thread search, a scoped cache reuses original float scores by dish, profile and intent for the same manager. Personal preferences and unknown enum values bypass caching. The cache is discarded after each click; menu-specific compatibility, ingredient filtering, weather/event effects, promotion, float accumulation and native caps still execute in the game's complete projection.
- Enumeration and native projection calls stay inside the DLL, avoiding per-candidate Lua writes and conversion of the returned projection/profile arrays. Native-owned return arrays are released through the matching engine allocator. This version still performs the projection's display-only calculations; it does not claim an adoption-only API.
- Before trials, the direct native projection must match the Lua baseline bit-for-bit. Domains with at most 243 combinations compare each visited candidate with caching disabled; larger domains compare the first 32. Every winner is checked again with caching disabled. A mismatch aborts. The native scope restores all seven menu bytes on success or C++ exceptions; Lua also restores the original definition before saving the winner once and refreshing. These checks do not recover from arbitrary process crashes.

Prices, dish data, weather and events are stable during the synchronous call on the game thread. No cache persists across clicks or Lua reload. DLL updates require restarting the game. Search remains exponential and can pause gameplay on large catalogues. Small-domain differential checks deliberately add extra projections. A final-winner check alone is not proof of global equivalence; the cache contract and exhaustive small-domain comparisons are also required. Real engine acceptance is pending.

### Timing logs

Four lines per successful composition:

| Line | Meaning |
| --- | --- |
| `SEARCH` | Period, eligible counts including empty, full product, Lua clock |
| `COMPOSED` | Version, exact native rate, candidate evaluations, total seconds |
| `TIMING_PARTS` | Setup, search/bridge, restoration, save, verification, refresh and residual Lua work; milliseconds and shares |
| `NATIVE` | Native search milliseconds, cache hits/misses/bypasses, cached-versus-uncached checks, stopping reason |

`TIMING_PARTS.search` includes DLL loading/discovery on first use, request I/O, the baseline, native enumeration and result decoding. `NATIVE.search_ms` uses a monotonic native clock and includes enumeration, differential checks, winner verification and restoration, excluding initialization and the baseline. It is an inclusive subtotal, not another share. Candidate evaluations exclude diagnostic projections. `checks` excludes the initial Lua/native baseline comparison. Cache misses count original single-dish calls retained for reuse; bypasses include the uncached checks. Full original projections still build their own UI data, so cache statistics are not a direct measure of saved wall time. Lua `os.clock` has limited resolution; zero milliseconds does not imply zero cost. There are no per-candidate logs, progress UI or search timers.

### Build and verification

Windows x64 with MSVC C++ Build Tools and the Windows SDK:

```powershell
uv run --with lupa==2.6 python auto-menu-mod/tests/run.py
python auto-menu-mod/build.py
python tools/check_repository.py
python tools/check_syntax.py
python -m unittest discover -s tools/tests -v
git diff --check
```

The build runs native tests before packaging. Six Lua suites check request serialization/cleanup, fresh results, eligible domains, host restrictions, final save/restoration, logs, language and reload behavior. The native harness checks every supported dish/profile/intent cache key, cache lifetime and thread isolation, exhaustive non-additive search, empty menus, ties, exact ceilings, float comparisons, synthetic full-projection differential checks, native array ownership and restoration on failures. A non-game executable must be rejected before patching. Local native discovery is also checked read-only against the installed reference executable; that does not execute the game functions or establish in-game speed.

Build output: `outputs/auto-menu/AutoMenu-0.5.0-dev.zip` and SHA-256. The allowlist contains seven Lua modules, one generated helper DLL, README, DEVELOPMENT, CHANGELOG and the activation marker. CI verifies the generated DLL hash. Source, tests, request/result files, tools and game references are excluded. Builds do not install, modify saves, start/stop the game or publish a release.

### In-game checks

1. Restart after installing the new DLL. Test both services with small domains and confirm every visited menu passes the cached/uncached checks, including empty menus, absent main dishes, missing ingredients and promotion.
2. Change prices, weather/events and enabled/staffed choices between clicks; confirm each search rebuilds its cache and the native forecast agrees with the chosen rate.
3. Repeat the larger catalogue used with 0.4.1-dev. Compare native time, cache misses/hits, checks and candidate counts. Do not infer a measured speedup from offline test duration.
4. Confirm one final save, the other service untouched, native empty-menu deactivation, host-only behavior, one localized button and repeated Lua reload. Removing/updating the DLL requires game exit.

## 中文

**0.5.0-dev，待实机验收。** 独立 Lua Mod，新增原创 Windows x64 辅助模块。本机接口核对版本为 Steam Build 25532071 / ProjectVersion 1.0.1.44eb、UE4SS experimental `v3.0.1-1140-gf58e8f84`。游戏参考和原生分析全部留在被忽略的 `work/`。

### 实现

- Lua 仍负责按钮、候选资格过滤和最终保存。每类包含留空；符合条件的当前选项优先，其余编号升序。通过一次同步请求将对象／属性地址、原菜单、原生基准选择率、上限和候选传入 DLL；调用后删除含地址的请求文件，调用前清除旧结果。不逐组合读写文件，也不依赖 Lua ABI 内部结构。
- DLL 完整枚举全部组合，严格比较原生浮点数，同值保留首个组合；只有精确达到原生上限才提前停止。无需贪心、近似分数或预先固化的菜单排名。
- 从游戏的原生函数注册名发现调用目标，核对调用布局、返回数组归属、菜单存储和五处单菜评分调用。不能识别或已被其他模块修改时停止，不写入固定游戏地址，也不强制匹配整个 EXE 哈希。
- 五处调用转至原创适配器；DLL 和跳转保持到进程退出。只在本次游戏线程搜索内，按同一餐厅、菜品、顾客类型和用餐意图缓存原生分数。个体偏好、未知枚举值以及其他线程直接执行原函数；搜索之外也直接转发。每次点击重新建立缓存，价格、天气和活动不会沿用上次结果。
- 每份菜单仍调用游戏完整预测，保留食材过滤、菜单组合规则、原生浮点运算和各种上限，也仍计算展示字段。枚举在 DLL 内进行，去掉逐组合 Lua 属性写入和整个预测结果转成 Lua 表的开销；原生返回数组由匹配的引擎释放函数回收。此版本不是单独的“只算选择率”接口。
- 开始前对照 Lua 与直接原生调用的基准值；最多 243 个组合时逐个关闭缓存复算，较大搜索检查前 32 个，每次都关闭缓存复核最终菜单。逐位不一致就中止。正常结束或 C++ 异常时恢复七字节原菜单；Lua 也会恢复，再调用原生保存一次并刷新。任意进程崩溃不属于可恢复异常。

搜索同步运行，期间价格、菜品、天气和活动不随游戏帧更新。缓存不跨点击或 Lua 重载保留；更新 DLL 必须重启游戏。组合数仍呈乘积增长，大菜单可能让游戏等待；小菜单的逐项对照会额外调用预测。仅复核最佳菜单不能单独证明全局等价，仍需缓存输入契约和完整的小规模对照。真实引擎验收尚未完成。

### 计时日志

成功时四行：`SEARCH` 记录餐段、含空选项的候选数和组合数；`COMPOSED` 记录版本、选择率、试算次数及总秒数；`TIMING_PARTS` 记录准备、搜索／桥接、恢复、保存、保存核对、刷新和其余 Lua 开销的毫秒数与占比；`NATIVE` 记录原生搜索毫秒数、缓存命中／未命中／绕过次数、对照检查数和结束原因。

Lua 的 `search` 包括首次 DLL 加载／定位、文件交换、基准预测、原生枚举及结果解析；原生单调时钟的 `search_ms` 只覆盖枚举、对照、最佳菜单复核和恢复，不含初始化及基准值。这是子合计，不能再次加入阶段占比。试算次数不含诊断预测；`checks` 不含开始时的 Lua／原生基准对照，`bypasses` 包括关闭缓存的检查。缓存命中数不能直接当作耗时减少比例。Lua `os.clock` 精度有限，零毫秒不表示没有开销。不显示进度，也不加入搜索定时器或逐组合日志。

### 构建与验证

使用 Windows x64、MSVC C++ Build Tools 和 Windows SDK，执行英文部分命令。六组 Lua 测试覆盖协议、候选、恢复／保存、计时、多语言和重载；原生测试覆盖全部支持的缓存键、线程与搜索隔离、非加性完整枚举、空菜单、同值／上限、逐位浮点比较、合成预测的逐组合缓存对照、原生数组释放及异常恢复。构建还验证非游戏 EXE 被拒绝。本机已只读核对参考 EXE 的目标发现；这不代表已执行真实游戏函数或测得提速。

产物为 `outputs/auto-menu/AutoMenu-0.5.0-dev.zip` 和 SHA-256。固定白名单只含七个 Lua 模块、一个编译生成的 DLL、三份文档及启用标记，CI 核对 DLL 哈希；不包含源码、测试、交换文件、工具或游戏参考。构建不安装、不改存档、不启停游戏，也不发布版本。

### 实机检查

1. 安装 DLL 后重启，午餐／晚餐分别用少量候选测试逐组合对照，涵盖全空、无主菜、缺料和推广影响。
2. 两次点击之间改变菜价、天气／活动和启用／员工条件，核对重新建立缓存及最终原生预测。
3. 使用与 0.4.1-dev 相同的大菜单条件比较原生耗时、缓存计数、检查数和组合数；不把离线测试时长当作实机提速。
4. 核对只保存一次、另一餐段不变、空菜单原生停用、房主限制、单按钮、多语言和反复 Lua 重载。更新或卸载 DLL 必须退出游戏。
