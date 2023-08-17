#!/usr/bin/python3.10
import sys
signaldir = ''
storagedir = ''
progressdir = f'{signaldir}/progress'
command = sys.argv[1]
session = sys.argv[2]
import json
import os
import subprocess as p
def scansession():
    #Get all jobs listed on the session
    with open(f'{progressdir}/{session}/{session}.jobs') as j, \
        open(f'{progressdir}/{session}/filenames.files') as f:
        totaljobs = j.read()
        totalfiles = [r.rstrip() for r in f.readlines()[1:]]
        progress={}
        for file in totalfiles:
            job_status = []
            for jobs in totaljobs:
                with open(f'{signaldir}/{jobs}/{session}/out/{file}.status') as tmp_fs:
                    filestatus = tmp_fs.read()
                    tmp_fs.close()
                if filestatus == 0:     #waiting to be analyzed
                    job_status.append(f'{jobs} w')
                elif filestatus == 1:     #file is processing
                    job_status.append(f'{jobs} p')
                elif filestatus == 2:     #job done
                    job_status.append(f'{jobs} d')
                elif filestatus == 'e':   #error
                    job_status.append(f'{jobs} e')
        waiting = False
        for js in job_status:
            stt = js.split(' ')[1]
            if stt == 'e':
                progress[js] = 'e'
                break
            elif stt == 'w':
                progress[js] = 'w'
                waiting = True
                break
            elif stt == 'd':
                if waiting:
                    pass
                else:
                    progress[js] = 'c'

def sessionerror():
    filename = sys.argv[2]
    if os.path.exists(f'{storagedir}/tempstorage/{session}/{filename}.json'):
        with open(f'{storagedir}/tempstorage/{session}/{filename}.json') as tmp_pro:
            fileprogress = json.load(tmp_pro)
            tmp_pro.close()
        fileprogress[filename] = 'e'

        with open(f'{storagedir}/tempstorage/{session}/{filename}.json','w') as tmp_new:
            json.dump(fileprogress,tmp_new)
            tmp_new.close()
        p.run(f"mv -f {storagedir}/queqe/{filename}.fq.gz {storagedir}/{session}/errstorage",\
              shell=True,stdout=p.null, stderr=p.null)

def sessionsuccess():
    filename = sys.argv[2]     
    if os.path.exists(f'{storagedir}/tempstorage/{session}/{filename}.json'):
        with open(f'{storagedir}/tempstorage/{session}/{filename}.json') as tmp_pro:
            fileprogress = json.load(tmp_pro)
            tmp_pro.close()
        fileprogress[filename] = 'S'

        with open(f'{storagedir}/tempstorage/{session}/{filename}.json','w') as tmp_new:
            json.dump(fileprogress,tmp_new)
            tmp_new.close()
        p.run(f"mv -f {storagedir}/queqe/{filename}.fq.gz {storagedir}/{session}/tmpstorage", shell=True,stdout=p.null, stderr=p.null)
        prog_file = f'{signaldir}/working/{session}.request'
        session_prog = [r.rstrip() for r in \
                        open(prog_file).readlines()]
        kq = []
        for task in session_prog:
            if os.path.exists(f'{signaldir}/{task}/{session}/in/results.txt'):
                kq.append(f'{signaldir}/{task}/{session}/in/results.txt')
        with open(f'{signaldir}/interface/request/{session}.request') as tmp_exp_req:
            token = json.load(tmp_exp_req.read())['token']
            tmp_exp_req.close()
        with open(f'{signaldir}/interface/response/{token}.response','w') as tmp_tk_res:
            tmp_tk_res.write('\n'.join(kq))
            tmp_tk_res.close()

match command:
    case "scan":
        scansession()
    case "error":
        sessionerror()
