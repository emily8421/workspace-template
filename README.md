# 文件工作区管理模板（_workspace-template）

> 版本：v0.5　|　模板仓：独立 git 仓　|　适用：多目录 + AI CLI 协作的工作区

面向「多目录 + AI CLI 协作」的工作区治理模板。**方法论与管理机制全部在 `模板/` 单目录**，实例化时复制并按需填写；版本与同步见下。

## 模板结构（一个内容目录）

| 路径 | 说明 |
|---|---|
| `模板/00-总入口.md` ~ `06-*.md` | 治理规则（复制到实例 `_workspace/`） |
| `模板/模板-工作区*.md` | 实例根 README / AGENTS / code-workspace 模板 |
| `模板/目录骨架/` | 各业务目录 README+AGENTS 骨架（01-文档/02-数据/03-知识输入/04-工具） |
| `模板/_handoff/` | 会话续接文档模板与索引 |
| `模板/参考/` | 实例化参考（落地计划/说明） |
| `sync-template.ps1` | 模板→实例同步脚本 |
| `CHANGELOG.md` | 版本历史 |

## 版本管理

- 版本号 `v<主>.<次>`，历史见 `CHANGELOG.md`。
- 每个模板文件头部带 front-matter：`<!-- 模板 vX.Y | sync: auto/manual | target: <实例路径> -->`。
- 修改模板后：小改升次号（v0.5 → v0.6），结构/机制变化升主号；并登记 CHANGELOG。

## 使用方法（新工作区）

1. 克隆/复制本仓。
2. 建实例目录 `<实例名>/`；`模板/` 下编号规则 → 实例 `_workspace/`；`模板-工作区*` → 实例根；`目录骨架/*` → 实例各目录。
3. 按 `模板/05-落地检查清单.md` 走阶段 1-4 落地。
4. 实例独立 git 拓扑见 `模板/03-git管理.md`。

## 同步最新版本到实例

```powershell
# 查看模板与实例差异（dry-run，不改动实例）
& sync-template.ps1 -Instance D:\...\<实例名>

# 应用 auto 类文件（模板权威，覆盖实例对应文件）
& sync-template.ps1 -Instance D:\...\<实例名> -Apply

# 只处理单个模板文件
& sync-template.ps1 -Instance D:\...\<实例名> -File 06-AI执行环境.md -Apply
```

- `sync: auto`：模板权威，可安全覆盖（`04-会话续接.md` / `06-AI执行环境.md` / `05-落地检查清单.md` / `_handoff/_模板-续接文档.md`）。
- `sync: manual`：实例化文件（目录索引/跨目录约束/git 管理/README/AGENTS/目录骨架等），脚本只报告差异，**需人工合并**。
- 同步前建议确认实例各仓 git 状态干净；同步后按 `03-git管理.md` 提交。