@echo off
path c:\bin;c:\gnu;c:\dosemu;d:\dosemu\compila\tc\bin;d:\dosemu\compila\td
set HELPPATH=c:\help
prompt $P$G
unix -s DOSTMP
unix -s DOSDRIVE_D
if "%DOSDRIVE_D%" == "" goto nodrived
lredir d: linux\fs%DOSDRIVE_D%
if "%DOSTMP%" == "" goto dosver
lredir e: linux\fs%DOSTMP%
set TEMP=E:\
goto dosver
:nodrived
if "%DOSTMP%" == "" goto dosver
lredir d: linux\fs%DOSTMP%
set TEMP=D:\
:dosver
unix -s DOSEMU_VERSION
echo "Welcome to dosemu %DOSEMU_VERSION%!"
unix -e
