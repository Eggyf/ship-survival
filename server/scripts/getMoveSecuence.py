from sys import argv
from SetupSimulation import getEdges
from sender import sendRequest
import networkx as nx

def BuildSubGraph(data):
    
    msg = {
        'ORDER' : 'BUILD_SUBGRAPH',
        'DATA' : getEdges(data)
    }
    
    response = sendRequest(msg,*argv)
    if response == 'OK':
        return True
    return False

if BuildSubGraph(argv[3]):
    pos = argv[4]
    goal = argv[5]
    data = {
        'ORDER' : 'GET_PATH_TO',
        'DATA' : (pos,goal)
    }
    response = sendRequest(data,*argv)
    print(response)
    pass
else:
    print('ERROR')