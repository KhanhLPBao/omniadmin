#!/bin/bash
signaldir=$1
storagedir=$2
logdir="log/session"
linkdir=$storagedir"/link"
statusdir=$storagedir"/status"

movefile(){
    tmp_dir="$signaldir/processing/*_1_*.request"
    priority_count=$( ls -l $tmp_dir | grep ^- | wc -l )
    echo $priority_count
    tmp_dir2=$signaldir/queqe/high/
    priority_await=$( ls -l $tmp_dir2 | grep ^- | wc -l )
    echo "Priority: $priority_await"
    if [ $priority_await -gt 1 ]
    then

        workdate=$( date "+%d-%m-%y" )
        worktime=$( date "+%H:%M:%S" )

        #LOG
        echo $worktime" - Detect "$(( priority_await - 1 ))" requestes from priority queqe - Moving... "\
        >> $logdir"/"$workdate"_queqe.adminlog"
        #END LOG 
        tmp_count_high=(  )
        tmp_count_process=$signaldir"/processing/"
        for file in  $signaldir/queqe/high/*.request #Move priority request
        do
            echo $file
            if [ "$file" != $signaldir"/queqe/high/*.request" ] && \
            [ $( ls -l $tmp_count_process | grep ^- | wc -l ) -lt 8 ] 
            then
                priority_count=$(( $priority_count + 1 ))
                name_origin=$( basename $file )
                name_new=$priority_count"_1_"$name_origin
                mv -f "$file" $signaldir"/processing/"$name_new
                echo "$file moved"
                tmp_sessionstatusname=$( echo $name_origin | cut -d "." -f 1 )
                echo 1 > $statusdir"/"$tmp_sessionstatusname".sessionstatus"
            fi
        done
    fi
    #Rename all normal files to match with new queqe
        #LOG
    echo $worktime" - Resorting normal requests... "\
    >> $logdir"/"$workdate"_queqe.adminlog"
        #END LOG     
    n=$priority_count
    tmp_count_normal=( $signaldir/processing/*_0_*.request )
    echo "tmp_count_normal: ${tmp_count_normal[@]}"
    for file in $signaldir/processing/*_0_*.request
    do
        echo "Normal: $file"
        if [ "$file" != $signaldir"/processing/*_0_*.request" ]
        then
            n=$(( $n + 1 ))
            b=`basename $file`
            filename=`echo $b | cut -d "_" -f 3`
            old_count=`echo $b | cut -d "_" -f 1`
            newname=$n"_0_"$filename
            mv -f "$file" $signaldir"/processing/"$newname
        fi
    done
    tmp_sig_nor=$signaldir"/queqe/normal/"
    normal_count=$(ls -l $tmp_sig_nor | grep ^- | wc -l )
    echo "Normal: $normal_count Process: $( ls -l $tmp_count_process | grep ^- | wc -l) "

    if [ $normal_count -gt 1 ] && [ $( ls -l $tmp_count_process | grep ^- | wc -l ) -lt 9 ]
    then
        count=$( ls -l $tmp_count_process | grep ^- | wc -l )
        echo "Count: $count"
        #LOG
        echo $worktime" - Detect "$(( normal_count - 1 ))" requestes from normal queqe - Moving... "\
        >> $logdir"/"$workdate"_queqe.adminlog"
        #END LOG
        
        for file in $signaldir/queqe/normal/*.request #Move normal request
        do
            echo "File scanned: $file"
            echo $count
            if [ "$file" != $signaldir"/queqe/normal/*.request" ] && [ $count -lt 9 ]
            then
                echo $file
                count=$(( $count + 1 ))
                name_normal_origin=$( basename $file )
                name_normal_new=$count"_0_"$name_normal_origin            
                mv -f "$file" $signaldir"/processing/"$name_normal_new
                
            fi
        done
    fi
}

resort(){
    count=1

}

#Only work if the processing folder has less than 8 files
#Coding to have 2 digits on all counting is not worth the time ATM

while :
do
    tmp_file_process=$signaldir"/processing/*.request"
    file_process_count=$( ls -l $tmp_file_process | wc -l )
    if [ $file_process_count -lt 8 ]
    then
        movefile
    fi
    sleep 1m
done
