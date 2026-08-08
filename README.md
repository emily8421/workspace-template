<!-- 模板 v1.0 | sync: manual | target: <实例根>/README.md -->
# <工作区名> · 工作区总览

> 本文件是工作区**人类入口**：了解这个空间有哪些目录、各自装什么、怎么用。
> AI 入口见 `AGENTS.md`（Codex）/ `CLAUDE.md`（Claude），均指向 `_workspace/00-总入口.md`。

## 这个工作区解决什么问题

<1-3 句>

## 目录地图

| 目录 | 类型 | 用途 | 入口 | 只读 |
|---|---|---|---|---|
| <目录> | 文档/数据/代码/工具/治理/知识/归档 | <用途> | README.md / AGENTS.md | 是/否 |

> 可选区（02-数据 / 03-知识输入）按需启用；详细索引与新增目录登记：`_workspace/01-目录索引.md`

## 怎么用

- 人看：按目录地图进入对应目录 README。
- AI：Codex 任意目录进入后自动读 AGENTS.md → `_workspace/00-总入口.md`；Claude Code 读 CLAUDE.md（根 `CLAUDE.md` / `_workspace/CLAUDE.md` 桥接同一入口）。
- 新会话：先看 `_workspace/_handoff/README.md` 是否有未完成任务续接。

## 硬约束（摘要）

- 保护目录：<列>
- 凭据：禁入 git 与文档
- 跨目录：读允许、写回所属目录
> 详见 `_workspace/02-跨目录约束.md`

## 当前主线

<本阶段在推进什么，链接到相关目录>