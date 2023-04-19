@echo off

setlocal EnableDelayedExpansion

set "string=install_dir=%%userprofile%%\VMs"

.\parse_config_line.bat !string!