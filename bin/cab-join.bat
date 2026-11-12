@echo off
setlocal EnableExtensions
rem ===================================================================
rem  cab-join.bat
rem  Restore the original file from CAB files created by cab-split.bat.
rem  Put all the CAB files (<name>_1.cab, <name>_2.cab, ...) in the
rem  same folder and pass the FIRST one.
rem
rem  Usage : cab-join.bat <first.cab> [outdir]
rem    outdir : where to restore (default: the folder of the CAB files)
rem ===================================================================

if "%~1"=="" goto :usage
if not exist "%~f1" (
  echo [ERROR] CAB file not found: %~1
  exit /b 1
)
if /i not "%~x1"==".cab" (
  echo [ERROR] Specify the first .cab file: %~1
  exit /b 1
)

set "FIRST=%~f1"
set "OUTDIR=%~2"
if "%OUTDIR%"=="" set "OUTDIR=%~dp1"
for %%D in ("%OUTDIR%.") do set "OUTDIR=%%~fD"
if not exist "%OUTDIR%" mkdir "%OUTDIR%" || exit /b 1

echo Files in the CAB set:
extrac32 /D "%FIRST%"
echo.
echo Restoring to %OUTDIR% ...
rem /E: extract all files (follows the continuation CAB files in the set)
rem /L: output folder   /Y: do not ask before overwriting
extrac32 /Y /E /L "%OUTDIR%" "%FIRST%"
if errorlevel 1 (
  echo [ERROR] extrac32 failed. Check that all CAB files of the set are in the same folder.
  exit /b 1
)

echo Done.
exit /b 0

:usage
echo Usage: %~nx0 ^<first.cab^> [outdir]
echo   e.g. %~nx0 backup_cab\backup_1.cab D:\restore
exit /b 2
