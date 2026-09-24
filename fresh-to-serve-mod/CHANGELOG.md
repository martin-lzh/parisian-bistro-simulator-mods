# Changelog

## Unreleased

- Fresh to Serve 0.1.1-dev extends cleanup and remake requests to finished drinks, including cocktails, on drink output areas and elevator serving slots.
- Match drink order GUIDs to the original customer; clean up through the native drink lifecycle, deduplicate prepared/queued drinks, and preserve other customers' unplaced orders.
- Estimate drink preparation from live equipment fill/interaction durations and handling allowance. Check assigned working bartenders, defer during manual claims, and recheck customer presence and patience before every request.
- Fresh to Serve 0.1.1-dev 将低劣成品清理与重做扩展至饮料及鸡尾酒出品位和升降机；核对原顾客订单编号、去重并保留其他顾客尚未下单的状态。按设备灌装、交互及取料耗时估算，检查楼层调酒师和手动认领，每次补单重新检查顾客与耐心。仍待实机验收。

- Rename Fresh Service to Fresh to Serve (焕新上桌), including its source folder, package, loader folder and log prefix. Gameplay behavior and version remain unchanged.
- Fresh Service 更名为 Fresh to Serve（焕新上桌），同步修改源码目录、安装包、加载目录和日志前缀；玩法与版本号不变。

- Add Fresh to Serve 0.1.0-dev: clear poor cooked meals from kitchen pickup positions/elevators and request replacements through the normal kitchen flow.
- Require the original customer/order to remain active and remaining patience to cover cooking, backlog and service allowance. Never reset patience.
- Reconcile existing meals and queue entries; preserve order identity; bound retries; guard authority, active pickup, world changes and ambiguous engine failures.
- Add independent packaging, synthetic behavior tests and bilingual guides. In-game acceptance is pending.
- 新增 Fresh to Serve 0.1.0-dev：清理厨房取餐位及升降机低劣熟食，核对原顾客、订单与耐心预算后补单，再由服务员上菜；含去重、有限重试、房主权限及双语说明，仍待实机验收。
