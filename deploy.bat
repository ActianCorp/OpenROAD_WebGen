@echo off
setlocal

if exist "%CATALINA_HOME%" set WEBAPPDIR=%CATALINA_HOME%\webapps\

if exist "C:\Program Files\Apache Software Foundation\Tomcat 8.5\webapps\" set WEBAPPDIR=C:\Program Files\Apache Software Foundation\Tomcat 8.5\webapps\

if exist "C:\Program Files\Apache Software Foundation\Tomcat 9.0\webapps\" set WEBAPPDIR=C:\Program Files\Apache Software Foundation\Tomcat 9.0\webapps\

echo "Tomcat Webapps: %WEBAPPDIR%"

if exist "%WEBAPPDIR%" ( xcopy /S/Y/Q .\webapps "%WEBAPPDIR%") else ( echo Tomcat webapps not found... )

endlocal
