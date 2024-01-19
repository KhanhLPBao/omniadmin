class response:
    def __init__(self,session,info:list):
        print('Begin response')
        self.responsestorage = '/storage/response' #directory of communication folder
        self.info = info
        self.session = session
        self.codeblock_export()
        
    def codeblock_request(self):
        requestblock = [
            '<title>',
            'login response',
            '</title>','<registry>',
            self.info[0],
            '</registry>','<input>',
            self.info[1],
            '</input>','<output>',
            self.info[2],
            '</output>',
            '<END>'
        ]
        return requestblock

    def codeblock_export(self):
        from subprocess import run
        from time import sleep
        from random import uniform
        request_block = self.codeblock_request()
        bashdir = '/home/software/login'
        #try:
        with open(f'{self.responsestorage}/{self.session}.response','w') as outputresponse:
            outputresponse.write('\n'.join(map(str,request_block)))
        sleep(uniform(0.3,1.5))
        run([f'bash {bashdir}/ftpupload.sh {self.responsestorage}/{self.session}.response'],shell=True)
        #    return 0
        #except Exception as ex:
        #    return 1   

if __name__ == '__main__':
    print('YOU CANNOT RUN THIS FILE!!!!')
    exit(1)