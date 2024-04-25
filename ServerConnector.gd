extends Node2D

class_name ServerConnector

func SendData(data,client: StreamPeerTCP):
	var data_to_send = JSON.print(data)
	client.put_data(data_to_send.to_utf8())
	return true

func GetData(client: StreamPeerTCP):
	while true:
		var d = client.get_available_bytes()
		if d > 0:
			return PoolByteArray(client.get_data(d)[1]).get_string_from_utf8()
		pass
	pass

func killServer(client: StreamPeerTCP):
	
	var data = {
		'ORDER' : 'CLOSE',
		'DATA' : ''
	}
	SendData(data,client)
	pass

func ShowGraph(client: StreamPeerTCP):
	
	var data = {
		'ORDER' : 'SHOW GRAPH',
		'DATA' : ''
	}
	SendData(data,client)
	GetData(client)
	pass

func IsInRange(x_size,y_size,pos_x,pos_y):
	if pos_x < 0 or pos_y < 0:
		return false
	if pos_x > x_size:
		return false
	if pos_y > y_size:
		return false 
	return true

func SendBuildGraphRequest(Map:Array,client:StreamPeerTCP):
	"""
	build the edges of the graph given the boolean map and send its to the server
	"""
	var edges = []
	
	var x_size = Map[0].size() - 1
	var y_size = Map.size() - 1
	
	for i in range(x_size + 1):
		for j in range(y_size + 1):
			if Map[j][i]:

				var node0 = str(i) + ',' + str(j)
				
				if IsInRange(x_size,y_size,i + 1,j) and Map[j][i + 1]:
					var node1 = str(i + 1) + ',' + str(j)
					var edge0 = [node0,node1,1]
					edges.append(edge0)
					pass
				
				if IsInRange(x_size,y_size,i,j + 1) and Map[j + 1][i]:
					var node1 = str(i) + ',' + str(j + 1)
					var edge0 = [node0,node1,1]
					edges.append(edge0)
					pass
				
				if IsInRange(x_size,y_size,i - 1,j) and Map[j][i - 1]:
					var node1 = str(i - 1) + ',' + str(j)
					var edge0 = [node0,node1,1]
					edges.append(edge0)
					pass
				
				if IsInRange(x_size,y_size,i,j - 1) and Map[j - 1][i]:
					var node1 = str(i) + ',' + str(j - 1)
					var edge0 = [node0,node1,1]
					edges.append(edge0)
					pass
				
				if edges.size() > 20:
					var data = {
						'ORDER' : 'BUILD_GRAPH',
						'DATA' : edges
					}
					SendData(data,client)
					GetData(client)
					edges.clear()
					pass
				
				pass
			pass
		pass
	
	if edges.size() > 0:
		var data = {
				'ORDER' : 'BUILD_GRAPH',
				'DATA' : edges
			}
		SendData(data,client)
		GetData(client)
		edges.clear()
		pass
	pass

func BFS_WITH_DEPTH(Map:Array,position:Vector2,depth:int):
	var queue = [[position,0]]
	var x_direction = [0,1,1,1,0,-1,-1,-1]
	var y_direction = [-1,-1,0,1,1,1,0,-1]
	var edges = []
	while queue[0][1] < depth:
		var cell = queue.pop_at(0)
		var node0 = str(cell[0].x) + ',' + str(cell[0].y)
		for i in range(x_direction.size()):
			var x = cell[0].x + x_direction[i]
			var y = cell[0].y + y_direction[i]
			
			if IsInRange(Map[0].size() - 1,Map.size() - 1,x,y) and Map[y][x]:
				var node1 = str(x) + ',' + str(y)
				var edge0 = [node0,node1,1]
				var edge1 = [node1,node0,1]
				edges.append(edge0)
				edges.append(edge1)
				queue.append([Vector2(x,y),cell[1] + 1])
				pass
			pass
		pass
	return edges

func SendSubGraph(Map:Array,position:Vector2,depth:int,client: StreamPeerTCP):
	var edges = BFS_WITH_DEPTH(Map,position,depth)
	var data = {
		'ORDER' : 'BUILD_SUBGRAPH',
		'DATA' : edges
	}
	SendData(data,client)
	GetData(client)
	pass

func GetPathTo(Map: Array,from: Vector2,to: Vector2,client: StreamPeerTCP):
	SendSubGraph(Map,from,2,client)
	var node_from = str(from.x) + ',' + str(from.y)
	var node_to = str(to.x) + ',' + str(to.y)
	var data = {
		'ORDER' : 'GET_PATH_TO',
		'DATA' : [node_from,node_to]
	}
	SendData(data,client)
	var result = GetData(client)
	return result

func SendShipState(enemys_positions: Array ,enemys_rotations: Array, client: StreamPeerTCP):
	var data = {
		'ORDER' : 'SET_STATE',
		'DATA' : {
			'EnemysPositions' : enemys_positions,
			'EnemysRotations' : enemys_rotations
		}
	}
	SendData(data,client)
	GetData(client)
	pass
