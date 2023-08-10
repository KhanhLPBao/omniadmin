#!/bin/bash
maindir="~/Program/maindir/maindir.txt"
signaldir=$( cat $maindir | cut -d " " -f 1 )
storagedir=$( cat $maindir | cut -d " " -f 2 )

logdir="log/control"
errordir=$storagedir"/error"
statusdir=$storagedir"/status"
scriptdir="python"
workingdir=$signaldir"/working/"
processir=$signaldir"/processing"
donedir=$storagedir"/done"

session_working="$signaldir/session/working.l"
session_done="$signaldir/session/done"
session_error="$signaldir/session/error"
session_status="$signaldir/session/status"

checksession(){
    ss=( )
    IFS=" " read -r -a $ss <<< $session_working #input array
    if [[ " ${ss[*]} " =~ *"$1"*]]
    then
        pass
    else
        #regis session
        python $scriptdir"/regissession.py" $1
    fi

    for a in ${ss[@]}
    do       
        python $scriptdir"/sessioncheck.py scan " $a
        while read -r $line
        do
            sample=$( echo $line | cut -f ";" -d 1 )
            status=$( echo $line | cut -f ";" -d 2 )
            case $status in
                e)          #Error
                    python $scriptdir"/sessioncheck.py error " $a $sample
                    ss=( "${ss[@]}/$a" )
                    echo ${ss[@]} > $session_working
                ;;
                c)          #Completed
                    python $scriptdir"/sessioncheck.py done " $a
                    ss=( "${ss[@]}/$a" )
                    workdate=$( date "+%y/%m/%d" )
                    worktime=$( date "+%H:%M:%S" )
                    echo $a"-"$worktime >> $session_done"/"$workdate".l"
                    mv -f $signaldir"/working/"$1".*" $donedir
                ;;
                *)
                    pass
                ;;
            esac
        done < $session_status"/"$a".s"

    done
}

while 0
do
    for file in $processir"/*"
    do
        if [ $file != $processir"/*" ]
        then
            session=`echo $( basename $file ) | cut -d "_" -f 3`
            checksession $session
    done
    sleep 2m
done
