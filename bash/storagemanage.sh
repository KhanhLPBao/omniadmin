#!/bin/bash
signaldir="media/signal"
storagedir="media/storage"
logdir="log/control"
storageserver=""    #directory to shared storage server
tempstorage=$storagedir"/sessioncache"
donedir=$storagedir"/done"

storage_move(){
    processdate=$( date "+%y-%m-%d" )
    worktime=$( date "+%H:%M:%S" )
    processdate_s=$( date -d $processdate "+%s" )
    for session in $tempstorage"/*"
    do
        if [ -d $session ]
        then
            sessionid=$( basename $file )
            insertday=$( date -d $( echo $sessionid | cut -d "_" -f 2 ) "+%s" )
            datediff=$(( $processdate_s - $insertday ))
        fi

        if [ $datediff -gt 259200 ]
        then
            echo $processdate"_"$worktime" - Move $file to storage cluster" > $logdir
            echo $session >> $signaldir"/nas/request/movefile/"$session
        fi
    done
}

cache_add(){
    for file in $signaldir"/done/*.request"
    do
        if [ -f $file ]
        then
            sessionid=$( basename $file )
            if [ -d $storangedir"/processing/"$sessionid ]
            then
                mv -f $storangedir"/processing/"$sessionid $tempstorage
                mv -f $signaldir"/done/"$sessionid".*" $tempstorage"/"$sessionid
            fi
        fi
}

while :
do
    cache_add
    storage_move
done