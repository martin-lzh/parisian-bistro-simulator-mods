# Contributing / 参与贡献

[English](#english) · [中文](#中文)

## English

Bug reports, translations, documentation improvements and focused code changes are welcome in English or Chinese. Read the [community guidelines](CODE_OF_CONDUCT.md#english). For gameplay help use [Support](SUPPORT.md#english); report vulnerabilities through [Security](SECURITY.md#english).

### Before changing code

1. Read [DEVELOPMENT.md](DEVELOPMENT.md#english), [AGENTS.md](AGENTS.md), and the target Mod's README, DEVELOPMENT and CHANGELOG. The development guide covers setup, architecture, tests and release boundaries.
2. Search existing [issues](https://github.com/martin-lzh/parisian-bistro-simulator-mods/issues). For a substantial new feature, describe the player problem and proposed behavior before expanding the implementation.
3. Work in an existing development checkout. Contributors with repository access can use a feature branch from `dev`; changes reach protected `main` through a pull request. Preserve unrelated local changes. Do not create temporary worktrees or push directly to `main`.

The repository is private. Making this repository public or publishing a release requires explicit maintainer authorization; ordinary contributions do neither.

### What belongs in a change

- Keep each `<feature>-mod/` independent and include only implemented features and necessary tests.
- Keep every README in English and Chinese, including repository, Mod, image-directory and documentation-index READMEs. Mod player guides cover download, installation, gameplay, updates, removal and help. Put architecture, API details, build commands and debugging in DEVELOPMENT; documents other than READMEs may be English-only.
- Keep runtime text aligned with all 14 supported game languages. Prefer native text, translate only Mod-owned wording, and test English fallback and recovery after language-read failures. See [localization](docs/localization.md#english).
- Preserve the current version unless the maintainer explicitly requests a version change. Add changes to the Mod's `Unreleased` notes; do not rewrite historical numbered entries or infer release approval from a successful test.
- Keep the root and per-Mod MIT licenses consistent, and include the license in every package. Contributions must be original or have compatible terms and appropriate attribution. Do not assume a game's assets or an external tool are covered by this project's MIT license.
- Keep all game files, extracted material, analysis, third-party research tools and related scripts in ignored `work/`. Do not attach them to commits, issues or PRs. Game installations are read-only; builds do not install Mods or modify saves.

### Before opening a pull request

Run the relevant checks from [Development](DEVELOPMENT.md#build-and-checks). For behavior changes, run the affected Mod's Lua tests; for packaging or shared tooling changes, run tool tests and the full package build. Review the staged diff and `python tools/check_repository.py`, including new files. For documentation-only work, check instructions, links and whitespace.

Describe the player-visible problem, resulting behavior, tests actually run, and remaining in-game checks. List the affected Mods and whether their versions are unchanged or explicitly authorized to advance. A build passing is not in-game acceptance. Use focused commits and keep generated output out of Git.

Maintainers review changes before merging. GitHub releases use the separate [release authorization process](releases/approvals/README.md#english); ordinary contributions do not publish a new release.

## 中文

欢迎使用中文或英文提交问题、翻译、文档改进及针对明确问题的代码改动。请遵守[社区规范](CODE_OF_CONDUCT.md#中文)。游戏使用问题见[帮助](SUPPORT.md#中文)，漏洞报告见[安全反馈](SECURITY.md#中文)。

### 开始修改前

1. 阅读 [DEVELOPMENT.md](DEVELOPMENT.md#中文)、[AGENTS.md](AGENTS.md)，以及目标 Mod 的 README、DEVELOPMENT 和 CHANGELOG。开发说明记录环境、架构、测试和发布边界。
2. 先搜索已有 [Issue](https://github.com/martin-lzh/parisian-bistro-simulator-mods/issues)。较大的新功能应先说明要解决的玩家问题及预期行为，再扩大实现范围。
3. 使用现有开发目录。有仓库权限的贡献者可从 `dev` 建立功能分支，通过 PR 合入受保护的 `main`。保留无关本地改动，不创建临时工作树，不直接推送 `main`。

仓库目前私密；将本仓库改为公开或发布版本需要维护者明确授权，普通贡献不会执行这些操作。

### 改动要求

- 每个 `<feature>-mod/` 独立维护，只加入实际实现及必要测试。
- 所有 README 均须中英双语，包括仓库、各 Mod、图片目录和文档索引的 README。Mod 玩家说明涵盖下载、安装、游戏内操作、更新、卸载和求助。架构、API、构建命令及调试内容放入 DEVELOPMENT；README 以外的文档可以仅使用英语。
- 新增文案覆盖游戏支持的 14 种语言；优先复用原生文案，只翻译 Mod 自有内容。测试语言读取失败时的英语回退及恢复，见[多语言适配](docs/localization.md#中文)。
- 维护者未明确要求升级时，保留现有版本，将改动记入 Mod 的 `Unreleased` 条目。不改写已有编号历史，不将测试通过视为发布授权。
- 根目录与各 Mod 的 MIT 许可证保持一致，每个安装包都附许可全文。贡献内容须为原创或具有兼容条款及必要署名；游戏资产和外部工具不自动适用本项目的 MIT 许可。
- 游戏文件、提取资料、分析、第三方研究工具及相关脚本全部留在被忽略的 `work/`，不提交，也不附到 Issue 或 PR。游戏安装目录只读；构建不自动安装 Mod 或修改存档。

### 提交 PR 前

按[开发说明](DEVELOPMENT.md#构建与检查)执行相关检查。行为改动运行对应 Mod 的 Lua 测试；打包或共享工具改动运行工具测试及全量构建。审查暂存差异并运行 `python tools/check_repository.py`，包含新文件。仅文档改动检查内容、链接和空白即可。

说明玩家遇到的问题、修改后的行为、实际执行的验证和剩余实机检查；列出受影响 Mod 及其版本保持不变或已明确获准升级。构建通过不等于实机验收。提交按目的组织，生成产物不进入 Git。

维护者审查后合并。GitHub Release 另按[发布授权流程](releases/approvals/README.md#中文)处理，普通贡献不会自动发布新版本。
