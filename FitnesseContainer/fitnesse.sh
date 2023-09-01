#!/bin/sh
# Fitnesse This shell script takes care of starting and stopping Fitnesse
#
SERVICE_NAME=Fitnesse
#
export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk
export FITNESSE_HOME=/apps/fitnesse
export FITNESSE_PORT=8080
export RUN_AS_USER=fitnesse_user
export PATH=$JAVA_HOME/bin:$PATH
export FITNESSE_LOG_PATH=/apps/fitnesse/logs/
export FITNESSE_STARTUP_LOG=fitnesse.startup.log
export SHUTDOWN_WAIT=20
#
application_pid() {
        echo $(ps -ef | grep -i fitnesse-standalone.jar | grep -v grep | awk {'print $2'})
}
#
start() {
	pid=$(application_pid)
        if [ -n "$pid" ];then
                echo "Fitness is already running (PID: $pid)"
        else
            	# Start fitnesse
                echo "Starting Fitnesse"
                #ulimit -n 100000
                #umask 007
                #sudo -Eu fitnesse_user bash -c 'nohup /usr/lib/jvm/jre-1.8.0-openjdk/bin/java -jar /apps/fitnesse/fitnesse-standalone.jar -d /apps/fitnesse -l /apps/fitnesse/logs/ -p 8080 >> /apps/fitnesse/logs/fitnesse.startup.log &'
                #/bin/bash -c "nohup $JAVA_HOME/bin/java -jar $FITNESSE_HOME/fitnesse-standalone.jar -d $FITNESSE_HOME -l $FITNESSE_LOG_PATH -p $FITNESSE_PORT >> $FITNESSE_LOG_PATH$FITNESSE_STARTUP_LOG &"
                sudo -Eu $RUN_AS_USER bash -c 'nohup $JAVA_HOME/bin/java -jar $FITNESSE_HOME/fitnesse-standalone.jar -d $FITNESSE_HOME -l $FITNESSE_LOG_PATH -p $FITNESSE_PORT >> $FITNESSE_LOG_PATH$FITNESSE_STARTUP_LOG &'                
        fi
	#
	return 0
}
#
stop() {
        pid=$(application_pid)
        if [ -n "$pid" ];then
                echo "Stopping Fitnesse"
                while kill $pid > /dev/null
                do
                  	# Wait for one second
                        sleep 1
                        # Increment the second counter
                        count=$((count + 1))
                        # Has the process been killed? If so, exit the loop. Else hard kill
                        if ! ps -p $pid > /dev/null ; then
                                break
                        fi
                        # Have we exceeded $SHUTDOWN_WAIT? If so, kill the process with "kill -9" and exit the loop
                        if [ $count -gt $SHUTDOWN_WAIT ]; then
                                kill -9 $pid
                                break
                        fi
                done
                echo "Process has been killed after $count seconds."
        else
            	echo "Fitnesse is not running"
        fi
}
#
status() {
	pid=$(application_pid)
        #
	if [ -n "$pid" ];then
                echo "Fitnesse is running with PID: $pid"
        else
            	echo "Fitnesse is not running"
        fi
}
#
echo "Begin"
echo $1
case $1 in
'start')
        start
	status
;;
'stop')
       	stop
	status
;;
'restart')
	stop
	Start
	status
;;
'status')
	status
;;
esac
echo "End"
exit 0

