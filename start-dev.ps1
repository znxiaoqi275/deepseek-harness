# DeepSeek Harness 开发服务器一键启动脚本（Windows / PowerShell 7+）
# 用法：pwsh -File start-dev.ps1
# 功能：首次运行自动补齐依赖与构建产物，然后启动 dsh web 开发服务器
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

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
