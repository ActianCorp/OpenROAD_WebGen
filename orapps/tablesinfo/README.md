# OpenROAD "tablesinfo" Sample Applications 

## OpenROAD Applications

1. `tablesinfo` - export file: `tablesinfo.xml`
    * This application is an OpenROAD Server application that connects to a database (default: localhostii::demodb).
    * It provides the "gettables" 4GL procedure that provides information about available user tables/views/indexes.
2. `tablesinfo_client` - export file: `tablesinfo_client.xml` 
    * This is a client GUI application that contains a "top" frame, whcich connects to the OpenROAD Server application via "http-jsonrpc" routing.
    * It calls the "gettables" 4GL procedure in the server via a JSON-RPC request.
3. `tablesinfo_shared` - export file: `tablesinfo_shared.xml`
    * This application contains the class uctables that is used in both `tablesinfo` and `tablesinfo_client`.
    * It is used in both `tablesinfo` and `tablesinfo_client` as included application.


## Build, Deploy, Run, WebGen

1. Import the `tablesinfo_shared`, `tablesinfo` and `tablesinfo_client` applications from their export files.
2. Build an image file`tablesinfo.img` from the the `tablesinfo` application and place it into the `%II_SYSTEM%\ingres\w4glapps` directory of your OpenROAD Server installation.
3. Place the `tablesinfo.json` file  into the `%II_SYSTEM%\ingres\files\orjsonconfig` directory of your OpenROAD Server installation.
4. Edit the `%II_SYSTEM%\ingres\files\orserver.json` file - add the entry for the `tablesinfo` application into the "rows" array:

    	{
    	"akaname": "tablesinfo",
    	"asolibhousekeepmins": 0,
    	"asolocation": "",
    	"asotrxlimit": 0,
    	"authorizedforspo": 1,
    	"autosuspend": 0,
    	"cmdflags": "-dlocalhostii::demodb -Tyes,logonly -Ltablesinfo.log",
    	"enabled": 1,
    	"environment": null,
    	"environment_exp": null,
    	"guid": "",
    	"imagefile": "tablesinfo.img",
    	"maxslaves": 1,
    	"routing": "",
    	"serverlocation": "",
    	"servertype": 3,
    	"timeoutinterval": 600000,
    	"useasolib": 0
    	},
        
5. Change the `localhostii::demodb` within the "cmdflags" value above to whatever database it should connect to.
6. Restart the OpenROAD Server (and Tomcat).
7. Run the "tablesinfo_client" application - check if it works as expected. 
	- Might have to change the script of the "top" frame to accomodate the URL of the OpenROAD JSON-RPC servlet used.
8. Generate Web applications for the tablesinfo_shared and tablesinfo_client applications:

	    w4gldev compileapp <mydb> tablesinfo_shared -js tablesinfo_shared.js
	    w4gldev compileapp <mydb> tablesinfo_client -js tablesinfo_client.js

9. Apply the generated files into Tomcat and run the HTML for the top frame in a browser (URL like: http://localhost:8080/tablesinfo/top.html).
