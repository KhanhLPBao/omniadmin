#!/usr/env python3.10.13
import json
import sys
from addon.blockengine import requestblock, responseblock
from addon.codeengine import decode, account
import os
#loginrequest:
#[token]|[ID]|[pass - in encoded form]
################
packagedir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(packagedir)

admindir = '/mnt/share/source/debug/admin'
account_storage = f'/storage/account'
serverin = f'/mnt/server/in'


class reg:
    def __init__(self,file,matrix):
        self.file = f'{file}.login'
        self.matrix = matrix
        self.block_component = requestblock(self.file).blockexport()
        match self.block_component[1].split(':')[0]:
            case 'account':
                suggest_account = self.block_component[1].split(':')[1]
                accountfile = f'{account_storage}/{suggest_account}.account'
                if os.path.isdir(accountfile):
                    accountconfig = decode(0).codeblockextract(requestblock(accountfile).block_export())['block']
                    signupblock = self.block_component[-1]
                    signup_encoded = decode(0).codeblockextract(signupblock)
                    signupform = decode(0).decode(signup_encoded['seed'],signup_encoded['block'])
                    account_name = f'{account_storage}/{signupform}.account'
                    if '--signup:1' in accountconfig:
                        if os.path.isdir(account_name):
                            result([signupform,1,'Exists'])
                        else:
                            acc_info = account(signupform).signup()
                            with open(account_name,'w') as createaccount:
                                createaccount.write('\n'.join(map(str,acc_info)))
                                result([signupform,0,''])
                    else:
                        result([signupform,1,'Authority error'])
            case 'adminkey':
                keyid = self.block_component[1].split(':')[1]
                keyseq = self.block_component[1].split(':')[2]
                keyhash = self.block_component[1].split(':')[3]
class login:
    def __init__(self,file,matrix):
        self.matrix = matrix
        self.file = f'{file}.login'
        self.block_component = requestblock(f'{serverin}/{self.file}').block_export()
        self.rqacc, self.accpwd = self.decryptacc(self.block_component[1:3],'2')
        if os.path.isdir(f'{account_storage}/{self.rqacc[0]}.account'):
            comparepwd = self.compare_pwd()
            if comparepwd:
                result([self.rqacc[0],'accept',''])
            else:
                result([self.rqacc[0],'reject','Login mismatch'])
        else:
            result([self.rqacc[0],'reject','Login mismatch'])
    def decryptacc(self,acc_info,rqtype):
        def decrypt_admin(_encryptedstr,rqtype):
            if type(_encryptedstr) is list:
                if len(_encryptedstr) == 1:
                    encryptedstr = _encryptedstr[0]
                else:
                    encryptedstr = _encryptedstr
            else:
                encryptedstr = _encryptedstr
            match rqtype:
                case '1':
                    decode_block = decode(0).codeblockextract(encryptedstr)
                    return decode(0).decode(decode_block[0],decode_block[1])
                case '2':
                    encrypted_block = [encryptedstr[i:i+4] for i in range(0,len(encryptedstr),4)]
                    out = decode(0).decode(self.matrix,encrypted_block)[0]
                    for e in range(len(encrypted_block)):
                        try:
                            combi0 = decode(0).decode(self.matrix,[encrypted_block[e]])
                            if e != len(encrypted_block) - 1:
                                combi1 = decode(0).decode(self.matrix,[encrypted_block[e+1]])
                                if combi0[1] == combi1[0]:
                                    out += combi0[1]
                                else:
                                    out += f'<MISSMATCH at pos {e+1}'
                            else:
                                return out
                        except KeyError:
                            if e != len(encrypted_block) - 1:
                                out += f'<MISSMATCH at pos {e+1}'
                            else:
                                return out
        if type(acc_info) is list:
            return [decrypt_admin(line,rqtype) for line in acc_info]
        else:
            return decrypt_admin(acc_info,rqtype)

    def compare_pwd(self):
        from time import sleep
        from random import uniform
        from hashlib import blake2b  
        """
        ==================+======================+
        In account file:  | In login file:       |
        #1: Salt          | #1: Account (encoded)|
        #2: PWD           | #2: Pass (encoded)   |
        #3: config        |                      |
        ==================+======================+
        """    
        libacc = account(self.rqacc[0]).accountextract()
        libsalt,libpwd,libconfig = self.decryptacc(libacc,'1')
        h = black2b(salt = libsalt)
        h.update(bytes(self.accpwd[0],'utf-8'))
        sleep(uniform(0.2,1))
        compare = libpwd == h.hexdigest()
        return compare
class result:
    def __init__(self,account,response,other):
        from loginresponse import response
        self.account = account
        self.other = other
        self.response = response
        match response:
            case 'reject':
                self.reject()
            case 'accept':
                self.accept()
    def reject(self):
        reject_log = self.other
        self.response(session,[self.account,1,self.other])
    def accept(self):
        self.response(session,[self.account,1,'0'])

if __name__ == '__main__':
    from time import sleep
    print('Begin login comparison')
    request = sys.argv[2]
    session = sys.argv[1]
    print(request,session)    
    seq = f'{serverin}/{session}.seq'
    while True:
        if os.path.isfile(seq):
            print('Found seq file')
            with open(seq) as seqfile:
                matrix = [_a for _b in seqfile.readlines() for _a in _b.rstrip().split('\t')]
                #print('login.py - matrix is\n',matrix)
                #os.remove(seq)
                break
        else:
            print('No Seq file found, sleeping...')
            sleep(1)
    
    match request:
        case 'register':
            reg(session,matrix)
        case 'login':
            login(session,matrix)
        case 'test':
            print(matrix)
        