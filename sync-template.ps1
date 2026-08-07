<#
  sync-template.ps1 — 模板 → 实例 同步机制（v0.5）

  用法：
    & sync-template.ps1 -Instance <实例目录>                      # dry-run：只报告差异
    & sync-template.ps1 -Instance <实例目录> -Apply                # 应用 sync:auto 文件（模板权威，覆盖实例）
    & sync-template.ps1 -Instance <实例目录> -File <模板相对路径> -Apply   # 只处理单个文件

  规则（由模板文件头部 front-matter 驱动）：
    <!-- 模板 vX.Y | sync: auto | target: <实例相对路径> -->   自动同步（可覆盖）
    <!-- 模板 vX.Y | sync: manual | target: ... -->            实例化文件，仅报告差异，需人工合并
    target 含 <占位符>（如 <实例根>/README.md）               无法解析，按 manual 处理
#>
param(
  [Parameter(Mandatory = $true)][string]$Instance,
  [switch]$Apply,
  [string]$File
)
$ErrorActionPreference = 'Stop'
$tplDir = Join-Path $PSScriptRoot '模板'
if (-not (Test-Path -LiteralPath $Instance)) { throw "实例目录不存在: $Instance" }
if (-not (Test-Path -LiteralPath $tplDir)) { throw "模板目录不存在: $tplDir" }

$files = Get-ChildItem -LiteralPath $tplDir -Recurse -File -Force |
  Where-Object { $_.Name -eq '.gitignore' -or $_.Extension -in '.md', '.code-workspace' }
$auto = [System.Collections.Generic.List[object]]::new()
$manual = [System.Collections.Generic.List[object]]::new()
$skipped = 0

foreach ($f in $files) {
  $rel = $f.FullName.Substring($tplDir.Length + 1)
  if ($File -and $rel -ne $File) { $skipped++; continue }
  $head = Get-Content -LiteralPath $f.FullName -TotalCount 1 -Encoding UTF8
  $m = [regex]::Match($head, '模板 v[\d.]+ \| sync: (\w+) \| target: (.+?) *(?:-->)?\s*$')
  if (-not $m.Success) {
    $manual.Add([pscustomobject]@{ Rel = $rel; Sync = 'manual(无标记)'; Target = ''; Status = '需人工' })
    continue
  }
  $sync = $m.Groups[1].Value
  $target = $m.Groups[2].Value.Trim()
  if ($sync -ne 'auto' -or $target -like '<*') {
    $dest = if ($target -like '<*') { '' } else { Join-Path $Instance $target }
    $status = if ($dest -and (Test-Path -LiteralPath $dest)) { '需人工合并' } else { '待新增' }
    $manual.Add([pscustomobject]@{ Rel = $rel; Sync = 'manual'; Target = $target; Status = $status })
    continue
  }

  $dest = Join-Path $Instance $target
  $tplText = [System.IO.File]::ReadAllText($f.FullName)
  if (Test-Path -LiteralPath $dest) {
    $instText = [System.IO.File]::ReadAllText($dest)
    $status = if ($tplText -eq $instText) { 'SAME' } else { 'DIFF' }
  } else { $status = 'NEW' }
  if ($Apply -and $status -ne 'SAME') {
    $destDir = Split-Path $dest -Parent
    if (-not (Test-Path -LiteralPath $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }
    Copy-Item -LiteralPath $f.FullName -Destination $dest -Force
    $status = '已同步'
  }
  $auto.Add([pscustomobject]@{ Rel = $rel; Sync = 'auto'; Target = $target; Status = $status })
}

'=== auto（模板权威，-Apply 时覆盖）==='
$auto | Format-Table -AutoSize Rel, Target, Status
'=== manual（实例化文件，需人工合并）==='
$manual | Format-Table -AutoSize Rel, Target, Status
$applied = @($auto | Where-Object Status -eq '已同步').Count
"=== 摘要 ===  auto=$($auto.Count)（本次已同步 $applied） manual=$($manual.Count) 跳过=$skipped"
"实例: $Instance    Apply=$Apply"
if ($Apply -and $applied -gt 0) { '提示：同步后请按实例 03-git管理.md 约定提交；manual 文件差异请人工合并。' }