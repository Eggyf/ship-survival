from datetime import datetime

def Log(data):
    date = datetime.now()
    
    with open('Log.txt','a') as f:
        f.write(f'{date} : {data}\n')
        pass
    pass