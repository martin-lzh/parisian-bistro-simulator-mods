# Gameplay guide update / 游戏操作说明更新

[English](#english) · [中文](#中文)

## English

On 2026-09-26, the maintainer requested a subagent audit of every Mod README, complete explanations of in-game controls and features, no Mod implementation changes, unchanged versions, and repackaging to update the existing Release downloads.

This explicitly authorizes a documentation-only replacement of the seven existing Release attachment sets. The normal release workflow continues to preserve published versions; it does not perform this replacement automatically. This instruction applies only to the documentation update recorded here.

| Mod | Unchanged version | Existing Release tag |
| --- | --- | --- |
| Bartender's Note | 0.1.2 | `bartenders-note-v0.1.2` |
| Auto Checkout | 0.1.4 | `auto-checkout-v0.1.4` |
| Fresh to Serve | 0.1.2 | `fresh-to-serve-v0.1.2` |
| First to Serve | 0.1.7 | `first-to-serve-v0.1.7` |
| Smart Delivery | 0.1.5 | `smart-delivery-v0.1.5` |
| Auto Menu | 0.5.0 | `auto-menu-v0.5.0` |
| Scan to Order | 0.1.1 | `scan-to-order-v0.1.1` |

Three subagents audit separate groups of guides against the original Mod source and tests. The primary agent reviews the results and checks that instructions agree across English and Chinese. The maintainer also requires every README to be bilingual, while other documents may be English-only. All 18 repository READMEs, including image guides and documentation indexes, were checked; the contributor and development guidance reflects this policy. Existing screenshots and installation guidance remain available. Game actions or key bindings that cannot be established from the available evidence are not invented.

Repackaging starts from the published ZIPs at runtime source `b52a4c008b4c7993614ea49f37b032a8e6b3a4e7`. Only `README.md` and `CHANGELOG.md` inside each ZIP may change. Every other entry, including Lua scripts, native DLLs, `enabled.txt`, developer documentation and the license, must retain exactly the same bytes. The versions, release IDs, tag names and tag targets remain unchanged. The original publication approval records continue to describe the original release source.

Each replacement includes a new ZIP, `SHA256SUMS.txt` and `build-info.json`. The build record identifies the documentation commit separately from the unchanged runtime source and records the previous archive hash. Release descriptions link the updated guide at its documentation commit. Before replacement, the old attachments are backed up locally; after upload, all three new attachments are downloaded and compared with the prepared files. This documentation update does not change repository visibility.

This update adds documentation, not new gameplay behavior or a new in-game test claim. The maintainer's prior in-game and multiplayer acceptance remains in the [validation record](validation.md#english).

## 中文

2026-09-26，维护者要求：“每个mod的readme需要把完整的游戏内操作方式/功能介绍明白，调用subagents审计一下，不涉及mod改动，版本都保持不变。但是后续需要重新打包发布更新release包。”

本次明确授权仅为文档更新替换现有 7 个 Release 的附件组。常规发布工作流仍保留已发布版本，不会自动执行此次替换；本指令仅覆盖本文件记录的文档更新。

| Mod | 版本保持不变 | 现有 Release 标签 |
| --- | --- | --- |
| 调饮手记 | 0.1.2 | `bartenders-note-v0.1.2` |
| 收银管家 | 0.1.4 | `auto-checkout-v0.1.4` |
| 焕鲜上桌 | 0.1.2 | `fresh-to-serve-v0.1.2` |
| 出餐有序 | 0.1.7 | `first-to-serve-v0.1.7` |
| 配送随心 | 0.1.5 | `smart-delivery-v0.1.5` |
| 菜单巧配 | 0.5.0 | `auto-menu-v0.5.0` |
| 扫码点餐 | 0.1.1 | `scan-to-order-v0.1.1` |

3 个 subagent 分组对照原创 Mod 源码与测试审计说明，由主代理复核结果和中英文一致性。维护者另要求所有 README 均须双语，其他文档可以仅使用英语；已核对仓库全部 18 份 README，包括图片说明及文档索引，并同步贡献与开发规范。保留现有截图与安装说明；无法从现有证据确认的原生操作或固定键位不作编造。

重新打包以运行源码 `b52a4c008b4c7993614ea49f37b032a8e6b3a4e7` 对应的已发布 ZIP 为基础，仅允许替换各包内的 `README.md` 和 `CHANGELOG.md`。其余条目，包括 Lua、原生 DLL、`enabled.txt`、开发说明及许可证，均须逐字节一致。版本、Release ID、标签名称及指向保持不变；原发布授权记录继续对应原始发布源码。

每组替换附件包含新的 ZIP、`SHA256SUMS.txt` 和 `build-info.json`。构建记录分别记录文档提交与未改变的运行源码，并保存旧安装包哈希；Release 说明链接到新文档提交中的操作指南。替换前在本地备份旧附件，上传后下载全部 3 个新附件并与准备文件比较。该文档更新不更改仓库可见性。

本次只完善文档，不增加玩法或新的实机验收结论。此前维护者确认的实机与联机验收仍见[验收记录](validation.md#中文)。
