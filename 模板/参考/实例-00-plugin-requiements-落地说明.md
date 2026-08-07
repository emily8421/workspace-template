# 实例评估与落地说明：00-plugin-requiements

> 日期：2026-08-07　性质：模板以本工作区为实例的评估 + 已落地清单 + 可选后续。

## 一、三条需求 vs 实例现状

| 需求 | 实例现状 | 评估 |
|---|---|---|
| 1. 全局认识/唯一入口/任一目录进入可获概况 | 已有 `_ai-global/00-总入口.md`（唯一入口）+ `_ai-global/03-folder索引.md`（目录地图）；多数 folder 有 `AGENTS.md` 转发；`03-newer_knowledge/00-AI规则/` 有 folder 规则 | 基本达标；缺口：**工作区根目录无 README/AGENTS（从根进入无概况）**；索引缺 `03-spec-basic-data`、缺类型/入口/git 列；两个数据目录（`01-plugin-basic-data`、`03-spec-basic-data`）无 AI 入口 |
| 2. Git 管理机制 | 多仓实践：`_ai-global`、`03-newer_knowledge` 各为独立仓；数据镜像自带各 clone 的 `.git`；各有 `.gitignore` | 有实践无机制文档：缺统一「仓库拓扑/提交约定/禁入清单」说明；提交约定靠习惯（实际已用 Conventional Commits） |
| 3. 会话续接机制 | `_ai-global/_handoff/`：文档模板 + 索引 README + 生命周期，规范见 `_ai-global/01-续接文档管理.md` | 已达标，是模板的范本；可选加强：全局入口加「新会话先查续接索引」提示 |

## 二、本次落地（全部为新增，未修改任何现有文档）

| 新增 | 位置 | 作用 |
|---|---|---|
| 工作区根 `README.md` | `00-plugin-requiements/` | 人类入口：目录地图/使用方式/硬约束摘要/模板指引 |
| 工作区根 `AGENTS.md` | `00-plugin-requiements/` | AI 入口：先读 `_ai-global/00-总入口.md`，再读所在目录规则；新会话先查 `_handoff/README.md` |
| 模板包 | `_workspace-template/` | 可整体复制到新工作区的治理模板（`_workspace/` 骨架 + 根/目录模板 + 落地检查清单） |

## 三、模板与实例的对应关系

| 模板 | 实例现有实现 |
|---|---|
| `_workspace/00-总入口.md` | `_ai-global/00-总入口.md` |
| `_workspace/01-目录索引.md` | `_ai-global/03-folder索引.md` |
| `_workspace/02-跨目录约束.md` | `_ai-global/02-保护目录与跨folder约束.md` |
| `_workspace/03-git管理.md` | 缺失（本次仅模板，实例未落） |
| `_workspace/04-会话续接.md` | `_ai-global/01-续接文档管理.md` |
| `_workspace/_handoff/` | `_ai-global/_handoff/` |
| 根 README/AGENTS | 本次新增（此前缺失） |

## 四、可选后续（未执行，避免改动现有文档）

1. 全局索引补登记：`_ai-global/03-folder索引.md` 增加 `03-spec-basic-data` 行，并补「类型/入口/git」列。
2. 数据目录补入口：`01-plugin-basic-data/`、`03-spec-basic-data/` 各补一份 `AGENTS.md`（只读说明 + 指向全局入口）。
3. 全局入口加提示：`_ai-global/00-总入口.md` 增加「新会话先读 `_handoff/README.md`」。
4. Git 机制文档化：把 `03-git管理.md` 内容并入 `_ai-global`（如新增编号规则 `05-git管理.md`），填实例仓库登记表。
5. 根 `README.md` 与 `_ai-global/03-folder索引.md` 建立互链（各加一行指向）。