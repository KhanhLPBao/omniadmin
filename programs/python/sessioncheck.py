#!/usr/bin/python3.10
import sys
signaldir = "/mnt/share/source/debug/signal"
storagedir = "/mnt/share/source/debug/storage"
errorsignaldir=f"{storagedir}/error/signal"
donesignaldir=f"{storagedir}/done/signal"
#sessiondir = f'{signaldir}/session'
command = sys.argv[1]
session = sys.argv[2]
import json
import os
import subprocess as p

def jobscan(_joblib,_file):
    waiting = False
    _statusstr = ''
    for _job in _joblib:
        _job, _status = _job.split(' ')
        match _status:
            case 'w':   #waiting
                waiting = True
            case 'p':   #processing
                _statusstr += ' p '
            case 'd':   #done
                if waiting:
                    _statusstr += ' w '
                else:
                    with open(f'{session}/donefiles.txt','w') as _d_files:
                        _d_files.write(_file + '\n')
                        _d_files.close()
            case 'e':
                    with open(f'{session}/errorfiles.txt','w') as _e_file:
                        _e_file.write(_file + '\n')
                        _e_file.close()
                


def scansession():
    #Get all jobs and filenames listed on the session
    with open(f'{session}/session.jobs') as j, \
    open(f'{session}/session.files') as f:
        totaljobs = [x.rstrip() for x in j.readlines()]
        totalfiles = [r.rstrip().split('/')[-1] for r in f.readlines()[1:]]
        j.close()
        f.close()

    with open(f'{session}/session.json') as _injson:
        session_summarise = json.load(_injson)
        _injson.close()
    if session_summarise['session status'] == -1:           #Create blank template for session to be analyzed
        session_summarise['session files'] = totalfiles
        session_summarise['session command'] = totaljobs
        session_summarise['session stop'] = {
            x:0 for x in totalfiles
        }
        session_summarise['session status'] = 0
        with open(f'{session}/session.json','w') as _outjson:
            json.dump(session_summarise,_outjson,indent=1)
            _outjson.close()
    elif session_summarise['session status'] == 0:
        progress={} 
        if os.path.isfile(f'{session}/status.json'):
            with open(f'{session}/status.json') as _tmpjsonload:
                session_file_status = json.load(_tmpjsonload)
                for session_file in session_file_status:
                    jobs_status = session_file_status[session_file]
                    job_scan = jobscan(jobs_status,session_file)    
        else:
            session_template_file_job = {
                x:[f'{y} 0' for y in totaljobs] for x in totalfiles
            }
            with open(f'{session}/status.json','w') as _job_status:
                json.dump(session_template_file_job,_job_status)
            files_status = [session_summarise['session stop'][m]  for m in session_summarise['session stop']]
            files_status = [n == 0 for n in files_status]
            if False not in files_status:
                print(5)
            else:
                print(0)

def sessionsuccess():
    try:
        sessionid = session.split('/')[-1].split('.')[0]
        with open(f'{session}/donefiles.txt') as signal_done:
            signal_lib = [v.rstrip() for v in signal_done.readlines() if v.rstrip() != '']
        if signal_lib != ['']:
            for donefile in signal_lib:
                if os.path.isdir(f'{donesignaldir}/{sessionid}') is False:
                    os.mkdir(f'{donesignaldir}/{sessionid}')
                if os.path.isfile(f'{donesignaldir}/{sessionid}/filetransfered.txt') is False:
                    f = open(f'{donesignaldir}/{sessionid}/filetransfered.txt','w')
                    f.close()
                with open(f'{donesignaldir}/{sessionid}/filetransfered.txt','a+') as signal_done_export:
                    signal_done_lib = [k.rstrip() for k in signal_done_export.readlines()]
                    if donefile not in signal_done_lib:
                        signal_done_export.write(donefile + '\n')
                # For command to move files to donedir
    except FileNotFoundError:
        print(0)
            
def sessionerror():
    try:
        sessionid = session.split('/')[-1].split('.')[0]
        with open(f'{session}/errorfiles.txt') as signal_done:
            signal_lib = [v.rstrip() for v in signal_done.readlines() if v.rstrip() != '']
            signal_done.close()
        if signal_lib != ['']:
            for donefile in signal_lib:
                if os.path.isdir(f'{errorsignaldir}/{sessionid}') is False:
                    os.mkdir(f'{errorsignaldir}/{sessionid}')
                if os.path.isfile(f'{errorsignaldir}/{sessionid}/filetransfered.txt') is False:
                    f = open(f'{errorsignaldir}/{sessionid}/filetransfered.txt','w')
                    f.close()
                with open(f'{errorsignaldir}/{sessionid}/filetransfered.txt','a+') as signal_done_export:
                    signal_done_lib = [k.rstrip() for k in signal_done_export.readlines()]
                    if donefile not in signal_done_lib:
                        signal_done_export.write(donefile + '\n')
                        signal_done_export.close()     
                # For command to move files to errordir  
    except FileNotFoundError:   #No file generated, continue
        print(0) 



match command:
    case "scan":
        scansession()
    case "error":
        sessionerror()
    case "done":
        sessionsuccess()
