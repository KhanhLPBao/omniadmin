import json as j
import sys

admindir=""
logdir=f'{admindir}/log/processing'
maindir = "~/Program/maindir/maindir.txt"
with open(maindir).read() as maindir:
    signaldir = maindir.split(' ')[0]
    storagedir = maindir.split(' ')[1]
    maindir.close()

statusdir = f'{storagedir}/status'
sessionid = sys.argv[1]


with open('priority_program.json') as p:
    priority_prog = j.load(p)
    p.close()
del p

enlistedprog = [priority_prog[x] for x in priority_prog]
programrequest = f'{storagedir}/method/{sessionid}/programs.prog'

programs = [r.rstrip() for r in open(programrequest).readlines()]
unmatched = []

for prog in programs:
    if prog in enlistedprog:
        pass
    else:
        unmatched.append(prog)

if len(unmatched) > 0:  #Error
    with open(f'{statusdir}/{sessionid}.sessionstatus','a') as errdet:
        errdet.write('\nE1')    #E1 Error: Unauthorized methods
        errdet.close()
    exit('E1')
else:
    exit(0)