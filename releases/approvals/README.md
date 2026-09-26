# Release authorization / 发布授权记录

[English](#english) · [中文](#中文)

## English

Following the Old Market Simulator project, each new numbered Mod version requires a source-bound release record. A record preserves the maintainer's existing explicit release instruction; it neither requests another approval nor grants permission by itself. A request for development, builds or CI maintenance does not authorize a version release.

1. Use the maintainer's instruction to identify the Mod and target version. Update `build.py`, README, the diagnostic version identifier and CHANGELOG. Put the authorized changes in the first corresponding numbered entry; keep later features on a separate development branch. Neither `Unreleased` nor `未发布` may contain pending release content.
2. Complete the required tests and package checks, commit the source and confirm a clean working tree.
3. From the repository root, record the instruction already received:

```powershell
python tools/release.py record-approval --mod bartenders-note --authorization '<summary of the maintainer instruction explicitly releasing this Mod and version>'
```

The optional `--prerelease` flag marks a numbered version as a GitHub prerelease. `-dev` packages only produce CI artifacts and are excluded from Release publication. The command does not bump versions, contact GitHub or upload attachments.

4. Review and commit `releases/approvals/<mod>-v<version>.json`, then merge through a PR into `main`. CI checks existing Releases, the authorization record, numbered notes and the source digest. The `main` publishing job publishes only after all required checks pass.

A record contains the Mod, version, prerelease status, source commit, source digest and instruction summary. The digest covers that Mod's directory, `tools/`, `.github/workflows/` and `.gitattributes`; the authorization record itself is outside the digest. A changed commit ID after merging or squashing does not by itself invalidate the record. Changes to another Mod or root documentation also do not invalidate it.

A new version without a record is skipped, allowing normal development merges. An existing record with changed source or remaining `Unreleased` content fails release preflight. Published versions are always skipped: attachments are not overwritten and tags are not moved. A record is a reviewable maintainer statement; it cannot automatically prove conversation authorization. Agents must use the user's actual instruction.

When source changes invalidate a record, first check whether the original release instruction still covers those changes. Move the old record unchanged into `history/`, adding its source commit to the filename, then commit the archive and source changes. Only afterward may a new record be created for the version still covered by the original instruction. Archived records do not participate in publication. Never expand the authorized version scope or edit an old digest merely to make CI pass.

All seven current source versions remain development packages; see the [version record](../README.md#english). The 2026-09-26 report that all Mods completed in-game testing does not request stable promotion or add release authorization. Historical stable acceptance records remain unchanged.

## 中文

参照菜市场模拟器项目，每个 Mod 的新编号版本由一份绑定源码的记录控制发布。记录保存维护者已给出的明确发布指令，不是新增一次审批，也不会自行赋予发布权限。仅要求开发、构建或维护 CI 不等同于要求发布某个版本。

1. 按维护者指令确定 Mod 和目标版本，更新 `build.py`、README、诊断版本标识及 CHANGELOG。将本次获准内容放到首个对应编号条目；后续功能保留在单独的开发分支。`Unreleased` 和 `未发布` 不得有待发布内容。
2. 完成实际所需的测试和包检查，提交源码，确认工作区干净。
3. 在仓库根目录记录已经取得的指令：

```powershell
python tools/release.py record-approval --mod bartenders-note --authorization '<维护者明确发布该 Mod 和版本的指令摘要>'
```

可选 `--prerelease` 将编号版本标记为 GitHub 预发布；`-dev` 开发包只生成 CI artifacts，不参与 Release 发布。记录命令不升级版本、不访问 GitHub、不上传附件。

4. 审查并提交生成的 `releases/approvals/<mod>-v<version>.json`，通过 PR 合入 `main`。CI 检查现有 Release、授权记录、编号说明及源码摘要；`main` 的发布任务在全部必需检查通过后发布。

记录包含 Mod、版本、预发布状态、来源提交、源码摘要及指令摘要。摘要覆盖该 Mod 目录、`tools/`、`.github/workflows/` 和 `.gitattributes`，记录文件本身在摘要范围之外。合并或 squash 后提交号变化不会单独导致失效；其他 Mod 和根说明也不会使此记录失效。

没有记录的新版本直接跳过，允许日常开发合并；有记录但源码改变或仍有 `Unreleased` 内容会使发布预检失败。已发布版本始终跳过，不覆盖附件、不移动标签。记录是可审查的维护者声明，不能自动验证对话授权真伪；Agent 必须依据用户实际指令填写。

源码变化导致记录失效时，先核对原发布指令是否仍覆盖变更。将旧记录原样移入 `history/`，在文件名附来源提交，再提交归档和源码；之后才可为原指令仍覆盖的版本重新记录。归档记录不参与发布，禁止为了让 CI 通过而扩大版本范围或修改旧摘要。

全部 7 个 Mod 的当前源码仍为开发版，见[版本记录](../README.md#中文)。2026-09-26 全部 Mod 实机测试完成的反馈未要求转正式版，也不新增发布授权；历史正式版验收记录保持不变。
