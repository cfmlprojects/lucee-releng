@echo off
setlocal enabledelayedexpansion

set CFDISTRO_HOME=%userprofile%\cfdistro
set FILE_URL="http://cfmlprojects.org/artifacts/cfdistro/latest/cfdistro.zip"
set FILE_DEST=%CFDISTRO_HOME%\cfdistro.zip
set buildfile=build/build.xml
set ANT_HOME=%CFDISTRO_HOME%\ant
set ANT_CMD=%CFDISTRO_HOME%\ant\bin\ant.bat
if not exist "%CFDISTRO_HOME%" (
  mkdir "%CFDISTRO_HOME%"
)
if not exist "%FILE_DEST%" (
  echo Downloading with powershell: %FILE_URL% to %FILE_DEST%
  powershell.exe -command "$webclient = New-Object System.Net.WebClient; $url = \"%FILE_URL%\"; $file = \"%FILE_DEST%\"; $webclient.DownloadFile($url,$file);"
  echo Expanding with powershell to: %CFDISTRO_HOME%
  powershell -command "$shell_app=new-object -com shell.application; $zip_file = $shell_app.namespace(\"%FILE_DEST%\"); $destination = $shell_app.namespace(\"%CFDISTRO_HOME%\"); $destination.Copyhere($zip_file.items())"
) else (
  echo "cfdistro.zip already downloaded, delete to re-download"
)
if "%1" == "" goto MENU
set args=%1
SHIFT
:Loop
IF "%1" == "" GOTO Continue
SET args=%args% -D%1%
SHIFT
IF "%1" == "" GOTO Continue
SET args=%args%=%1%
SHIFT
GOTO Loop
:Continue


SET "FOUNDJAVAARG="
for %%x in (%*) do (
   IF DEFINED FOUNDJAVAARG SET "JAVA_HOME=%%~x"& echo java_home set to %JAVA_HOME%
   IF "%%~x" == "java.home" SET FOUNDJAVAARG="%%~x"
)
SET "FOUND="
for %%X in (java.exe) do (set FOUND=%%~$PATH:X)
if not defined FOUND SET "PATH=%PATH%;%JAVA_HOME%\bin"
echo %PATH%
:JAVAHOME_LOOP_DONE


if not exist %buildfile% (
	set buildfile="%CFDISTRO_HOME%\build.xml"
)
call "%ANT_CMD%" -nouserlib -f %buildfile% %args%
goto end
:MENU
cls
echo.
echo       railo-releng menu
REM echo       usage: railo-releng.bat [start|stop|{target}]
echo.
echo       1. Build
echo       2. Build all
echo       3. List available targets
echo       4. Update project
echo       5. Run Target
echo       6. Quit
echo.
set choice=
set /p choice=      Enter option 1, 2, 3, 4, 5 or 6 :
echo.
if not '%choice%'=='' set choice=%choice:~0,1%
if '%choice%'=='1' goto build
if '%choice%'=='2' goto buildAll
if '%choice%'=='3' goto listTargets
if '%choice%'=='4' goto updateProject
if '%choice%'=='5' goto runTarget
if '%choice%'=='6' goto end
::
echo.
echo.
echo "%choice%" is not a valid option - try again
echo.
pause
goto MENU
::
:build
cls
call "%ANT_CMD%" -nouserlib -f %buildfile% build
goto end
::
:buildAll
call "%ANT_CMD%" -nouserlib -f %buildfile% build.all
goto end
::
:listTargets
call "%ANT_CMD%" -nouserlib -f %buildfile% help
echo       press any key ...
pause > nul
goto MENU
::
:updateProject
call "%ANT_CMD%" -nouserlib -f %buildfile% project.update
echo       press any key ...
pause > nul
goto MENU
::
:runTarget
set target=
set /p target=      Enter target name:
if not "%target%"=="" call %0 %target%
echo       press any key ...
pause > nul
goto MENU
::
:end
set choice=
echo       press any key ...
pause
REM EXIT
			
