@echo off
setlocal

:: 讀取第一個參數 (init, install, uninstall)
set "COMMAND=%~1"
:: 讀取第二個參數 (python版本 或 套件名稱)
set "ARGUMENT=%~2"

:: 根據第一個參數跳轉到對應的區塊
if /i "%COMMAND%"=="init" goto :init
if /i "%COMMAND%"=="install" goto :install
if /i "%COMMAND%"=="uninstall" goto :uninstall

:: 如果指令不符，顯示幫助訊息
echo.
echo Usage:
echo   euv init [python 版本]
echo   euv install [python 套件名稱]
echo   euv uninstall [python 套件名稱]
echo.
goto :eof

:init
echo --- Checking for prerequisites... ---

:: 檢查 uv 是否安裝
where uv >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [EUV] 'uv' command not found. Attempting to install...
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
) else (
    echo [EUV] uv is already installed.
)

:: 檢查 Poetry 是否安裝
where poetry >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [EUV] 'Poetry' command not found. Attempting to install...
    powershell -NoProfile -Command "(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | py -"
) else (
    echo [EUV] Poetry is already installed.
)

echo.
echo --- Running EUV Init for Python %ARGUMENT% ---
poetry init
uv venv --python %ARGUMENT%
echo --- EUV Init Complete ---
goto :eof

:install
echo --- Running EUV install: %ARGUMENT% ---
poetry add %ARGUMENT% --lock
uv pip compile pyproject.toml -o requirements.txt --all-extras
uv pip sync requirements.txt
echo --- EUV install Complete ---
goto :eof

:uninstall
echo --- Running EUV uninstall: %ARGUMENT% ---
poetry remove %ARGUMENT% --lock
uv pip compile pyproject.toml -o requirements.txt --all-extras
uv pip sync requirements.txt
echo --- EUV uninstall Complete ---
goto :eof
