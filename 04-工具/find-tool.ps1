<#
.SYNOPSIS
  检索工具注册表（tool-registry.json）。

.DESCRIPTION
  读取 <实例根>\04-工具\tool-registry.json，按关键字过滤（匹配 ID / 名称 / 范围 / 输入输出契约），
  打印命中的条目。注册表为空时提示无需检索。
  默认路径按 $PSScriptRoot 推导：脚本放在实例 04-工具\ 下即可直接运行。
  编码：注册表按 UTF-8 读取。

.PARAMETER Keyword
  检索关键字（必填）；传 * 列出全部。

.EXAMPLE
  & find-tool.ps1 -Keyword sync
  & find-tool.ps1 -Keyword "*"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string] $Keyword
)

$ErrorActionPreference = 'Stop'

$RegistryFile = Join-Path $PSScriptRoot 'tool-registry.json'
if (-not (Test-Path -LiteralPath $RegistryFile)) {
    throw "注册表不存在：$RegistryFile"
}

$registry = Get-Content -Raw -LiteralPath $RegistryFile -Encoding UTF8 | ConvertFrom-Json
$tools = @($registry.工具)
if ($tools.Count -eq 0) {
    Write-Host "注册表为空（还没有登记的工具）。满足登记判据任一即需登记，规则见 _workspace/09-工具管理.md。" -ForegroundColor Cyan
    return
}

if ($Keyword -ne '*' -and -not [string]::IsNullOrWhiteSpace($Keyword)) {
    $tools = @($tools | Where-Object {
        ($_.ID -and $_.ID -like "*$Keyword*") -or
        ($_.名称 -and $_.名称 -like "*$Keyword*") -or
        ($_.范围 -and $_.范围 -like "*$Keyword*") -or
        ($_.'输入输出契约' -and $_.'输入输出契约' -like "*$Keyword*")
    })
}

if ($tools.Count -eq 0) {
    Write-Host "未命中关键字：$Keyword" -ForegroundColor Yellow
    return
}

Write-Host ("命中 {0} 条：" -f $tools.Count) -ForegroundColor Green
$tools | ForEach-Object {
    Write-Host ("  [{0}] {1} | 生命周期:{2} | 范围:{3}" -f $_.ID, $_.名称, $_.'生命周期', $_.范围)
    if ($_.最小命令) { Write-Host ("      最小命令: {0}" -f $_.最小命令) }
    if ($_.最后验证日期) { Write-Host ("      最后验证: {0}" -f $_.最后验证日期) }
}
