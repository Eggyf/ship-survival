import networkx as nx
from networkx.algorithms.traversal.breadth_first_search import bfs_successors
from networkx.algorithms.shortest_paths.astar import astar_path,astar_path_length

def GetSubGraphVision(position,graph,depth):
    """
    return all the neighbors of the given position in the graph in bfs given a 
    """
    return list(bfs_successors(graph,position,depth_limit=depth))

def GetPathToPoint(position,graph,goal):
    """
    return the better path to the goal
    """
    
    def ManhatanHeuristic(node0,node1):
        node0 = node0.split(',')
        x0 = int(node0[0])
        y0 = int(node0[1])
        
        node1 = node1.split(',')
        x1 = int(node1[0])
        y1 = int(node1[1])
        
        return abs(x1 - x0) + abs(y1 - y0)
    
    new_goal = None
    if not goal in graph.nodes:
        new_goal = list(graph.nodes)[0]
        distance = ManhatanHeuristic(new_goal,goal)
        for node in graph.nodes:
            d = ManhatanHeuristic(node,goal)
            if d < distance:
                distance = d
                new_goal = node
                pass
            pass
        pass
    
    if not new_goal == None:
        goal = new_goal
        pass
    
    return list(astar_path(graph,position,goal,heuristic=ManhatanHeuristic))