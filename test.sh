#/bin/bash -v
if [ $env == "DEV" ] 
then
	array=($(find $1 -iname "*.sql"))
    >/home/npatil/sql_client/instantclient_19_3/check.log
    date=`date '+%A_%Y_%m_%d_%H:%M:%S'`
     status="success"
for i in "${array[@]}"
	do
		echo "SQL File name :"$i
		cd /home/npatil/sql_client/instantclient_19_3
		 echo exit | ./sqlplus dummy/$dummy@'(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=10.117.135.26)(PORT = 1521))(CONNECT_DATA = (SERVICE_NAME = ORCLCDB.localdomain)))'  <<EOF >>check.log
   		@$WORKSPACE/$i  
EOF
	grep "ERROR" check.log
    echo $?
    if [ $? -eq 0 ]
		then
        cd /home/npatil/sql_client/instantclient_19_3
		echo exit | ./sqlplus -v  
    	echo ROLLBACK | ./sqlplus dummy/$dummy@'(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=10.117.135.26)(PORT = 1521))(CONNECT_DATA = (SERVICE_NAME = ORCLCDB.localdomain)))' 
        echo "Following error has been found in file $i" >>/tmp/sql_error_$date.log
 		cat check.log >>/tmp/sql_error_$date.log
        status="error"
        exit 2;
     else
        cat check.log >>/tmp/sql_success_$date.log	
	fi
    
done
	cd /home/npatil/sql_client/instantclient_19_3
	echo exit | ./sqlplus -v 
	echo COMMIT | ./sqlplus dummy/$dummy@'(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=10.117.135.26)(PORT = 1521))(CONNECT_DATA = (SERVICE_NAME = ORCLCDB.localdomain)))'  >> /tmp/sql_success_$date.log

echo "checking"
echo "Status of script execution: $status" | mail -A /tmp/sql_$scriptstatus_$date.log -s "SQL Script Execution Report" npatil@rocketsoftware.com

fi
