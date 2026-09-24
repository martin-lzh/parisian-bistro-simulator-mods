# Changelog

## Unreleased

- Rename Fresh Service to Fresh to Serve (焕新上桌), including its source folder, package, loader folder and log prefix. Gameplay behavior and version remain unchanged.
- Fresh Service 更名为 Fresh to Serve（焕新上桌），同步修改源码目录、安装包、加载目录和日志前缀；玩法与版本号不变。

- Add Fresh to Serve 0.1.0-dev: clear poor cooked meals from kitchen pickup positions/elevators and request replacements through the normal kitchen flow.
- Require the original customer/order to remain active and remaining patience to cover cooking, backlog and service allowance. Never reset patience.
- Reconcile existing meals and queue entries; preserve order identity; bound retries; guard authority, active pickup, world changes and ambiguous engine failures.
- Add independent packaging, synthetic behavior tests and bilingual guides. In-game acceptance is pending.
- 新增 Fresh to Serve 0.1.0-dev：清理厨房取餐位及升降机低劣熟食，核对原顾客、订单与耐心预算后补单，再由服务员上菜；含去重、有限重试、房主权限及双语说明，仍待实机验收。
