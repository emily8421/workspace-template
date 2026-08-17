<!-- 模板 v1.1 | sync: manual | target: <实例>/04-工具/README.md -->
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

- 脚本：`sync-vscode-workspace.ps1`（PowerShell 5.1 兼容，UTF-8 BOM）
- 作用：把「VS Code 挂载登记表」(`_workspace\07-VSCode工作区挂载登记.md` 的 json 块)幂等同步到 `.code-workspace` 的 `folders` 段；`settings` 等其他顶层字段不动。
- 默认路径按 `$PSScriptRoot` 推导：脚本放任意实例的 `04-工具\` 下即可直接运行（登记表按 `*VSCode工作区挂载登记.md` 通配，兼容实例编号 06 / 模板编号 07）。
- 行为：**无变化时不写文件**（保持现状与时间戳）；`-DryRun` 只预览；`folders` 为覆盖式（以登记表为唯一真相，手改 `.code-workspace` 的 folders 会被覆盖）。

```powershell
# 预览将发生的变更（不写文件）
& .\sync-vscode-workspace.ps1 -DryRun

# 执行同步
& .\sync-vscode-workspace.ps1
```

## 工具注册与检索

- 注册表：`tool-registry.json`（**唯一登记源**，规则见 `_workspace/09-工具管理.md`；先检索后新建）
- 检索：`find-tool.ps1 -Keyword <关键词>`（或直接读注册表）
- 登记判据（满足任一即登记）：可跨阶段复用 / 生成正式产物或决策证据 / 修改复制下载数据 / 需他人发现复跑维护
- 纯文档实例可保持注册表为空；一次性临时脚本放系统临时区，不登记
