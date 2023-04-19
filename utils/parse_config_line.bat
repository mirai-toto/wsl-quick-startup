@echo off

setlocal EnableDelayedExpansion

set "string=%~1"

for /f "tokens=1,2,3 delims=%%" %%a in ("%string%") do (
    set "substring=%%b"
    set "before=%%a"
    set "after=%%c"
)
for /f %%i in ('call echo %%%substring%%%') do set "output=%%i"
echo %before%