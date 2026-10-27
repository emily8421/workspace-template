<#
  sync-template.ps1 — 模板 → 实例 同步机制（v1.5，front-matter 驱动）

  位置：_模板维护\sync-template.ps1（模板仓自身脚本，不复制进实例）。

  用法：
    & _模板维护\sync-template.ps1 -Instance <实例目录>                      # dry-run：只报告差异
    & _模板维护\sync-template.ps1 -Instance <实例目录> -Apply                # 应用 sync:auto 文件（模板权威，覆盖实例）并留痕
    & _模板维护\sync-template.ps1 -Instance <实例目录> -File <模板相对路径> -Apply   # 只处理单个文件

  v1.4 新增：
    同步模式门禁——实例 _workspace\10-模板同步.md 机读块 sync_mode=independent 时拒绝同步
    （重新接入需用户确认后主动修改该机读块为 follow；缺文件/块按 follow 兼容旧实例）
    manual 文件内容比对——status 从「需人工合并」细化为 SAME / DIFF / 待新增 / 无法解析
    同步留痕——-Apply 时向实例 _workspace\_同步记录.md 自动追加一行（日期/模板 VERSION/auto 已同步/manual DIFF）
  v1.5 调整：门禁两级化——dry-run 任何模式可跑（独立模式下作为切回前盘点工具，输出提示）；
    仅 -Apply 需 follow 模式。auto 组 DIFF 即「实例改动过方法论文件」信号，裁决流程见实例 10-模板同步.md。

  规则（由模板文件前 4 行内的 front-matter 标记驱动；Trae 规则文件 front-matter 占第 1 行，标记随其后）：
    <!-- 模板 vX.Y | sync: auto | target: <实例相对路径> -->   自动同步（可覆盖）
    <!-- 模板 vX.Y | sync: manual | target: ... -->            实例化文件，仅报告差异，需人工合并
    target 含 <占位符>（如 <实例根>/README.md）               无法解析，按 manual 处理
  无 front-matter 的文件（模板自身文件，含 _模板维护\）自动跳过。
#>
param(
  [Parameter(Mandatory = $true)][string]$Instance,
  [switch]$Apply,
  [string]$File
)
$ErrorActionPreference = 'Stop'
# 脚本在 _模板维护\ 子目录：模板仓根 = 脚本父目录
$tplDir = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path -LiteralPath $Instance)) { throw "实例目录不存在: $Instance" }
if (-not (Test-Path -LiteralPath $tplDir)) { throw "模板仓不存在: $tplDir" }

# v1.4 同步模式门禁：读实例 10-模板同步.md 机读块（```json 围栏内首个 json 对象）
$instanceMode = $null
$modeFile = Join-Path $Instance '_workspace\10-模板同步.md'
if (Test-Path -LiteralPath $modeFile) {
  $modeText = [System.IO.File]::ReadAllText($modeFile)
  $jm = [regex]::Match($modeText, '```json\s*(\{.*?\})\s*```', [System.Text.RegularExpressions.RegexOptions]::Singleline)
  if ($jm.Success) {
    try { $instanceMode = ((($jm.Groups[1].Value | ConvertFrom-Json).sync_mode)) } catch { $instanceMode = $null }
  }
}
if ($instanceMode -eq 'independent') {
  if ($Apply) {
    throw "实例为独立管理模式（_workspace/10-模板同步.md 机读块 sync_mode=independent），-Apply 已拒绝。`n如需重新接入模板方法分发：先跑 dry-run 盘点独立期间的改动并按「切回四步」安顿（见实例 10-模板同步.md），再由用户确认后将机读块 sync_mode 改为 follow。"
  }
  Write-Host '提示: 实例为独立管理模式（independent），本次 dry-run 仅供切回前盘点/查看，-Apply 将被拒绝；切回流程见实例 _workspace/10-模板同步.md。'
}
if (-not $instanceMode) { Write-Host '提示: 实例缺 _workspace/10-模板同步.md 或机读块不可解析，按 follow 模式处理（旧实例兼容）。' }

$files = Get-ChildItem -LiteralPath $tplDir -Recurse -File -Force |
  Where-Object { $_.FullName -notmatch '\\.git\\' -and ($_.Name -eq '.gitignore' -or $_.Extension -in '.md', '.code-workspace') }
$auto = [System.Collections.Generic.List[object]]::new()
$manual = [System.Collections.Generic.List[object]]::new()
$appliedList = [System.Collections.Generic.List[string]]::new()
$diffList = [System.Collections.Generic.List[string]]::new()
$skipped = 0

foreach ($f in $files) {
  $rel = $f.FullName.Substring($tplDir.Length + 1)
  if ($File -and $rel -ne $File) { $skipped++; continue }
  # 标记允许在文件前 5 行内：Trae 规则文件要求 --- front-matter 置于第 1 行，模板标记随其后（v1.3）
  $m = $null
  foreach ($line in (Get-Content -LiteralPath $f.FullName -TotalCount 5 -Encoding UTF8)) {
    $m = [regex]::Match($line, '模板 v[\d.]+ \| sync: (\w+) \| target: (.+?) *(?:-->)?\s*$')
    if ($m.Success) { break }
  }
  if (-not $m.Success) { continue }  # 模板自身文件等，跳过
  $syncMode = $m.Groups[1].Value
  $target = $m.Groups[2].Value.Trim()
  $tplText = [System.IO.File]::ReadAllText($f.FullName)
  if ($syncMode -ne 'auto' -or $target -like '<*') {
    # v1.4：manual 文件也做内容比对，status 细化为 SAME / DIFF / 待新增 / 无法解析
    $dest = if ($target -like '<*') { '' } else { Join-Path $Instance $target }
    $status = if (-not $dest) { '无法解析' }
      elseif (-not (Test-Path -LiteralPath $dest)) { '待新增' }
      elseif ($tplText -eq [System.IO.File]::ReadAllText($dest)) { 'SAME' } else { 'DIFF' }
    if ($status -eq 'DIFF') { $diffList.Add($rel) }
    $manual.Add([pscustomobject]@{ Rel = $rel; Sync = 'manual'; Target = $target; Status = $status })
    continue
  }

  $dest = Join-Path $Instance $target
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
  if ($status -eq '已同步') { $appliedList.Add($rel) }
}

'=== auto（模板权威，-Apply 时覆盖）==='
$auto | Format-Table -AutoSize Rel, Target, Status
'=== manual（实例化文件，SAME=一致 DIFF=需人工合并）==='
$manual | Format-Table -AutoSize Rel, Target, Status
$applied = @($auto | Where-Object Status -eq '已同步').Count
$diff = @($manual | Where-Object Status -eq 'DIFF').Count
"=== 摘要 ===  auto=$($auto.Count)（本次已同步 $applied） manual=$($manual.Count)（DIFF $diff） 跳过=$skipped"
"实例: $Instance    Apply=$Apply"

# v1.4 同步留痕：-Apply 时向实例 _workspace\_同步记录.md 追加一行
if ($Apply -and ($appliedList.Count -gt 0 -or $diffList.Count -gt 0)) {
  $version = 'unknown'
  $verFile = Join-Path $tplDir 'VERSION'
  if (Test-Path -LiteralPath $verFile) { $version = (Get-Content -LiteralPath $verFile -TotalCount 1).Trim() }
  $recFile = Join-Path $Instance '_workspace\_同步记录.md'
  if (Test-Path -LiteralPath $recFile) {
    $autoStr = if ($appliedList.Count) { $appliedList -join '；' } else { '无' }
    $manualStr = if ($diffList.Count) { $diffList -join '；' } else { '无' }
    $row = "| $(Get-Date -Format 'yyyy-MM-dd') | $version | $autoStr | $manualStr | - |"
    Add-Content -LiteralPath $recFile -Value $row -Encoding UTF8
    "已留痕: $recFile"
  } else {
    '提示: 实例缺 _workspace/_同步记录.md，本次未留痕（可从模板 _workspace/ 复制骨架）。'
  }
}
if ($Apply -and ($applied -gt 0 -or $diff -gt 0)) { '提示：同步后请按实例 _workspace/03-git管理.md 约定提交；manual DIFF 项请人工合并（指引见实例 _workspace/10-模板同步.md 与实例根 CHANGELOG-PLAIN.md）。' }