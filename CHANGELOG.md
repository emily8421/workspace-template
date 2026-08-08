## v1.0（2026-08-08）模板优化落地（通用原则 + 空表单 + 参考区 + 最小骨架）

> 依据 `模板优化建议-20260808.md`（实例会话复盘，2026-08-08 全量落地）。**模板 = 通用文档管理骨架；业务目录 = 实例自由区。**

- **A 通用原则入规则**：新增 `_workspace/08-通用文档管理原则.md`（sync: auto，A1-A6：事实源锚点 / 范围变更整体归档 / 断链检查 / handoff 主线程指针 / 脚本路径从配置读 / 处理可追溯）。`00-总入口.md` 读取顺序补 08；`04-会话续接.md` 必含小节补「当前主线/下一任务」+ 主线程指针规则；`_handoff/_模板-续接文档.md` 与 `_handoff/README.md` 补主线程指针字段/行；`05-落地检查清单.md` A3 断链检查强化（迁移/改名后 `rg -n` 必查）。
- **B 空表单库**：新增 `_workspace/_表单/`（README + `_模板-数据源登记表.md` B1 + `_模板-需求文档雏形.md` B3，均 sync: auto / manual），去业务字段。
- **C 实例参考区**：新增 `_workspace/_参考示例/`（README + 分盘数据地图 C1 + 需求区标准骨架 C2 + URS与数据清洗要求 C3，sync: manual，<实例> 占位），明确「示例，非规则」。
- **D 顶层最小骨架 + 可选区**：`create-instance.ps1` 加 `-IncludeOptionalZones` 开关（默认只建 `_workspace` + `01-文档` + `04-工具`）；`07-VSCode工作区挂载登记.md` json 块 02/03 改 `mount: false`（可选区仅登记）；`01-目录索引.md` / `03-git管理.md` / `05-落地检查清单.md` / `06-AI执行环境.md` 目录措辞改「核心 + 可选区按需」；02-数据/03-知识输入/01-文档 README 加可选区标注与 B1 指针。
- 全部模板文件 front-matter 统一升至 v1.0；`模板优化建议-20260808.md` 标注「已落地」。
- `模板说明.md` 加「一分钟看懂」总览：mermaid 流程图 + 一句话工作流 + 读者指引，通俗化入口说明。

## v0.9（2026-08-07）Claude Code 桥接（CLAUDE.md 入口）

- 新增根 `CLAUDE.md`（sync: manual）：Claude Code 专属入口（不读 AGENTS.md），实例根 `@` 导入 `_workspace\00-总入口.md`（实例化时替换为绝对路径）；Claude 从实例任意子目录启动都能被引导。
- 新增 `_workspace/CLAUDE.md`（sync: manual）：治理仓内 Claude 桥接，`@AGENTS.md` 链回治理入口。
- `_workspace/00-总入口.md` AI 引导机制小节补充 Claude Code 发现规则（向上逐层查 CLAUDE.md、跨 git 边界、@导入桥接）；新目录引导三件事并入 Claude 侧要求。
- `_workspace/01-目录索引.md` 登记约定补充「Claude 侧同目录需配 CLAUDE.md 桥接」；`07-VSCode工作区挂载登记.md` 挂载≠引导说明补 Claude 相关。
- 根 AGENTS.md / README.md / 模板-folder-AGENTS.md / 模板说明.md front-matter 升 v0.9。

## v0.8（2026-08-07）AI 引导机制（AGENTS.md 入口 + 引导三件事）

- 新增 `_workspace/AGENTS.md`（sync: manual）：治理仓库自身入口，链回 `00-总入口.md`，保证从 `_workspace` 及其子目录启动也有引导（git 根边界内自动加载）。
- `_workspace/00-总入口.md` 增加「AI 引导机制」小节：AGENTS.md 发现规则（git 根向下 / 非 git 只查当前目录）+ 新目录引导三件事。
- `_workspace/01-目录索引.md`：`_workspace` 行入口改为 `AGENTS.md`（→ `00-总入口.md`）；登记约定补充 AI 引导三件事与「挂载≠引导」注意。
- `_workspace/07-VSCode工作区挂载登记.md` 增加「挂载 ≠ AI 引导」说明；根 AGENTS.md 增加引导边界说明。
- 全部模板文件 front-matter 统一升至 v0.8（含 README / 模板-folder-AGENTS.md）。

## v0.7（2026-08-07）新增 VS Code 挂载机制

- 新增 `_workspace/07-VSCode工作区挂载登记.md`（sync: manual）：挂载登记表 = `.code-workspace` folders 唯一真相，预填 5 个骨架目录，新实例首跑即「已是最新」。
- 新增 `04-工具/sync-vscode-workspace.ps1`：`$PSScriptRoot` 推导式默认路径（登记表通配兼容实例 06 / 模板 07），幂等同步、`-DryRun`、settings 保留。
- `04-工具/README.md` 增加「VS Code 工作区挂载同步」小节；模板说明升 v0.7。
- 模板 `_workspace/00-总入口.md` 增加「VS Code 工作区挂载」小节（登记 07 机制）。

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