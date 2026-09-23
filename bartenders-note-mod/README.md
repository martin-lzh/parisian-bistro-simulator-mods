# Bartender's Note

在餐厅名称下方显示你认领且尚未制作完成的饮料，按类型合并为一行，例如：

`浓缩咖啡 x 10  ·  柠檬水 x 3`

只统计当前本地玩家认领的订单。待制作和制作中的饮料计入清单，已制作完成的饮料不计入；取消认领、取消订单或完成制作后数量随队列更新。清单为空时隐藏。饮料名称跟随游戏语言，相同译名的不同饮料仍分别统计。

界面在运行时使用餐厅名称条的背景、字体与文字颜色；随原生 HUD 缩放，长清单缩小以维持单行。不会占用鼠标、键盘或手柄焦点。

## 状态与依赖

**0.1.0 正式版。** 2026-09-24 用户确认开发包实机测试成功。正式版保持已测试的运行逻辑；验证范围见[开发说明](DEVELOPMENT.md)。安装文件后需重启游戏才会加载。

- 目标：Parisian Bistro Simulator，Unreal Engine 5.4；本机参考基线 Steam Build 25393699，ProjectVersion 1.0.0.44eb。
- 依赖：[UE4SS experimental](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental-latest)，需要 `LoopInGameThreadWithDelay` 和 `ExecuteInGameThreadWithDelay`。本机核对的 API 版本为 `v3.0.1-1140-gf58e8f84`；这是实验分支版本号，**不是**旧的稳定版 3.0.1。实测环境已能加载运行；未据此声明兼容所有实验版加载器。
- 包内不含 UE4SS、游戏资产、游戏程序集或反编译资料。

## 安装与卸载

构建不会安装 Mod。以下步骤由玩家在游戏关闭时手动进行：

1. 根据 [UE4SS 官方安装说明](https://docs.ue4ss.com/dev/installation-guide.html)安装上述实验版本。使用该版本发行包自己的目录结构与默认设置。
2. 将压缩包里的 `BartendersNote` 文件夹放到 UE4SS 的 `Mods` 目录。新布局通常为游戏 `BrasserieSimulator/Binaries/Win64/ue4ss/Mods/BartendersNote`；以实际加载器位置为准。
3. 确认存在 `BartendersNote/Scripts/main.lua` 和 `BartendersNote/enabled.txt`。无需替换整个 `mods.txt`，也不要重复添加另一个启用条目。
4. 启动游戏，进入餐厅，在平板饮料队列认领订单，然后关闭平板查看餐厅名称下方。

卸载时在游戏关闭后移除 `BartendersNote` 文件夹即可。本 Mod 不写入存档、不修改订单，也不改动原 HUD 的名称条。

## 更新与排查

反射事件发生后会请求刷新；另有每 750 毫秒一次的队列核对，补足原生与联机队列变化。画面不会逐帧扫描订单；内容未变时不重写文字。

没有已认领的待做饮料、餐厅名称条隐藏或离开游戏 HUD 时，清单不可见。数据源失效时清空旧清单，并在 UE4SS 日志中输出 `[Bartender's Note]` 原因；恢复后自动重新连接。缺少所需加载器 API 时直接停用并记录提示。翻译暂不可用时会显示 `Drink <编号>`，保留实际数量。

开发与验收方法见 [DEVELOPMENT.md](DEVELOPMENT.md)。
