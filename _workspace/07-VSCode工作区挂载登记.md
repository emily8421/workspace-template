<!-- 模板 v1.1 | sync: manual | target: _workspace/07-VSCode工作区挂载登记.md -->
# VS Code 工作区挂载登记（模板）

- 性质：`.code-workspace` 挂载项的**唯一真相**。由 `04-工具\sync-vscode-workspace.ps1` 读取并同步到 `.code-workspace` 的 `folders` 段。
- 变更方式：**只改本文件的 json 块**，再运行同步脚本；不要手改 `.code-workspace` 的 `folders`（会被下次同步覆盖）。`settings` 等其他字段脚本不动，可自行维护。
- path 基准：相对 `.code-workspace` 所在目录（实例根）；绝对路径原样写（如 `E:/...`）。
- 顺序：json 数组顺序 = VS Code 侧边栏显示顺序。
- 实例化：`create-instance.ps1` 默认生成核心骨架 `_workspace` + `01-文档` + `04-工具`（下方 json 块预填，`mount: true`），新实例首跑即「已是最新」。`02-数据`/`03-知识输入` 为**可选区**：默认不建、json 预填 `mount: false`（仅登记不挂载）；加 `-IncludeOptionalZones` 创建时自动改 `mount: true` 并挂载。实例后续自行增删可选区时，改 json 的 `mount` 再跑同步脚本。外部目录按需追加，`mount: false` 表示仅登记不挂载。

## 字段

| 字段 | 含义 |
|---|---|
| `name` | VS Code 侧边栏显示名 |
| `path` | 挂载路径（相对实例根，或绝对路径） |
| `type` | 类型（治理/文档/数据/知识/工具/代码/模板） |
| `purpose` | 用途说明（人读） |
| `mount` | `true`=挂载进工作区；`false`=仅登记不挂载 |

## 挂载项

> 示例（外部目录 / 绝对路径）：`{ "name": "外部数据盘", "path": "E:/external-data", "type": "数据", "purpose": "外部盘数据", "mount": true }`

```json
[
  { "name": "_workspace", "path": "_workspace", "type": "治理", "purpose": "全局规则/索引/git/续接", "mount": true },
  { "name": "01-文档", "path": "01-文档", "type": "文档", "purpose": "学习/方案/文档", "mount": true },
  { "name": "04-工具", "path": "04-工具", "type": "工具", "purpose": "维护/自动化脚本", "mount": true },
  { "name": "02-数据", "path": "02-数据", "type": "数据", "purpose": "数据源登记表（可选区，按需）", "mount": false },
  { "name": "03-知识输入", "path": "03-知识输入", "type": "知识", "purpose": "只读参考依据（可选区，按需）", "mount": false }
]
```

## 用法

```powershell
# 预览将发生的变更（不写文件）
& .\04-工具\sync-vscode-workspace.ps1 -DryRun

# 执行同步
& .\04-工具\sync-vscode-workspace.ps1
```

> 同步后 VS Code 会提示「工作区已更改，重新加载」。无变化时脚本不写文件。

## 注意：挂载 ≠ AI 引导

把目录加进 `.code-workspace` 只影响 VS Code 显示与挂载边界，不会让 AI CLI 自动读取治理规则。AI 引导靠各目录自身的 `AGENTS.md`（Codex）/ `CLAUDE.md`（Claude，不读 AGENTS.md）链回 `_workspace\00-总入口.md`；新目录引导三件事见 `01-目录索引.md` 登记约定。

## settings 基线（版本化记录）

`.code-workspace` 位于实例根；拓扑 A 下实例根非 git 仓，`settings` 段无人版本管理，易漂移丢失。本节做版本化记录，约定：**手改 `.code-workspace` 的 `settings` 段时，同步在本表加一行**（`folders` 段由挂载登记 + 同步脚本维护，不在本节记录）。

| 日期 | settings 摘要 | 说明 |
|---|---|---|
| <YYYY-MM-DD> | <改了哪些键，如 `files.exclude` 增 `**/.cache`> | <为什么改> |

> 注：保护目录的编辑器软保护（`files.readonlyInclude`）同样非强制、有局限（多根工作区对整目录根不生效），约束以 `02-跨目录约束.md` 为准。