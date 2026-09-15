#!/usr/bin/env python3
"""Validate the canonical tool registry and registered script locations."""

from __future__ import annotations

import json
import re
import sys
from argparse import ArgumentParser
from pathlib import Path


TOOL_ROOT = Path(__file__).resolve().parents[1]
WORKSPACE_ROOT = TOOL_ROOT.parent
REGISTRY = TOOL_ROOT / "tool-registry.json"
# 专用工具目录（scope=分析专用工具 的存放根）：按实例目录结构修改此行。
# 无专用工具目录的实例可保持占位值（注册表无该 scope 条目时不参与实际校验）。
ANALYSIS_TOOL_ROOT = WORKSPACE_ROOT / "01-文档/00-分析工具"
REQUIRED = {
    "id",
    "name",
    "scope",
    "lifecycle",
    "execution_policy",
    "risk_level",
    "owner_role",
    "path",
    "keywords",
    "input_contract",
    "output_contract",
    "artifact_ids",
    "minimal_command",
    "verification",
    "last_verified",
    "notes",
}
SCOPES = {"公共工具", "分析专用工具", "历史工具"}
LIFECYCLES = {"草稿", "现役", "冻结", "历史", "废弃"}
RISKS = {"低", "中", "高"}
ID_RE = re.compile(r"^(PUB|ANL)-[A-Z]+-\d{3}$")
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")


def expected_prefix(scope: str) -> str:
    if scope == "公共工具":
        return "04-工具/"
    return ANALYSIS_TOOL_ROOT.relative_to(WORKSPACE_ROOT).as_posix() + "/"


def main() -> int:
    parser = ArgumentParser(description="Validate a tool registry JSON file.")
    parser.add_argument("--registry", type=Path, default=REGISTRY, help="Registry JSON to validate.")
    args = parser.parse_args()
    registry_path = args.registry.resolve()
    errors: list[str] = []
    try:
        registry = json.loads(registry_path.read_text(encoding="utf-8-sig"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"ERROR cannot read registry {registry_path}: {exc}")
        return 1

    if registry.get("schema_version") != "1.0":
        errors.append("schema_version must be 1.0")
    tools = registry.get("tools")
    # 空注册表合法（纯文档实例可保持为空）；非数组才报错。
    if not isinstance(tools, list):
        errors.append("tools must be an array")
        tools = []

    ids: set[str] = set()
    paths: set[str] = set()
    path_owners: dict[str, list[str]] = {}
    for index, tool in enumerate(tools, start=1):
        label = f"tools[{index}]"
        if not isinstance(tool, dict):
            errors.append(f"{label} must be an object")
            continue
        missing = REQUIRED - tool.keys()
        if missing:
            errors.append(f"{label} missing fields: {', '.join(sorted(missing))}")
            continue
        tool_id = tool["id"]
        path = tool["path"]
        scope = tool["scope"]
        if not isinstance(tool_id, str) or not ID_RE.fullmatch(tool_id):
            errors.append(f"{label} invalid id: {tool_id!r}")
        elif tool_id in ids:
            errors.append(f"duplicate id: {tool_id}")
        else:
            ids.add(tool_id)
        if scope not in SCOPES:
            errors.append(f"{tool_id} invalid scope: {scope!r}")
        elif not str(path).replace('\\', '/').startswith(expected_prefix(scope)):
            errors.append(f"{tool_id} path is outside its scope: {path}")
        if tool["lifecycle"] not in LIFECYCLES:
            errors.append(f"{tool_id} invalid lifecycle: {tool['lifecycle']!r}")
        if tool["risk_level"] not in RISKS:
            errors.append(f"{tool_id} invalid risk level: {tool['risk_level']!r}")
        if not isinstance(tool["keywords"], list) or not tool["keywords"]:
            errors.append(f"{tool_id} must have keywords")
        if not isinstance(tool["artifact_ids"], list):
            errors.append(f"{tool_id} artifact_ids must be an array")
        if not DATE_RE.fullmatch(str(tool["last_verified"])):
            errors.append(f"{tool_id} invalid last_verified date: {tool['last_verified']!r}")
        normalized_path = str(path).replace('\\', '/')
        paths.add(normalized_path)
        path_owners.setdefault(normalized_path, []).append(tool_id)
        # 临时根按实例约定（下方 d:/tmp 为示例默认，实例可改）：
        # 登记为正式工具的脚本不得放在临时区。
        if "d:/tmp" in normalized_path.lower() or "d:\\tmp" in str(path).lower():
            errors.append(f"{tool_id} must not register a temp path: {path}")
        absolute_path = WORKSPACE_ROOT / Path(*normalized_path.split('/'))
        if not absolute_path.is_file():
            errors.append(f"{tool_id} registered path does not exist: {path}")
        if scope == "历史工具" and tool["lifecycle"] != "历史":
            errors.append(f"{tool_id} historical scope must use lifecycle 历史")
        if scope == "分析专用工具" and tool["lifecycle"] == "现役" and not tool["artifact_ids"]:
            errors.append(f"{tool_id} active analysis tool must have artifact_ids")

    # 同路径多工具：须全部显式声明同一 shared_generator，否则视为意外重复
    for normalized_path, owner_ids in path_owners.items():
        if len(owner_ids) < 2:
            continue
        markers = {t.get("shared_generator") for t in tools if t["id"] in owner_ids}
        if len(markers) != 1 or "" in markers or None in markers:
            errors.append(
                f"duplicate path shared without matching shared_generator: "
                f"{normalized_path} ({', '.join(owner_ids)})"
            )

    script_paths: set[str] = set()
    for root in (TOOL_ROOT, ANALYSIS_TOOL_ROOT):
        if not root.is_dir():
            continue
        for file_path in root.rglob("*"):
            if not file_path.is_file() or file_path.suffix.lower() not in {".py", ".ps1"}:
                continue
            if "__pycache__" in file_path.parts:
                continue
            relative = file_path.relative_to(WORKSPACE_ROOT).as_posix()
            script_paths.add(relative)
    unregistered = sorted(script_paths - paths)
    if unregistered:
        errors.append("unregistered scripts: " + ", ".join(unregistered))
    missing_scripts = sorted(paths - script_paths)
    if missing_scripts:
        errors.append("registered paths are not recognized scripts: " + ", ".join(missing_scripts))

    if errors:
        print("TOOL_REGISTRY_INVALID")
        for error in errors:
            print(f"- {error}")
        return 1
    print(f"TOOL_REGISTRY_OK tools={len(tools)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
