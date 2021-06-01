@echo off

set DIR=%~dp0
set TEMPDIR=temp
set INPUTDIR=proto
set JAVADIR=java
set PBDIR=pb
echo "%DIR%"

echo "create temp proto files"
java -jar %DIR%PbSplit.jar PbSplit 

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

if exist %DIR%%JAVADIR% rmdir /s /q %DIR%%JAVADIR%
@echo "remove and mkdir java"
mkdir %DIR%%JAVADIR%

cd /d %DIR%%TEMPDIR%

echo "create java pb files, waiting ............."

for /r %%i in (*.proto) do (
	set pbname=%%i
	set pbname=!pbname:~0,-5!pb
	:protoc.exe -I %DIR% --descriptor_set_out !pbname! %%i
	%DIR%protoc.exe -I%DIR%%TEMPDIR% -o!pbname! --java_out=%DIR%%JAVADIR% %%i
)

cd /d %DIR%

echo "remove temp proto files"
if exist %DIR%%TEMPDIR% rmdir /s /q %DIR%%TEMPDIR%

echo "finished"
cd /d %DIR%
pause