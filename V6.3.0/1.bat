@echo off

set DIR=%~dp0
set INPUTDIR=proto
set JAVADIR=java
set PBDIR=pb
echo "%DIR%"

cd /d %DIR%%INPUTDIR%

setlocal enabledelayedexpansion

if exist %DIR%%PBDIR% rmdir /s /q %DIR%%PBDIR%
@echo "mkdir pb"
mkdir %DIR%%PBDIR%

if exist %DIR%%JAVADIR% rmdir /s /q %DIR%%JAVADIR%
@echo "mkdir java"
mkdir %DIR%%JAVADIR%

for /r %%i in (*.proto) do (
	set pbname=%%i
	set pbname=!pbname:~0,-5!pb
	:protoc.exe -I %DIR% --descriptor_set_out !pbname! %%i
	%DIR%protoc.exe -I%DIR%%INPUTDIR% -o!pbname! --java_out=%DIR%%JAVADIR% %%i
)

@echo "move files pb"
move *.pb %DIR%%PBDIR%

echo "finished"
cd /d %DIR%
pause