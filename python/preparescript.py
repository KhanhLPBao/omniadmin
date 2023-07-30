import json as j
import sys
import os 

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

def writescript():
    