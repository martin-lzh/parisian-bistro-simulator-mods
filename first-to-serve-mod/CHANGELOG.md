# Changelog

## Unreleased

## 0.1.7 - 2026-09-26

### Documentation update / 文档更新 — 2026-09-26

- Expand the English/Chinese player guide after a source-based subagent audit of in-game controls, feature behavior, multiplayer requirements and waiting/recovery conditions. Refresh the existing Release package documentation; the version and runtime files are unchanged.
- 经 subagent 对照源码审计，补全中英文游戏内操作、功能行为、联机要求及等待／恢复条件。更新现有 Release 包内文档，版本与运行文件保持不变。

### English

- Promote 0.1.7-dev to 0.1.7 after the maintainer confirmed that all current Mods passed in-game and multiplayer testing and explicitly authorized stable publication on 2026-09-26. Retain the tested gameplay logic; update version identifiers, package names and release documentation.
- Hold at kitchen passes or drink output surfaces to collect the oldest ready items with trays or food trolleys; retain native short-click behavior, localized hints and language-failure recovery.
- Include kitchen/drink-area screenshots and a 5.13 MiB gameplay GIF with its complete 4.48-second duration.
- Include English/Chinese installation, usage and update guides, the MIT license, and verified package contents. Documentation images remain outside the installable ZIP.

### 中文

- 维护者于 2026-09-26 确认全部当前 Mod 实机及联机测试通过，并明确授权发布正式版，据此将 0.1.7-dev 转为 0.1.7；保留已测试的玩法逻辑，更新版本标识、包名和发布说明。
- 持托盘或餐车在出餐口、饮料出品台长按，按完成先后拿取成品；保留原生短按、本地化提示及语言读取失败恢复。
- 附上出餐口与饮料出品台截图，以及保留完整 4.48 秒时长的 5.13 MiB 实机 GIF。
- 附上中英文安装、使用、更新说明及 MIT 许可，并校验包内容；文档图片不进入安装 ZIP。

## 0.1.7-dev

- Compress the gameplay GIF from 81.05 MiB to 5.13 MiB using 960 × 600 frames, approximately 6.25 fps and a 96-color palette; retain the full 4.48-second recording and loop.
- 将实机 GIF 从 81.05 MiB 压缩为 5.13 MiB，采用 960 × 600、约 6.25 帧/秒及 96 色，保留完整 4.48 秒录制与循环播放。

- Add the maintainer-provided kitchen-pass gameplay GIF to both README languages, preserving the original animation and recording its dimensions, duration and frame count.
- 将维护者提供的厨房出餐口实机 GIF 加入中英文 README，保留原始动画并记录尺寸、时长与帧数。

- Add maintainer-provided tray screenshots at the kitchen pass and drink output area to both README languages, with image provenance and visible-scene notes.
- 将维护者提供的托盘出餐口、饮料出品台实机图加入中英文 README，并记录图片来源及可见场景。

- Add an assets directory for in-game test screenshots and promotional artwork, with README links and embedding examples.
- 新增 assets 目录存放实机测试图与宣传图，并提供 README 入口和图片引用示例。

- Adopt **出餐有序** as the Chinese display name in player guides and shared documentation.
- 中文名称统一为 **出餐有序**，同步玩家说明及公共文档。

- Rewrite player installation, usage, update and removal guides; move implementation and reload details into developer documentation and repair links used from extracted packages.
- 重写面向玩家的安装、使用、更新及卸载说明，将实现与重载细节移入开发文档，并修复解压后使用的文档链接。

- Include the MIT license in source and installable packages, with packaging checks for missing or changed license text.
- 为源码及安装包附上 MIT 许可全文，增加许可缺失或内容改变时的打包校验。

- Fall back to English when the game language cannot be read, keeping pickup active and restoring the selected language on a later successful refresh. Add failure and recovery regression coverage; this change has not been tested in-game.
- 游戏语言读取失败时回退英语，保持取餐功能运行，后续成功刷新后恢复所选语言。增加失败与恢复回归验证；本次改动尚未实机测试。

- Update to 0.1.7-dev: start oldest-first pickup on the drink output surface without aiming at a cup. Keep the same source while panning, pick only eligible full drinks into the held tray or food trolley, and preserve native short-click deposit. Add area isolation, rejection, three-cup sequencing and cancellation regressions; in-game acceptance remains pending.
- 更新至 0.1.7-dev：可直接对准饮料出品台面启动最早优先长按，无需瞄准某一杯；准星在同一台面内移动时继续，只将合适的成品饮料拿到当前托盘或餐车，保留原生短按放回饮料。增加区域隔离、拒绝条件、连续三杯及取消回归测试；实机验收仍待完成。

- Update to 0.1.6-dev: use a held food trolley for the same oldest-first hold at the kitchen pass, ready dishes and drinks. Track ordinary and stack slots, drink-only and tower-burger top-slot rules, and stop when the trolley is released or replaced. Keep ordinary server interactions and manual Lua hot reload.
- 更新至 0.1.6-dev：握持餐车时可在出餐口、成品菜品及饮料处使用相同的最早优先长按取餐；识别普通位和堆叠位、饮料专用位及高层汉堡顶层限制，放开或更换餐车即取消。保留原生服务器交互及手动 Lua 热重载。

- Update to 0.1.5-dev: support manual Ctrl+R script reload, keep an in-progress hold canceled until the key is released in the new runtime, and terminate the unloaded fallback loop. Add cross-runtime hold and queued-callback regression tests.
- 更新至 0.1.5-dev：支持 Ctrl+R 手动重载脚本，重载中断的长按在新运行状态中松键前不会重新启动；停止已卸载的备用循环，增加跨重载长按及排队回调回归测试。

- Update to 0.1.4-dev: start oldest-first pickup by holding over the kitchen pass's native pickup area, without aiming at a particular dish. Resolve its kitchen through the current world and keep per-dish server requests, readiness, reach, floor, tray capacity and acknowledgement checks.
- Keep direct dish/drink targeting and native short clicks. Empty passes do not start pickup; the hold hint remains below the native pickup hint while eligible dishes remain. Add area-started three-item pickup, camera panning, rejection and cancellation regression coverage. New area targeting awaits in-game acceptance.
- 更新至 0.1.4-dev：可直接对准厨房出餐口的原生拿取区域长按，无需瞄准某一盘菜品；通过当前世界定位厨房，保留按时间排序的逐盘服务器请求、成品状态、距离、楼层、托盘容量及拿取确认检查。
- 保留直接瞄准菜品或饮料的用法及原生短按；空出餐口不启动取餐，有可取菜品时在原生拿取提示下显示长按提示。增加从出餐口连续取三盘、移动准星、拒绝条件及取消操作的回归测试；新增区域触发仍待实机验收。

- Update to 0.1.3-dev: keep the selected source throughout a hold when the aimed item is being picked, moves to the tray or leaves an empty spot. Repeated input events preserve pending acknowledgement; turning/walking away, release and source/session changes still cancel.
- Remove orphaned central and legacy sidebar Mod hints after hot reload, including when no pickup session is available. Preserve one central row, stop unloaded runtimes and restore saved native hint visibility on the game thread.
- Add adapter/runtime regression coverage for three consecutive food and drink pickups and for reload cleanup. In-game acceptance remains pending.
- 更新至 0.1.3-dev：长按期间保持所选来源，瞄准餐品正在拿取、进入托盘或留下空位时不再中断；重复输入事件保留待确认状态，转开视线、走开、松键及切换来源或会话仍会取消。
- 热重载后清理中央及旧版侧边栏的 Mod 提示残留，包括未持托盘的情况；仅保留一份中央提示，停止已卸载逻辑，并在游戏线程恢复已记录的原生提示可见性。
- 增加真实适配层与运行逻辑联动的菜品/饮料连续三份拿取回归测试，以及重载清理测试；实机验收仍待完成。

- Keep the hold hint only below the native central pickup hint, with no sidebar fallback. Clear it when the pickup row, its parent containers or the HUD is hidden.
- 长按提示仅保留在原生中央取餐提示下方，不再挂接侧边栏；拿取提示、父容器或 HUD 隐藏时同步清除。

- Update to 0.1.2-dev: reduce the consecutive-pickup request interval from 300 ms to 50 ms and check active holds every 25 ms instead of 100 ms. Preserve pickup acknowledgement, rejection timeout and cancellation; idle scans stay at 100 ms.
- 更新至 0.1.2-dev：连续取餐请求间隔从 300 毫秒缩短至 50 毫秒，长按期间检查间隔从 100 毫秒缩短至 25 毫秒；保留拿取确认、超时及取消机制，空闲检查仍为 100 毫秒。

- Update to 0.1.1-dev: aim at an eligible dish or finished drink to activate pickup; empty output surfaces and pass pickup spots no longer trigger it.
- Anchor the native hold hint directly below the visible click-to-pick-up row, following native row refreshes and preserving other hint rows.
- 更新至 0.1.1-dev：仅瞄准可拿取菜品或成品饮料时触发，空出餐台面和拿取点不再触发。
- 原生长按提示紧接可见的点击拿取提示下方，跟随原生行刷新并保留其他提示行。

- Rename Oldest First to **First to Serve（先做好先端）**, including the source directory, package, install folder, log prefix and CI registration. Pickup behavior is unchanged.
- 将 Oldest First 更名为 **First to Serve（先做好先端）**，同步源码目录、安装包、安装目录、日志前缀和 CI 登记；拿取行为不变。

- Add First to Serve 0.1.0-dev: hold at the kitchen pass or drink output area to pick eligible items by native creation time, with bounded requests and tray acknowledgement.
- Add the game's native mapped-key hint with wording for all 14 game languages, preserving short clicks and restoring other interaction hints on exit.
- Add an independent source-only package and offline behavior checks. In-game and multiplayer acceptance remain pending.
- 新增 First to Serve 0.1.0-dev：长按出餐口或饮料台，按原生制作时间拿取合适的餐品，限制请求频率并等待托盘或台面确认。
- 增加游戏原生键位提示和 14 种语言说明，保留短按，离开后恢复其他交互提示。
- 增加独立原创源码安装包和离线行为验证；实机及联机验收待完成。
