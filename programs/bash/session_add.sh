#!/bin/bash
signaldir="/mnt/share/source/debug/signal"
storagedir="/mnt/share/source/debug/storage"
logdir="/mnt/share/source/debug/log/session"
linkdir=$storagedir"/link"
###################################3
# Requestest from GUI come at 2 files: .request and .contents
# .request contain session id and priority status
# .contents contain filename and method to get it

while :
do
    requests=( $signaldir"/request/*.request" )
    for request in ${requests[@]}
    do
        if [ "$( basename $request )" != "*.request" ]
        then
            echo $request

            workdate=$( date "+%y-%m-%d" )
            worktime=$( date "+%H:%M:%S" )
            account=$( basename $request | cut -d "." -f 1 | cut -d "-" -f 2 )
            normalcount=$( ls $signaldir"/queqe/normal" | wc -l ) 
            prioritycount=$( ls $signaldir"/queqe/high" | wc -l )     
            queqebefore=$(( $normalcount + $prioritycount ))
            content=$( cat $request )
            echo "content: "$content
            session=$( echo $content | cut -d " " -f 1  )
            prio=$( echo $content | cut -d " " -f 2 )
            echo "prior: "$prior
            case $prio in
                0)
                    priority="normal"
                ;;
                1)
                    priority="high"
                ;;
            esac
            echo "priority: "$priority
            session_dir="$signaldir/queqe/$priority"
            session_queqe=$(( $( ls -l $session_dir | grep ^- | wc -l ) + 1 ))
            echo $session_queqe > "$signaldir/queqe/number$priority" 
        #LOG
            echo $worktime" - Account $account request session $session as $priority priority, 
            number of Session(s) need to reprocess before this: $queqebefore ))" \
            >> $logdir"/"$workdate"_add.adminlog"
        #END LOG   
            mv -f "$request" $signaldir"/queqe/"$priority"/"$session_queqe"_"$session".request"
            if [ ! -d "$storagedir/input/$session" ]
            then
                mkdir "$storagedir/input/$session"
            fi
            mv -f $signaldir"/request/"$session".contents" $storagedir"/input/"$session"/filenames.files"
        fi
    done
    sleep 1m
done