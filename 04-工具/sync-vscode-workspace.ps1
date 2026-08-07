<#
.SYNOPSIS
  将「VS Code 工作区挂载登记表」同步到 .code-workspace（幂等）。

.DESCRIPTION
  读取 <实例根>\_workspace\ 下 *VSCode工作区挂载登记.md 的 json 挂载项，幂等地更新
  <实例根>\ 下 *.code-workspace 的 folders 段；settings 等其他顶层字段保持不动。
  默认路径按 $PSScriptRoot 推导：脚本放在实例 04-工具\ 下即可直接运行；
  登记表通配 *VSCode工作区挂载登记.md 兼容实例编号 06 与模板编号 07。
  - 无变化时不写文件（保持现状与时间戳）。
  - -DryRun 只预览将发生的变更，不写文件。
  - folders 为覆盖式：以登记表为唯一真相，手改 .code-workspace 的 folders 会被覆盖。
  - 编码：登记表与 .code-workspace 一律按 UTF-8 读写；写回时 UTF-8 无 BOM、不转义中文。

.PARAMETER DryRun
  只打印变更计划，不写入。

.PARAMETER RegisterFile
  登记表路径（默认 <实例根>\_workspace\*VSCode工作区挂载登记.md 的第一个匹配）。

.PARAMETER WorkspaceFile
  .code-workspace 路径（默认 <实例根>\*.code-workspace 的第一个匹配）。

.EXAMPLE
  & sync-vscode-workspace.ps1 -DryRun
  & sync-vscode-workspace.ps1
#>
[CmdletBinding()]
param(
    [switch] $DryRun,
    [string] $RegisterFile,
    [string] $WorkspaceFile
)

$ErrorActionPreference = 'Stop'

# --- 0. 推导默认路径：脚本位于 <实例根>\04-工具\ 下 ---
$InstanceRoot = Split-Path $PSScriptRoot -Parent
if (-not $RegisterFile) {
    $regFiles = @(Get-ChildItem -LiteralPath (Join-Path $InstanceRoot '_workspace') -Filter '*VSCode工作区挂载登记.md' -File -ErrorAction SilentlyContinue)
    if ($regFiles.Count -lt 1) { throw "未找到登记表：$InstanceRoot\_workspace\*VSCode工作区挂载登记.md" }
    $RegisterFile = $regFiles[0].FullName
}
if (-not $WorkspaceFile) {
    $wsFiles = @(Get-ChildItem -LiteralPath $InstanceRoot -Filter '*.code-workspace' -File -ErrorAction SilentlyContinue)
    if ($wsFiles.Count -lt 1) { throw "未找到 .code-workspace：$InstanceRoot\*.code-workspace" }
    $WorkspaceFile = $wsFiles[0].FullName
}

# PS 5.1 的 ConvertTo-Json 会把非 ASCII 转义成 \uXXXX；这里反转义回 UTF-8 字符（仅 BMP）。
function ConvertTo-JsonUtf8NoEscape {
    param([object] $Data, [int] $Depth = 20)
    $s = ConvertTo-Json -InputObject $Data -Depth $Depth
    $decoder = {
        param($m)
        $cp = [Convert]::ToInt32($m.Groups[1].Value, 16)
        if ($cp -lt 0x10000) { [char]$cp } else { $m.Value }
    }
    return [regex]::Replace($s, '\\u([0-9a-fA-F]{4})', $decoder)
}

# --- 1. 读登记表，提取 json 挂载数组 ---
if (-not (Test-Path -LiteralPath $RegisterFile)) {
    throw "登记表不存在：$RegisterFile"
}
$md = Get-Content -Raw -LiteralPath $RegisterFile -Encoding UTF8
$start = $md.IndexOf('```json')
if ($start -lt 0) { throw "登记表未找到 json 挂载数组代码块（需用 ```json 开头的代码块）" }
$arrayStart = $md.IndexOf('[', $start)
$blockEnd   = $md.IndexOf('```', $arrayStart)
if ($blockEnd -lt 0) { throw "登记表 json 代码块未闭合（缺结尾 ```）" }
$jsonBlock = $md.Substring($arrayStart, $blockEnd - $arrayStart)
$items = ConvertFrom-Json -InputObject $jsonBlock

# --- 2. 构造 folders（mount 不为 false 的项，保持登记顺序） ---
$newFolders = @()
foreach ($it in $items) {
    if ([string]::IsNullOrWhiteSpace($it.name) -or [string]::IsNullOrWhiteSpace($it.path)) {
        throw "登记项缺少 name 或 path：$($it | ConvertTo-Json -Compress)"
    }
    if ($it.mount -ne $false) {
        $newFolders += [ordered]@{ name = [string]$it.name; path = [string]$it.path }
    }
}

# --- 3. 读现有 .code-workspace ---
if (-not (Test-Path -LiteralPath $WorkspaceFile)) {
    throw ".code-workspace 不存在：$WorkspaceFile"
}
$ws = Get-Content -Raw -LiteralPath $WorkspaceFile -Encoding UTF8 | ConvertFrom-Json

# --- 4. 顺序敏感比较 old vs new ---
$oldFolders = @($ws.folders)
$equal = ($oldFolders.Count -eq $newFolders.Count)
if ($equal) {
    for ($i = 0; $i -lt $newFolders.Count; $i++) {
        if ($oldFolders[$i].name -ne $newFolders[$i].name -or $oldFolders[$i].path -ne $newFolders[$i].path) {
            $equal = $false; break
        }
    }
}

# --- 5. 摘要（按 name 集合差） ---
$oldNames = @($oldFolders | ForEach-Object { $_.name })
$newNames = @($newFolders | ForEach-Object { $_.name })
$added   = @($newNames | Where-Object { $oldNames -notcontains $_ })
$removed = @($oldNames | Where-Object { $newNames -notcontains $_ })

if ($equal) {
    Write-Host ("已是最新：folders 与登记表一致（{0} 项），无需写入。" -f $newFolders.Count) -ForegroundColor Green
    Write-Host ("  " + ($newNames -join ' | '))
    return
}

Write-Host "检测到 folders 与登记表不一致：" -ForegroundColor Yellow
if ($added.Count)   { Write-Host ("  + 新增：" + ($added -join ', '))   -ForegroundColor Green }
if ($removed.Count) { Write-Host ("  - 移除：" + ($removed -join ', ')) -ForegroundColor Red }
if (-not $added -and -not $removed) { Write-Host "  ~ 顺序/路径变化（项数不变）" -ForegroundColor Yellow }

if ($DryRun) {
    Write-Host "[DryRun] 未写入。去掉 -DryRun 执行同步。" -ForegroundColor Cyan
    return
}

# --- 6. 写回（保留 settings 等其他字段；UTF-8 无 BOM；中文不转义） ---
$ws.folders = $newFolders
$out = ConvertTo-JsonUtf8NoEscape -Data $ws -Depth 20
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($WorkspaceFile, $out, $utf8NoBom)
Write-Host "已同步 .code-workspace。VS Code 会提示重新加载。" -ForegroundColor Green