#!/bin/bash
clientdir="/mnt/share/source/omniclient"
inputdir="source/debug/omniclient"
processdir="/mnt/share/source/debug/signal/processing"
session_store_id=1
maxworking=1    #total number of processing that can be run at the same time

process_begin(){
    for file in $processdir/*.request
    do
        if [ -f $file ]
        then
            filename=`cat $file | cut -d "=" -f 3 | cut -d ":" -f 2`
            #mv $file $clientdir"/input/$filename.admin"
            echo Begin $filename
            bash $clientdir/admin/bash/account/accountscan.sh $filename admin
            rm $file
        fi
    done
}
while :
do
    process_begin
    sleep 1m
done
