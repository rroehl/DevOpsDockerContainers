#!/bin/bash
# trap the container shutdown
trap 'shut_down' SIGTERM

# Populate these variable
processname=
fulllogpath=
fullstartscriptpath=

shut_down(){
       now=$(date)
       echo "$now stopping $processname" >> $fulllogpath

        # Stop the process via the signal handler
       $fullstartscriptpath stop >> $fulllogpath
       echo "$now $processname stopped" >> $fulllogpath
}

now=$(date)
echo "$now starting $processname" >> $fulllogpath

#Start the process
$fullstartscriptpath start >> $fulllogpath

echo "$now started $processname" >> $fulllogpath

# Sleep forever
sleep infinity & wait