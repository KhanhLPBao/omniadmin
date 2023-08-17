#!/bin/bash
admindir=""
signaldir="media/signal"
storagedir="media/storage"
logdir=$admindir"/log/processing"
linkdir=$storagedir"/link"
workingdir=$signaldir"/working"
donedir=$signaldir"/done"
processdir=$signaldir"/processing"
sessiondir=$signaldir"/sessions"
errordir=$storagedir"/error"
statusdir=$storagedir"/status"
scriptdir="~/Programs/scripts/admin/python/"
while :
do
    #<code>
        #<IF>
    if [ $( ls -l $workingdir"/*" | wc -l ) -gt 1 ]
    then
        for file in $workingdir"/*.contents"
        do
            #<IF>
            if [ -f $file ]
            then
                filename=`basename $file`
                sessionid=$( echo $filename | cut -d "." -f 1 )
                prog_check=$( python $scriptdir"/session_new.py" \
                    $sessionid )
                if [ $prog_check -eq 1 ]
                then
                    python $scriptdir"/preparescript.py"

                fi
            fi
            #</IF>        
        done
    fi
        #{/IF}
    #<end code>
    sleep 1m 
done