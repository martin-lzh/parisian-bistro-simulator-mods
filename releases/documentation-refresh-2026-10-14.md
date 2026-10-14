# Steam Build 25822788 documentation update / Steam Build 25822788 文档更新

[English](#english) · [中文](#中文)

## English

On 2026-10-14, the maintainer requested updating the documentation in the existing GitHub Release packages and the Nexus game compatibility descriptions to **Steam Build 25822788 / game 1.0.2.44eb**, while keeping all Mod versions unchanged.

| Mod | Version | Existing Release tag |
| --- | --- | --- |
| Bartender's Note | 0.1.2 | `bartenders-note-v0.1.2` |
| Auto Checkout | 0.1.4 | `auto-checkout-v0.1.4` |
| Fresh to Serve | 0.1.3 | `fresh-to-serve-v0.1.3` |
| First to Serve | 0.1.7 | `first-to-serve-v0.1.7` |
| Smart Delivery | 0.1.5 | `smart-delivery-v0.1.5` |
| Auto Menu | 0.5.0 | `auto-menu-v0.5.0` |
| Scan to Order | 0.1.2 | `scan-to-order-v0.1.2` |

Use documentation commit `1e5949b08d5287980c0f9a19820ef47546081f22`, merged through PR #12. Start with each published ZIP and replace only `README.md`, `DEVELOPMENT.md` and `CHANGELOG.md` with the tracked documents at that commit. Preserve every other entry byte-for-byte, including Lua, DLLs, `enabled.txt` and the license. Keep Release IDs, tags, tag targets, Mod versions and original runtime provenance.

Back up the existing attachments before replacement. Update the ZIP, `SHA256SUMS.txt`, `build-info.json` and Release description, recording the documentation commit separately from the preserved runtime source and retaining the previous archive hash. Download the replacement attachments and verify their bytes, archive contents, hashes and release/tag identities.

On Nexus, update the current Mod descriptions and current main-file compatibility metadata, preserving Mod versions, file IDs, existing ZIPs and download history. This request does not replace Nexus ZIPs or relabel historical files. In-game and multiplayer testing is skipped for this documentation update at the maintainer's request because runtime code is unchanged. Earlier acceptance records retain their original dates and builds.

Local backups, execution records and verification artifacts remain in ignored work/. The normal release workflow continues to skip already published versions.

### Completion

All seven existing GitHub Release attachment sets were replaced and downloaded again on 2026-10-14. The three documents match the pinned documentation commit, every other ZIP entry is byte-for-byte preserved, all replacement attachment checksums match, and Release identities and tag targets are unchanged.

All seven Nexus listings' English/Chinese compatibility sections, short descriptions and current main-file descriptions now identify Steam Build 25822788. Public pages were read back; Mod versions, file IDs and prior downloads are preserved. Gameplay and installation text outside the compatibility section is unchanged. The retained Nexus main-file IDs are:

| Mod | Nexus Mod ID | Retained main-file ID |
| --- | ---: | ---: |
| Bartender's Note | 1 | 10 |
| Auto Checkout | 2 | 11 |
| Fresh to Serve | 3 | 8 |
| Smart Delivery | 4 | 12 |
| Auto Menu | 5 | 13 |
| First to Serve | 6 | 14 |
| Scan to Order | 7 | 9 |

## 中文

2026-10-14，维护者要求将 GitHub 现有 Release 安装包内文档与 Nexus 游戏兼容性说明同步更新至 **Steam Build 25822788／游戏 1.0.2.44eb**，七款 Mod 版本保持上表数值。

文档采用 PR #12 合入的提交 `1e5949b08d5287980c0f9a19820ef47546081f22`。以各自已发布 ZIP 为基础，仅替换该提交中的 `README.md`、`DEVELOPMENT.md` 和 `CHANGELOG.md`。其他所有条目，包括 Lua、DLL、`enabled.txt` 和许可证，须逐字节不变；保留 Release ID、标签及指向、Mod 版本和原运行源码来源。

替换前备份现有附件，更新 ZIP、`SHA256SUMS.txt`、`build-info.json` 与 Release 说明。构建记录分别标识文档提交和保留的运行源码，保存旧包哈希；更新后重新下载附件，核验字节、包内容、校验和及 Release／标签身份。

Nexus 更新当前 Mod 正文及当前主文件的兼容性元数据，保留版本、文件 ID、现有 ZIP 和下载历史；此次不替换 Nexus ZIP，也不修改历史文件的兼容标注。按维护者要求，本次仅更新文档且运行代码不变，实机及联机测试跳过；以往验收继续对应原日期及构建。

备份、执行记录和核验产物留在被忽略的 work/。常规自动发布继续跳过已发布版本。

### 完成结果

2026-10-14，七款 GitHub 现有 Release 附件组均已更新并重新下载。三份文档与指定提交一致，其他所有 ZIP 条目逐字节保留，更新附件的校验和一致，Release 身份及标签指向不变。

七款 Nexus 页面的中英兼容段、短简介及当前主文件说明均已标注 Steam Build 25822788，公开页面读回核对通过；Mod 版本、文件 ID 和旧下载保留。兼容段之外的玩法和安装正文保持原样；现有主文件 ID 见上表。
