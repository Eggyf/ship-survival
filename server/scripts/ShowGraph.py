from sys import argv
from sender import sendRequest

order = 'SHOW GRAPH'
data = {
    'ORDER' : order,
    'DATA' : ''
}

response = sendRequest(data,*argv)
print(response)