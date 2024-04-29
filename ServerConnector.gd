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
			var result = PoolByteArray(client.get_data(d)[1]).get_string_from_utf8()
			var a = parse_json(result)
			return a
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
		'ORDER' : 'SHOW_GRAPH',
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
				
				if edges.size() > 50:
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

func IsValidPosition(pos: Vector2, Map: Array,ships_positions: Array):
	for i in range(-2,3):
		for j in range(-2,3):
			if IsInRange(Map[0].size() - 1,Map.size() - 1,pos.x + j,pos.y + i) and Vector2(pos.x + j,pos.y + i) in ships_positions:
				return false
			pass
		pass
	return true

func BFS_WITH_DEPTH(Map:Array,position:Vector2,depth:int,ships_psitions: Array):
	var queue = [[position,0]]
	var visited = []
	var x_direction = [0,1,0,-1]
	var y_direction = [-1,0,1,0]
	var edges = []
	while queue.size() > 0 and queue[0][1] < depth:
		var cell = queue.pop_at(0)
		var node0 = str(cell[0].x) + ',' + str(cell[0].y)
		for i in range(x_direction.size()):
			var x = cell[0].x + x_direction[i]
			var y = cell[0].y + y_direction[i]
			
			if IsInRange(Map[0].size() - 1,Map.size() - 1,x,y) and Map[y][x] and not Vector2(x,y) in visited:
				if IsValidPosition(Vector2(x,y),Map,ships_psitions):
					var node1 = str(x) + ',' + str(y)
					var edge0 = [node0,node1,1]
					edges.append(edge0)
					if not [Vector2(x,y),cell[1] + 1] in queue:
						queue.append([Vector2(x,y),cell[1] + 1])
						pass
					pass
				pass
			pass
		visited.append(cell[0])
		pass
	return edges

func SendSubGraph(Map:Array,position:Vector2,depth:int,ships_positions: Array,client: StreamPeerTCP):
	var edges = BFS_WITH_DEPTH(Map,position,depth,ships_positions)
	var data = {
		'ORDER' : 'BUILD_SUBGRAPH',
		'DATA' : edges
	}
	SendData(data,client)
	GetData(client)
	pass

func GetPathTo(Map: Array,from: Vector2,to: Vector2,ships_positions: Array,client: StreamPeerTCP):
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

func SendFriendsPositions(friends: Array,client: StreamPeerTCP):
	
	var pos = []
	for soldier in friends:
		pos.append(Vector2(int(soldier.global_position.x / 30),int(soldier.global_position.y / 30)))
		pass
	var data = {
		'ORDER' : 'UPDATE_FRIENDS_POSITIONS',
		'DATA' : pos
	}
	SendData(data,client)
	var result = GetData(client)
	pass

func SendEnemysPositions(enemys: Array,client: StreamPeerTCP):
	var pos = []
	for enemy in enemys:
		pos.append(Vector2(int(enemy.global_position.x / 30),int(enemy.global_position.y / 30)))
		pass
	var data = {
		'ORDER' : 'SET_ENEMY_POSITIONS',
		'DATA' : pos
	}
	SendData(data,client)
	var result = GetData(client)
	print(result)
	pass
