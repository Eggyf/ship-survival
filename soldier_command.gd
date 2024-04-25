extends Area2D

var motion = Vector2()
var rotation_head = 0
var life = 100
var Bullet = preload("res://bullet.tscn")
var id = "enemy"
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
var dimention_x
var dimention_y
var enemy_detected = false
var enemy_on_target = false
var time = 0 # time between every key press of the type ( up, down , left , right )
var enemy_list = []
var shot_avaliable = false
var delta
var ship_name

# Called when the node enters the scene tree for the first time.

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
	change_direction(instruction,0,0)
	pass

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
		change_direction(GetAction(direction),0,0)
		Defense()
		pass
	elif HasTarget:
		Attack()
		pass
	else:
		pass
	
	pass

func _ready():
	
	hide()
	$radar.targets = ["friend" , "player"]
	ship_name = id.hash()

	#InstructionsStack = ['right','right','right','right','right','right','right','right','right','right']
	StateDefensive = true
	#targetPosition = Vector2(1500,600)
	#for i in range(50):
	#	InstructionsStack.append('right')
	#	pass
	#for i in range(50):
	#	InstructionsStack.append('left')
	#	pass
	pass

func change_time():
	
	if time == 0 : 
		pass
	else: 
		time -= 1

	pass

func change_direction(action , x , y):
	
	$AnimatedSprite.animation = "speed1"
	
	if action == "down" and time == 0  and not $direction_collision.down_is_colliding() :
		if rotation_head == 90:
			$AnimatedSprite.animation = "step_back"
		elif rotation_head == 0 or rotation_head == 360:
			$AnimatedSprite.animation = "desplace_right"
		elif rotation_head == 180:
			$AnimatedSprite.animation = "desplace_left"
		else:
			$AnimatedSprite.animation = "speed3"
			
		motion.y += y
	
	if action == "up" and time == 0 and not $direction_collision.up_is_colliding():
		
		if rotation_head == 270:
			$AnimatedSprite.animation = "step_back"
		elif rotation_head == 0 or rotation_head == 360:
			$AnimatedSprite.animation = "desplace_left"
		elif rotation_head == 180:
			$AnimatedSprite.animation = "desplace_right"
		else:
			$AnimatedSprite.animation = "speed3"
		
		motion.y += - y
	
	if action == "left" and time == 0 and not $direction_collision.left_is_colliding():
		
		if rotation_head == 90:
			$AnimatedSprite.animation = "desplace_right"
		elif rotation_head == 270:
			$AnimatedSprite.animation = "desplace_left"
		elif rotation_head == 0 or rotation_head == 360 :
			$AnimatedSprite.animation = "step_back"
		else:
			$AnimatedSprite.animation = "speed3"
			
		motion.x += - x
	
	if action == "right" and time == 0 and not $direction_collision.right_is_colliding():
		
		if rotation_head == 90:
			$AnimatedSprite.animation = "desplace_left"
		elif rotation_head == 270:
			$AnimatedSprite.animation = "desplace_right"
		elif rotation_head == 180 :
			$AnimatedSprite.animation = "step_back"
		else:
			$AnimatedSprite.animation = "speed3"
			
		motion.x +=  x
	
	position += motion
	position.x = clamp(position.x , 50 , dimention_x  )  
	position.y = clamp(position.y , 0 , dimention_y  ) 
		
	return position 
		
func face_to_enemy( vector: Vector2 ):
	
	var degree = vector.normalized().angle()
	
	#var direction = $head.global_position - global_position
	
	self.rotation = degree
	rotation_head = degree 
	
	$direction_collision.rotation = -degree
	
	return vector
	
func defend_position( vector ):
	
	var direction = face_to_enemy(vector)
	if shot_avaliable:
		shot( direction )
		shot_avaliable = false
		
	pass

func fill_life():
	
	if life < 100 and time == 0:
		life += 0.1
	
	pass

func _physics_process(delta):
	
	self.delta = delta
	
	motion = Vector2()
	
	fill_life()
	
	change_time()
	
	MakeAction()
	
	Defense()
	
	pass

func start_position(pos , dimention_x , dimention_y):
	
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
	
	pass

func rocket_explotion():
	
	$explotion.global_position= position
	$explotion.show()
	$explotion_animation.play("explotion")	
	
	pass

func _on_enemy_soldier_area_entered(area):
	
	if area.id == "commander":
		ship_explotion()
		get_parent().ship_explotion.play()
	elif area.id == "friend":
		ship_explotion()
		get_parent().ship_explotion.play()
	elif area.id == "player":
		ship_explotion()
		get_parent().ship_explotion.play()
	elif area.id == "bullet":
		life -= 20
		rocket_explotion()
		area.queue_free()
		get_parent().impact.play()
	
	if life <= 0 :
		ship_explotion()
		get_parent().ship_explotion.play()
	
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

func _on_radar_enemy():
	
	enemy_detected = true

	enemy_list = $radar.enemy_list	

	pass # Replace with function body.

func _on_radar_enemy_exited():

	enemy_list = $radar.enemy_list	
	if enemy_list.size() == 0:
		enemy_detected = false
		
	pass # Replace with function body.
