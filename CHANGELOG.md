## v0.7（2026-08-07）新增 VS Code 挂载机制

- 新增 `_workspace/07-VSCode工作区挂载登记.md`（sync: manual）：挂载登记表 = `.code-workspace` folders 唯一真相，预填 5 个骨架目录，新实例首跑即「已是最新」。
- 新增 `04-工具/sync-vscode-workspace.ps1`：`$PSScriptRoot` 推导式默认路径（登记表通配兼容实例 06 / 模板 07），幂等同步、`-DryRun`、settings 保留。
- `04-工具/README.md` 增加「VS Code 工作区挂载同步」小节；模板说明升 v0.7。

## v0.6（2026-08-07）恢复复制即用布局

- 结构回退：模板包顶层 = 实例骨架（README / AGENTS / _workspace / 01-文档 / 02-数据 / 03-知识输入 / 04-工具 / code-workspace），复制或克隆后改名即可用。
- 新增 create-instance.ps1：一条命令生成新实例骨架。
- sync-template.ps1 改为 front-matter 驱动（模板自身文件自动排除）。
- 参考文件移入实例 _handoff/归档/，模板仓保持纯净。
- 版本 / CHANGELOG / 同步 / 远端作为模板仓附加层，不影响骨架复制。

# 更新记录（CHANGELOG）

版本格式：`v<主>.<次>`。v0.x 为模板迭代期；结构/机制变化升主号，小改升次号。登记原则：每次修改模板后必须在此记录。

## v0.5（2026-08-07）模板仓化 + 单目录 + 同步机制

- 结构：方法论与管理机制全部收拢到 `模板/` 单目录（原根目录散落文件与 `_workspace/`、`02-数据/`、`03-知识输入/`、`04-工具/` 槽位移入）。
- 新增：`sync-template.ps1` 模板→实例同步机制（auto 覆盖 / manual 合并提示，front-matter 驱动）。
- 新增：`CHANGELOG.md` 版本管理；模板文件头部 front-matter（`<!-- 模板 vX.Y | sync: auto|manual | target: <实例路径> -->`）。
- 模板包独立 git 仓（init + 首提交；远端待配置）。

## v0.4（2026-08-07）实例实操回流（miiot_plugin_develop_system）

- 01-目录索引：强制绝对路径 + 可达性前提；数据目录统一 README+AGENTS。
- 新增 06-AI执行环境.md（沙箱/权限/审批边界）。
- 03-git管理：拓扑选择判据 + 入仓边界图 + 首次提交流程。
- 新增 02-数据 模板（README+AGENTS：登记表/绝对路径/可达性/索引清单）。
- 03-知识输入：登记 vs 复制决策点明确化。
- 续接文档模板：新增 Git 状态小节。
- 落地检查清单：阶段化 + 每项附验证方式 + 收尾（D6）步骤。
- .gitignore 补齐 *.secret/*.key/*.pem/*.log。

## v0.3（早期）实例目录聚合

- 每个 workspace 实例 = 一个自包含目录；`.code-workspace` 与 `_workspace/` 及根入口同目录。