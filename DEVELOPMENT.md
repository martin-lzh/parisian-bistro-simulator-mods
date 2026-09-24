# 开发

## 本地参考

所有反编译相关内容均位于被忽略的 `work/`：资源解包、蓝图与类型映射、导出数据、原生代码分析、内存快照、日志、第三方工具及提取脚本。具体路径和可读范围见本机的 `work/reference/README.md`。

游戏安装目录保持只读。构建、解包和研究工作只写入本项目；安装 Mod 和实际游戏测试是单独的步骤。不得把游戏原始资产或反编译输出复制进可跟踪目录。

## 新 Mod

确定功能后创建 `<feature>-mod/`，沿用独立 Mod 目录模式：

- `README.md`：用途、安装与使用方法、实际验证的兼容范围。
- `DEVELOPMENT.md`：原创实现设计、构建入口和测试方法。
- `CHANGELOG.md`：开发期间先记录到 `Unreleased`。
- 源码和构建脚本：按实际采用的 Unreal Mod 方案组织。
- `tests/`：仅在有适合自动验证的行为时添加。

仅建立实际需要的文件，不提交空插件、占位实现或从其他游戏复制的加载器配置。包输出到根目录 `outputs/`，只包含原创 Mod 文件和必要声明。

## 提交

直接使用当前工作目录，不创建临时 worktree。`main` 启用保护后，在 `development` 或功能分支开发，通过 PR 合并到 `main`，不可直接推送或绕过保护。

每次任务结束检查差异、提交并推送，除非用户明确要求不推送。推送前执行：

```powershell
python tools/check_repository.py
git diff --check
git status --short
```

检查器审查 Git 已跟踪和暂存的路径；新增文件应先有选择地暂存再检查。`work/` 和 `outputs/` 在本地保留，干净的 Git 工作区不代表删除它们。

## CI 与 main 保护

GitHub Actions 工作流 `.github/workflows/mods.yml` 在 `main`、`dev`、`development` 推送，目标为 `main` 的 PR，以及手动运行时执行。测试和打包使用 GitHub 托管 Windows Runner、Python 3.12、uv 0.10.7 和 lupa 2.6（Lua 5.4），无需游戏安装、UE4SS 或 `work/` 资料。

- `Script, data and workflow syntax`：审查仓库文件边界、Python/JSON 语法、空白错误和工作流语法。actionlint 下载使用固定版本和 SHA-256 校验。
- `Lua tests and packages`：核对版本、编号 CHANGELOG、诊断版本与打包白名单，测试包校验器，运行两个 Mod 的全部离线测试，构建 ZIP 并逐文件核对源码与 SHA-256。
- `mod-packages` artifact 保存两个 ZIP、各自校验文件及记录提交号的 `build-info.json`，保留 14 天。GitHub Actions 均固定提交 SHA，默认仅授予仓库读取权限。
- 构建检查还执行只读的 Release 预检。`main` 的 push 在两个检查通过后运行 Ubuntu 发布任务，仅该任务拥有 `contents: write`，从同次 CI 产物发布获准的新编号版本。创建草稿、附件回读校验及中断续传规则见[发布说明](releases/README.md)。

本地运行相同核心检查：

```powershell
python tools/check_repository.py
python tools/check_syntax.py
python -m unittest discover -s tools/tests -v
python tools/ci.py build
```

`outputs/ci/` 必须为空或只含本次版本的产物；升级版本后先移走该目录旧产物，以免混入当前 artifact。每个 Mod 独立的 `build.py` 仍可直接使用。

`main` 保护配置保存在 `.github/main-ruleset.json`，通过 GitHub Rulesets 管理：必须经 PR、分支包含最新 `main`、上述两个 GitHub Actions 检查均通过；禁止强推和删除，无绕过者。沿用参考项目的零审批人数，不要求另一位维护者批准自己的 PR。仓库继续保持私密。

规则集属于 GitHub 仓库设置；修改 JSON 不会自动更改远端规则。维护时通过 REST API 显式应用，再读取远端配置核对；CI 不持有仓库管理凭据。
