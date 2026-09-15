<!-- 模板 v1.3 | sync: manual | target: <实例>/04-工具/README.md -->
# 04-工具（脚本与使用文档）

存放可运行的维护/自动化脚本及使用说明（ps1/py/sql 等）。

## 约定

- 脚本 + 使用说明 README 放本目录；说明性方案文档归 `01-文档/`。
- 凭据、token 禁止入脚本与 git。
- 涉及外部平台数据的脚本须遵守全局规则（如小米 IOT 数据约束）。
- 建议独立 git 仓（拓扑 A）或按需入仓；构建产物/缓存排除。

## 入口

- AI：`AGENTS.md` → `_workspace/00-总入口.md`

## VS Code 工作区挂载同步

- 脚本：`03-工作区治理/sync-vscode-workspace.ps1`（PowerShell 5.1 兼容，UTF-8 BOM）
- 作用：把「VS Code 挂载登记表」(`_workspace\07-VSCode工作区挂载登记.md` 的 json 块)幂等同步到 `.code-workspace` 的 `folders` 段；`settings` 等其他顶层字段不动。
- 默认路径按 `$PSScriptRoot` 推导：脚本位于实例 `04-工具\03-工作区治理\` 下即可直接运行（登记表按 `*VSCode工作区挂载登记.md` 通配）。
- 行为：**无变化时不写文件**（保持现状与时间戳）；`-DryRun` 只预览；`folders` 为覆盖式（以登记表为唯一真相，手改 `.code-workspace` 的 folders 会被覆盖）。
- 同目录配套：`test-handoff-index.ps1`（续接索引唯一性校验，发现冲突报 `HOF-001`；用法见 `_workspace/05-落地检查清单.md`）。

```powershell
# 预览将发生的变更（不写文件）
& .\03-工作区治理\sync-vscode-workspace.ps1 -DryRun

# 执行同步
& .\03-工作区治理\sync-vscode-workspace.ps1
```

## 工具注册与检索

- 注册表：`tool-registry.json`（**唯一登记源**，规则见 `_workspace/09-工具管理.md`；先检索后新建）
- 检索：`find-tool.ps1 -Keyword <关键词>`（或直接读注册表）
- 校验与渲染：`00-工具治理/validate-tool-registry.py` → `render-tool-registry.py`（改 JSON 后先校验再重建 `tool-registry.md`；Python 3 标准库）
- 机器可读保护镜像：`00-工具治理/protected-paths.json`（批量/整理脚本读它做路径排除，不硬编码；与 `_workspace/02-跨目录约束.md` 清单同步维护）
- 登记判据（满足任一即登记）：可跨阶段复用 / 生成正式产物或决策证据 / 修改复制下载数据 / 需他人发现复跑维护
- 纯文档实例可清空注册表 `tools` 数组；一次性临时脚本放系统临时区，不登记
