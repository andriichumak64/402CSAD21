@echo off
cd /d "%~dp0"

call npm ci
if %errorlevel% neq 0 exit /b %errorlevel%

call npm test
if %errorlevel% neq 0 exit /b %errorlevel%

call npm run build
if %errorlevel% neq 0 exit /b %errorlevel%

if not exist "dist\hello.js" exit /b 1
exit /b 0
