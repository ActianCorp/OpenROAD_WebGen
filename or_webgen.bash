#!/bin/bash
#
# This script creates web application from OpenROAD and deploys it under Tomcat
#   It has to be run in an OpenROAD environment (II_SYSTEM, PATH, etc. should be set)
#   Ingres/Net and OR Server should  be running.
#   The parameter passed is the database (incl. vnode) used for the tests.
# USAGE:
#        or_webgen.bash <dbname> [<appname>]
#

# -----------------------------------------------------------------------------
# Function TEST_CLEANUP
#   This function performs the cleanup (deletion of files) and exit of the script.
#   Parameter passed is the exit code to be returned to the shell.
# ------------------------------------------------------------------------------
TEST_CLEANUP()
{
    return_code=$1
	rm -f *.cfg ignore_apps.lst
    if [ -d $LOGDIR ]
    then
        cd $LOGDIR
#       Remove OpenROAD XML export files (XML files containing an <OPENROAD> element).
#       Note: The test stats XML file (if OR_UNITTEST_GEN_XML_STATS=TRUE)
#             is not an export file, thus it will not be deleted.
        for orxml in $(grep -l "^<OPENROAD " *.xml)
        do
            rm -f $orxml
        done
		rm -f *.bash
    fi
    exit $return_code
}

TEST_CHECKCMD()
{
# -----------------------------------------------------------------------------
# Function TEST_CHECKCMD
#   First parameter passed is the return code of the last command executed.
#   Second parameter passed is the expected return code.
#   Third parameter:
#       Y: Indicates an error is deemed as critical
#       N: Any errors are reported, but not as critical
#   Remaining parameters give a brief description of what the command was doing.
# ------------------------------------------------------------------------------
   h_clf_return_code=$1
   shift

   h_clf_return_code_expected=$1
   shift

   h_clf_critical=$1
   shift

   h_clf_command=$*

   if [ $h_clf_return_code -ne $h_clf_return_code_expected ]
   then
      printf "++ ERROR ++\n%s\n" "$h_clf_command"
      printf "+++ Status Code: expected: %s, actual: %s\n\n" $h_clf_return_code_expected $h_clf_return_code

      if [ "$h_clf_critical" = "Y" ]
      then
         TEST_CLEANUP 1
      else
          ((rv++))
      fi
   fi

   return 0
}

# -----------------------------------------------------------------------------
#       Main execution
# -----------------------------------------------------------------------------
rv=0

cd $(dirname $0)
export SCRIPTDIR=`pwd`

if [ $# -lt 1 ]
then
    printf "USAGE:\n\t$0 <dbname> [<appname>] [<compileflags>]\n\n"
    exit 1
fi

if [ -z "$1" ]
then
    printf "Empty <dbname> supplied!\n\n"
    exit 1
fi

export TESTDB=$1

if [ -n "$2" ]
then
	if [ "$2" == "e" ]; then
		export compileflags="-e"
	elif [ "$2" == "w" ]; then
		export compileflags="-w"
	elif [ "$2" == "ew" ]; then
		export compileflags="-e -w"
	else
		export APPNAME=$2
	fi
fi

if [ -n "$3" ]
then
	if [ "$3" == "e" ]; then
		export compileflags="-e"
	elif [ "$3" == "w" ]; then
		export compileflags="-w"
	elif [ "$3" == "ew" ]; then
		export compileflags="-e -w"
	else
		export compileflags=""
	fi
fi

export LOGDIR=$SCRIPTDIR/logs

rm -rf $LOGDIR
TEST_CHECKCMD $? 0 "Y" "Unable to delete $LOGDIR"

echo '\q' | tm -S $TESTDB
TEST_CHECKCMD $? 0 "Y" "Unable to connect to ${TESTDB}"

mkdir -p $LOGDIR
TEST_CHECKCMD $? 0 "Y" "Unable to create $LOGDIR"

export WEBDIR=$SCRIPTDIR/webapps

rm -rf $WEBDIR
TEST_CHECKCMD $? 0 "Y" "Unable to delete $WEBDIR"

mkdir -p $WEBDIR
TEST_CHECKCMD $? 0 "Y" "Unable to create $WEBDIR"

export II_LOG=.

cygwin=false
if [ `uname | grep "^CYGWIN"` ]
then
    cygwin=true
fi

printf "\nOpenROAD WebGen:\n"

cd $LOGDIR
TEST_CHECKCMD $? 0 "Y" "Unable to change into ${LOGDIR}"
rm -f *.xml
cp -r ${SCRIPTDIR}/orapps/* .
TEST_CHECKCMD $? 0 "Y" "Unable to copy OpenROAD application files into ${LOGDIR}"

if $cygwin
then
    display_log_file=`cygpath --windows ${LOGDIR}/or_webgen.log`
    json_registration_file=`cygpath --windows ${SCRIPTDIR}/orapps`
else
    display_log_file=${LOGDIR}/or_webgen.log
    json_registration_file=${SCRIPTDIR}/orapps
fi
export II_W4GL_JSON_CONFIG=${json_registration_file}
printf " Logfile : %s\n" ${display_log_file}

rc=0
rc1=0

for orxml in *.xml
do
    orapp=`basename "$orxml" .xml`
     
	if [ -n "$APPNAME" ]
	then
    	if [ "${orapp,,}" = "${APPNAME,,}" ]
		then
         	((rc1++))
		else
         	continue
		fi
	fi
	
	#   remove any locks for this app, as they would prevent importing
    tm -S ${TESTDB} <<EOF
\sql
DELETE FROM ii_locks WHERE entity_id IN (SELECT entity_id FROM ii_entities WHERE folder_id IN
(SELECT entity_id FROM ii_entities WHERE entity_type='appsource' AND lowercase(entity_name)=lowercase('${orapp}')));
DELETE FROM ii_locks WHERE entity_id IN (SELECT entity_id FROM ii_entities WHERE entity_type='appsource' AND lowercase(entity_name)=lowercase('${orapp}'));
COMMIT;\g\q
EOF
    w4gldev backupapp in ${TESTDB} $orapp $orxml -nreplace -xml -nowindows -Lor_webgen.log -Tyes,logonly -A
    rv1=$?
    if [ $rv1 -eq 0 ]
    then
        printf "\n ${orapp}: "
		if [ -f ignore_apps.lst ]
        then
            grep -w -i ${orapp} ignore_apps.lst > /dev/null && {
                printf "${orapp} IGNORED\n"
                continue
            }
        fi
		
		# Generate WebApp
		webapp="${orapp,,}"
		export WEBAPPDIR=$LOGDIR/${webapp}
		
		rm -rf $WEBAPPDIR
		TEST_CHECKCMD $? 0 "Y" "Unable to delete webapp directory $WEBAPPDIR"

		mkdir -p $WEBAPPDIR
		TEST_CHECKCMD $? 0 "Y" "Unable to create webapp directory $WEBAPPDIR"
		
		cd $WEBAPPDIR
		TEST_CHECKCMD $? 0 "Y" "Unable to change into ${WEBAPPDIR}"
		w4gldev compileapp ${TESTDB} $orapp -js ${webapp}.js -nowindows -L../or_webgen.log -Tyes,logonly -A -l ${compileflags}
		rv2=$?
        if [ $rv2 -eq 0 ]
        then
			printf "WebApp Generation OK.\n"
			
            cp -f ${SCRIPTDIR}/core.js ${WEBAPPDIR}/.
			TEST_CHECKCMD $? 0 "Y" "Unable to copy core.js into $WEBAPPDIR"

			cp -f ${SCRIPTDIR}/orfields.js ${WEBAPPDIR}/.
			TEST_CHECKCMD $? 0 "Y" "Unable to copy orfields.js into $WEBAPPDIR"
			
			for frames in $(ls *.html | sort)
			do
				framename=$(basename $frames .html)
				printf "\n WebApp URL: http://localhost:8080/${webapp}/${framename}.html\n"
			done
			printf "==============================================================\n"
			
			cd $LOGDIR
			TEST_CHECKCMD $? 0 "Y" "Unable to change back into ${LOGDIR}"

			mv -f ${WEBAPPDIR} ${WEBDIR}/.
			TEST_CHECKCMD $? 0 "Y" "Unable to move ${WEBAPPDIR} into ${WEBDIR}"
        else
			printf "WebApp Generation FAILED.\n"
			
			cd $LOGDIR
			TEST_CHECKCMD $? 0 "Y" "Unable to change back into ${LOGDIR}"

			((rc++))
        fi
	else
        printf " ${orapp}: Import of application FAILED.\n"
        ((rc++))
    fi
done

if [ -n "$APPNAME" -a $rc1 -eq 0 ]
then
	printf "\n${APPNAME} application is not found in orapps directory.\n" $rc2
	TEST_CLEANUP $rc1
fi

if [ $rc -ne 0 ]
then
	printf "\nERROR(s) encountered in %s application(s) for WebApp Generation.\n" $rc
	TEST_CLEANUP $rc
else
	printf "\nWebApp Generations successfully executed.\n"
	TEST_CLEANUP 0
fi
