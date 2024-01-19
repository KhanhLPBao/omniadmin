#!/usr/bin/env python3.10
import glob
#####       Function keywords        #####
function_keyword = ['test','process','queqe']
##########################################
try:
    args_input = {'function':sys.argv[1], 'folder':sys.argv[2]}
except IndexError:
    if args_input[1] == 'test':
        args_input['folder'] = None
    elif args_input[1] == None:
        print("ERROR - No funtion input")
        exit 
    elif args_input[1] not in function_keyword:
        print("ERROR - Function not matched")
        exit 
##########              Functions           ##########
def test():
    print(f"Testing to see if the python 3.10 in running on this script\n\
        \t- Function: Testing to see the script is running with python3.10\n\
        \t- Dir: Testing not required")  
def countprocess():
    count_type = sys.argv[3]
    count_lib = {
        'prior':f'{args_input["folder"]}/*_1_*.request',\
        'normal':f'{args_input["folder"]}/*_0_*.request',\
        'all':f'{args_input["folder"]}/*.request',\
    }        
    c = len(glob.glob(count_lib[count_type]))
    print(c)
def countqueqe():
    c = len(glob.glob(f'{args_input["folder"]}/*.request'))
    print(c)
######################################################
#####       Function library        #####
function_lib = {'test':test,\
                'process':countprocess,\
                'queqe':countqueqe,\
                }            #
#########################################
match args_input['function']:
    case 'test':
        function_lib['test']()
    case other: 
        function_lib[args_input['function']]()