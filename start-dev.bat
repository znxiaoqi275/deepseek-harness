@echo off
rem ============================================
rem  DeepSeek Harness 开发服务器一键启动（双击运行）
rem  首次运行自动装依赖/构建，然后启动 dsh web
rem  访问 http://127.0.0.1:3080 ，Ctrl+C 停止
rem ============================================
cd /d "%~dp0"

if not exist node_modules (
    echo [start-dev] installing dependencies...
    call pnpm install
)

if not exist apps\web\dist (
    echo [start-dev] building web frontend...
    call pnpm run build
)

echo [start-dev] starting dsh web at http://127.0.0.1:3080
call pnpm dsh web

pause
