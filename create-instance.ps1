<#
  create-instance.ps1 — 从模板仓创建新工作区实例（v0.6）

  用法：
    & create-instance.ps1 -Name <实例名> [-Parent <父目录>] [-From <模板仓路径>]

  行为：
    1. 复制模板骨架到 <Parent>/<Name>（排除模板自身文件：.git、.gitignore、模板说明.md、CHANGELOG.md、sync-template.ps1、create-instance.ps1）
    2. 生成 <Name>.code-workspace（含骨架目录，外部目录按实例自行添加）
    3. 提示按 _workspace/05-落地检查清单.md 落地
#>
param(
  [Parameter(Mandatory = $true)][string]$Name,
  [string]$Parent,
  [string]$From
)
$ErrorActionPreference = 'Stop'
if (-not $From) { $From = $PSScriptRoot }
if (-not $Parent) { $Parent = (Get-Location).Path }
$dest = Join-Path $Parent $Name
if (Test-Path -LiteralPath $dest) { throw "目标已存在: $dest" }
if (-not (Test-Path -LiteralPath $From)) { throw "模板仓不存在: $From" }

New-Item -ItemType Directory -Force -Path $dest | Out-Null
$exclude = @('.git', '.gitignore', '模板说明.md', 'CHANGELOG.md', 'sync-template.ps1', 'create-instance.ps1')
Get-ChildItem -LiteralPath $From -Force | Where-Object { $_.Name -notin $exclude } | ForEach-Object {
  Copy-Item -LiteralPath $_.FullName -Destination $dest -Recurse -Force
}

# 生成 <Name>.code-workspace
$dirs = @('_workspace', '01-文档', '02-数据', '03-知识输入', '04-工具')
$folders = ($dirs | ForEach-Object { "`t`t{ `"name`": `"$_`", `"path`": `"$_`" }" }) -join ",`r`n"
$ws = "{
`t`"folders`": [
$folders
`t],
`t`"settings`": {
`t`t`"files.exclude`": {
`t`t`t`"**/.git`": true,
`t`t`t`"**/node_modules`": true,
`t`t`t`"**/__pycache__`": true
`t`t}
`t}
}"
[System.IO.File]::WriteAllText((Join-Path $dest "$Name.code-workspace"), $ws, (New-Object System.Text.UTF8Encoding($true)))
Remove-Item -LiteralPath (Join-Path $dest '模板-工作区.code-workspace') -Force

"实例已创建: $dest"
"下一步：按 $dest\_workspace\05-落地检查清单.md 走阶段 1-4（git init、填目录索引/跨目录约束、入口链验证、首提交）。"