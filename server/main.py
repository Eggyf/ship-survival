from sys import argv
import socket as sk
from socket import socket
import networkx as nx
import json
from logger import Log
from algorithms import GetPathToPoint
import matplotlib.pyplot as plt

global Handlers
global Map
global SubGraph
global ShipState

Map = nx.DiGraph()

def BuildGraphHandler(edges):
    global Map
        
    Map.add_weighted_edges_from(edges)
    return 'BUILDED'

def BuildSubGraphHandler(edges):
    global SubGraph
    
    SubGraph = nx.DiGraph()
    SubGraph.add_weighted_edges_from(edges)
    return 'OK'

def GetPathToHandler(data):
    global SubGraph
    
    position = data[0]
    goal = data[1]
    
    path = GetPathToPoint(position,SubGraph,goal)
    return path

def ShowGraphHandler(data):
    global Map
    Log(list(Map.edges))
    nx.draw(Map,with_labels=True)
    plt.show()
    return 'OK'

Handlers = {
    'BUILD_GRAPH': BuildGraphHandler,
    'SHOW GRAPH' : ShowGraphHandler,
    'BUILD_SUBGRAPH' : BuildSubGraphHandler,
    'GET_PATH_TO' : GetPathToHandler
}

def MainHandler(request):
    global Handlers
    data = json.loads(request)
    try:
        order = data['ORDER']
        pass
    except Exception as ex:
        order = 'none'
        pass

    if list(Handlers.keys()).count(order) > 0:
        return json.dumps(Handlers[order](data['DATA']))

    return json.dumps(data)

HOST = argv[1]
PORT = int(argv[2])

server = socket(sk.AF_INET,sk.SOCK_STREAM)
server.bind((HOST,PORT))
server.listen(1)

while True:
    conn,addr = server.accept()

    while True:
        data = conn.recv(4096)
        if not data: break
        conn.send(bytes(MainHandler(data),'utf-8'))
        pass
    conn.close()
    pass