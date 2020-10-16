# OpenROAD WebGen Sample Applications

Latest version available from https://github.com/ActianCorp/OpenROAD_WebGen

Latest ZIP downloads from https://github.com/ActianCorp/OpenROAD_WebGen/archive/main.zip

## Initial Setup

1. Install OpenROAD 11.1 on Windows
2. Create a database for webgen testing, for example - `createdb webgendemodb`
3. Install Apache Tomcat 9 or 8.5. This web server will host webapps. 
4. Install Web browsers to be tested
    * Google Chrome (Minimum version 58)
    * Mozilla FireFox (Minimum version 52)
    * Microsoft Edge (Minimum version 12)
5. Under Windows additional setup steps: 
    * Install Cygwin or use bash from git install, e.g. launch `"C:\Program Files\Git\git-bash.exe"`
    * `set SHELLOPTS=igncr` to ignore windows line endings

## OpenROAD Applications
1. arithmetic
    * This application has a User Frame, 4GL procedure and User Class
    * Integer and Float arithmetic is done in click event, local procedure, 4GL procedure and user class methods
2. guiwidgets
    * This application has a frame with various GUI widgets such as freetrim, boxtrim, entryfield, multiline entryfield, togglefield, buttonfield, radiofield, optionfield and listfield
3. helloutf8
    * This application has a frame with imagetrim and shows unicode support
4. jsonrpctest
    * With this application you can test helloworld json-rpc request
    * Generated Web Application need to be deployed on same web server where JSON-RPC endpoint is available
    * Please note that button biases are not yet implemented in webgen
5. listen2port
    * This application generates a port number for an Ingres Installation ID
6. subtract
    * With this application you can test subtract json-rpc request
    * Generated Web Application need to be deployed on same web server where JSON-RPC endpoint is available
7. tablefield
    * This application has a frame with a tablefield
    * Please note that a table in web application is readonly

## Using bash/bat scripts to create and deploy webapps

Please run all commands from the source directory i.e. where or_webgen.bash resides.

1. `bash or_webgen.bash <DBNAME>` or `or_webgen.bat <DBNAME>`
    * You can run `bash or_webgen.bash <DBNAME>` where bash is available in PATH, for example git-bash, cygwin environment
    * If bash is not available in PATH, run `or_webgen.bat <DBNAME>` which adds cygwin binaries to PATH and then runs or_webgen.bash
    * It imports OpenROAD applications from orapps/ directory into the database specified
    * Then it generates javascript and html files for each OpenROAD application into webapps/ directory and log to logs/or_webgen.log
    * Test application to be ignored can be added to orapps/ignore_apps.lst
2. `bash or_webgen.bash <DBNAME> <APPNAME>` or `or_webgen.bat <DBNAME> <APPNAME>`
    * This imports, generate html and javascript files for the specified OpenROAD application
3. `deploy.bat` (Tomcat 8.5/9 on Windows only)
    * Copies all generated webapps into Tomcat webapps directory

## Notes

1. Tested under Windows only
2. Refer OpenROAD WebGen documentation for more details
