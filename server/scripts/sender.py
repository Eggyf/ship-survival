import socket as sk
from socket import socket
import json

def getServerAddr(argv):
    return argv[1],int(argv[2])

def sendData(host,port,data):
    client = socket(sk.AF_INET,sk.SOCK_STREAM)
    client.connect((host,port))

    json_data = json.dumps(data)
    client.send(bytes(json_data,'utf-8'))

    response = client.recv(1024)
    return response

def sendRequest(data,*argv):
    host,port = getServerAddr(argv)
    return json.loads(sendData(host,port,data))