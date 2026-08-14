@echo off
rem ============================================
rem  DeepSeek Harness dev server launcher (Windows)
rem  Double-click or run from cmd. Ctrl+C to stop.
rem  Web UI: http://127.0.0.1:3080
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
