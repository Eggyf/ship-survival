from sys import argv
from sender import sendRequest

def IsInRange(x_size,y_size,pos_x,pos_y):
    if pos_x < 0 or pos_y < 0:
        return False
    if pos_x > x_size:
        return False
    if pos_y > y_size:
        return False 
    return True

def getEdges(Map):
    """
    build the edges of the graph given the boolean map
    """
    edges = []
    
    x_size = len(Map[0]) - 1
    y_size = len(Map) - 1
    
    for i in range(x_size + 1):
        for j in range(y_size + 1):
            if Map[i][j]:
                
                node0 = f'{i},{j}'
                
                if IsInRange(x_size,y_size,i + 1,j) and Map[i + 1][j]:
                    node1 = f'{i + 1},{j}'
                    edge0 = node0,node1,1
                    if edges.count(edge0) == 0:
                        edges.append(edge0)
                        pass
                    edge1 = node1,node0,1
                    if edges.count(edge1) == 0:
                        edges.append(edge1)
                        pass
                    pass
                
                if IsInRange(x_size,y_size,i,j + 1) and Map[i][j + 1]:
                    node1 = f'{i},{j + 1}'
                    edge0 = node0,node1,1
                    if edges.count(edge0) == 0:
                        edges.append(edge0)
                        pass
                    edge1 = node1,node0,1
                    if edges.count(edge1) == 0:
                        edges.append(edge1)
                        pass
                    pass
                
                if IsInRange(x_size,y_size,i - 1,j) and Map[i - 1][j]:
                    node1 = f'{i - 1},{j}'
                    edge0 = node0,node1,1
                    if edges.count(edge0) == 0:
                        edges.append(edge0)
                        pass
                    edge1 = node1,node0,1
                    if edges.count(edge1) == 0:
                        edges.append(edge1)
                        pass
                    pass
                
                if IsInRange(x_size,y_size,i,j - 1) and Map[i][j - 1]:
                    node1 = f'{i},{j - 1}'
                    edge0 = node0,node1,1
                    if edges.count(edge0) == 0:
                        edges.append(edge0)
                        pass
                    edge1 = node1,node0,1
                    if edges.count(edge1) == 0:
                        edges.append(edge1)
                        pass
                    pass
                
                pass
            pass
        pass
    
    return edges

Map = [
    [True,True,True,True,False],
    [True,False,True,True,True],
    [True,False,False,False,True],
    [True,True,True,False,True],
    [True,True,True,True,True]
]

edges = getEdges(Map)
error = False
ed = []
while len(edges) > 0:
    ed.append(edges.pop())
    if len(ed) == 20 or len(edges) == 0:
        
        order = 'BUILD_GRAPH'
        data = {
            'ORDER' : order,
            'DATA' : ed
        }
        
        response = sendRequest(data,*argv)
        if not response == 'BUILDED':
            error = True
            break
        ed.clear()
        pass
        
    pass

if error:
    print('Error')
    pass
else:
    print('BUILDED')
    pass