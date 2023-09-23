@echo off

setlocal EnableDelayedExpansion

set "string=%~1"

REM this script is used to replace variable with %% with the value.
REM For example calling this script with %userprofile% will output the profile directory.
for /f "tokens=1,* delims=%%" %%a in ("%string%") do (
    set "value=%%a"
)
echo %value%