extends Node2D

var commander
var enemy_soldier 
var player_soldier
var wall
var project_path = ProjectSettings.globalize_path("res://") + "server/main.py"
var server_global_location = project_path
onready var bullet_contact = $bullet_contact
onready var ship_explotion = $ship_explotion
onready var commander_dead = $commander_dead
onready var chip_explotion = $chip_explotion
onready var player_dead = $player_dead
onready var impact = $impact
# ------server---------
var host = '127.0.0.1'
var port = 8000
var client = StreamPeerTCP.new()
var SimulationReady = false
var serverUp = false
var connector = ServerConnector.new()
#---------------------
var screen_size = Vector2()
var playlist = [
	
	preload("res://resource/Sounds/clockwork-chaos-dark-trailer-intro-202223.mp3"),
	preload("res://resource/Sounds/defining-moments-202410.mp3"),
	preload("res://resource/Sounds/dramatic-reveal-21469.mp3"),
	preload("res://resource/Sounds/fight-142564.mp3"),
	preload("res://resource/Sounds/the-epic-trailer-12955.mp3"),
	preload("res://resource/Sounds/the-shield-111353.mp3"),
	preload("res://resource/Sounds/warrior_medium-192841.mp3"),
	preload("res://resource/Sounds/GameSounds/suspense-intro-21472.mp3"),
	preload("res://resource/Sounds/GameSounds/soundtracksong-66467.mp3"),
	preload("res://resource/Sounds/GameSounds/epic-powerful-logo-196229.mp3"),
	preload("res://resource/Sounds/GameSounds/epic-ident-heroic-powerful-intro-logo-196233.mp3"),
	preload("res://resource/Sounds/GameSounds/epic-hybrid-logo-196235.mp3"),
	preload("res://resource/Sounds/GameSounds/epic-dramatic-inspirational-logo-196234.mp3"),
]
var world_map = map.new()
var my_map
var player_state = true
var length_x
var length_y
var time = 100
var list_of_instance_of_enemy_soldiers = []
var list_of_instance_of_player_soldiers = []
var commander_list = []
var left_flag
var right_flag

# Called when the node enters the scene tree for the first time.
func _ready():
	
	screen_size = get_viewport_rect().size
	
	OS.execute('py',[server_global_location,host,port],false,[])
	
	my_map = world_map.get_map_formatted(5,5,20)
	 
	client.connect_to_host(host,port)
	
	quite_map()  
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	rng = rng.randi_range(0, playlist.size() -1 )
	$background_sound.stream = playlist[rng]
	$background_sound.play()
	
	wall = preload("res://wall_area.tscn")
	commander = preload("res://command.tscn")
	enemy_soldier = preload("res://soldier_command.tscn")
	player_soldier = preload("res://soldier_user.tscn")
	
	instance_ship(Vector2(200,200),commander)
	init(  1  , 5 , 5 , Vector2(0,0))
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	pass

func _process(delta): 
	
	var status = client.get_status()
	if status == StreamPeerTCP.STATUS_CONNECTED:
		serverUp = true
		if serverUp and not SimulationReady:
			connector.SendBuildGraphRequest( my_map , client)
			SimulationReady = true
			pass
		pass
	else:
		serverUp = false
		pass

	# follow player
	if $player:
		$TextureRect.set_global_position($player.global_position - (screen_size/2))
		$background_sound.global_position = $player.global_position - (screen_size/2)
	
	pass

func quite_map():
	
	var map_size = my_map[0].size()* 30
	
	$left_frontier.set_( Vector2(0,map_size /2) , map_size , 20)
	
	$right_frontier.set_(Vector2( map_size , map_size/2 ) , map_size , 20)
	
	$top_frontier.set_(Vector2( map_size/2 , 0 ) , map_size , 20)
	
	$bottom_frontier.set_( Vector2( map_size /2  , map_size ) , map_size , 20 )
	
	length_x = map_size + 100
	length_y = map_size
	
	pass

func instance_ship(pos, intance_ship_type):
	
	var ship = intance_ship_type.instance()
	add_child(ship)
	ship.start_position( pos , length_x ,length_y )
	
	return ship

func init(commander_number , enemy_soldier_number , player_soldiers_number , player_position ):

	$player.start_position(player_position , length_x , length_y )
	
	draw_map(my_map)
	
	var flags = draw_flags()
	var blue = flags["blue"]
	var red = flags["red"]
	
	pass

func draw_map(Map):
	
	var x_size = Map[0].size()
	var y_size = Map.size()
	for i in range(x_size):
		for j in range(y_size):
			if not Map[j][i]:
				var wall_block = wall.instance()
				wall_block.set_position(Vector2(i*30 + 15,j*30 + 15))
				add_child(wall_block)
				pass
			pass
		pass
	
	pass

func _on_background_sound_finished():
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	rng = rng.randi_range(0, playlist.size() -1 )
	$background_sound.stream = playlist[rng]
	$background_sound.play()
	
	pass # Replace with function body.

func _on_world_tree_exited():
	connector.killServer(client)
	pass # Replace with function body.

func count_blocks(matrix):
	
	var count = 0
	for item in matrix:
		if item:
			count += 1	
	
	return count

func best_hole( start ):
	
	var best
	var best_matrix
	
	var top_matrix = []
	var center_matrix = []
	var bottom_matrix = []
	
	for i in range( 0, int(my_map.size()/3) ): # row
		var row = []
		for j in range( start , start + int(my_map.size()/3) ):# column
			row.append( my_map[i][j] )
		
		top_matrix.append(row)
	
	for i in range( int(my_map.size()/3) , int(my_map.size()/3) * 2 ): # row
		var row = []
		for j in range( start , start + int(my_map.size()/3) ): #column
			row.append( my_map[i][j] )
		
		center_matrix.append(row)
	
	for i in range( int(my_map.size()/3) * 2, my_map.size() ): # row
		var row = []
		for j in range( start ,  start + int(my_map.size()/3) ): # column
			row.append( my_map[i][j] )
		
		bottom_matrix.append(row)
	
	# select walless matrix in the range
	best = count_blocks(top_matrix)
	best_matrix = { "matrix": top_matrix , "row_offset": 0}
	
	var count2 = count_blocks(center_matrix)
	
	if best < count2:
		best_matrix = { "matrix": center_matrix , "row_offset": int(my_map.size()/3) }
		
	var count3 = count_blocks(bottom_matrix)
	if best< count3:
		best_matrix = { "matrix": bottom_matrix , "row_offset": int(my_map.size()/3)*2 }
	
	return best_matrix

func generate_left_flag(left):
	
	var left_matrix = left["matrix"]
	var left_row_offset = left["row_offset"]
	var posible_positions = []
	
	var current_time_msec = OS.get_ticks_msec()
	
	for i in range( 0 , left_matrix.size() ) :
		for j in range( 0 , left_matrix[0].size() ) :
			
			if is_valid_position(left_matrix,i,j):
				
				if left_matrix[i][j] and left_matrix[ i+ 1 ][j] and left_matrix[i][j + 1] and left_matrix[i + 1][j + 1]:
					var left_flag = { "row":i + left_row_offset , "column": j }
					posible_positions.append(left_flag)
	
	return posible_positions[ current_time_msec % posible_positions.size() ]

func generate_right_flag( right ):
	
	var right_matrix = right["matrix"]
	var right_row_offset = right["row_offset"]
	var posible_positions = []
	
	var current_time_msec = OS.get_ticks_msec()
	for i in range( 0 , right_matrix.size() ) :
		for j in range( 0 , right_matrix[0].size() ) :
			
			if is_valid_position(right_matrix,i,j):
				
				if right_matrix[i][j] and right_matrix[ i+ 1 ][j] and right_matrix[i][j + 1] and right_matrix[i + 1][j + 1]:
					var right_flag = { "row":i + right_row_offset , "column": j +  2 * int(my_map.size()/3)  }
					posible_positions.append(right_flag)
					
	return posible_positions[ current_time_msec % posible_positions.size() ]

func locate_flags():
	
	var left = best_hole(0)
	var left_flag = generate_left_flag(left)
	
	var right = best_hole( int(my_map.size()* 2 / 3) )
	var right_flag = generate_right_flag(right)
	
	print( "left:", left_flag )
	print( "right:" ,right_flag )

	return { "left": left_flag, "right": right_flag }

func is_valid_position(matrix , row,column):
	
	return row + 1 < matrix.size() and column + 1 < matrix[0].size()

func draw_flags():
	
	var flags = locate_flags()
	var left_flag = flags["left"]
	var right_flag = flags["right"]
	
	var current_time_msec = OS.get_ticks_msec()
	
	if current_time_msec % 2:
		$red_flag.set_position(Vector2( (left_flag["column"] + 1) * 30, (left_flag["row"] + 1) * 30 ) )
		$blue_flag.set_position(Vector2( (right_flag["column"] + 1) * 30, (right_flag["row"] + 1) * 30 ) )
		
		return {"red":left_flag , "blue": right_flag }
	else:
		$blue_flag.set_position(Vector2( (left_flag["column"]+ 1) * 30, (left_flag["row"] + 1) * 30 ) )
		$red_flag.set_position(Vector2( (right_flag["column"]+ 1 ) * 30, (right_flag["row"] + 1) * 30  ) )
		
		return {"red":right_flag , "blue": left_flag }
	pass

func is_bussy(bussy_cell_list,row,column):
	
	for cell in bussy_cell_list:
		
		if cell["row"] == row and cell["column"]: return true
		
	return false

# csp restrictions
func is_valid_ship_position( row,column,matrix , bussy_cell_list ): 
	
	if row - 2 < matrix.size() or row + 2 > matrix.size()  :
		return false
	
	if column - 2 < matrix[0].size() or column + 2 > matrix[0].size()  :
		return false
	
	if (left_flag["row"] == row and left_flag["column"] == column ) or \
	   (right_flag["row"] == row and right_flag["column"] == column): return false
		
	for i in range(-1,1):
		for j in range(-1,1):
			
			if  not matrix[ row + i][ column + j] and not is_bussy( bussy_cell_list , row , column ):
				return false
			
	return true

func locate_ships( number_ally , number_enemy , blue ,red ):
	
	var ally_list = csp( blue,number_ally , [] )
	var enemy_list = csp( red,number_enemy , ally_list )
	
	list_of_instance_of_player_soldiers = draw_ships(ally_list)
	list_of_instance_of_enemy_soldiers = draw_ships(enemy_list)
	pass

func draw_ships( list_of_ships ):
	
	var list_instance = []
	for ship in list_of_ships:
		
		var pos = Vector2( (ship["column"] + 1) * 30 + 15 , (ship["row"] + 1) * 30 + 15  )
		ship = instance_ship( pos, ship["ship"] )
		list_instance.append(ship)
		
	return list_instance

func csp( flag_position , number_ship , bussy_cell ):
	
	
	
	return bussy_cell
