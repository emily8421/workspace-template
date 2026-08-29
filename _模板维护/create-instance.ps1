<#
  create-instance.ps1 — 从模板仓创建新工作区实例（v1.2）

  位置：_模板维护\create-instance.ps1（模板仓自身脚本，不复制进实例）。

  用法：
    & _模板维护\create-instance.ps1 -Name <实例名> [-Parent <父目录>] [-From <模板仓路径>] [-IncludeOptionalZones]

  行为：
    1. 复制模板骨架到 <Parent>/<Name>（模板仓根扫描；排除模板自身文件：
       .git、.gitignore、.claude、_模板维护/、模板说明.md、使用手册.md、CHANGELOG.md）
    2. 生成 <Name>.code-workspace（含骨架目录，外部目录按实例自行添加）
    3. 提示按 _workspace/05-落地检查清单.md 落地

  默认只建核心骨架 _workspace + 01-文档 + 04-工具；02-数据/03-知识输入为可选区，
  加 -IncludeOptionalZones 才一并创建并挂载。
#>
param(
  [Parameter(Mandatory = $true)][string]$Name,
  [string]$Parent,
  [string]$From,
  [switch]$IncludeOptionalZones
)
$ErrorActionPreference = 'Stop'
# 脚本在 _模板维护\ 子目录：默认模板仓根 = 脚本父目录（显式 -From 可覆盖）
if (-not $From) { $From = Split-Path -Parent $PSScriptRoot }
if (-not $Parent) { $Parent = (Get-Location).Path }
$dest = Join-Path $Parent $Name
if (Test-Path -LiteralPath $dest) { throw "目标已存在: $dest" }
if (-not (Test-Path -LiteralPath $From)) { throw "模板仓不存在: $From" }

New-Item -ItemType Directory -Force -Path $dest | Out-Null
# 模板仓自身文件不随骨架复制：隐藏/仓文件、根级门面与记录文档、维护目录整树
$exclude = @('.git', '.gitignore', '.claude', '_模板维护', '模板说明.md', '使用手册.md', 'CHANGELOG.md')
if (-not $IncludeOptionalZones) {
  # 可选区默认不建（02-数据 / 03-知识输入）
  $exclude += @('02-数据', '03-知识输入')
}
Get-ChildItem -LiteralPath $From -Force | Where-Object { $_.Name -notin $exclude } | ForEach-Object {
  Copy-Item -LiteralPath $_.FullName -Destination $dest -Recurse -Force
}

# 可选区开启时，登记表 json 中 02-数据/03-知识输入 由 mount:false 改为 mount:true（与下方 folders 一致）
if ($IncludeOptionalZones) {
  $regFile = Join-Path $dest '_workspace\07-VSCode工作区挂载登记.md'
  if (Test-Path -LiteralPath $regFile) {
    $content = [System.IO.File]::ReadAllText($regFile)
    $content = $content -replace '("name": "02-数据"[^\r\n]*"mount": )false', '$1true'
    $content = $content -replace '("name": "03-知识输入"[^\r\n]*"mount": )false', '$1true'
    [System.IO.File]::WriteAllText($regFile, $content, (New-Object System.Text.UTF8Encoding($false)))
  }
}

# 生成 <Name>.code-workspace
$dirs = @('_workspace', '01-文档', '04-工具')
if ($IncludeOptionalZones) {
  $dirs += @('02-数据', '03-知识输入')
}
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
