extends Area2D

var motion = Vector2()
var rotation_head = 0
var limit
var thread =  Thread.new()
var life = 500
var Bullet = preload("res://bullet.tscn")       
var id = "commander"
var dimention_x
var dimention_y
var time = 0
var enemy_detected = false
var shot_avaliable = false
var ship_name
var my_soldiers = []
signal killed
var ally = []
var enemy_list = []
var targets = ["friend", "player" ,"my_commander"]
var ally_detection = ["commander","enemy"]
onready var client = get_tree().current_scene.client

var StateCloser = false
var StateEvadeStarted = false
var StateEvading = false
var StateFar = true
var StateDefensive = false
var InstructionsStack = []
var targetObject
var targetPosition: Vector2
var HasTarget = false
var HasInstruction = false
var brain = Brain.new()
var server_connector = ServerConnector.new()
onready var Map = get_tree().current_scene.my_map
onready var my_flag_position = get_tree().current_scene.GetRedFlagPosition()
var flag_found = false
var flag_position = Vector2()
var sectors = []
var sectors_seen = []
var sectors_created = false
var selected_sector = Vector2()
var seen = true

func SearchFlag(pos: Vector2=global_position):
	server_connector.SendFriendsPositions(my_soldiers,client)
	server_connector.SendEnemysPositions(enemy_list,client)
	var my_position = pos
	while int(my_position.x / 30) >= 100:
		my_position -= Vector2(1,0)
		pass
	while int(my_position.y / 30) >= 100:
		my_position -= Vector2(0,1)
		pass
	var coords = Vector2(int(my_position.x / 30), int(my_position.y / 30))
	if not sectors_created:
		sectors_created = true
		var x_start = 0
		var x_end = 0
		if my_flag_position.x < Map[0].size() * 15:
			x_start = int(Map[0].size() / 2)
			x_end = Map[0].size()
		else:
			x_start = 0
			x_end = int(Map[0].size() / 2)
			pass

		for i in range(x_start,x_end,25):
			for j in range(0,Map.size(),25):
				var sector_center = Vector2(i,j)
				sectors.append(sector_center)
				pass
			pass
		pass
	
	var distance = abs(coords.x - flag_position.x) + abs(coords.y - flag_position.y)
	
	if flag_found and distance < 10:
		return []

	if distance < 50:
		seen = true
		for i in range(sectors.size()):
			if sectors[i] == selected_sector:
				sectors.pop_at(i)
				break
			pass
		pass
		
	if sectors.size() == 0 and not flag_found:
		while sectors_seen.size() > 0:
			sectors.append(sectors_seen.pop_at(0))
			pass
		pass
	
	if not flag_found and sectors.size() > 0 and seen:
		var sector = int(rand_range(0,sectors.size()))
		var x = int(rand_range(selected_sector.x,selected_sector.x + 25))
		var y = int(rand_range(selected_sector.y,selected_sector.y + 25))
		selected_sector = sectors.pop_at(sector)
		sectors_seen.append(selected_sector)
		flag_position = Vector2(x,y)
		pass
	
	var MinPath = server_connector.GetPathTo(Map,coords,flag_position,[],client)
	var instructions = brain.TranslatePathToInstrucions(MinPath)
	return instructions

func SetTargetPosition(position: Vector2):
	
	targetPosition = position * 30
	StateDefensive = true
	HasTarget = false
	pass

func SetTargetObject(object):
	
	targetObject = object
	StateDefensive = false
	HasTarget = true
	pass

func GetVectorToTargetObject():
	return targetObject.global_position - global_position
	
func GetVectorToTargetPosition():
	return targetPosition - global_position
	
func GetAction(vector: Vector2):
	
	var degree = rad2deg(vector.angle())
	if degree < 45 or degree >= 315:
		return 'right'
	if degree < 135 and degree >= 45:
		return 'down'
	if degree < 0:
		return 'left'
	return 'up'

func FollowInstructions():
	var instruction = InstructionsStack[0]
	if not HasInstruction:
		if instruction == 'right':
			targetPosition = global_position + Vector2(30,0)
			pass
		elif instruction == 'up':
			targetPosition = global_position + Vector2(0,-30)
			pass
		elif instruction == 'down':
			targetPosition = global_position + Vector2(0,30)
			pass
		else:
			targetPosition = global_position + Vector2(-30,0)
			pass
		pass
	
	var direction = GetVectorToTargetPosition().normalized()
		
	if direction.x == 0 and direction.y == 0:
		$AnimatedSprite.animation = "speed1"
		InstructionsStack.pop_at(0)
		HasInstruction = false
		pass
	else:
		HasInstruction = true
		pass
	change_direction(instruction,1,1)
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	
	hide()
	$life_tag.set_life(life)
	ship_name = id.hash()
	
	pass

func change_time():
	
	if time == 0 : 
		pass
	else: 
		time -= 1

	pass

func change_direction( action, x=30 , y=30 ):
	
	if action == 'left' and $direction_collision.left_is_colliding():
		InstructionsStack.pop_at(0)
		HasInstruction = false
		pass
	
	if action == 'up' and $direction_collision.up_is_colliding():
		HasInstruction = false
		InstructionsStack.pop_at(0)
		pass
		
	if action == 'right' and $direction_collision.right_is_colliding():
		HasInstruction = false
		InstructionsStack.pop_at(0)
		pass
		
	if action == 'down' and $direction_collision.down_is_colliding():
		HasInstruction = false
		InstructionsStack.pop_at(0)
		pass
		
	if action == "down" and time == 0  and not $direction_collision.down_is_colliding() :
		motion.y += y
		pass
	if action == "up" and time == 0 and not $direction_collision.up_is_colliding():
		motion.y += - y
		pass
	if action == "left" and time == 0 and not $direction_collision.left_is_colliding():
		motion.x += - x
		pass
	if action == "right" and time == 0 and not $direction_collision.right_is_colliding():
		motion.x += x
		pass
	global_position += motion
	position += motion
	
	#position.x = clamp(position.x , 50 , dimention_x  )
	#position.y = clamp(position.y , 0 , dimention_y  ) 
	return position

func target_priority():
	
	var best = Vector2(500,500 )
	for item in enemy_list:
		
		var vector = item.global_position - global_position
		if best.length_squared() > vector.length_squared():
			best = vector
	
	return best

func Defense():
	
	if enemy_detected:
		var target = target_priority()
		defend_position( target )
	
	pass

func Attack():
	var direction: Vector2 = GetVectorToTargetObject()
	if direction.length_squared() < 150:
		StateCloser = true
		StateEvading = false
		StateEvadeStarted = false
		pass
	elif direction.length_squared() < 300:
		StateCloser = false
		StateFar = false
		if not StateEvadeStarted:
			StateEvadeStarted = true
			pass
		else:
			StateEvading = true
			pass
		pass
	elif direction.length_squared() > 450:
		StateEvadeStarted = false
		StateEvading = false
		StateFar = true
		pass
	
	if StateCloser:
		change_direction(GetAction(direction * -1),0,0)
		pass
	
	if StateFar:
		change_direction(GetAction(direction),0,0)
		pass
		
	pass

func MakeAction():
	if InstructionsStack.size() > 0:
		FollowInstructions()
		pass
	else:
		CommandSoldiers()
		InstructionsStack = SearchFlag()
		pass
	
	var my_position = global_position
	var coords = Vector2(int(my_position.x / 30), int(my_position.y / 30))
	
	var i = 0
	while i < sectors.size():
		if abs(coords.x - sectors[i].x) + abs(coords.y - sectors[i].y) < 50:
			sectors_seen.append(sectors.pop_at(i))
			continue
		i += 1
		pass
	
	pass

func CommandSoldiers():
	for soldier in my_soldiers:
		soldier.InstructionsStack = SearchFlag(soldier.global_position)
		print(soldier.global_position)
		pass
	pass

func face_to_enemy( vector: Vector2 ):
	
	var degree = vector.normalized().angle()
	
	var direction = $head.global_position - global_position
	
	self.rotation = degree
	rotation_head = degree 
	
	$direction_collision.rotation = -degree
	
	return direction
	
func defend_position( vector ):
	
	var direction = face_to_enemy(vector)
	if shot_avaliable and no_shot():
		shot( direction )
		shot_avaliable = false
	
	pass

func no_shot():
	if $shot_eye.is_colliding():
		var tar = $shot_eye.get_collider()
		if tar.id == "enemy" or tar.id == "commander" or tar.id == "wall":
			return false
	return true
	
func fill_life():
		
	if life < 500 and time == 0 :
		life += 0.5
	
	pass

func _physics_process(delta):
	
	motion = Vector2()
	
	$life_tag.set_life(life)
	
	fill_life()
	
	change_time()
	
	MakeAction()
	
	Defense()
	
	pass

func start_position( pos , dimention_x , dimention_y ):

	position = pos
	show()
	$explotion.hide()
	$CollisionShape2D.disabled = false
	$ship_collision.hide()
	self.dimention_x = dimention_x
	self.dimention_y = dimention_y
	
	pass

func shot( direction ):
		
	var my_shot = Bullet.instance()
	get_tree().current_scene.add_child(my_shot) # set the bullet as child of world
	
	my_shot.rotate(rotation) # give rotation bullet
	var shot_direction = direction # give direction to bullet
	my_shot.position = $head.global_position # give postion to bullet
	
	my_shot.set_direction(shot_direction) #shot
	
	pass

func ship_explotion():
	
	$ship_collision.global_position = position
	$ship_collision.show()
	$AnimatedSprite.hide()
	$ship_collision_animation.play("destruction")
	$CollisionShape2D.call_deferred("set", "disabled", true)
	emit_signal("killed")
	
	pass

func rocket_explotion():
	
	$explotion.global_position= position
	$explotion.show()
	$explotion_animation.play("explotion")	
	
	pass

func destroy_sound():
	
	var commander_dead = get_parent().commander_dead.instance()
	add_child(commander_dead) 
	commander_dead.play()
	pass

func _on_command_area_entered(area):
	
	if area.id == "enemy":
		ship_explotion()
		destroy_sound()
	elif area.id == "friend":
		ship_explotion()
		destroy_sound()
	elif area.id == "player":
		ship_explotion()
		destroy_sound()
	elif area.id == "my_commander":
		ship_explotion()
		destroy_sound()
	elif area.id == "bullet":
		life -= 20
		area.queue_free()
		rocket_explotion()
		var impact = get_parent().impact.instance()
		add_child(impact) 
		impact.play()
		
	if life <= 0 :
		ship_explotion()
		destroy_sound()

	pass

func _on_ship_collision_animation_animation_finished(anim_name):
	get_parent().call_deferred("remove_child",self)
	pass # Replace with function body.

func _on_explotion_animation_animation_finished(anim_name):
	$explotion.hide()
	pass # Replace with function body.

func _on_radar_enemy():

	enemy_detected = true

	enemy_list = $radar.enemy_list

	pass # Replace with function body.

func _on_radar_enemy_exited():
	
	enemy_list = $radar.enemy_list	
	if enemy_list.size() == 0:
		enemy_detected = false
		
	pass # Replace with function body.

func _on_attack_rate_timeout():
	
	shot_avaliable = true
	
	pass # Replace with function body.

func _on_radar_area_entered(area):
	
	for item in targets:
			
			if item == area.id:
				enemy_list.append( area )
				enemy_detected = true
	
	if area.id == "blue_flag":
		flag_found = true
		flag_position = area.coordenate
		SearchFlag()
		print('blue flag found')
			
	for item in ally_detection:
			
		if item == area.id:
			ally.append( area )		
	
	pass # Replace with function body.

func _on_radar_area_exited(area):
	
	var i =0
	while i < enemy_list.size():
		
		if area.id == enemy_list[i].id:
			enemy_list.remove(i)
			i -= 1
		i += 1
	
	i = 0
	while i < ally.size():
		
		if area.id == ally[i].id:
			ally.remove(i)
			i -= 1
		i += 1
	pass # Replace with function body.

func _on_direction_collision_restart_position():
	
	global_position = $direction_collision.last_avaliable_pos

	pass # Replace with function body.
