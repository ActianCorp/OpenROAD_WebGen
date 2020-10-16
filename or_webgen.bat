@echo off
setlocal

:: attempt to add defalt Cygwin paths to Windows path
path C:\cygwin\bin;%PATH%
path C:\cygwin64\bin;%PATH%

:: allow Windows new lines in shell scripts with Cygwin
set SHELLOPTS=igncr

set DBNAME=%1
set APPNAME=%2
bash or_webgen.bash %DBNAME% %APPNAME%

endlocal
