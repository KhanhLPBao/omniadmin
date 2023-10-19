#!/bin/bash
clientdir="/mnt/share/source/debug/omniclient"
processdir="/mnt/share/source/debug/signal/processing"
session_store_id=$1
maxworking=1    #total number of processing that can be run at the same time

process_begin(){
    for file in $processdir/*.request
    do
        if [ -f $file ] && [[ $( ls -l $clientdir/input/* | wc -l ) -lt $maxworking ]]
        then
            mv $file $clientdir"/input"
        fi
    done
}
while :
do
    process_begin
    sleep 1m
done
