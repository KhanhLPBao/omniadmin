#!/usr/bin/python3.10
signaldir = "/mnt/share/source/debug/signal"
session_working = f'{signaldir}/system/working.l'
logdir="/mnt/share/source/debug/log"
progressdir = f"{signaldir}/processing"
############    IMPORT DATA   ############
import sys
import os
import json

sessionname = sys.argv[1]
date = sys.argv[2]
time = sys.argv[3]
sessionid = f'{sessionname}'
blanktemp = {
    'date enlisted': date,
    'time enlisted': time,
    'session directory': f'{signaldir}/session/{date}/{sessionname}',
    'session files': {},
    'session command': {},
    'session progress': [],
    'session stop': {},         #File stopped processing due to error or all jobs completed
    'session status': -1,
}
with open(session_working) as _session_data_in:
    _session_lib = [l.rstrip() for l in _session_data_in.readlines()]
    _session_data_in.close()

############    PROCESSING  ############
_session_lib.append(sessionid)
try:
    with open(session_working,'w') as _session_data_out:
        data_write = '\n'.join(_session_lib)
        _session_data_out.write(data_write)
        _session_data_out.close()
    if os.path.isdir(f'{signaldir}/session/{date}'):
        pass
    else:
        os.mkdir(f'{signaldir}/session/{date}_{sessionname}')

    with open(f'{signaldir}/session/{date}_{sessionname}/session.json','w') as _json:   #json for omni interface
        json.dump(blanktemp,_json,indent=1)
        _json.close()

    with open(f'{logdir}/adminlog/{date}_queqe.adminlog','a') as _log:
        _log.write(f'\n{time} - Add {sessionid} to working list of date {date}')
        _log.close()
    exit(0)

except FileExistsError:
    exit(1)