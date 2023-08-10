#!/bin/bash
signaldir="media/signal"
storagedir="media/storage"
logdir="log/control"
storageserver=""    #directory to shared storage server
tempstorage=$storagedir"/tempstorage/"
donedir=$storagedir"/done"

storage_add(){
    processdate=$( date "+%y-%m-%d" )
    if [ $(ls -l $donedir"/*" | wc -l ) -gt 0 ]
    then
        for file in $tempstorage"/*"
        do
            filename=$( basename $file )
            suffix=$( echo $filename | cut -d "." -f 2 )
            case $suffix in
                request)
                    mv -f $file $storagedir"/history/request/"$processdate"_"$filename
                ;;
                contents)
                    mv -f $file $storagedir"/history/contents/"$processdate"_"$filename
                ;;
                *)
                    mv -f $file $storagedir"/tmpstorage/"$processdate"_"$filename
                ;;
            esac
    fi
}

storage_move(){
    processdate=$( date "+%y-%m-%d" )
    worktime=$( date "+%H:%M:%S" )
    processdate_s=$( date -d $processdate "+%s" )
    for file in $storagedir"/tmpstorage/*"
    do
        $filename=$( basename $file )
        insertday=$( date -d $( echo $filename | cut -d "-" -f 1 ) "+%s" )
        datediff=$(( $processdate_s - $insertday ))
        if [ $datediff -gt 259200 ]
        then
            echo $processdate"_"$worktime" - Move $file to storage cluster" > $logdir
            echo $file >> $signaldir"/tonas/"$processdate
        fi
    done
}