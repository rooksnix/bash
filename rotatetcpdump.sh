#!/bin/bash

#sth and filename prefix to store tcpdump captures at                                                                                                                                                                                                                          
CAPTURE_PATH="/tmp/capture"
# Length of time in seconds to capture data for after the event happens                                                                                                                                                                                                          
SLEEP_TIME=60
PIPE="/tmp/pdump.pipe"

# Clear then create named pipe to hold logs                                                                                                                                                                                                                                      
rm -f "$PIPE"
if [[ ! -p "$PIPE" ]]; then
    mkfifo "$PIPE"
else
    echo "ERROR: Pipe $PIPE already exists"; exit
fi

# Start tcpdump with changeable parameters                                                                                                                                                                                                                                       
tcpdump -w "$CAPTURE_PATH" -i any -C 1 -W 5 &
tpid=$!

# Monitor log and copy mesasges to named pipe in background                                                                                                                                                                                                                      
tail -Fn0 /tmp/delete/newfile > "$PIPE" &
mpid=$!

while read ln <"$PIPE"; do
    # Watch for event with the string below                                                                                                                                                                                                                                      
    echo "$ln" | grep -q 'KILLME';
    if [ $? = 0 ]; then
        eventcap="`ls -c ${CAPTURE_PATH}* | head -n1`"
        echo -e "\nFound event (`date`): $ln";
        echo -e " - event occured first within capture: $eventcap "
        echo -e "sleeping for another $SLEEP_TIME seconds in order to capture additional data...\n"
        sleep $SLEEP_TIME
        kill $tpid $mpid
        echo -e "tcpdump[$tpid] stopped\n";
        echo -e "Collect $eventcap and those modified since, or all capture files at $CAPTURE_PATH\n";
        ls -tlc ${CAPTURE_PATH}*
        echo -e "\nBe sure to note:"
        echo -e " - which file was most recently modified."
        echo -e " - that $eventcap was the capture when the event first occured."
        echo -e "Or send all files and the output of this script"
        break;
    fi;
done

# Clean up pipe                                                                                                                                                                                                                                                                  
rm -f "$PIPE"et -x

