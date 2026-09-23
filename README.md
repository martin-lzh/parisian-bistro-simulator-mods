# Parisian Bistro Simulator Mods

法式小馆儿模拟器的非官方 Mod 开发项目。仓库保持私密；已提供两个 Mod 的正式版，目前 Auto Checkout 继续开发后续修复。

| Mod | 功能 | 状态 |
| --- | --- | --- |
| [Bartender's Note](bartenders-note-mod/README.md) | 在餐厅名称下方汇总本地玩家认领的待做饮料 | 0.1.0 正式版 |
| [Auto Checkout](auto-checkout-mod/README.md) | 自动处理顾客柜台付款和收银机结账交互 | 0.1.2-dev，现金/刷卡及远距离结账已获实机确认 |

实机确认日期和范围见[验收记录](releases/validation.md)。CI 执行离线测试、打包及文件校验，产物从对应 [Actions 运行](https://github.com/martin-lzh/parisian-bistro-simulator-mods/actions/workflows/mods.yml)下载。

目录组织参考 Old Market Simulator Mods：每个 Mod 在根目录拥有独立的 `<feature>-mod/` 文件夹，独立维护源码、构建入口、说明和变更记录。

| 路径 | 用途 | Git |
| --- | --- | --- |
| `<feature>-mod/` | 实际开始开发某个功能时创建，存放原创 Mod 源码 | 跟踪 |
| `docs/` | 原创设计、兼容性与验证记录 | 跟踪 |
| `tools/` | 原创构建、打包及仓库检查脚本 | 跟踪 |
| `releases/` | 已确定的版本说明和发布记录 | 跟踪 |
| `work/` | 所有反编译资料、游戏参考、提取脚本、下载工具及临时文件 | 全部忽略 |
| `outputs/` | 本地构建产物和安装包 | 全部忽略 |

开发前阅读 [DEVELOPMENT.md](DEVELOPMENT.md) 和 [AGENTS.md](AGENTS.md)。本机游戏参考入口是 `work/reference/README.md`，不会随 Git 克隆同步。

本游戏使用 Unreal Engine。两个 Mod 使用 UE4SS experimental Lua；Bartender's Note 使用原生 UMG。菜市场模拟器的 Unity/C# 插件与加载器配置不能直接复用。

本项目与游戏开发商无隶属关系。游戏文件及其反编译衍生内容只保存在本地，不上传到本仓库，包括私密仓库。
