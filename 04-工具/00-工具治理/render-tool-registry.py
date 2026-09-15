#!/usr/bin/env python3
"""Render the human-readable tool registry from the canonical JSON source."""

from __future__ import annotations

import json
from pathlib import Path


TOOL_ROOT = Path(__file__).resolve().parents[1]
SOURCE = TOOL_ROOT / "tool-registry.json"
TARGET = TOOL_ROOT / "tool-registry.md"
SCOPE_ORDER = ("公共工具", "分析专用工具", "历史工具")


def cell(value: object) -> str:
    if isinstance(value, list):
        return "、".join(str(item) for item in value) if value else "-"
    return str(value).replace("|", "\\|").replace("\n", "<br>")


def tool_row(tool: dict[str, object]) -> str:
    return "| " + " | ".join(
        cell(tool[key])
        for key in (
            "id",
            "name",
            "lifecycle",
            "execution_policy",
            "risk_level",
            "path",
            "keywords",
            "input_contract",
            "output_contract",
            "artifact_ids",
            "last_verified",
        )
    ) + " |"


def main() -> None:
    registry = json.loads(SOURCE.read_text(encoding="utf-8"))
    tools = registry["tools"]
    lines = [
        "# 工具注册表",
        "",
        "> **状态**：人读视图，由 [`tool-registry.json`](tool-registry.json) 自动生成。不得直接编辑本文件。",
        ">",
        "> **唯一登记源**：`tool-registry.json`。新增、移动、弃用或修改输入输出边界时，先修改 JSON，再运行 `validate-tool-registry.py` 校验和 `render-tool-registry.py` 渲染。工具 ID 一经分配不得复用。",
        "",
        "## 使用入口",
        "",
        "```powershell",
        "# 在 04-工具 目录内按关键词检索现役、冻结和历史工具",
        "& .\\find-tool.ps1 -Keyword 关键词",
        "",
        "# 修改登记源后，先校验，再重建本文件",
        "python .\\00-工具治理\\validate-tool-registry.py",
        "python .\\00-工具治理\\render-tool-registry.py",
        "```",
        "",
        "## 生命周期",
        "",
        "| 状态 | 含义 | 是否可作为新任务入口 |",
        "|---|---|---|",
        "| 草稿 | 已预登记，尚未完成验证。 | 否 |",
        "| 现役 | 已验证，可按登记边界使用。 | 是 |",
        "| 冻结 | 当前版本仅保留证据或待参数化，禁止直接用于新任务。 | 否 |",
        "| 历史 | 仅用于复现已采纳的历史结果。 | 否 |",
        "| 废弃 | 已被替代；保留登记，不执行。 | 否 |",
        "",
        "## 工具清单",
        "",
    ]
    header = "| 工具 ID | 名称 | 生命周期 | 运行限制 | 风险 | 路径 | 关键词 | 输入契约 | 输出契约 | 产物 ID | 最后验证 |"
    separator = "|---|---|---|---|---|---|---|---|---|---|---|"
    for scope in SCOPE_ORDER:
        scoped_tools = [tool for tool in tools if tool["scope"] == scope]
        if not scoped_tools:
            continue
        lines.extend([f"### {scope}", "", header, separator])
        lines.extend(tool_row(tool) for tool in scoped_tools)
        lines.append("")
    lines.extend(
        [
            "## 登记要求",
            "",
            "1. 正式工具必须有稳定 ID、脚本路径、输入输出契约、运行限制、风险、最小命令、验证方式和最后验证日期。",
            "2. 临时目录（按实例约定，如 `D:\\tmp`）、缓存、日志、一次性中转文档、数据快照、Excel、CSV、JSON 产物不得登记为正式工具。",
            "3. 分析专用工具必须关联数据产物 ID；公共工具不得依赖某一阶段的固定快照或字段口径。",
            "4. 新工具先预登记为“草稿”，通过验证后才可改为“现役”。固定历史快照脚本应标记为“冻结”或“历史”。",
            "5. 运行前先使用 `find-tool.ps1` 检索关键词。发现同类工具时，先评估扩展现有工具，不重复新建。",
            "",
        ]
    )
    TARGET.write_text("\n".join(lines), encoding="utf-8", newline="\n")
    print(TARGET)


if __name__ == "__main__":
    main()
