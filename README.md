<!-- 模板 v1.1 | sync: manual | target: <实例根>/README.md -->
# <工作区名> · 工作区总览

这是工作区给人的入口。它说明目录分别存放什么，以及新建、维护这个工作区时应从哪里开始。

AI 入口见 `AGENTS.md`（Codex）和 `CLAUDE.md`（Claude Code）。两者都会指向 `_workspace/00-总入口.md`。

## 模板结构图

```text
<工作区名>/
|
|-- README.md                     人类入口：目录说明、使用方法和当前主线
|-- AGENTS.md / CLAUDE.md         AI 入口：指向全局规则
|-- <工作区名>.code-workspace     VS Code 工作区文件
|
|-- _workspace/                   治理区：规定如何管理这个工作区
|   |-- 00-总入口.md              AI 读取规则的起点
|   |-- 01-目录索引.md            所有目录的登记表
|   |-- 02-跨目录约束.md          只读边界、凭据和跨目录写入规则
|   |-- 03-git管理.md             仓库边界和提交约定
|   |-- 04-会话续接.md            中断后的续接规则
|   |-- 05-落地检查清单.md        新工作区的初始化检查项
|   |-- 06-09-*.md                AI 环境、挂载、文档和工具规则
|   |-- _handoff/                 当前任务和历史续接记录
|   |-- _表单/                    可复制使用的空表单
|   `-- _参考示例/                仅供参考的示例，不是强制目录
|
|-- 01-文档/                      正式文档、方案、记录（必选）
|-- 04-工具/                      脚本及其使用说明（必选）
|
|-- 02-数据/                      数据源登记与索引（可选，默认不创建）
`-- 03-知识输入/                  只读参考材料（可选，默认不创建）
```

`_workspace/` 管规则和任务记录，`01-文档/` 放人读产物，`04-工具/` 放可执行脚本。需要管理原始数据或外部资料时，再创建 `02-数据/` 和 `03-知识输入/`。

## 目录地图

| 目录 | 用途 | 是否默认创建 |
|---|---|---|
| `_workspace/` | 全局规则、目录索引、续接记录、表单和示例 | 是 |
| `01-文档/` | 需求、方案、会议记录、阶段产物等正式文档 | 是 |
| `04-工具/` | 可复用脚本、维护工具和使用说明 | 是 |
| `02-数据/` | 数据源登记、索引和访问说明；原始数据通常不入仓 | 否 |
| `03-知识输入/` | 只读参考资料及其索引 | 否 |

详细的绝对路径登记见 `_workspace/01-目录索引.md`。

## 使用方法

### 1. 通过 AI 创建和维护工作区

适用于希望让 AI 按模板完成创建、整理或续接的人。先在目标实例目录或其父目录启动 AI，再清楚说明目标和模板位置；不需要手动逐个创建目录。

| 场景 | 可以直接对 AI 说 | AI 应依据的文件 |
|---|---|---|
| 创建工作区 | “基于 `<模板仓路径>` 创建工作区 `<实例名>`，放在 `<父目录>`；不创建数据区和知识输入区。” | `模板说明.md`、`create-instance.ps1`、`_workspace/05-落地检查清单.md` |
| 创建含数据区的工作区 | “基于模板创建 `<实例名>`，同时创建 `02-数据` 和 `03-知识输入`。” | `create-instance.ps1` 的 `-IncludeOptionalZones` 说明 |
| 开始或续接任务 | “处理 `<任务>`。先读取当前工作区规则和 `_workspace/_handoff/README.md`，再开始。” | `AGENTS.md`、`_workspace/00-总入口.md`、`_workspace/_handoff/README.md` |
| 调整目录或迁移内容 | “把 `<内容>` 迁移到 `<目标目录>`；更新登记和引用，保留原始资料。” | `_workspace/01-目录索引.md`、`02-跨目录约束.md`、`08-通用文档管理原则.md` |

AI 应先读取规则，再说明会修改的文件和原因。涉及只读目录、删除归档、提交或推送时，AI 还必须遵守相应的确认边界。

### 2. 使用命令创建一个新工作区

在模板仓根目录运行以下命令。默认只创建治理区、文档区和工具区：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\create-instance.ps1 `
  -Name <实例名> `
  -Parent <父目录>
```

需要同时创建数据区和知识输入区时，加上 `-IncludeOptionalZones`：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\create-instance.ps1 `
  -Name <实例名> `
  -Parent <父目录> `
  -IncludeOptionalZones
```

脚本会生成 `<父目录>\<实例名>\` 和 `<实例名>.code-workspace`。打开该 `.code-workspace` 文件即可在 VS Code 中使用新工作区。

### 3. 初始化新工作区

创建后，按下面顺序完成首次配置：

1. 修改本 README 的 `<工作区名>`，补充目录地图和当前主线。
2. 在 `_workspace/01-目录索引.md` 登记实际目录及其绝对路径。
3. 在 `_workspace/02-跨目录约束.md` 登记只读目录、凭据边界和例外可写项。
4. 在 `_workspace/03-git管理.md` 选择仓库拓扑，并按 `_workspace/05-落地检查清单.md` 完成验证和首次提交。

### 4. 日常工作

- 文档写入 `01-文档/`；脚本写入 `04-工具/`；原始数据和参考资料先按只读规则登记。
- 新会话先查看 `_workspace/_handoff/README.md` 的“当前主线 / 下一任务”。任务没有完成时，在 `_handoff/` 更新续接文档。
- 新增、移动或重命名目录后，同步更新目录索引、挂载登记和相关引用。
- 修改 VS Code 挂载项时，只编辑 `_workspace/07-VSCode工作区挂载登记.md` 的 JSON 块，再运行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\04-工具\sync-vscode-workspace.ps1 -DryRun
```

确认预览正确后，去掉 `-DryRun` 执行同步。

### 5. 接收模板更新

在模板仓根目录先比较差异：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\sync-template.ps1 `
  -Instance <实例目录>
```

输出为 `sync: auto` 的文件可以使用 `-Apply` 更新；`sync: manual` 的文件只能人工合并，因为其中包含实例自己的路径、约束或业务信息。

## 硬约束

- 凭据、token、私钥不得写入文档或提交到 Git。
- 被登记为只读的目录不得修改；跨目录写入默认写回所属目录。
- 未经确认不得执行 `git push`，也不得删除或归档目录。

完整规则以 `_workspace/00-总入口.md` 和 `_workspace/02-跨目录约束.md` 为准。

## 当前主线

<本阶段在推进什么；无进行中任务时写“无”，并指向 `_workspace/_handoff/README.md`。>
