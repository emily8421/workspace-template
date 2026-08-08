<!-- 模板 v1.0 | sync: manual | target: <实例根>/AGENTS.md -->
# AI Agent 入口（工作区根）

从本工作区任意位置启动 AI 前，先读取并遵守：

1. `_workspace\00-总入口.md`（全局规则唯一入口）
2. 按 00-总入口 的读取顺序阅读 `_workspace\` 下编号规则
3. 当前所在目录的 `AGENTS.md` / `README.md` 与自有规则（如有）

新开会话先查 `_workspace\_handoff\README.md`（会话续接索引）。
续接文档统一写入 `_workspace\_handoff\<目录名>\`。

> 引导边界：`_workspace\` 是独立 git 仓库，AI 在其中启动只会自动加载 `_workspace\AGENTS.md`（治理仓自身入口，链回 00-总入口）；各子目录另有自己的 `AGENTS.md` 链回同一入口。Claude Code 不读 AGENTS.md：Claude 侧靠根 `CLAUDE.md` 与 `_workspace\CLAUDE.md` 桥接（`@` 导入 `00-总入口.md`）。