# DeepSeek Harness 开发服务器一键启动脚本（Windows / PowerShell 7+）
# 用法：pwsh -File start-dev.ps1
# 功能：首次运行自动补齐依赖与构建产物，然后启动 dsh web 开发服务器
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

# 读取 Windows 系统代理（WinINET），让 Node fetch 访问 LLM 网关时经由此代理。
# 背景：opencode.ai 等网关对部分模型（如 gpt-5.6-luna）按出口 IP 地区限制，
#       直连会返回 HTTP 403；而 Node 22 的 fetch 默认不读取系统代理
#       （Node 24+ 才默认启用 --use-env-proxy）。这里检测系统代理并注入
#       环境变量，使 dsh web 的 LLM 请求与浏览器走同一出口。
#       未启用系统代理时保持直连，行为与之前一致。
$sysProxy = $null
try {
    $inet = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -ErrorAction SilentlyContinue
    if ($inet.ProxyEnable -eq 1 -and $inet.ProxyServer) {
        $sysProxy = (($inet.ProxyServer -split ';') | Select-Object -First 1) -replace '^https?=', ''
    }
} catch { }

$nodeMajor = 0
try { $nodeMajor = [int]((& node --version) -replace '^v(\d+).*', '$1') } catch { }

if ($sysProxy -and $nodeMajor -ge 22) {
    if (-not $env:HTTP_PROXY) { $env:HTTP_PROXY = "http://$sysProxy" }
    if (-not $env:HTTPS_PROXY) { $env:HTTPS_PROXY = "http://$sysProxy" }
    if ($env:NODE_OPTIONS -notmatch '--use-env-proxy') {
        $env:NODE_OPTIONS = "$env:NODE_OPTIONS --use-env-proxy".Trim()
    }
    Write-Host "[start-dev] 已启用系统代理 $sysProxy 供 Node fetch 使用（--use-env-proxy）"
} elseif ($sysProxy) {
    Write-Host "[start-dev] 检测到系统代理 $sysProxy，但 Node 版本过低（v$nodeMajor），无法启用 --use-env-proxy，保持直连"
}

# 首次运行：自动安装依赖
if (-not (Test-Path (Join-Path $root 'node_modules'))) {
    Write-Host '[start-dev] 未找到 node_modules，执行 pnpm install ...'
    pnpm install
}

# 首次运行：自动构建前端产物（dsh web 服务依赖）
if (-not (Test-Path (Join-Path $root 'apps/web/dist'))) {
    Write-Host '[start-dev] 未找到 apps/web/dist，执行 pnpm run build ...'
    pnpm run build
}

Write-Host '[start-dev] 启动 dsh web 开发服务器 ...'
Write-Host '[start-dev] 浏览器访问 http://127.0.0.1:3080 ，按 Ctrl+C 停止'
pnpm dsh web
