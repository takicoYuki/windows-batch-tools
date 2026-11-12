@echo off
setlocal EnableExtensions
rem ===================================================================
rem  cab-split.bat
rem  Compress a file with makecab and split it into multiple CAB files.
rem
rem  Usage : cab-split.bat <file> [sizeMB] [outdir]
rem    sizeMB : max size of each CAB file in MB (default 100, max 2000)
rem    outdir : output folder (default: <file name>_cab next to the file)
rem  Result : <outdir>\<name>_1.cab, <name>_2.cab, ...
rem  Restore: cab-join.bat <outdir>\<name>_1.cab
rem ===================================================================

if "%~1"=="" goto :usage
if not exist "%~f1" (
  echo [ERROR] File not found: %~1
  exit /b 1
)
if exist "%~f1\" (
  echo [ERROR] Folders are not supported. Specify a single file: %~1
  exit /b 1
)

set "SRC=%~f1"
set "NAME=%~n1"
set "FILE=%~nx1"

set "SIZE_MB=%~2"
if "%SIZE_MB%"=="" set "SIZE_MB=100"
set /a SIZE_CHECK=SIZE_MB 2>nul
if not "%SIZE_CHECK%"=="%SIZE_MB%" (
  echo [ERROR] sizeMB must be a number: %SIZE_MB%
  exit /b 1
)
if %SIZE_MB% LSS 1 (
  echo [ERROR] sizeMB must be 1 or more.
  exit /b 1
)
if %SIZE_MB% GTR 2000 (
  echo [ERROR] sizeMB must be 2000 or less.
  exit /b 1
)
set /a SIZE_BYTES=SIZE_MB*1024*1024

set "OUTDIR=%~3"
if "%OUTDIR%"=="" set "OUTDIR=%~dpn1_cab"
for %%D in ("%OUTDIR%") do set "OUTDIR=%%~fD"
if exist "%OUTDIR%\%NAME%_1.cab" (
  echo [ERROR] CAB files already exist in %OUTDIR%. Remove them first.
  exit /b 1
)
if not exist "%OUTDIR%" mkdir "%OUTDIR%" || exit /b 1

rem --- write a temporary directive file (DDF) for makecab -------------
set "DDF=%TEMP%\cab-split-%RANDOM%%RANDOM%.ddf"
 > "%DDF%" echo .OPTION EXPLICIT
>> "%DDF%" echo .Set CabinetNameTemplate="%NAME%_*.cab"
>> "%DDF%" echo .Set DiskDirectoryTemplate="%OUTDIR%"
>> "%DDF%" echo .Set MaxDiskSize=%SIZE_BYTES%
>> "%DDF%" echo .Set Cabinet=on
>> "%DDF%" echo .Set Compress=on
>> "%DDF%" echo .Set CompressionType=LZX
>> "%DDF%" echo .Set CompressionMemory=21
>> "%DDF%" echo .Set InfFileName=nul
>> "%DDF%" echo .Set RptFileName=nul
>> "%DDF%" echo "%SRC%" "%FILE%"

echo Splitting "%FILE%" into %SIZE_MB% MB CAB files ...
makecab /F "%DDF%"
set "RC=%ERRORLEVEL%"
del "%DDF%" >nul 2>&1
if not "%RC%"=="0" (
  echo [ERROR] makecab failed. exit code=%RC%
  exit /b %RC%
)

echo.
echo Done. Output folder: %OUTDIR%
dir /b "%OUTDIR%\%NAME%_*.cab"
echo.
echo To restore: cab-join.bat "%OUTDIR%\%NAME%_1.cab"
exit /b 0

:usage
echo Usage: %~nx0 ^<file^> [sizeMB=100] [outdir]
echo   e.g. %~nx0 backup.zip 500
exit /b 2
