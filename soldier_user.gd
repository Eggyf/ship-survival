extends Area2D

var motion = Vector2()
var rotation_head = 0
var limit
var thread =  Thread.new()
var life = 100
var Bullet = preload("res://bullet.tscn")
var id = "friend"
var dimention_x
var dimention_y 
var enemy_detected = false
var shot_avaliable = false
var ship_name
var time = 0 # time between every key press of the type ( up, down , left , right )
signal killed
var enemy_list = []
var ally = []
var targets = ["enemy","commander"]
var ally_detection = ["friend","my_commander","player"]

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

func change_direction(action,x=30,y=30):
	
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
	elif StateDefensive:
		var direction = GetVectorToTargetPosition().normalized()
		if direction.x == 0 and direction.y == 0:
			$AnimatedSprite.animation = "speed1"
			pass
		change_direction(GetAction(direction),1,1)
		Defense()
		pass
	elif HasTarget:
		Attack()
		pass
	else:
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
	if shot_avaliable and no_shot() :
		shot( direction )
		shot_avaliable = false
		
	pass		

func no_shot():
	if $shot_eye.is_colliding():
		var tar = $shot_eye.get_collider()
		print(tar)
		if  tar.id == "player" or tar.id == "friend" or tar.id == "my_commander" or tar.id == "wall":
			return false
	return true

func fill_life():
		
	if life < 100 and time == 0:
		life += 0.1
	
	pass

func _physics_process(delta):
	
	motion = Vector2()
	
	$life_tag.set_life(life)
	
	fill_life()
	
	change_time()
	
	MakeAction()
	
	Defense()
	
	pass

func start_position(pos , dimention_x , dimention_y ):
	
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
	
	var ship_explotion = get_parent().ship_explotion.instance()
	add_child(ship_explotion) 
	ship_explotion.play()
	pass

func _on_soldier_user_area_entered(area):
	
	if area.id == "enemy":
		ship_explotion()
		destroy_sound()
	elif area.id == "commander":
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
		rocket_explotion()
		area.queue_free()
		var impact = get_parent().impact.instance()
		add_child(impact) 
		impact.play()
		
	if life <= 0 :
		ship_explotion()
		destroy_sound()
	
	pass # Replace with function body.

func _on_ship_collision_animation_animation_finished(anim_name):
	get_parent().call_deferred("remove_child",self)
	pass # Replace with function body.

func _on_explotion_animation_animation_finished(anim_name):
	$explotion.hide()
	pass # Replace with function body.

func _on_attack_rate_timeout():
	shot_avaliable = true
	pass # Replace with function body.

func _on_radar_area_entered(area):
	
	for item in targets:
		
		if item == area.id:
			enemy_list.append( area )
			enemy_detected = true
			
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
