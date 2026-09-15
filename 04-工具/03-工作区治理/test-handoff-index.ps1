<#
.SYNOPSIS
  校验工作区的唯一续接索引、主线程目标和影子索引。

.DESCRIPTION
  唯一可维护索引为 <实例根>\_workspace\_handoff\README.md。顶部主线程指针必须
  链接到存在且状态为“进行中”的续接文档，并在索引表中有相同链接的进行中行。
  其他 _handoff\README.md 仅允许是带 handoff-redirect: canonical 标记的跳转文件。
#>
[CmdletBinding()]
param(
    [string] $InstanceRoot
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($InstanceRoot)) {
    $toolRoot = Split-Path $PSScriptRoot -Parent
    $InstanceRoot = Split-Path $toolRoot -Parent
}
$InstanceRoot = (Resolve-Path -LiteralPath $InstanceRoot).Path
$canonicalPath = Join-Path $InstanceRoot '_workspace\_handoff\README.md'
$errors = New-Object System.Collections.Generic.List[string]

if (-not (Test-Path -LiteralPath $canonicalPath -PathType Leaf)) {
    $errors.Add("缺少唯一续接索引：$canonicalPath")
}
else {
    $canonical = Get-Content -LiteralPath $canonicalPath -Raw -Encoding utf8
    if ($canonical -notmatch '(?m)^<!-- handoff-index: canonical -->\s*$') {
        $errors.Add("唯一续接索引缺少 canonical 标记：$canonicalPath")
    }

    $pointer = [regex]::Match($canonical, '(?m)^> \*\*当前主线 / 下一任务\*\*：(.+)$')
    if (-not $pointer.Success) {
        $errors.Add('唯一续接索引缺少顶部“当前主线 / 下一任务”指针。')
    }
    else {
        $pointerText = $pointer.Groups[1].Value.Trim()
        if ($pointerText -ne '无') {
            $link = [regex]::Match($pointerText, '\]\(([^)]+)\)')
            if (-not $link.Success) {
                $errors.Add('主线程指针非「无」时必须包含指向续接文档的 Markdown 链接。')
            }
            else {
                $relativeTarget = $link.Groups[1].Value.Replace('/', [IO.Path]::DirectorySeparatorChar)
                $targetPath = Join-Path (Split-Path $canonicalPath -Parent) $relativeTarget
                if (-not (Test-Path -LiteralPath $targetPath -PathType Leaf)) {
                    $errors.Add("主线程指针目标不存在：$targetPath")
                }
                else {
                    $target = Get-Content -LiteralPath $targetPath -Raw -Encoding utf8
                    if ($target -notmatch '(?m)^- 状态：.*进行中') {
                        $errors.Add("主线程目标未标记为进行中：$targetPath")
                    }
                    $expectedLink = [regex]::Escape($link.Groups[1].Value)
                    if ($canonical -notmatch "(?m)^\|.*进行中.*\]\($expectedLink\).*$") {
                        $errors.Add('进行中索引行未链接到顶部主线程指针目标。')
                    }
                }
            }
        }
    }
}

$canonicalFullName = [IO.Path]::GetFullPath($canonicalPath)
$handoffReadmes = Get-ChildItem -LiteralPath $InstanceRoot -Recurse -File -Filter 'README.md' -Force |
    Where-Object { $_.Directory.Name -eq '_handoff' }
foreach ($readme in $handoffReadmes) {
    if ([IO.Path]::GetFullPath($readme.FullName) -eq $canonicalFullName) {
        continue
    }
    $content = Get-Content -LiteralPath $readme.FullName -Raw -Encoding utf8
    if ($content -notmatch '(?m)^<!-- handoff-redirect: canonical -->\s*$') {
        $errors.Add("发现非规范的活跃或未声明影子索引：$($readme.FullName)")
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error "HOF-001 $_" }
    exit 1
}

Write-Output "PASS Handoff index is canonical: $canonicalPath"
