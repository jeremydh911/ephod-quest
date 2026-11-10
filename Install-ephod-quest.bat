@echo off
setlocal
set DEST=%USERPROFILE%\ephod-quest
mkdir "%DEST%" 2>nul
xcopy /E /I /Y "%~dp0*" "%DEST%" >nul
if exist "%DEST%\.git" rmdir /S /Q "%DEST%\.git" 2>nul
echo Install ephod-quest - %DEST%
echo Publisher: Ahanaai Company
echo DUNS: 149970889
echo Record: %DEST%\PUBLISHER.txt
if exist "%DEST%\Makefile" (
  where make >nul 2>&1
  if not errorlevel 1 (
    pushd "%DEST%"
    make
    popd
  )
)
pause
endlocal
