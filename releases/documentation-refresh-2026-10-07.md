# Game compatibility documentation update / 游戏兼容性文档更新

[English](#english) · [中文](#中文)

## English

On 2026-10-07, after confirming in-game acceptance for game 1.0.2.44eb / Steam Build 25759268, the maintainer requested completing and merging the release records for Fresh to Serve 0.1.3 and Scan to Order 0.1.2, and republishing other Mods where their documentation had changed.

The two patch versions use the normal authorized-release workflow. This record covers documentation-only attachment replacements for the five unchanged versions below, when comparison with their published ZIPs confirms a documentation change:

| Mod | Unchanged version | Existing Release tag |
| --- | --- | --- |
| Bartender's Note | 0.1.2 | `bartenders-note-v0.1.2` |
| Auto Checkout | 0.1.4 | `auto-checkout-v0.1.4` |
| First to Serve | 0.1.7 | `first-to-serve-v0.1.7` |
| Smart Delivery | 0.1.5 | `smart-delivery-v0.1.5` |
| Auto Menu | 0.5.0 | `auto-menu-v0.5.0` |

Start from each published ZIP and replace only `README.md`, `DEVELOPMENT.md` and `CHANGELOG.md` with the corresponding tracked files at documentation commit `c6bc2c8d47a4efca563021385c320eb627a59981`. Preserve every other entry byte-for-byte, including Lua scripts, native DLLs, `enabled.txt` and the license. Keep the existing versions, Release IDs, tags and tag targets. Preserve the original release authorization and runtime source records.

Back up each existing attachment set before uploading the updated ZIP, `SHA256SUMS.txt` and `build-info.json`. The new build record must identify the documentation commit separately from the preserved runtime source, list the changed documents and retain the previous archive hash. Update the Release description to explain this documentation refresh and link the versioned guide. Download all replacement attachments and verify their bytes, archive contents and checksums after upload. Local backups, comparison reports and execution scripts remain in ignored `work/`.

The normal release workflow still skips already published versions. This authorization applies to the five documentation updates above; it does not change their gameplay code or extend the [reported testing scope](validation.md#english).

## 中文

2026-10-07，维护者确认游戏 1.0.2.44eb／Steam Build 25759268 实机验收通过后，要求：“ok，补一下合入，另外其他的mod可能也需要重新发布，因为其文档内容可能也发生了变化。”据此补齐焕鲜上桌 0.1.3 与扫码点餐 0.1.2 的发布记录并合入，同时核对另外五款 Mod 的文档变化并更新现有 Release 附件。

两个补丁版本使用常规授权发布流程。本记录仅覆盖上表五个版本经已发布 ZIP 对比确认存在差异后的文档附件更新，版本号保持不变。

以各自已发布 ZIP 为基础，只用文档提交 `c6bc2c8d47a4efca563021385c320eb627a59981` 中对应的已跟踪文件替换 `README.md`、`DEVELOPMENT.md` 和 `CHANGELOG.md`。其余所有条目，包括 Lua、原生 DLL、`enabled.txt` 及许可证，须逐字节不变。保留版本、Release ID、标签及标签指向，原始发布授权与运行源码记录继续保留。

上传前备份原附件组，再更新 ZIP、`SHA256SUMS.txt` 与 `build-info.json`。新的构建记录分别标识文档提交和保留的运行源码，列出更新文档并保存旧包哈希；Release 说明记录文档更新并链接到该提交的指南。上传后重新下载全部附件，核验字节、包内容与校验和。备份、比较结果和执行脚本均留在被忽略的 `work/`。

常规自动发布仍跳过已发布版本。此次授权仅覆盖上述五款的文档更新，不修改玩法代码，不扩大[已反馈的测试范围](validation.md#中文)。
