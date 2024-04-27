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
var enemy_list = []
var shot_avaliable = false
var ship_name
var my_soldiers = []
var ally = []
signal killed

# Called when the node enters the scene tree for the first time.
func _ready():
	
	hide()
	$life_tag.set_life(life)
	$radar.targets = ["friend" , "player" , "my_commander" ]
	ship_name = id.hash()
	
	pass

func change_time():
	
	if time == 0 : 
		pass
	else: 
		time -= 1

	pass

func change_direction( action, x=30 , y=30 ):
	
	$AnimatedSprite.animation = "speed1"
	
	if action == "down" and time == 0  and not $direction_collision.down_is_colliding() :
		if rotation_head == 90:
			$AnimatedSprite.animation = "step_back"
		elif rotation_head == 0 or rotation_head == 360:
			$AnimatedSprite.animation = "desplace_left"
		elif rotation_head == 180:
			$AnimatedSprite.animation = "desplace_right"
		else:
			$AnimatedSprite.animation = "speed3"
			
		motion.y += y
	
	if action == "up" and time == 0 and not $direction_collision.up_is_colliding():
		
		if rotation_head == 270:
			$AnimatedSprite.animation = "step_back"
		elif rotation_head == 0 or rotation_head == 360:
			$AnimatedSprite.animation = "desplace_right"
		elif rotation_head == 180:
			$AnimatedSprite.animation = "desplace_left"
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
	
func face_to_enemy( vector: Vector2 ):
	
	var degree = vector.normalized().angle()
	
	var direction = $head.global_position - global_position
	
	self.rotation = degree
	rotation_head = degree 
	
	$direction_collision.rotation = -degree
	
	return direction
	
func defend_position( vector ):
	
	var direction = face_to_enemy(vector)
	if shot_avaliable:
		shot( direction )
		shot_avaliable = false
		
	pass	
	
func fill_life():
		
	if life < 500 and time == 0 :
		life += 0.5
	
	pass

func _physics_process(delta):
	
	motion = Vector2()
	
	$life_tag.set_life(life)
	
	fill_life()
	
	change_time()
	
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
	call_deferred("queue_free")
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

func _on_radar_ally_in():
	ally = $radar.ally
	print("commander > ally in")
	pass # Replace with function body.

func _on_radar_ally_leave():
	ally = $radar.ally
	print("commander > ally exited")
	pass # Replace with function body.
