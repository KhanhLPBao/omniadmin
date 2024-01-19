#!/bin/bash
#maindir="~/Program/maindir/maindir.txt"
signaldir="/mnt/share/source/debug/signal"
storagedir="/mnt/share/source/debug/storage"
logdir="/mnt/share/source/debug/log"
scriptdir="/mnt/share/source/omniadmin/python"
processir=$signaldir"/processing"
sessiondir=$signaldir"/session"
requestdir=$signaldir"/request"
session_all_processed=$storagedir"/session"
#####
session_working="$signaldir/system/working.l"
session_done="$signaldir/system/done.l"
session_error="$signaldir/system/error.l"
session_status="$signaldir/system/status.l"


checksession(){
    ss=( )
    #input array

    for file in $processir/*.request
    do
#        echo $file
        if [ -f $file ]
        then
            #echo $file
            filecheck=`echo $( basename $file ) | cut -d "_" -f 3 | cut -d "." -f 1`
            checkifexists=$(python $scriptdir/subscript/request_checkenlist.py $file)
#            echo "Begin checksession with $filecheck"
            if [[ ! $checkifexists -eq 0 ]]
            then
                echo "$filecheck already listed, updated later"
            else
                #regis session
                echo "Registing for $filecheck"
                workdate=$( date "+%y-%m-%d" )
                echo "Workdate: $workdate"
                worktime=$( date "+%H:%M:%S" )                
                regisstatus=$( python $scriptdir"/regissession.py" $filecheck $workdate $worktime )
                if [[ $regisstatus -eq 0 ]]
                then
                    tmp_filename=`echo $(basename $file) | cut -d "." -f 1`
                    mv $requestdir"/"$filecheck".jobs" $sessiondir"/"$workdate"_"$filecheck"/session.jobs"
                    mv $requestdir"/"$filecheck".files" $sessiondir"/"$workdate"_"$filecheck"/session.files"
                    echo "=Date enlisted:$workdate=Session name:$workdate"_"$filecheck" >> $file

                fi
            fi
        fi           
    done

    for a in $sessiondir/*
    do       
        status_scan=$( python $scriptdir/sessioncheck.py scan $a )
        python $scriptdir/sessioncheck.py error $a
        python $scriptdir/sessioncheck.py done $a
        if [[ $status_scan -eq 5 ]] #Code 5: all files processed
        then
            echo "Session completed"
            mv -f $a $session_all_processed"/"
            #   For script to move neccessary files to storage  #  
        fi
    done
}

start_date=$( date "+%y-%m-%d" )
start_time=$( date "+%H:%M:%S" )
##  BEGIN LOOP  ##
echo "=========================================================" >> $logdir"/system/initlog.log"
echo "sessioncontrol.sh Initiate" >> $logdir"/system/initlog.log"
echo "=========================================================" >> $logdir"/system/initlog.log"
#   Create working.l if not exists
init_date=$( date "+%y-%m-%d" )
init_time=$( date "+%H:%M:%S" )

echo "$init_date $init_time sessioncontrol.sh turned on" >> $logdir"/system/initlog.log"

if [ ! -f $session_working ]
then
    echo "" > $session_working
    echo "+-----$init_date - $init_time $session_working not found, create one" >> $logdir"/system/initlog.log"
fi
if [ ! -f $session_done ]
then
    echo "" > $session_done
    echo "+-----$init_date - $init_time $session_done not found, create one" >> $logdir"/system/initlog.log"
fi
if [ ! -f $session_error ]
then
    echo "" > $session_error
    echo "+-----$init_date - $init_time $session_error not found, create one" >> $logdir"/system/initlog.log"
fi
if [ ! -f $session_status ]
then
    echo "" > $session_status
    echo "+-----$init_date - $init_time $session_status not found, create one" >> $logdir"/system/initlog.log"
fi
while :
do
    checksession
    sleep 1m
done
