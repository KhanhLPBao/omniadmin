import sys
filename = sys.argv[1]
with open(filename) as _data:
    if "Date enlisted" in _data.read():
        print(1)
    else:
        print(0)