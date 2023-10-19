#!/bin/bash
signaldir="/mnt/share/source/debug/signal"
storagedir="/mnt/share/source/debug/storage"
logdir="/mnt/share/source/debug/log/session"
linkdir=$storagedir"/link"
statusdir=$storagedir"/status"
pythondir="/mnt/share/source/omniadmin/python"

movefile(){
    tmp_dir="$signaldir/processing/"
    process_all_count=$( python $pythondir"/foldercount.py" process $tmp_dir all)
    _queqe_high_dir=$signaldir/queqe/high/
    priority_await=$( python $pythondir"/foldercount.py" queqe $_queqe_high_dir )
    echo "* Processing folder - Total request: $process_all_count
* Processing folder - Number of high priority files: $priority_await"
    if [ $priority_await -gt 1 ]
    then
        workdate=$( date "+%y-%m-%d" )
        worktime=$( date "+%H:%M:%S" )
        if [ ! -d  $logdir"/"$workdate"_queqe.adminlog" ]
        then
        echo ""> $logdir"/"$workdate"_queqe.adminlog"
        _process_high_count=$( python $pythondir"/foldercount.py" process $signaldir"/processing" prior)
        fi
#        Move priority request
        n=$_process_high_count
        for file in  $signaldir/queqe/high/*.request 
        do
            echo "Scanning High priority request "$file
            if [ -f $file ] && [ $process_all_count -lt 8 ] 
            then
                
#                    #LOG
                echo $worktime" - Detect "$priority_await" High priority requests"\
                >> $logdir"/"$workdate"_queqe.adminlog"
                echo $worktime" Found less than 8 files in process folder => Moving... "\
                >> $logdir"/"$workdate"_queqe.adminlog"
#                    #END LOG 
                n=$(( n + 1 ))
                name_origin=$( basename $file | cut -d "_" -f 2 )
                name_new=$n"_1_"$name_origin
                mv -f "$file" $signaldir"/processing/"$name_new
                echo "$file moved"
                tmp_sessionstatusname=$( echo $name_origin | cut -d "." -f 1 )
                echo 1 > $statusdir"/"$tmp_sessionstatusname".sessionstatus"
            fi
        done
    fi
#
#    Rename all normal files to match with new queqe
#        LOG
    echo $worktime" - Resorting normal requests... " >> $logdir"/"$workdate"_queqe.adminlog"
#        END LOG     
    process_all_count=$( python $pythondir"/foldercount.py" process $signaldir"/processing" prior)
    for file in $signaldir/processing/*_0_*.request
    do
        echo "Scanning normal priority request "$( basename $file )
        if [ -f $file ]
        then
            process_all_count=$(( process_all_count + 1 ))
            b=`basename $file`
            filename=`echo $b | cut -d "_" -f 3`
            newname=$process_all_count"_0_"$filename
            if [ ! $newname == $b ]
            then
                echo "Normal priority request $file will be renamed to $newname"
                mv -f "$file" $signaldir"/processing/"$newname
            fi
        fi
    done
#
#   Add normal queqe to process if total number of files below 8
    _queqe_normal_dir=$signaldir"/queqe/normal/"
    normal_count=$( python $pythondir"/foldercount.py" queqe $_queqe_normal_dir )
    echo "Total number of normal request on:
    - Queqe: $normal_count
    - Process: $( python $pythondir"/foldercount.py" process $tmp_dir prior)"

    if [ $normal_count -gt 0 ] && [ $process_all_count -lt 8 ]
    then
        #LOG
        echo $worktime" - Detect "$normal_count" requestes from normal queqe"\
        >> $logdir"/"$workdate"_queqe.adminlog"
        echo $worktime" Found less than 8 files in process folder => Moving... "\
        >> $logdir"/"$workdate"_queqe.adminlog"
        #END LOG
        process_all_count=$( python $pythondir"/foldercount.py" process $signaldir"/processing" all)
        for file in $signaldir/queqe/normal/*.request 
        do
            echo "File scanned: $file"
            if [ -f $file ] && [ $process_all_count -lt 9 ]
            then
                echo $file
                process_all_count=$(( $process_all_count + 1 ))
                name_normal_origin=$( basename $file | cut -d "_" -f 2 )
                name_normal_new=$process_all_count"_0_"$name_normal_origin            
                mv -f "$file" $signaldir"/processing/"$name_normal_new      
                echo $file" moved"
                tmp_sessionstatusname=$( echo $name_normal_origin | cut -d "." -f 1 )
                echo 1 > $statusdir"/"$tmp_sessionstatusname".sessionstatus"         
            fi
        done
    fi
}
#Only work if the processing folder has less than 8 files
#Coding to have 2 digits on all counting is not worth the time ATM
while :
do
    tmp_file_process=$signaldir"/processing"
    file_process_all_count=$( python $pythondir"/foldercount.py" process $tmp_file_process all)
    if [ $file_process_all_count -lt 8 ]
    then
        echo "Move file begin"
        movefile
    fi
    sleep 1m
done
