<!-- 模板 v1.1 | sync: manual | target: <实例根>/CLAUDE.md -->
# AI Agent 入口（Claude Code · 实例根）

Claude Code 的规则入口与 Codex 不同：Codex 读 `AGENTS.md`（见同目录同名文件），Claude Code 读 `CLAUDE.md`（不读 AGENTS.md），从启动目录向上逐层查找、跨 git 边界、项目根优先于上层。实例根放本文件后，从本工作区任意子目录启动 Claude 都会被引导。

> 实例化必改：把下方 `@` 后的 `<工作区根>/<实例名>` 替换为真实绝对路径（用正斜杠），如 `D:/<工作区根>/<实例名>/_workspace/00-总入口.md`；不替换则导入不生效。

@<工作区根>/<实例名>/_workspace/00-总入口.md