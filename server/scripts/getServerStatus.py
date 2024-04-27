from sys import argv
from sender import sendRequest


response = sendRequest('OK',*argv)
print(response)