import socket as skt
from socket import socket
import json
import networkx as nx
from multiprocessing import Process
from sys import argv
from algorithms import GetPathToPoint
import matplotlib.pyplot as plt


global Handlers
global Map
global SubGraph
global EnemyPositions
global FriendsPositions

FriendsPositions = []
Map = nx.DiGraph()
EnemyPositions = []

process_childs = []


def BuildGraphHandler(edges):
    global Map

    Map.add_weighted_edges_from(edges)
    return "BUILDED"


def BuildSubGraphHandler(edges):
    global SubGraph

    SubGraph = nx.DiGraph()
    SubGraph.add_weighted_edges_from(edges)
    return "BUILDED"


def GetPathToHandler(data):
    global Map
    global EnemyPositions
    global FriendsPositions

    position = data[0]
    goal = data[1]

    path = GetPathToPoint(Map, position, goal, EnemyPositions, FriendsPositions)

    return path


def SetEnemyPositionsHandler(data):
    global EnemyPositions

    positions = []
    for position in data:
        data_to_parse = position[1 : len(position) - 1]
        left, right = int(data_to_parse.split(",")[0]), int(data_to_parse.split(",")[1])
        positions.append((left, right))
        pass

    EnemyPositions = positions
    return "ADDED"


def ShowGraphHandler(data):
    global Map

    nx.draw(SubGraph, with_labels=True)
    plt.show()
    return "OK"


def SetFriendsPositionsHandler(data):
    global FriendsPositions

    positions = []
    for position in data:
        data_to_parse = position[1 : len(position) - 1]
        left, right = int(data_to_parse.split(",")[0]), int(data_to_parse.split(",")[1])
        positions.append((left, right))
        pass

    FriendsPositions = positions
    return "OK"


Handlers = {
    "BUILD_GRAPH": BuildGraphHandler,
    "BUILD_SUBGRAPH": BuildSubGraphHandler,
    "GET_PATH_TO": GetPathToHandler,
    "SET_ENEMY_POSITIONS": SetEnemyPositionsHandler,
    "SHOW_GRAPH": ShowGraphHandler,
    "UPDATE_FRIENDS_POSITIONS": SetFriendsPositionsHandler,
}


def MainHandler(request):
    global Handlers

    data = json.loads(request)
    try:
        order = data["ORDER"]
        pass
    except Exception as ex:
        order = "none"
        pass

    if order == "CLOSE":
        return "CLOSED"
    if list(Handlers.keys()).count(order) > 0:
        return json.dumps(Handlers[order](data["DATA"]))

    return json.dumps(data)


HOST = argv[1]
PORT = int(argv[2])

server = socket(skt.AF_INET, skt.SOCK_STREAM)
server.bind((HOST, PORT))
server.listen(1)
Alive = True

print("listening on port 8000")
while True:
    conn, addr = server.accept()

    while True:
        data = conn.recv(524288)
        if not data:
            break
        response = MainHandler(data)
        conn.send(bytes(response, "utf-8"))
        if response == "CLOSED":
            Alive = False
            break
        pass
    conn.close()
    if not Alive:
        break
    pass
