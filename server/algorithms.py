import networkx as nx
from networkx.algorithms.shortest_paths.astar import astar_path, astar_path_length
from math import log2


def GetPathToPoint(graph, position, goal, enemys, friends):
    """
    return the better path to the goal
    """

    def ManhatanDistance(from_pos, to_pos):
        x0, y0 = from_pos
        x1, y1 = to_pos

        return abs(x1 - x0) + abs(y1 - y0)

    def Heuristic(node0, node1):
        coords0 = node0.split(",")
        coords1 = node1.split(",")

        coords0 = int(coords0[0]), int(coords0[1])
        coords1 = int(coords1[0]), int(coords1[1])

        max_manhatan_distance = 0
        for friend in friends:
            if ManhatanDistance(coords1, friend) > max_manhatan_distance:
                max_manhatan_distance = ManhatanDistance(coords1, friend)
                pass
            pass

        if len(enemys) == 0:
            return ManhatanDistance(coords0, coords1) + max_manhatan_distance

        min_enemy_distance = ManhatanDistance(coords1, enemys[0])
        for enemy in enemys:
            distance = ManhatanDistance(coords1, enemy)
            if distance < min_enemy_distance:
                min_enemy_distance = distance
                pass
            pass

        return (
            ManhatanDistance(coords0, coords1)
            + 64 / log2(min_enemy_distance + 2)
            + max_manhatan_distance
        )

    new_goal = None
    if not goal in graph.nodes:

        new_goal = list(graph.nodes)[0]
        distance = Heuristic(new_goal, goal)
        for node in graph.nodes:
            if node == position:
                continue
            d = Heuristic(node, goal)
            if d < distance:
                distance = d
                new_goal = node
                pass
            pass
        pass

    if not new_goal == None:
        goal = new_goal
        pass

    return list(astar_path(graph, position, goal, heuristic=Heuristic))
