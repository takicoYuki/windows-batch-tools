@echo off
setlocal EnableExtensions
rem ===================================================================
rem  mirror-backup.bat
rem  Mirror a folder to a backup folder with robocopy.
rem  Files deleted from the source are also deleted from the backup,
rem  so always try "dry" first.
rem
rem  Usage : mirror-backup.bat <source> <backup> [dry]
rem    dry : only list what would be copied/deleted (nothing is changed)
rem  Log   : <backup>\_backup_logs\backup_YYYYMMDD_HHMMSS.log
rem ===================================================================

if "%~2"=="" goto :usage
if not exist "%~f1\" (
  echo [ERROR] Source folder not found: %~1
  exit /b 1
)

set "SRC=%~f1"
set "DST=%~f2"
if /i "%SRC%"=="%DST%" (
  echo [ERROR] Source and backup are the same folder.
  exit /b 1
)

set "DRY="
if /i "%~3"=="dry" set "DRY=/L"

for /f %%T in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "STAMP=%%T"
set "LOGDIR=%DST%\_backup_logs"
if not exist "%LOGDIR%" mkdir "%LOGDIR%" || exit /b 1
set "LOG=%LOGDIR%\backup_%STAMP%.log"

if defined DRY (echo [DRY RUN] Nothing will be changed.)
echo %SRC%  -^>  %DST%

rem /MIR mirror  /R /W retry  /NP no progress %%  /XD skip the log folder
robocopy "%SRC%" "%DST%" /MIR /R:2 /W:5 /NP /XD "%LOGDIR%" /LOG:"%LOG%" /TEE %DRY%
set "RC=%ERRORLEVEL%"

rem robocopy: 0-7 = success (bit flags), 8 or more = failure
if %RC% GEQ 8 (
  echo [ERROR] robocopy failed. exit code=%RC%  log: %LOG%
  exit /b %RC%
)
echo Done. exit code=%RC%  log: %LOG%
exit /b 0

:usage
echo Usage: %~nx0 ^<source^> ^<backup^> [dry]
echo   e.g. %~nx0 C:\work D:\backup\work dry
exit /b 2
