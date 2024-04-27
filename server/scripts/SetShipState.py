from sender import sendRequest
from sys import argv

def ParseVision(vision_string,x,y):
    if not len(vision_string) == x*y:
        return 'BAD PARAMETERS' 
    Map = []
    row = []
    for c in vision_string:
        if c == '0':
            row.append(False)
            pass
        else:
            row.append(True)
            pass
        if len(row) == x:
            Map.append([t for t in row])
            row.clear()
            pass
        pass
    
    return Map

def ParsePosition(x,y):
    return int(x),int(y)

def ParseRotation(x):
    return float(x)