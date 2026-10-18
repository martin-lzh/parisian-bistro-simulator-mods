# Changelog / 变更记录

## Unreleased

- Supports game 1.0.2.44eb (Steam Build 25822788).
- 支持游戏 1.0.2.44eb（Steam Build 25822788）。

- Documentation: added the cover image to the README and removed outdated download instructions.
- 文档：README 加入宣传封面，删除过时的下载说明。

- Documentation: rewrote the player guide in plainer language, focused on what the Mod does and how to use it.
- 文档：用更简洁的语言重写玩家说明，只保留功能介绍和操作方法。

- The Mod is now licensed under the PolyForm Noncommercial License 1.0.0: free to use, share and modify for non-commercial purposes; commercial use is not allowed. Versions released before this stay under MIT.
- 本 Mod 改用 PolyForm Noncommercial 1.0.0 许可：可免费用于非商业用途的使用、分享和修改，不允许商用。此前已发布的版本仍为 MIT 许可。

## 0.1.4 - 2026-09-26

### Compatibility documentation / 兼容性文档 — 2026-10-07

- Supports game 1.0.2.44eb (Steam Build 25759268).
- 支持游戏 1.0.2.44eb（Steam Build 25759268）。

### Documentation update / 文档更新 — 2026-09-26

- Documentation: expanded the player guide with controls, behaviour, multiplayer requirements and what to do when checkout waits or stops.
- 文档：补充玩家说明中的操作方式、功能行为、联机要求，以及结账等待或停止时的处理方法。

### English

- First stable release of the 0.1.4 changes.
- Completes cash and card checkout on the host from any distance, restores temporary interaction settings afterwards, follows the game language in log messages, and survives script reloads.
- Added the checkout-counter screenshot to the player guide.
- Added English and Chinese install, usage and update guides, plus the MIT license.

### 中文

- 0.1.4 的改动转为正式版。
- 房主端在任意距离自动完成现金与刷卡结账，结束后恢复临时交互设置，日志跟随游戏语言，并支持脚本重载。
- 玩家说明加入收银台实机截图。
- 附上中英文安装、使用、更新说明及 MIT 许可。

## 0.1.4-dev

### English

- Added the checkout-counter screenshot and an assets folder for screenshots and artwork.
- Chinese display name is now **收银管家**.
- Rewrote the install, usage, update and removal guides, and fixed links that are opened from the extracted package.
- The MIT license is now included in the download.
- 0.1.4-dev: scripts can be reloaded with the experimental UE4SS without losing retry counts or the employee-job changes, which are restored before the new scripts take over.
- A reload doesn't give a step extra tries, and a damaged reload record stops the Mod instead of being used.
- When upgrading from an earlier version, or removing the Mod for good, close the game first.
- 0.1.3-dev: log messages follow the game's current language in all 14 game languages, with English as the fallback; checkout keeps working if the language can't be read.
- Game notifications and interaction text stay the game's own.

### 中文

- 加入收银台实机截图，并新增存放实机图和宣传图的 assets 目录。
- 中文名称统一为 **收银管家**。
- 重写安装、使用、更新和卸载说明，修复解压后打开的文档链接。
- 下载包中附带 MIT 许可。
- 0.1.4-dev：支持 UE4SS 实验版重新加载脚本，重试次数和员工任务改动都会保留，新脚本接手前先恢复员工任务。
- 重新加载不会让某一步重新获得尝试次数；交接记录损坏时 Mod 停止运行，不使用损坏的记录。
- 从旧版升级或永久卸载时，请先关闭游戏。
- 0.1.3-dev：日志说明跟随游戏当前语言，覆盖游戏全部 14 种语言，无法识别时使用英语；读取语言失败也不影响结账。
- 游戏通知和交互文本保持游戏原样。

## 0.1.2 - 2026-09-24

### English

- Stable release of 0.1.2-dev.
- Fixed automatic checkout failing when the host was far from the register or payment. The interaction range is widened only for the Mod's own action and restored right after; the player is never moved.
- Settings are still restored if something goes wrong during that action; if restoring fails, the Mod asks you to reload the restaurant.
- Logs now include the host's distance to the register and the range used.

### 中文

- 0.1.2-dev 转为正式版。
- 修复房主离收银机或付款物件较远时无法自动结账的问题。只在 Mod 自身操作期间临时扩大交互范围，随后立即恢复，不会移动玩家。
- 操作中途出错也会恢复设置；恢复失败时会提示重新载入餐厅。
- 日志增加房主到收银机的距离及所用交互范围。

## 0.1.1 - 2026-09-24

### English

- Stable release of the latest development build.
- You can now do other work while the Mod checks out customers. If you accept the payment or close the drawer first, the Mod cancels its own action and continues from the new state.
- Employees no longer take new counter-checkout jobs on the host; jobs they already started still finish, and their other work and settings are unchanged. Their jobs are restored when you leave the session or if the Mod stops with an error, with a warning if that fails.
- Customer-at-counter notifications now trigger an immediate check of that register, in addition to the regular check every second. If the notification can't be used, the regular check continues.
- Much more detailed logs for troubleshooting, including why the Mod is waiting.
- An action cancelled at the last moment no longer uses up a try, and a register that is briefly unreadable keeps its retry history.

### 中文

- 最新开发版转为正式版。
- Mod 结账时可以同时做其他工作。你先收款或先关钱柜时，Mod 会取消自己的操作，按最新状态继续。
- 房主端员工不再领取新的柜台收银任务；已开始的任务照常完成，其他工作和员工设置不变。离开会话或 Mod 因错误停止时恢复员工任务，失败会发出警告。
- 收到“顾客到柜台”提醒时立即检查对应收银机，同时保留每秒一次的定时检查；提醒不可用时定时检查照常进行。
- 大幅补充排查用日志，包括 Mod 正在等待的原因。
- 最后一刻取消的操作不再消耗尝试次数；收银机短暂无法读取时保留其重试记录。

## 0.1.0-dev

### English

- First development version of automatic counter checkout for cash and card payments, using the game's normal interactions.
- Waits for card and drawer animations, and for employees, player actions and pause screens.
- Runs automatically after installation with no key or toggle; limits retries for each step, stops on errors and writes logs.
- Runs only in single player or for the multiplayer host, and resets when you change saves.
- Known issue in this version: automatic checkout did not complete correctly.

### 中文

- 柜台自动结账首个开发版本，按游戏默认交互处理现金与银行卡。
- 等待刷卡和钱柜动画，避让员工处理、玩家操作及暂停界面。
- 安装后自动运行，无需按键或开关；每一步都有重试上限，出错时停止并写入日志。
- 只在单人或联机房主端运行，切换存档时重置状态。
- 此版本已知问题：自动结账未能正常完成。
