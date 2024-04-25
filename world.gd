extends Node2D

var commander
var enemy_soldier 
var player_soldier
var time = 100
var list_of_instance_of_enemy_soldiers = []
var list_of_instance_of_player_soldiers = []
var server_global_location = "E:\\COLLEGE\\Further-Programming\\goDot\\Ship_Survival\\server\\main.py"
var commander_list = []
var wall
var wall_list = []
onready var bullet_contact = $bullet_contact
onready var ship_explotion = $ship_explotion
var world_map = map.new()
var host = '127.0.0.1'
var port = 8000
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
var client = StreamPeerTCP.new()
var serverUp = false
var connector = ServerConnector.new()
var my_map
var SimulationReady = false
var player_state = true
var length_x
var length_y
onready var commander_dead = $commander_dead
onready var chip_explotion = $chip_explotion
onready var player_dead = $player_dead
onready var impact = $impact
var original_map

# Called when the node enters the scene tree for the first time.
func _ready():
	
	screen_size = get_viewport_rect().size
	
	OS.execute('py',[server_global_location,host,port],false,[])
	
	var result = world_map.get_map_formatted(10,10,10)
	my_map = result["formated"]
	original_map = result["original"]
	
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
	
	init(  [ {"commander" : Vector2(100,520)  ,  "enemy_soldier" : [ Vector2(800,200) ] } ],
			 { "player_soldier" : [ Vector2(500,300) ] } , Vector2(0,100) , 
			my_map)
	
	
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

func init(commander_enemy , player_soldiers , player_position , Map ):
	
	var instances_of_player_soldiers = player_soldiers["player_soldier"]
	
	$player.start_position(player_position , length_x , length_y )
	
	for group in commander_enemy:
		
		var commander_instance = self.commander.instance() # instance commander
		add_child(commander_instance)
		commander_instance.start_position( group["commander"] , length_x ,length_y )
		commander_list.append(commander_instance) # add commander to list of commanders
		
		for enemy_soldier in  group["enemy_soldier"]: # instance all enemies
		
			var enemy = self.enemy_soldier.instance()
			add_child(enemy)
			enemy.start_position(enemy_soldier , length_x , length_y)
			#enemy.SetTargetObject($player)
		
			list_of_instance_of_enemy_soldiers.append(enemy)
	
	for item in instances_of_player_soldiers: # instance all friends
		
		var friends = self.player_soldier.instance()
		add_child(friends)
		friends.start_position( item , length_x ,length_y )
		
		list_of_instance_of_player_soldiers.append(friends)
	
	draw_map(Map)
	
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
	var center_matrix
	var bottom_matrix
	
	for i in range( 0, int(my_map.size()/3) ): # row
		var row = []
		for j in range( 0 , start + int(my_map.size()/3) ):# column
			row.append( my_map[i][j] )			
		
		top_matrix.append(row)
	
	for i in range( int(my_map.size()/3) , int(my_map.size()/3) * 2 ): # row
		var row = []
		for j in range( 0 , start + int(my_map.size()/3) ): #column
			row.append( my_map[i][j] )
		
		center_matrix.append(row)
	
	for i in range( int(my_map.size()/3) * 2, my_map.size() ): # row
		var row = []
		for j in range( 0 ,  start + int(my_map.size()/3) ): # column
			row.append( my_map[i][j] )
		
		bottom_matrix.append(row)
	
	# select walless matrix in the range
	best = count_blocks(top_matrix)
	best_matrix = top_matrix
	
	var count2 = count_blocks(center_matrix)
	
	if best < count2:
		best_matrix = center_matrix
		
	var count3 = count_blocks(bottom_matrix)
	if best< count3:
		best_matrix = bottom_matrix
	
	return best_matrix

func locate_flags():
	
	var left_matrix = best_hole(0)
	var right_matrix = best_hole( int(my_map.size()* 2 / 3) )
	
	var left_flag
	for i in range( 0 , left_matrix.size() ) :
		for j in range( 0 , left_matrix.size() ) :
			if left_matrix[i][j]:
				left_flag = { "row":i , "column": j }
	
	var right_flag
	for i in range( 0 , right_matrix.size() ) :
		for j in range( 0 , right_matrix.size() ) :
			if right_matrix[i][j]:
				right_flag = { "row":i , "column": j }
				
	
	print( left_flag )
	
	return [ left_flag, right_flag ]

func locate_ships( number_ally , number_enemy ):
	
	
	

	pass
