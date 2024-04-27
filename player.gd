extends Area2D

var motion = Vector2()
var rotation_head = 0
var limit
var thread =  Thread.new()
var life = 200
export (PackedScene) var Bullet
var time = 8 # time between every key press of the type ( up, down , left , right )
var id = "player"
var dimention_x
var dimention_y

# Called when the node enters the scene tree for the first time.
func _ready():
	
	hide()
	$life_tag.set_life(life)
	
	thread.start( self , "change_rotation")
		
	pass

func change_direction(position,delta):
	
	$AnimatedSprite.animation = "speed1"
	var speed = 200
	
	if Input.is_action_pressed("ui_down") and !$direction_collision.down_is_colliding() :
		if rotation_head == 90:
			$AnimatedSprite.animation = "step_back"
		elif rotation_head == 0 or rotation_head == 360:
			$AnimatedSprite.animation = "desplace_left"
		elif rotation_head == 180:
			$AnimatedSprite.animation = "desplace_right"
		else:
			$AnimatedSprite.animation = "speed3"
		
		motion.y += speed
	
	if Input.is_action_pressed("ui_up") and !$direction_collision.up_is_colliding():
		
		if rotation_head == 270:
			$AnimatedSprite.animation = "step_back"
		elif rotation_head == 0 or rotation_head == 360:
			$AnimatedSprite.animation = "desplace_right"
		elif rotation_head == 180:
			$AnimatedSprite.animation = "desplace_left"
		else:
			$AnimatedSprite.animation = "speed3"
		
		motion.y += - speed
	
	if Input.is_action_pressed("ui_left") and !$direction_collision.left_is_colliding():
		
		if rotation_head == 90:
			$AnimatedSprite.animation = "desplace_right"
		elif rotation_head == 270:
			$AnimatedSprite.animation = "desplace_left"
		elif rotation_head == 0 or rotation_head == 360 :
			$AnimatedSprite.animation = "step_back"
		else:
			$AnimatedSprite.animation = "speed3"
			
		motion.x += - speed
	
	if Input.is_action_pressed("ui_right") and !$direction_collision.right_is_colliding():
		
		if rotation_head == 90:
			$AnimatedSprite.animation = "desplace_left"
		elif rotation_head == 270:
			$AnimatedSprite.animation = "desplace_right"
		elif rotation_head == 180 :
			$AnimatedSprite.animation = "step_back"
		else:
			$AnimatedSprite.animation = "speed3"
			
		motion.x +=  speed
	
	position += motion * delta
	
	position.x = clamp(position.x , 50 , dimention_x  )  
	position.y = clamp(position.y , 0 , dimention_y  ) 

	return position 

func rotate_clock_wise():
	
	rotation_degrees +=5
	$direction_collision.rotation_degrees -=5
	rotation_head += -5
	pass

func rotate_against_clock_wise():
	
	rotation_degrees += -5
	$direction_collision.rotation_degrees += 5
	rotation_head += 5
	pass

func change_rotation():
		
	while true:
		
		if Input.is_action_pressed("actionD"):
				rotate_clock_wise()
		
		if  Input.is_action_pressed("actionA"):
				rotate_against_clock_wise()		

		if rotation_head == -45:
			rotation_head = 315
		elif rotation_head == 405:
			rotation_head = 45
		
		OS.delay_msec(120)
		
	pass

func fill_life():
	
	if life < 200 and time == 0:
		life += 0.1
	
	pass   

func change_time():
	
	if time == 0 : 
		time = 8
		pass
	else: 
		time -= 1

	pass

func _physics_process(delta):

	motion = Vector2()
	
	$life_tag.set_life(life)

	position =  change_direction(position,delta)

	fill_life()

	shot()
	
	change_time()
	
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

func shot():
	
	if Input.is_action_just_pressed("space"):
		
		var my_shot = Bullet.instance()
		get_tree().current_scene.add_child(my_shot) # set the bullet as child of world
	
		my_shot.rotate(rotation) # give rotation bullet
		var shot_direction = direction_head() # give direction to bullet
		my_shot.position = $head.global_position # give postion to bullet
	
		my_shot.set_direction(shot_direction) #shot
		
		pass	
	pass

func direction_head():
	
	var magnitude = 1.0  # Magnitude (length) of the vector
	var vector = Vector2(magnitude, 0).rotated(rotation)
	
	return vector	

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

func destroy_sound():
	
	var player_dead = get_parent().player_dead.instance()
	add_child(player_dead) 
	player_dead.play()
	pass

func _on_player_area_entered(area):

	if area.id == "enemy":
		ship_explotion()
		destroy_sound()
	elif area.id == "friend":
		ship_explotion()
		destroy_sound()
	elif area.id == "commander":
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

func _on_direction_collision_restart_position():
	
	global_position = $direction_collision.last_avaliable_pos
	
	pass # Replace with function body.
