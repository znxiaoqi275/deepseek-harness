@echo off
rem ============================================
rem  DeepSeek Harness dev server launcher (Windows)
rem  Double-click or run from cmd. Ctrl+C to stop.
rem  Web UI: http://127.0.0.1:3080
rem ============================================
setlocal enabledelayedexpansion
cd /d "%~dp0"

rem Read the Windows system proxy (WinINET) so Node fetch reaches LLM
rem gateways through it. Some gateways (e.g. opencode.ai) restrict models
rem like gpt-5.6-luna by egress IP and return HTTP 403 on a direct
rem connection; Node 22's fetch ignores the system proxy unless
rem --use-env-proxy is enabled (default only in Node 24+). Keep direct
rem connection when no system proxy is configured.
set "SYS_PROXY="
for /f "tokens=3" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable 2^>nul') do set "PROXY_ENABLE=%%a"
for /f "tokens=3" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer 2^>nul') do set "PROXY_SERVER=%%a"
if "%PROXY_ENABLE%"=="0x1" if defined PROXY_SERVER (
    for /f "tokens=1 delims=;" %%p in ("%PROXY_SERVER%") do set "SYS_PROXY=%%p"
)
if defined SYS_PROXY (
    if not defined HTTP_PROXY set "HTTP_PROXY=http://%SYS_PROXY%"
    if not defined HTTPS_PROXY set "HTTPS_PROXY=http://%SYS_PROXY%"
    echo !NODE_OPTIONS! | findstr /C:"--use-env-proxy" >nul 2>&1
    if errorlevel 1 (
        if defined NODE_OPTIONS (
            set "NODE_OPTIONS=!NODE_OPTIONS! --use-env-proxy"
        ) else (
            set "NODE_OPTIONS=--use-env-proxy"
        )
    )
    echo [start-dev] enabled system proxy !SYS_PROXY! for Node fetch ^(--use-env-proxy^)
)

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