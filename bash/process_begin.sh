#!/bin/bash
admindir=""
signaldir="media/signal"
storagedir="media/storage"
logdir=$admindir"/log/processing"
linkdir=$storagedir"/link"
workingdir=$signaldir"/working/"
processdir=$signaldir"/processing"
sessiondir=$signaldir"/sessions"
errordir=$storagedir"/error"
statusdir=$storagedir"/status"
scriptdir="~/Programs/scripts/admin/python/"
while :
do
    #<code>
        #<IF>
    if [ $( ls -l $workingdir"/*" | wc -l ) -eq 1 ]
    then
        for file in $workingdir"/*"
        do
            #<IF>
            if [ "$file" != $workingdir"/*" ]
            then
                filename=`basename $file`
                sessionid=$( echo $filename | cut -d "." -f 1 )
                prog_check=$( python $scriptdir"/checksession.py" \
                    $sessionid )
                case $prog_check in
                    0)
                        pass
                    ;;
                    *)  #ERROR
                        pass
                    ;;
                esac
            fi
            #</IF>
            python $scriptdir"/preparescripts.py" $sessionid
        done
    fi
        #{/IF}
    #<end code>
    sleep 1m 
done