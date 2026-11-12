@echo off
setlocal EnableExtensions
rem ===================================================================
rem  hash.bat
rem  Show the hash of a file, or compare two files by hash.
rem  Useful to confirm that a file restored by cab-join.bat is identical.
rem
rem  Usage : hash.bat <file> [algorithm]          show the hash
rem          hash.bat <file1> <file2> [algorithm] compare two files
rem    algorithm : MD5 / SHA1 / SHA256 (default) / SHA512
rem ===================================================================

if "%~1"=="" goto :usage
if not exist "%~f1" (
  echo [ERROR] File not found: %~1
  exit /b 1
)

set "ALG=SHA256"
set "OTHER="
if not "%~2"=="" (
  if exist "%~f2" (
    set "OTHER=%~f2"
    if not "%~3"=="" set "ALG=%~3"
  ) else (
    set "ALG=%~2"
  )
)

call :hash "%~f1" H1 || exit /b 1
if not defined OTHER (
  echo %ALG%  %H1%  %~nx1
  exit /b 0
)

call :hash "%OTHER%" H2 || exit /b 1
echo %ALG%  %H1%  %~nx1
echo %ALG%  %H2%  %~nx2
if /i "%H1%"=="%H2%" (
  echo [OK] The files are identical.
  exit /b 0
)
echo [NG] The files are different.
exit /b 1

:hash
rem certutil prints: header line / hash / footer line. Take the 2nd line.
set "%~2="
for /f "skip=1 delims=" %%L in ('certutil -hashfile "%~1" %ALG% 2^>nul') do (
  if not defined %~2 set "%~2=%%L"
)
if not defined %~2 (
  echo [ERROR] certutil failed: %~1 ^(algorithm: %ALG%^)
  exit /b 1
)
call set "%~2=%%%~2: =%%"
exit /b 0

:usage
echo Usage: %~nx0 ^<file^> [algorithm]
echo        %~nx0 ^<file1^> ^<file2^> [algorithm]
exit /b 2
