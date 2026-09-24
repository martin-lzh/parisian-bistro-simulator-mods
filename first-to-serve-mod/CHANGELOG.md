# Changelog

## Unreleased

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
