import json as j
import sys
import os 
import glob

maindir = "~/Program/maindir/maindir.txt"
with open(maindir).read() as maindir:
    signaldir = maindir.split(' ')[0]
    storagedir = maindir.split(' ')[1]
    maindir.close()

sessionid = sys.argv[1]

with open('priority_program.json') as p:
    priority_prog = j.load(p)
    p.close()
del p

with open('server_list.json') as s:
    serverlist = j.load(s)
    s.close()
del s

def writescript(session):
    prog_file = f'{signaldir}/working/{session}.request'
    session_prog = [r.rstrip() for r in \
                    open(prog_file).readlines()]
    session_prog = server_prog[3].split(' ')
    session_samples = [r.rstrip() for r in \
                       open(f'{signaldir}/working/{session}.contents').readlines() \
                       if 'prefix' not in r]

    for prior in priority_prog:
        server_prog = priority_prog[prior]
        if server_prog in session_prog:
            clusterinput = f'{signaldir}/{server_prog}/{session}/in'
            count = len(glob.glob(f'{clusterinput}/*.txt'))
            count += 1
            with open(f'{clusterinput}/{count}_{session}.txt','w') as i:
                i.write('\n'.join(session_samples))
                i.close()
            
writescript(sessionid)